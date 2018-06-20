import datetime
import io
import json
import os
import types
from collections import OrderedDict
from datetime import timedelta

import shutil
from dateutil.relativedelta import relativedelta
from random import randint
from random import shuffle
from random import random

from randomizer import datasource_methods
from rest.errors import EntityNotFoundError
from rest.logger import logger
from .renderer import Renderer
from config import DATASOURCES_DIR, GENERATED_DATASETS_DIR, ICD_10_CODES_FILE_PATH, MIN_PATIENT_AGE_ON_STUDY_PROFILE_START, \
    MAX_PATIENT_AGE_ON_STUDY_PROFILE_START, MIN_DAYS_TILL_FIRST_REPORT_AFTER_STUDY_PROFILE_START, \
    MAX_DAYS_TILL_FIRST_REPORT_AFTER_STUDY_PROFILE_START, MIN_DAYS_BETWEEN_FIRST_REPORT_AND_MAX_DATE, DEATH_AGE_MEAN, \
    DEATH_AGE_DEVIATION, MIN_DAYS_BETWEEN_REPORTS, MAX_DAYS_BETWEEN_REPORTS, MAX_DAYS_BETWEEN_BIRTH_AND_DIAGNOSIS_DATE, \
    MIN_DAYS_TILL_MORBIDITY_RESOLUTION, MAX_DAYS_TILL_MORBIDITY_RESOLUTION, DATASET_PREFIX
from rest.services.datasources_service import get_study_profiles_from_file, get_morbidities_from_study_profile_code

# Global variables
data_source = None
work_dir = None
session_id = None
military_eras = None
study_profile_lines = None
icd_morbidity_name_by_code = None

# setup a Jinja2 template renderer
renderer = Renderer()

# accurate average number of days in year
DAYS_IN_YEAR = 365.2425


def setup_work_session(output_dir, create_session_path=True, config_title=None, output_format='CCDA'):
    """
    Create a unique work folder for the current session
    :param output_dir: the output directory for generated dataset files
    :param create_session_path: True if session directory should be created, False otherwise
    :param config_title: the config title used
    :param output_format: the output format
    :return: None
    """
    global work_dir
    global session_id

    # generate new session ID from the current timestamp
    session_id = config_title and '{0}.{1}.{2}.{3}'.format(
        DATASET_PREFIX,
        config_title,
        datetime.datetime.now().strftime("%Y%m%d%H%M%S"),
        output_format) or datetime.datetime.now().isoformat().replace(':', '')
    work_dir = output_dir

    # load data sources if they haven't been loaded previously
    if not data_source:
        load_datasources()

    if not os.path.exists(work_dir):
        os.makedirs(work_dir)

    if create_session_path:
        # create subfolder for the current session
        session_path = "%(work_dir)s/%(session_id)s" % globals()
        # try to use short relative to the current directory path if possible
        try:
            session_path = os.path.relpath(session_path)
        except ValueError:
            pass

        if os.path.exists(session_path):
            shutil.rmtree(session_path)
        os.mkdir(session_path)
        logger.info("Using output folder " + session_path)


def load_datasources():
    """
    Load datasource.json, military eras and ICD-10 code/name pairs, terminate if error occurs
    """
    global data_source
    global military_eras

    # load datasource.json with generation rules for patient fields
    data_source_file = DATASOURCES_DIR + '/datasource.json'
    try:
        with open(data_source_file) as data_file:
            data_source = json.load(data_file, object_pairs_hook=OrderedDict)
    except Exception as e:
        logger.error('Could not open {0}. Error: {1}'.format(data_source_file, e))

    if data_source is None or len(data_source) == 0:
        logger.error('Datasource not defined. Cannot continue.')
        exit(1)

    # load all study profiles
    military_eras = get_study_profiles_from_file()

    # load ICD-10 code/name pairs
    load_icd10_codes()


def load_icd10_codes():
    """
    Read icd10cm_codes_2018.txt file, extract code/name pairs of known morbidities from it.
    The result is saved to the global icd_morbidity_name_by_code variable.
    :return: None
    """
    global icd_morbidity_name_by_code
    icd_morbidity_name_by_code = {}

    # load the ICD-10 datasource
    try:
        logger.info('Reading ICD-10 datasource...')
        lines_num = 0
        for line in open(ICD_10_CODES_FILE_PATH):
            code = line[:8].strip()
            name = line[8:].strip()
            icd_morbidity_name_by_code[code] = name
            lines_num += 1
        logger.info('Loaded {0} records from ICD-10 datasource'.format(lines_num))
    except Exception as e:
        logger.error('Could not open {0}. Error: {1}'.format(ICD_10_CODES_FILE_PATH, e))
        raise


