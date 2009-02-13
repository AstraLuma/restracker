"""
This is the configuration file.

NOTE: Do not use "from config import *". This prevents reloading of values.
"""

# The root of this application, in the form '/spam/eggs'
BASE_PATH = None

# The cookie name to use for session tracking
SESSION_COOKIE = 'rt-session'

# How long until the session expires, in seconds
SESSION_LENGTH = 1*365*24*60*60 # 1 year

# PostgreSQL connection info
SQL_HOST = '' # Local Unix socket
SQL_DATABASE = 'restracker'
SQL_USER = None
SQL_PASSWORD = None

import os
# Paths to find templates in
TEMPLATE_PATHS = (
	os.path.dirname(os.path.dirname(__file__)), # Application dir
	os.path.dirname(__file__), # Framework dir
	)

# Load these at startup.
PAGE_MODULES = (
	'restrack.pages',
	)
