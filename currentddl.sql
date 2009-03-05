--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: restracker; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE restracker IS 'The tables for ResTracker.';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin (
    aemail character varying(32) NOT NULL,
    title character varying(32),
    super boolean
);


--
-- Name: TABLE admin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE admin IS 'Users who approve, arbitrate, and manage.';


--
-- Name: COLUMN admin.aemail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN admin.aemail IS 'The reference back to the user table.';


--
-- Name: COLUMN admin.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN admin.title IS 'The job title of the admin';


--
-- Name: COLUMN admin.super; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN admin.super IS 'Can this admin manage the application?';


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    email character varying(32) NOT NULL,
    password character(32) NOT NULL,
    name character varying(64),
    CONSTRAINT users_email_check CHECK (("position"((email)::text, '/'::text) = 0))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE users IS 'All non-anonymous users of the system.';


--
-- Name: COLUMN users.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN users.email IS 'The email address and login identifier of the user.';


--
-- Name: COLUMN users.password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN users.password IS 'An MD5 hash of the password.';


--
-- Name: COLUMN users.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN users.name IS 'The display name of the user.';


--
-- Name: adminusers; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW adminusers AS
    SELECT admin.aemail, admin.title, admin.super, users.email, users.password, users.name FROM (admin JOIN users ON (((admin.aemail)::text = (users.email)::text)));


--
-- Name: club; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE club (
    cemail character varying(32) NOT NULL,
    description text,
    class integer
);


--
-- Name: TABLE club; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE club IS 'A student association, group, club, etc.';


--
-- Name: COLUMN club.cemail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN club.cemail IS 'Reference bakc to the user table.';


--
-- Name: COLUMN club.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN club.description IS 'A short description of the group.';


--
-- Name: COLUMN club.class; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN club.class IS 'The SGA class (0-6). 0=Not really a group.';


--
-- Name: clubusers; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW clubusers AS
    SELECT club.cemail, club.description, club.class, users.email, users.password, users.name FROM (club JOIN users ON (((club.cemail)::text = (users.email)::text)));


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    cid integer NOT NULL,
    madeat timestamp without time zone,
    txt text,
    email character varying(32) NOT NULL,
    eid integer NOT NULL,
    parent integer
);


--
-- Name: TABLE comments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE comments IS 'Comments made by users about events';


--
-- Name: COLUMN comments.cid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN comments.cid IS 'An arbitrary numeric identifier.';


--
-- Name: COLUMN comments.madeat; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN comments.madeat IS 'When it was made.';


--
-- Name: COLUMN comments.txt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN comments.txt IS 'The content of the comment.';


--
-- Name: COLUMN comments.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN comments.email IS 'Who said it.';


--
-- Name: COLUMN comments.eid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN comments.eid IS 'The event the comment is about.';


--
-- Name: COLUMN comments.parent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN comments.parent IS 'The parent comment, if this replies to it.';


--
-- Name: comments_cid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_cid_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comments_cid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_cid_seq OWNED BY comments.cid;


--
-- Name: event; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE event (
    description text,
    name character varying(32),
    expectedsize integer,
    eid integer NOT NULL
);


--
-- Name: TABLE event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE event IS 'Some event a group is throwing. The date/time it is thrown is dependent on its reservations.';


--
-- Name: COLUMN event.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN event.description IS 'A long textual description of an event. Can be multiple paragraphs, etc.';


--
-- Name: COLUMN event.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN event.name IS 'The short display name of the event.';


--
-- Name: COLUMN event.expectedsize; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN event.expectedsize IS 'About how many people are expected to show for the event.';


--
-- Name: COLUMN event.eid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN event.eid IS 'An arbitrary numeric identifier.';


--
-- Name: event_eid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_eid_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: event_eid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_eid_seq OWNED BY event.eid;


--
-- Name: isin; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE isin (
    equipname character varying(32) NOT NULL,
    roomnum character varying(5) NOT NULL,
    building character varying(3) NOT NULL,
    quantity integer,
    CONSTRAINT isin_equipname_check CHECK (("position"((equipname)::text, '/'::text) = 0))
);


--
-- Name: TABLE isin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE isin IS 'Equipment that a room has intrinsic to it.';


--
-- Name: COLUMN isin.equipname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN isin.equipname IS 'The equipment in reference.';


--
-- Name: COLUMN isin.roomnum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN isin.roomnum IS 'The room number the equipment is in.';


--
-- Name: COLUMN isin.building; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN isin.building IS 'The building the room is in.';


--
-- Name: COLUMN isin.quantity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN isin.quantity IS 'How many instances of the equipment is present.';


