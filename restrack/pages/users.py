# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Stuff dealing with users.
"""
import hashlib, sys
from restrack.web import page, template, HTTPError, ActionNotAllowed
from restrack.utils import struct, wrapprop, result2obj, first

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
	cur = req.db.cursor()
	cur.execute("""SELECT * FROM users ORDER BY name;""")
	data = list(result2obj(cur, User))
	
	return template(req, 'user-list', users=data)

@page('/user/([^/]+)') #regex
def details(req, userid): # The group from the regex is passed as a positional parameter
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
	data = first(result2obj(cur, User))
	
	clubs = None
	if data.semail:
		cur = req.execute("""SELECT * FROM memberof NATURAL JOIN clubusers 
	WHERE semail=%(u)s""",
			u=userid)
		clubs = list(result2obj(cur, User))
	
	return template(req, 'user', user=data, clubs=clubs) # user is a variable that the template references

def user_edit(req, user):
	cur = req.db.cursor()
	# Handles:
	# * user/student/admin/club info
	# * changing the type of user
	# * making admins super
	# * Adding club adminship
	cur.execute("""
SELECT * FROM users 
	LEFT OUTER JOIN admin ON email = aEmail 
	LEFT OUTER JOIN student ON email = sEmail
	LEFT OUTER JOIN club ON email = cEmail
WHERE email = %(email)s;
""", {'email': user})
	userdata = first(result2obj(cur, User))
	if cur.rowcount == 0:
		raise HTTPError(404)
	post = req.post()
	
	clubs = None
	if userdata.semail:
		curs = req.execute("""SELECT * FROM memberof NATURAL JOIN clubusers 
	WHERE semail=%(u)s""",
			u=user)
		clubs = list(result2obj(cur, User))
	
	if post is not None:
		# Save
		cur.execute("BEGIN");
		try:
			password = None
			print repr(post)
			if post['oldpassword'] or (req.issuper() and post['password1']):
				if post['password1'] != post['password2']:
					return template(req, 'user-edit', user=userdata, msg='Mismatched passwords')
				cur.execute("""
					UPDATE users 
					SET password=md5(%(password)s)
					WHERE email=%(email)s AND password=md5(%(old)s);
					""", 
					{'email': user, 'old': post['oldpassword'], 'password': post['password1']}
					)
				assert cur.rowcount
			
			cur.execute("""
				UPDATE users 
				SET name=%(name)s
				WHERE email=%(email)s;
				""", 
				{'name': post['name'], 'email': user}
				)
			assert cur.rowcount
			if userdata.aemail and 'aemail' in post:
				title = None
				if post['title']:
					title = post['title']
				if request.issuper():
					cur.execute("""
						UPDATE admin 
						SET title=%(title)s, super=%(super)s
						WHERE aemail=%(email)s;
						""", 
						{'title': title, 'super': 'super' in post, 'email': user}
						)
				else:
					cur.execute("""
						UPDATE admin 
						SET title=%(title)s
						WHERE aemail=%(email)s;
						""", 
						{'title': title, 'email': user}
						)
				assert cur.rowcount
			if userdata.semail and 'semail' in post:
				year = major1 = major2 = None
				if post['year']: year = int(post['year'])
				if post['major1']: major1 = post['major1']
				if post['major2']: major2 = post['major2']
				if major2 and not major1:
					major1, major2 = major2, None
				cur.execute("""
					UPDATE student 
					SET year=%(year)i, major1=%(major1)s, major2=%(major2)s
					WHERE semail=%(email)s;
					""", 
					{'year': year, 'major1': major1, 'major2': major2, 'email': user}
					)
				assert cur.rowcount
			if userdata.cemail and 'cemail' in post:
				cls = desc = None
				if post['class']: cls = int(post['class'])
				if post['description']: desc = post['description']
				cur.execute("""
					UPDATE club 
					SET class=%(cls)i, description=%(desc)s 
					WHERE cemail=%(email)s;
					""", 
					{'cls': cls, 'desc': desc, 'email': user}
					)
				assert cur.rowcount
			
			if 'mkadmin' in post and req.issuper() and not userdata.aemail and not userdata.cemail:
				cur.execute("INSERT INTO admin (aemail) VALUES (%(email)s)", {'email': user})
				assert cur.rowcount
			elif 'mkstudent' in post and not userdata.semail and not userdata.cemail:
				cur.execute("INSERT INTO student (semail) VALUES (%(email)s)", {'email': user})
				assert cur.rowcount
			elif 'mkclub' in post and req.issuper() and not userdata.semail and not userdata.aemail and not userdata.cemail:
				cur.execute("INSERT INTO club (cemail) VALUES (%(email)s)", {'email': user})
				assert cur.rowcount
		finally:
			if sys.exc_info()[0] is None:
				cur.execute("COMMIT")
			else:
				cur.execute("ROLLBACK")
	cur.execute("""
SELECT * FROM users 
	LEFT OUTER JOIN admin ON email = aEmail 
	LEFT OUTER JOIN student ON email = sEmail
	LEFT OUTER JOIN club ON email = cEmail
WHERE email = %(email)s;
""", {'email': user})
	userdata = first(result2obj(cur, User))
	
	return template(req, 'user-edit', user=userdata, clubs=clubs)

@page('/user/edit', mustauth=True)
def editme(req):
	"""
	Edit the current user.
	"""
	return user_edit(req, req.user)

@page('/user/([^/]+)/edit', mustauth=True, methods=['GET','POST'])
def editthem(req, user):
	"""
	Edit another user.
	"""
	if not (req.user == user or req.issuper()):
		raise ActionNotAllowed
	return user_edit(req, user)

@page('/user/create', methods=['GET','POST'])
def create(req):
	post = req.post()
	if post is not None:
		email = post['email']
		if '/' in email:
			return template(req, 'user-create', msg='Invalid character: emails cannot contain "/"')
		name = post['name'] or None
		if post['password1'] != post['password2']:
			return template(req, 'user-create', msg='Mismatched passwords')
		password = post['password1']
		if not email:
			return template(req, 'user-create', msg='Email required')
		cur = req.db.cursor()
		cur.execute("""
			INSERT INTO users (email, name, password) 
			VALUES (%(email)s, %(name)s, md5(%(password)s))
			""", 
			{'email': email, 'name': name, 'password': post['password1']}
			)
		if cur.rowcount:
			req.status(303)
			req.header('Location', req.fullurl('/user/%s/edit' % email))
			return
		else:
			return template(req, 'user-create', msg='Email already exists: %s' % email)
	else:
		# No POST
		return template(req, 'user-create')

@page('/login', methods=['GET', 'POST'])
def login(req):
	error = None
	url = req.query().get('returnto', None)
	post = req.post()
	if post is not None:
		url = post.get('returnto', None)
		user = post['user']
		pword = post['password']
		hp = hashlib.md5()
		hp.update(pword)
		
		cur = req.db.cursor()
		cur.execute("SELECT * FROM users WHERE email=%(user)s AND password=%(hash)s", 
			{'user': user, 'hash': hp.hexdigest()})
		if cur.rowcount == 0:
			error = "User/password pair does not exist."
		else:
			req.session['user'] = user # This is the actual "login" code.
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

