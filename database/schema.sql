--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Ubuntu 11.5-1)
-- Dumped by pg_dump version 11.6 (Ubuntu 11.6-1.pgdg18.04+1)

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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ads; Type: TABLE; Schema: public; Owner: inaki
--

CREATE TABLE public.ads (
    id bigint NOT NULL,
    keywords character varying[] NOT NULL,
    content text NOT NULL,
    uri character varying(200) NOT NULL
);


ALTER TABLE public.ads OWNER TO inaki;

--
-- Name: ads_id_seq; Type: SEQUENCE; Schema: public; Owner: inaki
--

ALTER TABLE public.ads ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pages; Type: TABLE; Schema: public; Owner: inaki
--

CREATE TABLE public.pages (
    id bigint NOT NULL,
    uri character varying(300) NOT NULL,
    scraped_at timestamp without time zone DEFAULT (now())::timestamp without time zone,
    title character varying(250) DEFAULT 'No Title'::character varying,
    image character varying(500)
);


ALTER TABLE public.pages OWNER TO inaki;

--
-- Name: words; Type: TABLE; Schema: public; Owner: inaki
--

CREATE TABLE public.words (
    word character varying(200) NOT NULL,
    id bigint NOT NULL,
    page_ids bigint[]
);


ALTER TABLE public.words OWNER TO inaki;

--
-- Name: TABLE words; Type: COMMENT; Schema: public; Owner: inaki
--

COMMENT ON TABLE public.words IS 'inverted index';


--
-- Name: words_id_seq; Type: SEQUENCE; Schema: public; Owner: inaki
--

ALTER TABLE public.words ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.words_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ads ads_pkey; Type: CONSTRAINT; Schema: public; Owner: inaki
--

ALTER TABLE ONLY public.ads
    ADD CONSTRAINT ads_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: inaki
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: words words_pkey; Type: CONSTRAINT; Schema: public; Owner: inaki
--

ALTER TABLE ONLY public.words
    ADD CONSTRAINT words_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

