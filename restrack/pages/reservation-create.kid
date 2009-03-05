<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Create Reservation - ${event.name}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Create Reservation - ${event.name}</h1>
		<form action="/event/${event.eid}/reservation/create" method="POST">
			<div class="bitinfo" py:if="request.issuper()">
				<label for="semail">Student booking:</label>
				<input type="text" name="semail" />
			</div>
			<div class="bitinfo">
				<label for="building">Building:</label>
				<input type="text" name="building" maxlength="3" value="${building}" />
			</div>
			<div class="bitinfo">
				<label for="roomnum">Room:</label>
				<input type="text" name="roomnum" maxlength="6" value="${roomnum}" />
			</div>
			<div class="bitinfo">
				<label for="starttime">Start:</label>
				<input type="text" name="starttime" value="${starttime}" />
			</div>
			<div class="bitinfo">
				<label for="endtime">End:</label>
				<input type="text" name="endtime" value="${endtime}" />
			</div>
			<input type="submit" value="Create" />
		</form>
	</body>
</html>

