"""
The dataset service.
It provides a method for generating records according to the specified dataset configuration.
"""

from os.path import isdir, join, exists
from os import listdir, stat
from shutil import rmtree
from datetime import datetime

from randomizer.pseudo_vets import generate_from_config
from rest.decorators import service
from rest.services import dataset_configuration_service
from rest.errors import EntityNotFoundError
from config import DATASET_PREFIX, GENERATED_DATASETS_DIR
from rest.logger import logger


@service(schema={'title': {'type': 'string', 'required': True}})
def generate(title):
    """
    Generate a dataset according to dataset configuration file with the specified title.
    It raises EntityNotFoundError if file cannot be found.
    :param title: the dataset configuration title
    :return: the number of generated report files
    """
    configurations = dataset_configuration_service.get(title)  # the length will be 1
    if len(configurations) <= 0:
        raise EntityNotFoundError('Cannot find configuration with title ' + title)
    return generate_from_config(configurations[0])


@service(schema={'title': {'type': 'string', 'required': True}})
def delete_dataset_by_title(title):
    """
    Delete dateset by title
    It raises EntityNotFoundError if dataset not found
    :param title: the dataset title
    """

    dataset_path = join(GENERATED_DATASETS_DIR, title)
    if not exists(dataset_path):
        raise EntityNotFoundError("Dataset not found where name = " + title)
    rmtree(dataset_path)


@service()
def get_all_datasets():
    """
    Get all dataset by scan output folder, if folder name start begin DATASET_PREFIX, that's mean this dataset generate
    by rest api, it should be returned.
    If get configuration by title failed, then this api will skip the dataset
    :return: the rest api generated datasets
    """
    datasets_folders = [f for f in listdir(GENERATED_DATASETS_DIR) if isdir(join(GENERATED_DATASETS_DIR, f))]
    datasets = []
    for dataset_name in datasets_folders:
        if not dataset_name.startswith(DATASET_PREFIX):  # not generate by rest api
            continue
        dataset_parts = dataset_name.split('.')
        name = len(dataset_parts) > 1 and dataset_parts[1] or 'ERROR TO GET NAME'
        output_format = len(dataset_parts) > 3 and dataset_parts[3] or 'CCDA'
        try:
            configurations = dataset_configuration_service.get_configuration_by_title(name)
            datasets.append({
                'title': name,
                'completedOn': datetime.fromtimestamp(
                    stat(join(GENERATED_DATASETS_DIR, dataset_name)).st_mtime).isoformat(),
                'configuration': configurations,
                'outputFormat': output_format,
                'datasetName': dataset_name
            })
        except Exception as e:
            # if get configuration error, then skip this dataset, so we don't need raise error here
            logger.error(e)
        if len(datasets) > 0:
            datasets = sorted(datasets, key=lambda k: k['completedOn'], reverse=True)
    return datasets
