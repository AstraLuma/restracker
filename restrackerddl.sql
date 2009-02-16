COMMENT ON DATABASE restracker IS 'The tables for ResTracker.';

CREATE TABLE users(
email VARCHAR(32),
password VARCHAR(16) NOT NULL,
name VARCHAR(32),
PRIMARY KEY(email)
);
COMMENT ON TABLE users IS 'All non-anonymous users of the system.';
COMMENT ON COLUMN users.email IS 'The email address and login identifier of the user.';
COMMENT ON COLUMN users.password IS 'A hash of the password.';
COMMENT ON COLUMN users.name IS 'The display name of the user.';

CREATE TABLE admin(
email VARCHAR(32),
title VARCHAR(32),
super boolean,
PRIMARY KEY(email),
FOREIGN KEY(email) REFERENCES users(email)
);
COMMENT ON TABLE admin IS 'Users who approve, arbitrate, and manage.';
COMMENT ON COLUMN admin.email IS 'The reference back to the user table.';
COMMENT ON COLUMN admin.title IS 'The job title of the admin';
COMMENT ON COLUMN admin.super IS 'Can this admin manage the application?';

CREATE TABLE student(
email VARCHAR(32),
year INT, --INT(4)
major1 VARCHAR(32),
major2 VARCHAR(32),
PRIMARY KEY(email),
FOREIGN KEY (email) REFERENCES users(email)
);
COMMENT ON TABLE student IS 'Members of groups.';
COMMENT ON COLUMN student.email IS 'The reference back to the user table.';
COMMENT ON COLUMN student.year IS 'Their official class year.';
COMMENT ON COLUMN student.major1 IS 'One of student''s majors, if they have at least 1.';
COMMENT ON COLUMN student.major2 IS 'The other of the student''s majors, if they have 2.';

CREATE TABLE club(
email VARCHAR(32),
description TEXT,
class INT, --INT(1)
PRIMARY KEY (email),
FOREIGN KEY (email) REFERENCES users(email)
);
COMMENT ON TABLE club IS 'A student association, group, club, etc.';
COMMENT ON COLUMN club.email IS 'Reference bakc to the user table.';
COMMENT ON COLUMN club.description IS 'A short description of the group.';
COMMENT ON COLUMN club.class IS 'The SGA class (0-6). 0=Not really a group.';

CREATE TABLE memberOf(
student VARCHAR(32),
club VARCHAR(32),
PRIMARY KEY(student,club),
FOREIGN KEY (student) REFERENCES student(email),
FOREIGN KEY (club) REFERENCES club(email)
);
COMMENT ON TABLE memberof IS 'What groups each student is a member of.';
COMMENT ON COLUMN memberof.student IS 'The student in question.';
COMMENT ON COLUMN memberof.club IS 'The group the student is part of.';

CREATE TABLE event(
description TEXT,
name VARCHAR(32),
expectedSize INT,
ID SERIAL, -- Special PostgreSQL type
PRIMARY KEY (ID)
);
COMMENT ON TABLE event IS 'Some event a group is throwing. The date/time it is thrown is dependent on its reservations.';
COMMENT ON COLUMN event.description IS 'A long textual description of an event. Can be multiple paragraphs, etc.';
COMMENT ON COLUMN event.name IS 'The short display name of the event.';
COMMENT ON COLUMN event.expectedsize IS 'About how many people are expected to show for the event.';
COMMENT ON COLUMN event.id IS 'An arbitrary numeric identifier.';

CREATE TABLE runBy(
club VARCHAR(32),
eventran INTEGER, -- The actual type of SERIAL
PRIMARY KEY(club,eventran),
FOREIGN KEY (club) REFERENCES club(email),
FOREIGN KEY (eventran) REFERENCES event(ID)
);
COMMENT ON TABLE runby IS 'What groups run events.';
COMMENT ON COLUMN runby.club IS 'The group running the event.';
COMMENT ON COLUMN runby.eventran IS 'The event being run.';

CREATE TABLE room(
occupancy INT,
roomNum INT,
building VARCHAR(3),
PRIMARY KEY(roomNum,building)
);
COMMENT ON TABLE room IS 'A place that can be reserved. May have equipment intrinsic to it.';
COMMENT ON COLUMN room.occupancy IS 'About how many people the room can hold.';
COMMENT ON COLUMN room.roomnum IS 'The room number.';
COMMENT ON COLUMN room.building IS 'The abbrev. of the building the room is in. (eg, FL, CC, KH)';

