import os

# the rest api base prefix
APPLICATION_ROOT = '/api/v1'

# the logger level
LOG_LEVEL = 'DEBUG'

# the logger format
LOG_FORMAT = '%(asctime)s %(levelname)s : %(message)s'

# the Flask run mode: PROD or DEBUG
FLASK_RUN_MODE = os.environ.get('MODE') or 'PROD'

# the Flask run port
WEB_PORT = os.environ.get('PORT') or 5000

# the project directory
PROJECT_DIR = os.path.dirname(os.path.realpath(__file__))

# the randomizer templates directory
TEMPLATES_DIR = PROJECT_DIR + '/randomizer/templates'

# the randomizer CCDA format template file name
CCDA_TPL_FILENAME = 'continuity_of_care_document.xml'

# the randomizer FHIR format template file name
FHIR_TPL_FILENAME = 'fhir/fhir_document.json'

# the datasources directory
DATASOURCES_DIR = PROJECT_DIR + '/randomizer/datasources'

# the frontend directory
FRONTEND_DIR = PROJECT_DIR + '/frontend/dist'

# the path of the file with ICD-10 morbidity codes and names
ICD_10_CODES_FILE_PATH = DATASOURCES_DIR + '/ICD-10/icd10cm_codes_2018.txt'

# the dataset configurations directory
DATASET_CONFIGURATIONS_DIR = PROJECT_DIR + '/output/datasetConfigurations'

# the generated datasets directory
GENERATED_DATASETS_DIR = PROJECT_DIR + '/output/generatedDatasets'

# the dataset configuration file prefix
CONFIGURATION_PREFIX = 'DatasetConfiguration'

# the datasets directory prefix
DATASET_PREFIX = 'Dataset'

# the code of the default study profile
DEFAULT_STUDY_PROFILE_CODE = 'world_war_ii'

# the minimum age of generated patients on study profile start
MIN_PATIENT_AGE_ON_STUDY_PROFILE_START = 18

# the maximum age of generated patients on study profile start
MAX_PATIENT_AGE_ON_STUDY_PROFILE_START = 40

# the average death age of the generated patients
DEATH_AGE_MEAN = 79

# the deviation of death age of the generated patients
# death age is generated uniformly in the range [MEAN +/- DEVIATION]
DEATH_AGE_DEVIATION = 15

# the minimum number of days between the study profile start and the first report for a patient
MIN_DAYS_TILL_FIRST_REPORT_AFTER_STUDY_PROFILE_START = 100

# the maximum number of days between the study profile start and the first report for a patient
MAX_DAYS_TILL_FIRST_REPORT_AFTER_STUDY_PROFILE_START = 20 * 365

# the minimum number of days between the first report for a patient and a max date
# that can be their death date or the configured report end year
MIN_DAYS_BETWEEN_FIRST_REPORT_AND_MAX_DATE = 5 * 365

# the minimum number of days between reports for the same patient
MIN_DAYS_BETWEEN_REPORTS = 3 * 365

# the maximum number of days between reports for the same patient
MAX_DAYS_BETWEEN_REPORTS = 10 * 365

# the maximum number of days between patient's birth and morbidity diagnosis date
MAX_DAYS_BETWEEN_BIRTH_AND_DIAGNOSIS_DATE = 80 * 365

# the minimum number of days between morbidity diagnosis and resolution
MIN_DAYS_TILL_MORBIDITY_RESOLUTION = 30

# the maximum number of days between morbidity diagnosis and resolution
MAX_DAYS_TILL_MORBIDITY_RESOLUTION = 100
