# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Some example pages.
"""
import os
from restrack.web import page, template, HTTPError
import users, events, reservations, rooms, statistics

@page('/')
@page('/index.html')
def index(req):
	"""Generates the front page."""
	req.header('Content-Type', 'text/html')
	import restrack.web as web
	yield '<ul>'
	for r, f, _ in sorted(web._pages, key=lambda r: r[0]):
		if r in ('/', '/index.html'):
			continue
		if isinstance(r, basestring):
			yield '<li><a href="%(url)s">%(url)s</a></li>' % {'url':r}
	yield '</ul>'

#@page('/test')
def test(req): # req == Request
	"""Generates a test page for debugging purposes. Not part of final design."""
	req.header('Content-Type', 'text/plain')
	
	# Possibly sent in chunks
	yield 'This is a test page. '
	yield 'Hi! '

@page('/info', methods=['GET', 'POST'])
def info(req):
	"""Displays debugging info from the server."""
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
	yield 'postall() = %r\n' % (req.postall())

#@page('/spam')
def spam(req):
	"""Testing stuff."""
	raise HTTPError(404) # For responses other than 200

#@page('/eggs')
def eggs(req):
	"""More testing information."""
	req.status(302) # Alternative method for setting the response status code
	req.header('Location', req.fullurl('/test'))
	# No content, don't have to return anything

#@page('/teapot')
def eggs(req):
	"""More testing information."""
	req.status(418)
	req.header('Content-Type', 'text/plain')
	yield """
I'm a little teapot, short and stout
Here is my handle, here is my spout
When I get all steamed up hear me shout.
Tip me over and pour me out."""

#@page('/error')
def mkerror(req):
	"""More testing information."""
	raise Exception, "A random exception"


