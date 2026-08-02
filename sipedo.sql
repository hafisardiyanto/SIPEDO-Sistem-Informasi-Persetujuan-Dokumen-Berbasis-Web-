--
-- PostgreSQL database dump
--

\restrict XQHuuZCGGgi2u7sEVajcLk44beQkjgva57kvd0xmScjh36f4Ax0NJam6Gej6K8s

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

-- Started on 2026-08-02 11:08:02

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5030 (class 1262 OID 18803)
-- Name: sipedo; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE sipedo WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';


ALTER DATABASE sipedo OWNER TO postgres;

\unrestrict XQHuuZCGGgi2u7sEVajcLk44beQkjgva57kvd0xmScjh36f4Ax0NJam6Gej6K8s
\connect sipedo
\restrict XQHuuZCGGgi2u7sEVajcLk44beQkjgva57kvd0xmScjh36f4Ax0NJam6Gej6K8s

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 5031 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 233 (class 1259 OID 20742)
-- Name: activity_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_log (
    id bigint NOT NULL,
    log_name character varying(255),
    description text NOT NULL,
    subject_type character varying(255),
    subject_id uuid,
    causer_type character varying(255),
    causer_id uuid,
    properties json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    event character varying(255),
    batch_uuid uuid
);


ALTER TABLE public.activity_log OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 20741)
-- Name: activity_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.activity_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activity_log_id_seq OWNER TO postgres;

--
-- TOC entry 5032 (class 0 OID 0)
-- Dependencies: 232
-- Name: activity_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.activity_log_id_seq OWNED BY public.activity_log.id;


--
-- TOC entry 231 (class 1259 OID 20724)
-- Name: assessment_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessment_logs (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    assessor_id uuid NOT NULL,
    status_from character varying(255),
    status_to character varying(255) NOT NULL,
    notes text,
    ip_address character varying(45),
    user_agent text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.assessment_logs OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 20631)
-- Name: cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 20638)
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache_locks OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 20771)
-- Name: companies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.companies (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    npwp character varying(255),
    address text,
    phone character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.companies OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 20844)
-- Name: document_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_categories (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.document_categories OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 20843)
-- Name: document_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_categories_id_seq OWNER TO postgres;

--
-- TOC entry 5033 (class 0 OID 0)
-- Dependencies: 241
-- Name: document_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_categories_id_seq OWNED BY public.document_categories.id;


--
-- TOC entry 246 (class 1259 OID 20885)
-- Name: document_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_types (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.document_types OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 20868)
-- Name: document_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_versions (
    id bigint NOT NULL,
    document_id uuid NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    file_path character varying(255) NOT NULL,
    uploaded_by uuid,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.document_versions OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 20867)
-- Name: document_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_versions_id_seq OWNER TO postgres;

--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 244
-- Name: document_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_versions_id_seq OWNED BY public.document_versions.id;


--
-- TOC entry 230 (class 1259 OID 20710)
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL,
    file_type character varying(255),
    category character varying(255) DEFAULT 'utama'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    version integer DEFAULT 1 NOT NULL,
    CONSTRAINT documents_category_check CHECK (((category)::text = ANY ((ARRAY['utama'::character varying, 'lampiran'::character varying, 'pengantar'::character varying, 'pendukung'::character varying])::text[])))
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN documents.version; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.documents.version IS 'Tracing hierarki revisi berkas v1, v2 tanpa timpa ulang';


--
-- TOC entry 226 (class 1259 OID 20663)
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 20662)
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO postgres;

--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 225
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- TOC entry 224 (class 1259 OID 20655)
-- Name: job_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 20646)
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 20645)
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO postgres;

--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 222
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- TOC entry 237 (class 1259 OID 20780)
-- Name: master_document_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.master_document_types (
    id uuid NOT NULL,
    type_code character varying(255) NOT NULL,
    type_name character varying(255) NOT NULL,
    description text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.master_document_types OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 20598)
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 20597)
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO postgres;

