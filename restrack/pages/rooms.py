# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError
from restrack.utils import struct, result2objs_table

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
	cur = req.db.cursor()
	cur.execute("""SELECT * FROM room ORDER BY building,roomnum;""")
	data = (o[None] for o in result2objs_table(cur, Room))

	return template(req, 'room-list',rooms=data)

@page('/room/(.+)')
def building_index(req, building):
	pass

@page('/room/(.+)/(.+)')
def details(req, building, room):
	cur = req.db.cursor()
	cur.execute("""SELECT * FROM room WHERE roomnum=%(room)s and
building=%(building)s""")
	roomdata = list(result2objs_table(cur,Room))[0][None]
	cur.execute("""SELECT equipname FROM isIn WHERE roomnum=%(room)s and
building=%(building)s""")
	equipdata = (o[0] for o in ittercursor(cur))
	return template (req, 'room',room=roomdata,equipment=equipdata)

@page('/room/(.+)/(.+)/edit', mustauth=True, methods=['GET','POST'])
def edit(req, building, room):
	# Handle occupancy, equipment
	pass

@page('/room/search')
def search(req):
	pass

@page('/room/create', mustauth=True, methods=['GET','POST'])
def create(req):
	pass

