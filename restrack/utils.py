# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Helpful functions, classes, etc. That don't really have a home.
"""
import pgdb
__all__ = 'blob',

class blob(object):
	"""
	A quick hack so that bytea isn't double-escaped.
	
	To insert into a query:
		>>> cur.execute("... %(spam)s ...", {'spam': blob('eggs')})
	
	To load from a SELECT:
		>>> blob.load(cur.fetchone()[0])
		"eggs"
	"""
	def __init__(self, data):
		self.data = data
	
	def __pg_repr__(self):
		return "E'%s'::bytea" % pgdb.escape_bytea(self.data)
	
	@staticmethod
	def load(data):
		return pgdb.unescape_bytea(data)

