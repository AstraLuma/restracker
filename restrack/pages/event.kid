<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Event Info - ${event.name}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<!--pre py:content="repr(user)" /-->
		<h1>${event.name}</h1>
		<p>${event.description}</p>
		<div class="infobit" py:if="event.expectedsize"><span>Expected Size:</span> ${event.expectedsize}</div>
		
		<div py:if="request.inclub(c.email for c in clubs) or request.issuper()">
			<a href="/event/${event.eid}/edit">Edit</a>
		</div>
		
		<h2>Running Clubs</h2>
		<ul>
			<li py:for="club in clubs"><a href="/user/${club.email}">${club.name}</a></li>
		</ul>
		
		<div py:if="equipment">
			<h2>Equipment</h2>
			<ul>
				<li py:for="e in equipment">${e}</li>
			</ul>
		</div>
		
		<h2>Comments</h2>
		<div py:for="comment in comments" class="comment" id="comment${comment.cid}" style="margin: 1em">
			<div>On ${comment.madeat}, <a
href="/user/${comment.email}">${comment.name}</a> 
				said<span py:if="comment.parent"> in reply to <a href="#comment${comment.parent}">comment #${comment.parent}</a></span>:</div>
			<pre style="margin-left: 1em">${comment.txt}</pre>
			<div py:if="request.user"><a href="/event/${event.eid}/comment?replyto=${comment.cid}">Reply</a></div>
		</div>
		
		<div py:if="request.user"><a href="/event/${event.eid}/comment">Make Comment</a></div>
	</body>
</html>