--
-- Name: memberof; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE memberof (
    semail character varying(32) NOT NULL,
    cemail character varying(32) NOT NULL
);


--
-- Name: TABLE memberof; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE memberof IS 'What groups each student is a member of.';


--
-- Name: COLUMN memberof.semail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN memberof.semail IS 'The student in question.';


--
-- Name: COLUMN memberof.cemail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN memberof.cemail IS 'The group the student is part of.';


--
-- Name: reservation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

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


--
-- Name: TABLE reservation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE reservation IS 'A particular room & time for an event.

Note: reservation.student must be a member of one of the reservation.forevent.runby clubs.';


--
-- Name: COLUMN reservation.rid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reservation.rid IS 'An arbitrary numeric identifier.';


--
-- Name: COLUMN reservation.timebooked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reservation.timebooked IS 'When the reservation was requested.';


--
-- Name: COLUMN reservation.starttime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reservation.starttime IS 'The start of when the room is needed.';


--
-- Name: COLUMN reservation.endtime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reservation.endtime IS 'The end of when the room is needed.';


--
-- Name: COLUMN reservation.roomnum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reservation.roomnum IS 'The room which is requested.';


--
-- Name: COLUMN reservation.building; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reservation.building IS 'The building the requested room is in.';


--
-- Name: COLUMN reservation.semail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reservation.semail IS 'The user who made the reservation.';


--
-- Name: COLUMN reservation.aemail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reservation.aemail IS 'The administrator who approved the reservation, making it official. NULL if it is unapproved.';


--
-- Name: COLUMN reservation.eid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN reservation.eid IS 'The event this reservation is for.';


--
-- Name: resconflicts; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW resconflicts AS
    SELECT r1.rid AS against, r2.rid FROM reservation r1, reservation r2 WHERE ((("overlaps"(r1.starttime, r1.endtime, r2.starttime, r2.endtime) AND (r1.eid <> r2.eid)) AND ((r1.roomnum)::text = (r2.roomnum)::text)) AND ((r1.building)::text = (r2.building)::text));


--
-- Name: reservation_rid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reservation_rid_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: reservation_rid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reservation_rid_seq OWNED BY reservation.rid;


--
-- Name: room; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE room (
    occupancy integer,
    roomnum character varying(5) NOT NULL,
    building character varying(3) NOT NULL,
    displayname character varying(32),
    CONSTRAINT room_building_check CHECK (("position"((building)::text, '/'::text) = 0)),
    CONSTRAINT room_roomnum_check CHECK (("position"((roomnum)::text, '/'::text) = 0))
);


--
-- Name: TABLE room; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE room IS 'A place that can be reserved. May have equipment intrinsic to it.';


--
-- Name: COLUMN room.occupancy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN room.occupancy IS 'About how many people the room can hold.';


--
-- Name: COLUMN room.roomnum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN room.roomnum IS 'The room number.';


--
-- Name: COLUMN room.building; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN room.building IS 'The abbrev. of the building the room is in. (eg, FL, CC, KH)';


--
-- Name: COLUMN room.displayname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN room.displayname IS 'The well-known name of the room. eg The Morgan Room instead of CC 208.';


--
-- Name: runby; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE runby (
    cemail character varying(32) NOT NULL,
    eid integer NOT NULL
);


--
-- Name: TABLE runby; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE runby IS 'What groups run events.';


--
-- Name: COLUMN runby.cemail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN runby.cemail IS 'The group running the event.';


--
-- Name: COLUMN runby.eid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN runby.eid IS 'The event being run.';


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id character(16) NOT NULL,
    data bytea DEFAULT ''::bytea,
    expires timestamp without time zone
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE sessions IS 'Handles web sessions.';


--
-- Name: COLUMN sessions.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN sessions.id IS 'The gibberish identifier.';


--
-- Name: COLUMN sessions.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN sessions.data IS 'The Pickle''d python dict of the session.';


--
-- Name: COLUMN sessions.expires; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN sessions.expires IS 'When the cookie for the session expires.';


--
-- Name: student; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE student (
    semail character varying(32) NOT NULL,
    year integer,
    major1 character varying(32),
    major2 character varying(32)
);


--
-- Name: TABLE student; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE student IS 'Members of groups.';


--
-- Name: COLUMN student.semail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN student.semail IS 'The reference back to the user table.';


--
-- Name: COLUMN student.year; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN student.year IS 'Their official class year.';


--
-- Name: COLUMN student.major1; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN student.major1 IS 'One of student''s majors, if they have at least 1.';


--
-- Name: COLUMN student.major2; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN student.major2 IS 'The other of the student''s majors, if they have 2.';


