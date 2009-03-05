<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
from itertools import groupby
?>
	<head>
		<title>Unapproved Reservations</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Reservations</h1>
			<table>
				<tr py:for="reservation in reservations">
					<td> <a href="/event/${reservation.eid}/reservation/${reservation.rid}">${reservation.eid}</a></td>
					<td> ${reservation.building} ${reservation.roomnum} </td>
					<td> ${reservation.starttime} </td>
					<td> ${reservation.endtime} </td>
				</tr>
			</table>
	</body>
</html>

