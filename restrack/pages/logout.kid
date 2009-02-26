<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Log Out</title>
	</head>
	<body>
		<h1>Log Out</h1>
		<p>You have been logged out</p>
		<p py:if="returnto"><a href="${returnto}">Return to the previous page</a></p>
	</body>
</html>

