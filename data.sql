--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- Name: comments_cid_seq; Type: SEQUENCE SET; Schema: public; Owner: restracker
--

SELECT pg_catalog.setval('comments_cid_seq', 9, true);


--
-- Name: event_eid_seq; Type: SEQUENCE SET; Schema: public; Owner: restracker
--

SELECT pg_catalog.setval('event_eid_seq', 23, true);


--
-- Name: reservation_rid_seq; Type: SEQUENCE SET; Schema: public; Owner: restracker
--

SELECT pg_catalog.setval('reservation_rid_seq', 17, true);


--
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO admin (aemail, title, super) VALUES ('sfuller@wpi.edu', 'student', true);
INSERT INTO admin (aemail, title, super) VALUES ('vzukas@wpi.edu', NULL, NULL);
INSERT INTO admin (aemail, title, super) VALUES ('shl@wpi.edu', NULL, NULL);


--
-- Data for Name: club; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO club (cemail, description, class) VALUES ('sfs@wpi.edu', 'Geeky club', 3);
INSERT INTO club (cemail, description, class) VALUES ('smas@wpi.edu', 'All things old.', 1);
INSERT INTO club (cemail, description, class) VALUES ('gdc@wpi.edu', 'They make games', 3);


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO comments (cid, madeat, txt, email, eid, parent) VALUES (1, '2004-10-19 10:23:54', 'This is a test comment', 'sfuller@wpi.edu', 1, NULL);
INSERT INTO comments (cid, madeat, txt, email, eid, parent) VALUES (2, '2009-02-18 16:16:53.226682', 'Lots of non-students', 'jebliss@wpi.edu', 2, NULL);
INSERT INTO comments (cid, madeat, txt, email, eid, parent) VALUES (4, '2009-02-18 16:17:24.901223', 'Yeah? So?', 'shl@wpi.edu', 2, 2);
INSERT INTO comments (cid, madeat, txt, email, eid, parent) VALUES (7, '2009-03-02 15:49:33.880939', '> This is a test comment

We know.', 'jebliss@wpi.edu', 1, 1);
INSERT INTO comments (cid, madeat, txt, email, eid, parent) VALUES (8, '2009-03-02 17:47:44.180304', '> > This is a test comment
> 
> We know.

Yay working replies.', 'sfuller@wpi.edu', 1, 7);
INSERT INTO comments (cid, madeat, txt, email, eid, parent) VALUES (9, '2009-03-05 20:43:47.364118', 'a new comment', 'sfuller@wpi.edu', 23, NULL);


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO event (description, name, expectedsize, eid) VALUES ('Information about events, plus a workshop sometimes.', 'Meeting', 17, 11);
INSERT INTO event (description, name, expectedsize, eid) VALUES ('People on the quad hitting each other with foam', 'Monday Night Fight Practice', 20, 2);
INSERT INTO event (description, name, expectedsize, eid) VALUES ('Board games, card games, and lots of nerdom.', 'Friday Night Gaming', 30, 1);
INSERT INTO event (description, name, expectedsize, eid) VALUES ('created for sake of example', 'Example Event', 1, 22);
INSERT INTO event (description, name, expectedsize, eid) VALUES ('Something very awesome!', 'Epic!', 9001, 21);
INSERT INTO event (description, name, expectedsize, eid) VALUES ('a test!', 'Test Event', 10, 23);


--
-- Data for Name: isin; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO isin (equipname, roomnum, building, quantity) VALUES ('chairs', '1946', 'CC', 10);


--
-- Data for Name: memberof; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO memberof (semail, cemail) VALUES ('jebliss@wpi.edu', 'smas@wpi.edu');
INSERT INTO memberof (semail, cemail) VALUES ('jebliss@wpi.edu', 'sfs@wpi.edu');
INSERT INTO memberof (semail, cemail) VALUES ('shl@wpi.edu', 'sfs@wpi.edu');
INSERT INTO memberof (semail, cemail) VALUES ('jonored@wpi.edu', 'sfs@wpi.edu');


--
-- Data for Name: reservation; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO reservation (rid, timebooked, starttime, endtime, roomnum, building, semail, aemail, eid) VALUES (1, '2009-01-01 10:23:54', '2009-02-20 18:00:00', '2009-02-21 02:00:00', '1946', 'CC', 'shl@wpi.edu', 'sfuller@wpi.edu', 1);
INSERT INTO reservation (rid, timebooked, starttime, endtime, roomnum, building, semail, aemail, eid) VALUES (7, '2009-02-18 16:13:41.539665', '2009-04-06 19:30:00', '2009-04-06 23:00:00', 'QUAD', 'Q', 'jebliss@wpi.edu', NULL, 2);
INSERT INTO reservation (rid, timebooked, starttime, endtime, roomnum, building, semail, aemail, eid) VALUES (8, '2009-02-18 16:13:41.539665', '2009-04-13 19:30:00', '2009-04-13 23:00:00', 'QUAD', 'Q', 'jebliss@wpi.edu', NULL, 2);
INSERT INTO reservation (rid, timebooked, starttime, endtime, roomnum, building, semail, aemail, eid) VALUES (5, '2009-02-18 16:12:30.76705', '2009-04-07 19:00:00', '2009-04-07 20:00:00', '208', 'CC', 'jebliss@wpi.edu', NULL, 11);
INSERT INTO reservation (rid, timebooked, starttime, endtime, roomnum, building, semail, aemail, eid) VALUES (11, '2009-03-04 22:33:21.18837', '2009-04-14 12:00:00', '2009-04-15 00:00:00', '208', 'CC', 'shl@wpi.edu', NULL, 21);
INSERT INTO reservation (rid, timebooked, starttime, endtime, roomnum, building, semail, aemail, eid) VALUES (9, '2009-02-18 16:12:30.76705', '2009-04-14 19:00:00', '2009-04-14 20:00:00', '208', 'CC', 'jebliss@wpi.edu', 'sfuller@wpi.edu', 11);
INSERT INTO reservation (rid, timebooked, starttime, endtime, roomnum, building, semail, aemail, eid) VALUES (15, '2009-03-05 04:42:17.284841', '2011-11-20 08:00:00', '2011-11-20 09:00:00', '208', 'CC', 'shl@wpi.edu', 'sfuller@wpi.edu', 22);
INSERT INTO reservation (rid, timebooked, starttime, endtime, roomnum, building, semail, aemail, eid) VALUES (14, '2009-03-05 02:55:03.1011', '2009-04-16 19:00:00', '2009-04-17 19:00:00', '230', 'HL', 'jebliss@wpi.edu', 'sfuller@wpi.edu', 21);
INSERT INTO reservation (rid, timebooked, starttime, endtime, roomnum, building, semail, aemail, eid) VALUES (17, '2009-03-05 20:42:50.09026', '2007-11-20 19:30:00', '2007-12-20 19:30:00', '1946', 'CC', 'shl@wpi.edu', NULL, 21);


--
-- Data for Name: room; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO room (occupancy, roomnum, building, displayname) VALUES (30, '1946', 'CC', 'Octawedge');
INSERT INTO room (occupancy, roomnum, building, displayname) VALUES (300, 'AUD', 'FL', 'FLAUD');
INSERT INTO room (occupancy, roomnum, building, displayname) VALUES (500, 'QUAD', 'Q', 'Quad');
INSERT INTO room (occupancy, roomnum, building, displayname) VALUES (15, '208', 'CC', 'The Morgan Room');
INSERT INTO room (occupancy, roomnum, building, displayname) VALUES (NULL, 'STAGE', 'CC', 'Forkey Commons Stage');
INSERT INTO room (occupancy, roomnum, building, displayname) VALUES (15, '128', 'CC', 'Taylor Room');
INSERT INTO room (occupancy, roomnum, building, displayname) VALUES (15, '129', 'CC', 'Chairman''s Room');
INSERT INTO room (occupancy, roomnum, building, displayname) VALUES (30, '230', 'HL', '');
INSERT INTO room (occupancy, roomnum, building, displayname) VALUES (100, '107', 'OLN', 'Olin 107');


--
-- Data for Name: runby; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO runby (cemail, eid) VALUES ('sfs@wpi.edu', 1);
INSERT INTO runby (cemail, eid) VALUES ('smas@wpi.edu', 11);
INSERT INTO runby (cemail, eid) VALUES ('smas@wpi.edu', 2);
INSERT INTO runby (cemail, eid) VALUES ('sfs@wpi.edu', 21);
INSERT INTO runby (cemail, eid) VALUES ('sfs@wpi.edu', 22);
INSERT INTO runby (cemail, eid) VALUES ('smas@wpi.edu', 21);
INSERT INTO runby (cemail, eid) VALUES ('sfs@wpi.edu', 23);
INSERT INTO runby (cemail, eid) VALUES ('smas@wpi.edu', 23);


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO sessions (id, data, expires) VALUES ('xb1f8hm7etmbi9l9', '\\200\\002}q\\000.', '2010-02-18 17:56:24');
INSERT INTO sessions (id, data, expires) VALUES ('t02xrdzfotqn1r2h', '\\200\\002}q\\000.', '2010-02-24 19:18:29');
INSERT INTO sessions (id, data, expires) VALUES ('792sc662aqg3bu9e', '\\200\\002}q\\000.', '2010-03-02 13:16:30');
INSERT INTO sessions (id, data, expires) VALUES ('wwmh3ijk8raiykyu', '\\200\\002}q\\000.', '2010-03-02 13:22:12');
INSERT INTO sessions (id, data, expires) VALUES ('z6ubecqhiowxkrg8', '\\200\\002}q\\000.', '2010-03-02 13:24:37');
INSERT INTO sessions (id, data, expires) VALUES ('a96mqax956dv2vmq', '\\200\\002}q\\000.', '2010-02-25 15:14:43');
INSERT INTO sessions (id, data, expires) VALUES ('l77e47p81w91hqzx', '\\200\\002}q\\000.', '2010-02-25 15:14:43');
INSERT INTO sessions (id, data, expires) VALUES ('0xc872mkxagcn3zs', '\\200\\002}q\\000.', '2010-03-02 13:28:44');
INSERT INTO sessions (id, data, expires) VALUES ('l7ydz30rzsytvl2j', '\\200\\002}q\\000.', '2010-03-02 14:22:35');
INSERT INTO sessions (id, data, expires) VALUES ('0brxvbsbqhl8zapu', '\\200\\002}q\\000.', '2010-02-25 14:46:28');
INSERT INTO sessions (id, data, expires) VALUES ('mv3bpi4lty3w8aec', '\\200\\002}q\\000.', '2010-03-04 15:52:52');
INSERT INTO sessions (id, data, expires) VALUES ('ypbxyy5q1c5ijvxk', '\\200\\002}q\\000.', '2010-03-04 15:53:04');
INSERT INTO sessions (id, data, expires) VALUES ('4rhpfybdd3iutsxa', '\\200\\002}q\\000.', '2010-03-05 01:31:14');
INSERT INTO sessions (id, data, expires) VALUES ('3kds6refjbi8k277', '\\200\\002}q\\000.', '2010-03-04 15:53:11');
INSERT INTO sessions (id, data, expires) VALUES ('m4qkrucfnbsoqlko', '\\200\\002}q\\000.', '2010-03-04 15:55:29');
INSERT INTO sessions (id, data, expires) VALUES ('ot91uapanhn2djz9', '\\200\\002}q\\000.', '2010-03-05 00:59:41');
INSERT INTO sessions (id, data, expires) VALUES ('y4n7g07hpxjjqudv', '\\200\\002}q\\000.', '2010-03-04 15:51:07');
INSERT INTO sessions (id, data, expires) VALUES ('8wanitobccz9nlpw', '\\200\\002}q\\000.', '2010-03-05 01:40:04');
INSERT INTO sessions (id, data, expires) VALUES ('kpehlu9qvldzmcx6', '\\200\\002}q\\000.', '2010-03-02 13:04:57');
INSERT INTO sessions (id, data, expires) VALUES ('3pjo32cbzf1vn1il', '\\200\\002}q\\000.', '2010-03-04 23:38:38');
INSERT INTO sessions (id, data, expires) VALUES ('y0dzas7daahfxw7c', '\\200\\002}q\\000.', '2010-03-02 13:06:44');
INSERT INTO sessions (id, data, expires) VALUES ('bmyxavuvpbxmorlp', '\\200\\002}q\\000.', '2010-03-05 00:25:41');
INSERT INTO sessions (id, data, expires) VALUES ('linxu4oyrfjobil7', '\\200\\002}q\\000.', '2010-03-05 01:44:37');
INSERT INTO sessions (id, data, expires) VALUES ('bupnldnlqd42bh15', '\\200\\002}q\\000.', '2010-03-02 13:07:56');
INSERT INTO sessions (id, data, expires) VALUES ('pbqpi31kqkqcnqo7', '\\200\\002}q\\000.', '2010-03-05 02:56:35');
INSERT INTO sessions (id, data, expires) VALUES ('blfnttm2880pemn2', '\\200\\002}q\\000U\\004userq\\001U\\017jebliss@wpi.eduq\\002s.', '2010-02-25 15:08:54');
INSERT INTO sessions (id, data, expires) VALUES ('ofoq9c3xtvt7n2pf', '\\200\\002}q\\000.', '2010-03-04 13:25:58');
INSERT INTO sessions (id, data, expires) VALUES ('lurzap79ynirklps', '\\200\\002}q\\000.', '2010-03-02 16:44:59');
INSERT INTO sessions (id, data, expires) VALUES ('yn99z9vy21pehdsp', '\\200\\002}q\\000.', '2010-03-04 15:56:51');
INSERT INTO sessions (id, data, expires) VALUES ('qpr57ih1pns04yi4', '\\200\\002}q\\000.', '2010-03-04 15:57:58');
INSERT INTO sessions (id, data, expires) VALUES ('wasks232k5d7sipn', '\\200\\002}q\\000.', '2010-03-04 15:58:52');
INSERT INTO sessions (id, data, expires) VALUES ('z30jvk3utpngfwgf', '\\200\\002}q\\000.', '2010-03-04 16:36:43');
INSERT INTO sessions (id, data, expires) VALUES ('m5ret49czxuv81gf', '\\200\\002}q\\000U\\004userq\\001U\\016vzukas@wpi.eduq\\002s.', '2010-03-05 00:52:56');
INSERT INTO sessions (id, data, expires) VALUES ('t3htdmqsfjc5x1ej', '\\200\\002}q\\000U\\004userq\\001U\\017sfuller@wpi.eduq\\002s.', '2010-02-24 18:27:16');
INSERT INTO sessions (id, data, expires) VALUES ('mfkv8i0hfvnnhjpb', '\\200\\002}q\\000.', '2010-03-02 13:10:59');
INSERT INTO sessions (id, data, expires) VALUES ('7p40uzrnlqbq5ikk', '\\200\\002}q\\000.', '2010-03-04 22:58:16');
INSERT INTO sessions (id, data, expires) VALUES ('gtu27tzs4epwpgd3', '\\200\\002}q\\000.', '2010-03-02 16:00:20');
INSERT INTO sessions (id, data, expires) VALUES ('uqybpnqi1s5pg89l', '\\200\\002}q\\000.', '2010-03-04 15:51:11');
INSERT INTO sessions (id, data, expires) VALUES ('g94veeyjgs9verti', '\\200\\002}q\\000.', '2010-03-04 13:27:11');
INSERT INTO sessions (id, data, expires) VALUES ('4ohc0058g3f7nwul', '\\200\\002}q\\000.', '2010-03-04 21:50:52');
INSERT INTO sessions (id, data, expires) VALUES ('h02er9431ej1rglr', '\\200\\002}q\\000.', '2010-03-03 17:38:44');
INSERT INTO sessions (id, data, expires) VALUES ('7h1d6pyg0232diou', '\\200\\002}q\\000.', '2010-03-02 13:11:04');
INSERT INTO sessions (id, data, expires) VALUES ('ajgptra732glzzqu', '\\200\\002}q\\000.', '2010-03-04 16:01:43');
INSERT INTO sessions (id, data, expires) VALUES ('hvw0xbmeovaxvbcv', '\\200\\002}q\\000.', '2010-03-02 13:26:50');
INSERT INTO sessions (id, data, expires) VALUES ('4m9cx2da8qk8bd3x', '\\200\\002}q\\000U\\004userq\\001U\\013shl@wpi.eduq\\002s.', '2010-03-04 20:26:03');
INSERT INTO sessions (id, data, expires) VALUES ('dsk3qmhdw4etgse6', '\\200\\002}q\\000U\\004userq\\001U\\017sfuller@wpi.eduq\\002s.', '2010-03-02 11:56:28');
INSERT INTO sessions (id, data, expires) VALUES ('tkm6h35mlgwe99r0', '\\200\\002}q\\000.', '2010-03-02 15:54:07');
INSERT INTO sessions (id, data, expires) VALUES ('8c6sfm7j3kugiwil', '\\200\\002}q\\000.', '2010-03-04 13:36:44');
INSERT INTO sessions (id, data, expires) VALUES ('wa0plismtxbkcdsi', '\\200\\002}q\\000.', '2010-03-02 13:19:12');
INSERT INTO sessions (id, data, expires) VALUES ('9khnox6mf89s7mdj', '\\200\\002}q\\000U\\004userq\\001U\\017sfuller@wpi.eduq\\002s.', '2010-02-26 18:35:32');
INSERT INTO sessions (id, data, expires) VALUES ('nj78s664723t2tqs', '\\200\\002}q\\000.', '2010-03-02 13:22:34');
INSERT INTO sessions (id, data, expires) VALUES ('4pmsy1dy1zmvykvk', '\\200\\002}q\\000.', '2010-03-03 19:58:05');
INSERT INTO sessions (id, data, expires) VALUES ('crw4npeg7i8mg6jy', '\\200\\002}q\\000.', '2010-03-02 13:26:02');
INSERT INTO sessions (id, data, expires) VALUES ('v2n94e4u8j81u8xd', '\\200\\002}q\\000.', '2010-03-05 01:31:29');
INSERT INTO sessions (id, data, expires) VALUES ('qz8ap2ap4fzuff09', '\\200\\002}q\\000.', '2010-03-04 21:52:51');
INSERT INTO sessions (id, data, expires) VALUES ('cezw8oz5nmq9e1yg', '\\200\\002}q\\000.', '2010-03-05 01:44:37');
INSERT INTO sessions (id, data, expires) VALUES ('ysxyr2l7y528tunj', '\\200\\002}q\\000.', '2010-03-04 13:40:13');
INSERT INTO sessions (id, data, expires) VALUES ('u5dp0otuq6z4jnor', '\\200\\002}q\\000.', '2010-03-02 13:47:11');
INSERT INTO sessions (id, data, expires) VALUES ('ja97xhjirn95lhy7', '\\200\\002}q\\000.', '2010-03-02 14:47:06');
INSERT INTO sessions (id, data, expires) VALUES ('de25cyloza9siw94', '\\200\\002}q\\000.', '2010-03-04 19:54:34');
INSERT INTO sessions (id, data, expires) VALUES ('cwbh060hd11f944y', '\\200\\002}q\\000.', '2010-03-05 01:44:08');
INSERT INTO sessions (id, data, expires) VALUES ('pk49z7eqtx26nuy6', '\\200\\002}q\\000.', '2010-03-04 15:58:59');
INSERT INTO sessions (id, data, expires) VALUES ('4yggqkixkaltk8wm', '\\200\\002}q\\000.', '2010-03-04 15:52:13');
INSERT INTO sessions (id, data, expires) VALUES ('bctoajeo3t8dnebw', '\\200\\002}q\\000.', '2010-03-04 18:33:11');
INSERT INTO sessions (id, data, expires) VALUES ('4le7lu4g63hjqcnx', '\\200\\002}q\\000.', '2010-03-05 17:58:30');
INSERT INTO sessions (id, data, expires) VALUES ('eiju2o2ujnp6sebs', '\\200\\002}q\\000.', '2010-03-05 02:29:06');
INSERT INTO sessions (id, data, expires) VALUES ('rqptiutufdqo228q', '\\200\\002}q\\000.', '2010-03-04 18:44:01');
INSERT INTO sessions (id, data, expires) VALUES ('hoqahmr6qm9jus5n', '\\200\\002}q\\000.', '2010-03-04 16:36:33');
INSERT INTO sessions (id, data, expires) VALUES ('5qpap6plmq2r15ef', '\\200\\002}q\\000.', '2010-03-04 21:49:57');
INSERT INTO sessions (id, data, expires) VALUES ('8tnbsp97vf89xuyh', '\\200\\002}q\\000.', '2010-03-04 21:52:22');
INSERT INTO sessions (id, data, expires) VALUES ('26skfy2tlxwzq57r', '\\200\\002}q\\000.', '2010-03-04 15:51:22');
INSERT INTO sessions (id, data, expires) VALUES ('thqtiqam31y6gemr', '\\200\\002}q\\000.', '2010-03-04 15:59:08');
INSERT INTO sessions (id, data, expires) VALUES ('as4liabkc34na0mg', '\\200\\002}q\\000.', '2010-03-02 13:26:37');
INSERT INTO sessions (id, data, expires) VALUES ('2l57oqreoz6gvvv2', '\\200\\002}q\\000.', '2010-03-04 19:38:46');
INSERT INTO sessions (id, data, expires) VALUES ('gfgu3ceztq955t33', '\\200\\002}q\\000.', '2010-03-04 16:45:18');
INSERT INTO sessions (id, data, expires) VALUES ('1nph6zjrjqii3ydd', '\\200\\002}q\\000.', '2010-03-04 15:59:30');
INSERT INTO sessions (id, data, expires) VALUES ('mg8h7qjlgbaz414t', '\\200\\002}q\\000.', '2010-03-04 19:56:18');
INSERT INTO sessions (id, data, expires) VALUES ('kqvmat06m25s2soa', '\\200\\002}q\\000.', '2010-03-04 18:37:11');
INSERT INTO sessions (id, data, expires) VALUES ('jmhkbikj3c67maku', '\\200\\002}q\\000.', '2010-03-04 21:48:36');
INSERT INTO sessions (id, data, expires) VALUES ('10781wz6z5z6e824', '\\200\\002}q\\000.', '2010-03-04 15:51:27');
INSERT INTO sessions (id, data, expires) VALUES ('fibq6kvgd20ocjlq', '\\200\\002}q\\000.', '2010-03-04 16:00:36');
INSERT INTO sessions (id, data, expires) VALUES ('6if12hlu99ooja5g', '\\200\\002}q\\000.', '2010-03-04 18:27:16');
INSERT INTO sessions (id, data, expires) VALUES ('dj6v1w4k0lc95e6m', '\\200\\002}q\\000.', '2010-03-04 16:01:06');
INSERT INTO sessions (id, data, expires) VALUES ('ckeg5yzlgo031fqf', '\\200\\002}q\\000.', '2010-03-04 21:51:58');
INSERT INTO sessions (id, data, expires) VALUES ('us65qaynuyl3ezrf', '\\200\\002}q\\000.', '2010-03-04 18:40:02');


--
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO student (semail, year, major1, major2) VALUES ('jebliss@wpi.edu', 2011, 'CS', 'BS');
INSERT INTO student (semail, year, major1, major2) VALUES ('shl@wpi.edu', 2010, 'CS', 'ME');
INSERT INTO student (semail, year, major1, major2) VALUES ('jonored@wpi.edu', 2008, 'CS', 'ME');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO users (email, password, name) VALUES ('sfuller@wpi.edu', 'acbd18db4cc2f85cedef654fccc4a4d8', 'Stephanie');
INSERT INTO users (email, password, name) VALUES ('sfs@wpi.edu', 'acbd18db4cc2f85cedef654fccc4a4d8', 'Science Fiction Society');
INSERT INTO users (email, password, name) VALUES ('smas@wpi.edu', 'acbd18db4cc2f85cedef654fccc4a4d8', 'Society of Medieval Arts and Sciences');
INSERT INTO users (email, password, name) VALUES ('jebliss@wpi.edu', 'acbd18db4cc2f85cedef654fccc4a4d8', 'Jamie');
INSERT INTO users (email, password, name) VALUES ('vzukas@wpi.edu', 'acbd18db4cc2f85cedef654fccc4a4d8', 'Vicky');
INSERT INTO users (email, password, name) VALUES ('shl@wpi.edu', 'acbd18db4cc2f85cedef654fccc4a4d8', 'Sam');
INSERT INTO users (email, password, name) VALUES ('shl@gmail.com', 'acbd18db4cc2f85cedef654fccc4a4d8', 'Sam');
INSERT INTO users (email, password, name) VALUES ('jonored@wpi.edu', 'acbd18db4cc2f85cedef654fccc4a4d8', 'Jonathan Gibbons');
INSERT INTO users (email, password, name) VALUES ('gdc@wpi.edu', 'acbd18db4cc2f85cedef654fccc4a4d8', 'Game Development Club');


--
-- Data for Name: uses; Type: TABLE DATA; Schema: public; Owner: restracker
--

INSERT INTO uses (eid, equipname, quantity) VALUES (1, 'chairs', 20);
INSERT INTO uses (eid, equipname, quantity) VALUES (11, 'chairs', NULL);
INSERT INTO uses (eid, equipname, quantity) VALUES (21, 'chair', NULL);
INSERT INTO uses (eid, equipname, quantity) VALUES (21, 'table', NULL);
INSERT INTO uses (eid, equipname, quantity) VALUES (21, 'nerf-gun', NULL);


--
-- PostgreSQL database dump complete
--

