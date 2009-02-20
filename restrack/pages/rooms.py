# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError

@page('/room')
def index(req):
	pass

@page('/room/(.+)')
def building_index(req, building):
	pass
@page('/room/(.+)/(.+)')
def details(req, building, room):
	pass

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

