<?xml version="1.0" encoding="utf-8" ?>
<!-- Copy this to create a new page -->
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>(Your Title Here)</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>(Your Title Here)</h1>
		<p>(Your Content Here)</p>
	</body>
</html>

