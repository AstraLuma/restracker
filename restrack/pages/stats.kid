<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Top Ten Lists</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Top Ten Lists </h1>
		<h2>Most used buildings</h2>
		<table>
			<tr py:for="room in usedrooms">
				<td>${room.c}</td>
				<!--FIXME: Use Room.display-->
				<td><a href="/room/${room.building}/${room.roomnum}">${room.building} ${room.roomnum}</a></td>
			</tr>
		</table>
		<h2>Students who run most events</h2>
		<table>
			<tr py:for="student in studentsevents">
				<td>${student.c}</td>
				<!--FIXME: Use User.name-->
				<td><a href="/user/${student.semail}" >${student.semail}</a></td>
			</tr>
		</table>
		<h2>Majors which run most events</h2>
		<table>
			<tr py:for="major in majorevents">
				<td>${major.count}</td>
				<td>${major.major or '(Undeclared)'}</td>
			</tr>
		</table>

</body>
</html>