def get_icd_morbidity_name_by_code(code):
    """
    Get ICD-10 morbidity name by its code. Return None if the code is unknown.
    :param code: the morbidity ICD-10 code
    :return: the morbidity name
    """
    # load codes if required
    if icd_morbidity_name_by_code is None:
        load_icd10_codes()

    return icd_morbidity_name_by_code.get(code)


def timedelta_years(years):
    """
    Creates timedelta for the specified number of years. Then this value can be added to datetime.
    :param years: the number of years
    :return: the timedelta object
    """
    return timedelta(days=years * DAYS_IN_YEAR)


def random_patient(index, study_profile, end_year):
    """
    Build a patient record to be used as base for template rendering and aging
    :param index: the 1-based index of the patient in the current dataset
    :param study_profile: the study profile entity
    :param end_year: the end year for generated reports
    :return: None
    """
    global session_id
    global data_source

    patient_id = '{session_id}-{index}'.format(session_id=session_id, index=index)

    # initialize dictionary with patient data
    patient = {
        'index': index,
        'study_profile': study_profile,
        'patient_id': patient_id,
        'icd_problems': [],
        'expected_problems': []
    }

    # assume that patient is between 18 and 40 years old when the study profile starts
    age_on_study_profile_start = randint(MIN_PATIENT_AGE_ON_STUDY_PROFILE_START, MAX_PATIENT_AGE_ON_STUDY_PROFILE_START)

    # generate random birth date
    study_profile_start_date = study_profile['start_date']
    date_of_birth = study_profile_start_date - timedelta_years(age_on_study_profile_start) - timedelta(days=randint(0, 365))
    patient['date_of_birth'] = date_of_birth

    # generate random death age based on configured mean and deviation (use uniform distribution)
    death_age = randint(DEATH_AGE_MEAN - DEATH_AGE_DEVIATION, DEATH_AGE_MEAN + DEATH_AGE_DEVIATION)
    date_of_death = date_of_birth + timedelta_years(death_age) + timedelta(days=randint(0, 365))
    patient['expected_death_age'] = death_age
    patient['expected_date_of_death'] = date_of_death

    # calculate number of days between study profile start and report end date or death date
    end_date = datetime.date(end_year, 12, 31)
    days_till_end = (min(date_of_death, end_date) - study_profile_start_date).days

    # generate date of the first report between study profile start and end/death date
    days_after_study_profile_start = randint(MIN_DAYS_TILL_FIRST_REPORT_AFTER_STUDY_PROFILE_START,
                                             min(MAX_DAYS_TILL_FIRST_REPORT_AFTER_STUDY_PROFILE_START,
                                             days_till_end - MIN_DAYS_BETWEEN_FIRST_REPORT_AND_MAX_DATE))
    report_date = study_profile_start_date + timedelta(days=days_after_study_profile_start)
    patient['effective_time'] = report_date

    # calculate age of patient on report generation date
    total_age = min(death_age, relativedelta(report_date, date_of_birth).years)
    patient['total_age'] = total_age

    patient['date_of_death'] = date_of_death if report_date >= date_of_death else None

    # add more fields as defined in datasource.json
    for field in data_source:
        if "repeat_max" in data_source[field]:
            # this field should be an array of repeatable items
            # build a list of repeat_max items
            value = []
            max_index = randint(1, data_source[field]["repeat_max"])
            for idx in range(0, max_index):
                value.append(get_rand_value(field, patient))
        else:
            value = get_rand_value(field, patient)

        patient[field] = value

    return patient


def populate_current_problems(patient):
    """
    Initializes "icd_problems" field of the given patient by taking "expected_problems" and "effective_date"
    into account. Only problems that have diagnosis date >= report date are added to the list.
    :param patient: the patient to be updated
    :return: None
    """
    report_date = patient['effective_time']
    expected_problems = patient['expected_problems']
    problems = [x for x in expected_problems if x['onset'] <= report_date]

    # mark appropriate problems as resolved
    for problem in problems:
        if problem['expected_resolution_date'] <= report_date:
            problem['resolved'] = True
            problem['resolved_on'] = problem['expected_resolution_date']
        else:
            problem['resolved'] = False
            problem['resolved_on'] = None

    patient['icd_problems'] = problems


