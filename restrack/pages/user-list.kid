<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
	<head>
		<title>Users</title>
	</head>
	<body>
		<h1>Users</h1>
		<ul>
			<li py:for="user in users"><a href="/user/${user.email}">${user.name}</a></li>
		</ul>
	</body>
</html>

