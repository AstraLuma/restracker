<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Comment on ${event.name}</title>
	</head>
	<body>
		<div py:replace="up()" />
		<h1>Comment on ${event.name}</h1>
		
		<div py:if="parent">
			<h2>In Reply To:</h2>
			<div class="comment" style="margin: 1em">
				<div>
On ${parent.madeat}, <a href="/user/${parent.email}">${parent.name}</a> 
said<span py:if="parent.parent"> in reply to 
<a href="/event/${event.eid}#comment${parent.parent}">comment 
#${parent.parent}</a></span>:
				</div>
				<pre style="margin-left: 1em">${parent.txt}</pre>
			</div>
		</div>
		
		<form action="/event/${event.eid}/comment" method="POST">
			<input py:if="parent" type="hidden" name="replyto" value="${parent.cid}"/>
			<div>
				<textarea name="txt" rows="10" cols="60">${quoted}</textarea>
			</div>
			<div>
				<input type="submit" value="Comment" />
			</div>
		</form>
	</body>
</html>

