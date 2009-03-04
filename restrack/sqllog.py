# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Defines classes for logging SQL queries.

Also contains some hacks for getting types to work.
"""
import logging
__all__ = 'ConnWrapper',

class ConnWrapper(object):
	__obj = None
	def __init__(self, obj):
		self.__obj = obj
	
	def __getattr__(self, name):
		return getattr(self.__obj, name)
	
	def cursor(self):
		return CurWrapper(self.__obj.cursor())

class CurWrapper(object):
	__obj = None
	def __init__(self, obj):
		self.__obj = obj
		self.__exec = set()
		self.__many = set()
		self.__proc = set()
	
	def __getattr__(self, name):
		return getattr(self.__obj, name)
	
	def _reduce(self, sql):
		#TODO: reduce whitespace to single space
		import re
		sql = re.sub("[ \t\r\n]+", ' ', sql)
		return sql.strip()
	
	def callproc(self, procname, *pargs, **kwargs):
		if operation not in self.__proc:
			logging.getLogger('sql.callproc').info("%s", procname)
			self.__proc.add(operation)
		return self.__obj.callproc(procname, *pargs, **kwargs)
	
	def execute(self, operation, *pargs, **kwargs):
		if operation not in self.__exec:
			logging.getLogger('sql.execute').info("%s", self._reduce(operation))
			self.__exec.add(operation)
		return self.__obj.execute(operation, *pargs, **kwargs)
	
	def executemany(self, operation, *pargs, **kwargs):
		if operation not in self.__many:
			logging.getLogger('sql.executemany').info("%s", self._reduce(operation))
			self.__many.add(operation)
		return self.__obj.executemany(operation, *pargs, **kwargs)

setup = False
def setuplog():
	global setup
	if setup: return
	l = logging.getLogger('sql')
	l.propogate = False
	l.setLevel(logging.INFO)
	lh = logging.FileHandler('queries.log')
	lh.setFormatter(logging.Formatter("%(name)s: %(message)r"))
	l.addHandler(lh)
	setup = True

### THERE BE DRAGONS HERE ###

import pgdb
import utils

_oldTypeCache = pgdb.pgdbTypeCache
class pgdbTypeCache(_oldTypeCache):
	def typecast(self, typ, value):
		# pgdb doesn't do timestamps correctly
		if typ == pgdb.BINARY:
			return utils.blob.load(value)
		elif typ == pgdb.DATETIME:
			return utils.datetime.load(value)
		else:
			return _oldTypeCache.typecast(self, typ, value)

pgdb.pgdbTypeCache = pgdbTypeCache
