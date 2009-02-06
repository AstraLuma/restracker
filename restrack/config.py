"""
This is the configuration file.

NOTE: Do not use "from config import *". This prevents reloading of values.
"""

# The root of this application, in the form '/spam/eggs'
BASE_PATH = None

# The cookie name to use for session tracking
SESSION_COOKIE = 'rt-session'

# How long until the session expires, in seconds
SESSION_LENGTH = 1*365*24*60*60

# PostgreSQL connection info
SQL_HOST = 'localhost'
SQL_DATABASE = 'restracker'
SQL_USER = None
SQL_PASSWORD = None
