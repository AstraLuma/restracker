<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Approve Reservation - ${event.name}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Approve Reservation - <a href="/event/${event.eid}">${event.name}</a>:<br/> 
			${reservation.format()}</h1>
		<div py:if="reservation.aemail">
			<div>This event has already been approved by 
				<a href="/user/${reservation.aemail}">${reservation.aemail}</a>
				</div>
		</div>
		<?python
		canapprove = True
		?>
		<div py:if="conflicts">
			<div class="warning">This reservation conflicts with these:</div>
			<ul>
				<li py:for="conf in conflicts">
					<a href="/event/${conf.eid}/reservation/${conf.rid}">${conf.format()}</a>
					<span py:if="conf.aemail" class="error"><?python canapprove=False ?>Approved</span>
				</li>
			</ul>
		</div>
		<div py:if="not reservation.aemail and canapprove">
			<div>Are you sure you want to approve this reservation?</div>
			<form action="/event/${event.eid}/reservation/${reservation.rid}/approve" method="POST">
				<div>
					<input type="submit" name="yes" value="Yes" />
					<input type="submit" name="no" value="No" />
				</div>
			</form>
		</div>
	</body>
</html>

