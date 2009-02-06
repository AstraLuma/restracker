# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Some example pages.
"""
from web import page, template, HTTPError

@page('/test')
def test(req): # req == Request
	req.header('Content-Type', 'text/plain')
	
	# Possibly sent in chunks
	yield 'This is a test page. '
	yield 'Hi! '

@page('/user/(.*)') #regex
def user(req, userid): # The group from the regex is passed as a positional parameter
	req.header('Content-Type', 'text/html')
	
	# Do some processing
	# Use req.db as the Connection object
	
	# sent all at once
	return template('user', user=data) # user is a variable that the template references

@page('/spam')
def spam(req):
	raise HTTPError(404) # For responses other than 200

@page('/eggs')
def eggs(req):
	req.status(302) # Alternative method for setting the response status code
	req.header('Location', req.fullurl('/test'))
	# No content, don't have to return anything
