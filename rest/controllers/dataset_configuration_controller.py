"""
The dataset configuration controller.
Methods of this controller handle requests for saving (creating or updating) the dataset configuration.
"""
from flask import request
from flask.json import loads

from rest.decorators import rest_mapping
from rest.errors import BadRequestError
from rest.services import dataset_configuration_service


@rest_mapping('/datasetConfigurations', ['PUT'])
def save():
    """
    Save request body JSON dataset configuration to a JSON file on the local file system
    :return: the saved data configuration JSON
    """
    return dataset_configuration_service.save(request.get_json(force=True, silent=True))


@rest_mapping('/datasetConfigurations', ['GET'])
def get():
    """
    Get dataset configurations by title. If title is None, then return all existing dataset configurations.
    :return: the JSON response with the matched dataset configurations
    """
    return dataset_configuration_service.get(request.args.get('title'))


@rest_mapping('/datasetConfigurationFromFile', ['POST'])
def save_file():
    """
    Get a file from the request body and check its content, then save the content to a JSON file on the
    local file system
    :return: the saved dataset configuration JSON
    """
    config_file_obj = request.files.get('datasetConfiguration')
    if config_file_obj is None:
        raise BadRequestError('Dataset configuration file is missing in POST request')
    return dataset_configuration_service.save(loads(config_file_obj.read()))

@rest_mapping('/datasetConfigurations', ['DELETE'])
def delete_config():
    """
    delete config by title
    :return: the message with the delete result
    """
    dataset_configuration_service.delete_config_by_title(request.args.get('title'))
    return {'message': 'succeed'}
