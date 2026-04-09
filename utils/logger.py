import logging

logger = logging.getLogger("logger")
logger.setLevel(logging.INFO)
logger.propagate = False

ch = logging.StreamHandler()
ch.setLevel(logging.INFO)

formatter = logging.Formatter("[%(asctime)s] %(levelname)s :: %(message)s",
                              "%H:%M:%S")
ch.setFormatter(formatter)

logger.addHandler(ch)
