# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Some example pages.
"""
import os
from restrack.web import page, template, HTTPError

@page('/')
def index(req):
	req.header('Content-Type', 'text/html')
	import web
	yield '<ul>'
	for r, f in web._pages:
		if isinstance(r, basestring):
			yield '<li><a href="%(url)s">%(url)s</a></li>' % {'url':r}
	yield '</ul>'

@page('/test')
def test(req): # req == Request
	req.header('Content-Type', 'text/plain')
	
	# Possibly sent in chunks
	yield 'This is a test page. '
	yield 'Hi! '

@page('/info')
def info(req):
	req.header('Content-Type', 'text/plain')
	
	for attr in [a for a in dir(req) if a[0] != '_']:
		try:
			value = getattr(req, attr)
		except AttributeError:
			continue
		if callable(value): continue
		if attr == 'environ':
			yield '%s = {\n' % attr
			ex = []
			for k,v in sorted(value.items(), key=lambda v: v[0]):
				if k in os.environ:
					ex.append(k)
				else:
					yield '\t%r: %r\n' % (k,v)
			if len(ex):
				yield '\tNot included: %s\n' % ', '.join(map(repr, ex))
			yield '}\n'
		elif isinstance(value, dict):
			yield '%s = {\n' % attr
			for k,v in sorted(value.items(), key=lambda v: v[0]):
				yield '\t%r: %r\n' % (k,v)
			yield '}\n'
		else:
			yield '%s = %r\n' % (attr, value)
	

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

@page('/teapot')
def eggs(req):
	req.status(418)
	req.header('Content-Type', 'text/plain')
	yield """
I'm a little teapot, short and stout
Here is my handle, here is my spout
When I get all steamed up hear me shout.
Tip me over and pour me out."""

@page('/error')
def mkerror(req):
	raise Exception, "A random exception"


