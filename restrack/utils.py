# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Helpful functions, classes, etc. That don't really have a home.
"""
import pgdb, itertools
__all__ = 'blob', 'struct', 'itercursor', 'result2objs', 'result2objs_table'

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

class struct(object):
	"""
	Helps when moving between objects and queries. Meant to be subclassed.
	"""
	__slots__ = '__weakref__', '__dict__'
	def __new__(cls, *pargs, **kwargs):
		"""struct(...)
		Takes the same arguments as dict.
		"""
		self = super(struct, cls).__new__(cls)
		self.__dict__.update(dict(*p, **kw))
	
	def __repr__(self):
		"""s.__repr__() <==> repr(s)
		"""
		return '<%s %s at 0x%08x>' % (
			type(self).__name__,
			' '.join('%s=%r' % av for av in self.__dict__.iteritems()),
			id(self)
			)
	
	# Cursor -> Struct
	@classmethod
	def row(cls, attrs, row):
		"""Struct.row((string, ...), (object, ...)) -> Struct
		Makes an instance of the class it's called from, assigning each item in 
		row to each property in attrs.
		"""
		assert len(attrs) == len(row)
		return cls(dict(zip(attrs, zip)))
	
	@classmethod
	def rows(cls, attrs, rows):
		"""Struct.rows((string, ...), [(object, ...), ...]) -> Struct, ...
		Produces multiple instances of the object by repeatedly calling row().
		"""
		for row in rows:
			yield cls.row(attrs, row)
	
	# Struct -> Cursor
	def get(self, *attrs):
		"""s.get(string, ...) -> tuple
		Returns the values of the named properties in the order given.
		"""
		return tuple(getattr(self, a) for a in attrs)
	
	def getdict(self, *attrs, **renamed):
		"""s.getdict(string, ...) -> dict
		Returns the values of the named properties in a dictionary. Can use the 
		form name='attribute' to rename attributes.
		"""
		rv = {}
		for a in attrs:
			rv[a] = getattr(self, a)
		for n, a in renamed.iteritems():
			rv[n] = getattr(self, a)
		return rv

xor = lambda l, r: bool(l) ^ bool(r)

def itercursor(cursor):
	"""itercursor(cursor) -> tuple, ...
	Repeatedly calls fetchone(), producing each row. Use in for-loops.
	"""
	r = cursor.fetchone()
	while r is not None:
		yield r
		r = cursor.fetchone()

def result2objs(cursor, *tmap, **dmap):
	"""result2objs(dbCursor, (slice, cls, attr, ...), ...) -> tuple, ...
	result2objs(dbCusros, name=(slice, cls, attr, ...), ...) -> dict, ...
	Maps an entire result set to a generator of either tuples or dicts, 
	depending on how it's called.
	"""
	if not xor(len(tmap), len(dmap)):
		raise TypeError, "Call with either positional or keyword arguments, not both."
	for row in itercursor(cursor):
		if len(tmap):
			yield tuple(sca[1].row(sca[2:], row[sca[0]]) for sca in tmap)
		else: # if len(tmap)
			yield dict((key, sca[1].row(sca[2:], row[sca[0]])) for key, sca in dmap.iteritems())

def result2objs_table(cursor, *pargs, **tableclass):
	"""result2objs_table(dbCursor, [class], table=class, ...) -> dict, ...
	Maps each row in a reult to a dictionary of instances, by table. If a 
	positional argument is given, fields without tables are put there (key is 
	None).
	"""
	# TODO: Full of clever bits, needs to be tested
	assert 0 <= len(pargs) < 2
	
	# prefix: table, class, fields=[(index, name), ...]
	ptcf = {}
	if len(pargs):
		ptcf[''] = None, pargs[0], [(i, f[0]) for i,f in enumerate(cursor.description) 
			if '.' not in f[0]]
	for table, cls in tableclass.items():
		ptcf[table+'.'] = table, cls, [(i, f[0][len(pre):]) for i,f in enumerate(cursor.description) 
			if f[0].startswith(pre)]
	
	for row in itercursor(cursor):
		rv = {}
		for pre, (tbl, cls, flds) in ptcf.items():
			vals = {}
			for i,n in flds:
				vals[n] = row[i]
			rv[tbl] = cls(**vals)
		yield rv

