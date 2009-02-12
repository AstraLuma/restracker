#!/usr/bin/python2.5
"""
A simple test server using wsgiref. That module is default in Python 2.5.
"""
import restrack.server
from wsgiref.simple_server import make_server
import logging, sys

PORT = 8888

logging.root.setLevel(logging.DEBUG)

httpd = make_server('', PORT, restrack.server.restracker_app)
print "Serving HTTP on port %i..." % PORT

# Respond to requests until process is killed
httpd.serve_forever()


