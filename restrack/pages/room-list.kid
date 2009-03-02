<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
from itertools import groupby
?>
	<head>
		<title>Rooms</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Rooms</h1>

		<ul>
			<li py:for="building, rms in groupby(rooms, key=lambda o: o.building)">
				<a href="/room/${building}">${building}</a>
				<ul>
				<li py:for="room in rms">
					<a href="/room/${room.building}/${room.roomnum}">${room.display}</a>
				</li>
				</ul>
			</li>
		</ul>
	</body>
</html>

