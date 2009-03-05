<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Create Event</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Create Event</h1>
		<form action="/event/create" method="POST">
			<fieldset>
				<legend>Basic Info</legend>
				<div class="infobit">
					<label for="name">Name:</label> 
					<input type="text" name="name" />
				</div>
				<div class="infobit">
					<label for="description">Description:</label> <br />
					<textarea name="description" rows="5" cols="80" />
				</div>
				<div class="infobit">
					<label for="expectedsize">Expected Size:</label> 
					<input type="text" name="expectedsize" />
				</div>
			</fieldset>
			
			<fieldset py:if="not request.isclub()">
				<legend>Running Club</legend>
				<div py:for="club in clubs"><!-- for supers, this should be all clubs -->
					<input type="checkbox" name="cemail" value="${club.email}" />
					<label>${club.name}</label> (<a href="/user/${club.email}">info</a>)
				</div>
			</fieldset>
			
			<fieldset>
				<legend>Equipment</legend>
				<div>(Separate equipment by whitespace.)</div>
				<textarea name="equipment" rows="5" cols="40" />
			</fieldset>
			<input type="submit" value="Create" />
		</form>
	</body>
</html>

