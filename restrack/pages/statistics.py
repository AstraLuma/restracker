# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Statistics
"""
from restrack.web import page, template, HTTPError
from restrack.utils import struct, result2obj, first, itercursor


@page('/stats')
def index(req):
	roomscur = req.execute("""select count(*) as c,building,roomnum
        from room natural join reservation 
        group by building,roomnum order by count(*) desc limit 10;""")
#	usedrooms = [r[0] for r in itercursor(cur)]
	usedrooms = result2obj(roomscur,struct)

		
	studentcur =req.execute("""SELECT count(*) as c,sEmail FROM reservation NATURAL JOIN
student
        GROUP BY sEmail ORDER BY count(*) DESC LIMIT 10;""")
#	studentsevents = [r[0] for r in itercursor(cur)]
	studentsevents = result2obj(studentcur,struct)

	majorcur=req.execute("""SELECT major, count1+count2 AS count
        FROM 
                (SELECT count(*) AS count1, major1 AS major
                FROM reservation NATURAL JOIN student GROUP BY major1) AS
someone             
        NATURAL JOIN
                (SELECT count(*) AS count2, major2 AS major
                FROM reservation NATURAL JOIN student GROUP BY major2) AS
something           
ORDER BY count DESC LIMIT 10;""")
#	majorevents = [r[0] for r in itercursor(cur)]
	majorevents = result2obj(majorcur,struct)

	return template(req, 'stats',
usedrooms=usedrooms,studentsevents=studentsevents,majorevents=majorevents)


