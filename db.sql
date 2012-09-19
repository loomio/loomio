--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    namespace character varying(255)
);


ALTER TABLE public.active_admin_comments OWNER TO aaronthornton;

--
-- Name: admin_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE admin_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_notes_id_seq OWNER TO aaronthornton;

--
-- Name: admin_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE admin_notes_id_seq OWNED BY active_admin_comments.id;


--
-- Name: admin_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('admin_notes_id_seq', 1, false);


--
-- Name: comment_votes; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE comment_votes (
    id integer NOT NULL,
    comment_id integer,
    user_id integer,
    value boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.comment_votes OWNER TO aaronthornton;

--
-- Name: comment_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE comment_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comment_votes_id_seq OWNER TO aaronthornton;

--
-- Name: comment_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE comment_votes_id_seq OWNED BY comment_votes.id;


--
-- Name: comment_votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('comment_votes_id_seq', 2, true);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    commentable_id integer DEFAULT 0,
    commentable_type character varying(255) DEFAULT ''::character varying,
    title character varying(255) DEFAULT ''::character varying,
    body text,
    subject character varying(255) DEFAULT ''::character varying,
    user_id integer DEFAULT 0 NOT NULL,
    parent_id integer,
    lft integer,
    rgt integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.comments OWNER TO aaronthornton;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_id_seq OWNER TO aaronthornton;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('comments_id_seq', 141, true);


--
-- Name: did_not_votes; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE did_not_votes (
    id integer NOT NULL,
    user_id integer,
    motion_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.did_not_votes OWNER TO aaronthornton;

--
-- Name: did_not_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE did_not_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.did_not_votes_id_seq OWNER TO aaronthornton;

--
-- Name: did_not_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE did_not_votes_id_seq OWNED BY did_not_votes.id;


--
-- Name: did_not_votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('did_not_votes_id_seq', 920, true);


--
-- Name: discussion_read_logs; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE discussion_read_logs (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    discussion_id integer,
    discussion_activity_when_last_read integer DEFAULT 0
);


ALTER TABLE public.discussion_read_logs OWNER TO aaronthornton;

--
-- Name: discussions; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE discussions (
    id integer NOT NULL,
    group_id integer,
    author_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying(255),
    activity integer DEFAULT 0 NOT NULL,
    last_comment_at timestamp without time zone,
    description text,
    has_current_motion boolean DEFAULT false
);


ALTER TABLE public.discussions OWNER TO aaronthornton;

--
-- Name: discussions_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE discussions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.discussions_id_seq OWNER TO aaronthornton;

--
-- Name: discussions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE discussions_id_seq OWNED BY discussions.id;


--
-- Name: discussions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('discussions_id_seq', 100, true);


--
-- Name: events; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    kind character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    eventable_id integer,
    eventable_type character varying(255),
    user_id integer
);


ALTER TABLE public.events OWNER TO aaronthornton;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO aaronthornton;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('events_id_seq', 194, true);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    viewable_by character varying(255),
    members_invitable_by character varying(255),
    parent_id integer,
    email_new_motion boolean DEFAULT true,
    hide_members boolean DEFAULT false,
    beta_features boolean DEFAULT false,
    description character varying(255),
    creator_id integer NOT NULL,
    memberships_count integer DEFAULT 0 NOT NULL,
    archived_at timestamp without time zone
);


ALTER TABLE public.groups OWNER TO aaronthornton;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groups_id_seq OWNER TO aaronthornton;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('groups_id_seq', 84, true);


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE memberships (
    id integer NOT NULL,
    group_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    access_level character varying(255),
    inviter_id integer
);


ALTER TABLE public.memberships OWNER TO aaronthornton;

--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.memberships_id_seq OWNER TO aaronthornton;

--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE memberships_id_seq OWNED BY memberships.id;


--
-- Name: memberships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('memberships_id_seq', 181, true);


--
-- Name: motion_read_logs; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE motion_read_logs (
    id integer NOT NULL,
    motion_activity_when_last_read integer,
    motion_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.motion_read_logs OWNER TO aaronthornton;

--
-- Name: motion_read_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE motion_read_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.motion_read_logs_id_seq OWNER TO aaronthornton;

--
-- Name: motion_read_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE motion_read_logs_id_seq OWNED BY discussion_read_logs.id;


--
-- Name: motion_read_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('motion_read_logs_id_seq', 183, true);


--
-- Name: motion_read_logs_id_seq1; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE motion_read_logs_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.motion_read_logs_id_seq1 OWNER TO aaronthornton;

--
-- Name: motion_read_logs_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE motion_read_logs_id_seq1 OWNED BY motion_read_logs.id;


--
-- Name: motion_read_logs_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('motion_read_logs_id_seq1', 71, true);


--
-- Name: motions; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE motions (
    id integer NOT NULL,
    name character varying(255),
    description text,
    author_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    phase character varying(255) DEFAULT 'voting'::character varying NOT NULL,
    discussion_url character varying(255) DEFAULT ''::character varying NOT NULL,
    close_date timestamp without time zone,
    discussion_id integer,
    activity integer DEFAULT 0
);


ALTER TABLE public.motions OWNER TO aaronthornton;

--
-- Name: motions_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE motions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.motions_id_seq OWNER TO aaronthornton;

--
-- Name: motions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE motions_id_seq OWNED BY motions.id;


--
-- Name: motions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('motions_id_seq', 183, true);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    event_id integer,
    viewed_at timestamp without time zone
);


ALTER TABLE public.notifications OWNER TO aaronthornton;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO aaronthornton;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('notifications_id_seq', 1069, true);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO aaronthornton;

--
-- Name: users; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    admin boolean DEFAULT false,
    name character varying(255),
    unconfirmed_email character varying(255),
    invitation_token character varying(60),
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_id integer,
    invited_by_type character varying(255),
    deleted_at timestamp without time zone,
    has_read_system_notice boolean DEFAULT false NOT NULL,
    is_admin boolean DEFAULT false,
    avatar_kind character varying(255),
    uploaded_avatar_file_name character varying(255),
    uploaded_avatar_content_type character varying(255),
    uploaded_avatar_file_size integer,
    uploaded_avatar_updated_at timestamp without time zone,
    has_read_dashboard_notice boolean DEFAULT false NOT NULL,
    has_read_group_notice boolean DEFAULT false NOT NULL,
    has_read_discussion_notice boolean DEFAULT false NOT NULL,
    avatar_initials character varying(255)
);


ALTER TABLE public.users OWNER TO aaronthornton;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO aaronthornton;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('users_id_seq', 41, true);


--
-- Name: votes; Type: TABLE; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    motion_id integer,
    user_id integer,
    "position" character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    statement character varying(255)
);


ALTER TABLE public.votes OWNER TO aaronthornton;

--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: aaronthornton
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.votes_id_seq OWNER TO aaronthornton;

--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aaronthornton
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aaronthornton
--

SELECT pg_catalog.setval('votes_id_seq', 107, true);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('admin_notes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY comment_votes ALTER COLUMN id SET DEFAULT nextval('comment_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY did_not_votes ALTER COLUMN id SET DEFAULT nextval('did_not_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY discussion_read_logs ALTER COLUMN id SET DEFAULT nextval('motion_read_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY discussions ALTER COLUMN id SET DEFAULT nextval('discussions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY motion_read_logs ALTER COLUMN id SET DEFAULT nextval('motion_read_logs_id_seq1'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY motions ALTER COLUMN id SET DEFAULT nextval('motions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: aaronthornton
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


--
-- Data for Name: active_admin_comments; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY active_admin_comments (id, resource_id, resource_type, author_id, author_type, body, created_at, updated_at, namespace) FROM stdin;
\.


--
-- Data for Name: comment_votes; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY comment_votes (id, comment_id, user_id, value, created_at, updated_at) FROM stdin;
1	15	3	t	2012-05-20 04:53:54.904618	2012-05-20 04:53:54.904618
2	14	3	t	2012-05-20 04:54:42.858075	2012-05-20 04:54:42.858075
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY comments (id, commentable_id, commentable_type, title, body, subject, user_id, parent_id, lft, rgt, created_at, updated_at) FROM stdin;
1	1	Discussion		watch out		1	\N	1	2	2012-05-09 23:02:46.109319	2012-05-09 23:02:46.109319
2	2	Discussion		Im very ravinous		1	\N	1	2	2012-05-10 03:06:10.367663	2012-05-10 03:06:10.367663
3	1	Discussion		shit is going down...		1	\N	3	4	2012-05-10 03:25:01.104199	2012-05-10 03:25:01.104199
4	1	Discussion		shit is going down...		1	\N	5	6	2012-05-10 03:28:30.330202	2012-05-10 03:28:30.330202
5	1	Discussion		and that is word		1	\N	7	8	2012-05-10 03:50:44.645232	2012-05-10 03:50:44.645232
6	2	Discussion		Me tooo		2	\N	3	4	2012-05-10 04:58:19.550272	2012-05-10 04:58:19.550272
7	2	Discussion		Last comment		2	\N	5	6	2012-05-10 06:34:28.067327	2012-05-10 06:34:28.067327
8	3	Discussion		Not my cup of tea		1	\N	1	2	2012-05-12 02:11:44.542981	2012-05-12 02:11:44.542981
9	4	Discussion		Its bliss...		1	\N	1	2	2012-05-12 05:23:54.640185	2012-05-12 05:23:54.640185
10	2	Discussion		+1 to activity please		2	\N	7	8	2012-05-12 07:38:56.312613	2012-05-12 07:38:56.312613
11	7	Discussion		Not a naked woman		1	\N	1	2	2012-05-14 02:47:33.975295	2012-05-14 02:47:33.975295
12	8	Discussion		Its pretty new		3	\N	1	2	2012-05-15 04:30:25.395829	2012-05-15 04:30:25.395829
14	10	Discussion		This will be great content		3	\N	1	2	2012-05-20 01:23:16.484455	2012-05-20 01:23:16.484455
17	11	Discussion		you'll!!!		4	\N	1	2	2012-05-21 05:56:42.62773	2012-05-21 05:56:42.62773
20	20	Discussion		kjhf		3	\N	1	2	2012-06-06 01:17:39.16379	2012-06-06 01:17:39.16379
21	20	Discussion		jsdfbkjasbf		3	\N	3	4	2012-06-06 01:17:44.393384	2012-06-06 01:17:44.393384
22	21	Discussion		this is the body		14	\N	1	2	2012-06-07 02:36:09.450573	2012-06-07 02:36:09.450573
23	11	Discussion		new!		2	\N	3	4	2012-06-08 05:07:30.752358	2012-06-08 05:07:30.752358
24	27	Discussion		jbfjabf		3	\N	1	2	2012-06-08 05:08:44.959106	2012-06-08 05:08:44.959106
25	16	Discussion		dsnfbasjdfb		3	\N	1	2	2012-06-08 05:09:21.961178	2012-06-08 05:09:21.961178
26	29	Discussion		first\r\nsecond\r\nthird		14	\N	1	2	2012-06-10 21:58:13.494602	2012-06-10 21:58:13.494602
27	29	Discussion		the\r\nbig\r\nhouse		14	\N	3	4	2012-06-10 22:00:41.190032	2012-06-10 22:00:41.190032
28	29	Discussion		This is a longer line\r\nthis\r\nis\r\nnot\r\n		14	\N	5	6	2012-06-10 22:01:07.320827	2012-06-10 22:01:07.320827
29	29	Discussion		this is a real long line and i hope it will span more than this line		14	\N	7	8	2012-06-10 22:02:02.927594	2012-06-10 22:02:02.927594
30	3	Discussion		this message it to check that this long email adress is not going to flow outside of  the screen: www.myverylonglinkatmyownhomepage.com/groups/id=35643847348734837436\r\n		3	\N	3	4	2012-06-11 03:14:22.531144	2012-06-11 03:14:22.531144
31	3	Discussion		this message it to check that this long email adress is not going to flow outside of the screen:\r\n\r\nwww.myverylonglinkatmyownhomepage.com/groups/id=35643847348734837436		3	\N	5	6	2012-06-11 05:08:23.677071	2012-06-11 05:08:23.677071
32	3	Discussion		this message it to check that this long email adress is not going to flow outside of the screen: www.myverylonglinkatmyownhomepage.com/groups/id=35643847348734837436		3	\N	7	8	2012-06-11 05:09:19.901366	2012-06-11 05:09:19.901366
33	3	Discussion		this message it to check that this long email adress is not going to flow outside of the screen:\r\nwww.myverylonglinkatmyownhomepage.com/groups/id=35643847348734837436		3	\N	9	10	2012-06-11 05:09:52.520321	2012-06-11 05:09:52.520321
34	3	Discussion		how about if it doesn\r\n\r\nhave a link have a link have a link have a link have a link have a link have a link have a link have a link \r\n\r\nor anything else like that		3	\N	11	12	2012-06-11 05:10:12.749022	2012-06-11 05:10:12.749022
35	30	Discussion		skdncaciuahiuchb		3	\N	1	2	2012-06-16 06:26:14.971351	2012-06-16 06:26:14.971351
36	32	Discussion		lkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknflkdnfasdfasfnasdfnaskndfaklnvsdncaskdnkjasndjkdsaskjdfnaksfklasnfdkljasdkfaskdnfasknf		2	\N	1	2	2012-06-23 01:05:08.791483	2012-06-23 01:05:08.791483
37	27	Discussion		No Thanks		3	\N	3	4	2012-06-28 04:38:51.297283	2012-06-28 04:38:51.297283
38	16	Discussion		This is a comment to contrast		3	\N	3	4	2012-06-29 01:36:12.644961	2012-06-29 01:36:12.644961
39	29	Discussion		Are all the comments like this?\r\n		3	\N	9	10	2012-06-30 05:25:01.630899	2012-06-30 05:25:01.630899
40	37	Discussion		Dangerously small		3	\N	1	2	2012-07-02 22:39:08.273304	2012-07-02 22:39:08.273304
41	31	Discussion		Whats happened to the formatting\r\n		3	\N	1	2	2012-07-07 07:56:06.927816	2012-07-07 07:56:06.927816
42	43	Discussion		comment\r\n		3	\N	1	2	2012-07-14 00:54:11.958352	2012-07-14 00:54:11.958352
43	44	Discussion		What happened to the tidy dropdown?\r\n		3	\N	1	2	2012-07-14 22:14:37.171223	2012-07-14 22:14:37.171223
44	43	Discussion		broken letterboxes		3	\N	3	4	2012-07-14 22:54:20.215854	2012-07-14 22:54:20.215854
45	44	Discussion		http://hello.com		2	\N	3	4	2012-07-24 22:11:29.62491	2012-07-24 22:11:29.62491
46	43	Discussion		Im a booga!		14	\N	5	6	2012-07-29 01:59:56.376693	2012-07-29 01:59:56.376693
47	49	Discussion		blahhhhh		18	\N	1	2	2012-08-03 03:13:50.428541	2012-08-03 03:13:50.428541
48	49	Discussion		what happens when we get two comments? 		18	\N	3	4	2012-08-03 03:15:50.361849	2012-08-03 03:15:50.361849
49	50	Discussion		blah		18	\N	1	2	2012-08-03 04:16:15.254764	2012-08-03 04:16:15.254764
50	55	Discussion		---\n:comment: By engaging on a topic and incorporating various opinions and facts, and\n  addressing any concerns that arise, the group can hone in on the best solutions.\n		3	\N	1	2	2012-08-05 06:47:13.200266	2012-08-05 06:47:13.200266
51	56	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.		3	\N	1	2	2012-08-05 06:57:23.98508	2012-08-05 06:57:23.98508
52	57	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.		3	\N	1	2	2012-08-05 06:58:14.493598	2012-08-05 06:58:14.493598
53	58	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.		3	\N	1	2	2012-08-05 06:59:13.032258	2012-08-05 06:59:13.032258
54	59	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.		3	\N	1	2	2012-08-05 07:06:12.655984	2012-08-05 07:06:12.655984
55	60	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.		3	\N	1	2	2012-08-05 20:32:05.374484	2012-08-05 20:32:05.374484
113	81	Discussion		chew chew		2	\N	5	6	2012-09-16 06:45:19.731289	2012-09-16 06:45:19.731289
56	61	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions./nYou can use this topic to post any questions about how to use Loomio, or test out the features./nClick into a group to view or start discussions and proposals in that group, or view a list of the group members./n		3	\N	1	2	2012-08-05 22:35:59.009597	2012-08-05 22:35:59.009597
57	62	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions./nYou can use this topic to post any questions about how to use Loomio, or test out the features./nClick into a group to view or start discussions and proposals in that group, or view a list of the group members./n		3	\N	1	2	2012-08-05 22:48:39.516111	2012-08-05 22:48:39.516111
58	64	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.You can use this topic to post any questions about how to use Loomio, or test out the features.Once you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.Click into a group to view or start discussions and proposals in that group, or view a list of the group members.		3	\N	1	2	2012-08-05 23:13:25.818723	2012-08-05 23:13:25.818723
59	65	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.\nYou can use this topic to post any questions about how to use Loomio, or test out the features.\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		3	\N	1	2	2012-08-05 23:26:39.799959	2012-08-05 23:26:39.799959
60	67	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.\n\nYou can use this topic to post any questions about how to use Loomio, or test out the features.\n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		3	\N	1	2	2012-08-06 04:20:05.599931	2012-08-06 04:20:05.599931
61	68	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.\n\nYou can use this topic to post any questions about how to use Loomio, or test out the features.\n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		3	\N	1	2	2012-08-06 05:16:29.593058	2012-08-06 05:16:29.593058
62	69	Discussion		By engaging on a topic and incorporating various opinions and facts, and addressing any concerns that arise, the group can hone in on the best solutions.\n\nYou can use this topic to post any questions about how to use Loomio, or test out the features.\n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-08-07 00:13:04.342965	2012-08-07 00:13:04.342965
63	70	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-08-07 02:59:06.648772	2012-08-07 02:59:06.648772
64	44	Discussion		aaron says https://mail.google.com/mail/u/0/#inbox/138ff869785a2aee\r\nhttps://mail.google.com/mail/u/0/#inbox/138ff869785a2aee		36	\N	5	6	2012-08-07 22:29:58.089735	2012-08-07 22:29:58.089735
65	66	Discussion		https://docs.google.com/document/d/1en1KK8k-CzPtoxZvBT6g8jWjuY0WssQwdRzgIoJKQI0/edit\r\n		2	\N	1	2	2012-08-07 22:35:43.397545	2012-08-07 22:35:43.397545
66	66	Discussion		https://docs.google.com/document/d/1en1KK8k-CzPtoxZvBT6g8jWjuY0WssQwdRzgIoJKQI0/edithttps://docs.google.com/document/d/1en1KK8k-CzPtoxZvBT6g8jWjuY0WssQwdRzgIoJKQI0/edit\r\n		2	\N	3	4	2012-08-07 22:35:57.290094	2012-08-07 22:35:57.290094
67	66	Discussion		https://docs.google.com/document/d/1en1KK8k-CzPtoxZvBT6g8jWjuY0WssQwdRzgIoJKQI0.pdf		2	\N	5	6	2012-08-07 22:36:21.440517	2012-08-07 22:36:21.440517
68	66	Discussion		https://docs.google.com/document/d/1en1KK8k-CzPtoxZvBT6g8jWjuY0WssQwdRzgIoJKQI0.pdf\r\nhttps://docs.google.com/document/d/1en1KK8k-CzPtoxZvBT6g8jWjuY0WssQwdRzgIoJKQI0.pdf		2	\N	7	8	2012-08-07 22:36:43.809189	2012-08-07 22:36:43.809189
69	66	Discussion		try this notification @aaron		2	\N	9	10	2012-08-08 20:52:46.46336	2012-08-08 20:52:46.46336
70	73	Discussion		what is the issue?\r\n		3	\N	1	2	2012-08-14 01:19:55.89202	2012-08-14 01:19:55.89202
71	73	Discussion		www.sjdfsdfadbfisbdviusdviusdvfiusdiufvhsdifviusdhviusdhviuhsdfivuhsdfiuvhsdifuvhisdufhvuviuds@DFJNVSDKJNVSDN.COM		3	\N	3	4	2012-08-14 02:57:48.841642	2012-08-14 02:57:48.841642
72	76	Discussion		skin		2	\N	1	2	2012-08-20 09:27:51.976406	2012-08-20 09:27:51.976406
73	77	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-08-22 04:29:10.922442	2012-08-22 04:29:10.922442
74	82	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-08-24 04:18:24.820067	2012-08-24 04:18:24.820067
114	89	Discussion		golden necter		2	\N	13	14	2012-09-16 06:52:19.84583	2012-09-16 06:52:19.84583
115	89	Discussion		where is the rain\r\n		2	\N	15	16	2012-09-16 22:39:44.910456	2012-09-16 22:39:44.910456
116	89	Discussion		I have only sunblock		2	\N	17	18	2012-09-16 22:40:05.494893	2012-09-16 22:40:05.494893
75	83	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-08-24 06:02:30.61514	2012-08-24 06:02:30.61514
76	84	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-08-24 06:06:34.302101	2012-08-24 06:06:34.302101
77	85	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-08-24 06:06:37.350434	2012-08-24 06:06:37.350434
78	86	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		33	\N	1	2	2012-08-26 02:45:42.513567	2012-08-26 02:45:42.513567
79	86	Discussion		I blocked it		2	\N	3	4	2012-08-27 10:03:09.175078	2012-08-27 10:03:09.175078
80	49	Discussion		youll aaron!		2	\N	5	6	2012-08-27 21:27:08.376968	2012-08-27 21:27:08.376968
81	43	Discussion		lets create something useful, I cant seem to make this work Blah blah		3	\N	7	8	2012-08-30 03:51:37.455249	2012-08-30 03:51:37.455249
82	73	Discussion		fhgsdhfg ilsuhdfil auhf isuhdfiush iusdhgiusdhfgiu sdfifhgisudh dfghislduh iusdhgiusdh  idsfuhgiush		18	\N	5	6	2012-09-02 22:27:04.328519	2012-09-02 22:27:04.328519
83	46	Discussion		peter says...		2	\N	1	2	2012-09-05 20:15:02.209862	2012-09-05 20:15:02.209862
84	45	Discussion		and it cleans your teeth		2	\N	1	2	2012-09-05 22:25:18.905852	2012-09-05 22:25:18.905852
85	78	Discussion		kauehfiusehfiuh		2	\N	1	2	2012-09-06 01:09:13.229024	2012-09-06 01:09:13.229024
86	73	Discussion		vf		3	\N	7	8	2012-09-06 02:39:34.268639	2012-09-06 02:39:34.268639
87	73	Discussion		vf		3	\N	9	10	2012-09-06 02:39:57.690998	2012-09-06 02:39:57.690998
88	73	Discussion		kjsdbcjasb		3	\N	11	12	2012-09-06 02:45:38.85592	2012-09-06 02:45:38.85592
89	73	Discussion		hi		2	\N	13	14	2012-09-06 03:57:12.032776	2012-09-06 03:57:12.032776
90	94	Discussion		comment 1		2	\N	1	2	2012-09-06 04:03:21.130427	2012-09-06 04:03:21.130427
91	94	Discussion		comment 2		2	\N	3	4	2012-09-06 04:03:42.850783	2012-09-06 04:03:42.850783
92	94	Discussion		comment 3		2	\N	5	6	2012-09-06 04:04:01.818165	2012-09-06 04:04:01.818165
93	94	Discussion		comment 4		2	\N	7	8	2012-09-06 04:05:22.088507	2012-09-06 04:05:22.088507
94	95	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-09-06 05:11:51.153754	2012-09-06 05:11:51.153754
95	89	Discussion		Im am enguaged		40	\N	1	2	2012-09-06 05:43:00.05244	2012-09-06 05:43:00.05244
96	90	Discussion		go for gold		2	\N	1	2	2012-09-07 21:28:26.215312	2012-09-07 21:28:26.215312
97	89	Discussion		still shinnig?		3	\N	3	4	2012-09-08 00:22:24.712685	2012-09-08 00:22:24.712685
98	97	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-09-11 02:57:38.317593	2012-09-11 02:57:38.317593
99	89	Discussion		hi 		2	\N	5	6	2012-09-11 04:33:07.11488	2012-09-11 04:33:07.11488
100	89	Discussion		Hi again		2	\N	7	8	2012-09-11 04:45:24.892789	2012-09-11 04:45:24.892789
101	98	Discussion		yay!		3	\N	1	2	2012-09-12 00:12:48.786433	2012-09-12 00:12:48.786433
102	99	Discussion		By engaging on a topic, discussing various perspectives and information, and addressing any concerns that arise, the group can put their heads together to find the best way forward.\n\nThis 'Welcome' discussion can be used to raise any questions about how to use Loomio, and to test out the features. \n\nOnce you are finished in this particular discussion, you can click the Loomio logo at the top of the screen to go back to your dashboard and see all your current discussions and proposals.\n\nClick into a group to view or start discussions and proposals in that group, or view a list of the group members.		34	\N	1	2	2012-09-12 00:32:28.332065	2012-09-12 00:32:28.332065
103	89	Discussion		can i measure the brightness		2	\N	9	10	2012-09-15 01:58:51.593887	2012-09-15 01:58:51.593887
104	89	Discussion		my tape just isn't long enough		2	\N	11	12	2012-09-15 02:00:14.684441	2012-09-15 02:00:14.684441
105	29	Discussion		more group fun\r\n		3	\N	11	12	2012-09-15 03:24:20.875546	2012-09-15 03:24:20.875546
106	29	Discussion		and some more		3	\N	13	14	2012-09-15 03:24:33.930497	2012-09-15 03:24:33.930497
107	45	Discussion		chew chew		3	\N	3	4	2012-09-15 03:25:40.804539	2012-09-15 03:25:40.804539
108	100	Discussion		howdy stranger		3	\N	1	2	2012-09-16 06:25:33.968586	2012-09-16 06:25:33.968586
109	100	Discussion		her you from		3	\N	3	4	2012-09-16 06:25:52.412781	2012-09-16 06:25:52.412781
110	50	Discussion		again and again		2	\N	3	4	2012-09-16 06:27:21.85905	2012-09-16 06:27:21.85905
111	81	Discussion		code		3	\N	1	2	2012-09-16 06:28:34.067538	2012-09-16 06:28:34.067538
112	81	Discussion		more code		3	\N	3	4	2012-09-16 06:31:31.23183	2012-09-16 06:31:31.23183
117	96	Discussion		goats		2	\N	1	2	2012-09-16 22:40:29.415514	2012-09-16 22:40:29.415514
118	96	Discussion		goat milk		3	\N	3	4	2012-09-16 22:52:40.887982	2012-09-16 22:52:40.887982
119	94	Discussion		Put an h in		3	\N	9	10	2012-09-16 22:53:12.587631	2012-09-16 22:53:12.587631
120	80	Discussion		negative		3	\N	1	2	2012-09-16 22:54:26.736821	2012-09-16 22:54:26.736821
121	80	Discussion		-		3	\N	3	4	2012-09-16 22:54:36.286354	2012-09-16 22:54:36.286354
122	21	Discussion		are you in?		2	\N	3	4	2012-09-16 22:56:24.346384	2012-09-16 22:56:24.346384
123	21	Discussion		Im in		3	\N	5	6	2012-09-16 22:58:02.372937	2012-09-16 22:58:02.372937
124	21	Discussion		Im in already		3	\N	7	8	2012-09-16 22:59:47.36954	2012-09-16 22:59:47.36954
125	80	Discussion		-------		2	\N	5	6	2012-09-16 23:07:59.544403	2012-09-16 23:07:59.544403
126	88	Discussion		Youlch its barbed wire		2	\N	1	2	2012-09-16 23:08:37.783051	2012-09-16 23:08:37.783051
127	88	Discussion		something		2	\N	3	4	2012-09-17 01:28:19.361422	2012-09-17 01:28:19.361422
128	11	Discussion		not old		2	\N	5	6	2012-09-17 01:28:55.739344	2012-09-17 01:28:55.739344
129	14	Discussion		rookie		2	\N	1	2	2012-09-17 01:30:08.626682	2012-09-17 01:30:08.626682
130	21	Discussion		submarine		2	\N	9	10	2012-09-17 01:31:50.399368	2012-09-17 01:31:50.399368
131	14	Discussion		hi		2	\N	3	4	2012-09-17 20:15:38.304437	2012-09-17 20:15:38.304437
132	21	Discussion		youll		2	\N	11	12	2012-09-18 01:54:36.609023	2012-09-18 01:54:36.609023
133	6	Discussion		toppsy		2	\N	1	2	2012-09-18 03:51:09.636453	2012-09-18 03:51:09.636453
134	89	Discussion		you		2	\N	19	20	2012-09-18 04:00:12.669809	2012-09-18 04:00:12.669809
135	14	Discussion		Boots		3	\N	5	6	2012-09-18 09:06:31.151396	2012-09-18 09:06:31.151396
136	88	Discussion		wgtn		3	\N	5	6	2012-09-18 09:10:29.930266	2012-09-18 09:10:29.930266
137	88	Discussion		auck		3	\N	7	8	2012-09-18 09:11:18.994876	2012-09-18 09:11:18.994876
138	14	Discussion		pus		3	\N	7	8	2012-09-18 09:12:34.702655	2012-09-18 09:12:34.702655
139	89	Discussion		dre		2	\N	21	22	2012-09-19 01:28:28.434679	2012-09-19 01:28:28.434679
140	89	Discussion		beats		2	\N	23	24	2012-09-19 01:29:20.8034	2012-09-19 01:29:20.8034
141	88	Discussion		CHCH		2	\N	9	10	2012-09-19 01:30:30.586503	2012-09-19 01:30:30.586503
\.


--
-- Data for Name: did_not_votes; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY did_not_votes (id, user_id, motion_id, created_at, updated_at) FROM stdin;
1	1	1	2012-05-09 23:04:21.205534	2012-05-09 23:04:21.205534
2	1	2	2012-05-09 23:26:51.749626	2012-05-09 23:26:51.749626
3	1	3	2012-05-10 03:08:47.580893	2012-05-10 03:08:47.580893
4	2	7	2012-05-14 03:02:29.858282	2012-05-14 03:02:29.858282
5	3	9	2012-05-16 04:17:33.731541	2012-05-16 04:17:33.731541
6	3	10	2012-05-16 05:02:28.779295	2012-05-16 05:02:28.779295
7	3	11	2012-05-16 05:04:41.467002	2012-05-16 05:04:41.467002
8	3	12	2012-05-16 05:23:10.682989	2012-05-16 05:23:10.682989
9	3	13	2012-05-16 07:05:27.706008	2012-05-16 07:05:27.706008
10	3	14	2012-05-16 07:16:19.107559	2012-05-16 07:16:19.107559
11	3	15	2012-05-16 08:06:04.646103	2012-05-16 08:06:04.646103
12	3	16	2012-05-16 08:10:33.048472	2012-05-16 08:10:33.048472
13	3	17	2012-05-16 09:52:31.564531	2012-05-16 09:52:31.564531
14	3	18	2012-05-16 20:35:07.25867	2012-05-16 20:35:07.25867
15	3	19	2012-05-16 20:35:40.116298	2012-05-16 20:35:40.116298
16	3	20	2012-05-16 22:22:55.582107	2012-05-16 22:22:55.582107
17	3	21	2012-05-16 22:24:23.124586	2012-05-16 22:24:23.124586
18	3	22	2012-05-16 23:02:43.842495	2012-05-16 23:02:43.842495
19	3	25	2012-05-17 02:18:47.243918	2012-05-17 02:18:47.243918
20	3	26	2012-05-17 02:28:45.236787	2012-05-17 02:28:45.236787
21	3	27	2012-05-17 02:30:19.79647	2012-05-17 02:30:19.79647
22	3	28	2012-05-18 23:33:11.172997	2012-05-18 23:33:11.172997
23	4	28	2012-05-18 23:33:11.18116	2012-05-18 23:33:11.18116
24	3	24	2012-05-19 01:30:33.297622	2012-05-19 01:30:33.297622
25	4	24	2012-05-19 01:30:33.305571	2012-05-19 01:30:33.305571
26	3	29	2012-05-20 01:47:14.545854	2012-05-20 01:47:14.545854
27	4	29	2012-05-20 01:47:14.552596	2012-05-20 01:47:14.552596
28	4	31	2012-05-20 04:55:02.556529	2012-05-20 04:55:02.556529
29	4	32	2012-05-21 23:47:15.240869	2012-05-21 23:47:15.240869
30	4	34	2012-05-22 01:20:15.191593	2012-05-22 01:20:15.191593
31	3	33	2012-05-22 01:28:21.692109	2012-05-22 01:28:21.692109
32	4	33	2012-05-22 01:28:21.698747	2012-05-22 01:28:21.698747
33	4	35	2012-05-22 01:28:43.370601	2012-05-22 01:28:43.370601
34	3	36	2012-05-22 01:53:33.420088	2012-05-22 01:53:33.420088
35	4	36	2012-05-22 01:53:33.43026	2012-05-22 01:53:33.43026
36	3	23	2012-05-22 23:24:37.529681	2012-05-22 23:24:37.529681
37	4	23	2012-05-22 23:24:37.544025	2012-05-22 23:24:37.544025
38	4	38	2012-05-23 04:53:27.802675	2012-05-23 04:53:27.802675
39	3	37	2012-05-29 23:31:12.768574	2012-05-29 23:31:12.768574
40	4	37	2012-05-29 23:31:12.776795	2012-05-29 23:31:12.776795
41	9	37	2012-05-29 23:31:12.78184	2012-05-29 23:31:12.78184
42	1	8	2012-05-30 02:52:52.698846	2012-05-30 02:52:52.698846
43	2	8	2012-05-30 02:52:52.706411	2012-05-30 02:52:52.706411
44	2	4	2012-05-30 02:52:52.760497	2012-05-30 02:52:52.760497
45	1	6	2012-05-30 02:52:52.802875	2012-05-30 02:52:52.802875
46	2	6	2012-05-30 02:52:52.809349	2012-05-30 02:52:52.809349
47	2	5	2012-05-30 02:52:52.903332	2012-05-30 02:52:52.903332
48	3	39	2012-05-30 05:17:12.006792	2012-05-30 05:17:12.006792
49	9	39	2012-05-30 05:17:12.019356	2012-05-30 05:17:12.019356
50	2	39	2012-05-30 05:17:12.028709	2012-05-30 05:17:12.028709
51	4	39	2012-05-30 05:17:12.038026	2012-05-30 05:17:12.038026
52	13	39	2012-05-30 05:17:12.047761	2012-05-30 05:17:12.047761
53	13	41	2012-05-31 05:18:08.971382	2012-05-31 05:18:08.971382
54	4	41	2012-05-31 05:18:08.978847	2012-05-31 05:18:08.978847
55	9	41	2012-05-31 05:18:08.983978	2012-05-31 05:18:08.983978
56	3	41	2012-05-31 05:18:08.989234	2012-05-31 05:18:08.989234
57	14	41	2012-05-31 05:18:08.993926	2012-05-31 05:18:08.993926
58	2	41	2012-05-31 05:18:08.99836	2012-05-31 05:18:08.99836
59	13	42	2012-05-31 05:20:24.777077	2012-05-31 05:20:24.777077
60	4	42	2012-05-31 05:20:24.784634	2012-05-31 05:20:24.784634
61	9	42	2012-05-31 05:20:24.789723	2012-05-31 05:20:24.789723
62	3	42	2012-05-31 05:20:24.794602	2012-05-31 05:20:24.794602
63	14	42	2012-05-31 05:20:24.799765	2012-05-31 05:20:24.799765
64	2	42	2012-05-31 05:20:24.804655	2012-05-31 05:20:24.804655
65	13	43	2012-05-31 05:40:12.749153	2012-05-31 05:40:12.749153
66	4	43	2012-05-31 05:40:12.755648	2012-05-31 05:40:12.755648
67	9	43	2012-05-31 05:40:12.759995	2012-05-31 05:40:12.759995
68	3	43	2012-05-31 05:40:12.764157	2012-05-31 05:40:12.764157
69	14	43	2012-05-31 05:40:12.768893	2012-05-31 05:40:12.768893
70	2	43	2012-05-31 05:40:12.773996	2012-05-31 05:40:12.773996
71	13	44	2012-05-31 05:41:24.598224	2012-05-31 05:41:24.598224
72	4	44	2012-05-31 05:41:24.604768	2012-05-31 05:41:24.604768
73	9	44	2012-05-31 05:41:24.610027	2012-05-31 05:41:24.610027
74	3	44	2012-05-31 05:41:24.61522	2012-05-31 05:41:24.61522
75	14	44	2012-05-31 05:41:24.621027	2012-05-31 05:41:24.621027
76	2	44	2012-05-31 05:41:24.625928	2012-05-31 05:41:24.625928
77	13	45	2012-05-31 23:48:32.349401	2012-05-31 23:48:32.349401
78	4	45	2012-05-31 23:48:32.357881	2012-05-31 23:48:32.357881
79	9	45	2012-05-31 23:48:32.362873	2012-05-31 23:48:32.362873
80	3	45	2012-05-31 23:48:32.367887	2012-05-31 23:48:32.367887
81	14	45	2012-05-31 23:48:32.372549	2012-05-31 23:48:32.372549
82	2	45	2012-05-31 23:48:32.377547	2012-05-31 23:48:32.377547
83	13	46	2012-06-01 03:37:40.291574	2012-06-01 03:37:40.291574
84	14	46	2012-06-01 03:37:40.297927	2012-06-01 03:37:40.297927
85	4	46	2012-06-01 03:37:40.302703	2012-06-01 03:37:40.302703
86	9	46	2012-06-01 03:37:40.308071	2012-06-01 03:37:40.308071
87	3	46	2012-06-01 03:37:40.313214	2012-06-01 03:37:40.313214
88	2	46	2012-06-01 03:37:40.318075	2012-06-01 03:37:40.318075
89	14	50	2012-06-08 04:36:25.179982	2012-06-08 04:36:25.179982
90	1	47	2012-06-10 22:57:07.368608	2012-06-10 22:57:07.368608
96	16	40	2012-06-11 00:15:40.459117	2012-06-11 00:15:40.459117
97	9	40	2012-06-11 00:15:40.465455	2012-06-11 00:15:40.465455
98	4	40	2012-06-11 00:15:40.472864	2012-06-11 00:15:40.472864
99	13	40	2012-06-11 00:15:40.478719	2012-06-11 00:15:40.478719
100	3	40	2012-06-11 00:15:40.48619	2012-06-11 00:15:40.48619
101	1	48	2012-06-13 02:02:00.279738	2012-06-13 02:02:00.279738
102	2	48	2012-06-13 02:02:00.28886	2012-06-13 02:02:00.28886
103	14	48	2012-06-13 02:02:00.294464	2012-06-13 02:02:00.294464
104	1	52	2012-06-16 08:45:52.176027	2012-06-16 08:45:52.176027
105	2	52	2012-06-16 08:45:52.183899	2012-06-16 08:45:52.183899
106	14	52	2012-06-16 08:45:52.189603	2012-06-16 08:45:52.189603
107	3	52	2012-06-16 08:45:52.196916	2012-06-16 08:45:52.196916
108	1	53	2012-06-16 08:48:38.413903	2012-06-16 08:48:38.413903
109	2	53	2012-06-16 08:48:38.421361	2012-06-16 08:48:38.421361
110	14	53	2012-06-16 08:48:38.426839	2012-06-16 08:48:38.426839
111	3	53	2012-06-16 08:48:38.432118	2012-06-16 08:48:38.432118
112	2	54	2012-06-17 23:58:55.965071	2012-06-17 23:58:55.965071
113	1	54	2012-06-17 23:58:55.972175	2012-06-17 23:58:55.972175
114	14	54	2012-06-17 23:58:55.979795	2012-06-17 23:58:55.979795
115	3	54	2012-06-17 23:58:55.98631	2012-06-17 23:58:55.98631
116	2	55	2012-06-18 00:43:27.851977	2012-06-18 00:43:27.851977
117	1	55	2012-06-18 00:43:27.859253	2012-06-18 00:43:27.859253
118	14	55	2012-06-18 00:43:27.865011	2012-06-18 00:43:27.865011
119	3	55	2012-06-18 00:43:27.870708	2012-06-18 00:43:27.870708
120	2	56	2012-06-18 00:44:19.499123	2012-06-18 00:44:19.499123
121	1	56	2012-06-18 00:44:19.506697	2012-06-18 00:44:19.506697
122	14	56	2012-06-18 00:44:19.513112	2012-06-18 00:44:19.513112
123	3	56	2012-06-18 00:44:19.518571	2012-06-18 00:44:19.518571
124	2	57	2012-06-18 00:45:45.894296	2012-06-18 00:45:45.894296
125	1	57	2012-06-18 00:45:45.902762	2012-06-18 00:45:45.902762
126	14	57	2012-06-18 00:45:45.909125	2012-06-18 00:45:45.909125
127	3	57	2012-06-18 00:45:45.914883	2012-06-18 00:45:45.914883
128	2	58	2012-06-18 02:14:12.470133	2012-06-18 02:14:12.470133
129	1	58	2012-06-18 02:14:12.477913	2012-06-18 02:14:12.477913
130	14	58	2012-06-18 02:14:12.48432	2012-06-18 02:14:12.48432
131	3	58	2012-06-18 02:14:12.49023	2012-06-18 02:14:12.49023
132	2	59	2012-06-18 02:26:59.059544	2012-06-18 02:26:59.059544
133	1	59	2012-06-18 02:26:59.067318	2012-06-18 02:26:59.067318
134	14	59	2012-06-18 02:26:59.072839	2012-06-18 02:26:59.072839
135	3	59	2012-06-18 02:26:59.078907	2012-06-18 02:26:59.078907
136	2	51	2012-06-18 04:15:02.605781	2012-06-18 04:15:02.605781
137	1	51	2012-06-18 04:15:02.61641	2012-06-18 04:15:02.61641
138	14	51	2012-06-18 04:15:02.621774	2012-06-18 04:15:02.621774
139	3	51	2012-06-18 04:15:02.627041	2012-06-18 04:15:02.627041
140	2	64	2012-06-20 03:15:46.234181	2012-06-20 03:15:46.234181
141	3	64	2012-06-20 03:15:46.245148	2012-06-20 03:15:46.245148
142	1	64	2012-06-20 03:15:46.251405	2012-06-20 03:15:46.251405
143	14	64	2012-06-20 03:15:46.258043	2012-06-20 03:15:46.258043
144	2	65	2012-06-20 03:18:43.707611	2012-06-20 03:18:43.707611
145	3	65	2012-06-20 03:18:43.714722	2012-06-20 03:18:43.714722
146	1	65	2012-06-20 03:18:43.720243	2012-06-20 03:18:43.720243
147	14	65	2012-06-20 03:18:43.726163	2012-06-20 03:18:43.726163
148	2	66	2012-06-20 03:22:33.051926	2012-06-20 03:22:33.051926
149	3	66	2012-06-20 03:22:33.060527	2012-06-20 03:22:33.060527
150	1	66	2012-06-20 03:22:33.066258	2012-06-20 03:22:33.066258
151	14	66	2012-06-20 03:22:33.072253	2012-06-20 03:22:33.072253
152	2	67	2012-06-20 03:37:31.621435	2012-06-20 03:37:31.621435
153	3	67	2012-06-20 03:37:31.629355	2012-06-20 03:37:31.629355
154	1	67	2012-06-20 03:37:31.635087	2012-06-20 03:37:31.635087
155	14	67	2012-06-20 03:37:31.641234	2012-06-20 03:37:31.641234
156	2	68	2012-06-20 03:39:19.034194	2012-06-20 03:39:19.034194
157	3	68	2012-06-20 03:39:19.041735	2012-06-20 03:39:19.041735
158	1	68	2012-06-20 03:39:19.048137	2012-06-20 03:39:19.048137
159	14	68	2012-06-20 03:39:19.0545	2012-06-20 03:39:19.0545
160	2	60	2012-06-20 04:15:20.392109	2012-06-20 04:15:20.392109
161	1	60	2012-06-20 04:15:20.402666	2012-06-20 04:15:20.402666
162	14	60	2012-06-20 04:15:20.408367	2012-06-20 04:15:20.408367
163	2	63	2012-06-20 04:31:19.412214	2012-06-20 04:31:19.412214
164	3	63	2012-06-20 04:31:19.421068	2012-06-20 04:31:19.421068
165	1	63	2012-06-20 04:31:19.427348	2012-06-20 04:31:19.427348
166	14	63	2012-06-20 04:31:19.434319	2012-06-20 04:31:19.434319
167	3	70	2012-06-23 04:31:50.390581	2012-06-23 04:31:50.390581
168	1	70	2012-06-23 04:31:50.402556	2012-06-23 04:31:50.402556
169	14	70	2012-06-23 04:31:50.40902	2012-06-23 04:31:50.40902
170	2	73	2012-06-28 00:42:22.831123	2012-06-28 00:42:22.831123
171	1	73	2012-06-28 00:42:22.844894	2012-06-28 00:42:22.844894
172	3	73	2012-06-28 00:42:22.851608	2012-06-28 00:42:22.851608
173	14	73	2012-06-28 00:42:22.863249	2012-06-28 00:42:22.863249
174	2	74	2012-06-28 00:45:34.678656	2012-06-28 00:45:34.678656
175	1	74	2012-06-28 00:45:34.686785	2012-06-28 00:45:34.686785
176	3	74	2012-06-28 00:45:34.692457	2012-06-28 00:45:34.692457
177	14	74	2012-06-28 00:45:34.698356	2012-06-28 00:45:34.698356
178	1	69	2012-06-28 02:19:42.852405	2012-06-28 02:19:42.852405
179	3	69	2012-06-28 02:19:42.865986	2012-06-28 02:19:42.865986
180	14	69	2012-06-28 02:19:42.873248	2012-06-28 02:19:42.873248
181	1	71	2012-06-28 02:29:47.406063	2012-06-28 02:29:47.406063
182	14	71	2012-06-28 02:29:47.416199	2012-06-28 02:29:47.416199
183	2	72	2012-06-28 02:47:22.213078	2012-06-28 02:47:22.213078
184	1	72	2012-06-28 02:47:22.223184	2012-06-28 02:47:22.223184
185	14	72	2012-06-28 02:47:22.231478	2012-06-28 02:47:22.231478
186	2	76	2012-06-28 04:44:33.939231	2012-06-28 04:44:33.939231
187	1	76	2012-06-28 04:44:33.947397	2012-06-28 04:44:33.947397
188	3	76	2012-06-28 04:44:33.955849	2012-06-28 04:44:33.955849
189	14	76	2012-06-28 04:44:33.961979	2012-06-28 04:44:33.961979
190	2	77	2012-06-28 05:29:50.017625	2012-06-28 05:29:50.017625
191	1	77	2012-06-28 05:29:50.025939	2012-06-28 05:29:50.025939
192	3	77	2012-06-28 05:29:50.031613	2012-06-28 05:29:50.031613
193	14	77	2012-06-28 05:29:50.037404	2012-06-28 05:29:50.037404
194	1	75	2012-06-29 03:45:37.680442	2012-06-29 03:45:37.680442
195	14	75	2012-06-29 03:45:37.690573	2012-06-29 03:45:37.690573
196	3	75	2012-06-29 03:45:37.696914	2012-06-29 03:45:37.696914
197	2	75	2012-06-29 03:45:37.703128	2012-06-29 03:45:37.703128
198	1	78	2012-07-01 05:30:44.196482	2012-07-01 05:30:44.196482
199	3	78	2012-07-01 05:30:44.21341	2012-07-01 05:30:44.21341
200	2	78	2012-07-01 05:30:44.222916	2012-07-01 05:30:44.222916
201	14	78	2012-07-01 05:30:44.232779	2012-07-01 05:30:44.232779
202	1	80	2012-07-02 04:11:01.478851	2012-07-02 04:11:01.478851
203	3	80	2012-07-02 04:11:01.500501	2012-07-02 04:11:01.500501
204	2	80	2012-07-02 04:11:01.510423	2012-07-02 04:11:01.510423
205	14	80	2012-07-02 04:11:01.521661	2012-07-02 04:11:01.521661
206	16	86	2012-07-04 00:42:47.397022	2012-07-04 00:42:47.397022
207	9	86	2012-07-04 00:42:47.46902	2012-07-04 00:42:47.46902
208	2	86	2012-07-04 00:42:47.477194	2012-07-04 00:42:47.477194
209	4	86	2012-07-04 00:42:47.483527	2012-07-04 00:42:47.483527
210	13	86	2012-07-04 00:42:47.490221	2012-07-04 00:42:47.490221
211	14	86	2012-07-04 00:42:47.495844	2012-07-04 00:42:47.495844
212	3	86	2012-07-04 00:42:47.501331	2012-07-04 00:42:47.501331
213	16	87	2012-07-04 00:45:29.273547	2012-07-04 00:45:29.273547
214	9	87	2012-07-04 00:45:29.281266	2012-07-04 00:45:29.281266
215	2	87	2012-07-04 00:45:29.287044	2012-07-04 00:45:29.287044
216	4	87	2012-07-04 00:45:29.293167	2012-07-04 00:45:29.293167
217	13	87	2012-07-04 00:45:29.299132	2012-07-04 00:45:29.299132
218	14	87	2012-07-04 00:45:29.305815	2012-07-04 00:45:29.305815
219	3	87	2012-07-04 00:45:29.312267	2012-07-04 00:45:29.312267
220	3	85	2012-07-07 07:51:24.443011	2012-07-07 07:51:24.443011
221	1	81	2012-07-07 07:53:58.418121	2012-07-07 07:53:58.418121
222	2	81	2012-07-07 07:53:58.430748	2012-07-07 07:53:58.430748
223	17	81	2012-07-07 07:53:58.441558	2012-07-07 07:53:58.441558
224	14	81	2012-07-07 07:53:58.452089	2012-07-07 07:53:58.452089
225	3	81	2012-07-07 07:53:58.462105	2012-07-07 07:53:58.462105
226	16	89	2012-07-07 22:38:18.826235	2012-07-07 22:38:18.826235
227	9	89	2012-07-07 22:38:18.839504	2012-07-07 22:38:18.839504
228	2	89	2012-07-07 22:38:18.849569	2012-07-07 22:38:18.849569
229	4	89	2012-07-07 22:38:18.860787	2012-07-07 22:38:18.860787
230	13	89	2012-07-07 22:38:18.870809	2012-07-07 22:38:18.870809
231	14	89	2012-07-07 22:38:18.880635	2012-07-07 22:38:18.880635
232	3	89	2012-07-07 22:38:18.891489	2012-07-07 22:38:18.891489
233	16	88	2012-07-08 06:53:46.477419	2012-07-08 06:53:46.477419
234	9	88	2012-07-08 06:53:46.489422	2012-07-08 06:53:46.489422
235	2	88	2012-07-08 06:53:46.499964	2012-07-08 06:53:46.499964
236	4	88	2012-07-08 06:53:46.510524	2012-07-08 06:53:46.510524
237	13	88	2012-07-08 06:53:46.52153	2012-07-08 06:53:46.52153
238	14	88	2012-07-08 06:53:46.532778	2012-07-08 06:53:46.532778
239	1	79	2012-07-08 06:57:04.313175	2012-07-08 06:57:04.313175
240	17	79	2012-07-08 06:57:04.327071	2012-07-08 06:57:04.327071
241	14	79	2012-07-08 06:57:04.339869	2012-07-08 06:57:04.339869
242	2	79	2012-07-08 06:57:04.356738	2012-07-08 06:57:04.356738
243	2	82	2012-07-09 04:35:30.790829	2012-07-09 04:35:30.790829
244	1	82	2012-07-09 04:35:30.804519	2012-07-09 04:35:30.804519
245	17	82	2012-07-09 04:35:30.811248	2012-07-09 04:35:30.811248
246	14	82	2012-07-09 04:35:30.817241	2012-07-09 04:35:30.817241
247	3	93	2012-07-09 05:55:00.393585	2012-07-09 05:55:00.393585
248	2	93	2012-07-09 05:55:00.40242	2012-07-09 05:55:00.40242
249	1	93	2012-07-09 05:55:00.408956	2012-07-09 05:55:00.408956
250	17	93	2012-07-09 05:55:00.415462	2012-07-09 05:55:00.415462
251	14	93	2012-07-09 05:55:00.42143	2012-07-09 05:55:00.42143
252	14	84	2012-07-09 22:50:52.969021	2012-07-09 22:50:52.969021
253	3	83	2012-07-10 00:28:52.869158	2012-07-10 00:28:52.869158
254	16	90	2012-07-10 22:11:22.044621	2012-07-10 22:11:22.044621
255	9	90	2012-07-10 22:11:22.05678	2012-07-10 22:11:22.05678
256	4	90	2012-07-10 22:11:22.064054	2012-07-10 22:11:22.064054
257	13	90	2012-07-10 22:11:22.069935	2012-07-10 22:11:22.069935
258	14	90	2012-07-10 22:11:22.07557	2012-07-10 22:11:22.07557
259	16	96	2012-07-10 22:42:48.320705	2012-07-10 22:42:48.320705
260	9	96	2012-07-10 22:42:48.329068	2012-07-10 22:42:48.329068
261	2	96	2012-07-10 22:42:48.335489	2012-07-10 22:42:48.335489
262	4	96	2012-07-10 22:42:48.340763	2012-07-10 22:42:48.340763
263	13	96	2012-07-10 22:42:48.346731	2012-07-10 22:42:48.346731
264	14	96	2012-07-10 22:42:48.353113	2012-07-10 22:42:48.353113
265	3	96	2012-07-10 22:42:48.358942	2012-07-10 22:42:48.358942
266	2	94	2012-07-11 02:16:47.069692	2012-07-11 02:16:47.069692
267	3	94	2012-07-11 02:16:47.078129	2012-07-11 02:16:47.078129
268	1	94	2012-07-11 02:16:47.084746	2012-07-11 02:16:47.084746
269	17	94	2012-07-11 02:16:47.091507	2012-07-11 02:16:47.091507
270	14	94	2012-07-11 02:16:47.097744	2012-07-11 02:16:47.097744
271	3	100	2012-07-12 04:54:01.003218	2012-07-12 04:54:01.003218
272	2	100	2012-07-12 04:54:01.021661	2012-07-12 04:54:01.021661
273	1	100	2012-07-12 04:54:01.033931	2012-07-12 04:54:01.033931
274	17	100	2012-07-12 04:54:01.046772	2012-07-12 04:54:01.046772
275	14	100	2012-07-12 04:54:01.058275	2012-07-12 04:54:01.058275
276	2	104	2012-07-14 07:51:10.515203	2012-07-14 07:51:10.515203
277	3	104	2012-07-14 07:51:10.527797	2012-07-14 07:51:10.527797
278	1	104	2012-07-14 07:51:10.534986	2012-07-14 07:51:10.534986
279	17	104	2012-07-14 07:51:10.541452	2012-07-14 07:51:10.541452
280	14	104	2012-07-14 07:51:10.547597	2012-07-14 07:51:10.547597
281	1	98	2012-07-14 22:10:22.873696	2012-07-14 22:10:22.873696
282	17	98	2012-07-14 22:10:22.884076	2012-07-14 22:10:22.884076
283	14	98	2012-07-14 22:10:22.890154	2012-07-14 22:10:22.890154
284	2	91	2012-07-15 20:58:08.199406	2012-07-15 20:58:08.199406
285	14	91	2012-07-15 20:58:08.209696	2012-07-15 20:58:08.209696
286	3	91	2012-07-15 20:58:08.215807	2012-07-15 20:58:08.215807
287	2	101	2012-07-16 02:22:34.730686	2012-07-16 02:22:34.730686
288	14	101	2012-07-16 02:22:34.749516	2012-07-16 02:22:34.749516
289	1	95	2012-07-17 02:34:19.223279	2012-07-17 02:34:19.223279
290	17	95	2012-07-17 02:34:19.244684	2012-07-17 02:34:19.244684
291	14	95	2012-07-17 02:34:19.251709	2012-07-17 02:34:19.251709
292	14	103	2012-07-17 02:34:19.342536	2012-07-17 02:34:19.342536
293	2	107	2012-07-18 00:05:54.159886	2012-07-18 00:05:54.159886
294	1	107	2012-07-18 00:05:54.170151	2012-07-18 00:05:54.170151
295	17	107	2012-07-18 00:05:54.177102	2012-07-18 00:05:54.177102
296	14	107	2012-07-18 00:05:54.184163	2012-07-18 00:05:54.184163
297	2	106	2012-07-18 00:05:54.227938	2012-07-18 00:05:54.227938
298	1	106	2012-07-18 00:05:54.234138	2012-07-18 00:05:54.234138
299	17	106	2012-07-18 00:05:54.23988	2012-07-18 00:05:54.23988
300	14	106	2012-07-18 00:05:54.246349	2012-07-18 00:05:54.246349
301	2	105	2012-07-18 00:05:54.286963	2012-07-18 00:05:54.286963
302	1	105	2012-07-18 00:05:54.293722	2012-07-18 00:05:54.293722
303	17	105	2012-07-18 00:05:54.300275	2012-07-18 00:05:54.300275
304	14	105	2012-07-18 00:05:54.30687	2012-07-18 00:05:54.30687
305	3	105	2012-07-18 00:05:54.313121	2012-07-18 00:05:54.313121
306	16	97	2012-07-18 00:07:26.323081	2012-07-18 00:07:26.323081
307	9	97	2012-07-18 00:07:26.330143	2012-07-18 00:07:26.330143
308	2	97	2012-07-18 00:07:26.336999	2012-07-18 00:07:26.336999
309	4	97	2012-07-18 00:07:26.343776	2012-07-18 00:07:26.343776
310	13	97	2012-07-18 00:07:26.350332	2012-07-18 00:07:26.350332
311	14	97	2012-07-18 00:07:26.356813	2012-07-18 00:07:26.356813
312	16	99	2012-07-19 01:15:41.515998	2012-07-19 01:15:41.515998
313	9	99	2012-07-19 01:15:41.531779	2012-07-19 01:15:41.531779
314	2	99	2012-07-19 01:15:41.538333	2012-07-19 01:15:41.538333
315	4	99	2012-07-19 01:15:41.544341	2012-07-19 01:15:41.544341
316	13	99	2012-07-19 01:15:41.551293	2012-07-19 01:15:41.551293
317	14	99	2012-07-19 01:15:41.558669	2012-07-19 01:15:41.558669
318	1	110	2012-07-23 00:13:12.665029	2012-07-23 00:13:12.665029
319	17	110	2012-07-23 00:13:12.677134	2012-07-23 00:13:12.677134
320	14	110	2012-07-23 00:13:12.683102	2012-07-23 00:13:12.683102
321	2	110	2012-07-23 00:13:12.689096	2012-07-23 00:13:12.689096
322	1	108	2012-07-23 02:52:16.639815	2012-07-23 02:52:16.639815
323	17	108	2012-07-23 02:52:16.648991	2012-07-23 02:52:16.648991
324	14	108	2012-07-23 02:52:16.655745	2012-07-23 02:52:16.655745
325	2	108	2012-07-23 02:52:16.663826	2012-07-23 02:52:16.663826
326	3	108	2012-07-23 02:52:16.670706	2012-07-23 02:52:16.670706
327	1	109	2012-07-23 22:25:40.908557	2012-07-23 22:25:40.908557
328	17	109	2012-07-23 22:25:40.916745	2012-07-23 22:25:40.916745
329	14	109	2012-07-23 22:25:40.922865	2012-07-23 22:25:40.922865
330	2	109	2012-07-23 22:25:40.929128	2012-07-23 22:25:40.929128
331	3	109	2012-07-23 22:25:40.935403	2012-07-23 22:25:40.935403
332	1	111	2012-07-26 05:32:00.261508	2012-07-26 05:32:00.261508
333	17	111	2012-07-26 05:32:00.270876	2012-07-26 05:32:00.270876
334	14	111	2012-07-26 05:32:00.278587	2012-07-26 05:32:00.278587
335	3	111	2012-07-26 05:32:00.285498	2012-07-26 05:32:00.285498
336	16	114	2012-07-27 23:47:58.508301	2012-07-27 23:47:58.508301
337	9	114	2012-07-27 23:47:58.518264	2012-07-27 23:47:58.518264
338	2	114	2012-07-27 23:47:58.525077	2012-07-27 23:47:58.525077
339	4	114	2012-07-27 23:47:58.531975	2012-07-27 23:47:58.531975
340	13	114	2012-07-27 23:47:58.538718	2012-07-27 23:47:58.538718
341	14	114	2012-07-27 23:47:58.546078	2012-07-27 23:47:58.546078
342	3	114	2012-07-27 23:47:58.553179	2012-07-27 23:47:58.553179
343	16	113	2012-07-27 23:48:18.900162	2012-07-27 23:48:18.900162
344	9	113	2012-07-27 23:48:18.908268	2012-07-27 23:48:18.908268
345	2	113	2012-07-27 23:48:18.914834	2012-07-27 23:48:18.914834
346	4	113	2012-07-27 23:48:18.921234	2012-07-27 23:48:18.921234
347	13	113	2012-07-27 23:48:18.928654	2012-07-27 23:48:18.928654
348	14	113	2012-07-27 23:48:18.935315	2012-07-27 23:48:18.935315
349	3	113	2012-07-27 23:48:18.942528	2012-07-27 23:48:18.942528
350	3	102	2012-07-29 09:13:31.925495	2012-07-29 09:13:31.925495
351	2	102	2012-07-29 09:13:31.936144	2012-07-29 09:13:31.936144
352	14	102	2012-07-29 09:13:31.942312	2012-07-29 09:13:31.942312
353	1	112	2012-07-31 03:57:10.116784	2012-07-31 03:57:10.116784
354	17	112	2012-07-31 03:57:10.12754	2012-07-31 03:57:10.12754
355	2	112	2012-07-31 03:57:10.134152	2012-07-31 03:57:10.134152
356	14	112	2012-07-31 03:57:10.139519	2012-07-31 03:57:10.139519
357	3	112	2012-07-31 03:57:10.145278	2012-07-31 03:57:10.145278
358	14	116	2012-08-04 21:30:21.81045	2012-08-04 21:30:21.81045
359	2	115	2012-08-04 21:30:21.984655	2012-08-04 21:30:21.984655
360	14	115	2012-08-04 21:30:21.990798	2012-08-04 21:30:21.990798
361	3	115	2012-08-04 21:30:21.997249	2012-08-04 21:30:21.997249
362	2	117	2012-08-07 10:14:54.831576	2012-08-07 10:14:54.831576
363	14	117	2012-08-07 10:14:54.842396	2012-08-07 10:14:54.842396
364	18	117	2012-08-07 10:14:54.848951	2012-08-07 10:14:54.848951
365	3	127	2012-08-08 20:57:49.513369	2012-08-08 20:57:49.513369
366	2	127	2012-08-08 20:57:49.524386	2012-08-08 20:57:49.524386
367	1	122	2012-08-09 03:11:36.668765	2012-08-09 03:11:36.668765
368	3	122	2012-08-09 03:11:36.678838	2012-08-09 03:11:36.678838
369	14	122	2012-08-09 03:11:36.685333	2012-08-09 03:11:36.685333
370	17	122	2012-08-09 03:11:36.691711	2012-08-09 03:11:36.691711
371	21	122	2012-08-09 03:11:36.699678	2012-08-09 03:11:36.699678
372	22	122	2012-08-09 03:11:36.705012	2012-08-09 03:11:36.705012
373	23	122	2012-08-09 03:11:36.711549	2012-08-09 03:11:36.711549
374	24	122	2012-08-09 03:11:36.717767	2012-08-09 03:11:36.717767
375	25	122	2012-08-09 03:11:36.723763	2012-08-09 03:11:36.723763
376	26	122	2012-08-09 03:11:36.730658	2012-08-09 03:11:36.730658
377	27	122	2012-08-09 03:11:36.736967	2012-08-09 03:11:36.736967
378	28	122	2012-08-09 03:11:36.743518	2012-08-09 03:11:36.743518
379	29	122	2012-08-09 03:11:36.750339	2012-08-09 03:11:36.750339
380	30	122	2012-08-09 03:11:36.755875	2012-08-09 03:11:36.755875
381	31	122	2012-08-09 03:11:36.762007	2012-08-09 03:11:36.762007
382	32	122	2012-08-09 03:11:36.767903	2012-08-09 03:11:36.767903
383	35	122	2012-08-09 03:11:36.774233	2012-08-09 03:11:36.774233
384	36	122	2012-08-09 03:11:36.780661	2012-08-09 03:11:36.780661
385	3	128	2012-08-12 07:20:06.435638	2012-08-12 07:20:06.435638
386	2	128	2012-08-12 07:20:06.447972	2012-08-12 07:20:06.447972
387	1	129	2012-08-13 02:45:54.928039	2012-08-13 02:45:54.928039
388	14	129	2012-08-13 02:45:54.941482	2012-08-13 02:45:54.941482
389	17	129	2012-08-13 02:45:54.949751	2012-08-13 02:45:54.949751
390	21	129	2012-08-13 02:45:54.958324	2012-08-13 02:45:54.958324
391	22	129	2012-08-13 02:45:54.965851	2012-08-13 02:45:54.965851
392	23	129	2012-08-13 02:45:54.973974	2012-08-13 02:45:54.973974
393	24	129	2012-08-13 02:45:54.980434	2012-08-13 02:45:54.980434
394	25	129	2012-08-13 02:45:54.987196	2012-08-13 02:45:54.987196
395	26	129	2012-08-13 02:45:54.992837	2012-08-13 02:45:54.992837
396	27	129	2012-08-13 02:45:54.999174	2012-08-13 02:45:54.999174
397	28	129	2012-08-13 02:45:55.006014	2012-08-13 02:45:55.006014
398	29	129	2012-08-13 02:45:55.013059	2012-08-13 02:45:55.013059
399	30	129	2012-08-13 02:45:55.019648	2012-08-13 02:45:55.019648
400	31	129	2012-08-13 02:45:55.026069	2012-08-13 02:45:55.026069
401	32	129	2012-08-13 02:45:55.032174	2012-08-13 02:45:55.032174
402	35	129	2012-08-13 02:45:55.038493	2012-08-13 02:45:55.038493
403	36	129	2012-08-13 02:45:55.044985	2012-08-13 02:45:55.044985
404	1	130	2012-08-16 03:34:45.091059	2012-08-16 03:34:45.091059
405	14	130	2012-08-16 03:34:45.105705	2012-08-16 03:34:45.105705
406	17	130	2012-08-16 03:34:45.112499	2012-08-16 03:34:45.112499
407	21	130	2012-08-16 03:34:45.12435	2012-08-16 03:34:45.12435
408	22	130	2012-08-16 03:34:45.131385	2012-08-16 03:34:45.131385
409	23	130	2012-08-16 03:34:45.142914	2012-08-16 03:34:45.142914
410	24	130	2012-08-16 03:34:45.15112	2012-08-16 03:34:45.15112
411	25	130	2012-08-16 03:34:45.157889	2012-08-16 03:34:45.157889
412	26	130	2012-08-16 03:34:45.165539	2012-08-16 03:34:45.165539
413	27	130	2012-08-16 03:34:45.171897	2012-08-16 03:34:45.171897
414	28	130	2012-08-16 03:34:45.178538	2012-08-16 03:34:45.178538
415	29	130	2012-08-16 03:34:45.186176	2012-08-16 03:34:45.186176
416	30	130	2012-08-16 03:34:45.192521	2012-08-16 03:34:45.192521
417	31	130	2012-08-16 03:34:45.199542	2012-08-16 03:34:45.199542
418	32	130	2012-08-16 03:34:45.206699	2012-08-16 03:34:45.206699
419	35	130	2012-08-16 03:34:45.213014	2012-08-16 03:34:45.213014
420	36	130	2012-08-16 03:34:45.218688	2012-08-16 03:34:45.218688
421	1	131	2012-08-17 04:23:11.192778	2012-08-17 04:23:11.192778
422	3	131	2012-08-17 04:23:11.203173	2012-08-17 04:23:11.203173
423	14	131	2012-08-17 04:23:11.209901	2012-08-17 04:23:11.209901
424	17	131	2012-08-17 04:23:11.217114	2012-08-17 04:23:11.217114
425	21	131	2012-08-17 04:23:11.223281	2012-08-17 04:23:11.223281
426	22	131	2012-08-17 04:23:11.229973	2012-08-17 04:23:11.229973
427	23	131	2012-08-17 04:23:11.236461	2012-08-17 04:23:11.236461
428	24	131	2012-08-17 04:23:11.242993	2012-08-17 04:23:11.242993
429	25	131	2012-08-17 04:23:11.24936	2012-08-17 04:23:11.24936
430	26	131	2012-08-17 04:23:11.256028	2012-08-17 04:23:11.256028
431	27	131	2012-08-17 04:23:11.262254	2012-08-17 04:23:11.262254
432	28	131	2012-08-17 04:23:11.26892	2012-08-17 04:23:11.26892
433	29	131	2012-08-17 04:23:11.275628	2012-08-17 04:23:11.275628
434	30	131	2012-08-17 04:23:11.281913	2012-08-17 04:23:11.281913
435	31	131	2012-08-17 04:23:11.289558	2012-08-17 04:23:11.289558
436	32	131	2012-08-17 04:23:11.295967	2012-08-17 04:23:11.295967
437	35	131	2012-08-17 04:23:11.303268	2012-08-17 04:23:11.303268
438	36	131	2012-08-17 04:23:11.310258	2012-08-17 04:23:11.310258
439	3	135	2012-08-19 21:36:28.944645	2012-08-19 21:36:28.944645
440	1	132	2012-08-22 03:46:54.038786	2012-08-22 03:46:54.038786
441	14	132	2012-08-22 03:46:54.05741	2012-08-22 03:46:54.05741
442	17	132	2012-08-22 03:46:54.064166	2012-08-22 03:46:54.064166
443	21	132	2012-08-22 03:46:54.070672	2012-08-22 03:46:54.070672
444	22	132	2012-08-22 03:46:54.07808	2012-08-22 03:46:54.07808
445	23	132	2012-08-22 03:46:54.084612	2012-08-22 03:46:54.084612
446	24	132	2012-08-22 03:46:54.092514	2012-08-22 03:46:54.092514
447	25	132	2012-08-22 03:46:54.09924	2012-08-22 03:46:54.09924
448	26	132	2012-08-22 03:46:54.105909	2012-08-22 03:46:54.105909
449	27	132	2012-08-22 03:46:54.113158	2012-08-22 03:46:54.113158
450	28	132	2012-08-22 03:46:54.119717	2012-08-22 03:46:54.119717
451	29	132	2012-08-22 03:46:54.127055	2012-08-22 03:46:54.127055
452	30	132	2012-08-22 03:46:54.134048	2012-08-22 03:46:54.134048
453	31	132	2012-08-22 03:46:54.140661	2012-08-22 03:46:54.140661
454	32	132	2012-08-22 03:46:54.14787	2012-08-22 03:46:54.14787
455	35	132	2012-08-22 03:46:54.154617	2012-08-22 03:46:54.154617
456	36	132	2012-08-22 03:46:54.161228	2012-08-22 03:46:54.161228
457	2	132	2012-08-22 03:46:54.167875	2012-08-22 03:46:54.167875
458	1	133	2012-08-22 08:01:45.382066	2012-08-22 08:01:45.382066
459	3	133	2012-08-22 08:01:45.400413	2012-08-22 08:01:45.400413
460	14	133	2012-08-22 08:01:45.40721	2012-08-22 08:01:45.40721
461	17	133	2012-08-22 08:01:45.414701	2012-08-22 08:01:45.414701
462	21	133	2012-08-22 08:01:45.420921	2012-08-22 08:01:45.420921
463	22	133	2012-08-22 08:01:45.428677	2012-08-22 08:01:45.428677
464	23	133	2012-08-22 08:01:45.436378	2012-08-22 08:01:45.436378
465	24	133	2012-08-22 08:01:45.442948	2012-08-22 08:01:45.442948
466	25	133	2012-08-22 08:01:45.449557	2012-08-22 08:01:45.449557
467	26	133	2012-08-22 08:01:45.455803	2012-08-22 08:01:45.455803
468	27	133	2012-08-22 08:01:45.461671	2012-08-22 08:01:45.461671
469	28	133	2012-08-22 08:01:45.468007	2012-08-22 08:01:45.468007
470	29	133	2012-08-22 08:01:45.474332	2012-08-22 08:01:45.474332
471	30	133	2012-08-22 08:01:45.480566	2012-08-22 08:01:45.480566
472	31	133	2012-08-22 08:01:45.487332	2012-08-22 08:01:45.487332
473	32	133	2012-08-22 08:01:45.493818	2012-08-22 08:01:45.493818
474	35	133	2012-08-22 08:01:45.500225	2012-08-22 08:01:45.500225
475	36	133	2012-08-22 08:01:45.50743	2012-08-22 08:01:45.50743
476	1	134	2012-08-22 10:02:37.637369	2012-08-22 10:02:37.637369
477	3	134	2012-08-22 10:02:37.64845	2012-08-22 10:02:37.64845
478	14	134	2012-08-22 10:02:37.655145	2012-08-22 10:02:37.655145
479	17	134	2012-08-22 10:02:37.661154	2012-08-22 10:02:37.661154
480	21	134	2012-08-22 10:02:37.666642	2012-08-22 10:02:37.666642
481	22	134	2012-08-22 10:02:37.673388	2012-08-22 10:02:37.673388
482	23	134	2012-08-22 10:02:37.680139	2012-08-22 10:02:37.680139
483	24	134	2012-08-22 10:02:37.687408	2012-08-22 10:02:37.687408
484	25	134	2012-08-22 10:02:37.693815	2012-08-22 10:02:37.693815
485	26	134	2012-08-22 10:02:37.700895	2012-08-22 10:02:37.700895
486	27	134	2012-08-22 10:02:37.707438	2012-08-22 10:02:37.707438
487	28	134	2012-08-22 10:02:37.71404	2012-08-22 10:02:37.71404
488	29	134	2012-08-22 10:02:37.72052	2012-08-22 10:02:37.72052
489	30	134	2012-08-22 10:02:37.726454	2012-08-22 10:02:37.726454
490	31	134	2012-08-22 10:02:37.732096	2012-08-22 10:02:37.732096
491	32	134	2012-08-22 10:02:37.73784	2012-08-22 10:02:37.73784
492	35	134	2012-08-22 10:02:37.744021	2012-08-22 10:02:37.744021
493	36	134	2012-08-22 10:02:37.750502	2012-08-22 10:02:37.750502
494	2	134	2012-08-22 10:02:37.756308	2012-08-22 10:02:37.756308
495	14	138	2012-08-23 23:00:06.705893	2012-08-23 23:00:06.705893
496	2	138	2012-08-23 23:00:06.724257	2012-08-23 23:00:06.724257
497	39	136	2012-08-24 01:11:42.00121	2012-08-24 01:11:42.00121
498	3	136	2012-08-24 01:11:42.010761	2012-08-24 01:11:42.010761
499	3	137	2012-08-24 01:13:57.122294	2012-08-24 01:13:57.122294
500	14	146	2012-08-24 21:09:58.544702	2012-08-24 21:09:58.544702
501	1	140	2012-08-25 22:03:08.485646	2012-08-25 22:03:08.485646
502	14	140	2012-08-25 22:03:08.500846	2012-08-25 22:03:08.500846
503	17	140	2012-08-25 22:03:08.507047	2012-08-25 22:03:08.507047
504	21	140	2012-08-25 22:03:08.513419	2012-08-25 22:03:08.513419
505	22	140	2012-08-25 22:03:08.520165	2012-08-25 22:03:08.520165
506	23	140	2012-08-25 22:03:08.526379	2012-08-25 22:03:08.526379
507	24	140	2012-08-25 22:03:08.53264	2012-08-25 22:03:08.53264
508	25	140	2012-08-25 22:03:08.538906	2012-08-25 22:03:08.538906
509	26	140	2012-08-25 22:03:08.545176	2012-08-25 22:03:08.545176
510	27	140	2012-08-25 22:03:08.551705	2012-08-25 22:03:08.551705
511	28	140	2012-08-25 22:03:08.558032	2012-08-25 22:03:08.558032
512	29	140	2012-08-25 22:03:08.564218	2012-08-25 22:03:08.564218
513	30	140	2012-08-25 22:03:08.570776	2012-08-25 22:03:08.570776
514	31	140	2012-08-25 22:03:08.577858	2012-08-25 22:03:08.577858
515	32	140	2012-08-25 22:03:08.58685	2012-08-25 22:03:08.58685
516	35	140	2012-08-25 22:03:08.596227	2012-08-25 22:03:08.596227
517	36	140	2012-08-25 22:03:08.608871	2012-08-25 22:03:08.608871
518	1	141	2012-08-25 22:05:41.891908	2012-08-25 22:05:41.891908
519	3	141	2012-08-25 22:05:41.899271	2012-08-25 22:05:41.899271
520	14	141	2012-08-25 22:05:41.905823	2012-08-25 22:05:41.905823
521	17	141	2012-08-25 22:05:41.91405	2012-08-25 22:05:41.91405
522	21	141	2012-08-25 22:05:41.921933	2012-08-25 22:05:41.921933
523	22	141	2012-08-25 22:05:41.930594	2012-08-25 22:05:41.930594
524	23	141	2012-08-25 22:05:41.937052	2012-08-25 22:05:41.937052
525	24	141	2012-08-25 22:05:41.944089	2012-08-25 22:05:41.944089
526	25	141	2012-08-25 22:05:41.951684	2012-08-25 22:05:41.951684
527	26	141	2012-08-25 22:05:41.958565	2012-08-25 22:05:41.958565
528	27	141	2012-08-25 22:05:41.965956	2012-08-25 22:05:41.965956
529	28	141	2012-08-25 22:05:41.973489	2012-08-25 22:05:41.973489
530	29	141	2012-08-25 22:05:41.979794	2012-08-25 22:05:41.979794
531	30	141	2012-08-25 22:05:41.987271	2012-08-25 22:05:41.987271
532	31	141	2012-08-25 22:05:41.993924	2012-08-25 22:05:41.993924
533	32	141	2012-08-25 22:05:41.999428	2012-08-25 22:05:41.999428
534	35	141	2012-08-25 22:05:42.005535	2012-08-25 22:05:42.005535
535	36	141	2012-08-25 22:05:42.011454	2012-08-25 22:05:42.011454
536	2	141	2012-08-25 22:05:42.018202	2012-08-25 22:05:42.018202
537	2	139	2012-08-25 22:46:14.070033	2012-08-25 22:46:14.070033
538	3	126	2012-08-28 23:57:16.791962	2012-08-28 23:57:16.791962
539	1	148	2012-08-29 00:08:12.932331	2012-08-29 00:08:12.932331
540	3	148	2012-08-29 00:08:12.945478	2012-08-29 00:08:12.945478
541	14	148	2012-08-29 00:08:12.957034	2012-08-29 00:08:12.957034
542	17	148	2012-08-29 00:08:12.968503	2012-08-29 00:08:12.968503
543	21	148	2012-08-29 00:08:12.979275	2012-08-29 00:08:12.979275
544	22	148	2012-08-29 00:08:12.991529	2012-08-29 00:08:12.991529
545	23	148	2012-08-29 00:08:13.001887	2012-08-29 00:08:13.001887
546	24	148	2012-08-29 00:08:13.014566	2012-08-29 00:08:13.014566
547	25	148	2012-08-29 00:08:13.026294	2012-08-29 00:08:13.026294
548	26	148	2012-08-29 00:08:13.038013	2012-08-29 00:08:13.038013
549	27	148	2012-08-29 00:08:13.049893	2012-08-29 00:08:13.049893
550	28	148	2012-08-29 00:08:13.062058	2012-08-29 00:08:13.062058
551	29	148	2012-08-29 00:08:13.073584	2012-08-29 00:08:13.073584
552	30	148	2012-08-29 00:08:13.084721	2012-08-29 00:08:13.084721
553	31	148	2012-08-29 00:08:13.09621	2012-08-29 00:08:13.09621
554	32	148	2012-08-29 00:08:13.107483	2012-08-29 00:08:13.107483
555	35	148	2012-08-29 00:08:13.119458	2012-08-29 00:08:13.119458
556	36	148	2012-08-29 00:08:13.130954	2012-08-29 00:08:13.130954
557	1	149	2012-08-29 05:00:07.827602	2012-08-29 05:00:07.827602
558	14	149	2012-08-29 05:00:07.84688	2012-08-29 05:00:07.84688
559	17	149	2012-08-29 05:00:07.858238	2012-08-29 05:00:07.858238
560	21	149	2012-08-29 05:00:07.868914	2012-08-29 05:00:07.868914
561	22	149	2012-08-29 05:00:07.881067	2012-08-29 05:00:07.881067
562	23	149	2012-08-29 05:00:07.892264	2012-08-29 05:00:07.892264
563	24	149	2012-08-29 05:00:07.903765	2012-08-29 05:00:07.903765
564	25	149	2012-08-29 05:00:07.915621	2012-08-29 05:00:07.915621
565	26	149	2012-08-29 05:00:07.926526	2012-08-29 05:00:07.926526
566	27	149	2012-08-29 05:00:07.938003	2012-08-29 05:00:07.938003
567	28	149	2012-08-29 05:00:07.953688	2012-08-29 05:00:07.953688
568	29	149	2012-08-29 05:00:07.969936	2012-08-29 05:00:07.969936
569	30	149	2012-08-29 05:00:07.983649	2012-08-29 05:00:07.983649
570	31	149	2012-08-29 05:00:07.99466	2012-08-29 05:00:07.99466
571	32	149	2012-08-29 05:00:08.005554	2012-08-29 05:00:08.005554
572	35	149	2012-08-29 05:00:08.016639	2012-08-29 05:00:08.016639
573	36	149	2012-08-29 05:00:08.02737	2012-08-29 05:00:08.02737
574	2	149	2012-08-29 05:00:08.039258	2012-08-29 05:00:08.039258
575	1	150	2012-08-29 05:04:53.55119	2012-08-29 05:04:53.55119
576	3	150	2012-08-29 05:04:53.566261	2012-08-29 05:04:53.566261
577	14	150	2012-08-29 05:04:53.578062	2012-08-29 05:04:53.578062
578	17	150	2012-08-29 05:04:53.589863	2012-08-29 05:04:53.589863
579	21	150	2012-08-29 05:04:53.601071	2012-08-29 05:04:53.601071
580	22	150	2012-08-29 05:04:53.611865	2012-08-29 05:04:53.611865
581	23	150	2012-08-29 05:04:53.623159	2012-08-29 05:04:53.623159
582	24	150	2012-08-29 05:04:53.634359	2012-08-29 05:04:53.634359
583	25	150	2012-08-29 05:04:53.648057	2012-08-29 05:04:53.648057
584	26	150	2012-08-29 05:04:53.659749	2012-08-29 05:04:53.659749
585	27	150	2012-08-29 05:04:53.671143	2012-08-29 05:04:53.671143
586	28	150	2012-08-29 05:04:53.683324	2012-08-29 05:04:53.683324
587	29	150	2012-08-29 05:04:53.694562	2012-08-29 05:04:53.694562
588	30	150	2012-08-29 05:04:53.705975	2012-08-29 05:04:53.705975
589	31	150	2012-08-29 05:04:53.717342	2012-08-29 05:04:53.717342
590	32	150	2012-08-29 05:04:53.728867	2012-08-29 05:04:53.728867
591	35	150	2012-08-29 05:04:53.740029	2012-08-29 05:04:53.740029
592	36	150	2012-08-29 05:04:53.751672	2012-08-29 05:04:53.751672
593	2	150	2012-08-29 05:04:53.76537	2012-08-29 05:04:53.76537
594	1	151	2012-08-29 05:13:37.363919	2012-08-29 05:13:37.363919
595	3	151	2012-08-29 05:13:37.378811	2012-08-29 05:13:37.378811
596	14	151	2012-08-29 05:13:37.599068	2012-08-29 05:13:37.599068
597	17	151	2012-08-29 05:13:37.61211	2012-08-29 05:13:37.61211
598	21	151	2012-08-29 05:13:37.623283	2012-08-29 05:13:37.623283
599	22	151	2012-08-29 05:13:37.634347	2012-08-29 05:13:37.634347
600	23	151	2012-08-29 05:13:37.645453	2012-08-29 05:13:37.645453
601	24	151	2012-08-29 05:13:37.656378	2012-08-29 05:13:37.656378
602	25	151	2012-08-29 05:13:37.667477	2012-08-29 05:13:37.667477
603	26	151	2012-08-29 05:13:37.678632	2012-08-29 05:13:37.678632
604	27	151	2012-08-29 05:13:37.691058	2012-08-29 05:13:37.691058
605	28	151	2012-08-29 05:13:37.702771	2012-08-29 05:13:37.702771
606	29	151	2012-08-29 05:13:37.714566	2012-08-29 05:13:37.714566
607	30	151	2012-08-29 05:13:37.725638	2012-08-29 05:13:37.725638
608	31	151	2012-08-29 05:13:37.737204	2012-08-29 05:13:37.737204
609	32	151	2012-08-29 05:13:37.74888	2012-08-29 05:13:37.74888
610	35	151	2012-08-29 05:13:37.760679	2012-08-29 05:13:37.760679
611	36	151	2012-08-29 05:13:37.771642	2012-08-29 05:13:37.771642
612	2	151	2012-08-29 05:13:37.782347	2012-08-29 05:13:37.782347
613	3	152	2012-08-29 21:08:33.138882	2012-08-29 21:08:33.138882
614	3	153	2012-08-29 21:24:26.572673	2012-08-29 21:24:26.572673
615	14	155	2012-08-30 20:07:02.881879	2012-08-30 20:07:02.881879
616	3	155	2012-08-30 20:07:02.893991	2012-08-30 20:07:02.893991
617	1	154	2012-09-02 09:44:04.869794	2012-09-02 09:44:04.869794
618	3	154	2012-09-02 09:44:04.885028	2012-09-02 09:44:04.885028
619	14	154	2012-09-02 09:44:04.896133	2012-09-02 09:44:04.896133
620	17	154	2012-09-02 09:44:04.911416	2012-09-02 09:44:04.911416
621	21	154	2012-09-02 09:44:04.922898	2012-09-02 09:44:04.922898
622	22	154	2012-09-02 09:44:04.934861	2012-09-02 09:44:04.934861
623	23	154	2012-09-02 09:44:04.947971	2012-09-02 09:44:04.947971
624	24	154	2012-09-02 09:44:04.958945	2012-09-02 09:44:04.958945
625	25	154	2012-09-02 09:44:04.970218	2012-09-02 09:44:04.970218
626	26	154	2012-09-02 09:44:04.983502	2012-09-02 09:44:04.983502
627	27	154	2012-09-02 09:44:05.003277	2012-09-02 09:44:05.003277
628	28	154	2012-09-02 09:44:05.015637	2012-09-02 09:44:05.015637
629	29	154	2012-09-02 09:44:05.029186	2012-09-02 09:44:05.029186
630	30	154	2012-09-02 09:44:05.041678	2012-09-02 09:44:05.041678
631	31	154	2012-09-02 09:44:05.053049	2012-09-02 09:44:05.053049
632	32	154	2012-09-02 09:44:05.064273	2012-09-02 09:44:05.064273
633	35	154	2012-09-02 09:44:05.075101	2012-09-02 09:44:05.075101
634	36	154	2012-09-02 09:44:05.087485	2012-09-02 09:44:05.087485
635	2	154	2012-09-02 09:44:05.101587	2012-09-02 09:44:05.101587
636	18	154	2012-09-02 09:44:05.113552	2012-09-02 09:44:05.113552
637	1	157	2012-09-02 23:40:16.93235	2012-09-02 23:40:16.93235
638	3	157	2012-09-02 23:40:16.955594	2012-09-02 23:40:16.955594
639	14	157	2012-09-02 23:40:16.974063	2012-09-02 23:40:16.974063
640	17	157	2012-09-02 23:40:16.990728	2012-09-02 23:40:16.990728
641	21	157	2012-09-02 23:40:17.008255	2012-09-02 23:40:17.008255
642	22	157	2012-09-02 23:40:17.025693	2012-09-02 23:40:17.025693
643	23	157	2012-09-02 23:40:17.045224	2012-09-02 23:40:17.045224
644	24	157	2012-09-02 23:40:17.063539	2012-09-02 23:40:17.063539
645	25	157	2012-09-02 23:40:17.081021	2012-09-02 23:40:17.081021
646	26	157	2012-09-02 23:40:17.098522	2012-09-02 23:40:17.098522
647	27	157	2012-09-02 23:40:17.114493	2012-09-02 23:40:17.114493
648	28	157	2012-09-02 23:40:17.131888	2012-09-02 23:40:17.131888
649	29	157	2012-09-02 23:40:17.147623	2012-09-02 23:40:17.147623
650	30	157	2012-09-02 23:40:17.160365	2012-09-02 23:40:17.160365
651	31	157	2012-09-02 23:40:17.172815	2012-09-02 23:40:17.172815
652	32	157	2012-09-02 23:40:17.185711	2012-09-02 23:40:17.185711
653	35	157	2012-09-02 23:40:17.199291	2012-09-02 23:40:17.199291
654	36	157	2012-09-02 23:40:17.212454	2012-09-02 23:40:17.212454
655	2	157	2012-09-02 23:40:17.225542	2012-09-02 23:40:17.225542
656	18	157	2012-09-02 23:40:17.238592	2012-09-02 23:40:17.238592
657	1	159	2012-09-03 01:24:54.892233	2012-09-03 01:24:54.892233
658	3	159	2012-09-03 01:24:54.905747	2012-09-03 01:24:54.905747
659	14	159	2012-09-03 01:24:54.916984	2012-09-03 01:24:54.916984
660	17	159	2012-09-03 01:24:54.928067	2012-09-03 01:24:54.928067
661	21	159	2012-09-03 01:24:54.938037	2012-09-03 01:24:54.938037
662	22	159	2012-09-03 01:24:54.949295	2012-09-03 01:24:54.949295
663	23	159	2012-09-03 01:24:54.960647	2012-09-03 01:24:54.960647
664	24	159	2012-09-03 01:24:54.97192	2012-09-03 01:24:54.97192
665	25	159	2012-09-03 01:24:54.982803	2012-09-03 01:24:54.982803
666	26	159	2012-09-03 01:24:54.992909	2012-09-03 01:24:54.992909
667	27	159	2012-09-03 01:24:55.004656	2012-09-03 01:24:55.004656
668	28	159	2012-09-03 01:24:55.014856	2012-09-03 01:24:55.014856
669	29	159	2012-09-03 01:24:55.024489	2012-09-03 01:24:55.024489
670	30	159	2012-09-03 01:24:55.035428	2012-09-03 01:24:55.035428
671	31	159	2012-09-03 01:24:55.046118	2012-09-03 01:24:55.046118
672	32	159	2012-09-03 01:24:55.058095	2012-09-03 01:24:55.058095
673	35	159	2012-09-03 01:24:55.068402	2012-09-03 01:24:55.068402
674	36	159	2012-09-03 01:24:55.079405	2012-09-03 01:24:55.079405
675	2	159	2012-09-03 01:24:55.090182	2012-09-03 01:24:55.090182
676	18	159	2012-09-03 01:24:55.10088	2012-09-03 01:24:55.10088
677	14	158	2012-09-03 03:52:55.158853	2012-09-03 03:52:55.158853
678	18	158	2012-09-03 03:52:55.17514	2012-09-03 03:52:55.17514
679	2	158	2012-09-03 03:52:55.187988	2012-09-03 03:52:55.187988
680	14	156	2012-09-03 22:08:45.821	2012-09-03 22:08:45.821
681	3	156	2012-09-03 22:08:45.83572	2012-09-03 22:08:45.83572
682	14	160	2012-09-04 03:23:54.79267	2012-09-04 03:23:54.79267
683	3	160	2012-09-04 03:23:54.811233	2012-09-04 03:23:54.811233
685	14	161	2012-09-04 06:07:42.995669	2012-09-04 06:07:42.995669
686	1	162	2012-09-07 21:26:05.675131	2012-09-07 21:26:05.675131
687	14	162	2012-09-07 21:26:05.694408	2012-09-07 21:26:05.694408
688	17	162	2012-09-07 21:26:05.701566	2012-09-07 21:26:05.701566
689	21	162	2012-09-07 21:26:05.707879	2012-09-07 21:26:05.707879
690	22	162	2012-09-07 21:26:05.71538	2012-09-07 21:26:05.71538
691	23	162	2012-09-07 21:26:05.722524	2012-09-07 21:26:05.722524
692	24	162	2012-09-07 21:26:05.728989	2012-09-07 21:26:05.728989
693	25	162	2012-09-07 21:26:05.735446	2012-09-07 21:26:05.735446
694	26	162	2012-09-07 21:26:05.741879	2012-09-07 21:26:05.741879
695	27	162	2012-09-07 21:26:05.748115	2012-09-07 21:26:05.748115
696	28	162	2012-09-07 21:26:05.753787	2012-09-07 21:26:05.753787
697	29	162	2012-09-07 21:26:05.761105	2012-09-07 21:26:05.761105
698	30	162	2012-09-07 21:26:05.767758	2012-09-07 21:26:05.767758
699	31	162	2012-09-07 21:26:05.773355	2012-09-07 21:26:05.773355
700	32	162	2012-09-07 21:26:05.778909	2012-09-07 21:26:05.778909
701	35	162	2012-09-07 21:26:05.785157	2012-09-07 21:26:05.785157
702	36	162	2012-09-07 21:26:05.791778	2012-09-07 21:26:05.791778
703	18	162	2012-09-07 21:26:05.800525	2012-09-07 21:26:05.800525
704	40	162	2012-09-07 21:26:05.806844	2012-09-07 21:26:05.806844
705	1	163	2012-09-08 04:37:00.659889	2012-09-08 04:37:00.659889
706	14	163	2012-09-08 04:37:00.674908	2012-09-08 04:37:00.674908
707	17	163	2012-09-08 04:37:00.682436	2012-09-08 04:37:00.682436
708	21	163	2012-09-08 04:37:00.689605	2012-09-08 04:37:00.689605
709	22	163	2012-09-08 04:37:00.697581	2012-09-08 04:37:00.697581
710	23	163	2012-09-08 04:37:00.704542	2012-09-08 04:37:00.704542
711	24	163	2012-09-08 04:37:00.711938	2012-09-08 04:37:00.711938
712	25	163	2012-09-08 04:37:00.718435	2012-09-08 04:37:00.718435
713	26	163	2012-09-08 04:37:00.72756	2012-09-08 04:37:00.72756
714	27	163	2012-09-08 04:37:00.734566	2012-09-08 04:37:00.734566
715	28	163	2012-09-08 04:37:00.741019	2012-09-08 04:37:00.741019
716	29	163	2012-09-08 04:37:00.748134	2012-09-08 04:37:00.748134
717	30	163	2012-09-08 04:37:00.754026	2012-09-08 04:37:00.754026
718	31	163	2012-09-08 04:37:00.760236	2012-09-08 04:37:00.760236
719	32	163	2012-09-08 04:37:00.767158	2012-09-08 04:37:00.767158
720	35	163	2012-09-08 04:37:00.772371	2012-09-08 04:37:00.772371
721	36	163	2012-09-08 04:37:00.779048	2012-09-08 04:37:00.779048
722	2	163	2012-09-08 04:37:00.787684	2012-09-08 04:37:00.787684
723	18	163	2012-09-08 04:37:00.79604	2012-09-08 04:37:00.79604
724	40	163	2012-09-08 04:37:00.803694	2012-09-08 04:37:00.803694
725	1	164	2012-09-09 08:04:04.8614	2012-09-09 08:04:04.8614
726	3	164	2012-09-09 08:04:04.872908	2012-09-09 08:04:04.872908
727	14	164	2012-09-09 08:04:04.880119	2012-09-09 08:04:04.880119
728	17	164	2012-09-09 08:04:04.887052	2012-09-09 08:04:04.887052
729	21	164	2012-09-09 08:04:04.893549	2012-09-09 08:04:04.893549
730	22	164	2012-09-09 08:04:04.901822	2012-09-09 08:04:04.901822
731	23	164	2012-09-09 08:04:04.908242	2012-09-09 08:04:04.908242
732	24	164	2012-09-09 08:04:04.915474	2012-09-09 08:04:04.915474
733	25	164	2012-09-09 08:04:04.921027	2012-09-09 08:04:04.921027
734	26	164	2012-09-09 08:04:04.927061	2012-09-09 08:04:04.927061
735	27	164	2012-09-09 08:04:04.933265	2012-09-09 08:04:04.933265
736	28	164	2012-09-09 08:04:04.938862	2012-09-09 08:04:04.938862
737	29	164	2012-09-09 08:04:04.944761	2012-09-09 08:04:04.944761
738	30	164	2012-09-09 08:04:04.951565	2012-09-09 08:04:04.951565
739	31	164	2012-09-09 08:04:04.957297	2012-09-09 08:04:04.957297
740	32	164	2012-09-09 08:04:04.96343	2012-09-09 08:04:04.96343
741	35	164	2012-09-09 08:04:04.969748	2012-09-09 08:04:04.969748
742	36	164	2012-09-09 08:04:04.97569	2012-09-09 08:04:04.97569
743	2	164	2012-09-09 08:04:04.982517	2012-09-09 08:04:04.982517
744	18	164	2012-09-09 08:04:04.988143	2012-09-09 08:04:04.988143
745	40	164	2012-09-09 08:04:04.994191	2012-09-09 08:04:04.994191
746	1	166	2012-09-10 01:44:49.637958	2012-09-10 01:44:49.637958
747	3	166	2012-09-10 01:44:49.649416	2012-09-10 01:44:49.649416
748	14	166	2012-09-10 01:44:49.655523	2012-09-10 01:44:49.655523
749	17	166	2012-09-10 01:44:49.66246	2012-09-10 01:44:49.66246
750	21	166	2012-09-10 01:44:49.668876	2012-09-10 01:44:49.668876
751	22	166	2012-09-10 01:44:49.675498	2012-09-10 01:44:49.675498
752	23	166	2012-09-10 01:44:49.681473	2012-09-10 01:44:49.681473
753	24	166	2012-09-10 01:44:49.687591	2012-09-10 01:44:49.687591
754	25	166	2012-09-10 01:44:49.692994	2012-09-10 01:44:49.692994
755	26	166	2012-09-10 01:44:49.69856	2012-09-10 01:44:49.69856
756	27	166	2012-09-10 01:44:49.705673	2012-09-10 01:44:49.705673
757	28	166	2012-09-10 01:44:49.712533	2012-09-10 01:44:49.712533
758	29	166	2012-09-10 01:44:49.721767	2012-09-10 01:44:49.721767
759	30	166	2012-09-10 01:44:49.728755	2012-09-10 01:44:49.728755
760	31	166	2012-09-10 01:44:49.73746	2012-09-10 01:44:49.73746
761	32	166	2012-09-10 01:44:49.745923	2012-09-10 01:44:49.745923
762	35	166	2012-09-10 01:44:49.753236	2012-09-10 01:44:49.753236
763	36	166	2012-09-10 01:44:49.759284	2012-09-10 01:44:49.759284
764	2	166	2012-09-10 01:44:49.765261	2012-09-10 01:44:49.765261
765	18	166	2012-09-10 01:44:49.883417	2012-09-10 01:44:49.883417
766	40	166	2012-09-10 01:44:49.889784	2012-09-10 01:44:49.889784
767	1	169	2012-09-11 02:15:23.549819	2012-09-11 02:15:23.549819
768	3	169	2012-09-11 02:15:23.561739	2012-09-11 02:15:23.561739
769	14	169	2012-09-11 02:15:23.56824	2012-09-11 02:15:23.56824
770	17	169	2012-09-11 02:15:23.576487	2012-09-11 02:15:23.576487
771	21	169	2012-09-11 02:15:23.582873	2012-09-11 02:15:23.582873
772	22	169	2012-09-11 02:15:23.590267	2012-09-11 02:15:23.590267
773	23	169	2012-09-11 02:15:23.596161	2012-09-11 02:15:23.596161
774	24	169	2012-09-11 02:15:23.602972	2012-09-11 02:15:23.602972
775	25	169	2012-09-11 02:15:23.611425	2012-09-11 02:15:23.611425
776	26	169	2012-09-11 02:15:23.621088	2012-09-11 02:15:23.621088
777	27	169	2012-09-11 02:15:23.629443	2012-09-11 02:15:23.629443
778	28	169	2012-09-11 02:15:23.636229	2012-09-11 02:15:23.636229
779	29	169	2012-09-11 02:15:23.642495	2012-09-11 02:15:23.642495
780	30	169	2012-09-11 02:15:23.649514	2012-09-11 02:15:23.649514
781	31	169	2012-09-11 02:15:23.655981	2012-09-11 02:15:23.655981
782	32	169	2012-09-11 02:15:23.6619	2012-09-11 02:15:23.6619
783	35	169	2012-09-11 02:15:23.668038	2012-09-11 02:15:23.668038
784	36	169	2012-09-11 02:15:23.673839	2012-09-11 02:15:23.673839
785	2	169	2012-09-11 02:15:23.680685	2012-09-11 02:15:23.680685
786	18	169	2012-09-11 02:15:23.687321	2012-09-11 02:15:23.687321
787	40	169	2012-09-11 02:15:23.693777	2012-09-11 02:15:23.693777
788	41	169	2012-09-11 02:15:23.699621	2012-09-11 02:15:23.699621
789	1	167	2012-09-11 04:24:49.966146	2012-09-11 04:24:49.966146
790	14	167	2012-09-11 04:24:49.978018	2012-09-11 04:24:49.978018
791	17	167	2012-09-11 04:24:49.984181	2012-09-11 04:24:49.984181
792	21	167	2012-09-11 04:24:49.99149	2012-09-11 04:24:49.99149
793	22	167	2012-09-11 04:24:49.998562	2012-09-11 04:24:49.998562
794	23	167	2012-09-11 04:24:50.005643	2012-09-11 04:24:50.005643
795	24	167	2012-09-11 04:24:50.011712	2012-09-11 04:24:50.011712
796	25	167	2012-09-11 04:24:50.019383	2012-09-11 04:24:50.019383
797	26	167	2012-09-11 04:24:50.025861	2012-09-11 04:24:50.025861
798	27	167	2012-09-11 04:24:50.031473	2012-09-11 04:24:50.031473
799	28	167	2012-09-11 04:24:50.037838	2012-09-11 04:24:50.037838
800	29	167	2012-09-11 04:24:50.15054	2012-09-11 04:24:50.15054
801	30	167	2012-09-11 04:24:50.158397	2012-09-11 04:24:50.158397
802	31	167	2012-09-11 04:24:50.164715	2012-09-11 04:24:50.164715
803	32	167	2012-09-11 04:24:50.172424	2012-09-11 04:24:50.172424
804	35	167	2012-09-11 04:24:50.178912	2012-09-11 04:24:50.178912
805	36	167	2012-09-11 04:24:50.185006	2012-09-11 04:24:50.185006
806	2	167	2012-09-11 04:24:50.190861	2012-09-11 04:24:50.190861
807	18	167	2012-09-11 04:24:50.19721	2012-09-11 04:24:50.19721
808	40	167	2012-09-11 04:24:50.204219	2012-09-11 04:24:50.204219
809	41	167	2012-09-11 04:24:50.21047	2012-09-11 04:24:50.21047
810	1	168	2012-09-11 04:25:23.363586	2012-09-11 04:25:23.363586
811	3	168	2012-09-11 04:25:23.371059	2012-09-11 04:25:23.371059
812	14	168	2012-09-11 04:25:23.377241	2012-09-11 04:25:23.377241
813	17	168	2012-09-11 04:25:23.384274	2012-09-11 04:25:23.384274
814	21	168	2012-09-11 04:25:23.390356	2012-09-11 04:25:23.390356
815	22	168	2012-09-11 04:25:23.396102	2012-09-11 04:25:23.396102
816	23	168	2012-09-11 04:25:23.403429	2012-09-11 04:25:23.403429
817	24	168	2012-09-11 04:25:23.409835	2012-09-11 04:25:23.409835
818	25	168	2012-09-11 04:25:23.416213	2012-09-11 04:25:23.416213
819	26	168	2012-09-11 04:25:23.422178	2012-09-11 04:25:23.422178
820	27	168	2012-09-11 04:25:23.42833	2012-09-11 04:25:23.42833
821	28	168	2012-09-11 04:25:23.435353	2012-09-11 04:25:23.435353
822	29	168	2012-09-11 04:25:23.442156	2012-09-11 04:25:23.442156
823	30	168	2012-09-11 04:25:23.450259	2012-09-11 04:25:23.450259
824	31	168	2012-09-11 04:25:23.457343	2012-09-11 04:25:23.457343
825	32	168	2012-09-11 04:25:23.463984	2012-09-11 04:25:23.463984
826	35	168	2012-09-11 04:25:23.470999	2012-09-11 04:25:23.470999
827	36	168	2012-09-11 04:25:23.478062	2012-09-11 04:25:23.478062
828	2	168	2012-09-11 04:25:23.484315	2012-09-11 04:25:23.484315
829	18	168	2012-09-11 04:25:23.490576	2012-09-11 04:25:23.490576
830	40	168	2012-09-11 04:25:23.496868	2012-09-11 04:25:23.496868
831	41	168	2012-09-11 04:25:23.503406	2012-09-11 04:25:23.503406
832	1	170	2012-09-11 04:26:37.163671	2012-09-11 04:26:37.163671
833	3	170	2012-09-11 04:26:37.172168	2012-09-11 04:26:37.172168
834	14	170	2012-09-11 04:26:37.179355	2012-09-11 04:26:37.179355
835	17	170	2012-09-11 04:26:37.185737	2012-09-11 04:26:37.185737
836	21	170	2012-09-11 04:26:37.192113	2012-09-11 04:26:37.192113
837	22	170	2012-09-11 04:26:37.198621	2012-09-11 04:26:37.198621
838	23	170	2012-09-11 04:26:37.204813	2012-09-11 04:26:37.204813
839	24	170	2012-09-11 04:26:37.210932	2012-09-11 04:26:37.210932
840	25	170	2012-09-11 04:26:37.21738	2012-09-11 04:26:37.21738
841	26	170	2012-09-11 04:26:37.223692	2012-09-11 04:26:37.223692
842	27	170	2012-09-11 04:26:37.229729	2012-09-11 04:26:37.229729
843	28	170	2012-09-11 04:26:37.23584	2012-09-11 04:26:37.23584
844	29	170	2012-09-11 04:26:37.242242	2012-09-11 04:26:37.242242
845	30	170	2012-09-11 04:26:37.24824	2012-09-11 04:26:37.24824
846	31	170	2012-09-11 04:26:37.255548	2012-09-11 04:26:37.255548
847	32	170	2012-09-11 04:26:37.262387	2012-09-11 04:26:37.262387
848	35	170	2012-09-11 04:26:37.27023	2012-09-11 04:26:37.27023
849	36	170	2012-09-11 04:26:37.276692	2012-09-11 04:26:37.276692
850	2	170	2012-09-11 04:26:37.28248	2012-09-11 04:26:37.28248
851	18	170	2012-09-11 04:26:37.289168	2012-09-11 04:26:37.289168
852	40	170	2012-09-11 04:26:37.294895	2012-09-11 04:26:37.294895
853	41	170	2012-09-11 04:26:37.301113	2012-09-11 04:26:37.301113
854	1	172	2012-09-15 01:54:07.472583	2012-09-15 01:54:07.472583
855	3	172	2012-09-15 01:54:07.488813	2012-09-15 01:54:07.488813
856	14	172	2012-09-15 01:54:07.496932	2012-09-15 01:54:07.496932
857	17	172	2012-09-15 01:54:07.504801	2012-09-15 01:54:07.504801
858	21	172	2012-09-15 01:54:07.51183	2012-09-15 01:54:07.51183
859	22	172	2012-09-15 01:54:07.520619	2012-09-15 01:54:07.520619
860	23	172	2012-09-15 01:54:07.528618	2012-09-15 01:54:07.528618
861	24	172	2012-09-15 01:54:07.536684	2012-09-15 01:54:07.536684
862	25	172	2012-09-15 01:54:07.544854	2012-09-15 01:54:07.544854
863	26	172	2012-09-15 01:54:07.552832	2012-09-15 01:54:07.552832
864	27	172	2012-09-15 01:54:07.561475	2012-09-15 01:54:07.561475
865	28	172	2012-09-15 01:54:07.569561	2012-09-15 01:54:07.569561
866	29	172	2012-09-15 01:54:07.577437	2012-09-15 01:54:07.577437
867	30	172	2012-09-15 01:54:07.585833	2012-09-15 01:54:07.585833
868	31	172	2012-09-15 01:54:07.594172	2012-09-15 01:54:07.594172
869	32	172	2012-09-15 01:54:07.602243	2012-09-15 01:54:07.602243
870	35	172	2012-09-15 01:54:07.609642	2012-09-15 01:54:07.609642
871	36	172	2012-09-15 01:54:07.617356	2012-09-15 01:54:07.617356
872	2	172	2012-09-15 01:54:07.625334	2012-09-15 01:54:07.625334
873	18	172	2012-09-15 01:54:07.631933	2012-09-15 01:54:07.631933
874	40	172	2012-09-15 01:54:07.638813	2012-09-15 01:54:07.638813
875	41	172	2012-09-15 01:54:07.646051	2012-09-15 01:54:07.646051
876	4	175	2012-09-17 20:13:16.508255	2012-09-17 20:13:16.508255
877	13	175	2012-09-17 20:13:16.525916	2012-09-17 20:13:16.525916
878	16	175	2012-09-17 20:13:16.538041	2012-09-17 20:13:16.538041
879	9	175	2012-09-17 20:13:16.549918	2012-09-17 20:13:16.549918
880	14	175	2012-09-17 20:13:16.560247	2012-09-17 20:13:16.560247
881	3	175	2012-09-17 20:13:16.57119	2012-09-17 20:13:16.57119
882	4	177	2012-09-18 02:28:01.895873	2012-09-18 02:28:01.895873
883	13	177	2012-09-18 02:28:01.909967	2012-09-18 02:28:01.909967
884	16	177	2012-09-18 02:28:01.916433	2012-09-18 02:28:01.916433
885	9	177	2012-09-18 02:28:01.922948	2012-09-18 02:28:01.922948
886	14	177	2012-09-18 02:28:01.928964	2012-09-18 02:28:01.928964
887	3	177	2012-09-18 02:28:01.935268	2012-09-18 02:28:01.935268
888	14	176	2012-09-18 02:35:46.592302	2012-09-18 02:35:46.592302
889	3	176	2012-09-18 02:35:46.605651	2012-09-18 02:35:46.605651
890	2	176	2012-09-18 02:35:46.61168	2012-09-18 02:35:46.61168
891	4	178	2012-09-18 03:24:17.472167	2012-09-18 03:24:17.472167
892	13	178	2012-09-18 03:24:17.481514	2012-09-18 03:24:17.481514
893	16	178	2012-09-18 03:24:17.489028	2012-09-18 03:24:17.489028
894	9	178	2012-09-18 03:24:17.495441	2012-09-18 03:24:17.495441
895	14	178	2012-09-18 03:24:17.501877	2012-09-18 03:24:17.501877
896	3	178	2012-09-18 03:24:17.508551	2012-09-18 03:24:17.508551
897	2	178	2012-09-18 03:24:17.515576	2012-09-18 03:24:17.515576
898	3	171	2012-09-18 03:47:57.676059	2012-09-18 03:47:57.676059
899	1	179	2012-09-18 03:59:16.133668	2012-09-18 03:59:16.133668
900	14	179	2012-09-18 03:59:16.142905	2012-09-18 03:59:16.142905
901	17	179	2012-09-18 03:59:16.151439	2012-09-18 03:59:16.151439
902	21	179	2012-09-18 03:59:16.15806	2012-09-18 03:59:16.15806
903	22	179	2012-09-18 03:59:16.166008	2012-09-18 03:59:16.166008
904	23	179	2012-09-18 03:59:16.173122	2012-09-18 03:59:16.173122
905	24	179	2012-09-18 03:59:16.180692	2012-09-18 03:59:16.180692
906	25	179	2012-09-18 03:59:16.187456	2012-09-18 03:59:16.187456
907	26	179	2012-09-18 03:59:16.194203	2012-09-18 03:59:16.194203
908	27	179	2012-09-18 03:59:16.20107	2012-09-18 03:59:16.20107
909	28	179	2012-09-18 03:59:16.207194	2012-09-18 03:59:16.207194
910	29	179	2012-09-18 03:59:16.213648	2012-09-18 03:59:16.213648
911	30	179	2012-09-18 03:59:16.220449	2012-09-18 03:59:16.220449
912	31	179	2012-09-18 03:59:16.227166	2012-09-18 03:59:16.227166
913	32	179	2012-09-18 03:59:16.233938	2012-09-18 03:59:16.233938
914	35	179	2012-09-18 03:59:16.24013	2012-09-18 03:59:16.24013
915	36	179	2012-09-18 03:59:16.246937	2012-09-18 03:59:16.246937
916	18	179	2012-09-18 03:59:16.253148	2012-09-18 03:59:16.253148
917	40	179	2012-09-18 03:59:16.259375	2012-09-18 03:59:16.259375
918	41	179	2012-09-18 03:59:16.266135	2012-09-18 03:59:16.266135
919	3	179	2012-09-18 03:59:16.274474	2012-09-18 03:59:16.274474
920	3	183	2012-09-18 10:04:41.568451	2012-09-18 10:04:41.568451
\.


--
-- Data for Name: discussion_read_logs; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY discussion_read_logs (id, user_id, created_at, updated_at, discussion_id, discussion_activity_when_last_read) FROM stdin;
41	3	2012-06-08 03:35:33.793261	2012-06-08 03:35:40.386217	26	0
68	3	2012-07-04 00:48:49.64912	2012-08-20 02:27:50.145742	39	0
39	14	2012-06-07 03:07:49.131282	2012-06-08 04:11:37.498223	26	0
43	2	2012-06-08 04:12:51.719124	2012-06-08 04:13:07.201349	28	0
42	3	2012-06-08 03:36:17.417375	2012-06-08 04:13:20.177791	28	0
58	3	2012-06-27 04:45:15.497203	2012-06-27 04:45:15.497203	33	0
59	3	2012-06-27 23:11:54.533316	2012-06-27 23:11:54.533316	34	0
60	3	2012-06-28 02:33:06.572782	2012-06-28 02:33:06.572782	35	0
5	1	2012-05-12 02:11:45.324233	2012-05-12 02:11:45.324233	3	0
6	1	2012-05-12 05:23:55.436267	2012-05-12 05:23:55.436267	4	0
75	3	2012-07-10 01:59:47.240843	2012-07-14 06:19:25.021586	42	0
40	3	2012-06-08 03:03:01.313038	2012-06-28 04:38:52.159968	27	0
46	14	2012-06-10 21:58:14.06782	2012-06-10 22:02:03.570737	29	0
1	1	2012-05-10 00:25:05.694924	2012-05-13 06:17:04.937489	1	0
28	14	2012-06-01 03:23:14.91729	2012-06-10 22:56:39.779572	11	0
8	1	2012-05-13 22:29:20.03512	2012-05-13 22:29:20.03512	5	0
2	1	2012-05-10 03:18:42.890418	2012-05-14 02:15:43.529197	2	0
10	1	2012-05-14 02:47:34.558653	2012-05-14 02:47:34.558653	7	0
9	1	2012-05-14 02:14:42.06238	2012-05-14 03:02:23.18394	6	0
48	2	2012-06-11 01:06:16.474942	2012-06-11 01:06:16.474942	10	0
61	14	2012-06-28 06:05:36.783881	2012-06-28 06:05:36.783881	32	0
32	14	2012-06-03 06:25:12.299216	2012-06-28 06:05:47.124111	6	0
14	3	2012-05-20 01:23:17.085977	2012-05-20 04:53:48.235894	10	0
62	14	2012-06-28 09:48:51.837011	2012-06-28 09:48:51.837011	3	0
7	2	2012-05-12 06:14:43.192514	2012-07-12 04:54:17.530128	3	0
63	3	2012-06-29 01:36:53.394058	2012-06-29 01:36:53.394058	5	0
15	4	2012-05-20 07:42:03.241577	2012-05-20 07:42:03.241577	10	0
50	3	2012-06-13 03:11:12.223349	2012-06-13 03:11:12.223349	7	0
17	4	2012-05-21 05:56:33.06103	2012-05-21 05:56:43.169888	11	0
13	4	2012-05-19 01:50:59.206375	2012-05-21 23:47:00.056031	9	0
23	3	2012-05-30 23:25:13.137734	2012-07-02 03:14:35.722588	16	0
52	3	2012-06-16 06:26:15.482918	2012-06-16 06:26:15.482918	30	0
11	3	2012-05-15 04:30:25.96974	2012-05-22 01:26:25.294548	8	0
18	4	2012-05-21 23:44:39.001904	2012-05-22 01:29:29.495986	8	0
64	2	2012-07-02 04:43:52.811541	2012-07-02 04:43:52.811541	20	0
53	3	2012-06-19 22:45:06.144202	2012-06-19 22:45:06.144202	19	0
12	3	2012-05-17 02:18:15.525099	2012-05-23 04:53:14.439934	9	0
19	3	2012-05-28 02:50:39.817994	2012-05-28 02:50:39.817994	12	0
20	3	2012-05-28 03:34:19.790816	2012-05-28 03:34:19.790816	13	0
22	3	2012-05-28 11:29:10.049437	2012-05-28 11:29:10.049437	15	0
24	2	2012-05-30 23:56:26.957294	2012-05-30 23:57:25.20872	17	0
25	14	2012-06-01 02:41:31.520966	2012-06-01 02:41:31.520966	14	0
26	14	2012-06-01 03:00:19.47752	2012-06-01 03:00:19.47752	18	0
27	14	2012-06-01 03:01:40.190524	2012-06-01 03:01:40.190524	19	0
51	2	2012-06-14 22:05:03.028326	2012-07-02 04:45:17.580242	16	0
30	3	2012-06-03 05:21:45.683068	2012-06-03 05:21:45.683068	1	0
56	2	2012-06-22 02:08:11.259239	2012-06-22 02:08:11.259239	9	0
34	14	2012-06-07 02:36:10.063996	2012-06-07 02:36:10.063996	21	0
35	14	2012-06-07 03:06:35.744842	2012-06-07 03:06:35.744842	22	0
36	14	2012-06-07 03:06:49.393118	2012-06-07 03:06:49.393118	23	0
37	14	2012-06-07 03:07:03.240685	2012-06-07 03:07:03.240685	24	0
38	14	2012-06-07 03:07:24.623062	2012-06-07 03:07:24.623062	25	0
33	3	2012-06-05 23:52:32.434929	2012-06-08 02:51:17.071119	20	0
31	3	2012-06-03 06:14:40.762735	2012-07-02 22:15:23.019169	2	0
65	3	2012-07-02 22:16:55.901361	2012-07-02 22:16:55.901361	36	0
90	3	2012-08-05 06:41:56.887324	2012-08-05 06:41:56.887324	53	0
66	3	2012-07-02 22:39:09.364222	2012-07-02 23:22:53.908655	37	0
67	3	2012-07-03 00:52:46.033032	2012-07-03 00:52:46.033032	38	0
4	2	2012-05-10 05:00:04.734467	2012-07-12 04:54:48.852693	1	0
70	3	2012-07-04 03:30:14.49735	2012-07-04 03:30:14.49735	18	0
87	18	2012-08-03 03:13:51.184649	2012-08-30 22:54:37.665629	49	0
49	3	2012-06-11 03:11:55.51593	2012-07-14 22:52:27.741044	3	0
57	2	2012-06-22 03:03:37.437977	2012-06-23 01:05:09.547343	32	0
55	3	2012-06-20 01:42:11.9649	2012-06-25 01:57:48.35275	32	0
81	3	2012-07-13 01:18:34.9682	2012-07-13 01:19:27.369352	47	0
72	2	2012-07-08 07:08:22.773164	2012-07-08 07:08:22.773164	29	0
73	3	2012-07-08 23:14:11.409514	2012-07-08 23:15:06.541452	41	0
3	2	2012-05-10 04:58:11.294866	2012-07-09 04:35:52.765507	2	0
74	2	2012-07-09 21:50:55.506373	2012-07-09 21:50:55.506373	38	0
82	3	2012-07-13 01:21:15.933294	2012-07-13 01:21:15.933294	48	0
54	3	2012-06-20 01:39:01.639106	2012-07-10 23:35:18.416493	31	0
91	3	2012-08-05 06:47:29.955664	2012-08-05 06:47:29.955664	55	0
83	2	2012-07-13 01:30:35.116866	2012-08-01 08:32:24.720113	42	0
86	2	2012-07-31 04:17:56.381753	2012-09-05 20:15:03.895875	46	0
88	18	2012-08-03 03:23:29.44535	2012-08-03 04:16:16.033009	50	0
76	3	2012-07-11 02:54:37.055448	2012-08-30 03:51:38.704353	43	0
97	3	2012-08-06 04:20:20.960691	2012-08-08 09:52:44.278082	67	0
84	14	2012-07-27 23:59:44.434511	2012-07-27 23:59:44.434511	37	0
89	3	2012-08-05 04:10:40.326468	2012-08-05 04:10:40.326468	51	0
93	3	2012-08-05 22:48:52.055929	2012-08-05 22:48:52.055929	62	0
94	3	2012-08-05 23:13:38.717158	2012-08-05 23:13:38.717158	64	0
95	3	2012-08-05 23:26:51.936255	2012-08-05 23:26:51.936255	65	0
98	3	2012-08-07 00:15:28.388858	2012-08-07 00:15:28.388858	69	0
100	3	2012-08-07 02:59:15.716226	2012-08-07 02:59:15.716226	70	0
102	36	2012-08-07 22:29:04.893352	2012-08-07 22:29:59.105849	44	0
77	3	2012-07-11 02:58:19.786579	2012-08-08 06:02:46.929211	44	0
103	2	2012-08-07 22:35:32.526008	2012-08-08 20:54:10.418358	66	0
99	3	2012-08-07 00:21:28.811238	2012-08-08 09:53:12.815208	68	0
104	2	2012-08-08 20:56:57.44013	2012-08-08 20:56:57.44013	71	0
92	3	2012-08-05 22:36:19.107784	2012-08-10 01:35:38.625589	61	0
85	14	2012-07-28 21:41:42.83561	2012-08-18 03:51:42.939899	43	0
69	3	2012-07-04 00:54:38.754339	2012-08-20 02:28:29.082337	40	0
71	2	2012-07-08 06:57:20.011233	2012-08-20 03:00:26.369205	31	0
79	3	2012-07-12 03:05:32.211968	2012-08-20 10:00:51.102171	46	0
105	3	2012-08-08 20:59:12.669291	2012-08-08 20:59:12.669291	72	0
106	3	2012-08-08 21:49:15.029302	2012-08-08 21:49:15.029302	71	0
96	3	2012-08-06 03:07:23.220199	2012-08-08 22:46:33.337128	66	0
171	40	2012-09-06 05:58:21.397694	2012-09-06 05:58:21.397694	73	0
16	3	2012-05-21 02:49:20.556714	2012-09-17 01:30:41.53549	11	0
78	3	2012-07-12 01:08:22.033032	2012-09-15 03:25:41.975294	45	0
101	2	2012-08-07 10:28:16.49883	2012-09-16 06:27:22.979712	50	0
163	2	2012-09-04 06:19:59.411302	2012-09-07 21:28:27.323663	90	0
107	3	2012-08-10 03:24:27.730818	2012-09-08 01:13:42.319812	73	0
109	3	2012-08-15 23:29:09.728322	2012-08-15 23:29:09.728322	74	0
112	3	2012-08-17 22:16:57.110459	2012-08-17 22:16:57.110459	60	0
113	14	2012-08-18 03:50:50.40294	2012-08-18 03:50:50.40294	73	0
114	14	2012-08-18 03:51:00.98387	2012-08-18 03:51:00.98387	74	0
115	14	2012-08-18 03:51:11.872673	2012-08-18 03:51:11.872673	75	0
116	14	2012-08-18 03:52:08.147841	2012-08-18 03:52:08.147841	66	0
117	14	2012-08-18 03:52:18.32043	2012-08-18 03:52:18.32043	44	0
118	14	2012-08-18 03:52:28.610883	2012-08-18 03:52:28.610883	46	0
119	14	2012-08-18 03:53:32.184069	2012-08-18 03:53:32.184069	42	0
120	14	2012-08-18 03:53:39.889599	2012-08-18 03:53:39.889599	16	0
110	3	2012-08-15 23:29:12.251337	2012-08-19 01:40:27.015701	75	0
122	39	2012-08-19 07:46:28.287717	2012-08-19 07:46:28.287717	73	0
80	2	2012-07-12 04:55:37.229168	2012-09-19 01:43:06.561587	44	6
44	2	2012-06-08 04:16:43.915055	2012-09-18 03:51:09.874434	6	4
21	3	2012-05-28 04:24:44.365468	2012-09-18 09:12:34.959487	14	2
160	18	2012-09-02 22:30:34.640938	2012-09-09 22:17:09.416409	78	0
123	39	2012-08-19 08:04:51.973808	2012-08-19 08:04:51.973808	6	0
121	39	2012-08-19 07:45:24.125695	2012-08-19 08:06:01.842884	46	0
124	39	2012-08-19 21:34:40.236814	2012-08-19 21:36:15.277924	40	0
125	39	2012-08-19 22:39:51.509837	2012-08-19 23:25:30.257244	39	0
126	2	2012-08-20 02:58:50.962999	2012-08-20 02:58:50.962999	13	0
128	2	2012-08-20 03:02:49.266195	2012-08-20 03:02:49.266195	19	0
129	2	2012-08-20 08:48:19.185172	2012-08-20 08:48:19.185172	72	0
130	2	2012-08-20 09:27:42.03308	2012-08-20 09:27:53.702122	76	0
111	2	2012-08-17 04:11:36.522926	2012-08-20 20:36:01.908028	75	0
131	2	2012-08-22 04:29:31.0072	2012-08-22 04:29:31.0072	77	0
132	2	2012-08-22 21:03:55.026724	2012-08-22 21:03:55.026724	33	0
133	2	2012-08-22 21:31:34.134846	2012-08-22 21:31:34.134846	74	0
135	2	2012-08-23 03:19:50.674374	2012-08-23 03:19:50.674374	79	0
138	3	2012-08-24 04:18:45.447025	2012-08-24 04:18:45.447025	82	0
139	3	2012-08-24 06:02:50.868785	2012-08-24 06:02:50.868785	83	0
140	14	2012-08-24 06:08:49.446151	2012-08-24 06:08:49.446151	85	0
141	2	2012-08-26 05:35:02.470223	2012-08-26 05:35:02.470223	8	0
142	2	2012-08-27 10:02:19.392199	2012-08-27 10:02:19.392199	86	0
143	2	2012-08-27 21:26:46.423543	2012-08-27 21:27:09.988918	49	0
144	3	2012-08-28 23:59:44.007542	2012-08-28 23:59:44.007542	78	0
145	2	2012-08-29 01:12:40.360139	2012-08-29 01:12:40.360139	47	0
146	2	2012-08-29 03:44:33.735301	2012-08-29 03:44:33.735301	27	0
148	3	2012-08-29 21:03:06.175516	2012-08-29 21:03:06.175516	4	0
149	3	2012-08-29 21:05:26.811755	2012-08-29 21:05:26.811755	87	0
152	18	2012-08-31 05:25:00.403915	2012-08-31 05:25:00.403915	79	0
154	3	2012-09-01 00:19:57.235237	2012-09-01 00:19:57.235237	91	0
155	3	2012-09-01 00:36:33.650156	2012-09-01 00:36:33.650156	92	0
156	18	2012-09-01 01:25:01.597944	2012-09-01 01:25:01.597944	75	0
158	18	2012-09-01 01:53:27.639363	2012-09-01 01:53:27.639363	91	0
157	18	2012-09-01 01:51:14.922359	2012-09-02 22:27:06.345162	73	0
159	18	2012-09-02 22:29:41.362691	2012-09-02 22:29:41.362691	74	0
162	18	2012-09-03 22:04:16.748708	2012-09-03 22:04:16.748708	66	0
161	18	2012-09-03 01:25:38.493211	2012-09-10 01:11:35.19136	89	0
174	18	2012-09-10 01:43:46.517406	2012-09-10 01:43:46.517406	90	0
134	2	2012-08-23 02:40:33.46772	2012-09-06 01:09:14.967096	78	0
166	2	2012-09-06 01:16:34.480358	2012-09-06 01:16:34.480358	93	0
108	2	2012-08-11 07:06:55.617173	2012-09-06 03:57:14.155968	73	0
167	2	2012-09-06 04:02:55.131823	2012-09-06 04:05:23.910863	94	0
168	40	2012-09-06 05:10:36.569215	2012-09-06 05:10:36.569215	4	0
169	40	2012-09-06 05:13:09.21369	2012-09-06 05:13:09.21369	95	0
170	40	2012-09-06 05:23:37.111671	2012-09-06 05:43:01.763669	89	0
179	3	2012-09-12 00:33:54.821425	2012-09-12 00:33:54.821425	99	0
173	3	2012-09-07 23:37:24.912216	2012-09-15 01:49:38.898189	90	0
176	3	2012-09-10 23:14:43.344851	2012-09-16 22:52:42.540218	96	0
136	3	2012-08-24 03:04:13.79314	2012-09-17 01:32:53.813024	80	0
47	3	2012-06-10 23:00:28.609845	2012-09-15 03:24:35.142229	29	0
182	3	2012-09-16 22:57:53.120148	2012-09-17 05:58:01.556522	21	0
180	3	2012-09-16 06:25:14.423842	2012-09-16 06:25:53.44852	100	0
177	3	2012-09-11 02:58:45.067848	2012-09-17 06:10:21.853238	97	0
137	3	2012-08-24 03:41:58.324111	2012-09-16 06:31:32.264177	81	0
150	2	2012-08-29 23:32:25.767513	2012-09-16 06:45:20.828525	81	0
172	3	2012-09-07 03:42:26.657054	2012-09-17 06:15:13.008602	94	0
165	2	2012-09-05 21:41:53.195729	2012-09-16 23:08:00.611445	80	0
181	2	2012-09-16 22:40:18.073968	2012-09-16 22:40:30.475807	96	0
183	2	2012-09-17 01:29:57.081085	2012-09-17 20:15:40.08251	14	0
147	2	2012-08-29 03:45:07.035997	2012-09-18 01:54:38.137813	21	2
45	2	2012-06-08 04:26:04.434774	2012-09-18 02:27:44.53711	11	5
127	2	2012-08-20 02:59:18.273203	2012-09-18 03:20:49.865584	45	2
29	3	2012-06-03 05:15:43.484555	2012-09-18 03:59:09.17618	6	4
153	3	2012-09-01 00:01:04.359209	2012-09-18 04:21:05.816219	89	5
175	3	2012-09-10 21:47:35.944061	2012-09-18 09:11:19.133671	88	2
178	3	2012-09-12 00:11:12.594612	2012-09-18 09:19:11.253762	98	1
164	2	2012-09-05 09:28:33.094354	2012-09-19 01:29:21.23151	89	7
151	2	2012-08-30 00:07:21.299069	2012-09-19 01:30:30.79549	88	3
\.


--
-- Data for Name: discussions; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY discussions (id, group_id, author_id, created_at, updated_at, title, activity, last_comment_at, description, has_current_motion) FROM stdin;
33	1	3	2012-06-27 04:45:14.733076	2012-07-17 05:25:17.456878	This is quite  LONG DISCUSSION TITLE LONG DISCUSSION TITLE LONG DISCUSSION TITLE LONG DISCUSSION TITLE LONG DISCUSSION TITLE LONG DISCUSSION TITLE	0	2012-06-27 04:45:14.733076	\N	f
9	3	3	2012-05-17 02:18:15.041542	2012-07-17 05:25:17.478102	test no close date	11	2012-05-17 02:18:15.041542	\N	f
34	24	3	2012-06-27 23:11:53.574333	2012-07-17 05:25:17.485429	This is a cute discussion	0	2012-06-27 23:11:53.574333	\N	f
35	22	3	2012-06-28 02:33:05.691169	2012-07-17 05:25:17.492881	New I am...Shinney	0	2012-06-28 02:33:05.691169	\N	f
15	3	3	2012-04-28 11:29:09.533796	2012-07-17 05:25:17.500173	11:25 comment	0	2012-04-28 11:29:09.533796	\N	f
13	3	3	2012-04-28 03:34:19.251911	2012-07-17 05:25:17.507721	less than one minute	0	2012-04-28 03:34:19.251911	\N	f
31	3	3	2012-06-20 01:39:01.096505	2012-07-17 05:25:17.533693	sdas	6	2012-07-07 07:56:06.927816	\N	f
28	11	3	2012-06-08 03:36:16.776899	2012-07-17 05:25:17.541602	dfaf	2	2012-06-08 03:36:16.776899	\N	f
47	11	3	2012-07-13 01:18:33.63714	2012-07-17 05:25:17.566165	new proposal!	1	2012-07-13 01:18:33.63714	\N	f
12	3	3	2012-04-28 02:50:39.24301	2012-07-17 05:25:17.574208	new discussion	0	2012-04-28 02:50:39.24301	\N	f
27	1	3	2012-06-08 03:03:00.691006	2012-07-17 05:25:17.583456	jnfkjhhiusahdfiuhasicuhsaiuhc,kn oihdiash9cdy oisdp8asyd98asyn oidosauc98sauc	2	2012-06-28 04:38:51.297283	\N	f
4	2	1	2012-05-12 05:23:54.603623	2012-07-17 05:25:17.596376	Heven pizza?	1	2012-05-12 05:23:54.640185	\N	f
48	11	3	2012-07-13 01:21:14.65778	2012-07-17 05:25:17.603636	no close date!	0	2012-07-13 01:21:14.65778	\N	f
44	1	3	2012-07-11 02:58:18.725322	2012-08-07 22:29:58.115733	I am from the groups page	6	2012-08-07 22:29:58.089735	\N	f
7	1	1	2012-05-14 02:47:33.945391	2012-07-17 05:25:17.612945	I want to see a flash	1	2012-05-14 02:47:33.975295	\N	f
30	14	3	2012-06-16 06:26:14.874491	2012-07-17 05:25:17.629632	sdkjasdjafaiuhefiuahefiuahiuahiuhaiuwheiuhiuaweiuwahiuhwe	1	2012-06-16 06:26:14.971351	\N	f
42	1	3	2012-07-10 01:59:45.517354	2012-07-17 05:25:17.63739	I am new	2	2012-07-10 01:59:45.517354	\N	f
10	3	3	2012-05-20 01:23:16.457082	2012-07-17 05:25:17.655782	new discussion for proposals	3	2012-05-20 01:23:16.484455	\N	f
3	1	1	2012-05-12 02:11:44.505107	2012-07-17 05:25:17.672121	Cop shows on TV	9	2012-06-11 05:10:12.749022	\N	f
32	1	3	2012-06-20 01:42:11.45887	2012-07-17 05:25:17.698397	daasas	6	2012-06-23 01:05:08.791483	\N	f
8	3	3	2012-05-15 04:30:25.36521	2012-07-17 05:25:17.70809	my new discussion	5	2012-05-15 04:30:25.395829	\N	f
18	3	14	2012-06-01 03:00:18.91577	2012-07-17 05:25:17.76549	00 message	0	2012-06-01 03:00:18.91577	\N	f
19	3	14	2012-06-01 03:01:39.548204	2012-07-17 05:25:17.773147	01n message	0	2012-06-01 03:01:39.548204	\N	f
1	1	1	2012-05-09 23:02:46.081509	2012-07-17 05:25:17.782053	Big trouble	7	2012-05-10 03:50:44.645232	\N	f
5	1	1	2012-05-13 22:29:19.43718	2012-07-17 05:25:17.789338	no proposal here	0	2012-05-13 22:29:19.43718	\N	f
16	1	3	2012-05-30 23:25:12.580976	2012-07-17 05:25:17.807569	new discussion time test	7	2012-06-29 01:36:12.644961	\N	f
22	18	14	2012-06-07 03:06:35.12453	2012-07-17 05:25:17.826748	Disc A	0	2012-06-07 03:06:35.12453	\N	f
23	18	14	2012-06-07 03:06:48.755244	2012-07-17 05:25:17.835132	Disc B	0	2012-06-07 03:06:48.755244	\N	f
24	18	14	2012-06-07 03:07:02.623926	2012-07-17 05:25:17.843659	Disc C	0	2012-06-07 03:07:02.623926	\N	f
25	17	14	2012-06-07 03:07:23.952226	2012-07-17 05:25:17.851848	Parent Disc	0	2012-06-07 03:07:23.952226	\N	f
20	1	3	2012-06-05 23:52:31.716267	2012-07-17 05:25:17.860994	second motion	3	2012-06-06 01:17:44.393384	\N	f
2	1	1	2012-05-10 03:06:10.329892	2012-07-17 05:25:17.869696	Lets dine out?	11	2012-05-12 07:38:56.312613	\N	f
26	18	14	2012-06-07 03:07:48.439107	2012-07-17 05:25:17.878169	Disc D	2	2012-06-07 03:07:48.439107	\N	f
36	21	3	2012-07-02 22:16:54.656779	2012-07-17 05:25:17.885805	Is it working yet? or is it bollocks?	0	2012-07-02 22:16:54.656779	\N	f
37	25	3	2012-07-02 22:39:08.235369	2012-07-17 05:25:17.895485	Sub of devastation	2	2012-07-02 22:39:08.273304	\N	f
38	27	3	2012-07-03 00:52:44.618927	2012-07-17 05:25:17.904016	show me a proposal	0	2012-07-03 00:52:44.618927	\N	f
41	20	3	2012-07-08 23:14:10.303605	2012-07-17 05:25:17.926715	Pain in the ass	1	2012-07-08 23:14:10.303605	\N	f
79	8	2	2012-08-23 03:19:49.556323	2012-08-23 03:19:49.556323	Take Ten	0	2012-08-23 03:19:49.556323	\N	f
63	56	3	2012-08-05 23:12:58.775026	2012-08-05 23:12:58.775026	Welcome and Introduction to Loomio!	0	2012-08-05 23:12:58.775026	\N	f
71	37	2	2012-08-08 20:56:56.421704	2012-08-08 20:56:56.421704	notorioua notifications	0	2012-08-08 20:56:56.421704	\N	f
51	33	3	2012-08-05 04:10:38.993559	2012-08-05 04:10:38.993559	hi no comment	0	2012-08-05 04:10:38.993559	\N	f
52	44	3	2012-08-05 06:39:19.592525	2012-08-05 06:39:19.592525	Welcome and Introduction to Loomio!	0	2012-08-05 06:39:19.592525	\N	f
53	45	3	2012-08-05 06:41:43.224561	2012-08-05 06:41:43.224561	Welcome and Introduction to Loomio!	0	2012-08-05 06:41:43.224561	\N	f
54	46	3	2012-08-05 06:46:40.181941	2012-08-05 06:46:40.181941	Welcome and Introduction to Loomio!	0	2012-08-05 06:46:40.181941	\N	f
55	47	3	2012-08-05 06:47:13.155752	2012-08-05 06:47:13.237304	Welcome and Introduction to Loomio!	1	2012-08-05 06:47:13.200266	\N	f
72	37	3	2012-08-08 20:59:11.657777	2012-08-08 20:59:11.657777	peep show	0	2012-08-08 20:59:11.657777	\N	f
56	48	3	2012-08-05 06:57:23.942817	2012-08-05 06:57:24.016584	Welcome and Introduction to Loomio!	1	2012-08-05 06:57:23.98508	\N	f
57	49	3	2012-08-05 06:58:14.451787	2012-08-05 06:58:14.521829	Welcome and Introduction to Loomio!	1	2012-08-05 06:58:14.493598	\N	f
58	50	3	2012-08-05 06:59:12.989532	2012-08-05 06:59:13.063191	Welcome and Introduction to Loomio!	1	2012-08-05 06:59:13.032258	\N	f
59	51	3	2012-08-05 07:06:12.627469	2012-08-05 07:06:12.675661	Welcome and Introduction to Loomio!	1	2012-08-05 07:06:12.655984	\N	f
60	52	3	2012-08-05 20:32:05.34177	2012-08-05 20:32:05.401404	Welcome and Introduction to Loomio!	1	2012-08-05 20:32:05.374484	\N	f
14	3	3	2012-05-27 23:24:43.882769	2012-09-18 09:12:34.727296	another newbie	2	2012-09-18 09:12:34.702655	\N	f
74	1	3	2012-08-15 23:29:08.406123	2012-08-15 23:29:08.406123	no comment	0	2012-08-15 23:29:08.406123	\N	f
82	70	34	2012-08-24 04:18:24.788321	2012-08-24 04:18:24.84311	Welcome and Introduction to Loomio!	1	2012-08-24 04:18:24.820067	\N	f
83	71	34	2012-08-24 06:02:30.558167	2012-08-24 06:02:30.649215	Welcome and Introduction to Loomio!	1	2012-08-24 06:02:30.61514	\N	f
84	72	34	2012-08-24 06:06:34.269154	2012-08-24 06:06:34.319494	Welcome and Introduction to Loomio!	1	2012-08-24 06:06:34.302101	\N	f
45	3	3	2012-07-12 01:08:20.264098	2012-09-15 03:25:40.817753	chew that cud	2	2012-09-15 03:25:40.804539	\N	f
85	73	34	2012-08-24 06:06:37.248647	2012-08-24 06:06:37.367181	Welcome and Introduction to Loomio!	1	2012-08-24 06:06:37.350434	\N	f
49	8	18	2012-08-03 03:13:50.384471	2012-09-03 03:52:55.210688	new!	3	2012-08-27 21:27:08.376968	\N	f
87	29	3	2012-08-29 21:05:24.942414	2012-08-29 21:24:26.612324	Lets get out of here	0	2012-08-29 21:05:24.942414	\N	f
86	80	33	2012-08-26 02:45:42.460507	2012-08-26 02:45:42.806902	Welcome and Introduction to Loomio!	1	2012-08-26 02:45:42.513567	\N	f
50	8	18	2012-08-03 03:23:28.513248	2012-09-16 06:27:21.872334	one motion after another and another	1	2012-09-16 06:27:21.85905	\N	f
81	7	3	2012-08-24 03:41:57.223131	2012-09-16 06:45:19.748677	nvbdsdsvjds	0	2012-09-16 06:45:19.731289	\N	f
29	15	14	2012-06-10 21:58:13.464766	2012-09-15 03:24:33.945065	gob smacked	5	2012-09-15 03:24:33.930497	\N	f
80	3	3	2012-08-24 03:04:12.584247	2012-09-16 23:07:59.556903	Not positive	0	2012-09-16 23:07:59.544403	\N	f
6	1	1	2012-05-14 02:14:41.564171	2012-09-18 03:51:09.743652	Another new discussion	4	2012-09-18 03:51:09.636453	\N	f
11	3	3	2012-05-21 02:49:19.995519	2012-09-17 21:01:27.792428	new	5	2012-09-17 01:28:55.739344	\N	t
88	3	2	2012-08-30 00:07:19.489542	2012-09-19 01:30:30.624712	Sitting on the fence	3	2012-09-19 01:30:30.586503	\N	f
66	1	3	2012-08-06 03:07:21.653402	2012-08-08 20:54:09.382288	new fish	6	2012-08-08 20:52:46.46336	\N	f
62	54	3	2012-08-05 22:48:39.488271	2012-08-20 04:13:27.217145	Welcome and Introduction to Loomio!	1	2012-08-05 22:48:39.516111	\N	t
64	57	3	2012-08-05 23:13:25.791657	2012-08-20 04:13:27.230969	Welcome and Introduction to Loomio!	1	2012-08-05 23:13:25.818723	\N	t
61	53	3	2012-08-05 22:35:58.982984	2012-08-20 04:13:27.238538	Welcome and Introduction to Loomio!	2	2012-08-05 22:35:59.009597	\N	t
65	58	3	2012-08-05 23:26:39.69849	2012-08-20 04:13:27.241663	Welcome and Introduction to Loomio!	1	2012-08-05 23:26:39.799959	\N	t
69	65	34	2012-08-07 00:13:04.210423	2012-08-20 04:13:27.253114	Welcome and Introduction to Loomio!	1	2012-08-07 00:13:04.342965	\N	t
67	59	3	2012-08-06 04:20:05.569435	2012-08-20 04:13:27.270536	Welcome and Introduction to Loomio!	2	2012-08-06 04:20:05.599931	\N	t
99	83	34	2012-09-12 00:32:28.298038	2012-09-12 00:32:28.758163	Welcome and Introduction to Loomio!	1	2012-09-12 00:32:28.332065	\N	f
40	23	3	2012-07-04 00:54:38.01738	2012-08-24 01:11:42.023892	Comments?	1	2012-07-04 00:54:38.01738	\N	f
39	23	3	2012-07-04 00:48:48.845717	2012-08-24 01:13:57.137308	Hi there	1	2012-07-04 00:48:48.845717	\N	f
76	11	2	2012-08-20 09:27:40.035011	2012-08-20 09:27:52.016054	The new z	1	2012-08-20 09:27:51.976406	\N	f
68	60	3	2012-08-06 05:16:29.564333	2012-08-24 21:22:37.531442	Welcome and Introduction to Loomio!	2	2012-08-06 05:16:29.593058	\N	f
75	1	3	2012-08-15 23:29:11.064171	2012-08-25 22:03:08.634277	no comment	1	2012-08-15 23:29:11.064171	\N	f
95	81	34	2012-09-06 05:11:51.101482	2012-09-06 05:11:51.507626	Welcome and Introduction to Loomio!	1	2012-09-06 05:11:51.153754	\N	f
77	68	34	2012-08-22 04:29:10.889213	2012-08-22 04:29:10.946513	Welcome and Introduction to Loomio!	1	2012-08-22 04:29:10.922442	\N	f
73	1	3	2012-08-10 03:24:25.858588	2012-09-07 21:26:05.820942	Friday drinks are calling	11	2012-09-06 03:57:12.032776	\N	f
78	1	2	2012-08-23 02:40:32.205487	2012-09-06 01:09:13.267951	mr D	1	2012-09-06 01:09:13.229024	keep cool, we got to do some work, then we can party.  Deadline is ...\r\n\r\n\r\njhhgguy	f
93	76	2	2012-09-06 01:16:33.018225	2012-09-06 01:16:33.018225	We should do this	0	2012-09-06 01:16:33.018225		f
97	82	34	2012-09-11 02:57:38.287429	2012-09-11 02:57:38.482128	Welcome and Introduction to Loomio!	1	2012-09-11 02:57:38.317593	\N	f
70	66	34	2012-08-07 02:59:06.620231	2012-08-20 04:13:27.257609	Welcome and Introduction to Loomio!	1	2012-08-07 02:59:06.648772	\N	f
89	1	3	2012-09-01 00:01:03.154748	2012-09-19 01:29:20.836729	too sunny	7	2012-09-19 01:29:20.8034	shin'n bright	f
90	1	3	2012-09-01 00:19:25.755541	2012-09-14 03:08:29.041927	viva la porca el quatro queso	1	2012-09-07 21:28:26.215312	por que?\r\nloco?	f
91	1	3	2012-09-01 00:19:55.359648	2012-09-04 23:02:06.419439	blah	0	2012-09-01 00:19:55.359648	testing the vapour now	f
98	63	3	2012-09-12 00:11:11.538436	2012-09-15 01:54:07.72108	spotty potty totty	1	2012-09-12 00:12:48.786433	dripping with goodness inside	f
92	25	3	2012-09-01 00:36:31.977432	2012-09-05 03:10:09.997232	Hey baby	0	2012-09-01 00:36:31.977432	hellllloosdafsadfdsa  sfsafasd what happnes now\r\nu\r\ntjos os gpomg abefore \r\n\r\nu\r\nwhat if we've got heaps of comments?\r\n\r\n\r\nthis thing could get quite messy and long...\r\n\r\nI reckonygiygiuyg7ugog\r\n\r\n\r\n\r\n\r\n\r\nvdsfvsdfvdsfv	f
46	1	3	2012-07-12 03:05:30.672032	2012-09-05 20:15:53.624787	Stay open please	6	2012-09-05 20:15:02.209862	After school is when i need to buy it	f
100	9	3	2012-09-16 06:25:13.278274	2012-09-16 06:25:52.427803	Anything at all	0	2012-09-16 06:25:52.412781	I love talking	f
43	25	3	2012-07-11 02:54:36.204146	2012-09-03 22:08:45.861544	lookin hard for it	6	2012-08-30 03:51:37.455249	\N	f
96	1	3	2012-09-10 23:14:42.179479	2012-09-16 22:52:40.903137	cdcd	0	2012-09-16 22:52:40.887982	acasdca	f
94	1	2	2012-09-06 04:02:53.406998	2012-09-16 22:53:12.60136	Reverse cronology	4	2012-09-16 22:53:12.587631	This is a spec up to give the developer an idea of what is required for this feature.	f
21	16	14	2012-06-07 02:36:09.41853	2012-09-18 01:54:36.640882	Sub group discussion #1	2	2012-09-18 01:54:36.609023	\N	f
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY events (id, kind, created_at, updated_at, eventable_id, eventable_type, user_id) FROM stdin;
1	new_vote	2012-08-08 09:52:43.313392	2012-08-08 09:52:43.313392	68	Vote	\N
2	new_vote	2012-08-08 09:53:11.845702	2012-08-08 09:53:11.845702	69	Vote	\N
3	new_comment	2012-08-08 20:52:46.510077	2012-08-08 20:52:46.510077	69	Comment	\N
4	new_vote	2012-08-08 20:54:09.408299	2012-08-08 20:54:09.408299	70	Vote	\N
5	user_added_to_group	2012-08-08 20:55:12.042224	2012-08-08 20:55:12.042224	146	Membership	\N
6	new_motion	2012-08-08 20:58:33.249982	2012-08-08 20:58:33.249982	128	Motion	\N
7	new_discussion	2012-08-08 20:59:11.709184	2012-08-08 20:59:11.709184	72	Discussion	\N
8	new_vote	2012-08-10 01:35:37.748942	2012-08-10 01:35:37.748942	71	Vote	\N
9	new_vote	2012-08-11 07:07:23.311688	2012-08-11 07:07:23.311688	72	Vote	\N
10	new_vote	2012-08-11 07:29:27.286307	2012-08-11 07:29:27.286307	73	Vote	\N
11	new_motion	2012-08-13 02:46:28.637815	2012-08-13 02:46:28.637815	130	Motion	\N
12	motion_blocked	2012-08-13 02:47:47.682158	2012-08-13 02:47:47.682158	74	Vote	\N
13	new_vote	2012-08-13 03:56:20.504811	2012-08-13 03:56:20.504811	75	Vote	\N
14	new_vote	2012-08-13 04:16:15.724683	2012-08-13 04:16:15.724683	76	Vote	\N
15	new_vote	2012-08-13 04:21:52.635277	2012-08-13 04:21:52.635277	77	Vote	\N
16	new_vote	2012-08-13 04:40:44.431532	2012-08-13 04:40:44.431532	78	Vote	\N
17	new_comment	2012-08-14 01:19:55.984423	2012-08-14 01:19:55.984423	70	Comment	\N
18	new_comment	2012-08-14 02:57:49.054082	2012-08-14 02:57:49.054082	71	Comment	\N
19	new_discussion	2012-08-15 23:29:08.55657	2012-08-15 23:29:08.55657	74	Discussion	\N
20	new_discussion	2012-08-15 23:29:11.115028	2012-08-15 23:29:11.115028	75	Discussion	\N
21	new_vote	2012-08-16 00:11:50.908179	2012-08-16 00:11:50.908179	83	Vote	\N
22	new_motion	2012-08-17 04:10:00.557737	2012-08-17 04:10:00.557737	131	Motion	\N
23	new_motion	2012-08-19 01:39:43.45026	2012-08-19 01:39:43.45026	132	Motion	\N
24	new_vote	2012-08-19 01:40:26.003941	2012-08-19 01:40:26.003941	84	Vote	\N
26	new_motion	2012-08-19 07:45:56.821164	2012-08-19 07:45:56.821164	133	Motion	\N
27	new_motion	2012-08-19 07:47:03.351492	2012-08-19 07:47:03.351492	134	Motion	\N
30	membership_requested	2012-08-19 21:26:25.434137	2012-08-19 21:26:25.434137	149	Membership	\N
31	user_added_to_group	2012-08-19 21:31:16.163441	2012-08-19 21:31:16.163441	150	Membership	\N
32	new_motion	2012-08-19 21:35:50.549005	2012-08-19 21:35:50.549005	135	Motion	\N
33	new_vote	2012-08-19 21:36:13.754505	2012-08-19 21:36:13.754505	87	Vote	\N
34	new_motion	2012-08-19 21:37:35.620581	2012-08-19 21:37:35.620581	136	Motion	\N
35	new_motion	2012-08-19 22:40:29.765118	2012-08-19 22:40:29.765118	137	Motion	\N
36	new_vote	2012-08-19 23:25:28.818112	2012-08-19 23:25:28.818112	88	Vote	\N
37	new_motion	2012-08-20 09:27:40.39873	2012-08-20 09:27:40.39873	138	Motion	\N
38	new_comment	2012-08-20 09:27:52.047868	2012-08-20 09:27:52.047868	72	Comment	\N
39	user_added_to_group	2012-08-20 09:29:36.454988	2012-08-20 09:29:36.454988	151	Membership	\N
40	new_vote	2012-08-20 09:30:35.157139	2012-08-20 09:30:35.157139	89	Vote	\N
41	new_motion	2012-08-22 10:15:59.562086	2012-08-22 10:15:59.562086	140	Motion	\N
42	new_motion	2012-08-22 21:32:18.448487	2012-08-22 21:32:18.448487	141	Motion	\N
43	new_vote	2012-08-22 21:32:56.94257	2012-08-22 21:32:56.94257	90	Vote	\N
44	new_vote	2012-08-22 21:38:14.974626	2012-08-22 21:38:14.974626	91	Vote	\N
45	new_discussion	2012-08-23 02:40:32.343272	2012-08-23 02:40:32.343272	78	Discussion	\N
46	new_discussion	2012-08-23 03:19:49.679455	2012-08-23 03:19:49.679455	79	Discussion	\N
47	new_discussion	2012-08-24 03:04:12.739859	2012-08-24 03:04:12.739859	80	Discussion	\N
48	new_discussion	2012-08-24 03:41:57.284457	2012-08-24 03:41:57.284457	81	Discussion	\N
49	new_vote	2012-08-24 06:03:55.830564	2012-08-24 06:03:55.830564	92	Vote	\N
50	user_added_to_group	2012-08-24 06:08:13.537763	2012-08-24 06:08:13.537763	163	Membership	\N
51	new_motion	2012-08-24 21:09:28.121159	2012-08-24 21:09:28.121159	146	Motion	\N
52	new_vote	2012-08-24 21:09:46.29593	2012-08-24 21:09:46.29593	94	Vote	\N
53	new_motion	2012-08-27 00:46:31.826139	2012-08-27 00:46:31.826139	148	Motion	\N
54	new_vote	2012-08-27 00:47:08.204087	2012-08-27 00:47:08.204087	95	Vote	\N
55	motion_blocked	2012-08-27 10:02:34.421802	2012-08-27 10:02:34.421802	96	Vote	\N
56	new_comment	2012-08-27 10:03:09.244795	2012-08-27 10:03:09.244795	79	Comment	\N
57	new_comment	2012-08-27 21:27:08.445972	2012-08-27 21:27:08.445972	80	Comment	\N
60	new_motion	2012-08-29 01:14:38.679478	2012-08-29 01:14:38.679478	149	Motion	\N
61	new_vote	2012-08-29 01:15:01.407931	2012-08-29 01:15:01.407931	97	Vote	\N
64	new_motion	2012-08-29 05:03:00.553839	2012-08-29 05:03:00.553839	150	Motion	\N
66	new_motion	2012-08-29 05:08:43.257805	2012-08-29 05:08:43.257805	151	Motion	\N
68	new_discussion	2012-08-29 21:05:25.0332	2012-08-29 21:05:25.0332	87	Discussion	\N
69	new_motion	2012-08-29 21:07:01.064562	2012-08-29 21:07:01.064562	152	Motion	\N
71	new_motion	2012-08-29 21:17:23.273968	2012-08-29 21:17:23.273968	153	Motion	\N
73	new_motion	2012-08-29 21:27:51.321178	2012-08-29 21:27:51.321178	154	Motion	\N
74	new_discussion	2012-08-30 00:07:19.581724	2012-08-30 00:07:19.581724	88	Discussion	\N
75	new_comment	2012-08-30 03:51:37.510042	2012-08-30 03:51:37.510042	81	Comment	\N
76	new_motion	2012-08-30 09:48:59.225682	2012-08-30 09:48:59.225682	155	Motion	\N
78	new_motion	2012-08-30 20:13:30.654331	2012-08-30 20:13:30.654331	156	Motion	\N
79	new_motion	2012-08-30 22:50:09.626966	2012-08-30 22:50:09.626966	157	Motion	\N
80	new_motion	2012-08-31 01:21:18.591631	2012-08-31 01:21:18.591631	158	Motion	\N
81	new_discussion	2012-09-01 00:01:03.209658	2012-09-01 00:01:03.209658	89	Discussion	\N
82	new_discussion	2012-09-01 00:19:25.965999	2012-09-01 00:19:25.965999	90	Discussion	\N
83	new_discussion	2012-09-01 00:19:55.435356	2012-09-01 00:19:55.435356	91	Discussion	\N
84	new_discussion	2012-09-01 00:36:32.056968	2012-09-01 00:36:32.056968	92	Discussion	\N
85	user_added_to_group	2012-09-01 00:38:14.076076	2012-09-01 00:38:14.076076	172	Membership	\N
86	new_comment	2012-09-02 22:27:04.401102	2012-09-02 22:27:04.401102	82	Comment	\N
87	new_motion	2012-09-02 23:56:51.603516	2012-09-02 23:56:51.603516	159	Motion	\N
89	new_motion	2012-09-04 03:14:21.176324	2012-09-04 03:14:21.176324	160	Motion	\N
91	new_motion	2012-09-04 03:28:17.864472	2012-09-04 03:28:17.864472	161	Motion	\N
92	new_vote	2012-09-04 03:28:39.621125	2012-09-04 03:28:39.621125	98	Vote	\N
94	new_motion	2012-09-04 06:16:06.910848	2012-09-04 06:16:06.910848	162	Motion	\N
95	new_vote	2012-09-04 06:16:23.158468	2012-09-04 06:16:23.158468	99	Vote	\N
96	new_motion	2012-09-05 03:24:16.054894	2012-09-05 03:24:16.054894	163	Motion	\N
97	new_comment	2012-09-05 20:15:02.283488	2012-09-05 20:15:02.283488	83	Comment	\N
98	new_comment	2012-09-05 22:25:19.103762	2012-09-05 22:25:19.103762	84	Comment	\N
58	motion_closed	2012-08-28 23:57:16.880457	2012-09-05 22:59:06.595059	126	Motion	34
59	motion_closed	2012-08-29 00:08:13.202042	2012-09-05 22:59:06.596883	148	Motion	2
62	motion_closed	2012-08-29 03:28:46.852626	2012-09-05 22:59:06.597977	147	Motion	33
63	motion_closed	2012-08-29 05:01:50.658308	2012-09-05 22:59:06.598991	149	Motion	3
65	motion_closed	2012-08-29 05:05:09.462182	2012-09-05 22:59:06.600458	150	Motion	3
67	motion_closed	2012-08-29 05:13:37.848972	2012-09-05 22:59:06.601755	151	Motion	3
70	motion_closed	2012-08-29 21:08:33.228229	2012-09-05 22:59:06.602973	152	Motion	3
72	motion_closed	2012-08-29 21:24:26.648928	2012-09-05 22:59:06.604606	153	Motion	3
77	motion_closed	2012-08-30 20:07:02.936758	2012-09-05 22:59:06.605795	155	Motion	3
88	motion_closed	2012-09-03 01:24:55.164312	2012-09-05 22:59:06.606888	159	Motion	18
90	motion_closed	2012-09-04 03:23:55.173919	2012-09-05 22:59:06.607908	160	Motion	3
93	motion_closed	2012-09-04 06:07:38.871492	2012-09-05 22:59:06.60888	161	Motion	3
99	new_comment	2012-09-06 01:09:13.302319	2012-09-06 01:09:13.302319	85	Comment	\N
100	new_discussion	2012-09-06 01:16:33.110376	2012-09-06 01:16:33.110376	93	Discussion	\N
101	new_comment	2012-09-06 02:39:34.354593	2012-09-06 02:39:34.354593	86	Comment	\N
102	new_comment	2012-09-06 02:39:57.772756	2012-09-06 02:39:57.772756	87	Comment	\N
103	new_comment	2012-09-06 02:45:38.941318	2012-09-06 02:45:38.941318	88	Comment	\N
104	new_vote	2012-09-06 03:56:32.401303	2012-09-06 03:56:32.401303	100	Vote	\N
105	new_comment	2012-09-06 03:57:12.125388	2012-09-06 03:57:12.125388	89	Comment	\N
106	new_discussion	2012-09-06 04:02:53.490238	2012-09-06 04:02:53.490238	94	Discussion	\N
107	new_comment	2012-09-06 04:03:21.203823	2012-09-06 04:03:21.203823	90	Comment	\N
108	new_comment	2012-09-06 04:03:42.919406	2012-09-06 04:03:42.919406	91	Comment	\N
109	new_comment	2012-09-06 04:04:02.049702	2012-09-06 04:04:02.049702	92	Comment	\N
110	new_motion	2012-09-06 04:04:46.692847	2012-09-06 04:04:46.692847	164	Motion	\N
111	new_comment	2012-09-06 04:05:22.15713	2012-09-06 04:05:22.15713	93	Comment	\N
112	user_added_to_group	2012-09-06 05:07:51.983725	2012-09-06 05:07:51.983725	173	Membership	\N
113	new_vote	2012-09-06 05:20:27.614003	2012-09-06 05:20:27.614003	101	Vote	\N
114	new_comment	2012-09-06 05:43:00.129054	2012-09-06 05:43:00.129054	95	Comment	\N
115	new_vote	2012-09-06 05:44:06.020218	2012-09-06 05:44:06.020218	102	Vote	\N
116	new_comment	2012-09-07 21:28:26.333381	2012-09-07 21:28:26.333381	96	Comment	\N
117	new_comment	2012-09-08 00:22:24.837564	2012-09-08 00:22:24.837564	97	Comment	\N
118	new_motion	2012-09-10 01:44:08.116842	2012-09-10 01:44:08.116842	166	Motion	\N
119	motion_closed	2012-09-10 01:44:49.931143	2012-09-10 01:44:49.931143	166	Motion	18
120	new_motion	2012-09-10 01:45:12.176889	2012-09-10 01:45:12.176889	167	Motion	\N
121	user_added_to_group	2012-09-10 05:19:01.239682	2012-09-10 05:19:01.239682	176	Membership	\N
122	new_vote	2012-09-10 22:57:37.135429	2012-09-10 22:57:37.135429	103	Vote	\N
123	new_discussion	2012-09-10 23:14:42.237506	2012-09-10 23:14:42.237506	96	Discussion	\N
124	new_motion	2012-09-10 23:25:25.11196	2012-09-10 23:25:25.11196	168	Motion	\N
125	new_motion	2012-09-11 01:26:36.835239	2012-09-11 01:26:36.835239	169	Motion	\N
126	motion_closed	2012-09-11 02:15:23.742305	2012-09-11 02:15:23.742305	169	Motion	3
127	new_motion	2012-09-11 02:23:27.544597	2012-09-11 02:23:27.544597	170	Motion	\N
128	motion_closed	2012-09-11 04:24:50.254473	2012-09-11 04:24:50.254473	167	Motion	3
129	motion_closed	2012-09-11 04:25:23.547598	2012-09-11 04:25:23.547598	168	Motion	3
130	motion_closed	2012-09-11 04:26:37.342692	2012-09-11 04:26:37.342692	170	Motion	3
131	new_comment	2012-09-11 04:33:07.167951	2012-09-11 04:33:07.167951	99	Comment	\N
132	new_comment	2012-09-11 04:45:25.055632	2012-09-11 04:45:25.055632	100	Comment	\N
133	new_motion	2012-09-11 04:59:32.807615	2012-09-11 04:59:32.807615	172	Motion	\N
134	new_discussion	2012-09-12 00:11:11.603664	2012-09-12 00:11:11.603664	98	Discussion	\N
135	new_motion	2012-09-12 00:11:53.803099	2012-09-12 00:11:53.803099	173	Motion	\N
136	new_comment	2012-09-12 00:12:48.836054	2012-09-12 00:12:48.836054	101	Comment	\N
137	new_vote	2012-09-12 00:13:44.311645	2012-09-12 00:13:44.311645	104	Vote	\N
138	new_comment	2012-09-15 01:58:51.644124	2012-09-15 01:58:51.644124	103	Comment	\N
139	new_comment	2012-09-15 02:00:14.728632	2012-09-15 02:00:14.728632	104	Comment	\N
140	new_comment	2012-09-15 03:24:20.925262	2012-09-15 03:24:20.925262	105	Comment	\N
141	new_comment	2012-09-15 03:24:33.976184	2012-09-15 03:24:33.976184	106	Comment	\N
142	new_comment	2012-09-15 03:25:40.920483	2012-09-15 03:25:40.920483	107	Comment	\N
143	new_discussion	2012-09-16 06:25:13.408102	2012-09-16 06:25:13.408102	100	Discussion	\N
144	new_comment	2012-09-16 06:25:34.086067	2012-09-16 06:25:34.086067	108	Comment	\N
145	new_comment	2012-09-16 06:25:52.51447	2012-09-16 06:25:52.51447	109	Comment	\N
146	new_comment	2012-09-16 06:27:21.896379	2012-09-16 06:27:21.896379	110	Comment	\N
147	new_comment	2012-09-16 06:28:34.176732	2012-09-16 06:28:34.176732	111	Comment	\N
148	new_comment	2012-09-16 06:31:31.27258	2012-09-16 06:31:31.27258	112	Comment	\N
149	new_comment	2012-09-16 06:45:19.779203	2012-09-16 06:45:19.779203	113	Comment	\N
150	new_comment	2012-09-16 06:52:19.959786	2012-09-16 06:52:19.959786	114	Comment	\N
151	new_comment	2012-09-16 22:39:44.952504	2012-09-16 22:39:44.952504	115	Comment	\N
152	new_comment	2012-09-16 22:40:05.533873	2012-09-16 22:40:05.533873	116	Comment	\N
153	new_comment	2012-09-16 22:40:29.45582	2012-09-16 22:40:29.45582	117	Comment	\N
154	new_comment	2012-09-16 22:52:40.929385	2012-09-16 22:52:40.929385	118	Comment	\N
155	new_comment	2012-09-16 22:53:12.627076	2012-09-16 22:53:12.627076	119	Comment	\N
156	new_comment	2012-09-16 22:54:26.781799	2012-09-16 22:54:26.781799	120	Comment	\N
157	new_comment	2012-09-16 22:54:36.394993	2012-09-16 22:54:36.394993	121	Comment	\N
158	new_comment	2012-09-16 22:56:24.387361	2012-09-16 22:56:24.387361	122	Comment	\N
159	new_comment	2012-09-16 22:58:02.414717	2012-09-16 22:58:02.414717	123	Comment	\N
160	new_comment	2012-09-16 22:59:47.411712	2012-09-16 22:59:47.411712	124	Comment	\N
161	new_comment	2012-09-16 23:07:59.583184	2012-09-16 23:07:59.583184	125	Comment	\N
162	new_comment	2012-09-16 23:08:37.900138	2012-09-16 23:08:37.900138	126	Comment	\N
163	new_comment	2012-09-17 01:28:19.404224	2012-09-17 01:28:19.404224	127	Comment	\N
164	new_comment	2012-09-17 01:28:55.780657	2012-09-17 01:28:55.780657	128	Comment	\N
165	new_comment	2012-09-17 01:30:08.66924	2012-09-17 01:30:08.66924	129	Comment	\N
166	new_comment	2012-09-17 01:31:50.443505	2012-09-17 01:31:50.443505	130	Comment	\N
167	new_motion	2012-09-17 20:12:06.10368	2012-09-17 20:12:06.10368	175	Motion	\N
168	new_vote	2012-09-17 20:12:27.195867	2012-09-17 20:12:27.195867	105	Vote	\N
169	motion_closed	2012-09-17 20:13:16.640813	2012-09-17 20:13:16.640813	175	Motion	2
170	new_comment	2012-09-17 20:15:38.457889	2012-09-17 20:15:38.457889	131	Comment	\N
171	new_motion	2012-09-17 20:59:53.866646	2012-09-17 20:59:53.866646	176	Motion	\N
172	new_motion	2012-09-17 21:01:27.947903	2012-09-17 21:01:27.947903	177	Motion	\N
173	new_vote	2012-09-17 21:02:31.94254	2012-09-17 21:02:31.94254	106	Vote	\N
174	new_comment	2012-09-18 01:54:36.678627	2012-09-18 01:54:36.678627	132	Comment	\N
175	motion_closed	2012-09-18 02:35:46.627831	2012-09-18 02:35:46.627831	176	Motion	2
176	new_motion	2012-09-18 03:21:15.938781	2012-09-18 03:21:15.938781	178	Motion	\N
177	motion_closed	2012-09-18 03:24:17.526207	2012-09-18 03:24:17.526207	178	Motion	2
178	new_motion	2012-09-18 03:40:10.56965	2012-09-18 03:40:10.56965	179	Motion	\N
179	new_vote	2012-09-18 03:40:18.499822	2012-09-18 03:40:18.499822	107	Vote	\N
180	new_comment	2012-09-18 03:51:09.751604	2012-09-18 03:51:09.751604	133	Comment	\N
181	motion_closed	2012-09-18 03:59:16.29073	2012-09-18 03:59:16.29073	179	Motion	3
182	new_motion	2012-09-18 04:00:02.107042	2012-09-18 04:00:02.107042	180	Motion	\N
183	new_comment	2012-09-18 04:00:12.705635	2012-09-18 04:00:12.705635	134	Comment	\N
184	new_motion	2012-09-18 09:05:51.860362	2012-09-18 09:05:51.860362	181	Motion	\N
185	new_comment	2012-09-18 09:06:31.182764	2012-09-18 09:06:31.182764	135	Comment	\N
186	new_motion	2012-09-18 09:09:15.389832	2012-09-18 09:09:15.389832	182	Motion	\N
187	new_comment	2012-09-18 09:10:29.959223	2012-09-18 09:10:29.959223	136	Comment	\N
188	new_comment	2012-09-18 09:11:19.021013	2012-09-18 09:11:19.021013	137	Comment	\N
189	new_comment	2012-09-18 09:12:34.73299	2012-09-18 09:12:34.73299	138	Comment	\N
190	new_motion	2012-09-18 09:19:46.906437	2012-09-18 09:19:46.906437	183	Motion	\N
191	motion_closed	2012-09-18 10:04:41.596009	2012-09-18 10:04:41.596009	183	Motion	3
192	new_comment	2012-09-19 01:28:28.614622	2012-09-19 01:28:28.614622	139	Comment	\N
193	new_comment	2012-09-19 01:29:20.842248	2012-09-19 01:29:20.842248	140	Comment	\N
194	new_comment	2012-09-19 01:30:30.632156	2012-09-19 01:30:30.632156	141	Comment	\N
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY groups (id, name, created_at, updated_at, viewable_by, members_invitable_by, parent_id, email_new_motion, hide_members, beta_features, description, creator_id, memberships_count, archived_at) FROM stdin;
52	Testdrive motion	2012-08-05 20:32:05.219497	2012-08-27 22:26:29.751652	everyone	members	\N	t	f	f	\N	3	1	2012-08-27 22:26:29.746481
2	Heavenly children	2012-05-10 00:20:54.690416	2012-07-19 03:12:48.443702	everyone	members	1	t	f	f	\N	1	1	\N
4	sub group 1	2012-05-16 06:54:36.309897	2012-07-19 03:12:48.448231	everyone	members	3	t	f	f	\N	3	1	\N
3	Awsomity neutral	2012-05-15 04:29:56.134544	2012-07-19 03:12:48.45332	everyone	members	\N	t	f	f	\N	13	7	\N
19	This is a group has a long name	2012-06-12 01:57:16.243361	2012-07-19 03:12:48.457998	everyone	members	\N	t	f	f	[Null]	3	1	\N
5	2nd group	2012-05-23 04:54:39.083841	2012-07-19 03:12:48.462662	everyone	members	\N	t	f	f	\N	5	1	\N
9	sub station zero	2012-05-29 05:25:38.884046	2012-07-19 03:12:48.471856	parent_group_members	members	7	t	f	f	\N	3	2	\N
12	Group C	2012-05-30 22:21:49.932483	2012-07-19 03:12:48.481538	everyone	members	\N	t	f	f	\N	2	2	\N
33	test	2012-08-05 01:26:34.267697	2012-08-27 22:27:19.932704	everyone	members	\N	t	f	f	\N	3	1	2012-08-27 22:27:19.927237
22	another reason to blank	2012-06-17 02:24:18.539134	2012-07-19 03:12:48.500174	everyone	members	\N	t	f	f	dfsfs	3	1	\N
17	sub group test	2012-06-07 00:26:28.75056	2012-07-19 03:12:48.504955	everyone	members	\N	t	f	f	\N	14	2	\N
18	Nice sub	2012-06-07 00:26:51.189624	2012-07-19 03:12:48.5097	everyone	members	17	t	f	f	\N	14	2	\N
16	sum Membership test	2012-06-06 23:51:55.017851	2012-09-16 22:57:33.156635	everyone	members	15	t	f	f	\N	14	3	\N
72	help	2012-08-24 06:06:34.198741	2012-08-25 22:42:22.861543	everyone	members	\N	t	f	f	\N	3	1	2012-08-25 22:42:22.858937
7	Anonymous	2012-05-23 09:55:06.483877	2012-07-19 03:12:48.572764	everyone	members	\N	t	f	f	jhuu	3	4	\N
11	Group B	2012-05-30 05:41:03.464954	2012-08-05 05:56:55.777714	everyone	members	\N	t	f	f	\N	2	2	\N
28	private subgroup	2012-07-04 22:21:13.356596	2012-07-19 03:12:48.585071	members	members	1	t	f	f	\N	14	1	\N
27	Longed name sub group shortened	2012-07-03 00:52:09.568757	2012-07-19 03:12:48.591348	parent_group_members	members	1	t	f	f	\N	3	1	\N
50	intro	2012-08-05 06:59:12.918616	2012-08-07 00:18:44.057759	everyone	members	\N	t	f	f	\N	3	1	2012-08-07 00:18:44.052498
26	shinning example	2012-06-28 04:41:01.382198	2012-07-26 05:31:23.843432	parent_group_members	members	1	t	f	f	Come in peter	3	1	\N
24	dlkflsd	2012-06-20 02:26:29.444763	2012-08-25 22:41:59.293389	members	members	\N	t	f	f	hello	3	2	2012-08-25 22:41:59.290038
23	Is this a singularity?	2012-06-17 03:42:38.736493	2012-09-03 23:16:55.582968	everyone	members	\N	t	f	f	the balls	3	2	\N
21	Got that shit workin damn	2012-06-17 02:23:47.248224	2012-07-26 05:40:31.997082	everyone	members	\N	t	f	f	\N	3	2	\N
29	Jail	2012-07-26 05:41:21.106722	2012-08-29 21:04:34.358788	parent_group_members	members	21	t	f	f	Testing edit on sub groups	3	1	\N
14	test 44	2012-06-01 02:27:03.711178	2012-07-27 01:05:11.995012	everyone	members	\N	t	f	f	preence	3	2	2012-07-27 01:05:11.992071
30	new leaving test	2012-07-27 02:05:39.140053	2012-07-27 02:06:20.98688	everyone	members	\N	t	f	f	\N	3	2	2012-07-27 02:06:20.984312
8	potspo	2012-05-23 10:01:45.263885	2012-07-27 06:40:00.816782	everyone	members	\N	t	f	f	\N	2	3	\N
25	Desperate angels	2012-06-25 02:08:53.377545	2012-09-04 02:49:09.49347	everyone	members	1	t	f	f	You can see but you cant touch it	3	2	\N
10	Group A	2012-05-30 04:25:56.07508	2012-08-05 05:15:59.994374	everyone	members	\N	t	f	f	ajksbdczXCCSZCjseiorjsjd isauhdsidhashduihcasiuhsaiodhcasiudchaisuhciusahsoidchasidhiauhdiuahsdivoijsdoifjvsodijvoisdfvosdfvosdhfoivjsdoifjvodisjvoidsasldasdvoiaj oisdjvioasjdiovhaihdv;ai shdiuashviuhasiudv h	3	3	2012-08-05 05:15:59.989406
35	Create Discussion	2012-08-05 04:56:43.010801	2012-08-05 05:17:57.42596	everyone	members	\N	t	f	f	\N	3	1	2012-08-05 05:17:57.420531
31	Private house	2012-08-04 03:26:37.674459	2012-09-03 02:54:26.248791	members	admins	\N	t	f	f	cheese 23456	18	2	\N
36	Create Discussion 2	2012-08-05 05:11:10.103022	2012-08-05 05:18:28.632557	everyone	members	\N	t	f	f	\N	3	1	2012-08-05 05:18:28.627461
37	Create Discussion 3	2012-08-05 05:12:53.702397	2012-08-27 22:26:58.976044	everyone	members	\N	t	f	f	\N	3	2	2012-08-27 22:26:58.971244
44	tinkle 3	2012-08-05 06:39:19.522437	2012-08-05 06:41:03.770626	everyone	members	\N	t	f	f	\N	3	1	2012-08-05 06:41:03.766157
32	welcome loomio 	2012-08-05 00:27:40.626511	2012-08-05 06:45:19.784954	everyone	members	\N	t	f	f	\N	3	1	2012-08-05 06:45:19.780036
45	tinkle 4	2012-08-05 06:41:43.156283	2012-08-05 06:46:07.65895	everyone	members	\N	t	f	f	\N	3	1	2012-08-05 06:46:07.654458
64	chockochip	2012-08-07 00:10:45.798486	2012-08-25 22:43:43.669568	everyone	members	\N	t	f	f	\N	3	1	2012-08-25 22:43:43.667023
43	tinkle 2	2012-08-05 06:38:16.643243	2012-08-05 06:55:49.944481	everyone	members	\N	t	f	f	\N	3	1	2012-08-05 06:55:49.939879
46	tinkle 5	2012-08-05 06:46:40.113237	2012-08-05 06:56:19.902371	everyone	members	\N	t	f	f	\N	3	1	2012-08-05 06:56:19.89737
47	tinkle 5	2012-08-05 06:47:12.979189	2012-08-05 06:56:55.107689	everyone	members	\N	t	f	f	\N	3	1	2012-08-05 06:56:55.102853
58	new line of old?	2012-08-05 23:26:39.655979	2012-08-07 00:20:45.339602	everyone	members	\N	t	f	f	\N	3	1	2012-08-07 00:20:45.335058
54	try this on for size	2012-08-05 22:48:39.442028	2012-08-05 23:11:39.782529	everyone	members	\N	t	f	f	\N	3	1	2012-08-05 23:11:39.779768
55	No welcome	2012-08-05 23:12:10.830437	2012-08-05 23:12:10.859435	everyone	members	\N	t	f	f	\N	3	1	\N
59	one more for old times sake	2012-08-06 04:20:05.523925	2012-08-25 22:45:10.630609	everyone	members	\N	t	f	f	\N	3	1	2012-08-25 22:45:10.627599
67	Just the stars	2012-08-19 05:05:11.926843	2012-08-19 05:05:11.963018	everyone	members	\N	t	f	f	\N	39	1	\N
66	rotten core	2012-08-07 02:59:06.487186	2012-08-07 02:59:07.002379	everyone	members	\N	t	f	f	\N	3	1	\N
60	now fly	2012-08-06 05:16:29.519612	2012-08-06 05:16:29.550682	everyone	members	\N	t	f	f	\N	3	1	\N
15	membership test	2012-06-06 23:48:02.80647	2012-08-07 23:50:36.126277	everyone	members	\N	t	f	f	\N	14	5	\N
65	Chocochoco	2012-08-07 00:13:04.103837	2012-08-25 22:40:14.32773	everyone	members	\N	t	f	f	\N	3	2	2012-08-25 22:40:14.325179
53	mo motion!	2012-08-05 22:35:58.939828	2012-08-25 22:43:17.884202	everyone	members	\N	t	f	f	\N	3	1	2012-08-25 22:43:17.881164
63	Chockchip	2012-08-07 00:07:57.424275	2012-08-07 00:07:57.473157	everyone	members	\N	t	f	f	\N	3	1	\N
56	motional	2012-08-05 23:12:58.734698	2012-08-25 22:44:21.565506	everyone	members	\N	t	f	f	\N	3	1	2012-08-25 22:44:21.562859
49	intro	2012-08-05 06:58:14.380791	2012-08-07 00:19:06.445887	everyone	members	\N	t	f	f	\N	3	1	2012-08-07 00:19:06.440858
70	Lets see	2012-08-24 04:18:24.71576	2012-08-25 22:40:45.894035	everyone	members	\N	t	f	f	\N	3	1	2012-08-25 22:40:45.891383
20	Got that shit workin	2012-06-17 02:22:54.878495	2012-08-07 00:18:18.923155	everyone	members	\N	t	f	f	\N	3	1	2012-08-07 00:18:18.917908
48	intro	2012-08-05 06:57:23.872794	2012-08-07 00:19:31.696989	everyone	members	\N	t	f	f	\N	3	1	2012-08-07 00:19:31.692264
57	motional	2012-08-05 23:13:25.749449	2012-08-07 00:19:57.984611	everyone	members	\N	t	f	f	\N	3	1	2012-08-07 00:19:57.979978
68	Intro	2012-08-22 04:29:10.812967	2012-08-22 04:29:11.192188	everyone	members	\N	t	f	f	\N	2	1	\N
69	No Loomios	2012-08-24 03:51:47.560338	2012-09-03 23:06:41.653556	everyone	members	\N	t	f	f	Nothing here	3	1	\N
73	help	2012-08-24 06:06:37.18664	2012-08-25 22:41:08.097029	everyone	members	\N	t	f	f	\N	3	2	2012-08-25 22:41:08.094375
71	monday	2012-08-24 06:02:30.439462	2012-08-24 06:05:59.768449	everyone	members	\N	t	f	f	\N	3	1	2012-08-24 06:05:59.765754
62	chibychibychiby	2012-08-07 00:05:09.662373	2012-08-25 22:42:51.983113	everyone	members	\N	t	f	f	\N	3	1	2012-08-25 22:42:51.980501
61	Chibychiby	2012-08-06 23:56:43.236438	2012-08-25 22:39:11.141776	everyone	members	\N	t	f	f	\N	3	1	2012-08-25 22:39:11.139116
51	intro 2	2012-08-05 07:06:12.519781	2012-08-25 22:41:38.276539	everyone	members	\N	t	f	f	\N	3	1	2012-08-25 22:41:38.273944
75	now who	2012-08-25 22:52:45.816541	2012-08-25 22:52:45.873496	everyone	members	\N	t	f	f	\N	2	1	\N
76	Chipy	2012-08-25 22:55:54.818666	2012-08-25 22:55:54.865955	everyone	members	\N	t	f	f	\N	2	1	\N
77	vrooom	2012-08-25 22:57:12.518963	2012-08-25 22:57:12.575401	everyone	members	\N	t	f	f	\N	2	1	\N
79	talk chips	2012-08-25 23:05:02.470936	2012-08-25 23:05:02.544003	everyone	members	\N	t	f	f	\N	2	1	\N
78	me	2012-08-25 22:59:20.646475	2012-08-26 20:49:50.514714	everyone	members	\N	t	f	f	\N	2	1	2012-08-26 20:49:50.508881
80	Zimmamimiman	2012-08-26 02:45:42.350208	2012-09-05 20:18:47.213074	everyone	members	\N	t	f	f	stuttering is my second name	2	1	\N
81	ice creams suck	2012-09-06 05:11:50.991927	2012-09-06 05:11:51.596123	everyone	members	\N	t	f	f	\N	40	1	\N
74	Who owns who	2012-08-25 22:46:38.075241	2012-09-09 00:47:24.83391	everyone	members	\N	t	f	f	\N	2	1	2012-09-09 00:47:24.831331
82	test group 54	2012-09-11 02:57:38.213724	2012-09-11 02:58:01.682677	everyone	members	\N	t	f	f	Group about nothing much	3	1	\N
84	upside down	2012-09-12 00:33:09.999099	2012-09-12 00:33:10.03709	parent_group_members	members	83	t	f	f	\N	3	1	\N
83	topsy turvy	2012-09-12 00:32:28.227462	2012-09-12 00:33:43.707742	everyone	members	\N	t	f	f	which way is up	3	1	\N
1	Delinquent Decoys	2012-05-09 23:01:18.917816	2012-09-14 02:07:39.18541	everyone	admins	\N	t	f	t	This group is about chrime, street style. No prisioners, hard ball. If you are a pussy stay at home with your mum. You gotta have what it takes to play ruff. take no prisoners. Hear what im saying govenor. Please play hard or go home. This is serious	1	22	\N
\.


--
-- Data for Name: memberships; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY memberships (id, group_id, user_id, created_at, updated_at, access_level, inviter_id) FROM stdin;
1	1	1	2012-05-09 23:01:18.939099	2012-05-09 23:01:18.939099	admin	\N
2	2	1	2012-05-10 00:20:54.770533	2012-05-10 00:20:54.770533	admin	\N
52	12	2	2012-05-31 03:59:12.487896	2012-05-31 04:00:00.034989	admin	\N
53	14	3	2012-06-01 02:27:03.73486	2012-06-01 02:27:03.73486	admin	\N
54	14	2	2012-06-01 02:27:13.437941	2012-06-01 02:27:13.437941	member	\N
55	3	16	2012-06-02 07:55:37.215424	2012-06-02 07:55:37.215424	member	\N
9	5	5	2012-05-23 05:00:30.330965	2012-05-23 05:00:30.330965	member	\N
10	5	3	2012-05-23 05:03:40.508421	2012-05-23 05:03:40.508421	request	\N
56	12	14	2012-06-02 07:57:35.178888	2012-06-02 07:57:49.250061	member	\N
57	15	14	2012-06-06 23:48:02.832808	2012-06-06 23:48:02.832808	admin	\N
59	16	14	2012-06-06 23:51:55.041926	2012-06-06 23:51:55.041926	admin	\N
63	17	14	2012-06-07 00:26:28.775384	2012-06-07 00:26:28.775384	admin	\N
64	18	14	2012-06-07 00:26:51.213855	2012-06-07 00:26:51.213855	admin	\N
24	9	12	2012-05-29 05:55:52.611506	2012-05-29 05:55:52.611506	member	\N
17	3	9	2012-05-28 05:56:48.217808	2012-05-30 02:37:31.015787	member	\N
66	17	3	2012-06-07 01:18:05.204525	2012-06-07 01:18:24.59274	member	\N
115	46	3	2012-08-05 06:46:40.1504	2012-08-05 06:46:40.1504	admin	\N
6	3	4	2012-05-17 22:25:08.924408	2012-05-30 04:11:19.106833	member	\N
28	3	13	2012-05-30 04:12:15.372169	2012-05-30 04:12:15.372169	member	\N
26	7	2	2012-05-30 03:22:29.570514	2012-09-16 06:44:57.569726	member	\N
30	10	3	2012-05-30 04:25:56.107171	2012-05-30 04:25:56.107171	admin	\N
32	10	14	2012-05-30 04:30:13.368694	2012-05-30 04:30:13.368694	member	\N
31	10	2	2012-05-30 04:29:09.375252	2012-05-30 04:33:06.322855	member	\N
33	7	14	2012-05-30 05:17:54.944967	2012-05-30 05:22:23.040589	member	\N
34	8	14	2012-05-30 05:27:00.23543	2012-05-30 05:28:33.402279	member	\N
37	11	14	2012-05-30 05:42:48.18535	2012-05-30 05:43:07.928955	member	\N
36	11	2	2012-05-30 05:41:28.256194	2012-05-30 05:43:43.451787	member	\N
67	18	3	2012-06-07 01:18:46.168391	2012-06-07 01:19:05.352293	member	\N
38	3	14	2012-05-30 05:54:40.887951	2012-05-30 06:07:20.371764	member	\N
116	47	3	2012-08-05 06:47:13.017853	2012-08-05 06:47:13.017853	admin	\N
68	19	3	2012-06-12 01:57:16.27322	2012-06-12 01:57:16.27322	admin	\N
22	7	12	2012-05-29 05:55:16.271701	2012-05-30 22:17:47.942131	member	\N
69	1	14	2012-06-12 04:26:10.522113	2012-06-12 04:26:10.522113	member	\N
70	20	3	2012-06-17 02:22:54.905366	2012-06-17 02:22:54.905366	admin	\N
72	22	3	2012-06-17 02:24:18.561092	2012-06-17 02:24:18.561092	admin	\N
117	48	3	2012-08-05 06:57:23.911916	2012-08-05 06:57:23.911916	admin	\N
73	23	3	2012-06-17 03:42:38.758208	2012-06-17 03:42:38.758208	admin	\N
74	24	3	2012-06-20 02:26:29.469068	2012-06-20 02:26:29.469068	admin	\N
75	25	3	2012-06-25 02:08:53.407268	2012-06-25 02:08:53.407268	admin	\N
118	49	3	2012-08-05 06:58:14.419739	2012-08-05 06:58:14.419739	admin	\N
76	26	3	2012-06-28 04:41:01.415662	2012-06-28 04:41:01.415662	admin	\N
77	2	3	2012-06-29 23:51:17.257121	2012-06-29 23:51:17.257121	request	\N
119	50	3	2012-08-05 06:59:12.957236	2012-08-05 06:59:12.957236	admin	\N
78	25	2	2012-06-30 04:18:33.24655	2012-06-30 04:18:33.24655	request	\N
120	51	3	2012-08-05 07:06:12.604851	2012-08-05 07:06:12.604851	admin	\N
80	24	2	2012-06-30 05:51:13.94823	2012-06-30 05:51:13.94823	member	\N
121	52	3	2012-08-05 20:32:05.317704	2012-08-05 20:32:05.317704	admin	\N
81	27	3	2012-07-03 00:52:09.613252	2012-07-03 00:52:09.613252	admin	\N
82	2	2	2012-07-04 00:56:50.57904	2012-07-04 00:56:50.57904	request	\N
83	1	17	2012-07-04 05:14:41.842579	2012-07-04 05:14:41.842579	member	\N
84	25	14	2012-07-04 05:16:01.044607	2012-07-04 05:16:16.180559	member	\N
85	28	14	2012-07-04 22:21:13.429255	2012-07-04 22:21:13.429255	admin	\N
87	21	2	2012-07-26 05:36:17.41254	2012-07-26 05:36:41.168219	admin	\N
89	21	3	2012-07-26 05:40:16.819603	2012-07-26 05:40:31.991626	member	\N
90	29	3	2012-07-26 05:41:21.136339	2012-07-26 05:41:21.136339	admin	\N
92	30	3	2012-07-27 02:05:39.166704	2012-07-27 02:05:39.166704	admin	\N
93	30	2	2012-07-27 02:06:14.053897	2012-07-27 02:06:14.053897	member	\N
95	8	18	2012-07-27 06:40:00.81129	2012-07-27 06:40:00.81129	member	\N
96	31	18	2012-08-04 03:26:37.717351	2012-08-04 03:26:37.717351	admin	\N
98	31	20	2012-08-04 03:28:28.739545	2012-08-04 03:28:28.739545	member	\N
99	1	21	2012-08-04 21:31:32.092047	2012-08-04 21:31:32.092047	member	\N
100	1	22	2012-08-04 21:44:33.722287	2012-08-04 21:44:33.722287	member	\N
101	1	23	2012-08-04 21:49:54.980193	2012-08-04 21:49:54.980193	member	\N
102	1	24	2012-08-04 21:54:08.429002	2012-08-04 21:54:08.429002	member	\N
103	1	25	2012-08-04 21:55:18.142019	2012-08-04 21:55:18.142019	member	\N
104	1	26	2012-08-04 21:56:23.824094	2012-08-04 21:56:23.824094	member	\N
105	1	27	2012-08-04 21:57:50.382887	2012-08-04 21:57:50.382887	member	\N
106	1	28	2012-08-04 22:00:52.571375	2012-08-04 22:00:52.571375	member	\N
107	32	3	2012-08-05 00:27:40.670804	2012-08-05 00:27:40.670804	admin	\N
108	33	3	2012-08-05 01:26:34.307325	2012-08-05 01:26:34.307325	admin	\N
109	35	3	2012-08-05 04:56:43.072956	2012-08-05 04:56:43.072956	admin	\N
110	36	3	2012-08-05 05:11:10.150382	2012-08-05 05:11:10.150382	admin	\N
111	37	3	2012-08-05 05:13:51.904573	2012-08-05 05:13:51.904573	admin	\N
112	43	3	2012-08-05 06:38:16.682048	2012-08-05 06:38:16.682048	admin	\N
113	44	3	2012-08-05 06:39:19.561406	2012-08-05 06:39:19.561406	admin	\N
114	45	3	2012-08-05 06:41:43.193571	2012-08-05 06:41:43.193571	admin	\N
122	53	3	2012-08-05 22:35:58.965529	2012-08-05 22:35:58.965529	admin	\N
123	54	3	2012-08-05 22:48:39.468249	2012-08-05 22:48:39.468249	admin	\N
124	55	3	2012-08-05 23:12:10.854549	2012-08-05 23:12:10.854549	admin	\N
125	56	3	2012-08-05 23:12:58.758839	2012-08-05 23:12:58.758839	admin	\N
126	57	3	2012-08-05 23:13:25.77431	2012-08-05 23:13:25.77431	admin	\N
127	58	3	2012-08-05 23:26:39.681819	2012-08-05 23:26:39.681819	admin	\N
128	1	29	2012-08-06 02:04:58.142899	2012-08-06 02:04:58.142899	member	\N
129	1	30	2012-08-06 02:11:04.530006	2012-08-06 02:11:04.530006	member	\N
130	1	31	2012-08-06 02:19:55.698083	2012-08-06 02:19:55.698083	member	\N
131	1	32	2012-08-06 02:21:04.73425	2012-08-06 02:21:04.73425	member	\N
132	59	3	2012-08-06 04:20:05.552372	2012-08-06 04:20:05.552372	admin	\N
133	60	3	2012-08-06 05:16:29.545474	2012-08-06 05:16:29.545474	admin	\N
134	61	3	2012-08-06 23:56:43.357968	2012-08-06 23:56:43.357968	admin	\N
135	62	3	2012-08-07 00:05:09.701917	2012-08-07 00:05:09.701917	admin	\N
60	15	2	2012-06-07 00:02:16.87235	2012-09-17 21:00:17.576638	member	\N
27	3	2	2012-05-30 03:58:21.124896	2012-09-17 01:29:47.419677	member	\N
62	16	3	2012-06-07 00:24:27.473099	2012-09-17 21:52:46.55874	member	\N
58	15	3	2012-06-06 23:49:31.321737	2012-09-17 21:52:22.290764	member	\N
4	3	3	2012-05-15 04:29:56.15743	2012-09-17 06:52:32.944815	member	\N
136	63	3	2012-08-07 00:07:57.464543	2012-08-07 00:07:57.464543	admin	\N
137	64	3	2012-08-07 00:10:45.840158	2012-08-07 00:10:45.840158	admin	\N
138	65	3	2012-08-07 00:13:04.142003	2012-08-07 00:13:04.142003	admin	\N
139	65	34	2012-08-07 00:13:04.180444	2012-08-07 00:13:04.180444	admin	\N
140	66	3	2012-08-07 02:59:06.581386	2012-08-07 02:59:06.581386	admin	\N
142	1	35	2012-08-07 04:23:39.805549	2012-08-07 04:23:39.805549	member	\N
143	1	36	2012-08-07 04:35:39.867666	2012-08-07 04:35:39.867666	member	\N
144	15	37	2012-08-07 23:31:07.880501	2012-08-07 23:31:07.880501	member	\N
145	15	38	2012-08-07 23:50:36.121538	2012-08-07 23:50:36.121538	member	\N
146	37	2	2012-08-08 20:55:12.008326	2012-08-08 20:55:12.008326	member	3
148	67	39	2012-08-19 05:05:11.958185	2012-08-19 05:05:11.958185	admin	\N
149	1	39	2012-08-19 21:26:25.256135	2012-08-19 21:26:25.256135	request	\N
150	23	39	2012-08-19 21:31:16.107749	2012-08-19 21:31:16.107749	member	3
152	68	2	2012-08-22 04:29:10.842894	2012-08-22 04:29:10.842894	admin	\N
154	69	3	2012-08-24 03:51:47.592027	2012-08-24 03:51:47.592027	admin	\N
11	7	3	2012-05-23 09:55:06.53204	2012-09-16 06:31:07.654623	admin	\N
19	9	3	2012-05-29 05:25:38.910647	2012-09-16 06:24:49.14816	admin	\N
29	8	2	2012-05-30 04:12:57.853285	2012-09-16 06:26:59.225056	member	\N
155	70	3	2012-08-24 04:18:24.74926	2012-08-24 04:18:24.74926	admin	\N
157	71	3	2012-08-24 06:02:30.492694	2012-08-24 06:02:30.492694	admin	\N
159	72	3	2012-08-24 06:06:34.226544	2012-08-24 06:06:34.226544	admin	\N
161	73	3	2012-08-24 06:06:37.212864	2012-08-24 06:06:37.212864	admin	\N
163	73	14	2012-08-24 06:08:13.507398	2012-08-24 06:08:13.507398	member	3
164	74	2	2012-08-25 22:46:38.191158	2012-08-25 22:46:38.191158	admin	\N
165	75	2	2012-08-25 22:52:45.865138	2012-08-25 22:52:45.865138	admin	\N
166	76	2	2012-08-25 22:55:54.856786	2012-08-25 22:55:54.856786	admin	\N
167	77	2	2012-08-25 22:57:12.566476	2012-08-25 22:57:12.566476	admin	\N
168	78	2	2012-08-25 22:59:20.675973	2012-08-25 22:59:20.675973	admin	\N
169	79	2	2012-08-25 23:05:02.530567	2012-08-25 23:05:02.530567	admin	\N
170	80	2	2012-08-26 02:45:42.395146	2012-08-26 02:45:42.395146	admin	\N
172	1	18	2012-09-01 00:38:14.027139	2012-09-01 00:38:14.027139	member	3
173	1	40	2012-09-06 05:07:51.679999	2012-09-06 05:07:51.679999	member	3
174	81	40	2012-09-06 05:11:51.035108	2012-09-06 05:11:51.035108	admin	\N
176	1	41	2012-09-10 05:19:01.143289	2012-09-10 05:19:01.143289	member	3
177	82	3	2012-09-11 02:57:38.248119	2012-09-11 02:57:38.248119	admin	\N
179	83	3	2012-09-12 00:32:28.256371	2012-09-12 00:32:28.256371	admin	\N
181	84	3	2012-09-12 00:33:10.031676	2012-09-12 00:33:10.031676	admin	\N
5	4	3	2012-05-16 06:54:36.334839	2012-09-16 06:29:34.943329	admin	\N
151	1	2	2012-08-20 09:29:36.236505	2012-09-16 22:59:12.708034	member	3
25	1	3	2012-05-30 03:00:23.349254	2012-09-17 06:49:07.370412	admin	\N
61	16	2	2012-06-07 00:03:08.389581	2012-09-17 20:58:04.507534	member	\N
\.


--
-- Data for Name: motion_read_logs; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY motion_read_logs (id, motion_activity_when_last_read, motion_id, user_id, created_at, updated_at) FROM stdin;
2	5	130	3	2012-08-13 04:23:20.74338	2012-08-13 04:40:45.9683
1	6	130	2	2012-08-13 04:22:05.16026	2012-08-16 00:11:51.920563
3	0	125	3	2012-08-16 00:50:40.558584	2012-08-16 00:50:40.558584
4	0	138	2	2012-08-20 09:27:41.999882	2012-08-20 09:27:41.999882
5	1	133	2	2012-08-20 09:30:21.402217	2012-08-20 09:30:36.742728
6	0	132	3	2012-08-20 09:32:33.806128	2012-08-20 09:32:33.806128
7	1	133	3	2012-08-20 10:00:51.070818	2012-08-20 10:00:51.070818
8	0	134	2	2012-08-20 20:17:08.767195	2012-08-20 20:17:08.767195
9	0	132	2	2012-08-20 20:36:01.870854	2012-08-20 20:36:01.870854
10	0	139	2	2012-08-22 04:29:30.980111	2012-08-22 04:29:30.980111
12	0	141	2	2012-08-22 21:32:19.63842	2012-08-22 21:32:19.63842
11	1	140	2	2012-08-22 10:16:00.736847	2012-08-22 21:32:57.94223
13	2	140	3	2012-08-22 21:34:45.421688	2012-08-22 21:38:16.056428
14	0	142	3	2012-08-24 04:18:45.422481	2012-08-24 04:18:45.422481
15	2	143	3	2012-08-24 06:02:50.729986	2012-08-24 06:05:01.710106
16	0	145	14	2012-08-24 06:08:49.419	2012-08-24 06:08:49.419
17	1	146	3	2012-08-24 21:09:29.293556	2012-08-24 21:09:47.444703
18	0	124	3	2012-08-24 21:22:25.861467	2012-08-24 21:22:25.861467
19	1	148	2	2012-08-27 00:46:33.648608	2012-08-27 00:47:09.77816
20	1	147	2	2012-08-27 10:02:19.35685	2012-08-27 10:02:36.050792
21	0	126	3	2012-08-27 22:16:02.150746	2012-08-27 22:16:02.150746
22	1	148	3	2012-08-28 23:59:43.972791	2012-08-28 23:59:43.972791
23	1	149	3	2012-08-29 01:14:40.688262	2012-08-29 01:15:03.102988
24	1	149	2	2012-08-29 04:57:34.876703	2012-08-29 04:57:34.876703
25	0	150	3	2012-08-29 05:03:02.707942	2012-08-29 05:03:02.707942
26	0	151	3	2012-08-29 05:08:45.422121	2012-08-29 05:08:45.422121
27	0	152	3	2012-08-29 21:07:02.890643	2012-08-29 21:07:02.890643
28	0	153	3	2012-08-29 21:17:25.301661	2012-08-29 21:17:25.301661
29	0	154	2	2012-08-29 21:27:53.223192	2012-08-29 21:27:53.223192
30	0	154	3	2012-08-30 01:55:24.70652	2012-08-30 01:55:24.70652
31	0	155	3	2012-08-30 09:49:00.244165	2012-08-30 09:49:00.244165
32	0	156	3	2012-08-30 20:13:31.713156	2012-08-30 20:13:31.713156
33	0	157	3	2012-08-30 22:50:10.831602	2012-08-30 22:50:10.831602
34	0	158	18	2012-08-31 01:21:19.72882	2012-08-31 01:21:19.72882
35	0	157	18	2012-09-01 01:51:14.743279	2012-09-01 01:51:14.743279
36	0	159	18	2012-09-02 23:56:53.840552	2012-09-02 23:56:53.840552
37	0	160	3	2012-09-04 03:14:23.774328	2012-09-04 03:14:23.774328
38	1	161	3	2012-09-04 03:28:19.676076	2012-09-04 03:28:41.673821
39	1	162	3	2012-09-04 06:16:08.838379	2012-09-04 06:16:24.834954
41	0	163	2	2012-09-05 09:28:33.05183	2012-09-05 09:28:33.05183
42	2	162	2	2012-09-05 09:29:12.472116	2012-09-06 03:56:33.929763
43	0	164	2	2012-09-06 04:04:48.648101	2012-09-06 04:04:48.648101
44	1	165	40	2012-09-06 05:13:09.183136	2012-09-06 05:20:29.118119
40	1	163	3	2012-09-05 03:24:18.696315	2012-09-06 05:44:07.867213
45	1	163	40	2012-09-06 05:23:37.07803	2012-09-06 05:54:08.186016
46	2	162	40	2012-09-06 05:58:21.365312	2012-09-06 05:58:21.365312
47	0	164	3	2012-09-07 03:42:26.627979	2012-09-07 03:42:26.627979
48	0	166	18	2012-09-10 01:44:09.301384	2012-09-10 01:44:09.301384
49	0	167	18	2012-09-10 01:45:13.33428	2012-09-10 01:45:13.33428
50	1	167	3	2012-09-10 22:57:29.104465	2012-09-10 22:57:38.181043
51	0	168	3	2012-09-10 23:25:26.340432	2012-09-10 23:25:26.340432
52	0	169	3	2012-09-11 01:26:38.12657	2012-09-11 01:26:38.12657
53	0	170	3	2012-09-11 02:23:28.804281	2012-09-11 02:23:28.804281
54	0	171	3	2012-09-11 02:58:45.046463	2012-09-11 02:58:45.046463
55	0	170	2	2012-09-11 04:24:33.708678	2012-09-11 04:24:33.708678
56	0	172	2	2012-09-11 04:59:34.170818	2012-09-11 04:59:34.170818
57	1	173	3	2012-09-12 00:11:54.792612	2012-09-12 00:13:45.429881
58	0	172	3	2012-09-12 00:16:56.982689	2012-09-12 00:16:56.982689
59	0	174	3	2012-09-12 00:33:54.798653	2012-09-12 00:33:54.798653
60	1	175	2	2012-09-17 20:12:07.730282	2012-09-17 20:12:28.722372
61	0	176	2	2012-09-17 20:59:55.511283	2012-09-17 20:59:55.511283
62	1	177	2	2012-09-17 21:01:29.625922	2012-09-17 21:02:33.495304
63	0	178	2	2012-09-18 03:21:16.084609	2012-09-18 03:21:16.084609
64	1	179	2	2012-09-18 03:40:10.820545	2012-09-18 03:40:18.57391
65	1	179	3	2012-09-18 03:59:09.14854	2012-09-18 03:59:09.14854
66	0	180	2	2012-09-18 04:00:02.488024	2012-09-18 04:00:02.488024
67	0	180	3	2012-09-18 04:21:05.790249	2012-09-18 04:21:05.790249
68	0	181	3	2012-09-18 09:05:51.98867	2012-09-18 09:05:51.98867
69	0	182	3	2012-09-18 09:09:15.505887	2012-09-18 09:09:15.505887
70	0	183	3	2012-09-18 09:19:46.978963	2012-09-18 09:19:46.978963
71	0	182	2	2012-09-19 01:30:21.865503	2012-09-19 01:30:21.865503
\.


--
-- Data for Name: motions; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY motions (id, name, description, author_id, created_at, updated_at, phase, discussion_url, close_date, discussion_id, activity) FROM stdin;
1	what do we break?	Lets have a loomio meeting to decide, we dont want to ignore any opinion.	1	2012-05-09 23:04:01.232656	2012-05-09 23:04:21.213766	closed		2012-05-09 23:04:21.209236	1	0
2	How about breaking our image?	We look to pretty...	1	2012-05-09 23:05:18.891171	2012-05-09 23:26:51.762002	closed		2012-05-09 23:26:51.757176	1	0
3	Curry?	Why not eh?	1	2012-05-10 03:06:42.080027	2012-05-10 03:08:47.594987	closed		2012-05-10 03:08:47.58758	2	0
7	maybe		1	2012-05-14 02:14:52.740595	2012-05-14 03:02:29.868047	closed		2012-05-14 03:02:29.863661	6	0
9	My new motion		3	2012-05-15 04:33:56.425954	2012-05-16 04:17:33.7458	closed		2012-05-16 04:17:33.741362	8	0
41	new 2		3	2012-05-31 05:16:38.535191	2012-05-31 05:18:09.004488	closed		2012-05-31 05:18:09.000792	14	0
28	test no close date 03		3	2012-05-17 02:44:33.067378	2012-05-18 23:33:11.188392	closed		2012-05-18 23:33:11.183955	9	0
24	Firefox 01		3	2012-05-16 23:10:51.966144	2012-05-19 01:30:33.313172	closed		2012-05-19 01:30:33.308723	8	0
10	New motion 04		3	2012-05-16 04:20:04.875997	2012-05-16 05:02:28.788642	closed		2012-05-16 05:02:28.783777	8	0
11	New motion 05	new	3	2012-05-16 05:03:37.944357	2012-05-16 05:04:41.476442	closed		2012-05-16 05:04:41.471566	8	0
29	my newest motion	This is a short discription	3	2012-05-19 01:40:38.024461	2012-05-20 01:47:14.559741	closed		2012-05-20 01:47:14.555255	8	0
12	New motion 06		3	2012-05-16 05:05:19.523844	2012-05-16 05:23:10.693175	closed		2012-05-16 05:23:10.687321	8	0
13	prop01	First	3	2012-05-16 07:04:53.05599	2012-05-16 07:05:27.71489	closed		2012-05-16 07:05:27.710767	8	0
14	prop02	second	3	2012-05-16 07:07:56.718502	2012-05-16 07:16:19.115972	closed		2012-05-16 07:16:19.111699	8	0
31	testing buttons		3	2012-05-20 02:51:16.240361	2012-05-20 04:55:02.566346	closed		2012-05-20 04:55:02.561505	10	0
15	prop03		3	2012-05-16 07:16:47.232463	2012-05-16 08:06:04.654826	closed		2012-05-16 08:06:04.650668	8	0
16	prop04	last	3	2012-05-16 08:06:25.142184	2012-05-16 08:10:33.058098	closed		2012-05-16 08:10:33.053041	8	0
30	Another new motion		4	2012-05-19 01:51:12.787457	2012-05-20 07:41:06.438207	closed		2012-05-20 07:41:06.43434	9	0
17	Title05		3	2012-05-16 08:14:37.267057	2012-05-16 09:52:31.574897	closed		2012-05-16 09:52:31.569138	8	0
18	motion08	baedtime	3	2012-05-16 09:52:58.54683	2012-05-16 20:35:07.269591	closed		2012-05-16 20:35:07.264386	8	0
19	new closure		3	2012-05-16 20:35:39.636662	2012-05-16 20:35:40.12549	closed		2012-05-16 20:35:40.120505	8	0
32	flash?		4	2012-05-20 07:41:21.136534	2012-05-21 23:47:15.25032	closed		2012-05-21 23:47:15.245945	9	0
20	new test 30-6		3	2012-05-16 21:21:32.462009	2012-05-16 22:22:55.591631	closed		2012-05-16 22:22:55.586545	8	0
21	new chrome test		3	2012-05-16 22:24:05.254092	2012-05-16 22:24:23.132537	closed		2012-05-16 22:24:23.127707	8	0
34	test buttons		3	2012-05-22 01:17:44.828986	2012-05-22 01:20:15.200262	closed		2012-05-22 01:20:15.195882	8	0
22	Chrome01		3	2012-05-16 22:26:35.117109	2012-05-16 23:02:43.851993	closed		2012-05-16 23:02:43.845806	8	0
33	asdfsadfsdfsadfsdf		3	2012-05-21 02:49:38.36196	2012-05-22 01:28:21.706422	closed		2012-05-22 01:28:21.701624	11	0
35	test button 2		3	2012-05-22 01:24:37.809854	2012-05-22 01:28:43.37894	closed		2012-05-22 01:28:43.375068	8	0
36	one more		3	2012-05-22 01:52:26.977549	2012-05-22 01:53:33.443419	closed		2012-05-22 01:53:33.43574	8	0
23	Chrome 2		3	2012-05-16 23:04:01.13892	2012-05-22 23:24:37.556972	closed		2012-05-22 23:24:37.548706	8	0
25	Test No Close		3	2012-05-17 02:18:35.706886	2012-05-17 02:18:47.252033	closed		2012-05-17 02:18:47.248012	9	0
26	Test noclose 02		3	2012-05-17 02:28:38.638199	2012-05-17 02:28:45.246125	closed		2012-05-17 02:28:45.241742	9	0
27	Test noclose 03		3	2012-05-17 02:30:06.191818	2012-05-17 02:30:19.805656	closed		2012-05-17 02:30:19.801203	9	0
42	new 3		3	2012-05-31 05:18:16.570487	2012-05-31 05:20:24.812035	closed		2012-05-31 05:20:24.807571	14	0
38	open as well		3	2012-05-22 23:30:43.060768	2012-05-23 04:53:27.819073	closed		2012-05-23 04:53:27.809261	9	0
37	open		3	2012-05-22 23:29:21.033527	2012-05-29 23:31:12.790436	closed		2012-05-29 23:31:12.785026	8	0
8	Lets take out some heat	chill	1	2012-05-14 03:04:12.669128	2012-05-30 02:52:52.714167	closed		2012-05-30 02:52:52.709226	6	0
4	How about Thai?	I know a good place	1	2012-05-10 03:09:11.181443	2012-05-30 02:52:52.767383	closed		2012-05-30 02:52:52.763649	2	0
6	New problem		1	2012-05-13 21:30:16.767075	2012-05-30 02:52:52.815907	closed		2012-05-30 02:52:52.812049	3	0
5	Lets play fuseball?	Ping	2	2012-05-10 05:18:23.481368	2012-05-30 02:52:52.911363	closed		2012-05-30 02:52:52.907972	1	0
39	test falsh	sdjawnfkjnakj	3	2012-05-23 04:53:42.180171	2012-05-30 05:17:12.062462	closed		2012-05-30 05:17:12.053352	9	0
50	sdafsd		3	2012-06-08 03:36:27.331859	2012-06-08 04:36:25.193411	closed		2012-06-08 04:36:25.188542	28	0
43	new 3		3	2012-05-31 05:20:43.97626	2012-05-31 05:40:12.781621	closed		2012-05-31 05:40:12.776725	14	0
48	what is your position		3	2012-06-05 23:53:05.719854	2012-06-13 02:02:00.304693	closed		2012-06-13 02:02:00.299336	20	0
47	Yet another new one	h	3	2012-06-03 05:16:05.474253	2012-06-10 22:57:07.380168	closed		2012-06-10 22:57:07.374244	6	0
40	javascript		3	2012-05-31 05:08:33.361553	2012-05-31 05:14:27.760588	closed		2012-06-11 00:15:40.489498	11	0
44	new 4		3	2012-05-31 05:41:09.867576	2012-05-31 05:41:24.716124	closed		2012-05-31 05:41:24.628834	14	0
49	shorten my details	My details are too long and i want them hidden from view so people dont judge me as bloated or un-necessary large.  This make me overly self conscious and hard for me to relax. sjdhfilhfsa dvasdvbsajkb klsdkjsbcj jbdjkb jkbvkjbsdjk kjnvkjxh kjhvcxh oixjciv oixhcvihixvh vjxjv jxncvjxnv vjxch uh  uhgiu j ih h ioh h iohi oihji oiho ih  iojoijoh  oih ih oih h h oh oihoihoih ih  iohj oih oih ih ih oih noi  oijoihiyiu h  ijoih  oih ih uhiu  ho hi h h,cknxv lkx	14	2012-06-07 03:26:31.384597	2012-06-14 06:01:36.191631	closed		2012-06-14 06:01:36.185557	26	0
45	new 5		3	2012-05-31 05:42:31.794202	2012-05-31 23:48:32.388229	closed		2012-05-31 23:48:32.381562	14	0
46	minutes		14	2012-06-01 02:41:43.245994	2012-06-01 03:37:40.325442	closed		2012-06-01 03:37:40.320891	14	0
52	jancjkasncd		3	2012-06-16 08:41:20.664914	2012-06-16 08:41:20.664914	closed		2012-06-16 08:45:52.199756	16	0
53	sadadaf		3	2012-06-16 08:46:40.064991	2012-06-16 08:46:40.064991	closed		2012-06-16 08:48:38.434734	16	0
54	Old news		3	2012-06-17 23:58:55.328841	2012-06-17 23:58:55.995398	closed		2012-06-17 23:58:55.988987	16	0
55	dsfnakjsn		3	2012-06-18 00:43:19.683234	2012-06-18 00:43:19.683234	closed		2012-06-18 00:43:27.873485	16	0
56	jsdfkja		3	2012-06-18 00:44:18.886513	2012-06-18 00:44:19.527601	closed		2012-06-18 00:44:19.521148	16	0
57	ssvds		3	2012-06-18 00:45:45.257894	2012-06-18 00:45:45.925215	closed		2012-06-18 00:45:45.918424	16	0
58	sdadc		3	2012-06-18 02:13:51.56525	2012-06-18 02:13:51.56525	closed		2012-06-18 02:14:12.493001	16	0
59	now		3	2012-06-18 02:25:12.23804	2012-06-18 02:25:12.23804	closed		2012-06-18 02:26:59.081577	16	0
51	new date	kjsdnfkjsdnksdhiuvhsdiuhviu iuhiuhiuhiuh iuhi uhuiuh i  ihiuhiuh iuh iuhiu hiu hiu Bob hi uhiuiuhiuh uh iuhiu hiu hiuh  in in Tim hiuhiuhi k nkjn iuhi uhiu nj niu hiu hj nkj niu hiu\r\n\r\nhiuhiuhiuhkim@schooltocool.com nk hniu hiu Jon hji uhiu nkj ni uh iuh n kjn iuh uh iun kj niu hiu n kjnk jniu h iun i uhiu hiu niu hPeter  iuhui	3	2012-06-11 04:12:49.759175	2012-06-18 04:15:02.63425	closed		2012-06-18 04:15:02.629407	3	0
64	sd		3	2012-06-20 03:15:38.448145	2012-06-20 03:15:38.448145	closed		2012-06-20 03:15:46.260621	32	0
65	asda		3	2012-06-20 03:16:01.920489	2012-06-20 03:16:01.920489	closed		2012-06-20 03:18:43.72903	32	0
66	qqqqq		3	2012-06-20 03:18:59.298647	2012-06-20 03:18:59.298647	closed		2012-06-20 03:22:33.075006	32	0
67	dfgsd		3	2012-06-20 03:37:23.863823	2012-06-20 03:37:23.863823	closed		2012-06-20 03:37:31.644274	32	0
60	Hippo	nicely done!	3	2012-06-18 03:09:57.854821	2012-06-20 04:15:20.417198	closed		2012-06-20 04:15:20.411151	16	0
63	Vote		3	2012-06-19 22:41:28.388559	2012-06-19 22:41:28.388559	closed		2012-06-20 04:31:19.43727	3	0
68	dasfsadf		3	2012-06-20 03:37:53.727621	2012-06-20 03:37:53.727621	closed		2012-06-20 03:39:19.057072	32	0
70	new proposal new motion		2	2012-06-22 03:03:16.361928	2012-06-22 03:03:16.361928	closed		2012-06-23 04:31:50.412344	3	0
73	New current proposal		3	2012-06-28 00:05:05.64591	2012-06-28 00:05:05.64591	closed		2012-06-28 00:42:22.867343	20	0
74	Third time down		3	2012-06-28 00:44:08.874682	2012-06-28 00:44:08.874682	closed		2012-06-28 00:45:34.701474	20	0
69	WhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakjdnfaknWhatafakj		3	2012-06-21 01:09:13.872559	2012-06-28 02:19:42.885993	closed		2012-06-28 02:19:42.877114	32	0
71	time out		2	2012-06-22 03:04:03.304853	2012-06-22 03:04:03.304853	closed		2012-06-28 02:29:47.419745	16	0
72	look at me im white		2	2012-06-23 04:32:06.453434	2012-06-23 04:32:06.453434	closed		2012-06-28 02:47:22.234176	3	0
76	Current		3	2012-06-28 02:48:41.526835	2012-06-28 02:48:41.526835	closed		2012-06-28 04:44:33.964912	3	0
77	look at thissy		3	2012-06-28 04:39:13.218485	2012-06-28 04:39:13.218485	closed		2012-06-28 05:29:50.12066	27	0
75	Whats the time?		3	2012-06-28 02:30:09.574347	2012-06-28 02:30:09.574347	closed		2012-06-29 03:45:37.70606	16	0
78	new new		3	2012-06-29 04:31:42.664673	2012-06-29 04:31:42.664673	closed		2012-07-01 05:30:44.237311	16	0
80	Should we lose the other badge?	I'm thinking probably	3	2012-07-01 22:06:22.318103	2012-07-01 22:06:22.318103	closed		2012-07-02 04:11:01.527118	27	0
86	Currently current	now	3	2012-07-04 00:31:58.052979	2012-07-04 00:31:58.052979	closed		2012-07-04 00:42:47.504098	11	0
94	Fish and chups	this is the description to end all descriptions 	3	2012-07-09 05:55:52.428469	2012-07-11 02:16:38.131737	closed		2012-07-11 02:16:47.100823	2	0
87	Ph 7.5	natural	3	2012-07-04 00:44:52.933927	2012-07-04 00:45:17.563887	closed		2012-07-04 00:45:29.314988	11	0
85	Now show me a proposal		3	2012-07-03 00:53:17.541941	2012-07-03 00:53:17.541941	closed		2012-07-07 07:51:24.459902	38	0
81	Is this long enough?		3	2012-07-02 22:13:57.761367	2012-07-02 22:13:57.761367	closed		2012-07-07 07:53:58.466924	33	0
89	Dont show me		3	2012-07-07 08:05:53.786632	2012-07-07 08:05:53.786632	closed		2012-07-07 22:38:18.896937	11	0
88	Close this group		3	2012-07-07 07:55:35.002835	2012-07-07 07:55:35.002835	closed		2012-07-08 06:53:46.541164	31	0
79	aarons prop		3	2012-07-01 06:46:19.775275	2012-07-08 06:57:04.376065	closed		2012-07-08 06:57:04.362243	16	0
82	Italiano just like the gangstas		3	2012-07-02 22:14:53.764612	2012-07-02 22:14:53.764612	closed		2012-07-09 04:35:30.820149	2	0
93	New Proposal 24		3	2012-07-09 04:57:24.688335	2012-07-09 04:57:24.688335	closed		2012-07-09 05:55:00.424494	2	0
84	destroy or be destroyed?	Really>	3	2012-07-02 22:39:43.049105	2012-07-09 22:50:52.980651	closed		2012-07-09 22:50:52.974227	37	0
83	It looks like the bollocks to me?		3	2012-07-02 22:17:21.653885	2012-07-10 00:28:52.887975	closed		2012-07-10 00:28:52.876412	36	0
90	Test vote modal		3	2012-07-08 06:54:32.72463	2012-07-08 06:54:32.72463	closed		2012-07-10 22:11:22.080306	31	0
96	Discussion to test proposal history	This is the description that i think we should see.  At least the first 120 characters. It should include this but after awhile should cut off the description with some dots	3	2012-07-10 22:18:06.971488	2012-07-10 22:23:51.295441	closed		2012-07-10 22:42:48.361819	31	0
100	Stay open please		3	2012-07-12 03:05:30.712386	2012-07-12 04:54:01.076216	closed		2012-07-12 04:54:01.063951	46	0
104	fresh veges		3	2012-07-14 01:34:43.559801	2012-07-14 01:34:43.559801	closed		2012-07-14 07:51:10.550648	3	0
98	I am from the groups page	Group group ...	3	2012-07-11 02:58:18.754029	2012-07-11 02:58:18.754029	closed		2012-07-14 22:10:22.89563	44	0
91	Editable?		2	2012-07-08 07:08:42.927529	2012-07-15 20:58:08.225193	closed		2012-07-15 20:58:08.21899	29	0
92	Button showcase		3	2012-07-08 23:14:30.602051	2012-07-16 00:09:50.920026	closed		2012-07-16 00:09:50.908886	41	0
101	new proposal!		3	2012-07-13 01:18:33.677803	2012-07-16 02:22:34.774605	closed		2012-07-16 02:22:34.760962	47	0
95	I am new		3	2012-07-10 01:59:45.560931	2012-07-17 02:34:19.265135	closed		2012-07-17 02:34:19.25784	42	0
103	Let go fo dinner		3	2012-07-14 00:54:43.562536	2012-07-17 02:34:19.353262	closed		2012-07-17 02:34:19.348978	43	0
107	I need some spagetti	lost in space	3	2012-07-14 22:55:41.926559	2012-07-18 00:05:54.197186	closed		2012-07-18 00:05:54.18997	46	0
106	Bring em back!!!!		3	2012-07-14 22:52:06.722142	2012-07-18 00:05:54.255685	closed		2012-07-18 00:05:54.251057	3	0
105	malicious dreams on inadiciousy	Chalk me up	3	2012-07-14 22:11:21.434913	2012-07-18 00:05:54.320814	closed		2012-07-18 00:05:54.316138	44	0
97	Vote changing motion		3	2012-07-10 23:34:43.952654	2012-07-18 00:07:26.367634	closed		2012-07-18 00:07:26.361671	31	0
99	chew that cud		3	2012-07-12 01:08:20.312087	2012-07-19 01:15:41.573905	closed		2012-07-19 01:15:41.56579	45	0
110	testing		3	2012-07-20 00:01:56.088945	2012-07-23 00:13:12.699922	closed		2012-07-23 00:13:12.694038	46	0
108	in little wellington	bad ass	3	2012-07-18 05:51:41.644773	2012-07-23 02:52:16.678843	closed		2012-07-23 02:52:16.673273	1	0
109	Wheres the loading icon?		3	2012-07-19 04:54:23.321581	2012-07-23 22:25:40.945846	closed		2012-07-23 22:25:40.938484	6	0
111	like the new lightbulb idea		3	2012-07-23 02:58:34.315138	2012-07-26 05:32:00.294678	closed		2012-07-26 05:32:00.288348	44	0
114	still got it?		3	2012-07-24 20:27:31.119975	2012-07-27 23:47:58.563077	closed		2012-07-27 23:47:58.556034	45	0
113	still got it?		3	2012-07-24 20:27:28.654062	2012-07-27 23:48:18.951573	closed		2012-07-27 23:48:18.945284	45	0
102	no close date!	www.hddsuihiundcjdscisumcdskjvsdhviusdhviuhdsifuvsdfviudsfuihviusdhfiusdhfviudsiuvh@fish.com	3	2012-07-13 01:21:14.695308	2012-07-29 09:05:51.961011	closed		2012-07-29 09:13:31.945169	48	0
112	One for the girls!		3	2012-07-23 22:15:07.027144	2012-07-31 03:57:10.219485	closed		2012-07-31 03:57:10.148138	1	0
116	Let do dinner at 8		3	2012-07-30 03:18:23.541064	2012-08-04 21:30:21.827582	closed		2012-08-04 21:30:21.820691	43	0
115	try this on for size	What are you thinking this is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is is 	3	2012-07-29 09:14:25.664729	2012-08-04 21:30:22.005064	closed		2012-08-04 21:30:22.00046	48	0
118	We use Loomio to make decisions together	Weigh in here on the decision to use Loomio as a tool in this group./nIf you need more information or want to discuss the topic further before stating your position, post a comment in the discussion to the left./nYou will be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	3	2012-08-05 22:35:59.049719	2012-08-05 22:35:59.049719	voting		\N	61	0
119	We use Loomio to make decisions together	Weigh in here on the decision to use Loomio as a tool in this group./nIf you need more information or want to discuss the topic further before stating your position, post a comment in the discussion to the left./nYou will be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	3	2012-08-05 22:48:39.553714	2012-08-05 22:48:39.553714	voting		\N	62	0
117	one motion		18	2012-08-03 03:23:28.545378	2012-08-07 10:14:54.858745	closed		2012-08-07 10:14:54.852107	50	0
120	We use Loomio to make decisions together	Weigh in here on the decision to use Loomio as a tool in this group.If you need more information or want to discuss the topic further before stating your position, post a comment in the discussion to the left.If you are clear about your position, click one of the icons below (hover over with your mouse for a detailed description of what each one means)You will be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	3	2012-08-05 23:13:25.935799	2012-08-05 23:13:25.935799	voting		\N	64	0
121	We use Loomio to make decisions together	Weigh in here on the decision to use Loomio as a tool in this group.\nIf you need more information or want to discuss the topic further before stating your position, post a comment in the discussion to the left.\nIf you are clear about your position, click one of the icons below (hover over with your mouse for a detailed description of what each one means)\nYou will be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	3	2012-08-05 23:26:39.842376	2012-08-05 23:26:39.842376	voting		\N	65	0
123	We use Loomio to make decisions together	Weigh in here on the decision to use Loomio as a tool in this group.\n\nIf you need more information or want to discuss the topic further before stating your position, post a comment in the discussion to the left.\n\nIf you are clear about your position, click one of the icons below (hover over with your mouse for a detailed description of what each one means)\n\nYou will be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	3	2012-08-06 04:20:05.733068	2012-08-06 04:20:05.733068	voting		\N	67	0
125	We use Loomio to make decisions together	Weigh in here on the decision to use Loomio as a tool in this group.\n\nIf you need more information or want to discuss the topic further before stating your position, post a comment in the discussion to the left.\n\nIf you are clear about your position, click one of the icons below (hover over with your mouse for a detailed description of what each one means)\n\nYou will be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-08-07 00:13:04.41317	2012-08-07 00:13:04.41317	voting		\N	69	0
127	notorioua notifications		2	2012-08-08 20:56:56.457323	2012-08-08 20:56:56.457323	closed		2012-08-08 20:57:49.527136	71	0
122	skdfnaslf		3	2012-08-06 03:07:21.688451	2012-08-09 03:11:36.789629	closed		2012-08-09 03:11:36.783378	66	0
137	Mirror,mirror		39	2012-08-19 22:40:29.613366	2012-08-24 01:13:57.144127	closed		2012-08-24 01:13:57.127617	39	0
132	I will drop mum and dad off at 4pm	at the train station	3	2012-08-19 01:39:42.524503	2012-08-22 03:46:54.190792	closed		2012-08-22 03:46:54.171115	75	0
128	chiby is largish		2	2012-08-08 20:58:33.109024	2012-08-12 07:20:06.460071	closed		2012-08-12 07:20:06.452025	71	0
129	Friday drinks are calling		3	2012-08-10 03:24:25.896495	2012-08-11 07:29:27.258966	closed		2012-08-13 02:45:55.047808	73	2
133	still open		39	2012-08-19 07:45:54.784071	2012-08-22 08:01:45.534843	closed		2012-08-22 08:01:45.513698	46	1
134	one for the road		39	2012-08-19 07:47:01.52443	2012-08-22 10:02:37.77485	closed		2012-08-22 10:02:37.759357	73	0
142	We have a holiday on the moon	To get a feel for how Loomio works, you can participate in the decision in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-08-24 04:18:24.870132	2012-08-24 04:18:24.870132	voting		2012-08-31 04:18:24.844966	82	0
139	We should use Loomio to make decisions together	To get a feel for how Loomio works, you can participate in the decision to use Loomio in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-08-22 04:29:10.974053	2012-08-25 22:46:14.088895	closed		2012-08-25 22:46:14.074752	77	0
130	monday drinks?	This is for all the binge misters	3	2012-08-13 02:46:27.665271	2012-08-16 03:34:45.229189	closed		2012-08-16 03:34:45.221639	73	6
131	logged in user puplic group		3	2012-08-17 04:09:59.673859	2012-08-17 04:09:59.673859	closed		2012-08-17 04:23:11.313241	75	0
135	Will technology trump the mind		39	2012-08-19 21:35:50.267431	2012-08-19 21:35:50.267431	closed		2012-08-19 21:36:28.957403	40	0
138	The new z		2	2012-08-20 09:27:40.089217	2012-08-23 23:00:06.741811	closed		2012-08-23 23:00:06.727969	76	0
136	Does time eat itself?		39	2012-08-19 21:37:35.483559	2012-08-24 01:11:42.14158	closed		2012-08-24 01:11:42.014576	40	0
124	We use Loomio to make decisions together	Weigh in here on the decision to use Loomio as a tool in this group.\n\nIf you need more information or want to discuss the topic further before stating your position, post a comment in the discussion to the left.\n\nIf you are clear about your position, click one of the icons below (hover over with your mouse for a detailed description of what each one means)\n\nYou will be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	3	2012-08-06 05:16:29.63243	2012-08-06 05:16:29.63243	closed		2012-08-24 21:22:37.513449	68	0
140	testing		2	2012-08-22 10:15:58.440539	2012-08-25 22:03:08.64602	closed		2012-08-25 22:03:08.618452	75	2
141	Halaluja!		2	2012-08-22 21:32:17.589749	2012-08-25 22:05:42.040248	closed		2012-08-25 22:05:42.021621	73	0
126	We use Loomio to make decisions together	To get a feel for how Loomio works, you can participate in the decision to use Loomio in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-08-07 02:59:06.693093	2012-08-07 02:59:06.693093	closed		2012-08-28 23:57:16.807714	70	0
159	chops		18	2012-09-02 23:56:48.934733	2012-09-02 23:56:48.934733	closed		2012-09-03 01:24:55.105643	73	0
143	We should have a holiday on the moon	To get a feel for how Loomio works, you can participate in the decision in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-08-24 06:02:30.697681	2012-08-24 06:05:00.610598	closed		2012-08-24 06:05:31.706494	83	2
144	We should have a holiday on the moon	To get a feel for how Loomio works, you can participate in the decision in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-08-24 06:06:34.347466	2012-08-24 06:06:34.347466	voting		2012-08-31 06:06:34.321426	84	0
145	We should have a holiday on the moon	To get a feel for how Loomio works, you can participate in the decision in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-08-24 06:06:37.397021	2012-08-24 06:06:37.397021	voting		2012-08-31 06:06:37.370347	85	0
158	sdzvzsdv		18	2012-08-31 01:21:18.453491	2012-09-03 03:52:55.224004	closed		2012-09-03 03:52:55.193653	49	0
146	Lost the scent		3	2012-08-24 21:09:28.021304	2012-08-24 21:09:46.271409	closed		2012-08-24 21:09:58.554692	43	1
156	The jam		3	2012-08-30 20:13:30.579629	2012-09-03 22:08:45.876888	closed		2012-09-03 22:08:45.842654	43	0
148	Closeing screwed		2	2012-08-27 00:46:29.83159	2012-08-27 00:47:08.169768	closed		2012-08-29 00:08:13.139966	78	1
160	jux		3	2012-09-04 03:14:20.905936	2012-09-04 03:14:20.905936	closed		2012-09-04 03:23:54.818288	92	0
147	We should have a holiday on the moon	To get a feel for how Loomio works, you can participate in the decision in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	33	2012-08-26 02:45:42.666045	2012-08-27 10:02:34.384475	closed		2012-08-29 03:28:46.793148	86	1
149	The moon		3	2012-08-29 01:14:36.455678	2012-08-29 01:15:01.373799	closed		2012-08-29 05:00:08.046856	78	1
150	liason		3	2012-08-29 05:02:30.10402	2012-08-29 05:02:30.10402	closed		2012-08-29 05:04:53.772127	78	0
151	open 24/7		3	2012-08-29 05:08:41.003868	2012-08-29 05:08:41.003868	closed		2012-08-29 05:13:37.787371	46	0
152	Use a spoon to dig out		3	2012-08-29 21:07:01.009984	2012-08-29 21:07:01.009984	closed		2012-08-29 21:08:33.148453	87	0
153	fork it		3	2012-08-29 21:17:23.212813	2012-08-29 21:17:23.212813	closed		2012-08-29 21:24:26.581839	87	0
155	lets pull finger		3	2012-08-30 09:48:59.114049	2012-08-30 09:48:59.114049	closed		2012-08-30 20:07:02.898156	43	0
154	paquet tiles		2	2012-08-29 21:27:48.854664	2012-09-02 09:44:05.149909	closed		2012-09-02 09:44:05.1187	78	0
157	We will kick it		3	2012-08-30 22:50:08.751196	2012-09-02 23:40:17.278177	closed		2012-09-02 23:40:17.244828	73	0
169	4%	of Jack	3	2012-09-11 01:26:35.937337	2012-09-11 02:15:23.707031	closed		2012-09-11 02:15:23.702316	89	0
161	pos		3	2012-09-04 03:28:17.464239	2012-09-04 03:28:39.580582	closed		2012-09-04 06:07:38.809918	92	1
165	We should have a holiday on the moon	To get a feel for how Loomio works, you can participate in the decision in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-09-06 05:11:51.383021	2012-09-06 05:20:27.577706	voting		2012-09-13 05:11:51.189143	95	1
167	Maybe we should do it in english	Great	18	2012-09-10 01:45:11.315282	2012-09-11 04:24:50.218256	closed		2012-09-11 04:24:50.213388	90	1
162	This is a new one......		3	2012-09-04 06:16:04.71431	2012-09-07 21:26:05.848802	closed		2012-09-07 21:26:05.810635	73	2
163	Sunnies?		3	2012-09-05 03:24:12.818425	2012-09-08 04:37:00.914076	closed		2012-09-08 04:37:00.806304	89	1
164	Lets change the order of these comments		2	2012-09-06 04:04:44.550114	2012-09-09 08:04:05.011962	closed		2012-09-09 08:04:04.998176	94	0
166	No comprende		18	2012-09-10 01:44:07.164586	2012-09-10 01:44:49.89732	closed		2012-09-10 01:44:49.892692	90	0
172	bobs bar	bent	2	2012-09-11 04:59:31.844569	2012-09-15 01:54:07.664658	closed		2012-09-15 01:54:07.649621	89	0
168	Dogs not goats	teeth not horns	3	2012-09-10 23:25:24.116836	2012-09-11 04:25:23.512321	closed		2012-09-11 04:25:23.507303	96	0
170	Avatars are swanky	swanky or _anky?	3	2012-09-11 02:23:26.634895	2012-09-11 04:26:37.308426	closed		2012-09-11 04:26:37.304004	89	0
174	Example proposal - We should have a holiday on the moon	To get a feel for how Loomio works, you can participate in the decision in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-09-12 00:32:28.377023	2012-09-12 00:32:28.377023	voting		2012-09-19 00:32:28.354515	99	0
173	To add more	Love it	3	2012-09-12 00:11:53.761719	2012-09-15 01:54:07.725439	closed		2012-09-15 01:54:07.713934	98	1
175	to test close	ready?	2	2012-09-17 20:12:05.337829	2012-09-17 20:13:16.588156	closed		2012-09-17 20:13:16.580367	14	1
176	Show me your ID	You got a badge?	2	2012-09-17 20:59:53.560497	2012-09-18 02:35:46.62101	closed		2012-09-18 02:35:46.614641	21	0
177	Position	Position	2	2012-09-17 21:01:27.219671	2012-09-18 02:28:01.947723	closed		2012-09-18 02:28:01.941174	11	1
178	Could go either way	this or that	2	2012-09-18 03:21:15.443883	2012-09-18 03:24:17.522506	closed		2012-09-18 03:24:17.518592	45	0
180	dr		2	2012-09-18 04:00:01.012085	2012-09-18 04:00:01.012085	voting		2012-09-21 03:59:57	89	0
171	We should have a holiday on the moon	To get a feel for how Loomio works, you can participate in the decision in your group.\n\nIf you're clear about your position, click one of the icons below (hover over with your mouse for a description of what each one means)\n\nYou'll be prompted to make a short statement about the reason for your decision. This makes it easy to see a summary of what everyone thinks and why. You can change your mind and edit your decision freely until the proposal closes.	34	2012-09-11 02:57:38.369103	2012-09-18 03:47:57.692096	closed		2012-09-18 03:47:57.685114	97	0
179	part of diaspora		2	2012-09-18 03:40:09.596185	2012-09-18 03:59:16.283745	closed		2012-09-18 03:59:16.27727	6	1
181	boots		3	2012-09-18 09:05:51.554981	2012-09-18 09:05:51.554981	voting		2012-09-21 09:05:42	14	0
182	Wellington	Wgtn	3	2012-09-18 09:09:15.057725	2012-09-18 09:09:15.057725	voting		2012-09-21 09:08:55	88	0
183	chewy goodness		3	2012-09-18 09:19:46.817081	2012-09-18 10:04:41.587773	closed		2012-09-18 10:04:41.579234	98	0
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY notifications (id, user_id, created_at, updated_at, event_id, viewed_at) FROM stdin;
1	3	2012-08-08 20:52:46.637562	2012-08-08 20:52:46.637562	3	2012-08-08 20:53:07.543759
2	3	2012-08-08 20:54:09.427958	2012-08-08 20:54:09.427958	4	2012-08-08 20:54:22.383549
3	2	2012-08-08 20:55:12.0653	2012-08-08 20:55:12.0653	5	2012-08-08 20:55:37.32818
4	3	2012-08-08 20:58:33.266302	2012-08-08 20:58:33.266302	6	2012-08-08 20:58:49.751809
5	2	2012-08-08 20:59:11.728125	2012-08-08 20:59:11.728125	7	2012-08-08 20:59:31.915947
6	3	2012-08-11 07:07:23.334027	2012-08-11 07:07:23.334027	9	2012-08-11 07:29:38.009443
7	1	2012-08-13 02:46:28.664529	2012-08-13 02:46:28.664529	11	\N
8	14	2012-08-13 02:46:28.670925	2012-08-13 02:46:28.670925	11	\N
9	17	2012-08-13 02:46:28.675715	2012-08-13 02:46:28.675715	11	\N
11	21	2012-08-13 02:46:28.687064	2012-08-13 02:46:28.687064	11	\N
12	22	2012-08-13 02:46:28.69286	2012-08-13 02:46:28.69286	11	\N
13	23	2012-08-13 02:46:28.698214	2012-08-13 02:46:28.698214	11	\N
14	24	2012-08-13 02:46:28.703706	2012-08-13 02:46:28.703706	11	\N
15	25	2012-08-13 02:46:28.709433	2012-08-13 02:46:28.709433	11	\N
16	26	2012-08-13 02:46:28.714787	2012-08-13 02:46:28.714787	11	\N
17	27	2012-08-13 02:46:28.720122	2012-08-13 02:46:28.720122	11	\N
18	28	2012-08-13 02:46:28.72604	2012-08-13 02:46:28.72604	11	\N
19	29	2012-08-13 02:46:28.731484	2012-08-13 02:46:28.731484	11	\N
20	30	2012-08-13 02:46:28.737136	2012-08-13 02:46:28.737136	11	\N
21	31	2012-08-13 02:46:28.743045	2012-08-13 02:46:28.743045	11	\N
22	32	2012-08-13 02:46:28.74832	2012-08-13 02:46:28.74832	11	\N
23	35	2012-08-13 02:46:28.753616	2012-08-13 02:46:28.753616	11	\N
24	36	2012-08-13 02:46:28.759038	2012-08-13 02:46:28.759038	11	\N
25	1	2012-08-13 02:47:47.70278	2012-08-13 02:47:47.70278	12	\N
27	14	2012-08-13 02:47:47.713729	2012-08-13 02:47:47.713729	12	\N
28	17	2012-08-13 02:47:47.719323	2012-08-13 02:47:47.719323	12	\N
29	21	2012-08-13 02:47:47.724361	2012-08-13 02:47:47.724361	12	\N
30	22	2012-08-13 02:47:47.730443	2012-08-13 02:47:47.730443	12	\N
31	23	2012-08-13 02:47:47.736002	2012-08-13 02:47:47.736002	12	\N
32	24	2012-08-13 02:47:47.741447	2012-08-13 02:47:47.741447	12	\N
33	25	2012-08-13 02:47:47.748121	2012-08-13 02:47:47.748121	12	\N
34	26	2012-08-13 02:47:47.753877	2012-08-13 02:47:47.753877	12	\N
35	27	2012-08-13 02:47:47.759507	2012-08-13 02:47:47.759507	12	\N
36	28	2012-08-13 02:47:47.764366	2012-08-13 02:47:47.764366	12	\N
37	29	2012-08-13 02:47:47.769615	2012-08-13 02:47:47.769615	12	\N
38	30	2012-08-13 02:47:47.774753	2012-08-13 02:47:47.774753	12	\N
39	31	2012-08-13 02:47:47.779997	2012-08-13 02:47:47.779997	12	\N
40	32	2012-08-13 02:47:47.785661	2012-08-13 02:47:47.785661	12	\N
41	35	2012-08-13 02:47:47.791348	2012-08-13 02:47:47.791348	12	\N
42	36	2012-08-13 02:47:47.796709	2012-08-13 02:47:47.796709	12	\N
46	1	2012-08-15 23:29:08.584711	2012-08-15 23:29:08.584711	19	\N
47	14	2012-08-15 23:29:08.595166	2012-08-15 23:29:08.595166	19	\N
48	17	2012-08-15 23:29:08.600903	2012-08-15 23:29:08.600903	19	\N
50	21	2012-08-15 23:29:08.613018	2012-08-15 23:29:08.613018	19	\N
51	22	2012-08-15 23:29:08.618462	2012-08-15 23:29:08.618462	19	\N
52	23	2012-08-15 23:29:08.624009	2012-08-15 23:29:08.624009	19	\N
53	24	2012-08-15 23:29:08.630537	2012-08-15 23:29:08.630537	19	\N
54	25	2012-08-15 23:29:08.636143	2012-08-15 23:29:08.636143	19	\N
55	26	2012-08-15 23:29:08.641119	2012-08-15 23:29:08.641119	19	\N
56	27	2012-08-15 23:29:08.64705	2012-08-15 23:29:08.64705	19	\N
57	28	2012-08-15 23:29:08.65289	2012-08-15 23:29:08.65289	19	\N
58	29	2012-08-15 23:29:08.658392	2012-08-15 23:29:08.658392	19	\N
59	30	2012-08-15 23:29:08.663504	2012-08-15 23:29:08.663504	19	\N
60	31	2012-08-15 23:29:08.669278	2012-08-15 23:29:08.669278	19	\N
61	32	2012-08-15 23:29:08.674643	2012-08-15 23:29:08.674643	19	\N
62	35	2012-08-15 23:29:08.680732	2012-08-15 23:29:08.680732	19	\N
63	36	2012-08-15 23:29:08.686695	2012-08-15 23:29:08.686695	19	\N
64	1	2012-08-15 23:29:11.136997	2012-08-15 23:29:11.136997	20	\N
65	14	2012-08-15 23:29:11.142746	2012-08-15 23:29:11.142746	20	\N
66	17	2012-08-15 23:29:11.148099	2012-08-15 23:29:11.148099	20	\N
68	21	2012-08-15 23:29:11.158914	2012-08-15 23:29:11.158914	20	\N
69	22	2012-08-15 23:29:11.164858	2012-08-15 23:29:11.164858	20	\N
70	23	2012-08-15 23:29:11.17005	2012-08-15 23:29:11.17005	20	\N
71	24	2012-08-15 23:29:11.175451	2012-08-15 23:29:11.175451	20	\N
72	25	2012-08-15 23:29:11.18086	2012-08-15 23:29:11.18086	20	\N
73	26	2012-08-15 23:29:11.18605	2012-08-15 23:29:11.18605	20	\N
74	27	2012-08-15 23:29:11.191221	2012-08-15 23:29:11.191221	20	\N
75	28	2012-08-15 23:29:11.195891	2012-08-15 23:29:11.195891	20	\N
76	29	2012-08-15 23:29:11.200865	2012-08-15 23:29:11.200865	20	\N
77	30	2012-08-15 23:29:11.208103	2012-08-15 23:29:11.208103	20	\N
78	31	2012-08-15 23:29:11.215506	2012-08-15 23:29:11.215506	20	\N
79	32	2012-08-15 23:29:11.310215	2012-08-15 23:29:11.310215	20	\N
80	35	2012-08-15 23:29:11.317979	2012-08-15 23:29:11.317979	20	\N
81	36	2012-08-15 23:29:11.323467	2012-08-15 23:29:11.323467	20	\N
83	1	2012-08-17 04:10:00.705722	2012-08-17 04:10:00.705722	22	\N
84	14	2012-08-17 04:10:00.714852	2012-08-17 04:10:00.714852	22	\N
85	17	2012-08-17 04:10:00.720636	2012-08-17 04:10:00.720636	22	\N
86	21	2012-08-17 04:10:00.726093	2012-08-17 04:10:00.726093	22	\N
87	22	2012-08-17 04:10:00.731421	2012-08-17 04:10:00.731421	22	\N
88	23	2012-08-17 04:10:00.737052	2012-08-17 04:10:00.737052	22	\N
89	24	2012-08-17 04:10:00.742947	2012-08-17 04:10:00.742947	22	\N
90	25	2012-08-17 04:10:00.748619	2012-08-17 04:10:00.748619	22	\N
91	26	2012-08-17 04:10:00.754122	2012-08-17 04:10:00.754122	22	\N
92	27	2012-08-17 04:10:00.760027	2012-08-17 04:10:00.760027	22	\N
93	28	2012-08-17 04:10:00.765757	2012-08-17 04:10:00.765757	22	\N
94	29	2012-08-17 04:10:00.77114	2012-08-17 04:10:00.77114	22	\N
95	30	2012-08-17 04:10:00.777396	2012-08-17 04:10:00.777396	22	\N
96	31	2012-08-17 04:10:00.783336	2012-08-17 04:10:00.783336	22	\N
97	32	2012-08-17 04:10:00.789386	2012-08-17 04:10:00.789386	22	\N
98	35	2012-08-17 04:10:00.795661	2012-08-17 04:10:00.795661	22	\N
99	36	2012-08-17 04:10:00.801973	2012-08-17 04:10:00.801973	22	\N
100	1	2012-08-19 01:39:43.473507	2012-08-19 01:39:43.473507	23	\N
101	14	2012-08-19 01:39:43.482899	2012-08-19 01:39:43.482899	23	\N
102	17	2012-08-19 01:39:43.488618	2012-08-19 01:39:43.488618	23	\N
103	21	2012-08-19 01:39:43.494846	2012-08-19 01:39:43.494846	23	\N
104	22	2012-08-19 01:39:43.500059	2012-08-19 01:39:43.500059	23	\N
105	23	2012-08-19 01:39:43.504887	2012-08-19 01:39:43.504887	23	\N
106	24	2012-08-19 01:39:43.510509	2012-08-19 01:39:43.510509	23	\N
107	25	2012-08-19 01:39:43.515709	2012-08-19 01:39:43.515709	23	\N
108	26	2012-08-19 01:39:43.520814	2012-08-19 01:39:43.520814	23	\N
109	27	2012-08-19 01:39:43.526265	2012-08-19 01:39:43.526265	23	\N
110	28	2012-08-19 01:39:43.531356	2012-08-19 01:39:43.531356	23	\N
111	29	2012-08-19 01:39:43.536359	2012-08-19 01:39:43.536359	23	\N
112	30	2012-08-19 01:39:43.541188	2012-08-19 01:39:43.541188	23	\N
113	31	2012-08-19 01:39:43.546697	2012-08-19 01:39:43.546697	23	\N
114	32	2012-08-19 01:39:43.552917	2012-08-19 01:39:43.552917	23	\N
115	35	2012-08-19 01:39:43.558643	2012-08-19 01:39:43.558643	23	\N
116	36	2012-08-19 01:39:43.566201	2012-08-19 01:39:43.566201	23	\N
118	1	2012-08-19 07:45:56.849925	2012-08-19 07:45:56.849925	26	\N
26	3	2012-08-13 02:47:47.708045	2012-08-13 02:47:47.708045	12	2012-08-25 22:42:06.926511
43	3	2012-08-13 03:56:20.532096	2012-08-13 03:56:20.532096	13	2012-08-25 22:42:06.926511
44	3	2012-08-13 04:16:15.74349	2012-08-13 04:16:15.74349	14	2012-08-25 22:42:06.926511
120	14	2012-08-19 07:45:56.872681	2012-08-19 07:45:56.872681	26	\N
121	17	2012-08-19 07:45:56.887091	2012-08-19 07:45:56.887091	26	\N
122	21	2012-08-19 07:45:56.901182	2012-08-19 07:45:56.901182	26	\N
123	22	2012-08-19 07:45:56.912177	2012-08-19 07:45:56.912177	26	\N
124	23	2012-08-19 07:45:56.922449	2012-08-19 07:45:56.922449	26	\N
125	24	2012-08-19 07:45:56.932417	2012-08-19 07:45:56.932417	26	\N
126	25	2012-08-19 07:45:56.943061	2012-08-19 07:45:56.943061	26	\N
127	26	2012-08-19 07:45:56.951838	2012-08-19 07:45:56.951838	26	\N
128	27	2012-08-19 07:45:56.961522	2012-08-19 07:45:56.961522	26	\N
129	28	2012-08-19 07:45:56.971776	2012-08-19 07:45:56.971776	26	\N
130	29	2012-08-19 07:45:56.982174	2012-08-19 07:45:56.982174	26	\N
131	30	2012-08-19 07:45:56.992385	2012-08-19 07:45:56.992385	26	\N
132	31	2012-08-19 07:45:57.002866	2012-08-19 07:45:57.002866	26	\N
133	32	2012-08-19 07:45:57.012586	2012-08-19 07:45:57.012586	26	\N
134	35	2012-08-19 07:45:57.022737	2012-08-19 07:45:57.022737	26	\N
135	36	2012-08-19 07:45:57.032379	2012-08-19 07:45:57.032379	26	\N
136	1	2012-08-19 07:47:03.380505	2012-08-19 07:47:03.380505	27	\N
138	14	2012-08-19 07:47:03.401287	2012-08-19 07:47:03.401287	27	\N
139	17	2012-08-19 07:47:03.410827	2012-08-19 07:47:03.410827	27	\N
140	21	2012-08-19 07:47:03.420539	2012-08-19 07:47:03.420539	27	\N
141	22	2012-08-19 07:47:03.429961	2012-08-19 07:47:03.429961	27	\N
142	23	2012-08-19 07:47:03.440017	2012-08-19 07:47:03.440017	27	\N
143	24	2012-08-19 07:47:03.449678	2012-08-19 07:47:03.449678	27	\N
144	25	2012-08-19 07:47:03.459768	2012-08-19 07:47:03.459768	27	\N
145	26	2012-08-19 07:47:03.47594	2012-08-19 07:47:03.47594	27	\N
146	27	2012-08-19 07:47:03.486619	2012-08-19 07:47:03.486619	27	\N
147	28	2012-08-19 07:47:03.496026	2012-08-19 07:47:03.496026	27	\N
148	29	2012-08-19 07:47:03.506245	2012-08-19 07:47:03.506245	27	\N
149	30	2012-08-19 07:47:03.515778	2012-08-19 07:47:03.515778	27	\N
150	31	2012-08-19 07:47:03.525676	2012-08-19 07:47:03.525676	27	\N
151	32	2012-08-19 07:47:03.53569	2012-08-19 07:47:03.53569	27	\N
152	35	2012-08-19 07:47:03.545465	2012-08-19 07:47:03.545465	27	\N
153	36	2012-08-19 07:47:03.55508	2012-08-19 07:47:03.55508	27	\N
173	1	2012-08-19 21:26:25.604909	2012-08-19 21:26:25.604909	30	\N
175	39	2012-08-19 21:31:16.202077	2012-08-19 21:31:16.202077	31	2012-08-20 00:27:45.658532
10	2	2012-08-13 02:46:28.681553	2012-08-13 02:46:28.681553	11	2012-08-20 02:59:52.635348
49	2	2012-08-15 23:29:08.606599	2012-08-15 23:29:08.606599	19	2012-08-20 02:59:52.635348
67	2	2012-08-15 23:29:11.153782	2012-08-15 23:29:11.153782	20	2012-08-20 02:59:52.635348
181	14	2012-08-20 09:27:40.428371	2012-08-20 09:27:40.428371	37	\N
183	39	2012-08-20 09:30:35.185375	2012-08-20 09:30:35.185375	40	\N
185	1	2012-08-22 10:15:59.583365	2012-08-22 10:15:59.583365	41	\N
187	14	2012-08-22 10:15:59.599752	2012-08-22 10:15:59.599752	41	\N
188	17	2012-08-22 10:15:59.606651	2012-08-22 10:15:59.606651	41	\N
189	21	2012-08-22 10:15:59.612295	2012-08-22 10:15:59.612295	41	\N
190	22	2012-08-22 10:15:59.618953	2012-08-22 10:15:59.618953	41	\N
191	23	2012-08-22 10:15:59.62491	2012-08-22 10:15:59.62491	41	\N
192	24	2012-08-22 10:15:59.630437	2012-08-22 10:15:59.630437	41	\N
193	25	2012-08-22 10:15:59.636646	2012-08-22 10:15:59.636646	41	\N
194	26	2012-08-22 10:15:59.642679	2012-08-22 10:15:59.642679	41	\N
195	27	2012-08-22 10:15:59.647912	2012-08-22 10:15:59.647912	41	\N
196	28	2012-08-22 10:15:59.653164	2012-08-22 10:15:59.653164	41	\N
197	29	2012-08-22 10:15:59.658716	2012-08-22 10:15:59.658716	41	\N
198	30	2012-08-22 10:15:59.6651	2012-08-22 10:15:59.6651	41	\N
199	31	2012-08-22 10:15:59.671533	2012-08-22 10:15:59.671533	41	\N
200	32	2012-08-22 10:15:59.677221	2012-08-22 10:15:59.677221	41	\N
201	35	2012-08-22 10:15:59.68204	2012-08-22 10:15:59.68204	41	\N
202	36	2012-08-22 10:15:59.689001	2012-08-22 10:15:59.689001	41	\N
203	1	2012-08-22 21:32:18.473	2012-08-22 21:32:18.473	42	\N
205	14	2012-08-22 21:32:18.487595	2012-08-22 21:32:18.487595	42	\N
206	17	2012-08-22 21:32:18.493842	2012-08-22 21:32:18.493842	42	\N
207	21	2012-08-22 21:32:18.500129	2012-08-22 21:32:18.500129	42	\N
208	22	2012-08-22 21:32:18.506153	2012-08-22 21:32:18.506153	42	\N
209	23	2012-08-22 21:32:18.51264	2012-08-22 21:32:18.51264	42	\N
210	24	2012-08-22 21:32:18.518718	2012-08-22 21:32:18.518718	42	\N
211	25	2012-08-22 21:32:18.524958	2012-08-22 21:32:18.524958	42	\N
212	26	2012-08-22 21:32:18.530254	2012-08-22 21:32:18.530254	42	\N
213	27	2012-08-22 21:32:18.535582	2012-08-22 21:32:18.535582	42	\N
214	28	2012-08-22 21:32:18.542466	2012-08-22 21:32:18.542466	42	\N
215	29	2012-08-22 21:32:18.54819	2012-08-22 21:32:18.54819	42	\N
216	30	2012-08-22 21:32:18.553928	2012-08-22 21:32:18.553928	42	\N
217	31	2012-08-22 21:32:18.560281	2012-08-22 21:32:18.560281	42	\N
218	32	2012-08-22 21:32:18.566713	2012-08-22 21:32:18.566713	42	\N
219	35	2012-08-22 21:32:18.571974	2012-08-22 21:32:18.571974	42	\N
220	36	2012-08-22 21:32:18.5771	2012-08-22 21:32:18.5771	42	\N
182	2	2012-08-20 09:29:36.496799	2012-08-20 09:29:36.496799	39	2012-08-22 22:32:36.678399
222	2	2012-08-22 21:38:14.992829	2012-08-22 21:38:14.992829	44	2012-08-22 22:32:36.678399
223	1	2012-08-23 02:40:32.366784	2012-08-23 02:40:32.366784	45	\N
225	14	2012-08-23 02:40:32.38231	2012-08-23 02:40:32.38231	45	\N
226	17	2012-08-23 02:40:32.38731	2012-08-23 02:40:32.38731	45	\N
227	21	2012-08-23 02:40:32.392764	2012-08-23 02:40:32.392764	45	\N
228	22	2012-08-23 02:40:32.398222	2012-08-23 02:40:32.398222	45	\N
229	23	2012-08-23 02:40:32.403559	2012-08-23 02:40:32.403559	45	\N
230	24	2012-08-23 02:40:32.409235	2012-08-23 02:40:32.409235	45	\N
231	25	2012-08-23 02:40:32.414732	2012-08-23 02:40:32.414732	45	\N
232	26	2012-08-23 02:40:32.420522	2012-08-23 02:40:32.420522	45	\N
233	27	2012-08-23 02:40:32.426489	2012-08-23 02:40:32.426489	45	\N
234	28	2012-08-23 02:40:32.431818	2012-08-23 02:40:32.431818	45	\N
235	29	2012-08-23 02:40:32.437377	2012-08-23 02:40:32.437377	45	\N
236	30	2012-08-23 02:40:32.443268	2012-08-23 02:40:32.443268	45	\N
237	31	2012-08-23 02:40:32.448033	2012-08-23 02:40:32.448033	45	\N
238	32	2012-08-23 02:40:32.453408	2012-08-23 02:40:32.453408	45	\N
239	35	2012-08-23 02:40:32.458956	2012-08-23 02:40:32.458956	45	\N
240	36	2012-08-23 02:40:32.464232	2012-08-23 02:40:32.464232	45	\N
242	14	2012-08-23 03:19:49.709998	2012-08-23 03:19:49.709998	46	\N
243	4	2012-08-24 03:04:12.762911	2012-08-24 03:04:12.762911	47	\N
244	13	2012-08-24 03:04:12.770892	2012-08-24 03:04:12.770892	47	\N
245	16	2012-08-24 03:04:12.776299	2012-08-24 03:04:12.776299	47	\N
246	9	2012-08-24 03:04:12.781102	2012-08-24 03:04:12.781102	47	\N
247	14	2012-08-24 03:04:12.787027	2012-08-24 03:04:12.787027	47	\N
249	12	2012-08-24 03:41:57.402322	2012-08-24 03:41:57.402322	48	\N
250	14	2012-08-24 03:41:57.409678	2012-08-24 03:41:57.409678	48	\N
252	34	2012-08-24 06:03:55.854903	2012-08-24 06:03:55.854903	49	\N
253	14	2012-08-24 06:08:13.637493	2012-08-24 06:08:13.637493	50	\N
248	2	2012-08-24 03:04:12.791926	2012-08-24 03:04:12.791926	47	2012-08-26 03:21:39.335372
251	2	2012-08-24 03:41:57.414985	2012-08-24 03:41:57.414985	48	2012-08-26 03:21:39.335372
241	18	2012-08-23 03:19:49.701964	2012-08-23 03:19:49.701964	46	2012-08-30 22:54:43.6713
254	14	2012-08-24 21:09:28.141562	2012-08-24 21:09:28.141562	51	\N
45	3	2012-08-13 04:21:52.652709	2012-08-13 04:21:52.652709	15	2012-08-25 22:42:06.926511
82	3	2012-08-16 00:11:50.930129	2012-08-16 00:11:50.930129	21	2012-08-25 22:42:06.926511
119	3	2012-08-19 07:45:56.860423	2012-08-19 07:45:56.860423	26	2012-08-25 22:42:06.926511
137	3	2012-08-19 07:47:03.391429	2012-08-19 07:47:03.391429	27	2012-08-25 22:42:06.926511
174	3	2012-08-19 21:26:25.622605	2012-08-19 21:26:25.622605	30	2012-08-25 22:42:06.926511
176	3	2012-08-19 21:35:50.575809	2012-08-19 21:35:50.575809	32	2012-08-25 22:42:06.926511
177	3	2012-08-19 21:36:13.786265	2012-08-19 21:36:13.786265	33	2012-08-25 22:42:06.926511
178	3	2012-08-19 21:37:35.797105	2012-08-19 21:37:35.797105	34	2012-08-25 22:42:06.926511
179	3	2012-08-19 22:40:29.791617	2012-08-19 22:40:29.791617	35	2012-08-25 22:42:06.926511
180	3	2012-08-19 23:25:28.849573	2012-08-19 23:25:28.849573	36	2012-08-25 22:42:06.926511
184	3	2012-08-20 09:30:35.201493	2012-08-20 09:30:35.201493	40	2012-08-25 22:42:06.926511
186	3	2012-08-22 10:15:59.593615	2012-08-22 10:15:59.593615	41	2012-08-25 22:42:06.926511
204	3	2012-08-22 21:32:18.480566	2012-08-22 21:32:18.480566	42	2012-08-25 22:42:06.926511
221	3	2012-08-22 21:32:56.962671	2012-08-22 21:32:56.962671	43	2012-08-25 22:42:06.926511
224	3	2012-08-23 02:40:32.376622	2012-08-23 02:40:32.376622	45	2012-08-25 22:42:06.926511
255	1	2012-08-27 00:46:31.86221	2012-08-27 00:46:31.86221	53	\N
257	14	2012-08-27 00:46:31.888292	2012-08-27 00:46:31.888292	53	\N
258	17	2012-08-27 00:46:31.897996	2012-08-27 00:46:31.897996	53	\N
259	21	2012-08-27 00:46:31.908642	2012-08-27 00:46:31.908642	53	\N
260	22	2012-08-27 00:46:31.920457	2012-08-27 00:46:31.920457	53	\N
261	23	2012-08-27 00:46:31.930017	2012-08-27 00:46:31.930017	53	\N
262	24	2012-08-27 00:46:31.940071	2012-08-27 00:46:31.940071	53	\N
263	25	2012-08-27 00:46:31.950101	2012-08-27 00:46:31.950101	53	\N
264	26	2012-08-27 00:46:31.960424	2012-08-27 00:46:31.960424	53	\N
265	27	2012-08-27 00:46:31.971897	2012-08-27 00:46:31.971897	53	\N
266	28	2012-08-27 00:46:31.98243	2012-08-27 00:46:31.98243	53	\N
267	29	2012-08-27 00:46:31.992437	2012-08-27 00:46:31.992437	53	\N
268	30	2012-08-27 00:46:32.002774	2012-08-27 00:46:32.002774	53	\N
269	31	2012-08-27 00:46:32.012506	2012-08-27 00:46:32.012506	53	\N
270	32	2012-08-27 00:46:32.021969	2012-08-27 00:46:32.021969	53	\N
271	35	2012-08-27 00:46:32.031942	2012-08-27 00:46:32.031942	53	\N
272	36	2012-08-27 00:46:32.042163	2012-08-27 00:46:32.042163	53	\N
273	33	2012-08-27 10:03:09.467932	2012-08-27 10:03:09.467932	56	\N
256	3	2012-08-27 00:46:31.87711	2012-08-27 00:46:31.87711	53	2012-08-28 23:10:46.141947
276	1	2012-08-29 00:08:13.238391	2012-08-29 00:08:13.238391	59	\N
278	14	2012-08-29 00:08:13.25931	2012-08-29 00:08:13.25931	59	\N
279	17	2012-08-29 00:08:13.269852	2012-08-29 00:08:13.269852	59	\N
280	21	2012-08-29 00:08:13.280532	2012-08-29 00:08:13.280532	59	\N
281	22	2012-08-29 00:08:13.290897	2012-08-29 00:08:13.290897	59	\N
282	23	2012-08-29 00:08:13.302581	2012-08-29 00:08:13.302581	59	\N
283	24	2012-08-29 00:08:13.314917	2012-08-29 00:08:13.314917	59	\N
284	25	2012-08-29 00:08:13.325395	2012-08-29 00:08:13.325395	59	\N
285	26	2012-08-29 00:08:13.33565	2012-08-29 00:08:13.33565	59	\N
286	27	2012-08-29 00:08:13.346599	2012-08-29 00:08:13.346599	59	\N
287	28	2012-08-29 00:08:13.357356	2012-08-29 00:08:13.357356	59	\N
288	29	2012-08-29 00:08:13.367521	2012-08-29 00:08:13.367521	59	\N
289	30	2012-08-29 00:08:13.378585	2012-08-29 00:08:13.378585	59	\N
290	31	2012-08-29 00:08:13.388503	2012-08-29 00:08:13.388503	59	\N
291	32	2012-08-29 00:08:13.398561	2012-08-29 00:08:13.398561	59	\N
292	35	2012-08-29 00:08:13.411849	2012-08-29 00:08:13.411849	59	\N
293	36	2012-08-29 00:08:13.423263	2012-08-29 00:08:13.423263	59	\N
294	1	2012-08-29 01:14:38.710008	2012-08-29 01:14:38.710008	60	\N
295	14	2012-08-29 01:14:38.723414	2012-08-29 01:14:38.723414	60	\N
296	17	2012-08-29 01:14:38.733739	2012-08-29 01:14:38.733739	60	\N
297	21	2012-08-29 01:14:38.745795	2012-08-29 01:14:38.745795	60	\N
298	22	2012-08-29 01:14:38.759434	2012-08-29 01:14:38.759434	60	\N
299	23	2012-08-29 01:14:38.773655	2012-08-29 01:14:38.773655	60	\N
300	24	2012-08-29 01:14:38.786043	2012-08-29 01:14:38.786043	60	\N
301	25	2012-08-29 01:14:38.797766	2012-08-29 01:14:38.797766	60	\N
302	26	2012-08-29 01:14:38.808785	2012-08-29 01:14:38.808785	60	\N
303	27	2012-08-29 01:14:38.818952	2012-08-29 01:14:38.818952	60	\N
304	28	2012-08-29 01:14:38.828737	2012-08-29 01:14:38.828737	60	\N
305	29	2012-08-29 01:14:38.838538	2012-08-29 01:14:38.838538	60	\N
306	30	2012-08-29 01:14:38.849248	2012-08-29 01:14:38.849248	60	\N
307	31	2012-08-29 01:14:38.860105	2012-08-29 01:14:38.860105	60	\N
308	32	2012-08-29 01:14:38.871743	2012-08-29 01:14:38.871743	60	\N
309	35	2012-08-29 01:14:38.882767	2012-08-29 01:14:38.882767	60	\N
310	36	2012-08-29 01:14:38.89329	2012-08-29 01:14:38.89329	60	\N
311	2	2012-08-29 01:14:38.905161	2012-08-29 01:14:38.905161	60	2012-08-29 01:21:37.162707
312	2	2012-08-29 01:15:01.596098	2012-08-29 01:15:01.596098	61	2012-08-29 01:21:37.162707
313	2	2012-08-29 03:28:46.884612	2012-08-29 03:28:46.884612	62	2012-08-29 03:39:28.910998
314	1	2012-08-29 05:01:50.890034	2012-08-29 05:01:50.890034	63	\N
315	14	2012-08-29 05:01:50.903515	2012-08-29 05:01:50.903515	63	\N
316	17	2012-08-29 05:01:50.913853	2012-08-29 05:01:50.913853	63	\N
317	21	2012-08-29 05:01:50.924317	2012-08-29 05:01:50.924317	63	\N
318	22	2012-08-29 05:01:50.935209	2012-08-29 05:01:50.935209	63	\N
319	23	2012-08-29 05:01:50.946606	2012-08-29 05:01:50.946606	63	\N
320	24	2012-08-29 05:01:50.956684	2012-08-29 05:01:50.956684	63	\N
321	25	2012-08-29 05:01:50.968071	2012-08-29 05:01:50.968071	63	\N
322	26	2012-08-29 05:01:50.978279	2012-08-29 05:01:50.978279	63	\N
323	27	2012-08-29 05:01:50.989025	2012-08-29 05:01:50.989025	63	\N
324	28	2012-08-29 05:01:50.999318	2012-08-29 05:01:50.999318	63	\N
325	29	2012-08-29 05:01:51.009933	2012-08-29 05:01:51.009933	63	\N
326	30	2012-08-29 05:01:51.0214	2012-08-29 05:01:51.0214	63	\N
327	31	2012-08-29 05:01:51.032111	2012-08-29 05:01:51.032111	63	\N
328	32	2012-08-29 05:01:51.043254	2012-08-29 05:01:51.043254	63	\N
329	35	2012-08-29 05:01:51.054802	2012-08-29 05:01:51.054802	63	\N
330	36	2012-08-29 05:01:51.065367	2012-08-29 05:01:51.065367	63	\N
332	1	2012-08-29 05:03:00.58307	2012-08-29 05:03:00.58307	64	\N
333	14	2012-08-29 05:03:00.594155	2012-08-29 05:03:00.594155	64	\N
334	17	2012-08-29 05:03:00.605236	2012-08-29 05:03:00.605236	64	\N
335	21	2012-08-29 05:03:00.615743	2012-08-29 05:03:00.615743	64	\N
336	22	2012-08-29 05:03:00.626133	2012-08-29 05:03:00.626133	64	\N
337	23	2012-08-29 05:03:00.636361	2012-08-29 05:03:00.636361	64	\N
338	24	2012-08-29 05:03:00.647107	2012-08-29 05:03:00.647107	64	\N
339	25	2012-08-29 05:03:00.657336	2012-08-29 05:03:00.657336	64	\N
340	26	2012-08-29 05:03:00.666945	2012-08-29 05:03:00.666945	64	\N
341	27	2012-08-29 05:03:00.678052	2012-08-29 05:03:00.678052	64	\N
342	28	2012-08-29 05:03:00.688394	2012-08-29 05:03:00.688394	64	\N
343	29	2012-08-29 05:03:00.697902	2012-08-29 05:03:00.697902	64	\N
344	30	2012-08-29 05:03:00.708228	2012-08-29 05:03:00.708228	64	\N
345	31	2012-08-29 05:03:00.718748	2012-08-29 05:03:00.718748	64	\N
346	32	2012-08-29 05:03:00.72866	2012-08-29 05:03:00.72866	64	\N
347	35	2012-08-29 05:03:00.73857	2012-08-29 05:03:00.73857	64	\N
348	36	2012-08-29 05:03:00.748752	2012-08-29 05:03:00.748752	64	\N
350	1	2012-08-29 05:05:09.498475	2012-08-29 05:05:09.498475	65	\N
351	14	2012-08-29 05:05:09.510867	2012-08-29 05:05:09.510867	65	\N
352	17	2012-08-29 05:05:09.521261	2012-08-29 05:05:09.521261	65	\N
353	21	2012-08-29 05:05:09.53198	2012-08-29 05:05:09.53198	65	\N
354	22	2012-08-29 05:05:09.542533	2012-08-29 05:05:09.542533	65	\N
355	23	2012-08-29 05:05:09.552406	2012-08-29 05:05:09.552406	65	\N
274	18	2012-08-27 21:27:08.490526	2012-08-27 21:27:08.490526	57	2012-08-30 22:54:43.6713
275	3	2012-08-28 23:57:16.915572	2012-08-28 23:57:16.915572	58	2012-08-31 23:23:28.379169
277	3	2012-08-29 00:08:13.248753	2012-08-29 00:08:13.248753	59	2012-08-31 23:23:28.379169
356	24	2012-08-29 05:05:09.562026	2012-08-29 05:05:09.562026	65	\N
357	25	2012-08-29 05:05:09.574831	2012-08-29 05:05:09.574831	65	\N
358	26	2012-08-29 05:05:09.584437	2012-08-29 05:05:09.584437	65	\N
359	27	2012-08-29 05:05:09.595562	2012-08-29 05:05:09.595562	65	\N
360	28	2012-08-29 05:05:09.60582	2012-08-29 05:05:09.60582	65	\N
361	29	2012-08-29 05:05:09.615581	2012-08-29 05:05:09.615581	65	\N
362	30	2012-08-29 05:05:09.625503	2012-08-29 05:05:09.625503	65	\N
363	31	2012-08-29 05:05:09.635303	2012-08-29 05:05:09.635303	65	\N
364	32	2012-08-29 05:05:09.645253	2012-08-29 05:05:09.645253	65	\N
365	35	2012-08-29 05:05:09.656206	2012-08-29 05:05:09.656206	65	\N
366	36	2012-08-29 05:05:09.666119	2012-08-29 05:05:09.666119	65	\N
368	1	2012-08-29 05:08:43.286698	2012-08-29 05:08:43.286698	66	\N
369	14	2012-08-29 05:08:43.300657	2012-08-29 05:08:43.300657	66	\N
370	17	2012-08-29 05:08:43.312005	2012-08-29 05:08:43.312005	66	\N
371	21	2012-08-29 05:08:43.324415	2012-08-29 05:08:43.324415	66	\N
372	22	2012-08-29 05:08:43.336333	2012-08-29 05:08:43.336333	66	\N
373	23	2012-08-29 05:08:43.352347	2012-08-29 05:08:43.352347	66	\N
374	24	2012-08-29 05:08:43.366098	2012-08-29 05:08:43.366098	66	\N
375	25	2012-08-29 05:08:43.377237	2012-08-29 05:08:43.377237	66	\N
376	26	2012-08-29 05:08:43.388284	2012-08-29 05:08:43.388284	66	\N
377	27	2012-08-29 05:08:43.402631	2012-08-29 05:08:43.402631	66	\N
378	28	2012-08-29 05:08:43.413059	2012-08-29 05:08:43.413059	66	\N
379	29	2012-08-29 05:08:43.422923	2012-08-29 05:08:43.422923	66	\N
380	30	2012-08-29 05:08:43.433852	2012-08-29 05:08:43.433852	66	\N
381	31	2012-08-29 05:08:43.446232	2012-08-29 05:08:43.446232	66	\N
382	32	2012-08-29 05:08:43.458029	2012-08-29 05:08:43.458029	66	\N
383	35	2012-08-29 05:08:43.468508	2012-08-29 05:08:43.468508	66	\N
384	36	2012-08-29 05:08:43.478524	2012-08-29 05:08:43.478524	66	\N
386	1	2012-08-29 05:13:37.887445	2012-08-29 05:13:37.887445	67	\N
387	14	2012-08-29 05:13:37.900475	2012-08-29 05:13:37.900475	67	\N
388	17	2012-08-29 05:13:37.911274	2012-08-29 05:13:37.911274	67	\N
389	21	2012-08-29 05:13:37.922216	2012-08-29 05:13:37.922216	67	\N
390	22	2012-08-29 05:13:37.932083	2012-08-29 05:13:37.932083	67	\N
391	23	2012-08-29 05:13:37.943589	2012-08-29 05:13:37.943589	67	\N
392	24	2012-08-29 05:13:37.954325	2012-08-29 05:13:37.954325	67	\N
393	25	2012-08-29 05:13:37.963824	2012-08-29 05:13:37.963824	67	\N
394	26	2012-08-29 05:13:37.974211	2012-08-29 05:13:37.974211	67	\N
395	27	2012-08-29 05:13:37.984346	2012-08-29 05:13:37.984346	67	\N
396	28	2012-08-29 05:13:37.994911	2012-08-29 05:13:37.994911	67	\N
397	29	2012-08-29 05:13:38.005553	2012-08-29 05:13:38.005553	67	\N
398	30	2012-08-29 05:13:38.015737	2012-08-29 05:13:38.015737	67	\N
399	31	2012-08-29 05:13:38.025594	2012-08-29 05:13:38.025594	67	\N
400	32	2012-08-29 05:13:38.035919	2012-08-29 05:13:38.035919	67	\N
401	35	2012-08-29 05:13:38.045951	2012-08-29 05:13:38.045951	67	\N
402	36	2012-08-29 05:13:38.055768	2012-08-29 05:13:38.055768	67	\N
404	1	2012-08-29 21:27:51.353104	2012-08-29 21:27:51.353104	73	\N
406	14	2012-08-29 21:27:51.378555	2012-08-29 21:27:51.378555	73	\N
407	17	2012-08-29 21:27:51.388747	2012-08-29 21:27:51.388747	73	\N
408	21	2012-08-29 21:27:51.3996	2012-08-29 21:27:51.3996	73	\N
409	22	2012-08-29 21:27:51.410336	2012-08-29 21:27:51.410336	73	\N
410	23	2012-08-29 21:27:51.427322	2012-08-29 21:27:51.427322	73	\N
411	24	2012-08-29 21:27:51.44107	2012-08-29 21:27:51.44107	73	\N
412	25	2012-08-29 21:27:51.455254	2012-08-29 21:27:51.455254	73	\N
413	26	2012-08-29 21:27:51.470638	2012-08-29 21:27:51.470638	73	\N
414	27	2012-08-29 21:27:51.481291	2012-08-29 21:27:51.481291	73	\N
415	28	2012-08-29 21:27:51.491702	2012-08-29 21:27:51.491702	73	\N
416	29	2012-08-29 21:27:51.502051	2012-08-29 21:27:51.502051	73	\N
417	30	2012-08-29 21:27:51.512239	2012-08-29 21:27:51.512239	73	\N
418	31	2012-08-29 21:27:51.522485	2012-08-29 21:27:51.522485	73	\N
419	32	2012-08-29 21:27:51.532495	2012-08-29 21:27:51.532495	73	\N
420	35	2012-08-29 21:27:51.542929	2012-08-29 21:27:51.542929	73	\N
421	36	2012-08-29 21:27:51.554024	2012-08-29 21:27:51.554024	73	\N
331	2	2012-08-29 05:01:51.07556	2012-08-29 05:01:51.07556	63	2012-08-29 22:11:55.946727
349	2	2012-08-29 05:03:00.758814	2012-08-29 05:03:00.758814	64	2012-08-29 22:11:55.946727
367	2	2012-08-29 05:05:09.677031	2012-08-29 05:05:09.677031	65	2012-08-29 22:11:55.946727
385	2	2012-08-29 05:08:43.489318	2012-08-29 05:08:43.489318	66	2012-08-29 22:11:55.946727
403	2	2012-08-29 05:13:38.066444	2012-08-29 05:13:38.066444	67	2012-08-29 22:11:55.946727
422	16	2012-08-30 00:07:19.62577	2012-08-30 00:07:19.62577	74	\N
423	9	2012-08-30 00:07:19.63674	2012-08-30 00:07:19.63674	74	\N
424	4	2012-08-30 00:07:19.647501	2012-08-30 00:07:19.647501	74	\N
425	13	2012-08-30 00:07:19.653887	2012-08-30 00:07:19.653887	74	\N
426	14	2012-08-30 00:07:19.661028	2012-08-30 00:07:19.661028	74	\N
428	14	2012-08-30 03:51:37.644941	2012-08-30 03:51:37.644941	75	\N
429	14	2012-08-30 09:48:59.245684	2012-08-30 09:48:59.245684	76	\N
430	14	2012-08-30 20:07:02.956323	2012-08-30 20:07:02.956323	77	\N
431	14	2012-08-30 20:13:30.67165	2012-08-30 20:13:30.67165	78	\N
432	1	2012-08-30 22:50:09.64852	2012-08-30 22:50:09.64852	79	\N
433	14	2012-08-30 22:50:09.656015	2012-08-30 22:50:09.656015	79	\N
434	17	2012-08-30 22:50:09.664883	2012-08-30 22:50:09.664883	79	\N
435	21	2012-08-30 22:50:09.670165	2012-08-30 22:50:09.670165	79	\N
436	22	2012-08-30 22:50:09.676101	2012-08-30 22:50:09.676101	79	\N
437	23	2012-08-30 22:50:09.682658	2012-08-30 22:50:09.682658	79	\N
438	24	2012-08-30 22:50:09.689245	2012-08-30 22:50:09.689245	79	\N
439	25	2012-08-30 22:50:09.695539	2012-08-30 22:50:09.695539	79	\N
440	26	2012-08-30 22:50:09.701612	2012-08-30 22:50:09.701612	79	\N
441	27	2012-08-30 22:50:09.706846	2012-08-30 22:50:09.706846	79	\N
442	28	2012-08-30 22:50:09.713157	2012-08-30 22:50:09.713157	79	\N
443	29	2012-08-30 22:50:09.719273	2012-08-30 22:50:09.719273	79	\N
444	30	2012-08-30 22:50:09.724125	2012-08-30 22:50:09.724125	79	\N
445	31	2012-08-30 22:50:09.729186	2012-08-30 22:50:09.729186	79	\N
446	32	2012-08-30 22:50:09.734097	2012-08-30 22:50:09.734097	79	\N
447	35	2012-08-30 22:50:09.738667	2012-08-30 22:50:09.738667	79	\N
448	36	2012-08-30 22:50:09.744597	2012-08-30 22:50:09.744597	79	\N
450	14	2012-08-31 01:21:18.612854	2012-08-31 01:21:18.612854	80	\N
405	3	2012-08-29 21:27:51.367565	2012-08-29 21:27:51.367565	73	2012-08-31 23:23:28.379169
427	3	2012-08-30 00:07:19.671623	2012-08-30 00:07:19.671623	74	2012-08-31 23:23:28.379169
452	1	2012-09-01 00:01:03.234648	2012-09-01 00:01:03.234648	81	\N
453	14	2012-09-01 00:01:03.241654	2012-09-01 00:01:03.241654	81	\N
454	17	2012-09-01 00:01:03.246198	2012-09-01 00:01:03.246198	81	\N
455	21	2012-09-01 00:01:03.251755	2012-09-01 00:01:03.251755	81	\N
456	22	2012-09-01 00:01:03.257733	2012-09-01 00:01:03.257733	81	\N
457	23	2012-09-01 00:01:03.262993	2012-09-01 00:01:03.262993	81	\N
458	24	2012-09-01 00:01:03.268281	2012-09-01 00:01:03.268281	81	\N
459	25	2012-09-01 00:01:03.274525	2012-09-01 00:01:03.274525	81	\N
460	26	2012-09-01 00:01:03.279403	2012-09-01 00:01:03.279403	81	\N
461	27	2012-09-01 00:01:03.285077	2012-09-01 00:01:03.285077	81	\N
462	28	2012-09-01 00:01:03.290823	2012-09-01 00:01:03.290823	81	\N
463	29	2012-09-01 00:01:03.295722	2012-09-01 00:01:03.295722	81	\N
464	30	2012-09-01 00:01:03.30144	2012-09-01 00:01:03.30144	81	\N
465	31	2012-09-01 00:01:03.306634	2012-09-01 00:01:03.306634	81	\N
466	32	2012-09-01 00:01:03.311684	2012-09-01 00:01:03.311684	81	\N
467	35	2012-09-01 00:01:03.31806	2012-09-01 00:01:03.31806	81	\N
468	36	2012-09-01 00:01:03.324074	2012-09-01 00:01:03.324074	81	\N
470	1	2012-09-01 00:19:26.001984	2012-09-01 00:19:26.001984	82	\N
471	14	2012-09-01 00:19:26.013737	2012-09-01 00:19:26.013737	82	\N
472	17	2012-09-01 00:19:26.024025	2012-09-01 00:19:26.024025	82	\N
473	21	2012-09-01 00:19:26.035533	2012-09-01 00:19:26.035533	82	\N
474	22	2012-09-01 00:19:26.047063	2012-09-01 00:19:26.047063	82	\N
475	23	2012-09-01 00:19:26.058329	2012-09-01 00:19:26.058329	82	\N
476	24	2012-09-01 00:19:26.069317	2012-09-01 00:19:26.069317	82	\N
477	25	2012-09-01 00:19:26.079241	2012-09-01 00:19:26.079241	82	\N
478	26	2012-09-01 00:19:26.089135	2012-09-01 00:19:26.089135	82	\N
479	27	2012-09-01 00:19:26.101055	2012-09-01 00:19:26.101055	82	\N
480	28	2012-09-01 00:19:26.111663	2012-09-01 00:19:26.111663	82	\N
481	29	2012-09-01 00:19:26.122768	2012-09-01 00:19:26.122768	82	\N
482	30	2012-09-01 00:19:26.133101	2012-09-01 00:19:26.133101	82	\N
483	31	2012-09-01 00:19:26.144165	2012-09-01 00:19:26.144165	82	\N
484	32	2012-09-01 00:19:26.154571	2012-09-01 00:19:26.154571	82	\N
485	35	2012-09-01 00:19:26.164457	2012-09-01 00:19:26.164457	82	\N
486	36	2012-09-01 00:19:26.174496	2012-09-01 00:19:26.174496	82	\N
488	1	2012-09-01 00:19:55.46862	2012-09-01 00:19:55.46862	83	\N
489	14	2012-09-01 00:19:55.479319	2012-09-01 00:19:55.479319	83	\N
490	17	2012-09-01 00:19:55.49008	2012-09-01 00:19:55.49008	83	\N
491	21	2012-09-01 00:19:55.50112	2012-09-01 00:19:55.50112	83	\N
492	22	2012-09-01 00:19:55.510905	2012-09-01 00:19:55.510905	83	\N
493	23	2012-09-01 00:19:55.520673	2012-09-01 00:19:55.520673	83	\N
494	24	2012-09-01 00:19:55.530426	2012-09-01 00:19:55.530426	83	\N
495	25	2012-09-01 00:19:55.540251	2012-09-01 00:19:55.540251	83	\N
496	26	2012-09-01 00:19:55.550237	2012-09-01 00:19:55.550237	83	\N
497	27	2012-09-01 00:19:55.559316	2012-09-01 00:19:55.559316	83	\N
498	28	2012-09-01 00:19:55.569371	2012-09-01 00:19:55.569371	83	\N
499	29	2012-09-01 00:19:55.579456	2012-09-01 00:19:55.579456	83	\N
500	30	2012-09-01 00:19:55.589343	2012-09-01 00:19:55.589343	83	\N
501	31	2012-09-01 00:19:55.600015	2012-09-01 00:19:55.600015	83	\N
502	32	2012-09-01 00:19:55.6101	2012-09-01 00:19:55.6101	83	\N
503	35	2012-09-01 00:19:55.619997	2012-09-01 00:19:55.619997	83	\N
504	36	2012-09-01 00:19:55.629301	2012-09-01 00:19:55.629301	83	\N
506	14	2012-09-01 00:36:32.090459	2012-09-01 00:36:32.090459	84	\N
507	18	2012-09-01 00:38:14.113445	2012-09-01 00:38:14.113445	85	\N
509	39	2012-09-02 22:27:04.662074	2012-09-02 22:27:04.662074	86	\N
511	1	2012-09-02 23:56:51.638701	2012-09-02 23:56:51.638701	87	\N
513	14	2012-09-02 23:56:51.664027	2012-09-02 23:56:51.664027	87	\N
514	17	2012-09-02 23:56:51.676269	2012-09-02 23:56:51.676269	87	\N
515	21	2012-09-02 23:56:51.688626	2012-09-02 23:56:51.688626	87	\N
516	22	2012-09-02 23:56:51.700428	2012-09-02 23:56:51.700428	87	\N
517	23	2012-09-02 23:56:51.711903	2012-09-02 23:56:51.711903	87	\N
518	24	2012-09-02 23:56:51.723511	2012-09-02 23:56:51.723511	87	\N
519	25	2012-09-02 23:56:51.735776	2012-09-02 23:56:51.735776	87	\N
520	26	2012-09-02 23:56:51.747319	2012-09-02 23:56:51.747319	87	\N
521	27	2012-09-02 23:56:51.758908	2012-09-02 23:56:51.758908	87	\N
522	28	2012-09-02 23:56:51.771761	2012-09-02 23:56:51.771761	87	\N
523	29	2012-09-02 23:56:51.784929	2012-09-02 23:56:51.784929	87	\N
524	30	2012-09-02 23:56:51.80008	2012-09-02 23:56:51.80008	87	\N
525	31	2012-09-02 23:56:51.815063	2012-09-02 23:56:51.815063	87	\N
526	32	2012-09-02 23:56:51.834861	2012-09-02 23:56:51.834861	87	\N
527	35	2012-09-02 23:56:51.851293	2012-09-02 23:56:51.851293	87	\N
528	36	2012-09-02 23:56:51.866352	2012-09-02 23:56:51.866352	87	\N
530	1	2012-09-03 01:24:55.198919	2012-09-03 01:24:55.198919	88	\N
532	14	2012-09-03 01:24:55.219459	2012-09-03 01:24:55.219459	88	\N
533	17	2012-09-03 01:24:55.229277	2012-09-03 01:24:55.229277	88	\N
534	21	2012-09-03 01:24:55.238618	2012-09-03 01:24:55.238618	88	\N
535	22	2012-09-03 01:24:55.25116	2012-09-03 01:24:55.25116	88	\N
536	23	2012-09-03 01:24:55.263683	2012-09-03 01:24:55.263683	88	\N
537	24	2012-09-03 01:24:55.274259	2012-09-03 01:24:55.274259	88	\N
538	25	2012-09-03 01:24:55.284668	2012-09-03 01:24:55.284668	88	\N
539	26	2012-09-03 01:24:55.294315	2012-09-03 01:24:55.294315	88	\N
540	27	2012-09-03 01:24:55.304405	2012-09-03 01:24:55.304405	88	\N
541	28	2012-09-03 01:24:55.313939	2012-09-03 01:24:55.313939	88	\N
542	29	2012-09-03 01:24:55.323797	2012-09-03 01:24:55.323797	88	\N
543	30	2012-09-03 01:24:55.334023	2012-09-03 01:24:55.334023	88	\N
544	31	2012-09-03 01:24:55.343624	2012-09-03 01:24:55.343624	88	\N
545	32	2012-09-03 01:24:55.353153	2012-09-03 01:24:55.353153	88	\N
546	35	2012-09-03 01:24:55.364027	2012-09-03 01:24:55.364027	88	\N
547	36	2012-09-03 01:24:55.374185	2012-09-03 01:24:55.374185	88	\N
508	3	2012-09-02 22:27:04.649499	2012-09-02 22:27:04.649499	86	2012-09-03 23:06:12.223978
512	3	2012-09-02 23:56:51.652493	2012-09-02 23:56:51.652493	87	2012-09-03 23:06:12.223978
531	3	2012-09-03 01:24:55.209969	2012-09-03 01:24:55.209969	88	2012-09-03 23:06:12.223978
549	14	2012-09-04 03:14:21.222797	2012-09-04 03:14:21.222797	89	\N
550	14	2012-09-04 03:23:55.221184	2012-09-04 03:23:55.221184	90	\N
551	14	2012-09-04 03:28:17.895871	2012-09-04 03:28:17.895871	91	\N
552	14	2012-09-04 06:07:38.908076	2012-09-04 06:07:38.908076	93	\N
553	1	2012-09-04 06:16:06.939058	2012-09-04 06:16:06.939058	94	\N
554	14	2012-09-04 06:16:06.950352	2012-09-04 06:16:06.950352	94	\N
555	17	2012-09-04 06:16:06.959799	2012-09-04 06:16:06.959799	94	\N
556	21	2012-09-04 06:16:06.969703	2012-09-04 06:16:06.969703	94	\N
557	22	2012-09-04 06:16:06.979406	2012-09-04 06:16:06.979406	94	\N
558	23	2012-09-04 06:16:06.988862	2012-09-04 06:16:06.988862	94	\N
559	24	2012-09-04 06:16:07.001947	2012-09-04 06:16:07.001947	94	\N
560	25	2012-09-04 06:16:07.012045	2012-09-04 06:16:07.012045	94	\N
561	26	2012-09-04 06:16:07.022749	2012-09-04 06:16:07.022749	94	\N
562	27	2012-09-04 06:16:07.035105	2012-09-04 06:16:07.035105	94	\N
563	28	2012-09-04 06:16:07.148827	2012-09-04 06:16:07.148827	94	\N
564	29	2012-09-04 06:16:07.162017	2012-09-04 06:16:07.162017	94	\N
565	30	2012-09-04 06:16:07.172203	2012-09-04 06:16:07.172203	94	\N
566	31	2012-09-04 06:16:07.181611	2012-09-04 06:16:07.181611	94	\N
567	32	2012-09-04 06:16:07.192613	2012-09-04 06:16:07.192613	94	\N
568	35	2012-09-04 06:16:07.204359	2012-09-04 06:16:07.204359	94	\N
569	36	2012-09-04 06:16:07.21597	2012-09-04 06:16:07.21597	94	\N
571	18	2012-09-04 06:16:07.241576	2012-09-04 06:16:07.241576	94	\N
572	1	2012-09-05 03:24:16.10199	2012-09-05 03:24:16.10199	96	\N
573	14	2012-09-05 03:24:16.120638	2012-09-05 03:24:16.120638	96	\N
574	17	2012-09-05 03:24:16.136323	2012-09-05 03:24:16.136323	96	\N
575	21	2012-09-05 03:24:16.155459	2012-09-05 03:24:16.155459	96	\N
576	22	2012-09-05 03:24:16.171491	2012-09-05 03:24:16.171491	96	\N
577	23	2012-09-05 03:24:16.189076	2012-09-05 03:24:16.189076	96	\N
578	24	2012-09-05 03:24:16.204946	2012-09-05 03:24:16.204946	96	\N
579	25	2012-09-05 03:24:16.222497	2012-09-05 03:24:16.222497	96	\N
580	26	2012-09-05 03:24:16.244107	2012-09-05 03:24:16.244107	96	\N
581	27	2012-09-05 03:24:16.433534	2012-09-05 03:24:16.433534	96	\N
582	28	2012-09-05 03:24:16.454724	2012-09-05 03:24:16.454724	96	\N
583	29	2012-09-05 03:24:16.473294	2012-09-05 03:24:16.473294	96	\N
584	30	2012-09-05 03:24:16.491416	2012-09-05 03:24:16.491416	96	\N
585	31	2012-09-05 03:24:16.508613	2012-09-05 03:24:16.508613	96	\N
586	32	2012-09-05 03:24:16.524276	2012-09-05 03:24:16.524276	96	\N
587	35	2012-09-05 03:24:16.542106	2012-09-05 03:24:16.542106	96	\N
588	36	2012-09-05 03:24:16.560441	2012-09-05 03:24:16.560441	96	\N
590	18	2012-09-05 03:24:16.596969	2012-09-05 03:24:16.596969	96	\N
487	2	2012-09-01 00:19:26.186543	2012-09-01 00:19:26.186543	82	2012-09-06 01:13:50.14305
592	39	2012-09-05 20:15:02.519367	2012-09-05 20:15:02.519367	97	\N
591	3	2012-09-05 20:15:02.507816	2012-09-05 20:15:02.507816	97	2012-09-05 20:46:14.365194
449	2	2012-08-30 22:50:09.751362	2012-08-30 22:50:09.751362	79	2012-09-06 01:13:50.14305
451	2	2012-08-31 01:21:18.620327	2012-08-31 01:21:18.620327	80	2012-09-06 01:13:50.14305
469	2	2012-09-01 00:01:03.329742	2012-09-01 00:01:03.329742	81	2012-09-06 01:13:50.14305
505	2	2012-09-01 00:19:55.63954	2012-09-01 00:19:55.63954	83	2012-09-06 01:13:50.14305
510	2	2012-09-02 22:27:04.673071	2012-09-02 22:27:04.673071	86	2012-09-06 01:13:50.14305
529	2	2012-09-02 23:56:51.880443	2012-09-02 23:56:51.880443	87	2012-09-06 01:13:50.14305
548	2	2012-09-03 01:24:55.384737	2012-09-03 01:24:55.384737	88	2012-09-06 01:13:50.14305
570	2	2012-09-04 06:16:07.229268	2012-09-04 06:16:07.229268	94	2012-09-06 01:13:50.14305
589	2	2012-09-05 03:24:16.57967	2012-09-05 03:24:16.57967	96	2012-09-06 01:13:50.14305
593	3	2012-09-05 22:25:19.189369	2012-09-05 22:25:19.189369	98	2012-09-06 02:38:20.861767
594	3	2012-09-06 01:09:13.522161	2012-09-06 01:09:13.522161	99	2012-09-06 02:38:20.861767
595	18	2012-09-06 02:39:34.477428	2012-09-06 02:39:34.477428	101	\N
596	39	2012-09-06 02:39:34.49151	2012-09-06 02:39:34.49151	101	\N
598	18	2012-09-06 02:39:57.891988	2012-09-06 02:39:57.891988	102	\N
599	39	2012-09-06 02:39:57.906096	2012-09-06 02:39:57.906096	102	\N
601	18	2012-09-06 02:45:39.202934	2012-09-06 02:45:39.202934	103	\N
602	39	2012-09-06 02:45:39.215781	2012-09-06 02:45:39.215781	103	\N
605	18	2012-09-06 03:57:12.259583	2012-09-06 03:57:12.259583	105	\N
607	39	2012-09-06 03:57:12.287981	2012-09-06 03:57:12.287981	105	\N
608	1	2012-09-06 04:02:53.52509	2012-09-06 04:02:53.52509	106	\N
610	14	2012-09-06 04:02:53.546742	2012-09-06 04:02:53.546742	106	\N
611	17	2012-09-06 04:02:53.556061	2012-09-06 04:02:53.556061	106	\N
612	21	2012-09-06 04:02:53.566318	2012-09-06 04:02:53.566318	106	\N
613	22	2012-09-06 04:02:53.575503	2012-09-06 04:02:53.575503	106	\N
614	23	2012-09-06 04:02:53.585988	2012-09-06 04:02:53.585988	106	\N
615	24	2012-09-06 04:02:53.597514	2012-09-06 04:02:53.597514	106	\N
616	25	2012-09-06 04:02:53.60749	2012-09-06 04:02:53.60749	106	\N
617	26	2012-09-06 04:02:53.618667	2012-09-06 04:02:53.618667	106	\N
618	27	2012-09-06 04:02:53.629138	2012-09-06 04:02:53.629138	106	\N
619	28	2012-09-06 04:02:53.639324	2012-09-06 04:02:53.639324	106	\N
620	29	2012-09-06 04:02:53.649436	2012-09-06 04:02:53.649436	106	\N
621	30	2012-09-06 04:02:53.658773	2012-09-06 04:02:53.658773	106	\N
622	31	2012-09-06 04:02:53.668633	2012-09-06 04:02:53.668633	106	\N
623	32	2012-09-06 04:02:53.678215	2012-09-06 04:02:53.678215	106	\N
624	35	2012-09-06 04:02:53.688555	2012-09-06 04:02:53.688555	106	\N
625	36	2012-09-06 04:02:53.698752	2012-09-06 04:02:53.698752	106	\N
626	18	2012-09-06 04:02:53.708279	2012-09-06 04:02:53.708279	106	\N
627	1	2012-09-06 04:04:46.72083	2012-09-06 04:04:46.72083	110	\N
629	14	2012-09-06 04:04:46.740438	2012-09-06 04:04:46.740438	110	\N
630	17	2012-09-06 04:04:46.750257	2012-09-06 04:04:46.750257	110	\N
631	21	2012-09-06 04:04:46.760324	2012-09-06 04:04:46.760324	110	\N
632	22	2012-09-06 04:04:46.770594	2012-09-06 04:04:46.770594	110	\N
633	23	2012-09-06 04:04:46.780511	2012-09-06 04:04:46.780511	110	\N
634	24	2012-09-06 04:04:46.790738	2012-09-06 04:04:46.790738	110	\N
635	25	2012-09-06 04:04:46.80186	2012-09-06 04:04:46.80186	110	\N
636	26	2012-09-06 04:04:46.81228	2012-09-06 04:04:46.81228	110	\N
637	27	2012-09-06 04:04:46.822449	2012-09-06 04:04:46.822449	110	\N
638	28	2012-09-06 04:04:46.832934	2012-09-06 04:04:46.832934	110	\N
639	29	2012-09-06 04:04:46.843484	2012-09-06 04:04:46.843484	110	\N
640	30	2012-09-06 04:04:46.852532	2012-09-06 04:04:46.852532	110	\N
641	31	2012-09-06 04:04:46.862545	2012-09-06 04:04:46.862545	110	\N
642	32	2012-09-06 04:04:46.872575	2012-09-06 04:04:46.872575	110	\N
643	35	2012-09-06 04:04:46.885528	2012-09-06 04:04:46.885528	110	\N
644	36	2012-09-06 04:04:46.898955	2012-09-06 04:04:46.898955	110	\N
645	18	2012-09-06 04:04:46.9088	2012-09-06 04:04:46.9088	110	\N
646	40	2012-09-06 05:07:52.023333	2012-09-06 05:07:52.023333	112	\N
647	34	2012-09-06 05:20:27.648072	2012-09-06 05:20:27.648072	113	\N
650	40	2012-09-08 00:22:24.885544	2012-09-08 00:22:24.885544	117	\N
597	2	2012-09-06 02:39:34.503787	2012-09-06 02:39:34.503787	101	2012-09-09 09:10:53.25685
600	2	2012-09-06 02:39:57.917835	2012-09-06 02:39:57.917835	102	2012-09-09 09:10:53.25685
603	2	2012-09-06 02:45:39.23035	2012-09-06 02:45:39.23035	103	2012-09-09 09:10:53.25685
651	1	2012-09-10 01:44:08.145516	2012-09-10 01:44:08.145516	118	\N
653	14	2012-09-10 01:44:08.161958	2012-09-10 01:44:08.161958	118	\N
654	17	2012-09-10 01:44:08.1678	2012-09-10 01:44:08.1678	118	\N
655	21	2012-09-10 01:44:08.173147	2012-09-10 01:44:08.173147	118	\N
656	22	2012-09-10 01:44:08.178419	2012-09-10 01:44:08.178419	118	\N
657	23	2012-09-10 01:44:08.185499	2012-09-10 01:44:08.185499	118	\N
658	24	2012-09-10 01:44:08.192161	2012-09-10 01:44:08.192161	118	\N
659	25	2012-09-10 01:44:08.1973	2012-09-10 01:44:08.1973	118	\N
660	26	2012-09-10 01:44:08.203367	2012-09-10 01:44:08.203367	118	\N
661	27	2012-09-10 01:44:08.208821	2012-09-10 01:44:08.208821	118	\N
662	28	2012-09-10 01:44:08.215348	2012-09-10 01:44:08.215348	118	\N
663	29	2012-09-10 01:44:08.22025	2012-09-10 01:44:08.22025	118	\N
664	30	2012-09-10 01:44:08.225744	2012-09-10 01:44:08.225744	118	\N
665	31	2012-09-10 01:44:08.232377	2012-09-10 01:44:08.232377	118	\N
666	32	2012-09-10 01:44:08.23925	2012-09-10 01:44:08.23925	118	\N
667	35	2012-09-10 01:44:08.244677	2012-09-10 01:44:08.244677	118	\N
668	36	2012-09-10 01:44:08.252199	2012-09-10 01:44:08.252199	118	\N
670	40	2012-09-10 01:44:08.264296	2012-09-10 01:44:08.264296	118	\N
671	1	2012-09-10 01:44:49.952928	2012-09-10 01:44:49.952928	119	\N
673	14	2012-09-10 01:44:49.96576	2012-09-10 01:44:49.96576	119	\N
674	17	2012-09-10 01:44:49.971024	2012-09-10 01:44:49.971024	119	\N
675	21	2012-09-10 01:44:49.97626	2012-09-10 01:44:49.97626	119	\N
676	22	2012-09-10 01:44:49.98153	2012-09-10 01:44:49.98153	119	\N
677	23	2012-09-10 01:44:49.987125	2012-09-10 01:44:49.987125	119	\N
678	24	2012-09-10 01:44:49.992409	2012-09-10 01:44:49.992409	119	\N
679	25	2012-09-10 01:44:49.99812	2012-09-10 01:44:49.99812	119	\N
680	26	2012-09-10 01:44:50.004773	2012-09-10 01:44:50.004773	119	\N
681	27	2012-09-10 01:44:50.010758	2012-09-10 01:44:50.010758	119	\N
682	28	2012-09-10 01:44:50.016761	2012-09-10 01:44:50.016761	119	\N
683	29	2012-09-10 01:44:50.022091	2012-09-10 01:44:50.022091	119	\N
684	30	2012-09-10 01:44:50.02746	2012-09-10 01:44:50.02746	119	\N
685	31	2012-09-10 01:44:50.033025	2012-09-10 01:44:50.033025	119	\N
686	32	2012-09-10 01:44:50.03841	2012-09-10 01:44:50.03841	119	\N
687	35	2012-09-10 01:44:50.044002	2012-09-10 01:44:50.044002	119	\N
688	36	2012-09-10 01:44:50.049665	2012-09-10 01:44:50.049665	119	\N
690	40	2012-09-10 01:44:50.060325	2012-09-10 01:44:50.060325	119	\N
691	1	2012-09-10 01:45:12.199565	2012-09-10 01:45:12.199565	120	\N
693	14	2012-09-10 01:45:12.366005	2012-09-10 01:45:12.366005	120	\N
694	17	2012-09-10 01:45:12.372974	2012-09-10 01:45:12.372974	120	\N
695	21	2012-09-10 01:45:12.378573	2012-09-10 01:45:12.378573	120	\N
696	22	2012-09-10 01:45:12.384408	2012-09-10 01:45:12.384408	120	\N
697	23	2012-09-10 01:45:12.39006	2012-09-10 01:45:12.39006	120	\N
698	24	2012-09-10 01:45:12.395674	2012-09-10 01:45:12.395674	120	\N
699	25	2012-09-10 01:45:12.401037	2012-09-10 01:45:12.401037	120	\N
669	2	2012-09-10 01:44:08.259023	2012-09-10 01:44:08.259023	118	2012-09-11 04:13:18.902856
689	2	2012-09-10 01:44:50.055152	2012-09-10 01:44:50.055152	119	2012-09-11 04:13:18.902856
700	26	2012-09-10 01:45:12.406836	2012-09-10 01:45:12.406836	120	\N
701	27	2012-09-10 01:45:12.413155	2012-09-10 01:45:12.413155	120	\N
702	28	2012-09-10 01:45:12.418522	2012-09-10 01:45:12.418522	120	\N
703	29	2012-09-10 01:45:12.423859	2012-09-10 01:45:12.423859	120	\N
704	30	2012-09-10 01:45:12.429074	2012-09-10 01:45:12.429074	120	\N
705	31	2012-09-10 01:45:12.434273	2012-09-10 01:45:12.434273	120	\N
706	32	2012-09-10 01:45:12.440231	2012-09-10 01:45:12.440231	120	\N
707	35	2012-09-10 01:45:12.445073	2012-09-10 01:45:12.445073	120	\N
708	36	2012-09-10 01:45:12.450408	2012-09-10 01:45:12.450408	120	\N
710	40	2012-09-10 01:45:12.463209	2012-09-10 01:45:12.463209	120	\N
711	41	2012-09-10 05:19:01.271576	2012-09-10 05:19:01.271576	121	\N
604	3	2012-09-06 03:56:32.432258	2012-09-06 03:56:32.432258	104	2012-09-10 22:57:26.042929
606	3	2012-09-06 03:57:12.274932	2012-09-06 03:57:12.274932	105	2012-09-10 22:57:26.042929
609	3	2012-09-06 04:02:53.536086	2012-09-06 04:02:53.536086	106	2012-09-10 22:57:26.042929
628	3	2012-09-06 04:04:46.730955	2012-09-06 04:04:46.730955	110	2012-09-10 22:57:26.042929
648	3	2012-09-06 05:43:00.199507	2012-09-06 05:43:00.199507	114	2012-09-10 22:57:26.042929
649	3	2012-09-07 21:28:26.3716	2012-09-07 21:28:26.3716	116	2012-09-10 22:57:26.042929
652	3	2012-09-10 01:44:08.155475	2012-09-10 01:44:08.155475	118	2012-09-10 22:57:26.042929
672	3	2012-09-10 01:44:49.960215	2012-09-10 01:44:49.960215	119	2012-09-10 22:57:26.042929
692	3	2012-09-10 01:45:12.356536	2012-09-10 01:45:12.356536	120	2012-09-10 22:57:26.042929
712	18	2012-09-10 22:57:37.155767	2012-09-10 22:57:37.155767	122	\N
713	1	2012-09-10 23:14:42.258668	2012-09-10 23:14:42.258668	123	\N
714	14	2012-09-10 23:14:42.264518	2012-09-10 23:14:42.264518	123	\N
715	17	2012-09-10 23:14:42.269531	2012-09-10 23:14:42.269531	123	\N
716	21	2012-09-10 23:14:42.274838	2012-09-10 23:14:42.274838	123	\N
717	22	2012-09-10 23:14:42.2803	2012-09-10 23:14:42.2803	123	\N
718	23	2012-09-10 23:14:42.285621	2012-09-10 23:14:42.285621	123	\N
719	24	2012-09-10 23:14:42.294467	2012-09-10 23:14:42.294467	123	\N
720	25	2012-09-10 23:14:42.300309	2012-09-10 23:14:42.300309	123	\N
721	26	2012-09-10 23:14:42.306036	2012-09-10 23:14:42.306036	123	\N
722	27	2012-09-10 23:14:42.311396	2012-09-10 23:14:42.311396	123	\N
723	28	2012-09-10 23:14:42.317056	2012-09-10 23:14:42.317056	123	\N
724	29	2012-09-10 23:14:42.322394	2012-09-10 23:14:42.322394	123	\N
725	30	2012-09-10 23:14:42.327941	2012-09-10 23:14:42.327941	123	\N
726	31	2012-09-10 23:14:42.333222	2012-09-10 23:14:42.333222	123	\N
727	32	2012-09-10 23:14:42.338562	2012-09-10 23:14:42.338562	123	\N
728	35	2012-09-10 23:14:42.344197	2012-09-10 23:14:42.344197	123	\N
729	36	2012-09-10 23:14:42.350414	2012-09-10 23:14:42.350414	123	\N
731	18	2012-09-10 23:14:42.361103	2012-09-10 23:14:42.361103	123	\N
732	40	2012-09-10 23:14:42.366258	2012-09-10 23:14:42.366258	123	\N
733	41	2012-09-10 23:14:42.371922	2012-09-10 23:14:42.371922	123	\N
734	1	2012-09-10 23:25:25.135523	2012-09-10 23:25:25.135523	124	\N
735	14	2012-09-10 23:25:25.142479	2012-09-10 23:25:25.142479	124	\N
736	17	2012-09-10 23:25:25.148767	2012-09-10 23:25:25.148767	124	\N
737	21	2012-09-10 23:25:25.155325	2012-09-10 23:25:25.155325	124	\N
738	22	2012-09-10 23:25:25.1615	2012-09-10 23:25:25.1615	124	\N
739	23	2012-09-10 23:25:25.167305	2012-09-10 23:25:25.167305	124	\N
740	24	2012-09-10 23:25:25.174157	2012-09-10 23:25:25.174157	124	\N
741	25	2012-09-10 23:25:25.180559	2012-09-10 23:25:25.180559	124	\N
742	26	2012-09-10 23:25:25.188291	2012-09-10 23:25:25.188291	124	\N
743	27	2012-09-10 23:25:25.194735	2012-09-10 23:25:25.194735	124	\N
744	28	2012-09-10 23:25:25.202488	2012-09-10 23:25:25.202488	124	\N
745	29	2012-09-10 23:25:25.209148	2012-09-10 23:25:25.209148	124	\N
746	30	2012-09-10 23:25:25.215034	2012-09-10 23:25:25.215034	124	\N
747	31	2012-09-10 23:25:25.221083	2012-09-10 23:25:25.221083	124	\N
748	32	2012-09-10 23:25:25.227837	2012-09-10 23:25:25.227837	124	\N
749	35	2012-09-10 23:25:25.233442	2012-09-10 23:25:25.233442	124	\N
750	36	2012-09-10 23:25:25.23822	2012-09-10 23:25:25.23822	124	\N
752	18	2012-09-10 23:25:25.249113	2012-09-10 23:25:25.249113	124	\N
753	40	2012-09-10 23:25:25.254168	2012-09-10 23:25:25.254168	124	\N
754	41	2012-09-10 23:25:25.260442	2012-09-10 23:25:25.260442	124	\N
755	1	2012-09-11 01:26:36.859346	2012-09-11 01:26:36.859346	125	\N
756	14	2012-09-11 01:26:36.865057	2012-09-11 01:26:36.865057	125	\N
757	17	2012-09-11 01:26:36.870164	2012-09-11 01:26:36.870164	125	\N
758	21	2012-09-11 01:26:36.878	2012-09-11 01:26:36.878	125	\N
759	22	2012-09-11 01:26:36.883929	2012-09-11 01:26:36.883929	125	\N
760	23	2012-09-11 01:26:36.890237	2012-09-11 01:26:36.890237	125	\N
761	24	2012-09-11 01:26:36.895468	2012-09-11 01:26:36.895468	125	\N
762	25	2012-09-11 01:26:36.900261	2012-09-11 01:26:36.900261	125	\N
763	26	2012-09-11 01:26:36.906244	2012-09-11 01:26:36.906244	125	\N
764	27	2012-09-11 01:26:36.911347	2012-09-11 01:26:36.911347	125	\N
765	28	2012-09-11 01:26:36.916226	2012-09-11 01:26:36.916226	125	\N
766	29	2012-09-11 01:26:36.921317	2012-09-11 01:26:36.921317	125	\N
767	30	2012-09-11 01:26:36.926412	2012-09-11 01:26:36.926412	125	\N
768	31	2012-09-11 01:26:36.93285	2012-09-11 01:26:36.93285	125	\N
769	32	2012-09-11 01:26:36.939046	2012-09-11 01:26:36.939046	125	\N
770	35	2012-09-11 01:26:36.944791	2012-09-11 01:26:36.944791	125	\N
771	36	2012-09-11 01:26:36.9512	2012-09-11 01:26:36.9512	125	\N
773	18	2012-09-11 01:26:36.962804	2012-09-11 01:26:36.962804	125	\N
774	40	2012-09-11 01:26:36.969154	2012-09-11 01:26:36.969154	125	\N
775	41	2012-09-11 01:26:36.976369	2012-09-11 01:26:36.976369	125	\N
776	1	2012-09-11 02:15:23.762854	2012-09-11 02:15:23.762854	126	\N
777	14	2012-09-11 02:15:23.768882	2012-09-11 02:15:23.768882	126	\N
778	17	2012-09-11 02:15:23.77435	2012-09-11 02:15:23.77435	126	\N
779	21	2012-09-11 02:15:23.779444	2012-09-11 02:15:23.779444	126	\N
780	22	2012-09-11 02:15:23.784711	2012-09-11 02:15:23.784711	126	\N
781	23	2012-09-11 02:15:23.789768	2012-09-11 02:15:23.789768	126	\N
782	24	2012-09-11 02:15:23.795159	2012-09-11 02:15:23.795159	126	\N
783	25	2012-09-11 02:15:23.801621	2012-09-11 02:15:23.801621	126	\N
784	26	2012-09-11 02:15:23.807306	2012-09-11 02:15:23.807306	126	\N
785	27	2012-09-11 02:15:23.812602	2012-09-11 02:15:23.812602	126	\N
786	28	2012-09-11 02:15:23.819039	2012-09-11 02:15:23.819039	126	\N
787	29	2012-09-11 02:15:23.824537	2012-09-11 02:15:23.824537	126	\N
788	30	2012-09-11 02:15:23.830941	2012-09-11 02:15:23.830941	126	\N
789	31	2012-09-11 02:15:23.836517	2012-09-11 02:15:23.836517	126	\N
790	32	2012-09-11 02:15:23.841751	2012-09-11 02:15:23.841751	126	\N
791	35	2012-09-11 02:15:23.847064	2012-09-11 02:15:23.847064	126	\N
792	36	2012-09-11 02:15:23.852731	2012-09-11 02:15:23.852731	126	\N
794	18	2012-09-11 02:15:23.863391	2012-09-11 02:15:23.863391	126	\N
795	40	2012-09-11 02:15:23.868479	2012-09-11 02:15:23.868479	126	\N
796	41	2012-09-11 02:15:23.873632	2012-09-11 02:15:23.873632	126	\N
797	1	2012-09-11 02:23:27.568147	2012-09-11 02:23:27.568147	127	\N
798	14	2012-09-11 02:23:27.575561	2012-09-11 02:23:27.575561	127	\N
799	17	2012-09-11 02:23:27.581874	2012-09-11 02:23:27.581874	127	\N
800	21	2012-09-11 02:23:27.587606	2012-09-11 02:23:27.587606	127	\N
801	22	2012-09-11 02:23:27.59351	2012-09-11 02:23:27.59351	127	\N
802	23	2012-09-11 02:23:27.59926	2012-09-11 02:23:27.59926	127	\N
803	24	2012-09-11 02:23:27.606325	2012-09-11 02:23:27.606325	127	\N
804	25	2012-09-11 02:23:27.614083	2012-09-11 02:23:27.614083	127	\N
805	26	2012-09-11 02:23:27.620794	2012-09-11 02:23:27.620794	127	\N
806	27	2012-09-11 02:23:27.626424	2012-09-11 02:23:27.626424	127	\N
807	28	2012-09-11 02:23:27.631794	2012-09-11 02:23:27.631794	127	\N
808	29	2012-09-11 02:23:27.637476	2012-09-11 02:23:27.637476	127	\N
809	30	2012-09-11 02:23:27.643279	2012-09-11 02:23:27.643279	127	\N
810	31	2012-09-11 02:23:27.648496	2012-09-11 02:23:27.648496	127	\N
811	32	2012-09-11 02:23:27.654624	2012-09-11 02:23:27.654624	127	\N
812	35	2012-09-11 02:23:27.660008	2012-09-11 02:23:27.660008	127	\N
813	36	2012-09-11 02:23:27.665583	2012-09-11 02:23:27.665583	127	\N
815	18	2012-09-11 02:23:27.676463	2012-09-11 02:23:27.676463	127	\N
816	40	2012-09-11 02:23:27.681303	2012-09-11 02:23:27.681303	127	\N
817	41	2012-09-11 02:23:27.686433	2012-09-11 02:23:27.686433	127	\N
709	2	2012-09-10 01:45:12.456731	2012-09-10 01:45:12.456731	120	2012-09-11 04:13:18.902856
730	2	2012-09-10 23:14:42.35553	2012-09-10 23:14:42.35553	123	2012-09-11 04:13:18.902856
751	2	2012-09-10 23:25:25.243695	2012-09-10 23:25:25.243695	124	2012-09-11 04:13:18.902856
772	2	2012-09-11 01:26:36.957173	2012-09-11 01:26:36.957173	125	2012-09-11 04:13:18.902856
793	2	2012-09-11 02:15:23.858624	2012-09-11 02:15:23.858624	126	2012-09-11 04:13:18.902856
814	2	2012-09-11 02:23:27.670844	2012-09-11 02:23:27.670844	127	2012-09-11 04:13:18.902856
818	1	2012-09-11 04:24:50.27889	2012-09-11 04:24:50.27889	128	\N
819	14	2012-09-11 04:24:50.286165	2012-09-11 04:24:50.286165	128	\N
820	17	2012-09-11 04:24:50.291784	2012-09-11 04:24:50.291784	128	\N
821	21	2012-09-11 04:24:50.296926	2012-09-11 04:24:50.296926	128	\N
822	22	2012-09-11 04:24:50.302319	2012-09-11 04:24:50.302319	128	\N
823	23	2012-09-11 04:24:50.308498	2012-09-11 04:24:50.308498	128	\N
824	24	2012-09-11 04:24:50.314343	2012-09-11 04:24:50.314343	128	\N
825	25	2012-09-11 04:24:50.320965	2012-09-11 04:24:50.320965	128	\N
826	26	2012-09-11 04:24:50.326315	2012-09-11 04:24:50.326315	128	\N
827	27	2012-09-11 04:24:50.331959	2012-09-11 04:24:50.331959	128	\N
828	28	2012-09-11 04:24:50.337821	2012-09-11 04:24:50.337821	128	\N
829	29	2012-09-11 04:24:50.343028	2012-09-11 04:24:50.343028	128	\N
830	30	2012-09-11 04:24:50.348412	2012-09-11 04:24:50.348412	128	\N
831	31	2012-09-11 04:24:50.353858	2012-09-11 04:24:50.353858	128	\N
832	32	2012-09-11 04:24:50.359294	2012-09-11 04:24:50.359294	128	\N
833	35	2012-09-11 04:24:50.365657	2012-09-11 04:24:50.365657	128	\N
834	36	2012-09-11 04:24:50.370797	2012-09-11 04:24:50.370797	128	\N
836	18	2012-09-11 04:24:50.381116	2012-09-11 04:24:50.381116	128	\N
837	40	2012-09-11 04:24:50.387463	2012-09-11 04:24:50.387463	128	\N
838	41	2012-09-11 04:24:50.392526	2012-09-11 04:24:50.392526	128	\N
839	1	2012-09-11 04:25:23.572363	2012-09-11 04:25:23.572363	129	\N
840	14	2012-09-11 04:25:23.578167	2012-09-11 04:25:23.578167	129	\N
841	17	2012-09-11 04:25:23.583423	2012-09-11 04:25:23.583423	129	\N
842	21	2012-09-11 04:25:23.588778	2012-09-11 04:25:23.588778	129	\N
843	22	2012-09-11 04:25:23.595199	2012-09-11 04:25:23.595199	129	\N
844	23	2012-09-11 04:25:23.601312	2012-09-11 04:25:23.601312	129	\N
845	24	2012-09-11 04:25:23.606851	2012-09-11 04:25:23.606851	129	\N
846	25	2012-09-11 04:25:23.612228	2012-09-11 04:25:23.612228	129	\N
847	26	2012-09-11 04:25:23.617794	2012-09-11 04:25:23.617794	129	\N
848	27	2012-09-11 04:25:23.623588	2012-09-11 04:25:23.623588	129	\N
849	28	2012-09-11 04:25:23.628872	2012-09-11 04:25:23.628872	129	\N
850	29	2012-09-11 04:25:23.63415	2012-09-11 04:25:23.63415	129	\N
851	30	2012-09-11 04:25:23.639427	2012-09-11 04:25:23.639427	129	\N
852	31	2012-09-11 04:25:23.64581	2012-09-11 04:25:23.64581	129	\N
853	32	2012-09-11 04:25:23.651284	2012-09-11 04:25:23.651284	129	\N
854	35	2012-09-11 04:25:23.656573	2012-09-11 04:25:23.656573	129	\N
855	36	2012-09-11 04:25:23.662046	2012-09-11 04:25:23.662046	129	\N
857	18	2012-09-11 04:25:23.673223	2012-09-11 04:25:23.673223	129	\N
858	40	2012-09-11 04:25:23.678782	2012-09-11 04:25:23.678782	129	\N
859	41	2012-09-11 04:25:23.684958	2012-09-11 04:25:23.684958	129	\N
860	1	2012-09-11 04:26:37.365214	2012-09-11 04:26:37.365214	130	\N
861	14	2012-09-11 04:26:37.371344	2012-09-11 04:26:37.371344	130	\N
862	17	2012-09-11 04:26:37.376944	2012-09-11 04:26:37.376944	130	\N
863	21	2012-09-11 04:26:37.38341	2012-09-11 04:26:37.38341	130	\N
864	22	2012-09-11 04:26:37.388884	2012-09-11 04:26:37.388884	130	\N
865	23	2012-09-11 04:26:37.394254	2012-09-11 04:26:37.394254	130	\N
866	24	2012-09-11 04:26:37.399647	2012-09-11 04:26:37.399647	130	\N
867	25	2012-09-11 04:26:37.405164	2012-09-11 04:26:37.405164	130	\N
868	26	2012-09-11 04:26:37.411058	2012-09-11 04:26:37.411058	130	\N
869	27	2012-09-11 04:26:37.41633	2012-09-11 04:26:37.41633	130	\N
870	28	2012-09-11 04:26:37.421655	2012-09-11 04:26:37.421655	130	\N
871	29	2012-09-11 04:26:37.426915	2012-09-11 04:26:37.426915	130	\N
872	30	2012-09-11 04:26:37.432321	2012-09-11 04:26:37.432321	130	\N
873	31	2012-09-11 04:26:37.437561	2012-09-11 04:26:37.437561	130	\N
874	32	2012-09-11 04:26:37.442629	2012-09-11 04:26:37.442629	130	\N
875	35	2012-09-11 04:26:37.447452	2012-09-11 04:26:37.447452	130	\N
876	36	2012-09-11 04:26:37.453869	2012-09-11 04:26:37.453869	130	\N
878	18	2012-09-11 04:26:37.463865	2012-09-11 04:26:37.463865	130	\N
879	40	2012-09-11 04:26:37.471045	2012-09-11 04:26:37.471045	130	\N
880	41	2012-09-11 04:26:37.477033	2012-09-11 04:26:37.477033	130	\N
881	40	2012-09-11 04:33:07.226806	2012-09-11 04:33:07.226806	131	\N
835	2	2012-09-11 04:24:50.375948	2012-09-11 04:24:50.375948	128	2012-09-11 04:33:17.927018
856	2	2012-09-11 04:25:23.667688	2012-09-11 04:25:23.667688	129	2012-09-11 04:33:17.927018
877	2	2012-09-11 04:26:37.458955	2012-09-11 04:26:37.458955	130	2012-09-11 04:33:17.927018
882	3	2012-09-11 04:33:07.232592	2012-09-11 04:33:07.232592	131	2012-09-11 04:41:00.28253
883	40	2012-09-11 04:45:25.112646	2012-09-11 04:45:25.112646	132	\N
884	3	2012-09-11 04:45:25.118862	2012-09-11 04:45:25.118862	132	2012-09-11 04:45:47.123556
885	1	2012-09-11 04:59:32.829649	2012-09-11 04:59:32.829649	133	\N
887	14	2012-09-11 04:59:32.842526	2012-09-11 04:59:32.842526	133	\N
888	17	2012-09-11 04:59:32.848585	2012-09-11 04:59:32.848585	133	\N
889	21	2012-09-11 04:59:32.854842	2012-09-11 04:59:32.854842	133	\N
890	22	2012-09-11 04:59:32.860691	2012-09-11 04:59:32.860691	133	\N
891	23	2012-09-11 04:59:32.866413	2012-09-11 04:59:32.866413	133	\N
892	24	2012-09-11 04:59:32.872239	2012-09-11 04:59:32.872239	133	\N
893	25	2012-09-11 04:59:32.878752	2012-09-11 04:59:32.878752	133	\N
894	26	2012-09-11 04:59:32.886555	2012-09-11 04:59:32.886555	133	\N
895	27	2012-09-11 04:59:32.893651	2012-09-11 04:59:32.893651	133	\N
896	28	2012-09-11 04:59:32.900547	2012-09-11 04:59:32.900547	133	\N
897	29	2012-09-11 04:59:32.906592	2012-09-11 04:59:32.906592	133	\N
898	30	2012-09-11 04:59:32.913313	2012-09-11 04:59:32.913313	133	\N
899	31	2012-09-11 04:59:32.920962	2012-09-11 04:59:32.920962	133	\N
900	32	2012-09-11 04:59:32.927186	2012-09-11 04:59:32.927186	133	\N
901	35	2012-09-11 04:59:32.932982	2012-09-11 04:59:32.932982	133	\N
902	36	2012-09-11 04:59:32.939151	2012-09-11 04:59:32.939151	133	\N
903	18	2012-09-11 04:59:32.946095	2012-09-11 04:59:32.946095	133	\N
904	40	2012-09-11 04:59:32.952458	2012-09-11 04:59:32.952458	133	\N
905	41	2012-09-11 04:59:32.958441	2012-09-11 04:59:32.958441	133	\N
886	3	2012-09-11 04:59:32.836715	2012-09-11 04:59:32.836715	133	2012-09-11 06:10:22.86309
906	40	2012-09-15 01:58:51.794997	2012-09-15 01:58:51.794997	138	\N
908	40	2012-09-15 02:00:14.788046	2012-09-15 02:00:14.788046	139	\N
907	3	2012-09-15 01:58:51.803823	2012-09-15 01:58:51.803823	138	2012-09-15 02:00:47.100946
909	3	2012-09-15 02:00:14.798575	2012-09-15 02:00:14.798575	139	2012-09-15 02:00:47.100946
910	14	2012-09-15 03:24:20.978356	2012-09-15 03:24:20.978356	140	\N
911	2	2012-09-15 03:24:20.985494	2012-09-15 03:24:20.985494	140	\N
912	14	2012-09-15 03:24:34.100547	2012-09-15 03:24:34.100547	141	\N
913	2	2012-09-15 03:24:34.108079	2012-09-15 03:24:34.108079	141	\N
914	2	2012-09-15 03:25:40.978454	2012-09-15 03:25:40.978454	142	\N
915	12	2012-09-16 06:25:13.437256	2012-09-16 06:25:13.437256	143	\N
916	18	2012-09-16 06:27:22.01329	2012-09-16 06:27:22.01329	146	\N
917	3	2012-09-16 06:45:19.806296	2012-09-16 06:45:19.806296	149	\N
918	40	2012-09-16 06:52:20.024134	2012-09-16 06:52:20.024134	150	\N
919	3	2012-09-16 06:52:20.032125	2012-09-16 06:52:20.032125	150	\N
920	40	2012-09-16 22:39:45.080151	2012-09-16 22:39:45.080151	151	\N
921	3	2012-09-16 22:39:45.087957	2012-09-16 22:39:45.087957	151	\N
922	40	2012-09-16 22:40:05.587655	2012-09-16 22:40:05.587655	152	\N
923	3	2012-09-16 22:40:05.594019	2012-09-16 22:40:05.594019	152	\N
924	3	2012-09-16 22:40:29.504076	2012-09-16 22:40:29.504076	153	\N
925	2	2012-09-16 22:52:40.974976	2012-09-16 22:52:40.974976	154	\N
926	2	2012-09-16 22:53:12.743868	2012-09-16 22:53:12.743868	155	\N
927	14	2012-09-16 22:56:24.414636	2012-09-16 22:56:24.414636	158	\N
928	14	2012-09-16 22:58:02.444609	2012-09-16 22:58:02.444609	159	\N
929	2	2012-09-16 22:58:02.450574	2012-09-16 22:58:02.450574	159	\N
930	14	2012-09-16 22:59:47.439311	2012-09-16 22:59:47.439311	160	\N
931	2	2012-09-16 22:59:47.445293	2012-09-16 22:59:47.445293	160	\N
932	3	2012-09-16 23:07:59.611826	2012-09-16 23:07:59.611826	161	\N
933	4	2012-09-17 01:28:55.834455	2012-09-17 01:28:55.834455	164	\N
934	3	2012-09-17 01:28:55.840556	2012-09-17 01:28:55.840556	164	\N
935	3	2012-09-17 01:30:08.731073	2012-09-17 01:30:08.731073	165	\N
936	14	2012-09-17 01:30:08.738667	2012-09-17 01:30:08.738667	165	\N
937	14	2012-09-17 01:31:50.472113	2012-09-17 01:31:50.472113	166	\N
938	3	2012-09-17 01:31:50.477863	2012-09-17 01:31:50.477863	166	\N
939	4	2012-09-17 20:12:06.138979	2012-09-17 20:12:06.138979	167	\N
940	13	2012-09-17 20:12:06.151151	2012-09-17 20:12:06.151151	167	\N
941	16	2012-09-17 20:12:06.161586	2012-09-17 20:12:06.161586	167	\N
942	9	2012-09-17 20:12:06.171487	2012-09-17 20:12:06.171487	167	\N
943	14	2012-09-17 20:12:06.180932	2012-09-17 20:12:06.180932	167	\N
944	3	2012-09-17 20:12:06.190186	2012-09-17 20:12:06.190186	167	\N
945	3	2012-09-17 20:12:27.226895	2012-09-17 20:12:27.226895	168	\N
946	4	2012-09-17 20:13:16.671582	2012-09-17 20:13:16.671582	169	\N
947	13	2012-09-17 20:13:16.681999	2012-09-17 20:13:16.681999	169	\N
948	16	2012-09-17 20:13:16.692052	2012-09-17 20:13:16.692052	169	\N
949	9	2012-09-17 20:13:16.701645	2012-09-17 20:13:16.701645	169	\N
950	14	2012-09-17 20:13:16.712026	2012-09-17 20:13:16.712026	169	\N
951	3	2012-09-17 20:13:16.722622	2012-09-17 20:13:16.722622	169	\N
952	3	2012-09-17 20:15:38.565753	2012-09-17 20:15:38.565753	170	\N
953	14	2012-09-17 20:15:38.576448	2012-09-17 20:15:38.576448	170	\N
954	14	2012-09-17 20:59:53.895955	2012-09-17 20:59:53.895955	171	\N
955	3	2012-09-17 20:59:53.906133	2012-09-17 20:59:53.906133	171	\N
956	4	2012-09-17 21:01:27.985315	2012-09-17 21:01:27.985315	172	\N
957	13	2012-09-17 21:01:27.997835	2012-09-17 21:01:27.997835	172	\N
958	16	2012-09-17 21:01:28.008031	2012-09-17 21:01:28.008031	172	\N
959	9	2012-09-17 21:01:28.01767	2012-09-17 21:01:28.01767	172	\N
960	14	2012-09-17 21:01:28.028073	2012-09-17 21:01:28.028073	172	\N
961	3	2012-09-17 21:01:28.038254	2012-09-17 21:01:28.038254	172	\N
962	3	2012-09-17 21:02:31.972172	2012-09-17 21:02:31.972172	173	\N
963	14	2012-09-18 01:54:36.827083	2012-09-18 01:54:36.827083	174	\N
964	3	2012-09-18 01:54:36.836254	2012-09-18 01:54:36.836254	174	\N
965	14	2012-09-18 02:35:46.651781	2012-09-18 02:35:46.651781	175	\N
966	3	2012-09-18 02:35:46.661603	2012-09-18 02:35:46.661603	175	\N
967	4	2012-09-18 03:21:15.953943	2012-09-18 03:21:15.953943	176	\N
968	13	2012-09-18 03:21:15.962802	2012-09-18 03:21:15.962802	176	\N
969	16	2012-09-18 03:21:15.969084	2012-09-18 03:21:15.969084	176	\N
970	9	2012-09-18 03:21:15.974483	2012-09-18 03:21:15.974483	176	\N
971	14	2012-09-18 03:21:15.979666	2012-09-18 03:21:15.979666	176	\N
972	3	2012-09-18 03:21:15.985159	2012-09-18 03:21:15.985159	176	\N
973	4	2012-09-18 03:24:17.538036	2012-09-18 03:24:17.538036	177	\N
974	13	2012-09-18 03:24:17.543484	2012-09-18 03:24:17.543484	177	\N
975	16	2012-09-18 03:24:17.548863	2012-09-18 03:24:17.548863	177	\N
976	9	2012-09-18 03:24:17.554141	2012-09-18 03:24:17.554141	177	\N
977	14	2012-09-18 03:24:17.559673	2012-09-18 03:24:17.559673	177	\N
978	3	2012-09-18 03:24:17.564971	2012-09-18 03:24:17.564971	177	\N
979	1	2012-09-18 03:40:10.577929	2012-09-18 03:40:10.577929	178	\N
980	14	2012-09-18 03:40:10.584066	2012-09-18 03:40:10.584066	178	\N
981	17	2012-09-18 03:40:10.589885	2012-09-18 03:40:10.589885	178	\N
982	21	2012-09-18 03:40:10.595652	2012-09-18 03:40:10.595652	178	\N
983	22	2012-09-18 03:40:10.601732	2012-09-18 03:40:10.601732	178	\N
984	23	2012-09-18 03:40:10.608635	2012-09-18 03:40:10.608635	178	\N
985	24	2012-09-18 03:40:10.614784	2012-09-18 03:40:10.614784	178	\N
986	25	2012-09-18 03:40:10.621742	2012-09-18 03:40:10.621742	178	\N
987	26	2012-09-18 03:40:10.626861	2012-09-18 03:40:10.626861	178	\N
988	27	2012-09-18 03:40:10.631972	2012-09-18 03:40:10.631972	178	\N
989	28	2012-09-18 03:40:10.637186	2012-09-18 03:40:10.637186	178	\N
990	29	2012-09-18 03:40:10.642795	2012-09-18 03:40:10.642795	178	\N
991	30	2012-09-18 03:40:10.649049	2012-09-18 03:40:10.649049	178	\N
992	31	2012-09-18 03:40:10.655411	2012-09-18 03:40:10.655411	178	\N
993	32	2012-09-18 03:40:10.660871	2012-09-18 03:40:10.660871	178	\N
994	35	2012-09-18 03:40:10.666308	2012-09-18 03:40:10.666308	178	\N
995	36	2012-09-18 03:40:10.672512	2012-09-18 03:40:10.672512	178	\N
996	18	2012-09-18 03:40:10.679188	2012-09-18 03:40:10.679188	178	\N
997	40	2012-09-18 03:40:10.684812	2012-09-18 03:40:10.684812	178	\N
998	41	2012-09-18 03:40:10.691889	2012-09-18 03:40:10.691889	178	\N
999	3	2012-09-18 03:40:10.699198	2012-09-18 03:40:10.699198	178	\N
1000	1	2012-09-18 03:40:18.509224	2012-09-18 03:40:18.509224	179	\N
1001	1	2012-09-18 03:51:09.792684	2012-09-18 03:51:09.792684	180	\N
1002	3	2012-09-18 03:51:09.801574	2012-09-18 03:51:09.801574	180	\N
1003	1	2012-09-18 03:59:16.30891	2012-09-18 03:59:16.30891	181	\N
1004	14	2012-09-18 03:59:16.316307	2012-09-18 03:59:16.316307	181	\N
1005	17	2012-09-18 03:59:16.32183	2012-09-18 03:59:16.32183	181	\N
1006	21	2012-09-18 03:59:16.327304	2012-09-18 03:59:16.327304	181	\N
1007	22	2012-09-18 03:59:16.332218	2012-09-18 03:59:16.332218	181	\N
1008	23	2012-09-18 03:59:16.337385	2012-09-18 03:59:16.337385	181	\N
1009	24	2012-09-18 03:59:16.343588	2012-09-18 03:59:16.343588	181	\N
1010	25	2012-09-18 03:59:16.348546	2012-09-18 03:59:16.348546	181	\N
1011	26	2012-09-18 03:59:16.354811	2012-09-18 03:59:16.354811	181	\N
1012	27	2012-09-18 03:59:16.362603	2012-09-18 03:59:16.362603	181	\N
1013	28	2012-09-18 03:59:16.368514	2012-09-18 03:59:16.368514	181	\N
1014	29	2012-09-18 03:59:16.374442	2012-09-18 03:59:16.374442	181	\N
1015	30	2012-09-18 03:59:16.37967	2012-09-18 03:59:16.37967	181	\N
1016	31	2012-09-18 03:59:16.384998	2012-09-18 03:59:16.384998	181	\N
1017	32	2012-09-18 03:59:16.390511	2012-09-18 03:59:16.390511	181	\N
1018	35	2012-09-18 03:59:16.395715	2012-09-18 03:59:16.395715	181	\N
1019	36	2012-09-18 03:59:16.460855	2012-09-18 03:59:16.460855	181	\N
1020	18	2012-09-18 03:59:16.467784	2012-09-18 03:59:16.467784	181	\N
1021	40	2012-09-18 03:59:16.473289	2012-09-18 03:59:16.473289	181	\N
1022	41	2012-09-18 03:59:16.478841	2012-09-18 03:59:16.478841	181	\N
1023	2	2012-09-18 03:59:16.483929	2012-09-18 03:59:16.483929	181	\N
1024	1	2012-09-18 04:00:02.11627	2012-09-18 04:00:02.11627	182	\N
1025	14	2012-09-18 04:00:02.122328	2012-09-18 04:00:02.122328	182	\N
1026	17	2012-09-18 04:00:02.128406	2012-09-18 04:00:02.128406	182	\N
1027	21	2012-09-18 04:00:02.134851	2012-09-18 04:00:02.134851	182	\N
1028	22	2012-09-18 04:00:02.14198	2012-09-18 04:00:02.14198	182	\N
1029	23	2012-09-18 04:00:02.14971	2012-09-18 04:00:02.14971	182	\N
1030	24	2012-09-18 04:00:02.156036	2012-09-18 04:00:02.156036	182	\N
1031	25	2012-09-18 04:00:02.161414	2012-09-18 04:00:02.161414	182	\N
1032	26	2012-09-18 04:00:02.168056	2012-09-18 04:00:02.168056	182	\N
1033	27	2012-09-18 04:00:02.174907	2012-09-18 04:00:02.174907	182	\N
1034	28	2012-09-18 04:00:02.181321	2012-09-18 04:00:02.181321	182	\N
1035	29	2012-09-18 04:00:02.187246	2012-09-18 04:00:02.187246	182	\N
1036	30	2012-09-18 04:00:02.194259	2012-09-18 04:00:02.194259	182	\N
1037	31	2012-09-18 04:00:02.202068	2012-09-18 04:00:02.202068	182	\N
1038	32	2012-09-18 04:00:02.208446	2012-09-18 04:00:02.208446	182	\N
1039	35	2012-09-18 04:00:02.214659	2012-09-18 04:00:02.214659	182	\N
1040	36	2012-09-18 04:00:02.221341	2012-09-18 04:00:02.221341	182	\N
1041	18	2012-09-18 04:00:02.22708	2012-09-18 04:00:02.22708	182	\N
1042	40	2012-09-18 04:00:02.233781	2012-09-18 04:00:02.233781	182	\N
1043	41	2012-09-18 04:00:02.244919	2012-09-18 04:00:02.244919	182	\N
1044	3	2012-09-18 04:00:02.253223	2012-09-18 04:00:02.253223	182	\N
1045	40	2012-09-18 04:00:12.742083	2012-09-18 04:00:12.742083	183	\N
1046	3	2012-09-18 04:00:12.830737	2012-09-18 04:00:12.830737	183	\N
1047	4	2012-09-18 09:05:51.874755	2012-09-18 09:05:51.874755	184	\N
1048	13	2012-09-18 09:05:51.883411	2012-09-18 09:05:51.883411	184	\N
1049	16	2012-09-18 09:05:51.890089	2012-09-18 09:05:51.890089	184	\N
1050	9	2012-09-18 09:05:51.895284	2012-09-18 09:05:51.895284	184	\N
1051	14	2012-09-18 09:05:51.900497	2012-09-18 09:05:51.900497	184	\N
1052	2	2012-09-18 09:05:51.905682	2012-09-18 09:05:51.905682	184	\N
1053	2	2012-09-18 09:06:31.232477	2012-09-18 09:06:31.232477	185	\N
1054	14	2012-09-18 09:06:31.239568	2012-09-18 09:06:31.239568	185	\N
1055	4	2012-09-18 09:09:15.397153	2012-09-18 09:09:15.397153	186	\N
1056	13	2012-09-18 09:09:15.403068	2012-09-18 09:09:15.403068	186	\N
1057	16	2012-09-18 09:09:15.408894	2012-09-18 09:09:15.408894	186	\N
1058	9	2012-09-18 09:09:15.414076	2012-09-18 09:09:15.414076	186	\N
1059	14	2012-09-18 09:09:15.419688	2012-09-18 09:09:15.419688	186	\N
1060	2	2012-09-18 09:09:15.426218	2012-09-18 09:09:15.426218	186	\N
1061	2	2012-09-18 09:10:29.979707	2012-09-18 09:10:29.979707	187	\N
1062	2	2012-09-18 09:11:19.040123	2012-09-18 09:11:19.040123	188	\N
1063	2	2012-09-18 09:12:34.778805	2012-09-18 09:12:34.778805	189	\N
1064	14	2012-09-18 09:12:34.785095	2012-09-18 09:12:34.785095	189	\N
1065	40	2012-09-19 01:28:28.673811	2012-09-19 01:28:28.673811	192	\N
1066	3	2012-09-19 01:28:28.686274	2012-09-19 01:28:28.686274	192	\N
1067	40	2012-09-19 01:29:20.897175	2012-09-19 01:29:20.897175	193	\N
1068	3	2012-09-19 01:29:21.031425	2012-09-19 01:29:21.031425	193	\N
1069	3	2012-09-19 01:30:30.661087	2012-09-19 01:30:30.661087	194	\N
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY schema_migrations (version) FROM stdin;
20120508233738
20111115062002
20111123003406
20111123003428
20111123023759
20111123063453
20111124031053
20111124033529
20111124044949
20111128013131
20111130020030
20111201065901
20111202014855
20111202021955
20111202023133
20111202031656
20111202042857
20111209202848
20111212061150
20120124225553
20120205233251
20120307190505
20120321232109
20120322094916
20120323030039
20120326022356
20120326091356
20120401221608
20120407070001
20120407071132
20120408015359
20120410011009
20120410030955
20120411031907
20120412035426
20120418072318
20120418082423
20120424221314
20120501012131
20120501012737
20120501031029
20120502005624
20120502010636
20120503000000
20120503072748
20120510004528
20120510021123
20120510035625
20120510041044
20120510131407
20120516044553
20120521041044
20120601035604
20120607070103
20120607190000
20120611230708
20120611231344
20120611231807
20120611232101
20120611232248
20120611233010
20120614034800
20120614054726
20120710011556
20120713210802
20120717044425
20120718141208
20120718141209
20120718141210
20120718141211
20120714011447
20120710230035
20120712140754
20120805234121
20120805234312
20120805234436
20120807050655
20120808011822
20120621042529
20120622014537
20120625002216
20120625002902
20120625024753
20120627063734
20120628053029
20120704081327
20120707012532
20120709031235
20120715235737
20120719062306
20120724025144
20120808042420
20120810053246
20120811064555
20120818230136
20120820034734
20120821031839
20120904050454
20120905023144
20120912015115
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, created_at, updated_at, admin, name, unconfirmed_email, invitation_token, invitation_sent_at, invitation_accepted_at, invitation_limit, invited_by_id, invited_by_type, deleted_at, has_read_system_notice, is_admin, avatar_kind, uploaded_avatar_file_name, uploaded_avatar_content_type, uploaded_avatar_file_size, uploaded_avatar_updated_at, has_read_dashboard_notice, has_read_group_notice, has_read_discussion_notice, avatar_initials) FROM stdin;
39	starman@sky.com	$2a$10$//s0Bcfx8TfyZvXxjTc0wukWQhv5ik4efAoMf8tPYqx76CmR1TE6O	\N	\N	\N	2	2012-08-19 21:24:14.166488	2012-08-19 05:04:42.335741	127.0.0.1	127.0.0.1	2012-08-19 05:02:07.079621	2012-08-20 09:25:38.346137	f	starman	\N	\N	2012-08-19 05:02:07.078387	2012-08-19 05:04:42.328662	\N	3	User	\N	t	f	\N	\N	\N	\N	\N	f	f	f	S
40	popsiclepaul@chill.com	$2a$10$8ymPj72Fj2uTpLoImSi0zusqTzdNr6oQ2ZxKZ/wdeLDOj3Qsk8VZ6	\N	\N	\N	1	2012-09-06 05:09:45.713004	2012-09-06 05:09:45.713004	127.0.0.1	127.0.0.1	2012-09-06 05:07:51.616634	2012-09-06 05:11:04.341442	f	Popsicle Paul	\N	\N	2012-09-06 05:07:51.615292	2012-09-06 05:09:45.700822	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	PP
41	gobfish2@sea.com		\N	\N	\N	0	\N	\N	\N	\N	2012-09-10 05:19:01.103709	2012-09-10 05:19:01.103709	f	gobfish2@sea.com	\N	s3Frcfz3yg2T8dfyRHrr	2012-09-10 05:19:01.102679	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	GO
4	tomcat@gmail.com	$2a$10$zIdIkpl8P.ptOt7dCFYJo.5dCzUp7fxqns3AtvhmK6qG7DcSMKEUa	\N	\N	\N	4	2012-05-21 23:44:25.779304	2012-05-20 23:25:13.872708	127.0.0.1	127.0.0.1	2012-05-17 22:25:08.889309	2012-08-08 01:31:26.836514	f	Tom	\N	\N	2012-05-17 22:25:08.88874	2012-05-17 22:26:44.892317	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	T
13	lyn@lyn.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-30 04:12:15.32887	2012-08-08 01:31:26.821127	f	lyn@lyn.com	\N	MsapxWvRJYqG52zNoezz	2012-05-30 04:12:15.327719	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	LY
16	tomo@home.com		\N	\N	\N	0	\N	\N	\N	\N	2012-06-02 07:55:37.185623	2012-08-08 01:31:26.834766	f	tomo@home.com	\N	vqjp2yqpFCc2y11DFt1B	2012-06-02 07:55:37.18495	\N	\N	14	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	TO
15	ben@loom.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-30 23:24:25.374173	2012-08-08 01:31:26.837971	f	ben@loom.com	\N	EZpv3asuEVC564d6cWy3	2012-05-30 23:24:25.373584	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	BE
5	spam@spam.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-23 05:00:30.275582	2012-08-08 01:31:26.839278	f	spam@spam.com	\N	ypdY7uXGHj3CoHytKb4C	2012-05-23 05:00:30.274508	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	SP
1	aaronthornton@gamil.com	$2a$10$k40QFEsy7lTLzIzJC9V8euS7DAdxVkG8xBXwC//Ga5UW.JQejwnli	\N	\N	2012-05-09 23:00:20.826033	14	2012-05-15 00:43:53.840605	2012-05-15 00:43:52.343693	127.0.0.1	127.0.0.1	2012-05-09 22:58:59.311992	2012-08-08 01:31:26.84074	f	Aaron	\N	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	f	f	f	A
6	champ@nothing.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-23 09:55:34.868695	2012-08-08 01:31:26.842157	f	champ@nothing.com	\N	xSdqtUFs3Bn2L9ZqKLLx	2012-05-23 09:55:34.867269	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	CH
7	dukkar@dip.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-23 10:02:01.496456	2012-08-08 01:31:26.843513	f	dukkar@dip.com	\N	Es8wucw1vZgYrwya4Eb4	2012-05-23 10:02:01.495558	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	DU
8	peteyboy@gmail.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-28 02:25:12.75665	2012-08-08 01:31:26.844826	f	peteyboy@gmail.com	\N	LfcCz2mgYzz3sZPbmbog	2012-05-28 02:25:12.756113	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	PE
9	jdhfkjhdfjsbdfiuadviuaivadbvibdv@skjbiabsbb.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-28 05:56:48.192494	2012-08-08 01:31:26.851909	f	jdhfkjhdfjsbdfiuadviuaivadbvibdv@skjbiabsbb.com	\N	5v9zC6xTi2JP8NDgkgP5	2012-05-28 05:56:48.191942	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	JD
10	removalman@dump.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-29 05:25:02.345154	2012-08-08 01:31:26.853675	f	removalman@dump.com	\N	A3NmQN5Wn6rf1QseUmDH	2012-05-29 05:25:02.34399	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	RE
11	billybob@parent.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-29 05:26:25.576695	2012-08-08 01:31:26.855156	f	billybob@parent.com	\N	opcFoVQzcP4WsxX7gjKz	2012-05-29 05:26:25.576146	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	BI
12	chiman@g.com		\N	\N	\N	0	\N	\N	\N	\N	2012-05-29 05:55:16.246369	2012-08-08 01:31:26.856513	f	chiman@g.com	\N	hS8CsGc39N25yYfAoA1d	2012-05-29 05:55:16.245662	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	CH
17	sue@sew.com		\N	\N	\N	0	\N	\N	\N	\N	2012-07-04 05:14:41.807782	2012-08-08 01:31:26.858086	f	sue@sew.com	\N	GZMX9tGqHkBw126gF6Qr	2012-07-04 05:14:41.807079	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	SU
19	johnthebabtist@+.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 03:27:28.522001	2012-08-08 01:31:26.859541	f	\N	\N	E9NxeTs5y1pgzBapfyHH	2012-08-04 03:27:28.520805	\N	\N	18	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	JO
20	johntron@fingerpop.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 03:28:28.705897	2012-08-08 01:31:26.861076	f	johntron@fingerpop.com	\N	RR4qP5wkNsd9WxsiLsEn	2012-08-04 03:28:28.705216	\N	\N	18	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	JO
21	julien@teethshop.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 21:31:31.998466	2012-08-08 01:31:26.862439	f	julien@teethshop.com	\N	EnKnJzCFMLCBSN7v3Gxe	2012-08-04 21:31:31.997548	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	JU
22	selwyntoobad@bags.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 21:44:33.694561	2012-08-08 01:31:26.863783	f	selwyntoobad@bags.com	\N	zVo8wsydrqN1Ejngzk82	2012-08-04 21:44:33.69393	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	SE
23	bob@bobsbar.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 21:49:54.950163	2012-08-08 01:31:26.865121	f	bob@bobsbar.com	\N	GT2W9JKfptVq1xKFVkEh	2012-08-04 21:49:54.949313	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	BO
24	sam@samitysams.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 21:54:08.398952	2012-08-08 01:31:26.866461	f	sam@samitysams.com	\N	ewaaUB4rRJCviYKgJzNK	2012-08-04 21:54:08.398176	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	SA
25	paul@pullface.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 21:55:18.112992	2012-08-08 01:31:26.867809	f	paul@pullface.com	\N	Z2ZDtkHUh9yR3rmsPyah	2012-08-04 21:55:18.112221	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	PA
26	diane@dinners.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 21:56:23.728182	2012-08-08 01:31:26.869153	f	diane@dinners.com	\N	ENybbRf8buJxzfRsXyEo	2012-08-04 21:56:23.727408	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	DI
27	cheech@chongs.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 21:57:50.354945	2012-08-08 01:31:26.870494	f	cheech@chongs.com	\N	KGRSPQCJ7HqsJYDjxk24	2012-08-04 21:57:50.354259	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	CH
28	cheech@chonghouse.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-04 22:00:52.544395	2012-08-08 01:31:26.871838	f	cheech@chonghouse.com	\N	QpK6uFJZRTt8MqkYizif	2012-08-04 22:00:52.543754	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	CH
33	info@loom.io	$2a$10$m4h6gjHnXg45bXYoINXRBujtaGz79E5Kz5eVxfM9q6i5/w3mNmxri	\N	\N	\N	0	\N	\N	\N	\N	2012-08-06 23:21:22.267313	2012-08-08 01:31:26.873469	f	gonzo	\N	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	f	f	f	G
34	contact@loom.io	$2a$10$L6fC8F7XkrRTTe4kZ6l9Ze9OuxiFBCdQJJqV1zxJXpzswdrO3RZV6	\N	\N	\N	0	\N	\N	\N	\N	2012-08-06 23:40:32.576539	2012-08-08 01:31:26.874851	f	Loomio	\N	\N	\N	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	f	f	f	L
35	porkbonesanpooha@hungi.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-07 04:23:39.769252	2012-08-08 01:31:26.876159	f	porkbonesanpooha@hungi.com	\N	GtnoyrEurWB5q3fxZUeq	2012-08-07 04:23:39.768194	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	PO
29	drainlayer@pipe.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-06 02:04:58.113505	2012-08-08 01:31:26.877503	f	drainlayer@pipe.com	\N	skT18impY7KPfDQUpLAi	2012-08-06 02:04:58.112867	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	DR
30	jim@jamjam.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-06 02:11:04.500604	2012-08-08 01:31:26.878914	f	jim@jamjam.com	\N	Eyi6ykxqKcCFmhDNiC2p	2012-08-06 02:11:04.500009	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	JI
31	jakesnakie@fish.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-06 02:19:55.668025	2012-08-08 01:31:26.88028	f	jakesnakie@fish.com	\N	5vkwezfjsreXx9TPsfSV	2012-08-06 02:19:55.667298	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	JA
32	bobthebouy@sea.com		\N	\N	\N	0	\N	\N	\N	\N	2012-08-06 02:21:04.703814	2012-08-08 01:31:26.881623	f	bobthebouy@sea.com	\N	ha1PBynWPt3EHu7stqtQ	2012-08-06 02:21:04.703041	\N	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	BO
38	chulaloosa@pixie.com	$2a$10$z441JvjavnpqJP/G793PdO4lxnvctQ9x1KHfhocqRixIf6lUFu4Wu	\N	\N	\N	1	2012-08-07 23:53:38.968272	2012-08-07 23:53:38.968272	127.0.0.1	127.0.0.1	2012-08-07 23:50:36.089525	2012-08-08 01:31:26.884608	f	cyan kyan kan	\N	\N	2012-08-07 23:50:36.088861	2012-08-07 23:53:38.960289	\N	14	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	CK
36	bingbingbaby@bounty.com	$2a$10$eQSEs8SWPBWouXSZ1w83J.LinWkVZiFEyfNyaT0Ca9mjqRVcrHweG	\N	\N	\N	1	2012-08-07 04:37:39.266997	2012-08-07 04:37:39.266997	127.0.0.1	127.0.0.1	2012-08-07 04:35:39.833239	2012-08-08 01:31:26.887804	f	chunky chips and chilly cucumber cheese chores	\N	\N	2012-08-07 04:35:39.832584	2012-08-07 04:37:39.259128	\N	3	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	CC
37	markie@marcos.com	$2a$10$0Jvxp5ouu9iCeTKxYwtJ4um5Mslh5YpPcK0LxH4YaLTe.lWf2/xHW	\N	\N	\N	1	2012-08-07 23:33:56.888974	2012-08-07 23:33:56.888974	127.0.0.1	127.0.0.1	2012-08-07 23:31:07.843854	2012-08-08 01:31:26.892795	f	Markie Martaos Mark	\N	\N	2012-08-07 23:31:07.84311	2012-08-07 23:33:56.881719	\N	14	User	\N	f	f	\N	\N	\N	\N	\N	f	f	f	MM
14	gobfish@sea.com	$2a$10$dXV..wEiVnmr4csZaqrtl.6D.ni37//5UJFpuo0/KRvR4ZwePUWfi	\N	\N	\N	31	2012-08-24 06:08:40.570324	2012-08-18 03:48:32.418533	127.0.0.1	127.0.0.1	2012-05-30 04:30:13.253558	2012-08-24 06:08:40.571498	f	gobfish@sea.com	\N	\N	2012-05-30 04:30:13.252711	2012-05-30 04:32:49.431899	\N	3	User	\N	t	f		system_consciousness.jpg	image/jpeg	142205	2012-08-07 23:28:11.690476	f	f	f	GO
18	aaronthornton00@gmail.com	$2a$10$b7UOoJ50ooRLDJBmIrJQg.ZSx3KmiW/ljrD5MGzUzyNv7kWgxl3U.	MistpwypyRUYjpv3XBu6	2012-07-27 06:41:03.609176	\N	19	2012-09-15 02:05:07.914489	2012-09-09 21:41:22.486848	127.0.0.1	127.0.0.1	2012-07-27 06:40:00.778688	2012-09-15 02:05:07.915912	f	aaronthornton00@gmail.com	\N	\N	2012-07-27 06:40:00.778031	2012-07-27 06:44:09.897409	\N	2	User	\N	f	f		system_consciousness.jpg	image/jpeg	142205	2012-08-03 04:15:34.539501	t	t	t	AA
3	aaronthornton@gmail.com	$2a$10$49Yc42oAnMvMm7ngwF1e7uMCBG7dKme0O4LdXs/XDRX8171sqxQla	\N	\N	\N	75	2012-09-15 02:05:45.798587	2012-09-13 22:04:00.321777	127.0.0.1	127.0.0.1	2012-05-15 02:51:04.527853	2012-09-15 02:05:45.799934	f	Aaron	\N	\N	\N	\N	\N	\N	\N	\N	t	f		system_consciousness.jpg	image/jpeg	142205	2012-08-07 04:12:53.507485	t	t	t	A
2	petermeter@wcc.co.nz	$2a$10$910zvepYgat.uw0P6u8qWuFQySZXtK2PoMfTuBr9WhXkkS0xsDbTu	\N	\N	\N	55	2012-09-16 22:36:45.307981	2012-09-15 01:58:04.939742	127.0.0.1	127.0.0.1	2012-05-10 03:20:20.791185	2012-09-16 22:36:45.309415	f	Peter Metric	\N	\N	2012-05-10 03:20:20.79006	2012-05-10 03:21:56.582879	\N	1	User	\N	t	f		system_consciousness.jpg	image/jpeg	142205	2012-08-01 09:05:10.705708	t	t	t	PM
\.


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: aaronthornton
--

COPY votes (id, motion_id, user_id, "position", created_at, updated_at, statement) FROM stdin;
6	5	1	no	2012-05-11 05:00:23.669735	2012-05-11 05:00:23.669735	
7	5	1	block	2012-05-13 06:16:32.851101	2012-05-13 06:16:32.851101	stop
8	5	1	yes	2012-05-13 06:17:04.365454	2012-05-13 06:17:04.365454	changed my mind its all good
9	4	1	abstain	2012-05-13 09:18:09.185302	2012-05-13 09:18:09.185302	
10	4	1	no	2012-05-14 02:15:42.92651	2012-05-14 02:15:42.92651	
11	7	1	no	2012-05-14 03:02:22.514101	2012-05-14 03:02:22.514101	
12	30	4	abstain	2012-05-19 01:51:44.445434	2012-05-19 01:51:44.445434	
13	30	3	no	2012-05-19 04:32:57.546096	2012-05-19 04:32:57.546096	THis is the reason for my vote
14	31	3	no	2012-05-20 03:48:09.745202	2012-05-20 03:48:09.745202	
15	30	3	yes	2012-05-20 07:39:06.358809	2012-05-20 07:39:06.358809	THis is the reason for my vote
16	32	3	abstain	2012-05-20 22:54:42.202089	2012-05-20 22:54:42.202089	
17	32	3	block	2012-05-20 22:56:03.199421	2012-05-20 22:56:03.199421	
18	34	3	yes	2012-05-22 01:17:50.681304	2012-05-22 01:17:50.681304	
19	35	3	no	2012-05-22 01:24:43.392054	2012-05-22 01:24:43.392054	
20	35	3	no	2012-05-22 01:24:52.117286	2012-05-22 01:24:52.117286	
21	35	3	block	2012-05-22 01:26:24.658996	2012-05-22 01:26:24.658996	
22	38	3	abstain	2012-05-22 23:31:00.695573	2012-05-22 23:31:00.695573	
23	38	3	no	2012-05-22 23:31:20.497678	2012-05-22 23:31:20.497678	
24	38	3	block	2012-05-23 04:53:13.448981	2012-05-23 04:53:13.448981	
25	40	14	abstain	2012-06-01 03:23:36.792432	2012-06-01 03:23:36.792432	
26	40	14	block	2012-06-01 03:37:03.605085	2012-06-01 03:37:03.605085	
27	48	3	yes	2012-06-08 02:51:16.425229	2012-06-08 02:51:16.425229	i am top
28	49	14	abstain	2012-06-08 03:07:45.078098	2012-06-08 03:07:45.078098	oh baby!
29	47	3	block	2012-06-08 03:09:24.351347	2012-06-08 03:09:24.351347	
30	49	3	no	2012-06-08 03:35:39.741844	2012-06-08 03:35:39.741844	
31	50	3	yes	2012-06-08 03:50:45.814229	2012-06-08 03:50:45.814229	
32	50	2	abstain	2012-06-08 04:13:06.542836	2012-06-08 04:13:06.542836	lookie here!
33	47	2	no	2012-06-08 04:16:49.13994	2012-06-08 04:16:49.13994	
34	40	2	abstain	2012-06-08 04:26:11.241746	2012-06-08 04:26:11.241746	
35	60	3	abstain	2012-06-19 05:18:59.167237	2012-06-19 05:18:59.167237	
36	70	2	yes	2012-06-22 04:58:39.743394	2012-06-22 04:58:39.743394	
37	69	2	abstain	2012-06-22 05:07:10.633126	2012-06-22 05:07:10.633126	dfgsdfgsd
38	71	2	yes	2012-06-22 05:10:00.439841	2012-06-22 05:10:00.439841	dfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfs
39	71	2	yes	2012-06-22 05:10:15.221514	2012-06-22 05:10:15.221514	dfgfsdgfdsgfdsgfddfgfsdgfd sgfdsgfddfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfsdgfdsgfdsgfddfgfs
40	69	2	abstain	2012-06-22 06:28:30.196939	2012-06-22 06:28:30.196939	dfgsdfgsd kjhsdhfgisudh kshfgiushgiusdh kjsdhgsdhgisdifguhlkdfjgdjfgjsdjfgoisjdgoijsd
41	69	2	abstain	2012-06-23 00:32:47.780292	2012-06-23 00:32:47.780292	dfgsdfgsdkjhsdhfgisudhkshfgiushgiusdhkjsdhgsdhgisdifguhlkdfjgdjfgjsdjfgoisjdgoijsd
42	69	2	abstain	2012-06-23 00:34:42.637485	2012-06-23 00:34:42.637485	dfgsdfgsdkjhsdhfgisudhkshfgiushgiusdhkjsdhgsdhgisdifguhlkdfjgdjfgjsdjfgoisjdgoijsddjkfnvsdkjnvsdfvlisdbfivsdbiubvdisubfviubdsiv
43	69	2	abstain	2012-06-23 00:39:12.951441	2012-06-23 00:39:12.951441	dfgsdfgsdkjhsdhfgisudhkshfgiu shgiusdhkjsdhgsdhgisdifguhlkdfjgdjfgjsdjfgoisjdgoijsddjkfnvsdkjnvsdfvlisdbfivsdbiubvdisubfviubdsiv
44	71	3	abstain	2012-06-25 02:06:17.714605	2012-06-25 02:06:17.714605	
45	72	3	no	2012-06-25 03:49:29.256088	2012-06-25 03:49:29.256088	
46	79	3	no	2012-07-02 03:14:34.476533	2012-07-02 03:14:34.476533	
47	82	3	yes	2012-07-02 22:15:21.791182	2012-07-02 22:15:21.791182	
48	84	3	block	2012-07-02 23:22:52.561577	2012-07-02 23:22:52.561577	
49	88	3	block	2012-07-08 06:46:51.041534	2012-07-08 06:46:51.041534	Block head
50	90	3	yes	2012-07-08 06:55:05.049981	2012-07-08 06:55:05.049981	Love it if it works
51	90	2	abstain	2012-07-08 07:01:52.591034	2012-07-08 07:01:52.591034	ydsfngkdjsnvkjdsnfvkjndsjkvnsdkjnvdfjksnydsfngkdjsnvkjdsnfvkjndsjkvnsdkjnvdfjksnydsfngkdjsnvkjdsnfvkjndsjkvnsdkjnvdfjksnydsfngkdjsnvkjdsnfvkjndsjkvnsdkjnvdfjksnydsfngkdjsnvkjdsnfvkjndsjkvnsdkjnvdfjksnydsfngkdjsnvkjdsnfvkjndsjkvnsdkjnvdfjksndsfgdgg
52	92	3	block	2012-07-08 23:15:05.331792	2012-07-08 23:15:05.331792	block that shit
53	97	3	abstain	2012-07-10 23:35:00.121742	2012-07-10 23:35:00.121742	first vote
54	97	3	no	2012-07-10 23:35:17.598476	2012-07-10 23:35:17.598476	first vote
55	98	3	no	2012-07-12 03:49:58.303946	2012-07-12 03:49:58.303946	
56	98	2	yes	2012-07-12 04:55:44.456431	2012-07-12 04:55:44.456431	
57	101	3	no	2012-07-13 01:19:26.206281	2012-07-13 01:19:26.206281	I think this is weird... Nice popup though!
58	95	2	no	2012-07-13 01:30:41.443358	2012-07-13 01:30:41.443358	
59	98	3	yes	2012-07-13 03:06:35.782883	2012-07-13 03:06:35.782883	
60	103	3	no	2012-07-14 00:55:07.348748	2012-07-14 00:55:07.348748	Not hungry
61	99	3	block	2012-07-14 00:56:15.84017	2012-07-14 00:56:15.84017	
62	95	3	abstain	2012-07-14 06:19:24.238261	2012-07-14 06:19:24.238261	
63	106	3	abstain	2012-07-14 22:52:26.957714	2012-07-14 22:52:26.957714	OK USA
64	107	3	yes	2012-07-15 23:01:23.376403	2012-07-15 23:01:23.376403	
65	110	3	abstain	2012-07-21 04:56:43.808987	2012-07-21 04:56:43.808987	Start with this
66	110	3	no	2012-07-21 04:57:07.267892	2012-07-21 04:57:07.267892	Change to this
67	116	3	no	2012-07-30 03:18:49.275065	2012-07-30 03:18:49.275065	na i eat early
68	123	3	no	2012-08-08 09:52:43.279918	2012-08-08 09:52:43.279918	
69	124	3	yes	2012-08-08 09:53:11.815539	2012-08-08 09:53:11.815539	
70	122	2	no	2012-08-08 20:54:09.373827	2012-08-08 20:54:09.373827	
71	118	3	no	2012-08-10 01:35:37.709861	2012-08-10 01:35:37.709861	
72	129	2	yes	2012-08-11 07:07:23.277345	2012-08-11 07:07:23.277345	Sherbery
73	129	3	abstain	2012-08-11 07:29:27.253045	2012-08-11 07:29:27.253045	
74	130	2	block	2012-08-13 02:47:47.59614	2012-08-13 02:47:47.59614	
75	130	2	no	2012-08-13 03:56:20.449359	2012-08-13 03:56:20.449359	
76	130	2	abstain	2012-08-13 04:16:15.692822	2012-08-13 04:16:15.692822	
77	130	2	yes	2012-08-13 04:21:52.602833	2012-08-13 04:21:52.602833	
78	130	3	abstain	2012-08-13 04:40:44.38951	2012-08-13 04:40:44.38951	
79	130	3	abstain	2012-08-13 22:30:33.993603	2012-08-13 22:30:33.993603	Are you kidding?
80	130	3	abstain	2012-08-14 02:56:10.237745	2012-08-14 02:56:10.237745	Are you kidding? iowejrowieuaweoiuf98waeuf98awue98fuaw98euf9w8eyf98wayef98wefy9w8eyf9w8yef98wyerg98ywer
81	130	3	abstain	2012-08-14 02:56:15.340027	2012-08-14 02:56:15.340027	Are you kidding? iowejrowieuaweoiuf98waeuf98awue98fuaw98euf9w8eyf98wayef98wefy9w8eyf9w8yef98wyerg98ywer
82	130	3	abstain	2012-08-14 02:57:02.356636	2012-08-14 02:57:02.356636	Are you kidding? iowejrowieuaweoiuf98wuf9w8eyf98wayef98wefy9w8eyf9w8yef98wyerg98ywer
83	130	2	no	2012-08-16 00:11:50.78262	2012-08-16 00:11:50.78262	
84	132	3	yes	2012-08-19 01:40:25.971309	2012-08-19 01:40:25.971309	
87	135	39	yes	2012-08-19 21:36:13.708973	2012-08-19 21:36:13.708973	
88	137	39	no	2012-08-19 23:25:28.773051	2012-08-19 23:25:28.773051	
89	133	2	yes	2012-08-20 09:30:35.112093	2012-08-20 09:30:35.112093	
90	140	2	yes	2012-08-22 21:32:56.908397	2012-08-22 21:32:56.908397	
91	140	3	no	2012-08-22 21:38:14.941877	2012-08-22 21:38:14.941877	
92	143	3	yes	2012-08-24 06:03:55.793107	2012-08-24 06:03:55.793107	Just show me the rocket\r\n
93	143	3	yes	2012-08-24 06:05:00.60467	2012-08-24 06:05:00.60467	Just show me the rocket
94	146	3	yes	2012-08-24 21:09:46.263927	2012-08-24 21:09:46.263927	keep sniffing
95	148	2	abstain	2012-08-27 00:47:08.158546	2012-08-27 00:47:08.158546	
96	147	2	block	2012-08-27 10:02:34.081022	2012-08-27 10:02:34.081022	
97	149	3	no	2012-08-29 01:15:01.361715	2012-08-29 01:15:01.361715	
98	161	3	abstain	2012-09-04 03:28:39.565455	2012-09-04 03:28:39.565455	
99	162	3	yes	2012-09-04 06:16:23.104329	2012-09-04 06:16:23.104329	
100	162	2	abstain	2012-09-06 03:56:32.352654	2012-09-06 03:56:32.352654	meh
101	165	40	no	2012-09-06 05:20:27.566327	2012-09-06 05:20:27.566327	here is a long email address take that www.ajskhdfkajshfashfhasidfuhasiudhfiasuhfiuashfiuashfiuashdfiuhas.com
102	163	3	abstain	2012-09-06 05:44:05.963868	2012-09-06 05:44:05.963868	
103	167	3	yes	2012-09-10 22:57:37.101851	2012-09-10 22:57:37.101851	
104	173	3	yes	2012-09-12 00:13:44.272888	2012-09-12 00:13:44.272888	more more
105	175	2	abstain	2012-09-17 20:12:27.143761	2012-09-17 20:12:27.143761	
106	177	2	yes	2012-09-17 21:02:31.894893	2012-09-17 21:02:31.894893	
107	179	2	no	2012-09-18 03:40:18.486295	2012-09-18 03:40:18.486295	
\.


--
-- Name: admin_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- Name: comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: did_not_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY did_not_votes
    ADD CONSTRAINT did_not_votes_pkey PRIMARY KEY (id);


--
-- Name: discussions_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY discussions
    ADD CONSTRAINT discussions_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: motion_read_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY discussion_read_logs
    ADD CONSTRAINT motion_read_logs_pkey PRIMARY KEY (id);


--
-- Name: motion_read_logs_pkey1; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY motion_read_logs
    ADD CONSTRAINT motion_read_logs_pkey1 PRIMARY KEY (id);


--
-- Name: motions_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY motions
    ADD CONSTRAINT motions_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: aaronthornton; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_admin_notes_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_admin_notes_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_comment_votes_on_comment_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_comment_votes_on_comment_id ON comment_votes USING btree (comment_id);


--
-- Name: index_comment_votes_on_user_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_comment_votes_on_user_id ON comment_votes USING btree (user_id);


--
-- Name: index_comments_on_commentable_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_id ON comments USING btree (commentable_id);


--
-- Name: index_comments_on_parent_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_comments_on_parent_id ON comments USING btree (parent_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_did_not_votes_on_motion_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_did_not_votes_on_motion_id ON did_not_votes USING btree (motion_id);


--
-- Name: index_did_not_votes_on_user_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_did_not_votes_on_user_id ON did_not_votes USING btree (user_id);


--
-- Name: index_discussions_on_author_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_discussions_on_author_id ON discussions USING btree (author_id);


--
-- Name: index_discussions_on_group_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_discussions_on_group_id ON discussions USING btree (group_id);


--
-- Name: index_events_on_eventable_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_events_on_eventable_id ON events USING btree (eventable_id);


--
-- Name: index_events_on_user_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_events_on_user_id ON events USING btree (user_id);


--
-- Name: index_groups_on_parent_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_groups_on_parent_id ON groups USING btree (parent_id);


--
-- Name: index_memberships_on_group_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_memberships_on_group_id ON memberships USING btree (group_id);


--
-- Name: index_memberships_on_inviter_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_memberships_on_inviter_id ON memberships USING btree (inviter_id);


--
-- Name: index_memberships_on_user_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_memberships_on_user_id ON memberships USING btree (user_id);


--
-- Name: index_motion_read_logs_on_discussion_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_motion_read_logs_on_discussion_id ON discussion_read_logs USING btree (discussion_id);


--
-- Name: index_motion_read_logs_on_user_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_motion_read_logs_on_user_id ON discussion_read_logs USING btree (user_id);


--
-- Name: index_motions_on_author_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_motions_on_author_id ON motions USING btree (author_id);


--
-- Name: index_motions_on_discussion_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_motions_on_discussion_id ON motions USING btree (discussion_id);


--
-- Name: index_notifications_on_event_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_notifications_on_event_id ON notifications USING btree (event_id);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_notifications_on_user_id ON notifications USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_users_on_invitation_token ON users USING btree (invitation_token);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_users_on_invited_by_id ON users USING btree (invited_by_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_votes_on_motion_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_votes_on_motion_id ON votes USING btree (motion_id);


--
-- Name: index_votes_on_user_id; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE INDEX index_votes_on_user_id ON votes USING btree (user_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: aaronthornton; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: aaronthornton
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM aaronthornton;
GRANT ALL ON SCHEMA public TO aaronthornton;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

