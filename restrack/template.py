import kid
# See http://www.kid-templating.org/guide.html

def template(req, name, **kwargs):
	"""template(request, string, [name=object, ...]) -> string
	Loads the template given in name, parses it, and substitutes the given 
	values, returning the string.
	"""
	# kid.Template() looks for either name, file, or source to load the template from
	# Can't really have those floating around
	extrakw = {}
	if 'file' in kwargs:
		extrakw['file'] = kwargs
		del kwargs['file']
	if 'source' in kwargs:
		extrakw['source'] = kwargs
		del kwargs['source']
	tmpl = kid.Template(name=name, request=req, **kwargs)
	for k,v in extrakw.iteritems():
		setattr(tmpl, k, v)
	return tmpl.serialize(encoding='utf-8', output=kid.XHTMLSerializer(doctype='xhtml-strict'))
