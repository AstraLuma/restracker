# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
The top-level WSGI work.
"""
import sys, logging, urllib, pgdb, Cookie, random
import config
__all__ = 'Request', 'restracker_app'

SESSION_CHARS = '1234567890qwertyuiopasdfghjklzxcvbnm'
SESSION_SIZE = 16

HTTP_STATUS_CODES = {
	# 1xx Informational
	100 : '100 Continue',
	101 : '101 Switching Protocols',
	102 : '102 Processing', # WebDAV
	122 : '122 Request-URI too long', # IE7 (?)
	# 2xx Success
	200 : '200 OK',
	201 : '201 Created',
	202 : '202 Accepted',
	203 : '203 Non-Authoritative Information', # HTTP/1.1
	204 : '204 No Content',
	205 : '205 Reset Content',
	206 : '206 Partial Content',
	207 : '207 Multi-Status', # WebDAV
	# 3xx Redirection
	300 : '300 Multiple Choices',
	301 : '301 Moved Permanently',
	302 : '302 Found',
	303 : '303 See Other', # HTTP/1.1
	304 : '304 Not Modified',
	305 : '305 Use Proxy', # HTTP/1.1
#	306 : '306 Switch Proxy', # Out since HTTP/1.1
	307 : '307 Temporary Redirect', # HTTP/1.1
	# 4xx Client Error
	400 : '400 Bad Request',
	401 : '401 Unauthorized',
	402 : '402 Payment Required',
	403 : '403 Forbidden',
	404 : '404 Not Found',
	405 : '405 Method Not Allowed',
	406 : '406 Not Acceptable', # HTCPCP
	407 : '407 Proxy Authentication Required',
	408 : '408 Request Timeout',
	409 : '409 Conflict',
	410 : '410 Gone',
	411 : '411 Length Required',
	412 : '412 Precondition Failed',
	413 : '413 Request Entity Too Large',
	414 : '414 Request-URI Too Long',
	415 : '415 Unsupported Media Type',
	416 : '416 Requested Range Not Satisfiable',
	417 : '417 Expectation Failed',
	418 : '418 I\'m a Teapot', # HTCPCP
	422 : '422 Unprocessable Entity', # WebDAV
	423 : '423 Locked', # WebDAV
	424 : '424 Failed Dependency', # WebDAV
	425 : '425 Unordered Collection', # WebDAV Advanced Collections
	426 : '426 Upgrade Required', # RFC 2817 (Upgrading to TLS Within HTTP/1.1)
	449 : '449 Retry With', # Microsoft
	450 : '450 Blocked', # Microsoft
	# 5xx Server Error
	500 : '500 Internal Server Error',
	501 : '501 Service Unavailable',
	502 : '502 Bad Gateway',
	503 : '503 Service Unavailable',
	504 : '504 Gateway Timeout',
	505 : '505 HTTP Version Not Supported',
	506 : '506 Variant Also Negotiates', # RFC 2295 (Transparent Content Negotiation in HTTP)
	507 : '507 Insufficient Storage', # WebDAV
	509 : '509 Bandwidth Limit Exceeded', # Apache
	510 : '510 Not Extended', # RFC 2774 (An HTTP Extension Framework)
	}

class Request(object):
	"""
	The req object passed to pages.
	"""
	#TODO: Sessions
	__slots__ = ('__weakref__', 'environ', '_start_response', 'db', 
		'_log_handler', 'cookies', 'session', 'user', '_status', '_headers')
	def __init__(self, environ, start_response):
		self.environ = environ
		self._start_response = start_response
		self._status = None
		
		# Database
		self.db = pgdb.connect(
			host=config.SQL_HOST, database=config.SQL_DATABASE, 
			user=config.SQL_USER, password=config.SQL_PASSWORD
			)
		
		# Cookies
		self.cookies = Cookie.SimpleCookie(self.environ.get('HTTP_COOKIE', None))
		
		# Session
		if config.SESSION_COOKIE not in self.cookies:
			while not self._initsession(): pass
		else:
			#TODO: Load session
			pass
		
		#TODO: User
	
	def _initsession(self):
		"""req._initsession() -> bool
		Tries to create a session, load the cookie, and insert it into the 
		database.
		
		Returns if it is successful.
		"""
		sess = self._mksession()
		exp = time.time() + config.SESSION_LENGTH
		cur = self.db.cursor()
		cur.execute(
			"""INSERT INTO sessions (id, expires) VALUES (%(id)s, %(exp)s)""", 
			id=sess, exp=pgdb.TimestampFromTicks(exp))
		if cur.rowcount == 0:
			return False
		self.cookies[config.SESSION_COOKIE] = sess
		self.cookies[config.SESSION_COOKIE]['max-age'] = config.SESSION_LENGTH
		return True
	
	def _mksession(self):
		"""req._mksession() -> string
		Returns a random session identifier. Not guaranteed to be unique.
		"""
		return ''.join(random.select(SESSION_CHARS) for _ in xrange(SESSION_SIZE))
	
	def status(self, code, status=None):
		"""req.status(integer, [string]) -> None
		Sets the current HTTP status.
		"""
		pass #TODO
	
	def header(self, name, value, overwrite=True):
		"""req.header(string, string, [boolean]) -> None
		Sets an HTTP header. Set overwrite to False in order to append headers.
		"""
		pass #TODO
	
	def fullurl(self, path=None):
		"""req.fullurl([string]) -> string
		Dereferences relative URLs, prefixes domain names, etc.
		"""
		if path is not None and (path.startswith('http:') or path.startswith('https:')):
			return path
		
		url = self.environ['wsgi.url_scheme']+'://'
		
		if self.environ.get('HTTP_HOST'):
			url += self.environ['HTTP_HOST']
		else:
			url += self.environ['SERVER_NAME']
			
			if self.environ['wsgi.url_scheme'] == 'https':
				if self.environ['SERVER_PORT'] != '443':
					url += ':' + self.environ['SERVER_PORT']
			else:
				if self.environ['SERVER_PORT'] != '80':
					url += ':' + self.environ['SERVER_PORT']
		
		if path is not None and path.startswith('/'):
			url += path
		else:
			url += urllib.quote(self.environ.get('SCRIPT_NAME',''))
			url += urllib.quote(self.environ.get('PATH_INFO',''))
			if path is None:
				if self.environ.get('QUERY_STRING'):
					url += '?' + self.environ['QUERY_STRING']
			else:
				if url[-1] != '/':
					url = url.rpartition('/')[0]+'/'
				#FIXME: handle . and ..
				if '?' not in path: # If doesn't contain a query string, ...
					path = urllib.quote(path) # then quote the path as needed
				url += path
		return url
	
	def getpath(self):
		"""req.getpath() -> string
		Returns the path component of the URL.
		"""
		return self.environ.get('SCRIPT_NAME','') + self.environ.get('PATH_INFO','')
	
	def send_response(self):
		"""req.send_response() -> None
		Sends headers & status to the client.
		"""
		headers = [] #FIXME: Pull from self._headers somehow
		headers += [('Set-Cookie', v.OutputString()) for v in self.cookies.itervalues()]
		st = HTTP_STATUS_CODES[self._status or 200]
	
	def __enter__(self):
		"""
		PEP 343
		Causes this request to become the active one.
		"""
		# Logging
		self._log_handler = logging.StreamHandler(self.environ['wsgi.error'])
		logging.root.addHandler(self._log_handler)
	
	def __exit__(self, type, value, traceback):
		"""
		PEP 343
		Reverses __enter__().
		"""
		# Database
#		if type is None:
#			self.db.commit()
#		else:
#			self.db.rollback()
		
		# Logging
		logging.root.removeHandler(self._log_handler)
		del self._log_handler
		
		# XXX: Send different reponse if error?
	
	def __del__(self):
		self.db.close()


def restracker_app(environ, start_response):
	"""
	The WSGI callback.
	"""
	req = Request(environ, start_response)
	
	# Emulate PEP 343
	req.__enter__()
	try:
		# TODO: Write this
		rv = web.callpage(req)
	finally:
		req.__exit__(*sys.exc_info())
	
	t = rv.next()
	req.send_response()
	if environ['REQUEST_METHOD'] != 'HEAD':
		yield t
	for t in rv: 
		if environ['REQUEST_METHOD'] != 'HEAD':
			yield t

