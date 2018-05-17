import coloredlogs
import logging

from config import LOG_LEVEL, LOG_FORMAT

# Create a logger object.
logger = logging.getLogger(__name__)

# inject color log
coloredlogs.install(level=LOG_LEVEL, fmt=LOG_FORMAT)
