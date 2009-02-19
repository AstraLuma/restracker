COMMENT ON DATABASE restracker IS 'The tables for ResTracker.';

CREATE TABLE users(
email VARCHAR(32),
password CHAR(32) NOT NULL,
name VARCHAR(64),
PRIMARY KEY(email)
);
ALTER TABLE users OWNER TO restracker;
COMMENT ON TABLE users IS 'All non-anonymous users of the system.';
COMMENT ON COLUMN users.email IS 'The email address and login identifier of the user.';
COMMENT ON COLUMN users.password IS 'An MD5 hash of the password.';
COMMENT ON COLUMN users.name IS 'The display name of the user.';

CREATE TABLE admin(
aEmail VARCHAR(32),
title VARCHAR(32),
super boolean,
PRIMARY KEY(aEmail),
FOREIGN KEY(aEmail) REFERENCES users(email) ON UPDATE CASCADE
);
ALTER TABLE admin OWNER TO restracker;
COMMENT ON TABLE admin IS 'Users who approve, arbitrate, and manage.';
COMMENT ON COLUMN admin.aEmail IS 'The reference back to the user table.';
COMMENT ON COLUMN admin.title IS 'The job title of the admin';
COMMENT ON COLUMN admin.super IS 'Can this admin manage the application?';

CREATE TABLE student(
sEmail VARCHAR(32),
year INT, --INT(4)
major1 VARCHAR(32),
major2 VARCHAR(32),
PRIMARY KEY(sEmail),
FOREIGN KEY (sEmail) REFERENCES users(email) ON UPDATE CASCADE
);
ALTER TABLE student OWNER TO restracker;
COMMENT ON TABLE student IS 'Members of groups.';
COMMENT ON COLUMN student.sEmail IS 'The reference back to the user table.';
COMMENT ON COLUMN student.year IS 'Their official class year.';
COMMENT ON COLUMN student.major1 IS 'One of student''s majors, if they have at least 1.';
COMMENT ON COLUMN student.major2 IS 'The other of the student''s majors, if they have 2.';

CREATE TABLE club(
cEmail VARCHAR(32),
description TEXT,
class INT, --INT(1)
PRIMARY KEY (cEmail),
FOREIGN KEY (cEmail) REFERENCES users(email) ON UPDATE CASCADE
);
ALTER TABLE club OWNER TO restracker;
COMMENT ON TABLE club IS 'A student association, group, club, etc.';
COMMENT ON COLUMN club.cEmail IS 'Reference bakc to the user table.';
COMMENT ON COLUMN club.description IS 'A short description of the group.';
COMMENT ON COLUMN club.class IS 'The SGA class (0-6). 0=Not really a group.';

CREATE TABLE memberOf(
sEmail VARCHAR(32),
cEmail VARCHAR(32),
PRIMARY KEY(sEmail,cEmail),
FOREIGN KEY (sEmail) REFERENCES student(sEmail) ON UPDATE CASCADE,
FOREIGN KEY (cEmail) REFERENCES club(cEmail) ON UPDATE CASCADE
);
ALTER TABLE memberOf OWNER TO restracker;
COMMENT ON TABLE memberOf IS 'What groups each student is a member of.';
COMMENT ON COLUMN memberOf.sEmail IS 'The student in question.';
COMMENT ON COLUMN memberOf.cEmail IS 'The group the student is part of.';

CREATE TABLE event(
description TEXT,
name VARCHAR(32),
expectedSize INT,
EID SERIAL, -- Special PostgreSQL type
PRIMARY KEY (EID)
);
ALTER TABLE event OWNER TO restracker;
COMMENT ON TABLE event IS 'Some event a group is throwing. The date/time it is thrown is dependent on its reservations.';
COMMENT ON COLUMN event.description IS 'A long textual description of an event. Can be multiple paragraphs, etc.';
COMMENT ON COLUMN event.name IS 'The short display name of the event.';
COMMENT ON COLUMN event.expectedsize IS 'About how many people are expected to show for the event.';
COMMENT ON COLUMN event.eid IS 'An arbitrary numeric identifier.';

CREATE TABLE runBy(
cEmail VARCHAR(32),
EID INTEGER, -- The actual type of SERIAL
PRIMARY KEY(cEmail,EID),
FOREIGN KEY (cEmail) REFERENCES club(cEmail) ON UPDATE CASCADE,
FOREIGN KEY (EID) REFERENCES event(EID)
);
ALTER TABLE runBy OWNER TO restracker;
COMMENT ON TABLE runBy IS 'What groups run events.';
COMMENT ON COLUMN runBy.cEmail IS 'The group running the event.';
COMMENT ON COLUMN runBy.EID IS 'The event being run.';

CREATE TABLE room(
occupancy INT,
roomNum VARCHAR(5),
building VARCHAR(3),
displayname VARCHAR(32),
PRIMARY KEY(roomNum,building)
);
ALTER TABLE room OWNER TO restracker;
COMMENT ON TABLE room IS 'A place that can be reserved. May have equipment intrinsic to it.';
COMMENT ON COLUMN room.occupancy IS 'About how many people the room can hold.';
COMMENT ON COLUMN room.roomnum IS 'The room number.';
COMMENT ON COLUMN room.building IS 'The abbrev. of the building the room is in. (eg, FL, CC, KH)';
COMMENT ON COLUMN room.displayname IS 'The well-known name of the room. eg The Morgan Room instead of CC 208.';

