# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
import kid, re, logging, os, sys
from config import config
__all__ = 'HTTPError', 'ActionNotAllowed', 'page', 'callpage', 'template'

class HTTPError(Exception):
	"""
	Causes processing to stop with this error.
	"""
	def __init__(self, code, status=None):
		self.code = code
		self.status = status

class ActionNotAllowed(Exception):
	"""
	Used for when the user is not authenticated correctly.
	"""

# [(regex|string, callable, dict), ...]
_pages = []

def page(regex, **options):
	"""@page(string, [option=value, ...])
	Registers a callable as a page handler. The passed string is used as a 
	Regular Expression if a '(' is found in the string.
	
	Note that searching (not matching) is used to select pages.
	
	The following flags may also be given as keyword arguments:
	* methods: Sequence of valid methods. Defaults to ['GET'].
	* mustauth: Boolean. Does the user need to be logged in? Defaults to False.
	"""
	if '(' in regex:
		regex = re.compile(regex)
	options.setdefault('methods', ['GET'])
	options.setdefault('mustauth', False)
	def _(func):
		_pages.append((regex, func, options))
		return func
	return _

def findpages(path):
	for r, f, ops in _pages:
		if isinstance(r, basestring):
			if r == path:
				yield False, f, None, (), {}, ops
		else:
			m = r.search(path)
			if m:
				yield True, f, r, m.groups(), m.groupdict(), ops

def callpage(req):
	"""callpage(Request) -> iterable
	Finds the page callable, calls it with correct arguments, handles 
	HTTPError, and returns something that can be returned to the WSGI server.
	"""
	# 1. Find callable & assemble args
	page = pargs = kwargs = None
	repaths = {}
	pageops = {}
	# about PATH_INFO:
	# wsgiref and mod_wsgi set it to be the part after the path to this app
	for isre, func, regex, p, kw, ops in findpages(req.apppath()):
		if not isre:
			page, pargs, kwargs, pageops = func, p, kw, ops
			break
		else:
			repaths[func] = regex, p, kw, ops
	else:
		if len(repaths) < 1:
			pass # None found
		elif len(repaths) == 1:
			page, (_, pargs, kwargs, pageops) = repaths.items()[0]
		else:
			logging.getLogger(__name__+'.callpage')\
				.warning("Multiple possible pages: %r", [page.__name__ for page,_ in repaths])
			# FIXME: Come up with some algorithm to select a page
	
	if page is None:
		rv = template(req, 'error-404')
	else:
		meth = req.environ['REQUEST_METHOD']
		if meth == 'HEAD': meth = 'GET' # HEAD is GET, but don't send the body
		if meth not in pageops['methods']:
			req.status(405)
			rv = template('error-405')
		elif pageops['mustauth'] and req.user is None:
			# TODO: Put up a login page
			pass
		else:
			# 2. Call
			try:
				rv = page(req, *pargs, **kwargs)
			except HTTPError, e:
				# 2a. Handle HTTPErrors
				req.status(e.code, e.status)
				rv = template(req, 'error-%i' % e.code, error=e)
	
	# 3. Return
	return rv

# See http://www.kid-templating.org/guide.html

def template(req, name, **kwargs):
	"""template(request, string, [name=object, ...]) -> string
	Loads the template given in name, parses it, and substitutes the given 
	values, returning the string.
	"""
	# kid.Template() looks for either name, file, or source to load the template from
	# Can't really have those floating around
	extrakw = {}
	if 'file' in kwargs:
		extrakw['file'] = kwargs
		del kwargs['file']
	if 'source' in kwargs:
		extrakw['source'] = kwargs
		del kwargs['source']
	
	f = name+'.kid'
	for d in config.getpathlist('TEMPLATE_PATHS'):
		fn = os.path.join(d, f)
		if os.path.exists(fn):
			break
	else:
		raise ValueError, "Template %r does not exist." % name
	
	logging.getLogger(__name__+'.template').info("%s -> %r", name, fn)
	
	tmpl = kid.Template(file=fn, request=req, **kwargs)
	logging.getLogger(__name__+'.template').info("%r", tmpl)
	for k,v in extrakw.iteritems():
		setattr(tmpl, k, v)
	return tmpl.serialize(encoding='utf-8', output=kid.XHTMLSerializer(doctype='xhtml-strict'))

