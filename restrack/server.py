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

class Request(object):
	"""
	The req object passed to pages.
	"""
	#TODO: Sessions
	__slots__ = ('__weakref__', 'environ', '_start_response', 'db', 
		'_log_handler', 'cookies', 'session', 'user')
	def __init__(self, environ, start_response):
		self.environ = environ
		self._start_response = start_response
		
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
		self.header('Set-Cookie', 
		pass #TODO
	
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

