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
FOREIGN KEY student REFERENCES student(email),
FOREIGN KEY club REFERENCES club(email)
);

CREATE TABLE event(
description TEXT,
name VARCHAR(32),
expectedSize INT,
ID INT,
PRIMARY KEY (ID),
);

CREATE TABLE runBy(
club VARCHAR(32),
event INT,
PRIMARY KEY(club,event),
FOREIGN KEY (club) REFERENCES club(email),
FOREIGN KEY (event) REFERENCES event(ID)
);

CREATE TABLE room(
occupancy INT,
roomNum INT,
building VARCHAR(3),
PRIMARY KEY(roomNum,building)
);

CREATE TABLE equipment(
name VARCHAR(32),
PRIMAY KEY(name)
);

CREATE TABLE isIn(
equipment VARCHAR(32),
roomNum INT,
building VARCHAR(3),
quantity INT,
PRIMARY KEY (equipment,roomNum,building),
FOREIGN KEY(equipment) REFERENCES equipment(name),
FOREIGN KEY (roomNum,building) REFERENCES room(roomNum,building)
);

CREATE TABLE uses(
event INT,
equipment VARCHAR(32),
quantity INT,
PRIMARY KEY(event,equipment),
FOREIGN KEY (event) REFERENCES event(ID),
FOREIGN KEY(equipment) REFERENCES equipment(name)
);

CREATE TABLE comments(
ID INT,
when DATETIME, 
txt TEXT,
madeBy VARCHAR(32) NOT NULL,
event INT NOT NULL,
parent INT,
FOREIGN KEY(madeBy) REFERENCES users(email),
FOREIGN KEY(event) REFERENCES event(ID),
PRIMARY KEY (ID),
FOREIGN KEY (parent) REFERENCES comments(ID)
);

CREATE TABLE reservation(
ID INT,
timeBooked DATETIME NOT NULL,
startTime DATETIME NOT NULL,
endTime DATETIME NOT NULL,
roomNum INT NOT NULL,
building INT NOT NULL,
student VARCHAR(32) NOT NULL,
admin VARCHAR(32),
event INT,
FOREIGN KEY(roomNum,building) REFERENCES room(roomNum,building),
FOREIGN KEY(student) REFERENCES student(email),
FOREIGN KEY(admin) REFERENCES admin(email),
FOREIGN KEY(event) REFERENCES event(ID),
PRIMARY KEY(ID)
);
