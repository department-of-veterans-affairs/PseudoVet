"""
Dataset configuration service.

The dataset configuration will be stored in the file named DatasetConfiguration.<title>.json.
If the file with such name already exists, it will be overwritten.
"""

from os.path import isfile, join, relpath, exists
from os import listdir, remove

from cerberus import Validator

from config import GENERATED_DATASETS_DIR, DATASET_CONFIGURATIONS_DIR, CONFIGURATION_PREFIX
from randomizer.pseudo_vets import get_icd_morbidity_name_by_code
from rest.decorators import service, custom_validators
from rest.errors import EntityNotFoundError, InnerServerError, BadRequestError
from rest.services.datasources_service import get_war_era_by_name, get_morbidities_from_war_code, \
    convert_raw_war

from flask.json import dumps, load

# the war era validation schema
war_era_schema = {
    'warEra': {'type': 'string', 'required': True},
    'warEraCode': {'type': 'string'},
    'warEraStartDate': {'type': 'string'},
    'percentage': {'type': 'float'},
    'warEraEndDate': {'type': 'string'},
}

# the morbidity validation schema
morbidity_schema = {
    'name': {'type': 'string'},
    'icd10Code': {'type': 'string', 'required': True},
    'percentOfPopulationWithDiagnosisRisk': {'type': 'float'},
    'percentOfProbabilityToAcquireDiagnosis': {'type': 'float'},
    'numberOfEncounters': {'type': 'integer'},
    'exclusionRules': {'type': 'string'},
}

# the related conditions validation schema
relatedConditions_schema = {
    'name': {'type': 'string'},
    'icd10Code': {'type': 'string', 'required': True},
    'percentOfPopulationWithDiagnosisRisk': {'type': 'float'},
    'percentOfProbabilityToAcquireDiagnosis': {'type': 'float'},
    'numberOfEncounters': {'type': 'integer'},
    'exclusionRules': {'type': 'string'},
}

# the configuration validation schema
dataset_configuration_schema = {
    'title': {'type': 'string', 'required': True},
    'warEra': {'type': 'dict', 'schema': war_era_schema, 'required': True},
    'numberOfPatients': {'type': 'integer', 'required': True},
    'maleRatio': {'type': 'float', 'required': False},
    'femaleRatio': {'type': 'float', 'required': False},
    # Cerberus currently doesn't support validation of list elements properly
    # thus morbiditiesData & relatedConditions items are validated separately
    'morbiditiesData': {'type': 'list', 'minlength': 1, 'required': True},
    'relatedConditionsData': {'type': 'list', 'required': False},
    'outputFolder': {'type': 'string'},
    'outputFormat': {'type': 'string', 'required': True, 'allowed': ['CCDA', 'FHIR-XML', 'FHIR-JSON', ]},
    'year': {'type': 'integer', 'required': True},
}

# create validator for "morbiditiesData" items
cerberus_validator = Validator()


def validate_document(document):
    """
    Validate the given document. Check only body_entity.morbiditiesData elements.
    Raise BadRequestError if validation failed.
    :param document: the document to be validated
    :return: None
    """
    if 'body_entity' in document:
        body_entity = document['body_entity']
        if 'morbiditiesData' in body_entity:
            morbidities_data = body_entity['morbiditiesData']
            for item in morbidities_data:
                if not cerberus_validator.validate(item, morbidity_schema):
                    raise BadRequestError("Request validation failed for morbiditiesData. Info: " +
                                          str(cerberus_validator.errors))
        if 'relatedConditionsData' in body_entity:
            relatedConditions_data = body_entity['relatedConditionsData']
            for item in relatedConditions_data:
                if not cerberus_validator.validate(item, relatedConditions_schema):
                    raise BadRequestError("Request validation failed for relatedConditionsData. Info: " +
                                          str(cerberus_validator.errors))


# register custom validator to validate "morbiditiesData" items
custom_validators.append(validate_document)


