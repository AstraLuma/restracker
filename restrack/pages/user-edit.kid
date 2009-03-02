<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Modify User - ${user.name}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<!--pre py:content="repr(user)" /-->
		<h1>${user.name} - Edit</h1>
		<div class="error" py:if="defined('msg')" py:content="msg" />
		
		<form action="/user/${user.email}/edit" method="POST">
			<div class="infobit"><span>Email:</span> ${user.email}</div>
			<div class="infobit">
				<label for="name">Name:</label> 
				<input type="text" name="name" value="${user.name}" />
			</div>
			
			<div class="infobit">
				<label for="oldpassword">Old Password:</label> 
				<input type="password" name="oldpassword" value="" />
			</div>
			<div class="infobit">
				<label for="password1">New Password:</label> 
				<input type="password" name="password1" value="" />
			</div>
			<div class="infobit">
				<label for="password2">Repeat Password:</label> 
				<input type="password" name="password2" value="" />
			</div>
			
			<fieldset py:if="user.aemail">
				<legend>Administrator Info</legend>
				<input type="hidden" name="aemail" value="${user.aemail}" />
				<div class="infobit">
					<label for="title">Title:</label> 
					<input type="text" name="title" value="${user.title} or ''" />
				</div>
				<div class="infobit" py:if="request.issuper()">
					<label for="super">SuperAdmin:</label> 
					<input type="checkbox" name="super" py:attrs="{'checked': 'checked'} and user.super or {}" value="super" />
				</div>
				<div class="infobit" py:if="not request.issuper()">
					<span>SuperAdmin:</span> ${user.super}
				</div>
			</fieldset>
			<fieldset py:if="user.semail">
				<legend>Student Info</legend>
				<input type="hidden" name="semail" value="${user.semail}" />
				<div class="infobit">
					<label for="year">Year:</label> 
					<input type="text" name="year" value="${user.year}" />
				</div>
				<div class="infobit">
					<label for="major1">Major 1:</label> 
					<input type="text" name="major1" value="${user.major1}" />
				</div>
				<div class="infobit">
					<label for="major2">Major 2:</label> 
					<input type="text" name="major2" value="${user.major2}" />
				</div>
			</fieldset>
			<fieldset py:if="user.cemail">
				<legend>Club Info</legend>
				<input type="hidden" name="cemail" value="${user.cemail}" />
				<div class="infobit">
					<label for="description">Description:</label> 
					<input type="text" name="description" value="${user.description}" />
				</div>
				<div class="infobit">
					<label for="class">SGA Class:</label> 
					<input type="text" name="class" value="${user.class_}" />
				</div>
			</fieldset>
			<a href="/user/${user.email}">Details</a>
			<input type="submit" value="Save" name="edit" />
			<div py:if="not user.cemail">
				<input py:if="not user.aemail and request.issuper()" type="submit" name="mkadmin" value="Make Admin" />
				<input py:if="not user.semail" type="submit" name="mkstudent" value="Make Student" />
				<input py:if="not user.aemail and not user.semail and request.issuper()" type="submit" name="mkclub" value="Make Club" />
			</div>
		</form>
	</body>
</html>

