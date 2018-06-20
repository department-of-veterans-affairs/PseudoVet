"""
the data source service , the service used to read csv content and cache the content.
because of military_eras.csv and morbidity_xxxx.csv are static files local in data source dir,
and most endpoint need check the study profiles, etc.. data, so this service must be cache data sources
to avoid read file for each request.
"""

import datetime
import csv

from rest.decorators import service
from rest.logger import logger
from config import DATASOURCES_DIR
from rest.errors import EntityNotFoundError

# use this list to cache study profiles data
military_eras = None

# use the map to cache morbidities data, the cache key is the study_profile_code
morbidity_map = {}


@service(
    schema={'study_profile': {'type': 'string', 'required': True}}
)
def get_morbidities_for_study_profile(study_profile):
    """
    get morbidities data by study_profile name , it will return 404 if didn't found study_profile
    :param study_profile: the study profile name
    :return: the morbidities data
    """
    study_profile_code = get_study_profile_by_name(study_profile)['study_profile_code']
    return get_morbidities_from_study_profile_code(study_profile_code)


@service()
def get_study_profiles():
    """
    Get data for all study profiles
    :return:  the list with study profiles data
    """
    study_profile_list = get_study_profiles_from_file()
    return list(map(lambda study_profile: convert_raw_study_profile(study_profile), study_profile_list))


def convert_raw_study_profile(study_profile):
    """
    Convert raw study profile to request study profile entity
    :param study_profile: the raw study profile
    :return: the request study profile
    """
    return {
        'studyProfile': study_profile['study_profile_name'],
        'studyProfileCode': study_profile['study_profile_code'],
        'studyProfileStartDate': study_profile['start_date'],
        'studyProfileEndDate': study_profile['end_date']
    }


def get_study_profile_by_name(name):
    """
    Get study profile by its name. Raises EntityNotFoundError if not found.
    :param name: the study profile name
    :return: the study profile details
    """
    study_profiles = get_study_profiles_from_file()
    filter_study_profiles = list(filter(lambda w: w['study_profile_name'] == name, study_profiles))
    if len(filter_study_profiles) <= 0:
        raise EntityNotFoundError('Cannot find study profile with name ' + name)
    return filter_study_profiles[0]


def get_morbidities_from_study_profile_code(study_profile_code, include_percentage=False):
    """
    Get morbidities by study profile code. If the result is already cached, then return the cached result.
    If not found raise EntityNotFoundError
    :param study_profile_code: the study profile code
    :param include_percentage: True if percentage of morbidity should be added to output, False otherwise
    :return: the list with morbidities data
    """
    global morbidity_map

    if morbidity_map.get(study_profile_code) is not None:  # return cached data
        return morbidity_map.get(study_profile_code)

    file_path = DATASOURCES_DIR + '/morbidity_' + study_profile_code + '.csv'
    try:
        with open(file_path, 'rU') as csv_file:
            morbidity_raw_list = csv.reader(csv_file, delimiter=',', quotechar='"')
            morbidity_list = []
            first = True
            for row in morbidity_raw_list:
                if first:  # skip first row with header
                    first = False
                    continue
                item = {'name': row[0], 'icd10Code': row[1]}
                if include_percentage:
                    item['percentOfProbabilityToAcquireDiagnosis'] = float(row[2])
                morbidity_list.append(item)
            morbidity_map[study_profile_code] = morbidity_list
            return morbidity_list
    except Exception as e:
        logger.error(e)
        raise EntityNotFoundError('Could not open {0}. Error: {1}'.format(file_path, e))


def str_to_datetime(str_time):
    """
    Convert CSV str time to datetime. If input is empty or None, return None.
    :param str_time: the str time from CSV file
    :return: the datetime or None
    """
    if str_time is None or str_time == '':
        return None

    return datetime.datetime.strptime(str_time, "%d-%b-%Y").date()


def get_study_profiles_from_file():
    """
    Get study profiles from file. Return cache result if data is already cached.
    :return: the study profiles
    """
    global military_eras
    if military_eras is not None:
        # return cached data
        return military_eras

    study_profiles_data_path = DATASOURCES_DIR + '/military_eras.csv'
    try:
        # load the military_eras datasource
        with open(study_profiles_data_path, 'rU') as csv_file:
            military_eras_list = csv.reader(csv_file, delimiter=',', quotechar='"')
            military_eras = []
            for row in military_eras_list:
                if row[0] == 'study_profile_code':  # skip first element (titles row)
                    continue

                study_profile_code = row[0]
                study_profile_name = row[1]
                percentage = float(row[2])
                start_date = str_to_datetime(row[3])
                end_date = str_to_datetime(row[4])

                military_eras.append({"study_profile_code": study_profile_code,
                                      "study_profile_name": study_profile_name,
                                      "percentage": percentage,
                                      "start_date": start_date,
                                      "end_date": end_date})
            return military_eras
    except Exception as e:
        logger.error('Could not open {0}. Error: {1}'.format(study_profiles_data_path, e))
