<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Delete Reservation - ${event.name}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Delete Reservation - <a href="/event/${event.eid}">${event.name}</a>:<br/> 
			${reservation.format()}</h1>
		<div>
			<div>Are you sure you want to delete this reservation?</div>
			<form action="/event/${event.eid}/reservation/${reservation.rid}/delete" method="POST">
				<div>
					<input type="submit" name="yes" value="Yes" />
					<input type="submit" name="no" value="No" />
				</div>
			</form>
		</div>
	</body>
</html>

