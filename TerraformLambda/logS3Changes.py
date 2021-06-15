import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def logS3Changes(event,context):
    logger.info('## ENVIRONMENT VARIABLES')
    logger.info(os.environ)
    logger.debug('## EVENT')
    logger.debug(event)