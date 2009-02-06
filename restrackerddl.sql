CREATE TABLE users(
email VARCHAR(32),
password VARCHAR(16) NOT NULL,
name VARCHAR(32),
PRIMARY KEY(email)
);

CREATE TABLE admin(
email VARCHAR(32),
title VARCHAR(32),
privledges VARCHAR(32),--what should this be
PRIMARY KEY(email),
FOREIGN KEY(email) REFERENCES users(email)
);

CREATE TABLE student(
email VARCHAR(32),
year INT, --INT(4)
major1 VARCHAR(32),
major2 VARCHAR(32),
PRIMARY KEY(email),
FOREIGN KEY (email) REFERENCES users(email)

);

CREATE TABLE club(
email VARCHAR(32),
description TEXT,
class INT, --INT(1)
PRIMARY KEY (email),
FOREIGN KEY (email) REFERENCES users(email)
);

CREATE TABLE memberOf(
student VARCHAR(32),
club VARCHAR(32),
PRIMARY KEY(student,club),
FOREIGN KEY (student) REFERENCES student(email),
FOREIGN KEY (club) REFERENCES club(email)
);

CREATE TABLE event(
description TEXT,
name VARCHAR(32),
expectedSize INT,
ID SERIAL, -- Special PostgreSQL type
PRIMARY KEY (ID)
);

CREATE TABLE runBy(
club VARCHAR(32),
eventran INTEGER, -- The actual type of SERIAL
PRIMARY KEY(club,eventran),
FOREIGN KEY (club) REFERENCES club(email),
FOREIGN KEY (eventran) REFERENCES event(ID)
);

CREATE TABLE room(
occupancy INT,
roomNum INT,
building VARCHAR(3),
PRIMARY KEY(roomNum,building)
);

CREATE TABLE equipment(
name VARCHAR(32),
PRIMARY KEY(name)
);

CREATE TABLE isIn(
whatequip VARCHAR(32),
roomNum INT,
building VARCHAR(3),
quantity INT,
PRIMARY KEY (whatequip,roomNum,building),
FOREIGN KEY(whatequip) REFERENCES equipment(name),
FOREIGN KEY (roomNum,building) REFERENCES room(roomNum,building)
);

CREATE TABLE uses(
usedat INTEGER,
whatequip VARCHAR(32),
quantity INT,
PRIMARY KEY(usedat,whatequip),
FOREIGN KEY (usedat) REFERENCES event(ID),
FOREIGN KEY(whatequip) REFERENCES equipment(name)
);

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

-- This doesn't appear in our ER model.
CREATE TABLE sessions (
	id CHAR(16) PRIMARY KEY,
	data BYTEA DEFAULT E''::bytea, -- PostgreSQL's BLOB, A Python Pickle of the session dict
	expires TIMESTAMP -- When to delete this record, same value as the cookie
);