def get_rand_value(field, patient):
    """
    Generate a new random value calling a datasource method, from a linked field or just
    read from the datasource.json definition
    """
    global data_source

    if "method" in data_source[field]:
        # some fields define a method call to be made
        method_name = data_source[field]["method"]
        method_params = [patient] + data_source[field]["params"]

        if isinstance(datasource_methods.__dict__.get(method_name), types.FunctionType):
            method = datasource_methods.__dict__.get(method_name)
            return method(method_params)
    else:
        if "linked_to" in data_source[field]:
            # some fields are linked to other fields, gender => gender_code(defined first)
            value_key = patient[data_source[field]["linked_to"]]
            value = data_source[field]["values"][value_key]
        else:
            if "values_from" in data_source[field]:
                # some fields share the same data set values
                values_from_field = data_source[field]["values_from"]
                field_values = data_source[values_from_field]["values"]
            else:
                field_values = data_source[field]["values"]

            value_index = randint(0, len(field_values) - 1)
            value = field_values[value_index]
        return value


def age_patient(patient, end_year):
    """
    Based on last aged 'patient' information determines the future field values at 'years',
    biological (calculated values) and non-biological (new random values) fields are considered.
    'patient' contains the last aged patient (previous aging)
    :param patient: the patient to be aged
    :param end_year: the report end year
    :return: True if aging was performed successfully, False if report end year is reached
    """
    global data_source

    death_age = patient['expected_death_age']
    date_of_death = patient['expected_date_of_death']

    last_report_date = patient['effective_time']

    # randomly generate the number of days till the next report
    days_till_next_report = randint(MIN_DAYS_BETWEEN_REPORTS, MAX_DAYS_BETWEEN_REPORTS)
    report_date = last_report_date + timedelta(days=days_till_next_report)

    # stop if report date has year greater than the specified end year
    if report_date.year > end_year:
        return False

    patient['effective_time'] = report_date

    if report_date >= date_of_death:
        patient['date_of_death'] = date_of_death

    # calculate age of patient on report generation date
    new_age = min(death_age, relativedelta(report_date, patient['date_of_birth']).years)
    patient['total_age'] = new_age

    for field in data_source:
        value = patient[field]

        if "aging" in data_source[field]:
            # check if field aging should be performed with some probability instead of constantly
            if "aging_prob" in data_source[field]:
                aging_prob = float(data_source[field]["aging_prob"])
                if random() > aging_prob:
                    # don't need to change this field
                    continue

            if data_source[field]["aging"] is True:
                # only generate a new random value
                value = get_rand_value(field, patient)
            else:
                # biological aging
                aging_dict = data_source[field]["aging"]
                # find key that is the closest to the current patient age
                best_changes = None
                best_age_diff = 1000
                for key_age in aging_dict:
                    # calculate how close key_age is to new_age
                    diff = abs(int(key_age) - new_age)
                    if diff < best_age_diff:
                        best_age_diff = diff
                        best_changes = aging_dict[key_age]

                if best_changes:
                    change = best_changes[randint(0, len(best_changes) - 1)]
                    value = float(value)
                    value += change
                    value = format(value, '.2f')

        patient[field] = value

    # add new problems and resolve existing ones
    populate_current_problems(patient)

    return True


def create_file(record, output_format):
    """
    Create an XML output file for the given patient
    :param record: the patient record to be saved to a file
    :param output_format: the output format
    :return: None
    """
    global renderer
    global work_dir
    global session_id

    index = record['index']
    age = record['total_age']
    result = renderer.render(record, output_format)
    file_extension = 'xml'
    if output_format in ['FHIR-JSON', ]:
        file_extension = 'json'
    filename = "{work_dir}/{session_id}/{session_id}-{index}_{age}.{extension}".format(
        work_dir=work_dir, session_id=session_id, index=index, age=age, extension=file_extension)

    with io.open(filename, 'w', encoding='utf-8') as f:
        f.write(result)


def set_gender_fields(patients, male_perc):
    """
    Randomly set "gender" and "gender_code" properties to the provided patients, but preserve required
    male percentage
    :param patients: the array with patient entities
    :param male_perc: the desired male percentage of patients (between 0 and 100)
    :return: None
    """
    # calculate desired number of males
    males_num = int(len(patients) * male_perc * 0.01)

    # create list of all patient indexes and shuffle it
    patient_indexes = [i for i in range(len(patients))]
    shuffle(patient_indexes)

    # assume that only first males_num indexes correspond to males
    for i in range(len(patient_indexes)):
        is_male = i < males_num
        patient = patients[patient_indexes[i]]
        patient['gender_code'] = "M" if is_male else "F"
        patient['gender'] = "Male" if is_male else "Female"


