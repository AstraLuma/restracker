<?xml version="1.0" encoding="utf-8" ?>
<!-- Copy this to create a new page -->
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Reservations - ${event.name}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Reservations - <a href="/event/${event.eid}">${event.name}</a></h1>
		<ul>
			<li py:for="resv in reservations">
				<a href="/event/${event.eid}/reservation/${resv.rid}">
					${resv.format()}</a>
				<span py:if="resv.aemail">Approved</span>
				<span py:if="resv.conflicts">Conflict!</span>
				<span py:if="not resv.conflicts and not resv.aemail and request.isadmin()">
					<a href="/event/${event.eid}/reservation/${resv.rid}/approve">Approve</a>
				</span>
			</li>
		</ul>
		<div py:if="request.issuper()">
			<a href="/event/${event.eid}/reservation/create">Add New</a>
		</div>
	</body>
</html>

