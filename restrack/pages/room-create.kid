<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Create Room</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Create Room</h1>
		<form action="/room/create" method="POST">
			<div class="infobit"><span>Building:</span>
				<input type="text" name="building" maxlength="3" />
			</div>
			<div class="infobit"><span>Room Number:</span>
				<input type="text" name="roomnum" maxlength="5" />
			</div>
			<div class="infobit"><span>Display Name:</span>
				<input type="text" name="display" maxlength="32" />
			</div>
			<div class="infobit"><span>Occupancy:</span>
				<input type="text" name="occupancy" />
			</div>
			<input type="submit" value="Create" />
		</form>
	</body>
</html>

