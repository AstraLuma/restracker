# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError
from restrack.utils import struct, result2obj, first

class Reservation(struct):
	__fields__ = ('rid', 'timebooked', 'starttime', 'endtime', 'roomnum', 
		'semail', 'aemail', 'eid')

@page('/event/(.+)/reservation/(.+)')
def details(req, eid, rid):
	raise NotImplementedError

@page('/event/(.+)/reservation/(.+)/edit', mustauth=True, methods=['GET','POST'])
def edit(req, eid, rid):
	raise NotImplementedError

@page('/event/(.+)/reservation/create', mustauth=True, methods=['GET','POST'])
def create(req):
	raise NotImplementedError

