# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
import kid, re, logging
__all__ = 'HTTPError', 'page', 'callpage', 'template'

class HTTPError(Exception):
	"""
	Causes processing to stop with this error.
	"""
	def __init__(self, code, status=None):
		self.code = code
		self.status = status


_pages = []

def page(regex):
	"""@page(string)
	Registers a callable as a page handler. The passed string is used as a 
	Regular Expression if a '(' is found in the string.
	
	Note that searching (not matching) is used to select pages.
	"""
	if '(' in regex:
		regex = re.compile(regex)
	def _(func):
		_pages.append((regex, func))
		return func
	return _

def findpages(path)
	for r, f in _pages:
		if isinstance(r, basestring):
			if r == path:
				yield False, f, (), {}
		else:
			m = r.search(path)
			if m:
				yield True, f, r, m.groups(), m.groupdict()

def callpage(req):
	"""callpage(Request) -> iterable
	Finds the page callable, calls it with correct arguments, handles 
	HTTPError, and returns something that can be returned to the WSGI server.
	"""
	# 1. Find callable & assemble args
	page = pargs = kwargs = None
	repaths = {}
	for isre, func, regex, p, kw in findpages(req.getpath()):
		if not isre:
			page, pargs, kwargs = func, p, kw
			break
		else:
			repaths[func] = regex, p, kw
	else:
		if len(relpaths) < 1:
			pass # None found
		if len(relpaths) == 1:
			page, (_, pargs, kwargs) = repaths.items()[0]
		else:
			logging.getLogger(__name__+'.callpage')\
				.warning("Multiple possible pages: %r", [page.__name__ for page,_ in repaths]
			# FIXME: Come up with some algorithm to select a page
	
	if page is None:
		rv = template(req, 'error-404')
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
	tmpl = kid.Template(name=name, request=req, **kwargs)
	for k,v in extrakw.iteritems():
		setattr(tmpl, k, v)
	return tmpl.serialize(encoding='utf-8', output=kid.XHTMLSerializer(doctype='xhtml-strict'))

