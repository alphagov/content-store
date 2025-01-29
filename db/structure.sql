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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: notify_route_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_route_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
          -- Trigger on INSERT or DELETE
          IF (TG_OP = 'INSERT' OR TG_OP = 'DELETE') THEN
              PERFORM pg_notify('route_changes', '');
              RETURN COALESCE(NEW, OLD);
          END IF;

          -- Trigger on UPDATE for specific columns
          IF (TG_OP = 'UPDATE') THEN
              IF TG_TABLE_NAME = 'content_items' THEN
                -- Specific column checks for the content_items table
                IF (NEW.routes IS DISTINCT FROM OLD.routes OR
                  NEW.redirects IS DISTINCT FROM OLD.redirects OR
                  NEW.schema_name IS DISTINCT FROM OLD.schema_name OR
                  NEW.rendering_app IS DISTINCT FROM OLD.rendering_app) THEN
                  PERFORM pg_notify('route_changes', '');
                END IF;
              ELSIF TG_TABLE_NAME = 'publish_intents' THEN
                -- Specific column checks for publish_intents table
                IF (NEW.routes IS DISTINCT FROM OLD.routes OR
                    NEW.rendering_app IS DISTINCT FROM OLD.rendering_app) THEN
                    PERFORM pg_notify('route_changes', '');
                END IF;
              END IF;
          END IF;

          RETURN COALESCE(NEW, OLD);
      END;
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: content_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    base_path character varying,
    content_id character varying,
    title character varying,
    description jsonb DEFAULT '{"value": null}'::jsonb,
    document_type character varying,
    content_purpose_document_supertype character varying DEFAULT ''::character varying,
    content_purpose_subgroup character varying DEFAULT ''::character varying,
    content_purpose_supergroup character varying DEFAULT ''::character varying,
    email_document_supertype character varying DEFAULT ''::character varying,
    government_document_supertype character varying DEFAULT ''::character varying,
    navigation_document_supertype character varying DEFAULT ''::character varying,
    search_user_need_document_supertype character varying DEFAULT ''::character varying,
    user_journey_document_supertype character varying DEFAULT ''::character varying,
    schema_name character varying,
    locale character varying DEFAULT 'en'::character varying,
    first_published_at timestamp(6) without time zone,
    public_updated_at timestamp(6) without time zone,
    publishing_scheduled_at timestamp(6) without time zone,
    details jsonb DEFAULT '{}'::jsonb,
    publishing_app character varying,
    rendering_app character varying,
    routes jsonb DEFAULT '[]'::jsonb,
    redirects jsonb DEFAULT '[]'::jsonb,
    expanded_links jsonb DEFAULT '{}'::jsonb,
    access_limited jsonb DEFAULT '{}'::jsonb,
    auth_bypass_ids character varying[] DEFAULT '{}'::character varying[],
    phase character varying DEFAULT 'live'::character varying,
    analytics_identifier character varying,
    payload_version integer,
    withdrawn_notice jsonb DEFAULT '{}'::jsonb,
    publishing_request_id character varying,
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone,
    _id character varying,
    scheduled_publishing_delay_seconds bigint
);


--
-- Name: publish_intents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publish_intents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    base_path character varying,
    publish_time timestamp(6) without time zone,
    publishing_app character varying,
    rendering_app character varying,
    routes jsonb DEFAULT '[]'::jsonb,
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone
);


--
-- Name: scheduled_publishing_log_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_publishing_log_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    base_path character varying,
    document_type character varying,
    scheduled_publication_time timestamp(6) without time zone,
    delay_in_milliseconds bigint,
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone,
    mongo_id character varying
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    uid character varying,
    email character varying,
    permissions character varying[],
    remotely_signed_out boolean DEFAULT false,
    organisation_slug character varying,
    disabled boolean DEFAULT false,
    organisation_content_id character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    mongo_id character varying
);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: content_items content_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_items
    ADD CONSTRAINT content_items_pkey PRIMARY KEY (id);


--
-- Name: publish_intents publish_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publish_intents
    ADD CONSTRAINT publish_intents_pkey PRIMARY KEY (id);


