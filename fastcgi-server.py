#!/usr/bin/python
"""
FastCGI server using flup. Reloads on SIGHUP.
"""
import site, os
site.addsitedir(os.path.dirname(__file__))
import restrack.server
from flup.server.fcgi import WSGIServer
import os, sys, logging, site

lh = logging.StreamHandler(sys.stderr)
lh.setFormatter(logging.Formatter(restrack.server.FORMAT))
logging.root.addHandler(lh)
logging.root.setLevel(logging.DEBUG)

f = open('/tmp/restracker.pid', 'w')
f.write(str(os.getpid()))
f.close()

try:
	ws = WSGIServer(restrack.server.restracker_app, bindAddress='/tmp/restracker.sock')
	rerun = ws.run()
finally:
	os.unlink('/tmp/restracker.pid')

if rerun:
	os.spawnv(__file__, sys.argv)

