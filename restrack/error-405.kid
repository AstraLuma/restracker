<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>405 Method Not Allowed</title>
	</head>
	<body>
		<img src="http://www.python.org/images/PythonPoweredSmall.gif" style="float: right;" />
		<h1>Method Not Allowed</h1>
		<p>The requested URL <tt py:content="request.getpath()" /> does not 
			allow <tt py:content="request.environ['REQUEST_METHOD']" /> requests.</p>
		<hr />
		<address><span py:replace="request.environ['SERVER_SOFTWARE']"/> Server at <span py:replace="request.environ['SERVER_NAME']"/> Port <span py:replace="request.environ['SERVER_PORT']"/></address>
	</body>
</html>

