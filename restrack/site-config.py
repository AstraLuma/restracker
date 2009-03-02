"""
This is the configuration file. Use config.py to actually get settings.

NOTE: All paths are relative to this file.
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

# Paths to find templates in
TEMPLATE_PATHS = (
	'..', # Application dir
	'.', # Framework dir
	'pages',
	)

# Import these at startup.
PAGE_MODULES = (
	'restrack.pages',
	)

EMAIL_FROM = 'restracker@astro73.com'

SMTP_SERVER = 'smtp.wpi.edu'
SMTP_USER = None
SMTP_PASSWORD = None
