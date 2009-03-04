<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Edit Event - ${event.name}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Edit Event - ${event.name}</h1>
		
		<fieldset>
			<legend>Basic Info</legend>
			<form action="/event/${event.eid}/edit" method="POST">
				<div class="infobit">
					<label for="name">Name:</label> 
					<input type="text" name="name" value="${event.name}" />
				</div>
				<div class="infobit">
					<label for="description">Description:</label> <br/>
					<textarea name="description" rows="5" cols="80">${event.description}</textarea>
				</div>
				<div class="infobit">
					<label for="expectedsize">Expected Size:</label> 
					<input type="text" name="expectedsize" value="${event.expectedsize}" />
				</div>
				<input type="submit" name="basicinfo" value="Save Changes" />
			</form>
		</fieldset>
		
		<fieldset>
			<legend>Clubs</legend>
			<ul>
				<li py:for="club in clubs">
					<a href="/user/${club.email}">${club.name}</a>
					<form py:if="request.inclub([club.email]) or request.issuper()" action="/event/${event.eid}/edit" method="POST">
						<input type="hidden" name="cemail" value="${club.cemail}" />
						<input type="submit" name="club-delete" value="Delete" />
					</form>
				</li>
				<li py:if="request.isstudent()">
					<form action="/event/${event.eid}/edit" method="POST">
						<label for="cemail">Club Name:</label>
						<select name="cemail">
							<option py:for="club in userclubs" value="${club.cemail}">${club.name}</option>
						</select>
						<input type="submit" name="club-add" value="Add" />
					</form>
				</li>
				<li py:if="request.isclub() or request.issuper()">
					<form action="/event/${event.eid}/edit" method="POST">
						<label for="cemail">Club Email:</label>
						<input type="text" name="cemail" value="" />
						<input type="submit" name="club-add" value="Add" />
					</form>
				</li>
			</ul>
		</fieldset>
		
		<fieldset>
			<legend>Equipment</legend>
			<ul>
				<li py:for="equip in equipment">${equip}
					<form action="/event/${event.eid}/edit" method="POST">
						<input type="hidden" name="equipname" value="${equip}" />
						<input type="submit" name="equip-delete" value="Delete" />
					</form>
				</li>
				<li>
					<form action="/event/${event.eid}/edit" method="POST">
						<label for="equipname">Equipment:</label>
						<input type="text" name="equipname" value="" />
						<input type="submit" name="equip-add" value="Add" />
					</form>
				</li>
			</ul>
		</fieldset>
	</body>
</html>

