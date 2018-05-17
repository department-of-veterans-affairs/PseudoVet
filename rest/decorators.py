"""
The decorators used by controllers and services
"""

import inspect
import os
from flask import jsonify
from functools import wraps

from rest.errors import BadRequestError
from config import APPLICATION_ROOT
from .logger import logger
from cerberus import Validator

# the cached flask app
app = None

# the cerberus validator instance
cerberus_validator = Validator()

# Bug fix: Cerberus doesn't want to validate morbiditiesData items
custom_validators = []


def inject_flask_app(flask_app):
    """
    Inject Flask app and cache it for auto registering routes
    :param flask_app: the Flask app instance
    :return: None
    """
    global app
    app = flask_app


def rest_mapping(path, methods=None):
    """
    The REST mapping decorator, used for registering path to the Flask app and wrapping result into JSON response
    :param path: the route path
    :param methods: the request methods
    :return: the decorator
    """

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            result = func(*args, **kwargs)
            return result is None and '' or jsonify(result)  # wrap json response

        new_path = APPLICATION_ROOT + path  # add path prefix to path
        logger.debug('endpoint added: ' + (methods and methods.__str__() or '[ALL]') + ' ' + new_path)
        app.route(new_path, methods=methods)(wrapper)  # inject route to Flask app

        return wrapper

    return decorator


def service(schema=None):
    """
    The REST service decorator, used for parameter check and logging service method entrance/exit with
    parameters and result
    :param schema: the validator schema
    :return: the decorator
    """

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            func_file_name = os.path.splitext(os.path.basename(inspect.getfile(func)))[0]
            func_name = func.__name__
            logger.info('** Enter service ' + func_file_name + '.' + func_name +
                        ', args = ' + str(args) + ', kwargs = ' + str(kwargs))

            if schema is not None:
                # check schema
                document = {}
                args_len = len(args)
                args_spec = inspect.getfullargspec(func)
                for i, document_key in enumerate(args_spec.args):
                    if i >= args_len:
                        document[document_key] = kwargs.get(document_key) or args_spec.defaults[i - args_len]
                    else:
                        document[document_key] = args[i]

                if not cerberus_validator.validate(document, schema):  # validator schema
                    raise BadRequestError("Request validation failed. Info: " + cerberus_validator.errors)

                # Bug fix: Cerberus doesn't want to validate morbiditiesData items
                for custom_validator in custom_validators:
                    custom_validator(document)

            service_result = func(*args, **kwargs)
            logger.info('** Leave service ' + func_file_name + '.' + func_name + ', result= ' + str(service_result))
            return service_result

        return wrapper

    return decorator
