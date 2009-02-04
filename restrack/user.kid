<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html py:extends="'page.kid'" xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
	<head>
		<title>User Info - ${user.name}</title>
	</head>
	<body>
		<div id="user-info" py:content="user"></div>
	</body>
</html>

