<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<?python
import traceback
?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Page Not Implemented</title>
	</head>
	<body>
		<img src="http://www.python.org/images/PythonPoweredSmall.gif" style="float: right;" />
		<div py:replace="up()" />
		<h1>Page Not Implemented</h1>
		<p>The function ${func.__name__} for URL ${request.apppath()} is not 
		yet implemented.</p>
		<hr />
		<div py:if="defined('exception')">
			<!-- TODO: Put cgitb-like traceback here. -->
			<pre py:content="traceback.format_exception(*exception)">
			</pre>
			<hr />
		</div>
		<address><span py:replace="request.environ['SERVER_SOFTWARE']"/> Server at <span py:replace="request.environ['SERVER_NAME']"/> Port <span py:replace="request.environ['SERVER_PORT']"/></address>
	</body>
</html>

