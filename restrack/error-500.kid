<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<?python
import traceback
?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
# We can get away with this because nothing's sent until after this is executed
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>500 Internal Server Error</title>
	</head>
	<body>
		<img src="http://www.python.org/images/PythonPoweredSmall.gif" style="float: right;" />
		<h1>Internal Server Error</h1>
		<p>The server encountered an internal error or misconfiguration and was 
		unable to complete your request.</p>
		<p>Please contact the server administrator, <span py:replace="None" /> 
		and inform them of the time the error occurred, and anything you might 
		have done that may have caused the error.</p>
		<p>More information about this error may be available in the server 
		error log.</p>
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

