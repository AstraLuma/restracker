<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
from restrack.pages.rooms import Room
?>
	<head>
		<title>Reservation - ${event.name} - ${reservation.format()}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Reservation - <a href="/event/${event.eid}">${event.name}</a>:<br/> 
			${reservation.format()}</h1>
		
		<a py:if="request.user == reservation.semail or request.issuper()" href="/event/${reservation.eid}/reservation/${reservation.rid}/edit">Edit</a>
		
		<div class="infobit"><span>Where:</span> ${Room(**reservation.__dict__).display}</div>
		<div class="infobit"><span>Start:</span> ${reservation.start()}</div>
		<div class="infobit"><span>End:</span> ${reservation.end()}</div>
		<div class="infobit"><span>When Booked:</span> ${reservation.timebooked}</div>
		<div class="infobit"><span>Who Booked:</span> 
			<a href="/user/${reservation.semail}">${reservation.semail}</a>
		</div>
		<div class="infobit"><span>Approver:</span> 
			<a py:if="reservation.aemail" href="/user/${reservation.aemail}">${reservation.aemail}</a>
			<span py:if="not reservation.aemail">Not Approved</span>
		</div>
		
		<div py:if="conflicts">
			<h2>Conflicts</h2>
			<ul>
				<li py:for="conf in conflicts">
					<a href="/event/${conf.eid}/reservation/${conf.rid}">${conf.format()}</a>
					<span py:if="conf.aemail">Approved</span>
				</li>
			</ul>
		</div>
		
		<a py:if="not conflicts and request.isadmin()" href="/event/${reservation.eid}/reservation/${reservation.rid}/approve">Approve</a>
	</body>
</html>

