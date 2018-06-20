# PseudoVet - VA Pseudovet Angular Frontend Python Backend Integration Challenge



## Backend local deploy

- Install python3, pip3, virtualenv
  - For Ubuntu, you need to run `sudo apt install python3 python3-pip virtualenv`
- Create Python virtual environment using the following commands:
  - `mkdir venv`
  - `virtualenv -p python3 venv`
  - `source venv/bin/activate`
- Install Python application dependencies: `pip3 install -r requirements.txt`




## Frontend local deploy

- install node v8.x ,npm 5.x
- build frontend
  - `cd ./frontend`
  - install dependencies, `npm i`
  - update backend url config baseUri in *frontend/src/environments/environment.prod.js* if you need
  - then run build `npm run build`

## Run

- For the CLI program (the old randomizer that now supports dataset configuration files), you can use `python pseudo_vets_cli.py`, for more details see *randomizer/README.md*
- For the REST server application, run `python3 pseudo_vets_server.py`

## Configuration

These are some configuration values that can be found in config.py

| configuration parameter name                         | description                                                       | environment key | default value                                          |
| ---------------------------------------------------- | ----------------------------------------------------------------- | --------------- | ------------------------------------------------------ |
| APPLICATION_ROOT                                     | the rest backend endpoint route prefix                            |                 | /api/v1                                                |
| LOG_LEVEL                                            | the backend log level                                             |                 | DEBUG                                                  |
| LOG_FORMAT                                           | the app log message format                                        |                 | %(asctime)s %(levelname)s : %(message)s                |
| FLASK_RUN_MODE                                       | the Flask run mode, DEBUG or PROD                                 | MODE            | PROD                                                   |
| WEB_PORT                                             | the Flask run web port                                            | PORT            | 5000                                                   |
| TEMPLATES_DIR                                        | the Jinja2 templates directory                                    |                 | ./randomizer/templates                                 |
| CCDA_TPL_FILENAME                                    | the CCDA template file                                            |                 | continuity_of_care_document.xml                        |
| FHIR_TPL_FILENAME                                    | the FHIR template file                                            |                 | fhir/fhir_document.json                                |
| DATASOURCES_DIR                                      | the path of datasource directory                                  |                 | ./randomizer/datasources                               |
| ICD_10_CODES_FILE_PATH                               | the file with ICD-10 codes and names                              |                 | ./randomizer/datasources/ICD-10/icd10cm_codes_2018.txt |
| DATASET_CONFIGURATIONS_DIR                           | the path of dataset config files dir                              |                 | ./output/datasetConfigurations                         |
| GENERATED_DATASETS_DIR                               | the generated datasets file dir path                              |                 | ./output/generatedDatasets                             |
| CONFIGURATION_PREFIX                                 | the datasource config file name prefix                            |                 | DatasetConfiguration                                   |
| DEFAULT_STUDY_PROFILE_CODE                       | the code of study profile to be used by default               |                 | world_war_ii                                           |
| MIN_PATIENT_AGE_ON_STUDY_PROFILE_START               | the minimum age of generated patients on study profile start      |                 | 18                                                     |
| MAX_PATIENT_AGE_ON_STUDY_PROFILE_START               | the maximum age of generated patients on study profile start      |                 | 40                                                     |
| DEATH_AGE_MEAN                                       | the average death age of the generated patients                   |                 | 79                                                     |
| DEATH_AGE_DEVIATION                                  | the deviation of death age of the generated patients              |                 | 15                                                     |
| MIN_DAYS_TILL_FIRST_REPORT_AFTER_STUDY_PROFILE_START | the min days from study profile start till 1st patient's report   |                 | 100                                                    |
| MAX_DAYS_TILL_FIRST_REPORT_AFTER_STUDY_PROFILE_START | the max days from study profile start till 1st patient's report   |                 | 20 * 365                                               |
| MIN_DAYS_BETWEEN_FIRST_REPORT_AND_MAX_DATE           | the min days between first report and death/end date              |                 | 5 * 365                                                |
| MIN_DAYS_BETWEEN_REPORTS                             | the min days between reports for the same patient                 |                 | 3 * 365                                                |
| MAX_DAYS_BETWEEN_REPORTS                             | the max days between reports for the same patient                 |                 | 10 * 365                                               |
| MAX_DAYS_BETWEEN_BIRTH_AND_DIAGNOSIS_DATE            | the max days between patient's birth and diagnosis date           |                 | 80 * 365                                               |
| MIN_DAYS_TILL_MORBIDITY_RESOLUTION                   | the min days between morbidity diagnosis and resolution           |                 | 30                                                     |
| MAX_DAYS_TILL_MORBIDITY_RESOLUTION                   | the max days between morbidity diagnosis and resolution           |                 | 100                                                    |
| DATASET_PREFIX                                       | the dataset folder prefix                                         |                 |                                                        |
| FRONTEND_DIR                                         | the frontend dist directory                                       |                 | ./frontend/dist                                        |

## Dataset configuration files

