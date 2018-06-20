"""
The datasource controller.
Method of this controller handle requests for getting study profiles and morbidities.
"""
from rest.decorators import rest_mapping
from rest.errors import BadRequestError
from rest.services import datasources_service
from flask import request


@rest_mapping('/morbidities', ['GET'])
def get_morbidities_for_study_profile():
    """
    Get all morbidities by study profile name.
    :return: JSON response with all morbidities
    """
    study_profile_name = request.args.get('studyProfile')
    if not study_profile_name:
        raise BadRequestError("studyProfile parameter is missing")
    return datasources_service.get_morbidities_for_study_profile(study_profile_name)


@rest_mapping('/studyProfiles', ['GET'])
def get_study_profiles():
    """
    Get list of all study profiles.
    :return: JSON response with all study profiles
    """
    return datasources_service.get_study_profiles()
