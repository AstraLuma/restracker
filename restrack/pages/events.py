# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError

@page('/event')
def index(req):
	pass

@page('/event/(.+)')
def details(req, eid):
	pass

@page('/event/(.+)/edit', mustauth=True, methods=['GET','POST'])
def edit(req, eid):
	pass

@page('/event/search')
def search(req):
	pass

@page('/event/create', mustauth=True, methods=['GET','POST'])
def create(req):
	pass

