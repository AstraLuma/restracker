<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Create User</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Create User</h1>
		<div class="error" py:if="defined('msg')" py:content="msg" />
		
		<form action="/user/create" method="POST">
			<div class="infobit">
				<label for="name">Email:</label> 
				<input type="text" name="email" value="" />
			</div>
			<div class="infobit">
				<label for="name">Name:</label> 
				<input type="text" name="name" value="" />
			</div>
			
			<div class="infobit">
				<label for="password1">Password:</label> 
				<input type="password" name="password1" value="" />
			</div>
			<div class="infobit">
				<label for="password2">Repeat Password:</label> 
				<input type="password" name="password2" value="" />
			</div>
			<input type="submit" value="Save" name="edit" />
		</form>
	</body>
</html>