@service(
    schema={
        'body_entity': {'type': 'dict', 'schema': dataset_configuration_schema}
    }
)
def save(body_entity):
    """
    Check whether the body entity warEra and morbidities exist or not.
    Then save it to the local file system.
    :param body_entity: the request dataset configuration entity
    :return: the same fully populated dataset configuration entity
    """

    # make sure war era exists
    war_era = get_war_era_by_name(body_entity['warEra']['warEra'])
    # update request war era
    body_entity['warEra'] = convert_raw_war(war_era)

    total_morbidities = get_morbidities_from_war_code(war_era['war_code'])

    for request_morbidity in body_entity['morbiditiesData']:
        morbidity_code = request_morbidity['icd10Code']
        # check whether morbidity exists in CSV file of the specified war
        morbidity_exists = False
        for morbidity in total_morbidities:
            if morbidity_code == morbidity['icd10Code']:
                # set or update morbidity name in request
                request_morbidity['name'] = morbidity['name']
                morbidity_exists = True
                break

        # if not found, try to find morbidity in ICD-10 datasource
        if not morbidity_exists:
            morbidity_name = get_icd_morbidity_name_by_code(morbidity_code)
            if morbidity_name:
                # set or update morbidity name in request
                request_morbidity['name'] = morbidity_name
                morbidity_exists = True

        if not morbidity_exists:
            raise EntityNotFoundError('Morbidity with ICD-10 code {0} is unknown'.format(morbidity_code))

    # set default output folder to the configuration
    output_folder = GENERATED_DATASETS_DIR
    # try to use short relative to the current directory path if possible
    try:
        output_folder = relpath(output_folder)
    except ValueError:
        pass
    body_entity['outputFolder'] = output_folder

    configuration_file = DATASET_CONFIGURATIONS_DIR + '/' + CONFIGURATION_PREFIX + '.' + body_entity['title'] + '.json'
    try:
        with open(configuration_file, 'w') as f:
            f.write(dumps(body_entity, indent=2))
        return body_entity

    except Exception as e:
        raise InnerServerError('Cannot save file {0}. Error: {1}'.format(configuration_file, e))


def read_configuration_from_file(file_path):
    """
    Read configuration from file with the specified path.
    :param file_path: the configuration file path
    :return: the configuration entity
    """
    try:
        with open(file_path, 'rU') as f:
            return load(f)
    except Exception as e:
        raise InnerServerError('Cannot read file {0}. Error: {1}'.format(file_path, e))


@service(schema={'title': {'type': 'string', 'nullable': True}})
def get(title):
    """
    Get configuration by title. If title is None, then return all configurations.
    :param title: the configuration title
    :return: the list with configuration entities
    """
    if title is None:  # return all configurations
        configurations = []
        files = [f for f in listdir(DATASET_CONFIGURATIONS_DIR) if isfile(join(DATASET_CONFIGURATIONS_DIR, f))]
        for file in files:
            configurations.append(read_configuration_from_file(DATASET_CONFIGURATIONS_DIR + '/' + file))
        return sorted(configurations, key=lambda k: k['title'].lower())
    else:
        # put single configuration to a list
        return [get_configuration_by_title(title)]


def get_configuration_by_title(title):
    """
    Get single configuration with the specified title
    :param title: the configuration title
    :return: the dataset configuration instance
    """
    configuration_file_path = DATASET_CONFIGURATIONS_DIR + '/' + CONFIGURATION_PREFIX + '.' + title + '.json'
    if isfile(configuration_file_path):
        return read_configuration_from_file(configuration_file_path)
    else:
        raise EntityNotFoundError('Cannot find configuration file for title ' + title)


@service(schema={'title': {'type': 'string', 'required': True}})
def delete_config_by_title(title):
    """
    Delete dateset Config by title
    It raises EntityNotFoundError if dataset config not found
    :param title: the dataset Config title
    """

    config_file = join(DATASET_CONFIGURATIONS_DIR, '{0}.{1}.{2}'.format(CONFIGURATION_PREFIX, title, 'json'))
    if not exists(config_file):
        raise EntityNotFoundError("Dataset config not found where title = " + title)
    remove(config_file)
