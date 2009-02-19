	SELECT * FROM room NATURAL JOIN isIn WHERE (roomNum='1946' AND 
		building='CC'); 

	SELECT * FROM isIn NATURAL JOIN room WHERE equipname='chairs'; 

	SELECT * FROM uses NATURAL JOIN event WHERE equipname='chairs'; 

	SELECT * FROM club WHERE cEmail='smas@wpi.edu';

	SELECT * FROM runBy NATURAL JOIN event WHERE cEmail='smas@wpi.edu';

	SELECT * FROM event WHERE EID=1;

	SELECT * FROM club NATURAL JOIN runBy WHERE EID=2;

	SELECT * FROM comments WHERE EID=1;

	SELECT * FROM uses WHERE EID=1;

	SELECT * 
	FROM reservation
	NATURAL JOIN 
		(SELECT count(r2.RID) AS conflicts, r1.RID
		FROM reservation AS r1, reservation AS r2
		WHERE (r1.startTime, r1.endTime) OVERLAPS (r2.startTime, r2.endTime) 
		AND r1.EID=11 AND r2.EID!=11 
		AND r1.roomNum=r2.roomNum AND r1.building=r2.building 
		GROUP BY r1.RID) AS conflicting;
 
	SELECT * 
	FROM users LEFT JOIN student ON email=sEmail LEFT JOIN admin ON
		email=aEmail 
	WHERE email='shl@wpi.edu'; 

	SELECT * FROM memberOf NATURAL JOIN club WHERE sEmail='jebliss@wpi.edu'; 

	SELECT event.* FROM reservation NATURAL JOIN event WHERE
sEmail='shl@wpi.edu';

	SELECT * FROM reservation NATURAL JOIN event WHERE RID=1;

	SELECT *
	FROM reservation 
	WHERE (TIMESTAMP '2009-01-01 10:00:00',TIMESTAMP '2009-02-03 3:00:00') OVERLAPS (startTime,
endTime) AND roomNum='1946' AND building='CC'
		AND RID!=1;


	SELECT * FROM reservation NATURAL JOIN event WHERE aEmail=NULL AND startTime >
		now() ORDER BY startTime; 

	SELECT * 
	FROM reservation AS r1, reservation AS r2
	WHERE (r1.startTime, r1.endTime) OVERLAPS (r2.startTime, r2.endTime)
		AND r1.RID < r2.RID
		AND  r1.roomNum=r2.roomNum AND r1.building=r2.building
		ORDER BY r1.startTime; 

	SELECT room.* FROM room 
	WHERE NOT EXISTS 
		(SELECT * 
		FROM reservation AS r 
		WHERE r.roomnum = '208' AND r.building = 'CC' AND (TIMESTAMP '2009-04-07
6:00:00', TIMESTAMP '2009-04-07 24:00:00')
			OVERLAPS (r.startTime, r.endTime)); 

BEGIN;
CREATE TEMPORARY TABLE "search" (equipname VARCHAR(32)) ON COMMIT DROP;
	INSERT INTO "search" VALUES ('chairs');
	SELECT * 
	FROM room 
	WHERE NOT EXIST 
		((SELECT * FROM search) EXCEPT 
			(SELECT equipname 
			FROM isIN 
			WHERE roomNum='1946' and building='CC'));
COMMIT;

	SELECT room.* 
	FROM room 
	WHERE 5 <= occupancy AND occupancy <= 50; 

	SELECT count(*),building,roomNum 
	FROM room NATURAL JOIN reservation 
	GROUP BY building,roomNum;

	SELECT count(*),sEmail FROM reservation NATURAL JOIN student 
	GROUP BY sEmail;

	SELECT count1+count2 AS count 
	FROM 
		(SELECT count(*) AS count1, major1 AS major 
		FROM reservation NATURAL JOIN student GROUP BY major1) AS
someone
	NATURAL JOIN
		(SELECT count(*) AS count2, major2 AS major 
		FROM reservation NATURAL JOIN student GROUP BY major2) AS
something;


SELECT DISTINCT equipName FROM uses UNION SELECT DISTINCT equipName FROM isIn;