--
-- Name: studentusers; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW studentusers AS
    SELECT student.semail, student.year, student.major1, student.major2, users.email, users.password, users.name FROM (student JOIN users ON (((student.semail)::text = (users.email)::text)));


--
-- Name: uses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE uses (
    eid integer NOT NULL,
    equipname character varying(32) NOT NULL,
    quantity integer,
    CONSTRAINT uses_equipname_check CHECK (("position"((equipname)::text, '/'::text) = 0))
);


--
-- Name: TABLE uses; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE uses IS 'Equipment used by a particular event.';


--
-- Name: COLUMN uses.eid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN uses.eid IS 'The event that''s using equipment.';


--
-- Name: COLUMN uses.equipname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN uses.equipname IS 'The equipment being used.';


--
-- Name: COLUMN uses.quantity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN uses.quantity IS 'How much equipment is being used.';


--
-- Name: cid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE comments ALTER COLUMN cid SET DEFAULT nextval('comments_cid_seq'::regclass);


--
-- Name: eid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE event ALTER COLUMN eid SET DEFAULT nextval('event_eid_seq'::regclass);


--
-- Name: rid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE reservation ALTER COLUMN rid SET DEFAULT nextval('reservation_rid_seq'::regclass);


--
-- Name: admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (aemail);


--
-- Name: club_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY club
    ADD CONSTRAINT club_pkey PRIMARY KEY (cemail);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (cid);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (eid);


--
-- Name: isin_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY isin
    ADD CONSTRAINT isin_pkey PRIMARY KEY (equipname, roomnum, building);


--
-- Name: memberof_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY memberof
    ADD CONSTRAINT memberof_pkey PRIMARY KEY (semail, cemail);


--
-- Name: reservation_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_pkey PRIMARY KEY (rid);


--
-- Name: room_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY room
    ADD CONSTRAINT room_pkey PRIMARY KEY (roomnum, building);


--
-- Name: runby_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY runby
    ADD CONSTRAINT runby_pkey PRIMARY KEY (cemail, eid);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: student_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY student
    ADD CONSTRAINT student_pkey PRIMARY KEY (semail);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (email);


--
-- Name: uses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uses
    ADD CONSTRAINT uses_pkey PRIMARY KEY (eid, equipname);


--
-- Name: admin_aemail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin
    ADD CONSTRAINT admin_aemail_fkey FOREIGN KEY (aemail) REFERENCES users(email);


--
-- Name: club_cemail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY club
    ADD CONSTRAINT club_cemail_fkey FOREIGN KEY (cemail) REFERENCES users(email);


--
-- Name: comments_eid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_eid_fkey FOREIGN KEY (eid) REFERENCES event(eid);


--
-- Name: comments_email_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_email_fkey FOREIGN KEY (email) REFERENCES users(email);


--
-- Name: comments_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_parent_fkey FOREIGN KEY (parent) REFERENCES comments(cid);


--
-- Name: isin_roomnum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY isin
    ADD CONSTRAINT isin_roomnum_fkey FOREIGN KEY (roomnum, building) REFERENCES room(roomnum, building);


--
-- Name: memberof_cemail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberof
    ADD CONSTRAINT memberof_cemail_fkey FOREIGN KEY (cemail) REFERENCES club(cemail);


--
-- Name: memberof_semail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberof
    ADD CONSTRAINT memberof_semail_fkey FOREIGN KEY (semail) REFERENCES student(semail);


--
-- Name: reservation_aemail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_aemail_fkey FOREIGN KEY (aemail) REFERENCES admin(aemail);


--
-- Name: reservation_eid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_eid_fkey FOREIGN KEY (eid) REFERENCES event(eid);


--
-- Name: reservation_roomnum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_roomnum_fkey FOREIGN KEY (roomnum, building) REFERENCES room(roomnum, building);


--
-- Name: reservation_semail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservation
    ADD CONSTRAINT reservation_semail_fkey FOREIGN KEY (semail) REFERENCES student(semail);


--
-- Name: runby_cemail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY runby
    ADD CONSTRAINT runby_cemail_fkey FOREIGN KEY (cemail) REFERENCES club(cemail);


--
-- Name: runby_eid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY runby
    ADD CONSTRAINT runby_eid_fkey FOREIGN KEY (eid) REFERENCES event(eid);


--
-- Name: student_semail_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY student
    ADD CONSTRAINT student_semail_fkey FOREIGN KEY (semail) REFERENCES users(email);


--
-- Name: uses_eid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY uses
    ADD CONSTRAINT uses_eid_fkey FOREIGN KEY (eid) REFERENCES event(eid);


--
-- PostgreSQL database dump complete
--

