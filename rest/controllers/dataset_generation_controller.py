"""
The dataset generation controller.

Methods of this controller handle requests for generating datasets.
"""

from flask import request

from rest.decorators import rest_mapping
from rest.services import dataset_generation_service


@rest_mapping('/generateDatasets', ['PUT'])
def generate():
    """
    Generate dataset by configuration with the specified title
    :return: the message with the number of generated report files
    """
    files_num = dataset_generation_service.generate(request.args.get('title'))
    message = "Dataset containing {0} files was generated successfully".format(files_num)
    return {'message': message}


@rest_mapping('/datasets', ['GET'])
def get_all_datasets():
    """
    get all datasets
    :return: the datasets with config objects
    """
    return dataset_generation_service.get_all_datasets()


@rest_mapping('/queryDataset', ['GET'])
def get_dataset_by_name():
    """
    query dataset with title
    :return: the cached datas
    """
    return dataset_generation_service.get(request.args.get('title'))


@rest_mapping('/datasets', ['DELETE'])
def delete_dataset():
    """
    delete dataset by title
    :return: the message with the delete result
    """
    dataset_generation_service.delete_dataset_by_title(request.args.get('title'))
    return {'message': 'succeed'}
