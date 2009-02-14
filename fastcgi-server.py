#!/usr/bin/python
"""
FastCGI server using flup. Reloads on SIGHUP.
"""
import restrack.server
from flup.server.fcgi import WSGIServer
import os, sys, logging, site

site.addsitedir(os.path.dirname(__file__))

lh = logging.StreamHandler(sys.stderr)
lh.setFormatter(logging.Formatter(restrack.server.FORMAT))
logging.root.addHandler(lh)
logging.root.setLevel(logging.DEBUG)

f = open('/tmp/restracker.pid', 'w')
f.write(os.getpid())
f.close()

try:
	ws = WSGIServer(restrack.server.restracker_app, bindAddress='/tmp/restracker.sock')
	if ws.run():
		os.execv(__file__, sys.argv)
finally:
	os.unlink('/tmp/restracker.pid')
