# -*- tab-width: 4; use-tabs: 1; coding: utf-8 -*-
# vim:tabstop=4:noexpandtab:
"""
Statistics
"""
from restrack.web import page, template, HTTPError
from restrack.utils import struct, result2obj, first, itercursor


@page('/stats')
def index(req):
	#FIXME: Join against room so we can use Room
	roomscur = req.execute("""SELECT COUNT(*) AS c, building, roomnum
	FROM room NATURAL JOIN reservation 
	GROUP BY building, roomnum 
	ORDER BY COUNT(*) DESC 
	LIMIT 10;""")
	usedrooms = result2obj(roomscur,struct)
	
	
	# FIXME: Join against users so we can use User
	studentcur =req.execute("""SELECT COUNT(*) AS c, semail 
	FROM reservation NATURAL JOIN student
	GROUP BY semail 
	ORDER BY COUNT(*) DESC 
	LIMIT 10;""")
	studentsevents = result2obj(studentcur,struct)

	majorcur=req.execute("""
SELECT major, COUNT(rid) AS count
	FROM 
		(
			(SELECT rid, major1 AS major FROM reservation NATURAL JOIN student)
		UNION
			(SELECT rid, major2 AS major FROM reservation NATURAL JOIN student 
				WHERE major2 IS NOT NULL)
		) AS counts
	GROUP BY major
	ORDER BY count DESC 
	LIMIT 10;""")
	majorevents = result2obj(majorcur,struct)

	return template(req, 'stats', 
		usedrooms=usedrooms, studentsevents=studentsevents, 
		majorevents=majorevents)


