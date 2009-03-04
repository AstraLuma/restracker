<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>User Info - ${user.name}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<!--pre py:content="repr(user)" /-->
		<h1>${user.name}</h1>
		<div class="infobit"><span>Email:</span> ${user.email}</div>
		<fieldset py:if="user.aemail">
			<legend>Administrator Info</legend>
			<div class="infobit" py:if="user.title"><span>Title:</span> ${user.title}</div>
			<div class="infobit"><span>SuperAdmin:</span> ${user.super}</div>
		</fieldset>
		<fieldset py:if="user.semail">
			<legend>Student Info</legend>
			<div class="infobit" py:if="user.year"><span>Year:</span> ${user.year}</div>
			<div class="infobit" py:if="user.majors"><span>Majors:</span> <span py:replace="', '.join(user.majors)" /></div>
			<div class="infobit" py:if="not user.majors"><span>Majors:</span> Undeclared</div>
			<div class="infobit" py:if="clubs"><span>Clubs:</span>
				<ul>
					<li py:for="club in clubs">
						<a href="/user/${club.cemail}">${club.name}</a>
					</li>
				</ul>
			</div>
		</fieldset>
		<fieldset py:if="user.cemail">
			<legend>Club Info</legend>
			<div class="infobit" py:if="user.description"><span>Description:</span> ${user.description}</div>
			<div class="infobit" py:if="user.class_"><span>SGA Class:</span> ${user.class_}</div>
		</fieldset>
		
		<div py:if="request.user == user.email or request.issuper()">
			<a href="/user/${user.email}/edit">Edit</a>
		</div>
		
		<div py:if="request.isclub() and user.semail">
			<a py:if="request.user not in [c.cemail for c in clubs]" href="/user/${request.user}/adduser?user=${user.email}">Add ${user.name} to yourself</a>
			<span py:if="request.user in [c.cemail for c in clubs]">${user.name} is already a member of you</span>
		</div>
	</body>
</html>

