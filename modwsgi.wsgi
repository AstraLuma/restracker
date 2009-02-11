# -*- tab-width: 4; use-tabs: 1; Mode: python; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:ft=python:
"""
The funky script for mod_wsgi.
"""

def application(environ, start_response):
	import restrack.server
	return restrack.server.restracker_app(environ, start_response)