--
-- Name: scheduled_publishing_log_entries scheduled_publishing_log_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_publishing_log_entries
    ADD CONSTRAINT scheduled_publishing_log_entries_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_content_items_on_base_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_items_on_base_path ON public.content_items USING btree (base_path);


--
-- Name: index_content_items_on_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_items_on_content_id ON public.content_items USING btree (content_id);


--
-- Name: index_content_items_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_items_on_created_at ON public.content_items USING btree (created_at);


--
-- Name: index_content_items_on_redirects; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_items_on_redirects ON public.content_items USING gin (redirects);


--
-- Name: index_content_items_on_routes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_items_on_routes ON public.content_items USING gin (routes);


--
-- Name: index_content_items_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_items_on_updated_at ON public.content_items USING btree (updated_at);


--
-- Name: index_publish_intents_on_base_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_publish_intents_on_base_path ON public.publish_intents USING btree (base_path);


--
-- Name: index_publish_intents_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publish_intents_on_created_at ON public.publish_intents USING btree (created_at);


--
-- Name: index_publish_intents_on_publish_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publish_intents_on_publish_time ON public.publish_intents USING btree (publish_time);


--
-- Name: index_publish_intents_on_routes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publish_intents_on_routes ON public.publish_intents USING gin (routes);


--
-- Name: index_publish_intents_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publish_intents_on_updated_at ON public.publish_intents USING btree (updated_at);


--
-- Name: index_scheduled_publishing_log_entries_on_mongo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scheduled_publishing_log_entries_on_mongo_id ON public.scheduled_publishing_log_entries USING btree (mongo_id);


--
-- Name: index_users_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_at ON public.users USING btree (created_at);


--
-- Name: index_users_on_disabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_disabled ON public.users USING btree (disabled);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_mongo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_mongo_id ON public.users USING btree (mongo_id);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name ON public.users USING btree (name);


--
-- Name: index_users_on_organisation_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_organisation_content_id ON public.users USING btree (organisation_content_id);


--
-- Name: index_users_on_organisation_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_organisation_slug ON public.users USING btree (organisation_slug);


--
-- Name: index_users_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_uid ON public.users USING btree (uid);


--
-- Name: index_users_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_updated_at ON public.users USING btree (updated_at);


--
-- Name: ix_ci_redirects_jsonb_path_ops; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ci_redirects_jsonb_path_ops ON public.content_items USING gin (redirects jsonb_path_ops);


--
-- Name: ix_ci_routes_jsonb_path_ops; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ci_routes_jsonb_path_ops ON public.content_items USING gin (routes jsonb_path_ops);


--
-- Name: ix_pi_routes_jsonb_path_ops; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_pi_routes_jsonb_path_ops ON public.publish_intents USING gin (routes jsonb_path_ops);


--
-- Name: ix_scheduled_pub_log_base_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_scheduled_pub_log_base_path ON public.scheduled_publishing_log_entries USING btree (base_path);


--
-- Name: ix_scheduled_pub_log_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_scheduled_pub_log_created ON public.scheduled_publishing_log_entries USING btree (created_at);


--
-- Name: ix_scheduled_pub_log_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_scheduled_pub_log_time ON public.scheduled_publishing_log_entries USING btree (scheduled_publication_time);


--
-- Name: content_items content_item_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER content_item_change_trigger AFTER INSERT OR DELETE OR UPDATE ON public.content_items FOR EACH ROW EXECUTE FUNCTION public.notify_route_change();


--
-- Name: publish_intents publish_intent_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER publish_intent_change_trigger AFTER INSERT OR DELETE OR UPDATE ON public.publish_intents FOR EACH ROW EXECUTE FUNCTION public.notify_route_change();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20241209132444'),
('20241105135438'),
('20240312132747'),
('20240220151333'),
('20231016112610'),
('20230830093643'),
('20230428144838'),
('20230425074357'),
('20230425074342'),
('20230420105019'),
('20230328141957'),
('20230328131042'),
('20230327101936'),
('20230327101118'),
('20230324113335'),
('20230320150042'),
('20230319100101');

