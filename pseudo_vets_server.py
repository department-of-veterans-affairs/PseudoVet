"""
The entry module of the Flask web application.
It starts Flask server and then listens to REST requests at port specified in pseudo_vets_config.py.
"""
import os
from http import HTTPStatus

from flask import Flask, send_from_directory, send_file
from flask_cors import CORS

from config import FLASK_RUN_MODE, WEB_PORT, DATASET_CONFIGURATIONS_DIR, GENERATED_DATASETS_DIR, FRONTEND_DIR
from rest.controllers import init
from rest.errors import error_handler
from rest.logger import logger
from randomizer.pseudo_vets import setup_work_session

# create new Flask app
app = Flask(__name__)
CORS(app)


@app.errorhandler(HTTPStatus.METHOD_NOT_ALLOWED)
@app.errorhandler(HTTPStatus.NOT_FOUND)
@app.errorhandler(HTTPStatus.INTERNAL_SERVER_ERROR)
@app.errorhandler(Exception)
def app_error_handler(err):
    """
    Handle all errors
    :param err: the error instance
    :return: the JSON response with error message
    """
    return error_handler(err)


@app.route('/')
def frontend_app_index():
    """
    Frontend index route
    :return: the index file content
    """
    return send_file(os.path.join(FRONTEND_DIR, 'index.html'))


@app.route('/<path:filename>')
def frontend_app_folder(filename):
    """
    Serve frontend folder resource and inject frontend url state
    :param filename:
    :return: the resource content
    """
    if not os.path.exists(os.path.join(FRONTEND_DIR, filename)):
        return frontend_app_index()

    return send_from_directory(FRONTEND_DIR, filename)


if __name__ == '__main__':
    # start flask app

    logger.info('Checking output directories...')

    # check and create dirs
    if not os.path.exists(DATASET_CONFIGURATIONS_DIR):
        os.makedirs(DATASET_CONFIGURATIONS_DIR)
    if not os.path.exists(GENERATED_DATASETS_DIR):
        os.makedirs(GENERATED_DATASETS_DIR)

    # init randomizer
    setup_work_session(GENERATED_DATASETS_DIR, create_session_path=False)
    logger.info('Starting app at port = {0}, with mode = {1}'.format(WEB_PORT, FLASK_RUN_MODE))
    # inject routers
    init(app)
    app.run(debug=(FLASK_RUN_MODE == 'DEBUG'), port=int(WEB_PORT))  # start run app
