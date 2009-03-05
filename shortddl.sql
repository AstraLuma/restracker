
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

COMMENT ON DATABASE restracker IS 'The tables for ResTracker.';

CREATE PROCEDURAL LANGUAGE plpgsql;

SET search_path = public, pg_catalog;

CREATE FUNCTION reserv_overlaps() RETURNS trigger
    AS $$DECLARE
	confs integer;
BEGIN
	IF NEW.aemail IS NULL THEN
		RETURN NEW;
	END IF;
	SELECT COUNT(rid) INTO confs FROM reservation WHERE rid<>NEW.rid AND (NEW.starttime, NEW.endtime) OVERLAPS (starttime, endtime) AND aemail IS NOT NULL;
	IF confs > 0 THEN
		RAISE EXCEPTION 'This reservation is approved and conflicts with another approved reservation';
	END IF;
	RETURN NEW;
END;$$
    LANGUAGE plpgsql;

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE admin (
    aemail character varying(32) NOT NULL,
    title character varying(32),
    super boolean
);

COMMENT ON TABLE admin IS 'Users who approve, arbitrate, and manage.';

COMMENT ON COLUMN admin.aemail IS 'The reference back to the user table.';

COMMENT ON COLUMN admin.title IS 'The job title of the admin';

COMMENT ON COLUMN admin.super IS 'Can this admin manage the application?';

CREATE TABLE users (
    email character varying(32) NOT NULL,
    password character(32) NOT NULL,
    name character varying(64),
    CONSTRAINT users_email_check CHECK (("position"((email)::text, '/'::text) = 0))
);

COMMENT ON TABLE users IS 'All non-anonymous users of the system.';

COMMENT ON COLUMN users.email IS 'The email address and login identifier of the user.';

COMMENT ON COLUMN users.password IS 'An MD5 hash of the password.';

COMMENT ON COLUMN users.name IS 'The display name of the user.';

CREATE VIEW adminusers AS
    SELECT admin.aemail, admin.title, admin.super, users.email, users.password, users.name FROM (admin JOIN users ON (((admin.aemail)::text = (users.email)::text)));

CREATE TABLE club (
    cemail character varying(32) NOT NULL,
    description text,
    class integer
);

COMMENT ON TABLE club IS 'A student association, group, club, etc.';

COMMENT ON COLUMN club.cemail IS 'Reference bakc to the user table.';

COMMENT ON COLUMN club.description IS 'A short description of the group.';

COMMENT ON COLUMN club.class IS 'The SGA class (0-6). 0=Not really a group.';

CREATE VIEW clubusers AS
    SELECT club.cemail, club.description, club.class, users.email, users.password, users.name FROM (club JOIN users ON (((club.cemail)::text = (users.email)::text)));

CREATE TABLE comments (
    cid integer NOT NULL,
    madeat timestamp without time zone,
    txt text,
    email character varying(32) NOT NULL,
    eid integer NOT NULL,
    parent integer
);

COMMENT ON TABLE comments IS 'Comments made by users about events';

COMMENT ON COLUMN comments.cid IS 'An arbitrary numeric identifier.';

COMMENT ON COLUMN comments.madeat IS 'When it was made.';

COMMENT ON COLUMN comments.txt IS 'The content of the comment.';

COMMENT ON COLUMN comments.email IS 'Who said it.';

COMMENT ON COLUMN comments.eid IS 'The event the comment is about.';

COMMENT ON COLUMN comments.parent IS 'The parent comment, if this replies to it.';

CREATE SEQUENCE comments_cid_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

ALTER SEQUENCE comments_cid_seq OWNED BY comments.cid;

CREATE TABLE event (
    description text,
    name character varying(32),
    expectedsize integer,
    eid integer NOT NULL
);

COMMENT ON TABLE event IS 'Some event a group is throwing. The date/time it is thrown is dependent on its reservations.';

COMMENT ON COLUMN event.description IS 'A long textual description of an event. Can be multiple paragraphs, etc.';

COMMENT ON COLUMN event.name IS 'The short display name of the event.';

COMMENT ON COLUMN event.expectedsize IS 'About how many people are expected to show for the event.';

COMMENT ON COLUMN event.eid IS 'An arbitrary numeric identifier.';

CREATE SEQUENCE event_eid_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

ALTER SEQUENCE event_eid_seq OWNED BY event.eid;

CREATE TABLE isin (
    equipname character varying(32) NOT NULL,
    roomnum character varying(5) NOT NULL,
    building character varying(3) NOT NULL,
    quantity integer,
    CONSTRAINT isin_equipname_check CHECK (("position"((equipname)::text, '/'::text) = 0))
);