--
-- TOC entry 5038 (class 0 OID 0)
-- Dependencies: 215
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- TOC entry 238 (class 1259 OID 20789)
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    type character varying(255) DEFAULT 'info'::character varying NOT NULL,
    read_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 20615)
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 20762)
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    module character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 20675)
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id uuid NOT NULL,
    name text NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.personal_access_tokens OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 20674)
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_access_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 5039 (class 0 OID 0)
-- Dependencies: 227
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- TOC entry 240 (class 1259 OID 20820)
-- Name: project_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_assignments (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    assessor_id uuid NOT NULL,
    old_assessor_id uuid,
    assigned_by uuid NOT NULL,
    reason text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.project_assignments OWNER TO postgres;

--
-- TOC entry 5040 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN project_assignments.assessor_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.project_assignments.assessor_id IS 'Penilai Baru (Re-Assigned)';


--
-- TOC entry 5041 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN project_assignments.old_assessor_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.project_assignments.old_assessor_id IS 'Penilai Lama';


--
-- TOC entry 5042 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN project_assignments.assigned_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.project_assignments.assigned_by IS 'Administrator yang melakukan penugasan';


--
-- TOC entry 5043 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN project_assignments.reason; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.project_assignments.reason IS 'Argumentasi pindah tugas wajib disematkan';


--
-- TOC entry 243 (class 1259 OID 20854)
-- Name: project_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_reviews (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    reviewer_id uuid NOT NULL,
    status_given character varying(255) NOT NULL,
    review_cycle integer DEFAULT 1 NOT NULL,
    notes text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.project_reviews OWNER TO postgres;

--
-- TOC entry 5044 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN project_reviews.status_given; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.project_reviews.status_given IS 'Misal: revision, approved';


--
-- TOC entry 5045 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN project_reviews.review_cycle; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.project_reviews.review_cycle IS 'Siklus Review ke-1, Review 2, dsb';


--
-- TOC entry 239 (class 1259 OID 20802)
-- Name: project_status_histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_status_histories (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    old_status character varying(255),
    new_status character varying(255) NOT NULL,
    changed_by_user_id uuid,
    notes text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.project_status_histories OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 20687)
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    project_number character varying(255),
    company_name character varying(255),
    pic_name character varying(255),
    phone character varying(255),
    email_pic character varying(255),
    doc_type character varying(255),
    additional_notes text,
    status character varying(255) DEFAULT 'draft'::character varying NOT NULL,
    reviewer_id uuid,
    target_review_date timestamp(0) without time zone,
    submitted_at timestamp(0) without time zone,
    reviewed_at timestamp(0) without time zone,
    approved_at timestamp(0) without time zone,
    rejected_at timestamp(0) without time zone,
    revision_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deadline_date date,
    CONSTRAINT projects_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'submitted'::character varying, 'assigned'::character varying, 'verification'::character varying, 'under_review'::character varying, 'approved'::character varying, 'rejected'::character varying, 'revision'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 20753)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 20622)
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id uuid,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 20604)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    role character varying(255) DEFAULT 'pemohon'::character varying NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'pemohon'::character varying, 'penilai'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 5046 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN users.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.is_active IS 'Toggle nonaktifkan entitas pekerja saat resign tanpa menghapus audit trail.';


--
-- TOC entry 4747 (class 2604 OID 20745)
-- Name: activity_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log ALTER COLUMN id SET DEFAULT nextval('public.activity_log_id_seq'::regclass);


--
-- TOC entry 4749 (class 2604 OID 20847)
-- Name: document_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_categories ALTER COLUMN id SET DEFAULT nextval('public.document_categories_id_seq'::regclass);


--
-- TOC entry 4751 (class 2604 OID 20871)
-- Name: document_versions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_versions ALTER COLUMN id SET DEFAULT nextval('public.document_versions_id_seq'::regclass);


