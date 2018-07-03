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

DATASET_GENERATING = 'Generating'
DATASET_COMPLETED = 'Completed'


class DataSetManager:
    """
    the dataset manager class
    """

    def __init__(self):
        """
        init cache map
        """
        self.cache_map = {}

    def update_entity(self, name, status, progress):
        """
        update dataset entity by name
        :param name:  the dataset name
        :param status: the dataset status
        :param progress: the dataset progress
        :return: None
        """
        entity = self.cache_map.get(name)
        if entity is not None:
            entity['status'] = status
            entity['progress'] = progress
            logger.info("%s status = %s, progress = %.2f%%" % (name, status, progress))
            if status == DATASET_COMPLETED and progress >= 100:
                entity['completedOn'] = datetime.now().isoformat()

    def push_entity(self, name, entity):
        """
        push new dataset entity into manager
        :param name: the dataset name
        :param entity: the dataset entity
        :return: None
        """
        self.cache_map[name] = entity

    def remove_by_configuration_title(self, config_title):
        """
        remove datasets when configuration file removed
        :param config_title:  the configuration title
        :return: None
        """
        pass

    def remove_by_name(self, name):
        """
        remove dataset entity by name
        :param name:  the dataset name
        :return: None
        """
        if self.cache_map.get(name) is not None:
            self.cache_map.pop(name, None)

    def get_all_keys(self):
        """
        get all dataset names
        :return:  the dataset names array
        """
        return self.cache_map.keys()

    def get_by_name(self, name):
        """
        get dataset by name
        :param name: the dataset name
        :return: the dateset entity
        """
        return self.cache_map.get(name)


# the global dataset_manager
dataset_manager = DataSetManager()


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

    return generate_from_config(configurations[0], dataset_manager)


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
    dataset_manager.remove_by_name(title)


def preload_datasets():
    """
    preload all datasets into manager
    Get all dataset by scan output folder, if folder name start begin DATASET_PREFIX, that's mean this dataset generate
    by rest api
    If get configuration by title failed, then this api will skip the dataset
    :return: None
    """
    datasets_folders = [f for f in listdir(GENERATED_DATASETS_DIR) if isdir(join(GENERATED_DATASETS_DIR, f))]
    for dataset_name in datasets_folders:
        if not dataset_name.startswith(DATASET_PREFIX):  # not generate by rest api
            continue
        dataset_parts = dataset_name.split('.')
        name = len(dataset_parts) > 1 and dataset_parts[1] or 'ERROR TO GET NAME'
        output_format = len(dataset_parts) > 3 and dataset_parts[3] or 'CCDA'
        try:
            configurations = dataset_configuration_service.get_configuration_by_title(name)
            dataset = {
                'title': name,
                'completedOn': datetime.fromtimestamp(
                    stat(join(GENERATED_DATASETS_DIR, dataset_name)).st_mtime).isoformat(),
                'configuration': configurations,
                'status': DATASET_COMPLETED,
                'progress': 100,
                'outputFormat': output_format,
                'datasetName': dataset_name
            }
            dataset_manager.push_entity(dataset_name, dataset)
            logger.info("succeed load dataset = " + dataset_name)
        except Exception as e:
            # if get configuration error, then skip this dataset, so we don't need raise error here
            logger.error(e)


@service()
def get_all_datasets():
    """
    get all datasets from cache
    :return: the rest api generated datasets
    """
    datasets = []
    global dataset_manager
    keys = dataset_manager.get_all_keys()
    for dataset_name in keys:
        dataset = dataset_manager.get_by_name(dataset_name)
        if dataset is None:
            continue
        dataset_parts = dataset_name.split('.')
        name = len(dataset_parts) > 1 and dataset_parts[1] or 'ERROR TO GET NAME'
        try:
            configurations = dataset_configuration_service.get_configuration_by_title(name)
            dataset['configuration'] = configurations
            datasets.append(dataset)
        except Exception as e:
            # if get configuration error, then skip this dataset, so we don't need raise error here
            logger.error(e)
        if len(datasets) > 0:
            datasets = sorted(datasets, key=lambda k: k['completedOn'], reverse=True)
    return datasets


def remove_dateset_by_config_title(title):
    """
    remove dataset by config title from cache
    :param title: the config title
    :return: None
    """
    global dataset_manager
    dataset_manager.remove_by_configuration_title(title)


def get(title):
    """
    get dataset by title
    :param title: the dataset cache key
    :return: the cached dataset
    """
    return dataset_manager.get_by_name(title)