The recent version of tha applications support generation of reports based on JSON dataset configuration files that have the following format (note that comments are not allowed in real JSON files, all parameters are shown for clarity only, some of them conflict with each other and cannot appear at the same time):
```js
{
   // The title of the dataset configuraton. Is required when saving/retrieving configs via REST API.
   // Must not contain any characters that cannot be part of a valid file name.
  "title": "config-01",
  // The percentage of males in the generated dataset (between 0 and 100).
  // Only one of maleRatio and femaleRatio should be specified. The apps support 2 genders only.
  // When both parameters are missing, only male patients are generated.
  "maleRatio": 60,
  // The percentage of females in the generated dataset (between 0 and 100).
  // Only one of maleRatio and femaleRatio should be specified. The apps support 2 genders only.
  // When both parameters are missing, only male patients are generated.
  "femaleRatio": 40,
  // The list of all morbidities that can appear in the generated reports.
  // Required. Cannot be empty.
  "morbiditiesData": [
    {
      // The standardized name of morbidity. Is optional in dataset configuration REST API.
      // Is required in dataset generation routines.
      "name": "Chronic ischemic heart disease",
      // The code of morbidity accouring to the ICD-10 specification. Required.
      "icd10Code": "I25",
      // The number of patients in the generated dataset with this morbidity.
      // Optional. When this parameter is specified, percentOfPopulationWithDiagnosisRisk
      // and percentOfProbabilityToAcquireDiagnosis are ignored
      "numberOfEncounters": 20,
      // The percentage (0-100) of patients who could potentially be affected by this morbidity
      // Optional. Is ignored when numberOfEncounters is specified.
      // Default is 100.
      "percentOfPopulationWithDiagnosisRisk": 60,
      // The percentage (0-100) of patients from the risk group (according to percentOfPopulationWithDiagnosisRisk
      // parameter) who actually have a diagnosis of this morbidity.
      // Optional. Is ignored when numberOfEncounters is specified.
      // Default is 100.
      "percentOfProbabilityToAcquireDiagnosis": "10",
      // The exclusion rules to be used for this morbidity. Optional.
      // The value of this parameter should be a Python expression that returns True or False.
      // The expression can use any patient field from datasource.json, e.g. gender, total_age, race, height, etc.
      // The expression is evaluated for each patient individually, if result value is True,
      // it's assumed that the patiant cannot have a problem associated with this morbidity.
      "exclusionRules": "gender == 'Female' or (gender == 'Male' and total_age <= 20)"
    }
  ],
  // The number of patients in the generated dataset. Optional. Default is 1.
  "numberOfPatients": 10,
  // The folder that will contain a subfolder (with name generated from timestamp) with all the generated report files.
  // Optional. Default is "./output/generatedDatasets".
  "outputFolder": "./output/generatedDatasets",
  // All patients are veterans of the study profile specified in the below parameter
  "studyProfile": {
    // The name of study profile. Is required in dataset configuration REST API.
    // Is optional in generation routines only if studyProfileCode is specified.
    "studyProfile": "World War II",
    // The code of the study profile. Is optional when studyProfile (study profile name) is specified.
    "studyProfileCode": "world_war_ii",
    // The end date of the study profile. Optional.
    "studyProfileEndDate": "Tue, 31 Dec 1946 00:00:00 GMT",
    // The start date of the study profile. Optional.
    "studyProfileStartDate": "Sun, 07 Dec 1941 00:00:00 GMT"
  },
  // the output format, CCDA,FHIR-XML,or FHIR-JSON
  "outputFormat": "CCDA",
  // The year to be used as maximum possible year of report effective dates.
  // It indicates how long aging of patiend records should be performed.
  // Optional. Default is current year.
  "year": 1980
}
```


## Verification Steps

### Backend

- Download postman (https://www.getpostman.com/) and run it
- Import *docs/pseudoVet-backend.postman_collection.json* and *docs/pseudoVet-env.postman_environment.json* and then run these endpoint.


### Frontend

- run `python3 pseudo_vets_server.py ` start server, then use browser open http://127.0.0.1:5000


### FHIR format verification

FHIR format verification need java runtime, make sure **you installed jdk 1.8+.**

- ` wget http://hl7.org/fhir/validator.zip` download validator, and unzip it.
- ` wget http://hl7.org/fhir/definitions.xml.zip`, download FHIR-XML definitions, **don't unzip this.**
- ` wget http://hl7.org/fhir/definitions.json.zip`,download FHIR-JSON definitions, **don't unzip this.**

  make sure org.hl7.fhir.validator.jar and definitions.*.zip **are in same folder**, then go to this folder.

  - for FHIR format, run `java -jar org.hl7.fhir.validator.jar demo.xml -defn definitions.xml.zip`, use your xml full path replace *demo.xml* .
  - for FHIR json format,  run `java -jar org.hl7.fhir.validator.jar demo.json -defn definitions.json.zip`, use your json full path replace *demo.json*. 

other way, for FHIR json format, you can open http://docs.smarthealthit.org/fred/?profiles=.%2Fprofiles%2Fstu3.json , click "Open Resource", then copy you FHIR-JSON file content, paste into it.

## Notes

- add endpoint GET /datasets to fetch all datasets
- add endpoint DELETE /datasets  to delete dateset by title
- update generated datasets output folder session_id from timestamp to DATASET_PREFIX.configuration-title
- swagger and postman example updated
- for frontend, add package ngx-toastr to toastr messages, and add @ngx-progressbar/core,@ngx-progressbar/http to progress bar on page top when http requesting.

## Video

**FHIR format Challenge video: **<https://youtu.be/Rme-ipwdCvM> 

Latest Challenge video:<https://youtu.be/rqsSgWlUv40>

this Integration Challenge video: <https://youtu.be/f0XJglZKOUE>

Demo of deployment, usage and testing of the recent version: <https://youtu.be/EspoccXdhzk>

Original video from the previous challenge: <https://youtu.be/GWFE5N2-8Fc>
