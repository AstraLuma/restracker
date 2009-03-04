# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
# kate: tab-width 4;
"""
The top-level WSGI work.
"""
import sys, logging, urllib, pgdb, Cookie, random, time, pickle, cgi
# Local imports
import web, utils, sqllog
from config import config
__all__ = 'Request', 'restracker_app'

FORMAT = "(%(name)s)[%(asctime)s] %(filename)s:%(lineno)d: %(levelname)s: %(message)s"
logging.basicConfig(filename='/tmp/restracker.log', format=FORMAT)

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
	#TODO: Use more urlparse stuff
	#TODO: Examine wsgiref more and see if it's useful
	def __init__(self, environ, start_response):
		self.environ = environ
		self._start_response = start_response
		self._status = None
		self._headers = []
		
		# Database
		self.db = pgdb.connect(
			host=config.SQL_HOST, database=config.SQL_DATABASE, 
			user=config.SQL_USER, password=config.SQL_PASSWORD
			)
		if config.get('SQL_LOGQUERIES', False):
			sqllog.setuplog()
			self.db = sqllog.ConnWrapper(self.db)
		
		# Cookies
		self.cookies = Cookie.SimpleCookie(self.environ.get('HTTP_COOKIE', None))
		
		# Session
		self._session_id = None
		if config.SESSION_COOKIE in self.cookies:
			self._session_id = self.cookies[config.SESSION_COOKIE].value
			cur = self.db.cursor()
			cur.execute(
				"""SELECT data FROM sessions WHERE id=%(id)s""", 
				dict(id=self._session_id)
				)
			data = cur.fetchone()
			if data is None:
				self._session_id = None
			else:
				self.session = pickle.loads(str(utils.blob.load(data[0])))
		if self._session_id is None:
			while not self._initsession(): pass
			self.db.commit()
			self.session = {}
		self.cookies[config.SESSION_COOKIE]['max-age'] = config.SESSION_LENGTH
		
		self.user = self.session.get('user', None) # None = anonymous user
	
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
			dict(id=sess, exp=pgdb.TimestampFromTicks(exp))
			)
		if cur.rowcount == 0:
			return False
		self._session_id = sess
		self.cookies[config.SESSION_COOKIE] = sess
		return True
	
	def _mksession(self):
		"""req._mksession() -> string
		Returns a random session identifier. Not guaranteed to be unique.
		"""
		return ''.join(random.choice(SESSION_CHARS) for _ in xrange(SESSION_SIZE))
	
	def status(self, code, status=None):
		"""req.status(integer, [string]) -> None
		Sets the current HTTP status.
		"""
		self._status = code
	
	def header(self, name, value, overwrite=True):
		"""req.header(string, string, [boolean]) -> None
		Sets an HTTP header. Set overwrite to False in order to append headers.
		"""
		if overwrite:
			for v in self._headers[:]:
				if v[0].lower() == name.lower():
					self._headers.remove(v)
		self._headers.append((name, value))
	
	def fullurl(self, path=None, **query):
		"""req.fullurl([string], [name=value, ...]) -> string
		Dereferences relative URLs, prefixes domain names, etc. Adds the query 
		string in the keyword arguments.
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
		if len(query):
			url += '?'
			url += urllib.urlencode(query.items())
		return url
	
	def getpath(self):
		"""req.getpath() -> string
		Returns the path component of the URL.
		"""
		return self.environ.get('SCRIPT_NAME','')+self.environ.get('PATH_INFO','')
	
	def apppath(self):
		"""req.apppath() -> string
		Returns the path component of the URL, sans application base.
		"""
		if 'lighttpd' in self.environ['SERVER_SOFTWARE']:
			return self.getpath()
		else:
			return self.environ.get('PATH_INFO','')
	
	def returnurl(self):
		"""req.returnurl() -> string
		Returns the path to use for returnto URLs.
		"""
		url = self.getpath()
		if self.environ.get('QUERY_STRING'):
			url += '?' + self.environ['QUERY_STRING']
		return url
	
	def post(self):
		"""r.post() -> None|dict
		Returns the POST data as a dictionary, or None if there was no POST.
		"""
		rv = self.postall()
		print "rv=%r" % rv
		if rv is None:
			return None
		else:
			return dict(rv)
	
	_postvars = None
	def postall(self):
		"""r.postall() -> [(name, value), ...]
		Returns the POST data as an ordered sequence of name/value pairs, or 
		None if there was no POST.
		"""
		if 'CONTENT_LENGTH' not in self.environ: 
			return
		if not self.environ['CONTENT_LENGTH']:
			return
		if self.environ['REQUEST_METHOD'] == 'GET':
			return
		if self._postvars is None:
			ctype, pdict = cgi.parse_header(self.environ['CONTENT_TYPE'])
			clength = int(self.environ['CONTENT_LENGTH'])
			qs = self.environ['wsgi.input'].read(clength)
			self._postvars = cgi.parse_qs(qs, True)
		
		return [(k,v) for k, vs in self._postvars.iteritems() for v in vs]
	
	def query(self):
		"""r.query() -> dict
		Returns the query string as a dictionary.
		"""
		rv = self.queryall()
		if rv is None:
			return None
		else:
			return dict(rv)
	
	def queryall(self):
		"""r.queryall() -> [(name, value), ...]
		Returns the query string as an ordered sequence of name/value pairs.
		"""
		return cgi.parse_qsl(self.environ.get('QUERY_STRING', ''), True)
	
	def send_response(self, exc_info=None):
		"""req.send_response() -> None
		Sends headers & status to the client.
		"""
		headers = self._headers[:]
		headers += [('Set-Cookie', v.OutputString()) for v in self.cookies.itervalues()]
		st = HTTP_STATUS_CODES[self._status or 200]
		if exc_info is not None:
			st = HTTP_STATUS_CODES[500]
		#....
		self._start_response(st, headers, exc_info)
	
	def save_session(self):
		cur = self.db.cursor()
		cur.execute(
			"""UPDATE sessions SET data=%(data)s WHERE id=%(id)s""", 
			dict(
				id=self._session_id, 
				data=utils.blob(pickle.dumps(self.session, pickle.HIGHEST_PROTOCOL)),
				)
			)
		self.db.commit()
	
	def __enter__(self):
		"""
		PEP 343
		Causes this request to become the active one.
		"""
		# Logging
		self._log_handler = logging.StreamHandler(self.environ['wsgi.errors'])
		self._log_handler.setFormatter(logging.Formatter(FORMAT))
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
		if hasattr(self, 'db'):
			self.db.close()
	
	_issuper = None
	_isadmin = None
	_isstudent = None
	_isclub = None
	
	def _findusertypes(self):
		if self.user is None:
			self._issuper = self._isadmin = self._isstudent = self._isclub = False
		else:
			cur = self.db.cursor()
			cur.execute("""
