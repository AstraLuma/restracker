<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Room Info - ${room.display}</title>
	</head>
	<body>
		<!--pre py:content="repr(user)" /-->
		<h1>${room.display}</h1>
		<div class="infobit"><span>Room:</span> ${room.display}</div>
			<legend>Room Information</legend>
			<div class="infobit"
py:if="room.building"><span>Building</span> ${room.building}</div>
			<div class="infobit" 
py:if="room:roomnum"><span>Room Number:</span> ${room.roomnum}</div>
			<div class="infobit" 
py:if="room:displayname"><span>Room Name:</span> ${room.displayname}</div>
			<div class="infobit"
py:if="room.occupancy"><span>Occupancy:</span> ${room.occupancy}</div>


	</body>
</html>

