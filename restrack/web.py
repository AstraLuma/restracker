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
	"""findpages(string) -> (bool, func, regex, match, ops)
	Finds all pages that could _possibly_ match the path.
	"""
	for r, f, ops in _pages:
		if isinstance(r, basestring):
			if r == path:
				yield False, f, None, None, ops
		else:
			m = r.match(path)
			if m:
				yield True, f, r, m, ops

def findpage(path):
	"""findpage(string) -> func, ops, pargs, kwargs
	Given a path, finds the appropriate registered caller, plus the arguments 
	to pass to it.
	"""
	log = logging.getLogger(__name__+'.findpage')
	repaths = {}
	# 1. Find any functions that match.
	#    Plain strings that match exactly cause us to exit.
	for isre, func, regex, match, ops in findpages(path):
		if not isre:
			return func, ops, (), {}
		else:
			repaths[func] = regex, match, ops
	else:
		# 1a. If we're empty, exit now.
		if len(repaths) < 1: # Nothing found
			return None, {}, (), {}
		# 1b. If we have one, return it
		elif len(repaths) == 1:
			func, (_, m, ops) = repaths.items()[0]
			return func, ops, m.groups(), m.groupdict()
	
	log.warning("Multiple possible pages for %r: %r", path, [page.__name__ for page in repaths])
	
	# 2. Find the regex that matches the longest portion. 
	#    (I think this doesn't matter in match mode.)
	cursize = 0
	curfunc = None
	for func, (r, m, ops) in repaths.items():
		if m.span(0) > cursize:
			cursize = m.span(0)
			if curfunc is not None:
				del repaths[curfunc]
			curfunc = func
		elif m.span(0) < cursize:
			del repaths[func]
	else:
		assert len(repaths) > 0, "Got rid of everything"
	
		if len(repaths) == 1:
			func, (_, m, ops) = repaths.items()[0]
			return func, ops, m.groups(), m.groupdict()
	
	raise RuntimeError, "Ran out of algorithms! We still have pages for %r: %r" % (path, repaths.keys())

def callpage(req):
	"""callpage(Request) -> iterable
	Finds the page callable, calls it with correct arguments, handles 
	HTTPError, and returns something that can be returned to the WSGI server.
	"""
	# 1. Find callable & assemble args
	page, pageops, pargs, kwargs = findpage(req.apppath())
	logging.getLogger(__name__+'.callpage').info("%r -> %r", req.apppath(), page)
	
	if page is None:
		rv = template(req, 'error-404')
	else:
		meth = req.environ['REQUEST_METHOD']
		if meth == 'HEAD': meth = 'GET' # HEAD is GET, but don't send the body
		if meth not in pageops['methods']:
			req.status(405)
			rv = template(req, 'error-405')
		elif pageops['mustauth'] and req.user is None:
			rv = template(req, 'error-login', func=page, title="Must Log In", msg="You must be logged in to use this page")
		else:
			# 2. Call
			try:
				rv = page(req, *pargs, **kwargs)
			except HTTPError, e:
				# 2a. Handle HTTPErrors
				req.status(e.code, e.status)
				rv = template(req, 'error-%i' % e.code, error=e)
			except ActionNotAllowed, e:
				rv = template(req, 'error-login', func=page, title="Not Allowed", msg="You do not have permissions to use this page")
			except NotImplementedError:
				rv = NotImplemented
			if rv is NotImplemented:
				req.status(500)
				rv = template(req, 'error-notimplemented', func=page)
	
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
	
	def up():
		url = os.path.dirname(req.apppath())
		link = kid.Element('a', href=url, title=url)
		link.text = u'«Up'
		
		wrapper = kid.Element('div', 
			style='text-transform: lowercase; font: bold 12pt sans-serif; margin: 0.1em; position: absolute; top: 2pt;', 
			**{'class': 'uplink'})
		wrapper.append(link)
		return wrapper
	
	tmpl = kid.Template(file=fn, request=req, up=up, **kwargs)
	logging.getLogger(__name__+'.template').info("%r", tmpl)
	for k,v in extrakw.iteritems():
		setattr(tmpl, k, v)
	return tmpl.serialize(encoding='utf-8', output=kid.XHTMLSerializer(doctype='xhtml-strict'))