def apply_morbidity(patients, morbidity_data):
    """
    Modify "icd_problems" field of the given patients by applying the given morbidity data
    :param patients: the list of patients to be updated
    :param morbidity_data: the details of a single morbidity to be applied
    :return: None
    """
    # calculate the number of patients with diagnosis
    if 'numberOfEncounters' in morbidity_data:
        diagnoses_num = int(morbidity_data['numberOfEncounters'])
    else:
        risk_perc = 100
        acquire_perc = 100
        if 'percentOfPopulationWithDiagnosisRisk' in morbidity_data:
            risk_perc = float(morbidity_data['percentOfPopulationWithDiagnosisRisk'])
        if 'percentOfProbabilityToAcquireDiagnosis' in morbidity_data:
            acquire_perc = float(morbidity_data['percentOfProbabilityToAcquireDiagnosis'])

        # number of diagnoses equals to the total number of patients multiplied by
        # risk factor and diagnosis acquirement probability
        diagnoses_num = int(round(len(patients) * risk_perc * 0.01 * acquire_perc * 0.01))

    # detect affected patients if exclusion rules are specified
    if 'exclusionRules' in morbidity_data:
        rules = morbidity_data['exclusionRules']
        affected_patients = []
        for patient in patients:
            try:
                exclude = eval(rules, patient)
                # if script returns anything except True and False, report an error
                if type(exclude) is not bool:
                    raise ValueError()
            except Exception:
                raise ValueError("Invalid exclusion rules format: {0}".format(rules))
            if not exclude:
                affected_patients.append(patient)
    else:
        # make a copy of the list so it can be shuffled later
        affected_patients = patients.copy()

    # shuffle affected patients and assume that first diagnoses_num patients have diagnoses
    shuffle(affected_patients)

    diagnoses_num = min(diagnoses_num, len(affected_patients))

    for idx in range(diagnoses_num):
        patient = affected_patients[idx]
        date_of_birth = patient['date_of_birth']

        # generate random date when this diagnosis appeared
        # multiplication by sqrt(random()) is used for increasing the number of diagnoses in early ages
        diagnosis_date = date_of_birth + timedelta(days=randint(0, MAX_DAYS_BETWEEN_BIRTH_AND_DIAGNOSIS_DATE) *
                                                        (random() ** 0.5))
        resolved_on = diagnosis_date + timedelta(days=randint(MIN_DAYS_TILL_MORBIDITY_RESOLUTION,
                                                              MAX_DAYS_TILL_MORBIDITY_RESOLUTION))
        patient['expected_problems'].append({
            'code': morbidity_data['icd10Code'],
            'name': morbidity_data['name'],
            'onset': diagnosis_date,
            'expected_resolution_date': resolved_on
        })


def generate_records(study_profile, patients_num, male_perc, morbidities_data, end_year, output_format):
    """
    Generates dataset record files using the specified parameters.
    :param study_profile: the study profile data dictionary (just name of code can be specified)
    :param patients_num: the number of patients
    :param male_perc: the male percentage of patients (between 0 and 100)
    :param morbidities_data: the list with morbidities details
    :param end_year: the end year for generated reports
    :param output_format: the output format
    :return: the total number of created report files
    """
    logger.info('Creating {0} fictional patient{1}...'.format(patients_num, "s" if patients_num > 1 else ""))

    # first generate required number of random patients
    patients = [random_patient(idx, study_profile, end_year) for idx in range(1, patients_num + 1)]

    set_gender_fields(patients, male_perc)

    for morbidity_data in morbidities_data:
        apply_morbidity(patients, morbidity_data)

    files_num = 0

    for patient in patients:
        # sort expected problems by diagnosis date to make them appear sequentially in the report
        patient['expected_problems'].sort(key=lambda p: p['onset'])

        # initialize initial morbidities
        populate_current_problems(patient)

        # save initial report for the current patient
        create_file(patient, output_format)
        patient_files_num = 1
        initial_problems_num = len(patient['icd_problems'])

        # create and save new reports while patient is alive
        while patient['date_of_death'] is None:
            if not age_patient(patient, end_year):
                break
            create_file(patient, output_format)
            patient_files_num += 1

        final_problems_num = len(patient['icd_problems'])
        logger.info("Generated {0} files for {1} patient with {2} problems".format(
            patient_files_num, patient['gender'].lower(),
            "no" if final_problems_num == 0
            else initial_problems_num if initial_problems_num == final_problems_num
            else str(initial_problems_num) + '-' + str(final_problems_num)))
        files_num += patient_files_num

    logger.info('Successfully generated {0} report files'.format(files_num))

    return files_num


