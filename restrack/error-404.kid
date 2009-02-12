<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
	<head>
		<title>404 Not Found</title>
	</head>
	<body>
		<h1>Not Found</h1>
		<p>The requested URL <tt py:content="request.getpath()" /> was not found on this server.</p>
		<hr />
		<address><span py:replace="request.environ['SERVER_SOFTWARE']"/> Server at <span py:replace="request.environ['SERVER_NAME']"/> Port <span py:replace="request.environ['SERVER_PORT']"/></address>
	</body>
</html>