CREATE TABLE equipment(
name VARCHAR(32),
PRIMARY KEY(name)
);
COMMENT ON TABLE equipment IS 'Something used by an event and intrinsic to a room. eg, projectors.';
COMMENT ON COLUMN equipment.name IS 'The name of the equipment';

CREATE TABLE isIn(
whatequip VARCHAR(32),
roomNum INT,
building VARCHAR(3),
quantity INT,
PRIMARY KEY (whatequip,roomNum,building),
FOREIGN KEY(whatequip) REFERENCES equipment(name),
FOREIGN KEY (roomNum,building) REFERENCES room(roomNum,building)
);
COMMENT ON TABLE isin IS 'Equipment that a room has intrinsic to it.';
COMMENT ON COLUMN isin.whatequip IS 'The equipment in reference.';
COMMENT ON COLUMN isin.roomnum IS 'The room number the equipment is in.';
COMMENT ON COLUMN isin.building IS 'The building the room is in.';
COMMENT ON COLUMN isin.quantity IS 'How many instances of the equipment is present.';

CREATE TABLE uses(
usedat INTEGER,
whatequip VARCHAR(32),
quantity INT,
PRIMARY KEY(usedat,whatequip),
FOREIGN KEY (usedat) REFERENCES event(ID),
FOREIGN KEY(whatequip) REFERENCES equipment(name)
);
COMMENT ON TABLE uses IS 'Equipment used by a particular event.';
COMMENT ON COLUMN uses.usedat IS 'The event that''s using equipment.';
COMMENT ON COLUMN uses.whatequip IS 'The equipment being used.';
COMMENT ON COLUMN uses.quantity IS 'How much equipment is being used.';

CREATE TABLE comments(
ID SERIAL,
madeat TIMESTAMP, 
txt TEXT,
madeBy VARCHAR(32) NOT NULL,
about INTEGER NOT NULL,
parent INTEGER,
FOREIGN KEY(madeBy) REFERENCES users(email),
FOREIGN KEY(about) REFERENCES event(ID),
PRIMARY KEY (ID),
FOREIGN KEY (parent) REFERENCES comments(ID)
);
COMMENT ON TABLE comments IS 'Comments made by users about events';
COMMENT ON COLUMN comments.ID IS 'An arbitrary numeric identifier.';
COMMENT ON COLUMN comments.madeat IS 'When it was made.';
COMMENT ON COLUMN comments.txt IS 'The content of the comment.';
COMMENT ON COLUMN comments.madeBy IS 'Who said it.';
COMMENT ON COLUMN comments.about IS 'The event the comment is about.';
COMMENT ON COLUMN comments.parent IS 'The parent comment, if this replies to it.';

CREATE TABLE reservation(
ID SERIAL,
timeBooked TIMESTAMP NOT NULL,
startTime TIMESTAMP NOT NULL,
endTime TIMESTAMP NOT NULL,
roomNum INT NOT NULL,
building VARCHAR(3) NOT NULL,
student VARCHAR(32) NOT NULL,
admin VARCHAR(32),
forevent INTEGER NOT NULL,
FOREIGN KEY(roomNum,building) REFERENCES room(roomNum,building),
FOREIGN KEY(student) REFERENCES student(email),
FOREIGN KEY(admin) REFERENCES admin(email),
FOREIGN KEY(forevent) REFERENCES event(ID),
PRIMARY KEY(ID)
);
COMMENT ON TABLE reservation IS 'A particular room & time for an event.

Note: reservation.student must be a member of one of the reservation.forevent.runby clubs.';
COMMENT ON COLUMN reservation.id IS 'An arbitrary numeric identifier.';
COMMENT ON COLUMN reservation.timebooked IS 'When the reservation was requested.';
COMMENT ON COLUMN reservation.starttime IS 'The start of when the room is needed.';
COMMENT ON COLUMN reservation.endtime IS 'The end of when the room is needed.';
COMMENT ON COLUMN reservation.roomnum IS 'The room which is requested.';
COMMENT ON COLUMN reservation.building IS 'The building the requested room is in.';
COMMENT ON COLUMN reservation.student IS 'The user who made the reservation.';
COMMENT ON COLUMN reservation.admin IS 'The administrator who approved the reservation, making it official. NULL if it is unapproved.';
COMMENT ON COLUMN reservation.forevent IS 'The event this reservation is for.';

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