SELECT email, aemail, super, semail, cemail FROM users 
	LEFT OUTER JOIN admin ON email = aEmail 
	LEFT OUTER JOIN student ON email = sEmail
	LEFT OUTER JOIN club ON email = cEmail
WHERE email = %(email)s;
""", {'email': self.user})
			assert cur.rowcount
			row = cur.fetchone()
			del cur
			self._issuper = row[2]
			self._isadmin = bool(row[1])
			self._isstudent = bool(row[3])
			self._isclub = bool(row[4])
	
	def isuser(self):
		return self.user is not None
	
	def isstudent(self):
		if self._isstudent is None: self._findusertypes()
		return self._isstudent
	
	def isclub(self):
		if self._isclub is None: self._findusertypes()
		return self._isclub
	
	def isadmin(self):
		if self._isadmin is None: self._findusertypes()
		return self._isadmin
	
	def issuper(self):
		if self._issuper is None: self._findusertypes()
		return self._issuper
	
	_inclubs = None
	def getclubs(self):
		if self.user is None: return []
		if self._inclubs is None:
			cur = self.db.cursor()
			cur.execute("SELECT cemail FROM memberof WHERE semail=%(email)s", {'email': self.user})
			self._inclubs = set(r[0] for r in utils.itercursor(cur))
		return list(self._inclubs)
	
	def inclub(self, clubs):
		"""r.inclub(list(string)) -> bool
		Is the current user a member of one of the given clubs? Note that if 
		the current user IS one of the clubs, this returns True.
		"""
		if self.user is None: return False
		clubs = set(clubs)
		if self.user in clubs: return True
		self.getclubs()
		return len(clubs) != len(clubs - self._inclubs)
	
	def execute(self, sql, **params):
		"""r.execute(string, [name=object, ...]) -> dbCursor
		Creates cursor, executes query, and returns cursor.
		Note that unlike cursor.execute(), parameters are taken as keyword 
		arguments not as a dict.
		"""
		cur = self.db.cursor()
		cur.execute(sql, params)
		return cur

def restracker_app(environ, start_response):
	"""
	The WSGI callback.
	"""
	
	logging.getLogger(__name__+'.restracker_app').debug("environ: %r", environ)
	
	for m in config.PAGE_MODULES:
		__import__(m)
	
	req = Request(environ, start_response)
	
	logging.getLogger(__name__+'.restracker_app').info(
		"Handling: %r (PATH_INFO=%r)", 
		req.fullurl(), req.environ['PATH_INFO']
		)
	
	# Emulate PEP 343
	req.__enter__()
	try:
		# TODO: Write this
		rv = web.callpage(req)
	except:
		req.db.rollback()
		req.status(500)
		rv = web.template(req, 'error-500', exception=sys.exc_info())
	finally:
		req.__exit__(*sys.exc_info())
	
	if rv is None:
		body = []
	else:
		body = list(rv)
	req.save_session()
	
	#FIXME: Handle 'Expect: 100-continue'
	#	(if we would send a 2xx, send a 100 instead, send 4xx as 417, and send everything else as-is)
	
	req.send_response()
	if environ['REQUEST_METHOD'] == 'HEAD':
		return []
	else:
		return body

