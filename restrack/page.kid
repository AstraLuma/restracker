<?xml version="1.0" encoding="utf-8" ?>
<!-- Handles basic page layout -->
<!-- See http://www.kid-templating.org/language.html -->
<?python
# We can get away with this because nothing's sent until after this is executed
request.header('Content-Type', 'text/html')

def htmltag(tag):
	return '{http://www.w3.org/1999/xhtml}'+tag

def tagcontents(elem):
	return [elem.text]+list(elem)
?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">
	<head py:match="item.tag == htmltag('head')">
		<meta py:replace="tagcontents(item)" />
	</head>
	<body py:match="item.tag == htmltag('body')">
		<div py:replace="tagcontents(item)" />
	</body>
</html>

