<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>Log In</title>
	</head>
	<body>
		<h1>Log In</h1>
		<div class="error" py:if="error" py:content="error" />
		<form action="/login" method="POST">
			<input py:if="defined('returnto')" name="returnto" type="hidden" value="${returnto}" />
			<table>
				<tr>
					<td><label for="user">User:</label> </td>
					<td><input name="user" type="text" value="${request.user}" /></td>
				</tr>
				<tr>
					<td><label>Password:</label> </td>
					<td><input name="password" type="password" /></td>
				</tr>
				<tr>
					<td colspan="2"><input type="submit" value="Log In" /></td>
				</tr>
			</table>
		</form>
	</body>
</html>

