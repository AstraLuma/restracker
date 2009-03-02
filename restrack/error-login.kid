<?xml version="1.0" encoding="utf-8" ?>
<!-- See http://www.kid-templating.org/language.html -->
<?python
import traceback
?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
<?python
request.header('Content-Type', 'text/html')
?>
	<head>
		<title>${title}</title>
	</head>
	<body>
		<h1>${title}</h1>
		<p class="error">${msg}</p>
		<form action="/login" method="POST">
			<input name="returnto" type="hidden" value="${request.returnurl()}" />
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

