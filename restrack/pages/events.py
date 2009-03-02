# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError
from restrack.utils import struct, result2obj, first

class Event(struct):
	__fields__ = ('eid', 'name', 'description', 'expectedsize')

@page('/event')
def index(req):
	cur = req.db.cursor()
	cur.execute("""SELECT * FROM event ORDER BY name;""")
	data = list(result2obj(cur, Event))
	
	return template(req, 'event-list', events=data)

@page(r'/event/(\d+)')
def details(req, eid):
	raise NotImplementedError

@page(r'/event/(\d+)/edit', mustauth=True, methods=['GET','POST'])
def edit(req, eid):
	raise NotImplementedError

@page('/event/search', methods=['GET','POST'])
def search(req):
	raise NotImplementedError

@page('/event/create', mustauth=True, methods=['GET','POST'])
def create(req):
	raise NotImplementedError

