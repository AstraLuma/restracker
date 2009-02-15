"""
Contains the Config object, which handles loading from a variety of sources.
"""
__all__ = 'config'
class _obj(object): pass

class _Config(object):
	__sources = None
	def __init__(self, *pargs):
		self.__sources = list(pargs)
	
	def addmodule(self, mod):
		"""config.addmodule(object|string)
		Adds a module, importing if necessary.
		"""
		if isinstance(mod, basestring):
			self.__sources.append(__import__(mod))
		else:
			self.__sources.append(mod)
	
	def addfile(self, fn):
		"""config.addfile(string)
		Loads & executes a Python file as a module.
		"""
		g = {
			'__file__': os.path.abspath(fn), 
			'__name__': os.path.basename(fn).replace('/', '.'),
			}
		execfile(fn, g)
		o = _obj()
		o.__dict__.update(g)
		self.addmodule(o)
	
	def __getattr__(self, name):
		for s in self.__sources:
			if hasattr(s, name):
				return getattr(s, name)
		else:
			return super(_Config, self).__getattr__(name)

config = _Config()
config.addmodule('siteconfig')
