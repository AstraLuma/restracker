<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Users</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Users</h1>
		<ul>
			<li py:for="user in users"><a href="/user/${user.email}">${user.name}</a></li>
		</ul>
		<a py:if="not request.isuser() or request.issuper()" href="/user/create">Create New</a>
	</body>
</html>

