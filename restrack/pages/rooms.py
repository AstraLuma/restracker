# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError, ActionNotAllowed
from restrack.utils import struct, result2obj, first, itercursor

class Room(struct):
	__fields__ = ('occupancy','roomnum','building','displayname')
	
	@property
	def display(self):
		if self.displayname:
			 return self.displayname
		else:
			return "%s %s"%(self.building,self.roomnum)

@page('/room')
def index(req):
	"""Create the front page for room browsing."""
	cur = req.db.cursor()
	cur.execute("""SELECT * FROM room ORDER BY building, roomnum;""")
	data = result2obj(cur, Room)

	return template(req, 'room-list', rooms=data)

@page('/room/([^/]+)')
def building_index(req, building):
	"""Create the index page of for buildings."""
	cur = req.db.cursor()
	cur.execute("""
SELECT * FROM room 
	WHERE building=%(building)s 
	ORDER BY roomnum
""", {'building': building})
	data = result2obj(cur, Room)

	return template(req, 'room-list-building', rooms=data, building=building)

@page('/room/([^/]+)/([^/]+)')
def details(req, building, room):
	"""Create the page for a specific room."""
	cur = req.db.cursor()
	cur.execute("""
SELECT * FROM room 
	WHERE roomnum=%(room)s AND building=%(building)s
""", {'room': room, 'building': building})
	roomdata = first(result2obj(cur, Room))
	cur.execute("""
SELECT equipname FROM isIn 
	WHERE roomnum=%(room)s AND building=%(building)s 
	ORDER BY equipname
""", {'room': room, 'building': building})
	equipdata = [r[0] for r in itercursor(cur)]
	
	return template(req, 'room', room=roomdata, equipment=equipdata)

@page('/room/([^/]+)/([^/]+)/edit', mustauth=True, methods=['GET','POST'])
def edit(req, building, room):
	"""Edit a room page."""
	# Handle occupancy, equipment
	raise NotImplementedError

@page('/room/search')
def search(req):
	"""Search for a room based on criteria."""
	raise NotImplementedError

@page('/room/create', mustauth=True, methods=['GET','POST'])
def create(req):
	"""Page for creating a new room and adding it to the database."""
	if not req.isadmin():
		raise ActionNotAllowed
	
	post = req.post()
	if post:
		building = post['building']
		roomnum = int(post['roomnum'])
		dn = post['display']
		occ = None
		if post['occupancy']:
			occ = int(post['occupancy'])
		cur = req.execute("""INSERT INTO room (building, roomnum, displayname, occupancy)
			VALUES (%(b)s, %(rn)s, %(dn)s, %(o)s)""",
			b=building, rn=roomnum, dn=dn, o=occ)
		assert cur.rowcount
		req.status(303)
		req.header('Location', req.fullurl('/room/%s/%s' % (building, roomnum)))
	
	return template(req, 'room-create')