--
-- TOC entry 4740 (class 2604 OID 20666)
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- TOC entry 4739 (class 2604 OID 20649)
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- TOC entry 4736 (class 2604 OID 20601)
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- TOC entry 4742 (class 2604 OID 20678)
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- TOC entry 5011 (class 0 OID 20742)
-- Dependencies: 233
-- Data for Name: activity_log; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5009 (class 0 OID 20724)
-- Dependencies: 231
-- Data for Name: assessment_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.assessment_logs VALUES ('a267208e-04e7-4aef-b022-c9f1ad546530', 'a2671fab-f4f4-4262-8fcc-001417eef891', 'a2671ea8-404d-49c1-8c0c-4ef7392b5754', 'submitted', 'approved', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-02 02:35:15', '2026-08-02 02:35:15', NULL);


--
-- TOC entry 4998 (class 0 OID 20631)
-- Dependencies: 220
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cache VALUES ('dashboard_stats_pemohon_a266f751-4f97-4caf-b81b-441b6015898b', 'a:7:{s:5:"total";i:0;s:5:"draft";i:0;s:9:"submitted";i:0;s:9:"in_review";i:0;s:8:"revision";i:0;s:8:"approved";i:0;s:8:"rejected";i:0;}', 1785634255);
INSERT INTO public.cache VALUES ('dashboard_stats_pemohon_a26714a6-cfd8-4374-9e8b-6c6f0a47f7e8', 'a:7:{s:5:"total";i:0;s:5:"draft";i:0;s:9:"submitted";i:0;s:9:"in_review";i:0;s:8:"revision";i:0;s:8:"approved";i:0;s:8:"rejected";i:0;}', 1785636209);
INSERT INTO public.cache VALUES ('dashboard_stats_pemohon_a267184a-8d86-4e41-88d9-22984aed86c2', 'a:7:{s:5:"total";i:0;s:5:"draft";i:0;s:9:"submitted";i:0;s:9:"in_review";i:0;s:8:"revision";i:0;s:8:"approved";i:0;s:8:"rejected";i:0;}', 1785637133);
INSERT INTO public.cache VALUES ('dashboard_stats_pemohon_a2671bc3-601c-4442-9f7c-840579d41cf3', 'a:7:{s:5:"total";i:1;s:5:"draft";i:0;s:9:"submitted";i:1;s:9:"in_review";i:0;s:8:"revision";i:0;s:8:"approved";i:0;s:8:"rejected";i:0;}', 1785637540);
INSERT INTO public.cache VALUES ('dashboard_stats_admin_a266f750-a9e9-45c0-9483-7692e2e3fd9e', 'a:7:{s:5:"total";i:1;s:5:"draft";i:0;s:9:"submitted";i:1;s:9:"in_review";i:0;s:8:"revision";i:0;s:8:"approved";i:0;s:8:"rejected";i:0;}', 1785637728);
INSERT INTO public.cache VALUES ('dashboard_stats_pemohon_a2671e60-ab19-4574-b684-688410c073c7', 'a:7:{s:5:"total";i:1;s:5:"draft";i:0;s:9:"submitted";i:0;s:9:"in_review";i:0;s:8:"revision";i:0;s:8:"approved";i:1;s:8:"rejected";i:0;}', 1785639293);


--
-- TOC entry 4999 (class 0 OID 20638)
-- Dependencies: 221
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5014 (class 0 OID 20771)
-- Dependencies: 236
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5020 (class 0 OID 20844)
-- Dependencies: 242
-- Data for Name: document_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5024 (class 0 OID 20885)
-- Dependencies: 246
-- Data for Name: document_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.document_types VALUES ('a267190a-fb88-4490-ba0e-29b62233830b', 'Sertifikat', 'Melihat Sertifikat', true, '2026-08-02 02:14:14', '2026-08-02 02:14:14');


--
-- TOC entry 5023 (class 0 OID 20868)
-- Dependencies: 245
-- Data for Name: document_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5008 (class 0 OID 20710)
-- Dependencies: 230
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5004 (class 0 OID 20663)
-- Dependencies: 226
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5002 (class 0 OID 20655)
-- Dependencies: 224
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5001 (class 0 OID 20646)
-- Dependencies: 223
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.jobs VALUES (1, 'default', '{"uuid":"a330a614-9757-47d9-af5e-3782b5d8667e","displayName":"App\\Jobs\\ProcessDocumentUploadJob","job":"Illuminate\\Queue\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"App\\Jobs\\ProcessDocumentUploadJob","command":"O:33:\"App\\Jobs\\ProcessDocumentUploadJob\":5:{s:9:\"projectId\";s:36:\"a2671cbe-b0ed-4724-9020-b9785bbdcbbc\";s:8:\"category\";s:5:\"utama\";s:8:\"origName\";s:17:\"We are hiring.pdf\";s:3:\"ext\";s:3:\"pdf\";s:8:\"tempPath\";s:59:\"temp_documents\/K5orYUvmn6xEWvYkwhUOTUyyy7I200epDNtJxR2a.pdf\";}"}}', 0, NULL, 1785637477, 1785637477);
INSERT INTO public.jobs VALUES (2, 'default', '{"uuid":"0b69560d-630a-4806-bd4c-f1f50db290e8","displayName":"App\\Jobs\\ProcessDocumentUploadJob","job":"Illuminate\\Queue\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"App\\Jobs\\ProcessDocumentUploadJob","command":"O:33:\"App\\Jobs\\ProcessDocumentUploadJob\":5:{s:9:\"projectId\";s:36:\"a2671fab-f4f4-4262-8fcc-001417eef891\";s:8:\"category\";s:5:\"utama\";s:8:\"origName\";s:17:\"We are hiring.pdf\";s:3:\"ext\";s:3:\"pdf\";s:8:\"tempPath\";s:59:\"temp_documents\/jB7cJ0OBCeZ24d52DPYRm0NlaQxKBPF5jXWik5F3.pdf\";}"}}', 0, NULL, 1785637966, 1785637966);


--
-- TOC entry 5015 (class 0 OID 20780)
-- Dependencies: 237
-- Data for Name: master_document_types; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4994 (class 0 OID 20598)
-- Dependencies: 216
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.migrations VALUES (1, '0001_01_01_000000_create_users_table', 1);
INSERT INTO public.migrations VALUES (2, '0001_01_01_000001_create_cache_table', 1);
INSERT INTO public.migrations VALUES (3, '0001_01_01_000002_create_jobs_table', 1);
INSERT INTO public.migrations VALUES (4, '2026_07_28_151832_create_personal_access_tokens_table', 1);
INSERT INTO public.migrations VALUES (5, '2026_07_28_152157_create_projects_table', 1);
INSERT INTO public.migrations VALUES (6, '2026_07_28_152201_create_documents_table', 1);
INSERT INTO public.migrations VALUES (7, '2026_07_28_152204_create_assessment_logs_table', 1);
INSERT INTO public.migrations VALUES (8, '2026_07_29_001934_create_activity_log_table', 1);
INSERT INTO public.migrations VALUES (9, '2026_07_29_001935_add_event_column_to_activity_log_table', 1);
INSERT INTO public.migrations VALUES (10, '2026_07_29_001936_add_batch_uuid_column_to_activity_log_table', 1);
INSERT INTO public.migrations VALUES (11, '2026_07_29_002000_create_enterprise_tables', 1);
INSERT INTO public.migrations VALUES (12, '2026_07_29_002005_create_project_status_histories_table', 1);
INSERT INTO public.migrations VALUES (13, '2026_07_29_153000_create_advanced_enterprise_schema_tables', 1);
INSERT INTO public.migrations VALUES (14, '2026_07_29_161500_create_document_versions_table', 1);
INSERT INTO public.migrations VALUES (15, '2026_07_30_043249_add_is_active_and_role_to_users_table', 1);
INSERT INTO public.migrations VALUES (16, '2026_07_30_043455_create_document_types_table', 1);
INSERT INTO public.migrations VALUES (17, '2026_07_30_999999_add_deadline_date_to_projects_table', 1);


--
-- TOC entry 5016 (class 0 OID 20789)
-- Dependencies: 238
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4996 (class 0 OID 20615)
-- Dependencies: 218
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5013 (class 0 OID 20762)
-- Dependencies: 235
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5006 (class 0 OID 20675)
-- Dependencies: 228
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.personal_access_tokens VALUES (7, 'App\Models\User', 'a266f751-4f97-4caf-b81b-441b6015898b', 'auth_token', '2119a18a87b397f9e6d17ee0d49d38b5760412cba744e78b5e2bd2b17c637c95', '["*"]', NULL, NULL, '2026-08-02 01:29:52', '2026-08-02 01:29:52');
INSERT INTO public.personal_access_tokens VALUES (10, 'App\Models\User', 'a26714a6-cfd8-4374-9e8b-6c6f0a47f7e8', 'auth_token', 'baea6b8fa7456fac8d935b7c4815edb35fd8d66fc7a5c3756c7dfbe6c6a8375d', '["*"]', NULL, NULL, '2026-08-02 02:02:26', '2026-08-02 02:02:26');
INSERT INTO public.personal_access_tokens VALUES (16, 'App\Models\User', 'a266f750-a9e9-45c0-9483-7692e2e3fd9e', 'auth_token', 'd0abbc65930c7dd68a779df085f710370d182ac933da865f7450f0ddacd12650', '["*"]', NULL, NULL, '2026-08-02 02:27:45', '2026-08-02 02:27:45');
INSERT INTO public.personal_access_tokens VALUES (17, 'App\Models\User', 'a2671e60-ab19-4574-b684-688410c073c7', 'auth_token', 'f5fbd7d2e2f3e02b1c191a72d22307236d96e7dbf32c57f7d0c6fc72da983977', '["*"]', NULL, NULL, '2026-08-02 02:30:30', '2026-08-02 02:30:30');
INSERT INTO public.personal_access_tokens VALUES (18, 'App\Models\User', 'a2671ea8-404d-49c1-8c0c-4ef7392b5754', 'auth_token', 'ecf78ceb55b17a08b6d0086709354c3fc7522427d4ac220d9f9764579db4d661', '["*"]', NULL, NULL, '2026-08-02 02:34:24', '2026-08-02 02:34:24');
INSERT INTO public.personal_access_tokens VALUES (19, 'App\Models\User', 'a2671e60-ab19-4574-b684-688410c073c7', 'auth_token', '0c7337ee31ed4b4b3b9df12abd5a10f24644216d027b327411e2472c6716a485', '["*"]', NULL, NULL, '2026-08-02 02:35:42', '2026-08-02 02:35:42');


--
-- TOC entry 5018 (class 0 OID 20820)
-- Dependencies: 240
-- Data for Name: project_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5021 (class 0 OID 20854)
-- Dependencies: 243
-- Data for Name: project_reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5017 (class 0 OID 20802)
-- Dependencies: 239
-- Data for Name: project_status_histories; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5007 (class 0 OID 20687)
-- Dependencies: 229
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.projects VALUES ('a2671cbe-b0ed-4724-9020-b9785bbdcbbc', 'a2671bc3-601c-4442-9f7c-840579d41cf3', 'Sertifikan', 'Melihat Review sebelum ke peserta', 'DOC-20260802-000001', 'NusaCodes', 'NusaCode', '08127382193', 'nusacode@gmai.com', 'Sertifikat', NULL, 'submitted', NULL, NULL, '2026-08-02 02:24:38', NULL, NULL, NULL, 0, '2026-08-02 02:24:35', '2026-08-02 02:24:38', NULL, '2026-08-05');
INSERT INTO public.projects VALUES ('a2671fab-f4f4-4262-8fcc-001417eef891', 'a2671e60-ab19-4574-b684-688410c073c7', 'Sertifikat', 'Melihat Review', 'DOC-20260802-000002', 'NusaCode', 'NusaCode', '0868213124', 'nusacode@gmail.com', 'Sertifikat', NULL, 'approved', 'a2671ea8-404d-49c1-8c0c-4ef7392b5754', NULL, '2026-08-02 02:32:48', '2026-08-02 02:35:15', '2026-08-02 02:35:15', NULL, 0, '2026-08-02 02:32:46', '2026-08-02 02:35:15', NULL, NULL);


--
-- TOC entry 5012 (class 0 OID 20753)
-- Dependencies: 234
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4997 (class 0 OID 20622)
-- Dependencies: 219
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sessions VALUES ('oEXGOBAFXLL7dujoh7r0UksKD2Z602ymoTvfzgut', 'a266f750-a9e9-45c0-9483-7692e2e3fd9e', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', 'YTo1OntzOjY6Il90b2tlbiI7czo0MDoiVzhkaVlBSUgxbFVYc1hTcXNGWXJnVUkyRXdxekJIYWl1Q25NWWEwZiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9hcGkvYWRtaW4vdXNlcnMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7czozNjoiYTI2NmY3NTAtYTllOS00NWMwLTk0ODMtNzY5MmUyZTNmZDllIjtzOjE3OiJwYXNzd29yZF9oYXNoX3dlYiI7czo2MDoiJDJ5JDEyJG1maVJlbVBpb3laMDd6QlY5Q1F0M2VEQnU3TnFpNzVYanBURXlSNUdISnZIUGtSanJwUjZXIjt9', 1785643647);
INSERT INTO public.sessions VALUES ('8jy3UkGo3inStax8vdegiMPqnNHSXFlOEo7Si53G', 'a2671e60-ab19-4574-b684-688410c073c7', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', 'YTo1OntzOjk6Il9wcmV2aW91cyI7YToxOntzOjM6InVybCI7czo3OToiaHR0cDovL2xvY2FsaG9zdDo4MDAwL2FwaS9wcm9qZWN0cy9hMjY3MWZhYi1mNGY0LTQyNjItOGZjYy0wMDE0MTdlZWY4OTEvaGlzdG9yeSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NjoiX3Rva2VuIjtzOjQwOiJTekNQdFBocEpPUFRuT3I5S1lzWlZITFZlRVRQRVNCNGl0MXNweXVLIjtzOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7czozNjoiYTI2NzFlNjAtYWIxOS00NTc0LWI2ODQtNjg4NDEwYzA3M2M3IjtzOjE3OiJwYXNzd29yZF9oYXNoX3dlYiI7czo2MDoiJDJ5JDEyJDBaQVRIdlU1M1BOa2JyT3pVVXZhZk9ITVNLVEt4MHB6OFZ6RUNQYm5xa1kyMm1UNHNVZ2NtIjt9', 1785639249);


--
-- TOC entry 4995 (class 0 OID 20604)
-- Dependencies: 217
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES ('a266f750-a9e9-45c0-9483-7692e2e3fd9e', 'Super Administrator', 'admin@example.com', NULL, '$2y$12$mfiRemPioyZ07zBV9CQt3eDBu7Nqi75XjpTEyR5GHJvHPkRjrpR6W', 'admin', NULL, '2026-08-02 00:39:56', '2026-08-02 00:39:56', NULL, true);
INSERT INTO public.users VALUES ('a266f751-4f97-4caf-b81b-441b6015898b', 'Pemohon 1', 'pemohon@example.com', NULL, '$2y$12$KZ//AgvZ5GPyoVPYocr1B.Vwd6Vll41s.xPDfEvATRGBWFu8XHPBi', 'pemohon', NULL, '2026-08-02 00:39:56', '2026-08-02 00:39:56', NULL, true);
INSERT INTO public.users VALUES ('a266f751-ee65-4857-a568-99ec4d7240c5', 'Penilai 1', 'penilai@example.com', NULL, '$2y$12$4tzFpSfQvYTWPrE/KvpTD.7GEyeVpQBZDlHKajzm0SSsu6AmM/a8C', 'penilai', NULL, '2026-08-02 00:39:57', '2026-08-02 00:39:57', NULL, true);
INSERT INTO public.users VALUES ('a26714a6-cfd8-4374-9e8b-6c6f0a47f7e8', 'hafis', 'hafisardiyanto19@gmail.com', NULL, '$2y$12$rtroZfi2wlBMkYzKzjDM1.Pcth/urlMlm5ygxS0MhI00XBg2uFtHG', 'pemohon', NULL, '2026-08-02 02:01:58', '2026-08-02 02:03:52', '2026-08-02 02:03:52', true);
INSERT INTO public.users VALUES ('a267184a-8d86-4e41-88d9-22984aed86c2', 'Firmasnyah', 'hafisfirmansyah372@gmail.com', NULL, '$2y$12$jE2b4CokpVHXswZjdKDkz.X7zsQVSrzmXUcaiRPPW/dPsdgCVR/xe', 'pemohon', NULL, '2026-08-02 02:12:08', '2026-08-02 02:18:21', '2026-08-02 02:18:21', true);
INSERT INTO public.users VALUES ('a2671bc3-601c-4442-9f7c-840579d41cf3', 'pemohon 2', 'pemohon2@gmail.com', NULL, '$2y$12$qDRN0etSl6jotxqUVNBwmuzzZA4e6ha0oRn/KzFxSdfyDFtGUUNeS', 'pemohon', NULL, '2026-08-02 02:21:51', '2026-08-02 02:21:51', NULL, true);
INSERT INTO public.users VALUES ('a2671e60-ab19-4574-b684-688410c073c7', 'pemohon3', 'pemohon3@gmail.com', NULL, '$2y$12$0ZATHvU53PNkbrOzUUvafOHMSKTKx0pz8VzECPbnqkY22mT4sUgcm', 'pemohon', NULL, '2026-08-02 02:29:09', '2026-08-02 02:29:09', NULL, true);
INSERT INTO public.users VALUES ('a2671ea8-404d-49c1-8c0c-4ef7392b5754', 'Penilai2', 'penilai2@gmail.com', NULL, '$2y$12$LnD7sTyqZ4uPL4OTJbbxoO6yhV9wRmI9fNS8dBWDBl9H3XzMj/kIG', 'penilai', NULL, '2026-08-02 02:29:56', '2026-08-02 02:33:59', NULL, true);


--
-- TOC entry 5047 (class 0 OID 0)
-- Dependencies: 232
-- Name: activity_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.activity_log_id_seq', 1, false);


--
-- TOC entry 5048 (class 0 OID 0)
-- Dependencies: 241
-- Name: document_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.document_categories_id_seq', 1, false);


--
-- TOC entry 5049 (class 0 OID 0)
-- Dependencies: 244
-- Name: document_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.document_versions_id_seq', 1, false);


--
-- TOC entry 5050 (class 0 OID 0)
-- Dependencies: 225
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- TOC entry 5051 (class 0 OID 0)
-- Dependencies: 222
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jobs_id_seq', 2, true);


--
-- TOC entry 5052 (class 0 OID 0)
-- Dependencies: 215
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 17, true);


--
-- TOC entry 5053 (class 0 OID 0)
-- Dependencies: 227
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 19, true);


--
-- TOC entry 4799 (class 2606 OID 20749)
-- Name: activity_log activity_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_pkey PRIMARY KEY (id);


--
-- TOC entry 4796 (class 2606 OID 20740)
-- Name: assessment_logs assessment_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_logs
    ADD CONSTRAINT assessment_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4772 (class 2606 OID 20644)
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- TOC entry 4770 (class 2606 OID 20637)
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- TOC entry 4811 (class 2606 OID 20779)
-- Name: companies companies_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_name_unique UNIQUE (name);


--
-- TOC entry 4813 (class 2606 OID 20777)
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- TOC entry 4825 (class 2606 OID 20853)
-- Name: document_categories document_categories_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_name_unique UNIQUE (name);


--
-- TOC entry 4827 (class 2606 OID 20851)
-- Name: document_categories document_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4833 (class 2606 OID 20894)
-- Name: document_types document_types_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_types
    ADD CONSTRAINT document_types_name_unique UNIQUE (name);


--
-- TOC entry 4835 (class 2606 OID 20892)
-- Name: document_types document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_types
    ADD CONSTRAINT document_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4831 (class 2606 OID 20874)
-- Name: document_versions document_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_versions
    ADD CONSTRAINT document_versions_pkey PRIMARY KEY (id);


--
-- TOC entry 4794 (class 2606 OID 20723)
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- TOC entry 4779 (class 2606 OID 20671)
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 4781 (class 2606 OID 20673)
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- TOC entry 4777 (class 2606 OID 20661)
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- TOC entry 4774 (class 2606 OID 20653)
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 4815 (class 2606 OID 20786)
-- Name: master_document_types master_document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.master_document_types
    ADD CONSTRAINT master_document_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4817 (class 2606 OID 20788)
-- Name: master_document_types master_document_types_type_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.master_document_types
    ADD CONSTRAINT master_document_types_type_code_unique UNIQUE (type_code);


--
-- TOC entry 4758 (class 2606 OID 20603)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 4819 (class 2606 OID 20801)
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 4764 (class 2606 OID 20621)
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- TOC entry 4807 (class 2606 OID 20770)
-- Name: permissions permissions_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_name_unique UNIQUE (name);


--
-- TOC entry 4809 (class 2606 OID 20768)
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 4784 (class 2606 OID 20682)
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4786 (class 2606 OID 20685)
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- TOC entry 4823 (class 2606 OID 20841)
-- Name: project_assignments project_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT project_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 4829 (class 2606 OID 20866)
-- Name: project_reviews project_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_reviews
    ADD CONSTRAINT project_reviews_pkey PRIMARY KEY (id);


--
-- TOC entry 4821 (class 2606 OID 20818)
-- Name: project_status_histories project_status_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_status_histories
    ADD CONSTRAINT project_status_histories_pkey PRIMARY KEY (id);


--
-- TOC entry 4789 (class 2606 OID 20706)
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- TOC entry 4791 (class 2606 OID 20708)
-- Name: projects projects_project_number_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_project_number_unique UNIQUE (project_number);


--
-- TOC entry 4803 (class 2606 OID 20761)
-- Name: roles roles_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_unique UNIQUE (name);


--
-- TOC entry 4805 (class 2606 OID 20759)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4767 (class 2606 OID 20628)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 4760 (class 2606 OID 20614)
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- TOC entry 4762 (class 2606 OID 20612)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4797 (class 1259 OID 20752)
-- Name: activity_log_log_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX activity_log_log_name_index ON public.activity_log USING btree (log_name);


--
-- TOC entry 4800 (class 1259 OID 20751)
-- Name: causer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX causer ON public.activity_log USING btree (causer_type, causer_id);


--
-- TOC entry 4775 (class 1259 OID 20654)
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- TOC entry 4782 (class 1259 OID 20686)
-- Name: personal_access_tokens_expires_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_expires_at_index ON public.personal_access_tokens USING btree (expires_at);


--
-- TOC entry 4787 (class 1259 OID 20683)
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- TOC entry 4792 (class 1259 OID 20709)
-- Name: projects_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_status_index ON public.projects USING btree (status);


--
-- TOC entry 4765 (class 1259 OID 20630)
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- TOC entry 4768 (class 1259 OID 20629)
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- TOC entry 4801 (class 1259 OID 20750)
-- Name: subject; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subject ON public.activity_log USING btree (subject_type, subject_id);


--
-- TOC entry 4839 (class 2606 OID 20734)
-- Name: assessment_logs assessment_logs_assessor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_logs
    ADD CONSTRAINT assessment_logs_assessor_id_foreign FOREIGN KEY (assessor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4840 (class 2606 OID 20729)
-- Name: assessment_logs assessment_logs_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_logs
    ADD CONSTRAINT assessment_logs_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- TOC entry 4848 (class 2606 OID 20875)
-- Name: document_versions document_versions_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_versions
    ADD CONSTRAINT document_versions_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- TOC entry 4849 (class 2606 OID 20880)
-- Name: document_versions document_versions_uploaded_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_versions
    ADD CONSTRAINT document_versions_uploaded_by_foreign FOREIGN KEY (uploaded_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4838 (class 2606 OID 20717)
-- Name: documents documents_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- TOC entry 4841 (class 2606 OID 20795)
-- Name: notifications notifications_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4844 (class 2606 OID 20830)
-- Name: project_assignments project_assignments_assessor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT project_assignments_assessor_id_foreign FOREIGN KEY (assessor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4845 (class 2606 OID 20835)
-- Name: project_assignments project_assignments_assigned_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT project_assignments_assigned_by_foreign FOREIGN KEY (assigned_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4846 (class 2606 OID 20825)
-- Name: project_assignments project_assignments_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT project_assignments_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- TOC entry 4847 (class 2606 OID 20860)
-- Name: project_reviews project_reviews_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_reviews
    ADD CONSTRAINT project_reviews_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- TOC entry 4842 (class 2606 OID 20812)
-- Name: project_status_histories project_status_histories_changed_by_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_status_histories
    ADD CONSTRAINT project_status_histories_changed_by_user_id_foreign FOREIGN KEY (changed_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4843 (class 2606 OID 20807)
-- Name: project_status_histories project_status_histories_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_status_histories
    ADD CONSTRAINT project_status_histories_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- TOC entry 4836 (class 2606 OID 20700)
-- Name: projects projects_reviewer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_reviewer_id_foreign FOREIGN KEY (reviewer_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4837 (class 2606 OID 20695)
-- Name: projects projects_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2026-08-02 11:08:03

--
-- PostgreSQL database dump complete
--

\unrestrict XQHuuZCGGgi2u7sEVajcLk44beQkjgva57kvd0xmScjh36f4Ax0NJam6Gej6K8s

