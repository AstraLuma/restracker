<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
	<head>
		<title>Rooms</title>
	</head>
	<body>
		<h1>Rooms</h1>
		<ul>
			<li py:for="room in rooms"><a
href="/user/${room.building}/${room.roomnum}">${room.display}</a></li>
		</ul>
	</body>
</html>

