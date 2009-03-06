<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Edit Room - ${room.display}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Edit Room - ${room.display}</h1>
		<form action="/room/${room.building}/${room.roomnum}/edit" method="POST">
			<div class="infobit"><span>Display Name:</span>
				<input type="text" name="displayname" maxlength="32" value="${room.displayname}" />
			</div>
			<div class="infobit"><span>Occupancy:</span>
				<input type="text" name="occupancy" value="${room.occupancy}" />
			</div>
			<input type="submit" name="edit" value="Edit" />
		</form>
		
		<fieldset>
			<legend>Equipment</legend>
			<ul>
				<li py:for="equip in equipment">
					${equip}
					<form action="/room/${room.building}/${room.roomnum}/edit" method="POST">
						<input type="hidden" name="equipment" value="${equip}" />
						<input type="submit" name="equip-delete" value="Remove" />
					</form>
				</li>
			</ul>
		</fieldset>
	</body>
</html>

