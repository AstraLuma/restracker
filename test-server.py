#!/usr/bin/python2.5
"""
A simple test server using wsgiref. That module is default in Python 2.5.
"""
import restrack.server, restrack.config
from wsgiref.simple_server import make_server
import logging, sys, os

PORT = 8888

logging.root.setLevel(logging.DEBUG)

# User-specific configuration (most likely PostgreSQL connection info)
try:
	restrack.config.config.addfile('user-config.py', __file__)
except (OSError, IOError): # File doesn't exist
	pass

httpd = make_server('', PORT, restrack.server.restracker_app)
print "Serving HTTP on port %i..." % PORT

# Respond to requests until process is killed
try:
	httpd.serve_forever()
except KeyboardInterrupt:
	pass

