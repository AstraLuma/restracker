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
	if ws.run():
		# Close fd's
		for fd in xrange(3, 1024):
			try:
				os.close(fd)
			except OSError:
				pass
		os.execv(__file__, sys.argv)
finally:
	os.unlink('/tmp/restracker.pid')
