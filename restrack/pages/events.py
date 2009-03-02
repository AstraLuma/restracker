# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError
from restrack.utils import struct, result2obj, first, itercursor
from users import User
from reservations import Reservation

class Event(struct):
	__fields__ = ('eid', 'name', 'description', 'expectedsize')

class Comment(struct):
	__fields__ = ('cid', 'madeat', 'txt', 'email', 'eid', 'parent')

@page('/event')
def index(req):
	cur = req.db.cursor()
	cur.execute("SELECT * FROM event ORDER BY name;")
	data = list(result2obj(cur, Event))
	
	return template(req, 'event-list', events=data)

@page(r'/event/(\d+)')
def details(req, eid):
	try:
		eid = int(eid)
	except:
		raise HTTPError(404)
	
	cur = req.db.cursor()
	cur.execute("SELECT * FROM event WHERE eid=%(id)i", {'id': eid})
	if cur.rowcount == 0:
		raise HTTPError(404)
	event = first(result2obj(cur, Event))
	
	cur.execute("""
SELECT * FROM runBy NATURAL JOIN club, users 
	WHERE cemail=email AND eid=%(id)i
	ORDER BY name""", {'id': eid})
	clubs = list(result2obj(cur, User))
	
	cur.execute("""
SELECT * FROM reservation NATURAL JOIN (
		SELECT count(r2.RID) AS conflicts, r1.RID
			FROM reservation AS r1, reservation AS r2
			WHERE (r1.startTime, r1.endTime) OVERLAPS (r2.startTime, r2.endTime) 
				AND r1.EID=%(event)i AND r2.EID!=%(event)i
				AND r1.roomNum=r2.roomNum AND r1.building=r2.building 
			GROUP BY r1.RID
		) AS conflicting
	WHERE reservation.eid = %(event)i
	ORDER BY starttime""", {'event': eid})
	reservations = list(result2obj(cur, Reservation))
	
	cur.execute("SELECT * FROM comments NATURAL JOIN users WHERE EID=%(id)i ORDER BY madeat", {'id': eid})
	comments = list(result2obj(cur, Comment))
	
	cur.execute("SELECT equipname FROM uses WHERE EID=%(id)i ORDER BY equipname", {'id': eid})
	equipment = [r[0] for r in itercursor(cur)]
	
	return template(req, 'event', event=event, clubs=clubs, equipment=equipment, comments=comments)

@page(r'/event/(\d+)/comment', mustauth=True, methods=['GET','POST'])
def comment(req, eid):
	raise NotImplementedError

@page(r'/event/(\d+)/edit', mustauth=True, methods=['GET','POST'])
def edit(req, eid):
#	if not (req.inclub(c.email for c in clubs) or req.issuper()):
#		raise ActionNotAllowed
	raise NotImplementedError

@page('/event/search', methods=['GET','POST'])
def search(req):
	raise NotImplementedError

@page('/event/create', mustauth=True, methods=['GET','POST'])
def create(req):
	raise NotImplementedError

