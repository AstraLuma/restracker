<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Events</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Events</h1>
		<ul>
			<li py:for="event in events"><a href="/event/${event.eid}">${event.name}</a></li>
		</ul>
	</body>
</html>

