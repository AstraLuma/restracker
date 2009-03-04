# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError
from restrack.utils import struct, result2obj, first

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
	raise NotImplementedError

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
	raise NotImplementedError

@page(r'/event/(\d+)/reservation/create', mustauth=True, methods=['GET','POST'])
def create(req, eid):
	try:
		eid = int(eid)
	except:
		raise HTTPError(404)
	raise NotImplementedError

