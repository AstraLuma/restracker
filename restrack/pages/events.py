# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
# kate: tab-width 4;
"""
Stuff dealing with rooms.
"""
from restrack.web import page, template, HTTPError, ActionNotAllowed
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
	
	cur = req.execute("SELECT * FROM event WHERE eid=%(id)i", id=eid)
	if cur.rowcount == 0:
		raise HTTPError(404)
	event = first(result2obj(cur, Event))
	
	cur = req.execute(
		"SELECT * FROM runBy NATURAL JOIN clubusers WHERE eid=%(id)i ORDER BY name", 
		id=eid)
	clubs = list(result2obj(cur, User))
	
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
	
	cur = req.execute(
		"SELECT * FROM comments NATURAL JOIN users WHERE EID=%(id)i ORDER BY madeat", 
		id=eid)
	comments = list(result2obj(cur, Comment))
	
	cur = req.execute(
		"SELECT equipname FROM uses WHERE EID=%(id)i ORDER BY equipname", 
		id=eid)
	equipment = [r[0] for r in itercursor(cur)]
	
	return template(req, 'event', 
		event=event, clubs=clubs, equipment=equipment, comments=comments, 
		reservations=reservations)

@page(r'/event/(\d+)/comment', mustauth=True, methods=['GET','POST'])
def comment(req, eid):
	try:
		eid = int(eid)
	except:
		raise HTTPError(404)
	get = req.query()
	post = req.post()
	
	cur = req.db.cursor()
	cur.execute("SELECT * FROM event WHERE eid=%(id)i", {'id': eid})
	if cur.rowcount == 0:
		raise HTTPError(404)
	event = first(result2obj(cur, Event))
	
	if post:
		replyto=None
		if 'replyto' in post:
			replyto = int(post['replyto'])
		
		txt = post['txt'].replace('\r\n', '\n').replace('\r', '\n')
		
		if replyto is None:
			cur = req.execute("""
INSERT INTO comments (eid, madeat, email, txt)
	VALUES (%(eid)i, NOW(), %(user)s, %(txt)s)""",
				eid=eid, user=req.user, txt=txt)
		else:
			cur = req.execute("""
INSERT INTO comments (eid, madeat, email, txt, parent)
	VALUES (%(eid)i, NOW(), %(user)s, %(txt)s, %(replyto)i)""", 
				eid=eid, user=req.user, txt=txt, replyto=replyto)
		
		assert cur.rowcount
		cid = cur.lastrowid
		req.status(303)
		req.header('Location', req.fullurl('/event/%i#comment%i' % (eid, cid)))
		return
	else:
		quoted = ''
		parent = None
		if get is not None and 'replyto' in get:
			try:
				r2 = int(get['replyto'])
			except: pass
			else:
				cur.execute(
					"SELECT * FROM comments NATURAL JOIN users WHERE cid=%(id)i", 
					id=r2)
				parent = first(result2obj(cur, Event))
				quoted = '\n'.join('> '+l for l in parent.txt.split('\n')) + '\n'
		return template(req, 'event-comment', event=event, parent=parent, quoted=quoted)

@page(r'/event/(\d+)/edit', mustauth=True, methods=['GET','POST'])
def edit(req, eid):
	try:
		eid = int(eid)
	except:
		raise HTTPError(404)
	
	cur = req.execute("SELECT * FROM event WHERE eid=%(id)i", id=eid)
	if cur.rowcount == 0:
		raise HTTPError(404)
	event = first(result2obj(cur, Event))
	
	cur = req.execute(
		"SELECT * FROM runBy NATURAL JOIN clubusers WHERE eid=%(id)i ORDER BY name", 
		id=eid)
	clubs = list(result2obj(cur, User))
	
	cur = req.execute(
		"SELECT equipname FROM uses WHERE EID=%(id)i ORDER BY equipname", 
		id=eid)
	equipment = [r[0] for r in itercursor(cur)]
	
	if not (req.inclub(c.email for c in clubs) or req.issuper()):
		raise ActionNotAllowed
	
	post = req.post()
	if post:
		if 'basicinfo' in post:
			size = None
			if post['expectedsize']:
				size = int(post['expectedsize'])
			
			req.execute("""UPDATE event 
SET name=%(name)s, description=%(desc)s, expectedsize=%(size)s 
WHERE eid=%(eid)i""",
			name=post['name'], desc=post['description'], size=size, eid=eid)
		
		elif 'club-delete' in post and len(clubs) > 1:
			# Broken?
			if req.inclub(post['cemail']) or req.issuper():
				req.execute("DELETE FROM runby WHERE eid=%(e)i AND cemail=%(c)s",
					e=eid, c=post['cemail'])
		elif 'club-add' in post:
			if (req.isstudent() and req.inclub([post['cemail']])) \
					or req.isclub() or req.issuper():
				req.execute("INSERT INTO runby (eid, cemail) VALUES (%(e)i, %(c)s)",
					e=eid, c=post['cemail'])
		
		elif 'equip-delete' in post:
			req.execute("DELETE FROM uses WHERE eid=%(e)i AND equipname=%(eq)s",
				e=eid, eq=post['equipname'])
		elif 'equip-add' in post:
			req.execute("""INSERT INTO uses (eid, equipname) VALUES (%(e)i, %(eq)s)""",
				e=eid, eq=post['equipname'])
		
		req.status(303)
		req.header('Location', req.fullurl('/event/%i/edit' % (eid)))
	else:
		userclubs = None
		if req.isstudent():
			cur = req.execute("""
SELECT * FROM memberof NATURAL JOIN clubusers WHERE semail=%(email)s ORDER BY name""", 
				email=req.user)
			userclubs = list(result2obj(cur, User))
		return template(req, 'event-edit', 
			event=event, clubs=clubs, equipment=equipment, userclubs=userclubs)

@page('/event/search', methods=['GET','POST'])
def search(req):
	raise NotImplementedError

@page('/event/create', mustauth=True, methods=['GET','POST'])
def create(req):
	if not (req.isstudent() or req.issuper()):
		raise ActionNotAllowed
	raise NotImplementedError

