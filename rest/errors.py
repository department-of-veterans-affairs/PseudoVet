"""
The common errors defined and error_handler
"""

from http import HTTPStatus

from flask import jsonify
from werkzeug.exceptions import MethodNotAllowed, NotFound

from .logger import logger


class EntityNotFoundError(Exception):
    """
    The backend will raise this error if some entity is not found
    """
    pass


class BadRequestError(Exception):
    """
    The backend will raise this error if request or invoke parameters have an error
    """
    pass


class InnerServerError(Exception):
    """
    The backend will raise this error if some other unexpected error occurred
    """
    pass


def error_handler(err):
    """
    Handle errors and return message with HTTP error code
    :param err: the error instance
    :return: the JSON response with error message and error code
    """

    logger.error(type(err))
    logger.exception(err)

    err_type = type(err)
    error_message = str(err)
    error_code = HTTPStatus.INTERNAL_SERVER_ERROR

    if err_type is EntityNotFoundError or err_type is NotFound:
        error_code = HTTPStatus.NOT_FOUND
    elif err_type is BadRequestError:
        error_code = HTTPStatus.BAD_REQUEST
    elif err_type in (InnerServerError, TypeError):
        error_code = HTTPStatus.INTERNAL_SERVER_ERROR
    elif err_type is MethodNotAllowed:
        error_code = HTTPStatus.METHOD_NOT_ALLOWED
    return jsonify({'message': error_message}), error_code
