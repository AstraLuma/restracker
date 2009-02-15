"""
Contains the Config object, which handles loading from a variety of sources.
"""
import os.path, warnings
__all__ = 'config'

# Used by _Config.addfile() to map a dict to objects
class _obj(object): pass

def _mkabs(path, rel):
	"""
	Like os.path.abspath(), but relative to the arg.
	"""
	if not os.path.isabs(path):
		path = os.path.join(rel, path)
	return path

class _Config(object):
	# The objects to pull config from. lower index -> higher priority
	__sources = None
	def __init__(self, *pargs):
		self.__sources = list(pargs)
	
	def addmodule(self, mod):
		"""config.addmodule(object|string)
		Adds a module, importing if necessary.
		"""
		if isinstance(mod, basestring):
			# TODO: If the caller does not have absolute_import, handle relative imports
			mod = __import__(mod)
		self.__sources.insert(0, mod)
	
	def addfile(self, fn, relto=None):
		"""config.addfile(string, [relto=string])
		Loads & executes a Python file as a module. If relto is given, it's the 
		file the referencing it.
		"""
		if relto is not None:
			fn = _mkabs(fn, os.path.dirname(relto))
		o = _obj()
		o.__dict__.update({
			'__file__': os.path.abspath(fn), 
			'__name__': os.path.basename(fn),
			})
		execfile(fn, o.__dict__)
		self.addmodule(o)
	
	def __get(self, name):
		for s in self.__sources:
			if hasattr(s, name):
				yield s, getattr(s, name)
	
	def __getattr__(self, name):
		for _,v in self.__get(name):
			return v
		else:
			return super(_Config, self).__getattr__(name)
	
	def get(self, name, default=None):
		"""config.get(string, [object]) -> object
		Gets a configuration value, or default if it is undefined.
		"""
		try:
			return getattr(self, name)
		except AttributeError:
			return default
	
	def getlist(self, name):
		"""config.getlist(string) -> sequence
		Goes through each source and concats the values together, most recent 
		first.
		"""
		rv = []
		for _,v in self.__get(name):
			rv += list(v)
		return rv
	
	def getpath(self, name):
		"""config.getpath(string) -> string
		Gets the config value and turns it into an absolute path, 
		relative to the source file.
		
		NOTE: If a configuration source does not have a __file__ attribute, it 
		is skipped with a warning if the value is not already absolute.
		"""
		for s,v in self.__get(name):
			if not os.path.isabs(v):
				if hasattr(s, '__file__'):
					rel = os.path.dirname(s.__file__)
					v = _mkabs(v, rel)
				else:
					warnings.warn("Relative path-valued setting found in %r but unable to make an absolute path out of it." % s)
					continue
			if os.path.isabs(v):
				return v
		else:
			raise ValueError, "%s is not a known setting" % name

	def getpathlist(self, name):
		"""config.getpathlist(string) -> sequence
		Combines getpath() and getlist().
		"""
		rv = []
		for s,vl in self.__get(name):
			rel = None
			if hasattr(s, '__file__'):
				rel = os.path.dirname(s.__file__)
			for v in vl:
				if not os.path.isabs(v):
					if rel is not None:
						v = _mkabs(v, rel)
					else:
						warnings.warn("Relative path-valued setting found in %r but unable to make an absolute path out of it." % s)
						continue
				if os.path.isabs(v):
					rv.append(v)
		return rv

config = _Config()
config.addfile('site-config.py', relto=__file__)