def get_full_study_profile(study_profile):
    """
    Get full study profile data by its name or code
    :param study_profile: the dictionary with available study profile data (name or code)
    :return: the dictionary with full study profile data or None if not found
    """
    study_profiles = get_study_profiles_from_file()

    # try to find study profile by name
    if 'studyProfile' in study_profile:
        study_profile_name = study_profile['studyProfile']
        filtered_study_profiles = list(filter(lambda w: w['study_profile_name'] == study_profile_name, study_profiles))
        if len(filtered_study_profiles) == 0:
            return None
        return filtered_study_profiles[0]

    # try to find study profile by code
    if 'studyProfileCode' in study_profile:
        study_profile_code = study_profile['studyProfileCode']
        filtered_study_profiles = list(filter(lambda w: w['study_profile_code'] == study_profile_code, study_profiles))
        if len(filtered_study_profiles) == 0:
            return None
        return filtered_study_profiles[0]

    return None


def generate_from_config(dataset_config):
    """
    Generate dataset records using the provided dataset configuration parameters and save them to files
    :param dataset_config: the dataset configuration dictionary
    :return: None
    """

    output_format = dataset_config.get('outputFormat', 'CCDA')
    if 'studyProfile' not in dataset_config:
        raise ValueError('Study profile is missing in the dataset configuration')
    study_profile = dataset_config['studyProfile']
    full_study_profile = get_full_study_profile(study_profile)
    if full_study_profile is None:
        raise ValueError('Invalid study profile is specified in the dataset configuration: {0}'.format(study_profile))

    if 'numberOfPatients' not in dataset_config:
        raise ValueError('Number of patients is missing in the dataset configuration')
    patients_num = dataset_config['numberOfPatients']
    if patients_num <= 0:
        raise ValueError("Dataset configuration contains invalid number of patients: {0}".format(patients_num))

    # detect male/female ratios, default is 100% males
    male_ratio = 100
    if 'maleRatio' in dataset_config:
        male_ratio = float(dataset_config['maleRatio'])
        if 'femaleRatio' in dataset_config and male_ratio + float(dataset_config['femaleRatio']) != 100:
            raise ValueError("Both male ({0}) and female ({1}) ratios are specified in the dataset configuration, "
                             "but their sum is not equal to 100".format(dataset_config['maleRatio'],
                                                                        dataset_config['femaleRatio']))
    elif 'femaleRatio' in dataset_config:
        male_ratio = 100 - float(dataset_config['femaleRatio'])

    if male_ratio < 0 or male_ratio > 100:
        raise ValueError("Dataset configuration contains invalid male ratio: {0}".format(male_ratio))

    # detect and check end year
    if 'year' not in dataset_config:
        raise ValueError('End report year is missing in the dataset configuration')
    end_year = dataset_config['year']
    if end_year <= full_study_profile['start_date'].year:
        raise ValueError('End report year must be greater than start date')

    # setup output directory
    cur_work_dir = GENERATED_DATASETS_DIR
    if 'outputFolder' in dataset_config:
        cur_work_dir = dataset_config['outputFolder']
    setup_work_session(cur_work_dir, True, dataset_config['title'], output_format)

    # retrieve morbidities from configuration or data source
    morbidities_data = None
    if 'morbiditiesData' not in dataset_config:
        study_profile_code = full_study_profile['study_profile_code']
        try:
            dataset_config['morbiditiesData'] = get_morbidities_from_study_profile_code(full_study_profile['study_profile_code'],
                                                                                        include_percentage=True)
        except EntityNotFoundError:
            raise ValueError('CSV file for study profile with code {0} does not exist'.format(study_profile_code))
        logger.info('Using morbidity probabilities of {0} from configuration file'.format(study_profile_code))
    morbidities_data = dataset_config['morbiditiesData']

    if ('relatedConditionsData' in dataset_config) and (len(dataset_config['relatedConditionsData']) > 0):
        morbidities_data.extend(dataset_config['relatedConditionsData'])

    return generate_records(full_study_profile, patients_num, male_ratio, morbidities_data, end_year, output_format)