CREATE TABLE isIn(
equipname VARCHAR(32),
roomNum VARCHAR(5),
building VARCHAR(3),
quantity INT,
PRIMARY KEY (equipname,roomNum,building),
FOREIGN KEY (roomNum,building) REFERENCES room(roomNum,building)
);
ALTER TABLE isIn OWNER TO restracker;
COMMENT ON TABLE isIn IS 'Equipment that a room has intrinsic to it.';
COMMENT ON COLUMN isIn.equipname IS 'The equipment in reference.';
COMMENT ON COLUMN isIn.roomnum IS 'The room number the equipment is in.';
COMMENT ON COLUMN isIn.building IS 'The building the room is in.';
COMMENT ON COLUMN isIn.quantity IS 'How many instances of the equipment is present.';

CREATE TABLE uses(
EID INTEGER,
equipname VARCHAR(32),
quantity INT,
PRIMARY KEY(EID,equipname),
FOREIGN KEY (EID) REFERENCES event(EID),
);
ALTER TABLE uses OWNER TO restracker;
COMMENT ON TABLE uses IS 'Equipment used by a particular event.';
COMMENT ON COLUMN uses.EID IS 'The event that''s using equipment.';
COMMENT ON COLUMN uses.equipname IS 'The equipment being used.';
COMMENT ON COLUMN uses.quantity IS 'How much equipment is being used.';

CREATE TABLE comments(
CID SERIAL,
madeat TIMESTAMP, 
txt TEXT,
email VARCHAR(32) NOT NULL,
EID INTEGER NOT NULL,
parent INTEGER,
FOREIGN KEY(email) REFERENCES users(email) ON UPDATE CASCADE,
FOREIGN KEY(EID) REFERENCES event(EID),
PRIMARY KEY (CID),
FOREIGN KEY (parent) REFERENCES comments(CID)
);
ALTER TABLE comments OWNER TO restracker;
COMMENT ON TABLE comments IS 'Comments made by users about events';
COMMENT ON COLUMN comments.CID IS 'An arbitrary numeric identifier.';
COMMENT ON COLUMN comments.madeat IS 'When it was made.';
COMMENT ON COLUMN comments.txt IS 'The content of the comment.';
COMMENT ON COLUMN comments.email IS 'Who said it.';
COMMENT ON COLUMN comments.EID IS 'The event the comment is about.';
COMMENT ON COLUMN comments.parent IS 'The parent comment, if this replies to it.';

CREATE TABLE reservation(
RID SERIAL,
timeBooked TIMESTAMP NOT NULL,
startTime TIMESTAMP NOT NULL,
endTime TIMESTAMP NOT NULL,
roomNum VARCHAR(5) NOT NULL,
building VARCHAR(3) NOT NULL,
sEmail VARCHAR(32) NOT NULL,
aEmail VARCHAR(32),
EID INTEGER NOT NULL,
FOREIGN KEY(roomNum,building) REFERENCES room(roomNum,building),
FOREIGN KEY(sEmail) REFERENCES student(sEmail) ON UPDATE CASCADE,
FOREIGN KEY(aEmail) REFERENCES admin(aEmail) ON UPDATE CASCADE,
FOREIGN KEY(EID) REFERENCES event(EID),
PRIMARY KEY(RID)
);
ALTER TABLE reservation OWNER TO restracker;
COMMENT ON TABLE reservation IS 'A particular room & time for an event.

Note: reservation.student must be a member of one of the reservation.forevent.runby clubs.';
COMMENT ON COLUMN reservation.rid IS 'An arbitrary numeric identifier.';
COMMENT ON COLUMN reservation.timebooked IS 'When the reservation was requested.';
COMMENT ON COLUMN reservation.starttime IS 'The start of when the room is needed.';
COMMENT ON COLUMN reservation.endtime IS 'The end of when the room is needed.';
COMMENT ON COLUMN reservation.roomNum IS 'The room which is requested.';
COMMENT ON COLUMN reservation.building IS 'The building the requested room is in.';
COMMENT ON COLUMN reservation.semail IS 'The user who made the reservation.';
COMMENT ON COLUMN reservation.aemail IS 'The administrator who approved the reservation, making it official. NULL if it is unapproved.';
COMMENT ON COLUMN reservation.eid IS 'The event this reservation is for.';

-- This doesn't appear in our ER model.
CREATE TABLE sessions (
	id CHAR(16) PRIMARY KEY,
	data BYTEA DEFAULT E''::bytea, -- PostgreSQL's BLOB, A Python Pickle of the session dict
	expires TIMESTAMP -- When to delete this record, same value as the cookie
);
COMMENT ON TABLE sessions IS 'Handles web sessions.';
COMMENT ON COLUMN sessions.id IS 'The gibberish identifier.';
COMMENT ON COLUMN sessions.data IS 'The Pickle''d python dict of the session.';
COMMENT ON COLUMN sessions.expires IS 'When the cookie for the session expires.';

