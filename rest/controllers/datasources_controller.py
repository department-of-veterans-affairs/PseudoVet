"""
The datasource controller.
Method of this controller handle requests for getting war eras and morbidities.
"""
from rest.decorators import rest_mapping
from rest.errors import BadRequestError
from rest.services import datasources_service
from flask import request


@rest_mapping('/morbidities', ['GET'])
def get_morbidities_for_war_era():
    """
    Get all morbidities by war name.
    :return: JSON response with all morbidities
    """
    war_era_name = request.args.get('warEra')
    if not war_era_name:
        raise BadRequestError("warEra parameter is missing")
    return datasources_service.get_morbidities_for_war_era(war_era_name)


@rest_mapping('/warEras', ['GET'])
def get_war_eras():
    """
    Get list of all war eras.
    :return: JSON response with all war eras
    """
    return datasources_service.get_war_eras()
