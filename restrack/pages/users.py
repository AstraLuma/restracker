# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with users.
"""
import hashlib
from restrack.web import page, template, HTTPError
from restrack.utils import struct, wrapprop, result2objs_table

class User(struct):
	__fields__ = ('email', 'name',
		# admin
		'title', 'super',
		# student
		'year', 'major1', 'major2',
		# club
		'description', 'class'
		)
	class_ = wrapprop('class')
	
	@property
	def majors(self):
		if hasattr(self, 'major1') and self.major1:
			if hasattr(self, 'major2') and self.major2:
				return self.major1, self.major2
			else:
				return self.major1,
		else:
			return ()

@page('/user')
def index(req):
	req.header('Content-Type', 'text/html')
	
	cur = req.db.cursor()
	cur.execute("""SELECT * FROM users ORDER BY name;""")
	data = (o[None] for o in result2objs_table(cur, User))
	
	return template(req, 'user-list', users=data)

@page('/user/([^/]+)') #regex
def details(req, userid): # The group from the regex is passed as a positional parameter
	req.header('Content-Type', 'text/html')
	
	cur = req.db.cursor()
	cur.execute("""
SELECT * FROM users 
	LEFT OUTER JOIN admin ON email = aEmail 
	LEFT OUTER JOIN student ON email = sEmail
	LEFT OUTER JOIN club ON email = cEmail
WHERE email = %(email)s;
""", {'email': userid})
	if cur.rowcount == 0:
		raise HTTPError(404)
	data = list(result2objs_table(cur, User))[0][None]
	
	# sent all at once
	return template(req, 'user', user=data) # user is a variable that the template references

def user_edit(req, user):
	# Handles:
	# * user/student/admin/club info
	# * changing the type of user
	# * making admins super
	# * Adding club adminship
	pass

@page('/user/edit', mustauth=True, methods=['GET','POST'])
def editme(req):
	return user_edit(req, req.user)

@page('/user/(.+)/edit', mustauth=True, methods=['GET','POST'])
def editthem(req, user):
	return user_edit(req, user)

@page('/user/create', methods=['GET','POST'])
def create(req):
	pass

@page('/login', methods=['GET', 'POST'])
def login(req):
	error = None
	url = req.query().get('returnto', None)
	post = req.post()
	if post is not None:
		url = post.get('returnto', [None])[0]
		user = post['user'][0]
		pword = post['password'][0]
		hp = hashlib.md5()
		hp.update(pword)
		
		cur = req.db.cursor()
		cur.execute("SELECT * FROM users WHERE email=%(user)s AND password=%(hash)s", 
			{'user': user, 'hash': hp.hexdigest()})
		if cur.rowcount == 0:
			error = "User/password pair does not exist."
		else:
			req.session['user'] = user
			req.status(303)
			req.header('Location', req.fullurl(url))
			return
	# Print the form, possibly with error
	print post, error
	return template(req, 'login', returnto=url, error=error)

@page('/logout')
def logout(req):
	if 'user' in req.session:
		del req.session['user']
	url = req.query().get('returnto', None)
	return template(req, 'logout', returnto=url)

