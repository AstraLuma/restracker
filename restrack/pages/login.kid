<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Log In</title>
	</head>
	<body>
		<h1>Log In</h1>
		<div class="error" py:if="error" py:content="error" />
		<form action="/login" method="POST">
			<input py:if="defined('returnto')" name="returnto" type="hidden" value="${returnto}" />
			<label>User:</label> <input name="user" type="text" /><br />
			<label>Password:</label> <input name="password" type="password" /><br />
			<input type="submit" value="Log In" />
		</form>
	</body>
</html>

