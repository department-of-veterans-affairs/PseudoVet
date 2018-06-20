"""PseudoVet Randomizer and Aging.

Description:
Creates C-CDA conformant documents of fictional patients using random data and
optional dataset configuration parameters.

Usage:
  pseudo-vets.py [-c path] [-t title] [-s code] [-n number] [-o output] [-y year]

Options:
    -c path         Path to the dataset configuration file.
    -t title        Title of dataset configuration to be used.
      At maximum one of -c and -t switches is expected to be specified.
    -s code         Code of study profile for which records are created.
      E.g. world_war_ii, vietnam_war, korean_conflict or gulf_war.
      Can override value specified in dataset configuration file.
      Default is world_war_ii.
    -n number       Integer number of records to create. Defaults to 1.
      Can override value specified in dataset configuration.
    -o Output       Path to the folder where the output files shall be saved to. Will be created if non existent.
      Defaults to ./output/generatedDatasets
      Can override value specified in dataset configuration.
    -y year         End year for the reports to be generated.
      Defaults to the current year
      Can override value specified in dataset configuration.

    -h --help       Show this screen.
    -v --version    Show version.
"""

#
# Main entry point to the script.
# Actual script execution code starts
#
import datetime
from docopt import docopt
from os.path import isfile

from rest.logger import logger
from rest.errors import EntityNotFoundError
from config import GENERATED_DATASETS_DIR, DEFAULT_STUDY_PROFILE_CODE
from randomizer.pseudo_vets import generate_from_config

from rest.services.dataset_configuration_service import read_configuration_from_file
from rest.services.dataset_configuration_service import get_configuration_by_title
from rest.services.datasources_service import get_morbidities_from_study_profile_code

if __name__ == '__main__':
    # parse command line options
    options = docopt(__doc__, version='1.0.0')

    # check configuration file parameters and read configuration file if required
    config_path = options['-c']
    config_title = options['-t']
    config = None
    if config_path and config_title:
        logger.error('Both configuration file path and configuration title were specified. ' +
                     'Only one of them can be provided at a time')
        exit(1)

    if config_path is not None:
        if not isfile(config_path):
            logger.error("Configuration file {0} doesn't exist".format(config_path))
            exit(1)
        try:
            config = read_configuration_from_file(config_path)
        except Exception as e:
            logger.error("Error occurred while reading configuration file: {0}".format(e))
            exit(1)
    elif config_title is not None:
        try:
            config = get_configuration_by_title(config_title)
        except EntityNotFoundError:
            logger.error("Configuration with title {0} doesn't exist".format(config_title))
            exit(1)
        except Exception as e:
            logger.error("Error occurred while reading configuration: {0}".format(e))
            exit(1)

    # if configuration was not loaded, create new one with default parameters
    if config is None:
        config = {
            'numberOfPatients': 1,
            'maleRatio': 100,
            'outputFolder': GENERATED_DATASETS_DIR,
            'year': datetime.datetime.now().year
        }

    # process -n switch with number of records to be generated
    num_records = options['-n']
    if num_records:
        try:
            num_records = int(num_records)
            if num_records <= 0:
                raise ValueError()
            config['numberOfPatients'] = num_records
        except ValueError:
            logger.error(
                'Number of records is expected to be positive integer, but {0} is specified'.format(num_records))
            exit(1)

    # process -y switch with report end year
    end_year = options['-y']
    if end_year:
        try:
            end_year = int(end_year)
            if end_year <= 0:
                raise ValueError()
            config['year'] = int(end_year)
        except ValueError:
            logger.error('End year is expected to be positive integer, but {0} is specified'.format(end_year))
            exit(1)

    # process -s switch with study profile code
    study_profile_code = options['-s']
    if study_profile_code:
        config['studyProfile'] = {'studyProfileCode': study_profile_code}
    elif 'studyProfile' not in config:
        # use World War II by default
        config['studyProfile'] = {'studyProfileCode': DEFAULT_STUDY_PROFILE_CODE}

    # process -o switch with output folder path
    if options['-o']:
        config['outputFolder'] = options['-o']

    files_num = None
    try:
        files_num = generate_from_config(config)
    except Exception as e:
        logger.error(e)
        exit(1)
