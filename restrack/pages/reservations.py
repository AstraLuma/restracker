# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError
from restrack.utils import struct, result2obj, first
from events import Event

class Reservation(struct):
	__fields__ = ('rid', 'timebooked', 'starttime', 'endtime', 'roomnum', 
		'building', 'semail', 'aemail', 'eid')
	
	def format(self):
		DFMT = "%m-%d-%Y "
		TFMT = "%I:%M%p"
		
		st = self.starttime.strftime(DFMT+TFMT)
		en = self.endtime.strftime(DFMT+TFMT)
		
		# If on the same day, print the date once
		if self.starttime.date() == self.endtime.date():
			en = self.endtime.strftime(TFMT)
		
		rv = '%s to %s: ' % (st, en)
		if hasattr(self, 'displayname'): # room info loaded
			from rooms import Room
			rv += Room(**self.__dict__).display
		else:
			rv += '%s %s' % (self.building, self.roomnum)
		return rv

@page(r'/event/(\d+)/reservation')
def index(req, eid):
	try:
		eid = int(eid)
	except:
		raise HTTPError(404)
	
	cur = req.execute("""
SELECT * FROM reservation NATURAL LEFT OUTER JOIN (
		SELECT COUNT(against) AS conflicts, rid
			FROM resconflicts NATURAL JOIN reservation 
			WHERE EID=%(event)i 
			GROUP BY rid
		) AS conflicting NATURAL LEFT OUTER JOIN room
	WHERE reservation.eid = %(event)i
	ORDER BY starttime""", event=eid)
	reservations = list(result2obj(cur, Reservation))
	
	return template(req, 'reservation-list', reservations=reservations)

@page(r'/event/(\d+)/reservation/(\d+)')
def details(req, eid, rid):
	try:
		eid = int(eid)
		rid = int(rid)
	except:
		raise HTTPError(404)
	raise NotImplementedError

@page(r'/event/(\d+)/reservation/(\d+)/edit', mustauth=True, methods=['GET','POST'])
def edit(req, eid, rid):
	raise NotImplementedError

@page(r'/event/(\d+)/reservation/(\d+)/approve', mustauth=True, methods=['GET','POST'])
def edit(req, eid, rid):
	try:
		eid = int(eid)
		rid = int(rid)
	except:
		raise HTTPError(404)
	
	if not req.isadmin():
		raise ActionNotAllowed
	
	cur = req.execute("SELECT * FROM event WHERE eid=%(e)i", e=eid)
	event = first(result2obj(cur, Event))
	
	cur = req.execute("SELECT * FROM reservation NATURAL JOIN room WHERE rid=%(r)i", r=rid)
	resv = first(result2obj(cur, Reservation))
	
	cur = req.execute(
		"SELECT * FROM resconflicts NATURAL JOIN reservation NATURAL JOIN room WHERE against=%(r)i",
		r=rid)
	confs = list(result2obj(cur, Reservation))
	
	post = req.post()
	if post and not resv.aemail:
		pass
	
	return template(req, 'reservation-approve', event=event, reservation=resv, 
		conflicts=confs)

@page(r'/event/(\d+)/reservation/create', mustauth=True, methods=['GET','POST'])
def create(req, eid):
	try:
		eid = int(eid)
	except:
		raise HTTPError(404)
	raise NotImplementedError

