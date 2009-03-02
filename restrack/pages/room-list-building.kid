<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
	<head>
		<title>Rooms - ${building}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Rooms - ${building}</h1>
		<ul>
			<li py:for="room in rooms">
				<a href="/room/${room.building}/${room.roomnum}">${room.display}</a>
			</li>
		</ul>
	</body>
</html>