COMMENT ON TABLE isin IS 'Equipment that a room has intrinsic to it.';

COMMENT ON COLUMN isin.equipname IS 'The equipment in reference.';

COMMENT ON COLUMN isin.roomnum IS 'The room number the equipment is in.';

COMMENT ON COLUMN isin.building IS 'The building the room is in.';

COMMENT ON COLUMN isin.quantity IS 'How many instances of the equipment is present.';

CREATE TABLE memberof (
    semail character varying(32) NOT NULL,
    cemail character varying(32) NOT NULL
);

COMMENT ON TABLE memberof IS 'What groups each student is a member of.';

COMMENT ON COLUMN memberof.semail IS 'The student in question.';

COMMENT ON COLUMN memberof.cemail IS 'The group the student is part of.';

CREATE TABLE reservation (
    rid integer NOT NULL,
    timebooked timestamp without time zone NOT NULL,
    starttime timestamp without time zone NOT NULL,
    endtime timestamp without time zone NOT NULL,
    roomnum character varying(5) NOT NULL,
    building character varying(3) NOT NULL,
    semail character varying(32) NOT NULL,
    aemail character varying(32),
    eid integer NOT NULL,
    CONSTRAINT reservation_check CHECK ((starttime < endtime))
);

COMMENT ON TABLE reservation IS 'A particular room & time for an event.

Note: reservation.student must be a member of one of the reservation.forevent.runby clubs.';

COMMENT ON COLUMN reservation.rid IS 'An arbitrary numeric identifier.';

COMMENT ON COLUMN reservation.timebooked IS 'When the reservation was requested.';

COMMENT ON COLUMN reservation.starttime IS 'The start of when the room is needed.';

COMMENT ON COLUMN reservation.endtime IS 'The end of when the room is needed.';

COMMENT ON COLUMN reservation.roomnum IS 'The room which is requested.';

COMMENT ON COLUMN reservation.building IS 'The building the requested room is in.';

COMMENT ON COLUMN reservation.semail IS 'The user who made the reservation.';

COMMENT ON COLUMN reservation.aemail IS 'The administrator who approved the reservation, making it official. NULL if it is unapproved.';

COMMENT ON COLUMN reservation.eid IS 'The event this reservation is for.';

CREATE VIEW resconflicts AS
    SELECT r1.rid AS against, r2.rid FROM reservation r1, reservation r2 WHERE ((("overlaps"(r1.starttime, r1.endtime, r2.starttime, r2.endtime) AND (r1.eid <> r2.eid)) AND ((r1.roomnum)::text = (r2.roomnum)::text)) AND ((r1.building)::text = (r2.building)::text));

CREATE SEQUENCE reservation_rid_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

ALTER SEQUENCE reservation_rid_seq OWNED BY reservation.rid;

CREATE TABLE room (
    occupancy integer,
    roomnum character varying(5) NOT NULL,
    building character varying(3) NOT NULL,
    displayname character varying(32),
    CONSTRAINT room_building_check CHECK (("position"((building)::text, '/'::text) = 0)),
    CONSTRAINT room_roomnum_check CHECK (("position"((roomnum)::text, '/'::text) = 0))
);

COMMENT ON TABLE room IS 'A place that can be reserved. May have equipment intrinsic to it.';

COMMENT ON COLUMN room.occupancy IS 'About how many people the room can hold.';

COMMENT ON COLUMN room.roomnum IS 'The room number.';

COMMENT ON COLUMN room.building IS 'The abbrev. of the building the room is in. (eg, FL, CC, KH)';

COMMENT ON COLUMN room.displayname IS 'The well-known name of the room. eg The Morgan Room instead of CC 208.';

CREATE TABLE runby (
    cemail character varying(32) NOT NULL,
    eid integer NOT NULL
);

COMMENT ON TABLE runby IS 'What groups run events.';

COMMENT ON COLUMN runby.cemail IS 'The group running the event.';

COMMENT ON COLUMN runby.eid IS 'The event being run.';

CREATE TABLE sessions (
    id character(16) NOT NULL,
    data bytea DEFAULT ''::bytea,
    expires timestamp without time zone
);

COMMENT ON TABLE sessions IS 'Handles web sessions.';

COMMENT ON COLUMN sessions.id IS 'The gibberish identifier.';

COMMENT ON COLUMN sessions.data IS 'The Pickle''d python dict of the session.';

COMMENT ON COLUMN sessions.expires IS 'When the cookie for the session expires.';

CREATE TABLE student (
    semail character varying(32) NOT NULL,
    year integer,
    major1 character varying(32),
    major2 character varying(32)
);

COMMENT ON TABLE student IS 'Members of groups.';

