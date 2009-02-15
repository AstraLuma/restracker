#!/usr/bin/python2.5
"""
A simple test server using wsgiref. That module is default in Python 2.5.
"""
import restrack.server, restrack.config
import wsgiref.simple_server
import logging, sys, os, cgitb

PORT = 8888

logging.root.setLevel(logging.DEBUG)

# User-specific configuration (most likely PostgreSQL connection info)
try:
	restrack.config.config.addfile('user-config.py', __file__)
except (OSError, IOError): # File doesn't exist
	pass

class DebugServerHandler(wsgiref.simple_server.ServerHandler):
	def error_output(self, environ, start_response):
		"""WSGI mini-app to create error output

		By default, this just uses the 'error_status', 'error_headers',
		and 'error_body' attributes to generate an output page.  It can
		be overridden in a subclass to dynamically generate diagnostics,
		choose an appropriate message for the user's preferred language, etc.
		"""
		start_response('500 Internal Server Error', [('Content-Type','text/html')], sys.exc_info())
		return [cgitb.html(sys.exc_info())]

class DebugWSGIRequestHandler(wsgiref.simple_server.WSGIRequestHandler):
	def handle(self):
		"""Handle a single HTTP request"""
		
		self.raw_requestline = self.rfile.readline()
		if not self.parse_request(): # An error code has been sent, just exit
			return
		
		handler = DebugServerHandler(
			self.rfile, self.wfile, self.get_stderr(), self.get_environ()
		)
		handler.request_handler = self      # backpointer for logging
		handler.run(self.server.get_app())

httpd = wsgiref.simple_server.make_server('', PORT, restrack.server.restracker_app, handler_class=DebugWSGIRequestHandler)
print "Serving HTTP on port %i..." % PORT

# Respond to requests until process is killed
try:
	httpd.serve_forever()
except KeyboardInterrupt:
	pass

