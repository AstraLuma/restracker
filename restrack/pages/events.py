# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError

@page('/event')
def index(req):
	raise NotImplementedError

@page('/event/(.+)')
def details(req, eid):
	raise NotImplementedError

@page('/event/(.+)/edit', mustauth=True, methods=['GET','POST'])
def edit(req, eid):
	raise NotImplementedError

@page('/event/search')
def search(req):
	raise NotImplementedError

@page('/event/create', mustauth=True, methods=['GET','POST'])
def create(req):
	raise NotImplementedError