COMMENT ON COLUMN student.semail IS 'The reference back to the user table.';

COMMENT ON COLUMN student.year IS 'Their official class year.';

COMMENT ON COLUMN student.major1 IS 'One of student''s majors, if they have at least 1.';

COMMENT ON COLUMN student.major2 IS 'The other of the student''s majors, if they have 2.';

CREATE VIEW studentusers AS
    SELECT student.semail, student.year, student.major1, student.major2, users.email, users.password, users.name FROM (student JOIN users ON (((student.semail)::text = (users.email)::text)));

CREATE TABLE uses (
    eid integer NOT NULL,
    equipname character varying(32) NOT NULL,
    quantity integer,
    CONSTRAINT uses_equipname_check CHECK (("position"((equipname)::text, '/'::text) = 0))
);

COMMENT ON TABLE uses IS 'Equipment used by a particular event.';

COMMENT ON COLUMN uses.eid IS 'The event that''s using equipment.';

COMMENT ON COLUMN uses.equipname IS 'The equipment being used.';

COMMENT ON COLUMN uses.quantity IS 'How much equipment is being used.';

ALTER TABLE comments ALTER COLUMN cid SET DEFAULT nextval('comments_cid_seq'::regclass);

ALTER TABLE event ALTER COLUMN eid SET DEFAULT nextval('event_eid_seq'::regclass);

ALTER TABLE reservation ALTER COLUMN rid SET DEFAULT nextval('reservation_rid_seq'::regclass);

ALTER TABLE ONLY admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (aemail);

ALTER TABLE ONLY club
    ADD CONSTRAINT club_pkey PRIMARY KEY (cemail);

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (cid);

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (eid);

ALTER TABLE ONLY isin
    ADD CONSTRAINT isin_pkey PRIMARY KEY (equipname, roomnum, building);

ALTER TABLE ONLY memberof
    ADD CONSTRAINT memberof_pkey PRIMARY KEY (semail, cemail);

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_pkey PRIMARY KEY (rid);

ALTER TABLE ONLY room
    ADD CONSTRAINT room_pkey PRIMARY KEY (roomnum, building);

ALTER TABLE ONLY runby
    ADD CONSTRAINT runby_pkey PRIMARY KEY (cemail, eid);

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY student
    ADD CONSTRAINT student_pkey PRIMARY KEY (semail);

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (email);

ALTER TABLE ONLY uses
    ADD CONSTRAINT uses_pkey PRIMARY KEY (eid, equipname);

CREATE TRIGGER roverlaps
    AFTER INSERT OR UPDATE ON reservation
    FOR EACH ROW
    EXECUTE PROCEDURE reserv_overlaps();

ALTER TABLE ONLY admin
    ADD CONSTRAINT admin_aemail_fkey FOREIGN KEY (aemail) REFERENCES users(email);

ALTER TABLE ONLY club
    ADD CONSTRAINT club_cemail_fkey FOREIGN KEY (cemail) REFERENCES users(email);

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_eid_fkey FOREIGN KEY (eid) REFERENCES event(eid);

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_email_fkey FOREIGN KEY (email) REFERENCES users(email);

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_parent_fkey FOREIGN KEY (parent) REFERENCES comments(cid);

ALTER TABLE ONLY isin
    ADD CONSTRAINT isin_roomnum_fkey FOREIGN KEY (roomnum, building) REFERENCES room(roomnum, building);

ALTER TABLE ONLY memberof
    ADD CONSTRAINT memberof_cemail_fkey FOREIGN KEY (cemail) REFERENCES club(cemail);

ALTER TABLE ONLY memberof
    ADD CONSTRAINT memberof_semail_fkey FOREIGN KEY (semail) REFERENCES student(semail);

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_aemail_fkey FOREIGN KEY (aemail) REFERENCES admin(aemail);

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_eid_fkey FOREIGN KEY (eid) REFERENCES event(eid);

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_roomnum_fkey FOREIGN KEY (roomnum, building) REFERENCES room(roomnum, building);

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_semail_fkey FOREIGN KEY (semail) REFERENCES student(semail);

ALTER TABLE ONLY runby
    ADD CONSTRAINT runby_cemail_fkey FOREIGN KEY (cemail) REFERENCES club(cemail);

ALTER TABLE ONLY runby
    ADD CONSTRAINT runby_eid_fkey FOREIGN KEY (eid) REFERENCES event(eid);

ALTER TABLE ONLY student
    ADD CONSTRAINT student_semail_fkey FOREIGN KEY (semail) REFERENCES users(email);

ALTER TABLE ONLY uses
    ADD CONSTRAINT uses_eid_fkey FOREIGN KEY (eid) REFERENCES event(eid);

