/*
 * 3.5e Database Companion - Database Schema & Initial Data
 * Copyright (C) 2026 Daniel Bender
 *
 * -----------------------------------------------------------------------
 * AI DISCLOSURE: 
 * The table structures and data entries in this file were created by the 
 * human author. Gemini Code Assist was utilized specifically for 
 * implementing PostgreSQL Full-Text Search logic (TSVectors) and 
 * performance indexing strategies.
 * -----------------------------------------------------------------------
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

--
-- PostgreSQL database dump
--

\restrict KfLY6u2zhjTjhdw85hbHDKceyhe9bcMkY9f97acfes28II7vmBskHagul8zB359

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

-- Started on 2026-01-07 16:37:18 CET

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
-- TOC entry 1098 (class 1247 OID 36650)
-- Name: armor_category_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.armor_category_enum AS ENUM (
    'Light',
    'Medium',
    'Heavy',
    'Shield',
    'Extra'
);


ALTER TYPE public.armor_category_enum OWNER TO postgres;

--
-- TOC entry 942 (class 1247 OID 35790)
-- Name: dnd_attributes; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.dnd_attributes AS ENUM (
    'Strength',
    'Dexterity',
    'Constitution',
    'Intelligence',
    'Wisdom',
    'Charisma'
);


ALTER TYPE public.dnd_attributes OWNER TO postgres;

--
-- TOC entry 945 (class 1247 OID 35804)
-- Name: weapon_category_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.weapon_category_enum AS ENUM (
    'Unarmed Attacks',
    'Light Melee',
    'One-Handed Melee',
    'Two-Handed Melee',
    'Ranged'
);


ALTER TYPE public.weapon_category_enum OWNER TO postgres;

--
-- TOC entry 948 (class 1247 OID 35816)
-- Name: weapon_handedness_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.weapon_handedness_enum AS ENUM (
    '1-handed',
    '2-handed',
    'versatile'
);


ALTER TYPE public.weapon_handedness_enum OWNER TO postgres;

--
-- TOC entry 951 (class 1247 OID 35824)
-- Name: weapon_side_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.weapon_side_enum AS ENUM (
    'primary',
    'secondary'
);


ALTER TYPE public.weapon_side_enum OWNER TO postgres;

--
-- TOC entry 954 (class 1247 OID 35830)
-- Name: weapon_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.weapon_type_enum AS ENUM (
    'Simple',
    'Martial',
    'Exotic'
);


ALTER TYPE public.weapon_type_enum OWNER TO postgres;

--
-- TOC entry 316 (class 1255 OID 36688)
-- Name: conditions_search_vector_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.conditions_search_vector_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.conditions_search_vector_update() OWNER TO postgres;

--
-- TOC entry 310 (class 1255 OID 35837)
-- Name: feats_search_vector_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.feats_search_vector_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.benefit, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(NEW.special, '')), 'C');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.feats_search_vector_update() OWNER TO postgres;

--
-- TOC entry 311 (class 1255 OID 35838)
-- Name: items_search_vector_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.items_search_vector_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.items_search_vector_update() OWNER TO postgres;

--
-- TOC entry 312 (class 1255 OID 35839)
-- Name: monsters_search_vector_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.monsters_search_vector_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.monsters_search_vector_update() OWNER TO postgres;

--
-- TOC entry 317 (class 1255 OID 36694)
-- Name: propagate_item_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.propagate_item_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_type_name text;
BEGIN
    -- Determine if this is a weapon or armor update based on the table name
    IF TG_TABLE_NAME = 'weapon_properties' THEN
        v_type_name := 'weapon';
    ELSIF TG_TABLE_NAME = 'armor_properties' THEN
        v_type_name := 'armor';
    ELSE
        RETURN NEW;
    END IF;

    -- Update the parent item's timestamp
    UPDATE public.items
    SET last_updated = NOW()
    WHERE properties_id = NEW.id
    AND item_type_id = (SELECT id FROM public.item_types WHERE name = v_type_name);

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.propagate_item_update() OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 36686)
-- Name: rules_search_vector_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.rules_search_vector_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(NEW.category, '')), 'C');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.rules_search_vector_update() OWNER TO postgres;

--
-- TOC entry 313 (class 1255 OID 35840)
-- Name: spells_search_vector_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.spells_search_vector_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.spells_search_vector_update() OWNER TO postgres;

--
-- TOC entry 314 (class 1255 OID 36677)
-- Name: update_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_timestamp() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 295 (class 1259 OID 36596)
-- Name: armor_properties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.armor_properties (
    id integer NOT NULL,
    ac_bonus integer NOT NULL,
    max_dex_bonus integer NOT NULL,
    armor_check_penalty integer NOT NULL,
    speed_thirty integer NOT NULL,
    speed_twenty integer NOT NULL,
    armor_category public.armor_category_enum,
    arcane_spell_failure integer DEFAULT 0
);


ALTER TABLE public.armor_properties OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 36595)
-- Name: armor_properties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.armor_properties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.armor_properties_id_seq OWNER TO postgres;

--
-- TOC entry 4066 (class 0 OID 0)
-- Dependencies: 294
-- Name: armor_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.armor_properties_id_seq OWNED BY public.armor_properties.id;


--
-- TOC entry 303 (class 1259 OID 36798)
-- Name: body_slots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.body_slots (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.body_slots OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 36797)
-- Name: body_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.body_slots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.body_slots_id_seq OWNER TO postgres;

--
-- TOC entry 4067 (class 0 OID 0)
-- Dependencies: 302
-- Name: body_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.body_slots_id_seq OWNED BY public.body_slots.id;


--
-- TOC entry 297 (class 1259 OID 36708)
-- Name: bonus_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bonus_types (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.bonus_types OWNER TO postgres;

--
-- TOC entry 296 (class 1259 OID 36707)
-- Name: bonus_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bonus_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bonus_types_id_seq OWNER TO postgres;

--
-- TOC entry 4068 (class 0 OID 0)
-- Dependencies: 296
-- Name: bonus_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bonus_types_id_seq OWNED BY public.bonus_types.id;


--
-- TOC entry 215 (class 1259 OID 35847)
-- Name: caster_progression; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.caster_progression (
    id integer NOT NULL,
    class_id integer NOT NULL,
    level integer NOT NULL,
    cantrips integer,
    first_grade integer,
    second_grade integer,
    third_grade integer,
    fourth_grade integer,
    fifth_grade integer,
    sixth_grade integer,
    seventh_grade integer,
    eighth_grade integer,
    ninth_grade integer,
    CONSTRAINT caster_progression_level_check CHECK (((level >= 1) AND (level <= 20)))
);


ALTER TABLE public.caster_progression OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 35851)
-- Name: caster_progression_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.caster_progression_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.caster_progression_id_seq OWNER TO postgres;

--
-- TOC entry 4070 (class 0 OID 0)
-- Dependencies: 216
-- Name: caster_progression_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.caster_progression_id_seq OWNED BY public.caster_progression.id;


--
-- TOC entry 283 (class 1259 OID 36469)
-- Name: character_classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_classes (
    character_id integer NOT NULL,
    class_id integer NOT NULL,
    class_level integer NOT NULL
);


ALTER TABLE public.character_classes OWNER TO postgres;

--
-- TOC entry 284 (class 1259 OID 36484)
-- Name: character_feats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_feats (
    character_id integer NOT NULL,
    feat_id integer NOT NULL,
    note text,
    id integer NOT NULL
);


ALTER TABLE public.character_feats OWNER TO postgres;

--
-- TOC entry 298 (class 1259 OID 36724)
-- Name: character_feats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.character_feats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.character_feats_id_seq OWNER TO postgres;

--
-- TOC entry 4073 (class 0 OID 0)
-- Dependencies: 298
-- Name: character_feats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.character_feats_id_seq OWNED BY public.character_feats.id;


--
-- TOC entry 289 (class 1259 OID 36537)
-- Name: character_inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_inventory (
    id integer NOT NULL,
    character_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer DEFAULT 1,
    is_equipped boolean DEFAULT false,
    custom_name text,
    enhancement_bonus integer DEFAULT 0,
    enchantment_ids integer[],
    is_masterwork boolean DEFAULT false,
    notes text
);


ALTER TABLE public.character_inventory OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 36536)
-- Name: character_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.character_inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.character_inventory_id_seq OWNER TO postgres;

--
-- TOC entry 4075 (class 0 OID 0)
-- Dependencies: 288
-- Name: character_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.character_inventory_id_seq OWNED BY public.character_inventory.id;


--
-- TOC entry 285 (class 1259 OID 36501)
-- Name: character_skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_skills (
    character_id integer NOT NULL,
    skill_id integer NOT NULL,
    ranks numeric(4,1) DEFAULT 0 NOT NULL,
    id integer NOT NULL,
    sub_skill text
);


ALTER TABLE public.character_skills OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 36735)
-- Name: character_skills_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.character_skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.character_skills_id_seq OWNER TO postgres;

--
-- TOC entry 4077 (class 0 OID 0)
-- Dependencies: 299
-- Name: character_skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.character_skills_id_seq OWNED BY public.character_skills.id;


--
-- TOC entry 301 (class 1259 OID 36782)
-- Name: character_spell_slots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_spell_slots (
    id integer NOT NULL,
    character_id integer NOT NULL,
    spell_level integer NOT NULL,
    slots_used integer DEFAULT 0
);


ALTER TABLE public.character_spell_slots OWNER TO postgres;

--
-- TOC entry 300 (class 1259 OID 36781)
-- Name: character_spell_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.character_spell_slots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.character_spell_slots_id_seq OWNER TO postgres;

--
-- TOC entry 4078 (class 0 OID 0)
-- Dependencies: 300
-- Name: character_spell_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.character_spell_slots_id_seq OWNED BY public.character_spell_slots.id;


--
-- TOC entry 287 (class 1259 OID 36518)
-- Name: character_spells; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_spells (
    id integer NOT NULL,
    character_id integer,
    spell_id integer,
    is_prepared boolean DEFAULT false,
    is_known boolean DEFAULT true,
    notes text,
    prepared_count integer DEFAULT 0
);


ALTER TABLE public.character_spells OWNER TO postgres;

--
-- TOC entry 286 (class 1259 OID 36517)
-- Name: character_spells_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.character_spells_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.character_spells_id_seq OWNER TO postgres;

--
-- TOC entry 4080 (class 0 OID 0)
-- Dependencies: 286
-- Name: character_spells_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.character_spells_id_seq OWNED BY public.character_spells.id;


--
-- TOC entry 282 (class 1259 OID 36443)
-- Name: characters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.characters (
    id integer NOT NULL,
    user_id integer,
    name text NOT NULL,
    race_id integer,
    alignment text,
    gender text,
    age integer,
    height text,
    weight text,
    description text,
    strength integer DEFAULT 10,
    dexterity integer DEFAULT 10,
    constitution integer DEFAULT 10,
    intelligence integer DEFAULT 10,
    wisdom integer DEFAULT 10,
    charisma integer DEFAULT 10,
    hit_points_max integer,
    hit_points_current integer,
    experience_points integer DEFAULT 0,
    money_gp integer DEFAULT 0
);


ALTER TABLE public.characters OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 36442)
-- Name: characters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.characters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.characters_id_seq OWNER TO postgres;

--
-- TOC entry 4082 (class 0 OID 0)
-- Dependencies: 281
-- Name: characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.characters_id_seq OWNED BY public.characters.id;


--
-- TOC entry 217 (class 1259 OID 35852)
-- Name: class_description_sections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_description_sections (
    id integer NOT NULL,
    class_id integer NOT NULL,
    section_name text NOT NULL,
    content text NOT NULL
);


ALTER TABLE public.class_description_sections OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 35857)
-- Name: class_description_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.class_description_sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.class_description_sections_id_seq OWNER TO postgres;

--
-- TOC entry 4084 (class 0 OID 0)
-- Dependencies: 218
-- Name: class_description_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_description_sections_id_seq OWNED BY public.class_description_sections.id;


--
-- TOC entry 219 (class 1259 OID 35858)
-- Name: class_features; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_features (
    id integer NOT NULL,
    class_id integer NOT NULL,
    level integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.class_features OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 35863)
-- Name: class_features_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.class_features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.class_features_id_seq OWNER TO postgres;

--
-- TOC entry 4086 (class 0 OID 0)
-- Dependencies: 220
-- Name: class_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_features_id_seq OWNED BY public.class_features.id;


--
-- TOC entry 221 (class 1259 OID 35864)
-- Name: class_progression; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_progression (
    id integer NOT NULL,
    class_id integer NOT NULL,
    level integer NOT NULL,
    bab integer[] NOT NULL,
    fort integer NOT NULL,
    ref integer NOT NULL,
    will integer NOT NULL,
    CONSTRAINT class_progression_level_check CHECK (((level >= 1) AND (level <= 20)))
);


ALTER TABLE public.class_progression OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 35870)
-- Name: class_progression_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.class_progression_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.class_progression_id_seq OWNER TO postgres;

--
-- TOC entry 4088 (class 0 OID 0)
-- Dependencies: 222
-- Name: class_progression_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_progression_id_seq OWNED BY public.class_progression.id;


--
-- TOC entry 223 (class 1259 OID 35871)
-- Name: class_skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_skills (
    class_id integer NOT NULL,
    skill_id integer NOT NULL
);


ALTER TABLE public.class_skills OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 35874)
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classes (
    id integer NOT NULL,
    name text NOT NULL,
    is_prestige boolean DEFAULT false NOT NULL,
    skill_points integer NOT NULL,
    alignment text NOT NULL,
    source_id integer NOT NULL,
    num_dice integer DEFAULT 1 NOT NULL,
    dice_type integer NOT NULL,
    main_attr public.dnd_attributes NOT NULL,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 35881)
-- Name: classes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.classes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.classes_id_seq OWNER TO postgres;

--
-- TOC entry 4091 (class 0 OID 0)
-- Dependencies: 225
-- Name: classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.classes_id_seq OWNED BY public.classes.id;


--
-- TOC entry 226 (class 1259 OID 35882)
-- Name: conditions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conditions (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    source_id integer,
    search_vector tsvector,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.conditions OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 35887)
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conditions_id_seq OWNER TO postgres;

--
-- TOC entry 4093 (class 0 OID 0)
-- Dependencies: 227
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conditions_id_seq OWNED BY public.conditions.id;


--
-- TOC entry 228 (class 1259 OID 35894)
-- Name: critical_combinations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.critical_combinations (
    id integer NOT NULL,
    crit_range integer,
    crit_damage integer NOT NULL
);


ALTER TABLE public.critical_combinations OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 36863)
-- Name: critical_combinations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.critical_combinations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.critical_combinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 35897)
-- Name: damage_scaling; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.damage_scaling (
    id integer NOT NULL,
    base text NOT NULL,
    lower_one text,
    lower_two text,
    lower_three text,
    lower_four text,
    higher_one text,
    higher_two text,
    higher_three text,
    higher_four text
);


ALTER TABLE public.damage_scaling OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 35902)
-- Name: damage_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.damage_types (
    id integer NOT NULL,
    name text NOT NULL,
    category text
);


ALTER TABLE public.damage_types OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 35907)
-- Name: damage_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.damage_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.damage_type_id_seq OWNER TO postgres;

--
-- TOC entry 4097 (class 0 OID 0)
-- Dependencies: 231
-- Name: damage_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.damage_type_id_seq OWNED BY public.damage_types.id;


--
-- TOC entry 232 (class 1259 OID 35908)
-- Name: domain_spells; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.domain_spells (
    domain_id integer NOT NULL,
    spell_id integer NOT NULL,
    level integer NOT NULL
);


ALTER TABLE public.domain_spells OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 35911)
-- Name: domains; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.domains (
    id integer NOT NULL,
    name text NOT NULL,
    granted_power text,
    source_id integer
);


ALTER TABLE public.domains OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 35916)
-- Name: domains_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.domains_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.domains_id_seq OWNER TO postgres;

--
-- TOC entry 4100 (class 0 OID 0)
-- Dependencies: 234
-- Name: domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.domains_id_seq OWNED BY public.domains.id;


--
-- TOC entry 235 (class 1259 OID 35917)
-- Name: enchantment_applicable_to; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enchantment_applicable_to (
    enchantment_id integer NOT NULL,
    item_type_id integer NOT NULL
);


ALTER TABLE public.enchantment_applicable_to OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 35920)
-- Name: enchantments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enchantments (
    id integer NOT NULL,
    name text NOT NULL,
    bonus_value integer NOT NULL,
    description text NOT NULL,
    source_id integer NOT NULL,
    bonus_type_id integer NOT NULL
);


ALTER TABLE public.enchantments OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 35925)
-- Name: enchantments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.enchantments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.enchantments_id_seq OWNER TO postgres;

--
-- TOC entry 4103 (class 0 OID 0)
-- Dependencies: 237
-- Name: enchantments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.enchantments_id_seq OWNED BY public.enchantments.id;


--
-- TOC entry 238 (class 1259 OID 35926)
-- Name: entity_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_tables (
    id integer NOT NULL,
    source_table_id integer,
    entity_type_id integer,
    entity_id integer NOT NULL
);


ALTER TABLE public.entity_tables OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 35929)
-- Name: entity_tables_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entity_tables_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entity_tables_id_seq OWNER TO postgres;

--
-- TOC entry 4105 (class 0 OID 0)
-- Dependencies: 239
-- Name: entity_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_tables_id_seq OWNED BY public.entity_tables.id;


--
-- TOC entry 240 (class 1259 OID 35930)
-- Name: entity_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_types (
    id integer NOT NULL,
    table_name character varying(50) NOT NULL,
    display_name character varying(50) NOT NULL,
    for_players boolean DEFAULT false NOT NULL
);


ALTER TABLE public.entity_types OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 35934)
-- Name: entity_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entity_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entity_types_id_seq OWNER TO postgres;

--
-- TOC entry 4107 (class 0 OID 0)
-- Dependencies: 241
-- Name: entity_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_types_id_seq OWNED BY public.entity_types.id;


--
-- TOC entry 242 (class 1259 OID 35935)
-- Name: feat_prereq_attribute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feat_prereq_attribute (
    id integer NOT NULL,
    feat_id integer NOT NULL,
    attribute public.dnd_attributes NOT NULL,
    value integer NOT NULL
);


ALTER TABLE public.feat_prereq_attribute OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 35938)
-- Name: feat_prereq_attribute_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feat_prereq_attribute_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feat_prereq_attribute_id_seq OWNER TO postgres;

--
-- TOC entry 4109 (class 0 OID 0)
-- Dependencies: 243
-- Name: feat_prereq_attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feat_prereq_attribute_id_seq OWNED BY public.feat_prereq_attribute.id;


--
-- TOC entry 244 (class 1259 OID 35939)
-- Name: feat_prereq_feat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feat_prereq_feat (
    id integer NOT NULL,
    feat_id integer NOT NULL,
    prereq_feat_id integer NOT NULL
);


ALTER TABLE public.feat_prereq_feat OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 35942)
-- Name: feat_prereq_feat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feat_prereq_feat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feat_prereq_feat_id_seq OWNER TO postgres;

--
-- TOC entry 4111 (class 0 OID 0)
-- Dependencies: 245
-- Name: feat_prereq_feat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feat_prereq_feat_id_seq OWNED BY public.feat_prereq_feat.id;


--
-- TOC entry 246 (class 1259 OID 35943)
-- Name: feat_prereq_skill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feat_prereq_skill (
    id integer NOT NULL,
    feat_id integer NOT NULL,
    skill_name text NOT NULL,
    ranks integer NOT NULL
);


ALTER TABLE public.feat_prereq_skill OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 35948)
-- Name: feat_prereq_skill_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feat_prereq_skill_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feat_prereq_skill_id_seq OWNER TO postgres;

--
-- TOC entry 4113 (class 0 OID 0)
-- Dependencies: 247
-- Name: feat_prereq_skill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feat_prereq_skill_id_seq OWNED BY public.feat_prereq_skill.id;


--
-- TOC entry 248 (class 1259 OID 35949)
-- Name: feats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feats (
    id integer NOT NULL,
    name text NOT NULL,
    feat_type text,
    benefit text NOT NULL,
    normal text,
    special text,
    description text,
    source_id integer NOT NULL,
    search_vector tsvector,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.feats OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 35954)
-- Name: feats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feats_id_seq OWNER TO postgres;

--
-- TOC entry 4115 (class 0 OID 0)
-- Dependencies: 249
-- Name: feats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feats_id_seq OWNED BY public.feats.id;


--
-- TOC entry 250 (class 1259 OID 35955)
-- Name: item_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_types (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.item_types OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 35960)
-- Name: item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.item_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.item_types_id_seq OWNER TO postgres;

--
-- TOC entry 4117 (class 0 OID 0)
-- Dependencies: 251
-- Name: item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.item_types_id_seq OWNED BY public.item_types.id;


--
-- TOC entry 291 (class 1259 OID 36559)
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    price integer,
    weight numeric(6,2),
    source_id integer,
    image_url text,
    base_item_id integer,
    properties_id integer,
    last_updated timestamp with time zone DEFAULT now(),
    search_vector tsvector,
    item_type_id integer NOT NULL,
    enhancement_bonus integer DEFAULT 0,
    enchantment_ids integer[],
    body_slot_id integer
);


ALTER TABLE public.items OWNER TO postgres;

--
-- TOC entry 290 (class 1259 OID 36558)
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.items_id_seq OWNER TO postgres;

--
-- TOC entry 4119 (class 0 OID 0)
-- Dependencies: 290
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- TOC entry 252 (class 1259 OID 35961)
-- Name: monsters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.monsters (
    id integer NOT NULL,
    name text NOT NULL,
    cr_text text,
    type text,
    alignment text,
    hit_dice text,
    description text,
    source_id integer,
    num_dice integer,
    dice_type integer,
    bonus integer,
    cr_number numeric(4,2),
    search_vector tsvector,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.monsters OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 35966)
-- Name: monsters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.monsters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.monsters_id_seq OWNER TO postgres;

--
-- TOC entry 4121 (class 0 OID 0)
-- Dependencies: 253
-- Name: monsters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.monsters_id_seq OWNED BY public.monsters.id;


--
-- TOC entry 254 (class 1259 OID 35973)
-- Name: npcs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.npcs (
    id integer NOT NULL,
    name text,
    role text,
    description text,
    source_id integer
);


ALTER TABLE public.npcs OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 35978)
-- Name: npcs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.npcs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.npcs_id_seq OWNER TO postgres;

--
-- TOC entry 4123 (class 0 OID 0)
-- Dependencies: 255
-- Name: npcs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npcs_id_seq OWNED BY public.npcs.id;


--
-- TOC entry 256 (class 1259 OID 35979)
-- Name: race_features; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.race_features (
    id integer NOT NULL,
    race_id integer,
    name text,
    description text
);


ALTER TABLE public.race_features OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 35984)
-- Name: race_features_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.race_features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.race_features_id_seq OWNER TO postgres;

--
-- TOC entry 4125 (class 0 OID 0)
-- Dependencies: 257
-- Name: race_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.race_features_id_seq OWNED BY public.race_features.id;


--
-- TOC entry 258 (class 1259 OID 35985)
-- Name: races; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.races (
    id integer NOT NULL,
    name text NOT NULL,
    size text NOT NULL,
    speed integer NOT NULL,
    type text NOT NULL,
    source_id integer NOT NULL,
    last_updated timestamp with time zone DEFAULT now(),
    personality text,
    physical_description text,
    relations text,
    alignment text,
    lands text,
    religion text,
    language text,
    names text,
    adventurers text
);


ALTER TABLE public.races OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 35990)
-- Name: races_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.races_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.races_id_seq OWNER TO postgres;

--
-- TOC entry 4127 (class 0 OID 0)
-- Dependencies: 259
-- Name: races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.races_id_seq OWNED BY public.races.id;


--
-- TOC entry 260 (class 1259 OID 35991)
-- Name: rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rules (
    id integer NOT NULL,
    category text NOT NULL,
    subcategory text,
    name text NOT NULL,
    description text NOT NULL,
    source_id integer,
    search_vector tsvector,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.rules OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 35996)
-- Name: rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rules_id_seq OWNER TO postgres;

--
-- TOC entry 4129 (class 0 OID 0)
-- Dependencies: 261
-- Name: rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rules_id_seq OWNED BY public.rules.id;


--
-- TOC entry 262 (class 1259 OID 35997)
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    id integer NOT NULL,
    name text NOT NULL,
    key_attribute public.dnd_attributes NOT NULL,
    trained_only boolean DEFAULT false NOT NULL,
    armor_check_penalty boolean DEFAULT false NOT NULL,
    description text,
    source_id integer,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 36004)
-- Name: skills_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.skills_id_seq OWNER TO postgres;

--
-- TOC entry 4131 (class 0 OID 0)
-- Dependencies: 263
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.skills_id_seq OWNED BY public.skills.id;


--
-- TOC entry 264 (class 1259 OID 36005)
-- Name: source_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.source_entries (
    id integer NOT NULL,
    page integer,
    errata text,
    book_id integer NOT NULL,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.source_entries OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 36010)
-- Name: source_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.source_tables (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    table_data jsonb NOT NULL
);


ALTER TABLE public.source_tables OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 36015)
-- Name: source_tables_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.source_tables_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.source_tables_id_seq OWNER TO postgres;

--
-- TOC entry 4134 (class 0 OID 0)
-- Dependencies: 266
-- Name: source_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.source_tables_id_seq OWNED BY public.source_tables.id;


--
-- TOC entry 267 (class 1259 OID 36016)
-- Name: sources; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sources (
    id integer NOT NULL,
    name text NOT NULL,
    abbreviation text NOT NULL,
    published_year integer,
    is_core boolean NOT NULL,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.sources OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 36021)
-- Name: sources_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sources_id_seq OWNER TO postgres;

--
-- TOC entry 4136 (class 0 OID 0)
-- Dependencies: 268
-- Name: sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sources_id_seq OWNED BY public.source_entries.id;


--
-- TOC entry 269 (class 1259 OID 36022)
-- Name: sources_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sources_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sources_id_seq1 OWNER TO postgres;

--
-- TOC entry 4137 (class 0 OID 0)
-- Dependencies: 269
-- Name: sources_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sources_id_seq1 OWNED BY public.sources.id;


--
-- TOC entry 270 (class 1259 OID 36023)
-- Name: spell_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spell_levels (
    spell_id integer NOT NULL,
    level integer,
    class_id integer NOT NULL
);


ALTER TABLE public.spell_levels OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 36026)
-- Name: spells; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spells (
    id integer NOT NULL,
    name text NOT NULL,
    school text NOT NULL,
    subschool text,
    descriptors text[],
    casting_time text,
    spell_range text,
    target text,
    duration text,
    saving_throw text,
    spell_resistance boolean DEFAULT false NOT NULL,
    description text NOT NULL,
    source_id integer NOT NULL,
    has_verbal_component boolean DEFAULT false NOT NULL,
    has_somatic_component boolean DEFAULT false NOT NULL,
    has_material_component boolean DEFAULT false NOT NULL,
    has_focus_component boolean DEFAULT false NOT NULL,
    has_xp_component boolean DEFAULT false NOT NULL,
    has_divine_focus_component boolean DEFAULT false NOT NULL,
    has_expensive_component boolean DEFAULT false NOT NULL,
    material_focus_description text,
    gp_cost integer DEFAULT 0 NOT NULL,
    xp_cost integer DEFAULT 0 NOT NULL,
    search_vector tsvector,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.spells OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 36041)
-- Name: spells_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.spells_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.spells_id_seq OWNER TO postgres;

--
-- TOC entry 4140 (class 0 OID 0)
-- Dependencies: 272
-- Name: spells_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spells_id_seq OWNED BY public.spells.id;


--
-- TOC entry 273 (class 1259 OID 36042)
-- Name: spells_known_progression; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spells_known_progression (
    id integer NOT NULL,
    class_id integer NOT NULL,
    level integer NOT NULL,
    cantrips integer,
    first_grade integer,
    second_grade integer,
    third_grade integer,
    fourth_grade integer,
    fifth_grade integer,
    sixth_grade integer,
    seventh_grade integer,
    eighth_grade integer,
    ninth_grade integer,
    CONSTRAINT spells_known_progression_level_check CHECK (((level >= 1) AND (level <= 20)))
);


ALTER TABLE public.spells_known_progression OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 36046)
-- Name: spells_known_progression_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.spells_known_progression_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.spells_known_progression_id_seq OWNER TO postgres;

--
-- TOC entry 4142 (class 0 OID 0)
-- Dependencies: 274
-- Name: spells_known_progression_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spells_known_progression_id_seq OWNED BY public.spells_known_progression.id;


--
-- TOC entry 280 (class 1259 OID 36429)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password_hash text NOT NULL,
    email text,
    created_at timestamp with time zone DEFAULT now(),
    last_login timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 36428)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4144 (class 0 OID 0)
-- Dependencies: 279
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 308 (class 1259 OID 36833)
-- Name: view_character_feats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_character_feats AS
 SELECT cf.id,
    cf.character_id,
    cf.note,
    f.name AS feat_name,
    f.feat_type,
    f.benefit
   FROM (public.character_feats cf
     JOIN public.feats f ON ((cf.feat_id = f.id)));


ALTER VIEW public.view_character_feats OWNER TO postgres;

--
-- TOC entry 305 (class 1259 OID 36819)
-- Name: view_character_inventory; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_character_inventory AS
 SELECT ci.id,
    ci.character_id,
    ci.is_equipped,
    ci.quantity,
    ci.custom_name,
    ci.notes,
    ci.is_masterwork,
    ci.enhancement_bonus,
    ci.enchantment_ids,
    i.name AS base_item_name,
    i.weight,
    i.price,
    i.image_url,
    it.name AS item_type,
    bs.name AS body_slot
   FROM (((public.character_inventory ci
     JOIN public.items i ON ((ci.item_id = i.id)))
     JOIN public.item_types it ON ((i.item_type_id = it.id)))
     LEFT JOIN public.body_slots bs ON ((i.body_slot_id = bs.id)));


ALTER VIEW public.view_character_inventory OWNER TO postgres;

--
-- TOC entry 307 (class 1259 OID 36829)
-- Name: view_character_skills; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_character_skills AS
 SELECT cs.id,
    cs.character_id,
    cs.ranks,
    cs.sub_skill,
    s.name AS skill_name,
    s.key_attribute,
    s.trained_only,
    s.armor_check_penalty
   FROM (public.character_skills cs
     JOIN public.skills s ON ((cs.skill_id = s.id)));


ALTER VIEW public.view_character_skills OWNER TO postgres;

--
-- TOC entry 306 (class 1259 OID 36824)
-- Name: view_character_spells; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_character_spells AS
 SELECT cs.id,
    cs.character_id,
    cs.is_prepared,
    cs.prepared_count,
    cs.is_known,
    cs.notes,
    s.name AS spell_name,
    s.school,
    s.subschool,
    s.description
   FROM (public.character_spells cs
     JOIN public.spells s ON ((cs.spell_id = s.id)));


ALTER VIEW public.view_character_spells OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 36047)
-- Name: view_feat_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_feat_details AS
 SELECT f.id,
    f.name,
    f.feat_type,
    f.benefit,
    f.normal,
    f.special,
    f.description,
    src.name AS book_name,
    src.abbreviation AS book_abbr,
    se.page,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('attribute', a.attribute, 'value', a.value)) AS jsonb_agg
           FROM public.feat_prereq_attribute a
          WHERE (a.feat_id = f.id)), '[]'::jsonb) AS prereq_attributes,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('id', p.prereq_feat_id, 'name', pf.name)) AS jsonb_agg
           FROM (public.feat_prereq_feat p
             JOIN public.feats pf ON ((p.prereq_feat_id = pf.id)))
          WHERE (p.feat_id = f.id)), '[]'::jsonb) AS prereq_feats,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('skill', s.skill_name, 'ranks', s.ranks)) AS jsonb_agg
           FROM public.feat_prereq_skill s
          WHERE (s.feat_id = f.id)), '[]'::jsonb) AS prereq_skills
   FROM ((public.feats f
     LEFT JOIN public.source_entries se ON ((f.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_feat_details OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 36579)
-- Name: weapon_properties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weapon_properties (
    id integer NOT NULL,
    damage_id integer NOT NULL,
    critical_id integer NOT NULL,
    range smallint,
    handedness public.weapon_handedness_enum NOT NULL,
    weapon_type public.weapon_type_enum NOT NULL,
    weapon_category public.weapon_category_enum NOT NULL
);


ALTER TABLE public.weapon_properties OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 36814)
-- Name: view_item_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_item_details AS
 SELECT i.id,
    i.name,
    it.name AS item_type,
    bs.name AS body_slot,
    i.description,
    i.price,
    i.weight,
    i.image_url,
    i.base_item_id,
    src.name AS book_name,
    se.page,
    i.enhancement_bonus,
    i.enchantment_ids,
    wp.damage_id,
    wp.critical_id,
    wp.range,
    wp.handedness,
    wp.weapon_type,
    wp.weapon_category,
    ap.ac_bonus,
    ap.max_dex_bonus,
    ap.armor_check_penalty,
    ap.speed_thirty,
    ap.speed_twenty,
    ap.armor_category,
    ap.arcane_spell_failure
   FROM ((((((public.items i
     JOIN public.item_types it ON ((i.item_type_id = it.id)))
     LEFT JOIN public.body_slots bs ON ((i.body_slot_id = bs.id)))
     LEFT JOIN public.source_entries se ON ((i.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)))
     LEFT JOIN public.weapon_properties wp ON (((i.properties_id = wp.id) AND (it.name = 'weapon'::text))))
     LEFT JOIN public.armor_properties ap ON (((i.properties_id = ap.id) AND (it.name = 'armor'::text))));


ALTER VIEW public.view_item_details OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 36057)
-- Name: view_monster_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_monster_details AS
 SELECT m.id,
    m.name,
    m.cr_text,
    m.cr_number,
    m.type,
    m.alignment,
    m.hit_dice,
    src.name AS book_name,
    se.page
   FROM ((public.monsters m
     LEFT JOIN public.source_entries se ON ((m.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_monster_details OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 36062)
-- Name: view_spell_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_spell_details AS
 SELECT s.id,
    s.name,
    s.school,
    s.subschool,
    s.descriptors,
    s.casting_time,
    s.spell_range,
    s.target,
    s.duration,
    s.saving_throw,
    s.spell_resistance,
    s.description,
    s.source_id,
    s.has_verbal_component,
    s.has_somatic_component,
    s.has_material_component,
    s.has_focus_component,
    s.has_xp_component,
    s.has_divine_focus_component,
    s.has_expensive_component,
    s.material_focus_description,
    s.gp_cost,
    s.xp_cost,
    s.search_vector,
    se.page,
    src.name AS book_name,
    src.abbreviation AS book_abbr
   FROM ((public.spells s
     JOIN public.source_entries se ON ((s.source_id = se.id)))
     JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_spell_details OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 36067)
-- Name: weapon_damage_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weapon_damage_type (
    weapon_properties_id integer NOT NULL,
    damage_type_id integer NOT NULL
);


ALTER TABLE public.weapon_damage_type OWNER TO postgres;

--
-- TOC entry 292 (class 1259 OID 36578)
-- Name: weapon_properties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.weapon_properties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weapon_properties_id_seq OWNER TO postgres;

--
-- TOC entry 4150 (class 0 OID 0)
-- Dependencies: 292
-- Name: weapon_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.weapon_properties_id_seq OWNED BY public.weapon_properties.id;


--
-- TOC entry 3580 (class 2604 OID 36599)
-- Name: armor_properties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.armor_properties ALTER COLUMN id SET DEFAULT nextval('public.armor_properties_id_seq'::regclass);


--
-- TOC entry 3585 (class 2604 OID 36801)
-- Name: body_slots id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_slots ALTER COLUMN id SET DEFAULT nextval('public.body_slots_id_seq'::regclass);


--
-- TOC entry 3582 (class 2604 OID 36711)
-- Name: bonus_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus_types ALTER COLUMN id SET DEFAULT nextval('public.bonus_types_id_seq'::regclass);


--
-- TOC entry 3501 (class 2604 OID 36077)
-- Name: caster_progression id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caster_progression ALTER COLUMN id SET DEFAULT nextval('public.caster_progression_id_seq'::regclass);


--
-- TOC entry 3564 (class 2604 OID 36725)
-- Name: character_feats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_feats ALTER COLUMN id SET DEFAULT nextval('public.character_feats_id_seq'::regclass);


--
-- TOC entry 3571 (class 2604 OID 36540)
-- Name: character_inventory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_inventory ALTER COLUMN id SET DEFAULT nextval('public.character_inventory_id_seq'::regclass);


--
-- TOC entry 3566 (class 2604 OID 36736)
-- Name: character_skills id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_skills ALTER COLUMN id SET DEFAULT nextval('public.character_skills_id_seq'::regclass);


--
-- TOC entry 3583 (class 2604 OID 36785)
-- Name: character_spell_slots id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_spell_slots ALTER COLUMN id SET DEFAULT nextval('public.character_spell_slots_id_seq'::regclass);


--
-- TOC entry 3567 (class 2604 OID 36521)
-- Name: character_spells id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_spells ALTER COLUMN id SET DEFAULT nextval('public.character_spells_id_seq'::regclass);


--
-- TOC entry 3555 (class 2604 OID 36446)
-- Name: characters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters ALTER COLUMN id SET DEFAULT nextval('public.characters_id_seq'::regclass);


--
-- TOC entry 3502 (class 2604 OID 36078)
-- Name: class_description_sections id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_description_sections ALTER COLUMN id SET DEFAULT nextval('public.class_description_sections_id_seq'::regclass);


--
-- TOC entry 3503 (class 2604 OID 36079)
-- Name: class_features id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_features ALTER COLUMN id SET DEFAULT nextval('public.class_features_id_seq'::regclass);


--
-- TOC entry 3504 (class 2604 OID 36080)
-- Name: class_progression id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_progression ALTER COLUMN id SET DEFAULT nextval('public.class_progression_id_seq'::regclass);


--
-- TOC entry 3505 (class 2604 OID 36081)
-- Name: classes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes ALTER COLUMN id SET DEFAULT nextval('public.classes_id_seq'::regclass);


--
-- TOC entry 3509 (class 2604 OID 36082)
-- Name: conditions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions ALTER COLUMN id SET DEFAULT nextval('public.conditions_id_seq'::regclass);


--
-- TOC entry 3511 (class 2604 OID 36084)
-- Name: damage_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.damage_types ALTER COLUMN id SET DEFAULT nextval('public.damage_type_id_seq'::regclass);


--
-- TOC entry 3512 (class 2604 OID 36085)
-- Name: domains id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domains ALTER COLUMN id SET DEFAULT nextval('public.domains_id_seq'::regclass);


--
-- TOC entry 3513 (class 2604 OID 36086)
-- Name: enchantments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantments ALTER COLUMN id SET DEFAULT nextval('public.enchantments_id_seq'::regclass);


--
-- TOC entry 3514 (class 2604 OID 36087)
-- Name: entity_tables id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tables ALTER COLUMN id SET DEFAULT nextval('public.entity_tables_id_seq'::regclass);


--
-- TOC entry 3515 (class 2604 OID 36088)
-- Name: entity_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types ALTER COLUMN id SET DEFAULT nextval('public.entity_types_id_seq'::regclass);


--
-- TOC entry 3517 (class 2604 OID 36089)
-- Name: feat_prereq_attribute id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_attribute ALTER COLUMN id SET DEFAULT nextval('public.feat_prereq_attribute_id_seq'::regclass);


--
-- TOC entry 3518 (class 2604 OID 36090)
-- Name: feat_prereq_feat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_feat ALTER COLUMN id SET DEFAULT nextval('public.feat_prereq_feat_id_seq'::regclass);


--
-- TOC entry 3519 (class 2604 OID 36091)
-- Name: feat_prereq_skill id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_skill ALTER COLUMN id SET DEFAULT nextval('public.feat_prereq_skill_id_seq'::regclass);


--
-- TOC entry 3520 (class 2604 OID 36092)
-- Name: feats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feats ALTER COLUMN id SET DEFAULT nextval('public.feats_id_seq'::regclass);


--
-- TOC entry 3522 (class 2604 OID 36093)
-- Name: item_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_types ALTER COLUMN id SET DEFAULT nextval('public.item_types_id_seq'::regclass);


--
-- TOC entry 3576 (class 2604 OID 36562)
-- Name: items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- TOC entry 3523 (class 2604 OID 36094)
-- Name: monsters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monsters ALTER COLUMN id SET DEFAULT nextval('public.monsters_id_seq'::regclass);


--
-- TOC entry 3525 (class 2604 OID 36096)
-- Name: npcs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npcs ALTER COLUMN id SET DEFAULT nextval('public.npcs_id_seq'::regclass);


--
-- TOC entry 3526 (class 2604 OID 36097)
-- Name: race_features id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.race_features ALTER COLUMN id SET DEFAULT nextval('public.race_features_id_seq'::regclass);


--
-- TOC entry 3527 (class 2604 OID 36098)
-- Name: races id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.races ALTER COLUMN id SET DEFAULT nextval('public.races_id_seq'::regclass);


--
-- TOC entry 3529 (class 2604 OID 36099)
-- Name: rules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rules ALTER COLUMN id SET DEFAULT nextval('public.rules_id_seq'::regclass);


--
-- TOC entry 3531 (class 2604 OID 36100)
-- Name: skills id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills ALTER COLUMN id SET DEFAULT nextval('public.skills_id_seq'::regclass);


--
-- TOC entry 3535 (class 2604 OID 36101)
-- Name: source_entries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_entries ALTER COLUMN id SET DEFAULT nextval('public.sources_id_seq'::regclass);


--
-- TOC entry 3537 (class 2604 OID 36102)
-- Name: source_tables id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_tables ALTER COLUMN id SET DEFAULT nextval('public.source_tables_id_seq'::regclass);


--
-- TOC entry 3538 (class 2604 OID 36103)
-- Name: sources id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sources ALTER COLUMN id SET DEFAULT nextval('public.sources_id_seq1'::regclass);


--
-- TOC entry 3540 (class 2604 OID 36104)
-- Name: spells id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells ALTER COLUMN id SET DEFAULT nextval('public.spells_id_seq'::regclass);


--
-- TOC entry 3552 (class 2604 OID 36105)
-- Name: spells_known_progression id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_known_progression ALTER COLUMN id SET DEFAULT nextval('public.spells_known_progression_id_seq'::regclass);


--
-- TOC entry 3553 (class 2604 OID 36432)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3579 (class 2604 OID 36582)
-- Name: weapon_properties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_properties ALTER COLUMN id SET DEFAULT nextval('public.weapon_properties_id_seq'::regclass);


--
-- TOC entry 4050 (class 0 OID 36596)
-- Dependencies: 295
-- Data for Name: armor_properties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.armor_properties (id, ac_bonus, max_dex_bonus, armor_check_penalty, speed_thirty, speed_twenty, armor_category, arcane_spell_failure) FROM stdin;
1	5	2	-5	20	15	Medium	30
2	2	6	0	30	20	Light	10
\.


--
-- TOC entry 4058 (class 0 OID 36798)
-- Dependencies: 303
-- Data for Name: body_slots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.body_slots (id, name, description) FROM stdin;
1	Head	Phylacteries, hats, headbands, helmets, and masks.
2	Eyes	Lenses, goggles, and spectacles.
3	Neck	Amulets, brooches, medallions, necklaces, periapt, and scarabs.
4	Shoulders	Capes, cloaks, and mantles.
5	Body	Armor and Robes. You cannot wear armor and a magical robe at the same time.
6	Torso	Shirts, vests, and vestments. Distinct from the Body slot; can be worn under armor.
7	Wrists	Bracers and bracelets.
8	Hands	Gauntlets and gloves.
9	Ring	Rings. A character can wear up to two rings.
10	Waist	Belts and girdles.
11	Feet	Boots and slippers.
12	Shield	Shields.
13	Held	Items held in hand.
14	None	Items that do not occupy a body slot.
\.


--
-- TOC entry 4052 (class 0 OID 36708)
-- Dependencies: 297
-- Data for Name: bonus_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bonus_types (id, name, description) FROM stdin;
1	enhancement	An enhancement bonus improves the quality of an item. Multiple enhancement bonuses on the same object do not stack.
2	deflection	A deflection bonus increases AC and stacks with all other bonuses to AC except other deflection bonuses.
3	natural armor	A natural armor bonus improves AC and stacks with all other bonuses to AC except other natural armor bonuses.
4	resistance	A resistance bonus applies to saving throws and stacks with all other bonuses except other resistance bonuses.
5	competence	A competence bonus affects skill checks and does not stack with other competence bonuses.
6	insight	An insight bonus affects some rolls and does not stack with other insight bonuses.
7	luck	A luck bonus affects a roll and does not stack with other luck bonuses.
8	morale	A morale bonus represents positive effects on a creature's state of mind. It does not stack with other morale bonuses.
9	sacred	A sacred bonus stems from holy power and does not stack with other sacred bonuses. It does not stack with profane bonuses.
10	profane	A profane bonus stems from unholy power and does not stack with other profane bonuses. It does not stack with sacred bonuses.
11	dodge	A dodge bonus represents physical skill at avoiding blows. Dodge bonuses stack with all other bonuses, including other dodge bonuses.
12	circumstance	A circumstance bonus arises from specific situations. Circumstance bonuses stack with all other bonuses, including other circumstance bonuses, unless they arise from the same or a similar circumstance.
13	alchemical	An alchemical bonus is granted by a nonmagical, alchemical substance. It does not stack with other alchemical bonuses.
14	size	A size bonus or penalty applies to certain rolls based on a creature's size. Size bonuses do not stack.
15	special ability	An enchantment that has a cost but does not provide a direct numerical bonus to a roll or stat (e.g., Flaming).
\.


--
-- TOC entry 3973 (class 0 OID 35847)
-- Dependencies: 215
-- Data for Name: caster_progression; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.caster_progression (id, class_id, level, cantrips, first_grade, second_grade, third_grade, fourth_grade, fifth_grade, sixth_grade, seventh_grade, eighth_grade, ninth_grade) FROM stdin;
3	2	1	3	1	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 4038 (class 0 OID 36469)
-- Dependencies: 283
-- Data for Name: character_classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_classes (character_id, class_id, class_level) FROM stdin;
3	1	1
4	2	1
\.


--
-- TOC entry 4039 (class 0 OID 36484)
-- Dependencies: 284
-- Data for Name: character_feats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_feats (character_id, feat_id, note, id) FROM stdin;
3	1	\N	1
4	2	Evocation	2
\.


--
-- TOC entry 4044 (class 0 OID 36537)
-- Dependencies: 289
-- Data for Name: character_inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_inventory (id, character_id, item_id, quantity, is_equipped, custom_name, enhancement_bonus, enchantment_ids, is_masterwork, notes) FROM stdin;
2	3	1	1	t	\N	0	\N	f	\N
3	3	3	1	t	\N	0	\N	f	\N
4	3	5	1	f	\N	0	\N	f	\N
5	4	2	1	t	\N	0	\N	f	\N
6	4	5	1	f	\N	0	\N	f	\N
7	4	6	5	f	\N	0	\N	f	\N
\.


--
-- TOC entry 4040 (class 0 OID 36501)
-- Dependencies: 285
-- Data for Name: character_skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_skills (character_id, skill_id, ranks, id, sub_skill) FROM stdin;
4	10	4.0	1	\N
4	9	4.0	2	\N
\.


--
-- TOC entry 4056 (class 0 OID 36782)
-- Dependencies: 301
-- Data for Name: character_spell_slots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_spell_slots (id, character_id, spell_level, slots_used) FROM stdin;
\.


--
-- TOC entry 4042 (class 0 OID 36518)
-- Dependencies: 287
-- Data for Name: character_spells; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_spells (id, character_id, spell_id, is_prepared, is_known, notes, prepared_count) FROM stdin;
1	4	5	t	t	\N	2
\.


--
-- TOC entry 4037 (class 0 OID 36443)
-- Dependencies: 282
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.characters (id, user_id, name, race_id, alignment, gender, age, height, weight, description, strength, dexterity, constitution, intelligence, wisdom, charisma, hit_points_max, hit_points_current, experience_points, money_gp) FROM stdin;
3	3	Valeros	17	Neutral Good	Male	25	6'0"	200 lbs	A brave fighter with a love for ale.	16	14	14	10	10	10	12	12	0	15
4	3	Ezren	17	Lawful Neutral	Male	45	5'10"	170 lbs	A scholar seeking knowledge.	10	12	14	16	12	10	6	6	0	25
\.


--
-- TOC entry 3975 (class 0 OID 35852)
-- Dependencies: 217
-- Data for Name: class_description_sections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.class_description_sections (id, class_id, section_name, content) FROM stdin;
\.


--
-- TOC entry 3977 (class 0 OID 35858)
-- Dependencies: 219
-- Data for Name: class_features; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.class_features (id, class_id, level, name, description) FROM stdin;
\.


--
-- TOC entry 3979 (class 0 OID 35864)
-- Dependencies: 221
-- Data for Name: class_progression; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.class_progression (id, class_id, level, bab, fort, ref, will) FROM stdin;
5	1	1	{1}	2	0	0
6	2	1	{0}	0	0	2
\.


--
-- TOC entry 3981 (class 0 OID 35871)
-- Dependencies: 223
-- Data for Name: class_skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.class_skills (class_id, skill_id) FROM stdin;
2	9
2	10
\.


--
-- TOC entry 3982 (class 0 OID 35874)
-- Dependencies: 224
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classes (id, name, is_prestige, skill_points, alignment, source_id, num_dice, dice_type, main_attr, last_updated) FROM stdin;
1	Fighter	f	2	Any	1	1	10	Strength	2026-01-06 15:45:22.279134+01
2	Wizard	f	2	Any	1	1	4	Intelligence	2026-01-06 15:45:22.279134+01
5	Cleric	f	2	Any	1	1	8	Wisdom	2026-01-07 00:07:12.660111+01
\.


--
-- TOC entry 3984 (class 0 OID 35882)
-- Dependencies: 226
-- Data for Name: conditions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conditions (id, name, description, source_id, search_vector, last_updated) FROM stdin;
1	Blinded	The creature cannot see. It takes a -2 penalty to Armor Class, loses its Dexterity bonus to AC (if any), and takes a -4 penalty on most Strength- and Dexterity-based skill checks and on opposed Perception checks.	1	'-2':9B '-4':25B 'ac':19B 'armor':12B 'base':33B 'blind':1A 'bonus':17B 'cannot':4B 'check':35B,40B 'class':13B 'creatur':3B 'dexter':16B,32B 'dexterity-bas':31B 'lose':14B 'oppos':38B 'penalti':10B,26B 'percept':39B 'see':5B 'skill':34B 'strength':29B 'take':7B,23B	2026-01-07 00:07:12.660111+01
2	Dazed	The creature is unable to act normally. A dazed creature can take no actions, but has no penalty to AC.	1	'ac':21B 'act':7B 'action':15B 'creatur':3B,11B 'daze':1A,10B 'normal':8B 'penalti':19B 'take':13B 'unabl':5B	2026-01-07 00:07:12.660111+01
\.


--
-- TOC entry 3986 (class 0 OID 35894)
-- Dependencies: 228
-- Data for Name: critical_combinations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.critical_combinations (id, crit_range, crit_damage) FROM stdin;
1	19	2
2	20	3
\.


--
-- TOC entry 3987 (class 0 OID 35897)
-- Dependencies: 229
-- Data for Name: damage_scaling; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.damage_scaling (id, base, lower_one, lower_two, lower_three, lower_four, higher_one, higher_two, higher_three, higher_four) FROM stdin;
1	1d2	1	\N	\N	\N	1d3	1d4	1d6	1d8
2	1d3	1d2	1	\N	\N	1d4	1d6	1d8	2d6
3	1d4	1d3	1d2	1	\N	1d6	1d8	2d6	3d6
4	1d6	1d4	1d3	1d2	1	1d8	2d6	3d6	4d6
5	1d8	1d6	1d4	1d3	1d2	2d6	3d6	4d6	6d6
6	1d10	1d8	1d6	1d4	1d3	2d8	3d8	4d8	6d8
7	1d12	1d10	1d8	1d6	1d4	3d6	4d6	6d6	8d6
8	2d4	1d6	1d4	1d3	1d2	2d6	3d6	4d6	6d6
9	2d6	1d10	1d8	1d6	1d4	3d6	4d6	6d6	8d6
10	2d8	2d6	1d10	1d8	1d6	3d8	4d8	6d8	8d8
11	2d10	2d8	2d6	1d10	1d8	4d8	6d8	8d8	12d8
\.


--
-- TOC entry 3988 (class 0 OID 35902)
-- Dependencies: 230
-- Data for Name: damage_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.damage_types (id, name, category) FROM stdin;
1	Bludgeoning	Physical
2	Piercing	Physical
3	Slashing	Physical
4	Acid	Elemental
5	Cold	Elemental
6	Electricity	Elemental
7	Fire	Elemental
8	Sonic	Elemental
9	Force	Energy
10	Positive Energy	Energy
11	Negative Energy	Energy
12	Poison	Special
13	Divine	Optional
14	Vile	Optional
15	Psychic	Optional
16	Necrotic	Optional
17	Radiant	Optional
18	Untyped	Conditional
19	Non-Lethal	Conditional
20	Falling	Conditional
\.


--
-- TOC entry 3990 (class 0 OID 35908)
-- Dependencies: 232
-- Data for Name: domain_spells; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.domain_spells (domain_id, spell_id, level) FROM stdin;
1	6	1
\.


--
-- TOC entry 3991 (class 0 OID 35911)
-- Dependencies: 233
-- Data for Name: domains; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.domains (id, name, granted_power, source_id) FROM stdin;
1	Healing	You cast healing spells at +1 caster level.	1
2	War	Free Martial Weapon Proficiency with deity’s favored weapon and Weapon Focus with that weapon.	1
\.


--
-- TOC entry 3993 (class 0 OID 35917)
-- Dependencies: 235
-- Data for Name: enchantment_applicable_to; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enchantment_applicable_to (enchantment_id, item_type_id) FROM stdin;
\.


--
-- TOC entry 3994 (class 0 OID 35920)
-- Dependencies: 236
-- Data for Name: enchantments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enchantments (id, name, bonus_value, description, source_id, bonus_type_id) FROM stdin;
1	Flaming	1	Upon command, a flaming weapon is sheathed in fire that deals an extra 1d6 points of fire damage on a successful hit.	1	15
2	Keen	1	This ability doubles the threat range of a weapon.	1	15
\.


--
-- TOC entry 3996 (class 0 OID 35926)
-- Dependencies: 238
-- Data for Name: entity_tables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_tables (id, source_table_id, entity_type_id, entity_id) FROM stdin;
\.


--
-- TOC entry 3998 (class 0 OID 35930)
-- Dependencies: 240
-- Data for Name: entity_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_types (id, table_name, display_name, for_players) FROM stdin;
\.


--
-- TOC entry 4000 (class 0 OID 35935)
-- Dependencies: 242
-- Data for Name: feat_prereq_attribute; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.feat_prereq_attribute (id, feat_id, attribute, value) FROM stdin;
3	1	Strength	13
\.


--
-- TOC entry 4002 (class 0 OID 35939)
-- Dependencies: 244
-- Data for Name: feat_prereq_feat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.feat_prereq_feat (id, feat_id, prereq_feat_id) FROM stdin;
\.


--
-- TOC entry 4004 (class 0 OID 35943)
-- Dependencies: 246
-- Data for Name: feat_prereq_skill; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.feat_prereq_skill (id, feat_id, skill_name, ranks) FROM stdin;
\.


--
-- TOC entry 4006 (class 0 OID 35949)
-- Dependencies: 248
-- Data for Name: feats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.feats (id, name, feat_type, benefit, normal, special, description, source_id, search_vector, last_updated) FROM stdin;
1	Power Attack	General	You can make exceptionally powerful melee attacks.	\N	If you attack with a two-handed weapon, or with a one-handed weapon wielded in two hands, instead add twice the number subtracted from your attack rolls. You can’t add the bonus from Power Attack to the damage dealt with a light weapon (except with unarmed strikes or natural weapon attacks), even though the penalty on attack rolls still applies. (Normally, you treat a double weapon as a one-handed weapon and a light weapon. If you choose to use a double weapon like a two-handed weapon, attacking with only one end of it in a round, you treat it as a two-handed weapon.) A fighter may select Power Attack as one of his fighter bonus feats.	On your action, before making attack rolls for a round, you may choose to subtract a number from all melee attack rolls and add the same number to all melee damage rolls. This number may not exceed your base attack bonus. The penalty on attacks and bonus on damage apply until your next turn.	1	'add':31C,43C 'appli':73C 'attack':2A,9B,12C,38C,48C,64C,70C,104C,128C 'bonus':45C,134C 'choos':92C 'damag':51C 'dealt':52C 'doubl':78C,96C 'end':108C 'even':65C 'except':6B,57C 'feat':135C 'fighter':124C,133C 'hand':17C,24C,29C,84C,102C,121C 'instead':30C 'light':55C,88C 'like':98C 'make':5B 'may':125C 'mele':8B 'natur':62C 'normal':74C 'number':34C 'one':23C,83C,107C,130C 'one-hand':22C,82C 'penalti':68C 'power':1A,7B,47C,127C 'roll':39C,71C 'round':113C 'select':126C 'still':72C 'strike':60C 'subtract':35C 'though':66C 'treat':76C,115C 'twice':32C 'two':16C,28C,101C,120C 'two-hand':15C,100C,119C 'unarm':59C 'use':94C 'weapon':18C,25C,56C,63C,79C,85C,89C,97C,103C,122C 'wield':26C	2026-01-06 15:45:53.624211+01
2	Spell Focus	General	Choose a school of magic, such as illusion. Your spells of that school are more potent than normal.	\N	You can gain this feat multiple times. Its effects do not stack. Each time you take the feat, it applies to a new school of magic.	Add +1 to the Difficulty Class for all saving throws against spells from the school of magic you select.	1	'appli':40C 'choos':3B 'effect':29C 'feat':25C,38C 'focus':2A 'gain':23C 'illus':10B 'magic':7B,46C 'multipl':26C 'new':43C 'normal':20B 'potent':18B 'school':5B,15B,44C 'spell':1A,12B 'stack':32C 'take':36C 'time':27C,34C	2026-01-06 15:45:53.624211+01
\.


--
-- TOC entry 4008 (class 0 OID 35955)
-- Dependencies: 250
-- Data for Name: item_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item_types (id, name) FROM stdin;
1	weapon
2	armor
3	consumable
4	wondrous
5	ring
6	rod
7	staff
8	wand
9	potion
10	scroll
11	gear
\.


--
-- TOC entry 4046 (class 0 OID 36559)
-- Dependencies: 291
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id, name, description, price, weight, source_id, image_url, base_item_id, properties_id, last_updated, search_vector, item_type_id, enhancement_bonus, enchantment_ids, body_slot_id) FROM stdin;
1	Longsword	A longsword is a martial weapon.	1500	4.00	1	\N	\N	1	2026-01-07 00:17:33.392261+01	'longsword':1A,3B 'martial':6B 'weapon':7B	1	0	\N	13
2	Shortbow	A shortbow is a martial ranged weapon.	3000	2.00	1	\N	\N	2	2026-01-07 00:17:33.392261+01	'martial':6B 'rang':7B 'shortbow':1A,3B 'weapon':8B	1	0	\N	13
3	Chainmail	Chainmail armor.	15000	40.00	1	\N	\N	1	2026-01-07 00:17:33.392261+01	'armor':3B 'chainmail':1A,2B	2	0	\N	5
4	Leather Armor	Leather armor.	1000	15.00	1	\N	\N	2	2026-01-07 00:17:33.392261+01	'armor':2A,4B 'leather':1A,3B	2	0	\N	5
5	Backpack	A leather pack carried on the back.	200	2.00	1	\N	\N	\N	2026-01-07 00:17:33.392261+01	'back':8B 'backpack':1A 'carri':5B 'leather':3B 'pack':4B	11	0	\N	14
6	Torch	A wooden stick wrapped in cloth and dipped in pitch.	1	1.00	1	\N	\N	\N	2026-01-07 00:17:33.392261+01	'cloth':7B 'dip':9B 'pitch':11B 'stick':4B 'torch':1A 'wooden':3B 'wrap':5B	11	0	\N	13
\.


--
-- TOC entry 4010 (class 0 OID 35961)
-- Dependencies: 252
-- Data for Name: monsters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.monsters (id, name, cr_text, type, alignment, hit_dice, description, source_id, num_dice, dice_type, bonus, cr_number, search_vector, last_updated) FROM stdin;
3	Goblin	1/3	Humanoid (Goblinoid)	Neutral Evil	1d8+1	\N	1	1	8	1	0.33	'goblin':1A	2026-01-07 00:07:12.660111+01
4	Skeleton, Human Warrior	1/3	Undead	Neutral Evil	1d12	\N	1	1	12	0	0.33	'human':2A 'skeleton':1A 'warrior':3A	2026-01-07 00:07:12.660111+01
\.


--
-- TOC entry 4012 (class 0 OID 35973)
-- Dependencies: 254
-- Data for Name: npcs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.npcs (id, name, role, description, source_id) FROM stdin;
\.


--
-- TOC entry 4014 (class 0 OID 35979)
-- Dependencies: 256
-- Data for Name: race_features; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.race_features (id, race_id, name, description) FROM stdin;
1	17	Size	Medium: As Medium creatures, humans have no special bonuses or penalties due to their size.
2	17	Speed	Human base land speed is 30 feet.
3	17	Bonus Feat	1 extra feat at 1st level, because humans are quick to master specialized tasks and varied in their talents.
4	17	Skills	4 extra skill points at 1st level and 1 extra skill point at each additional level, since humans are versatile and capable.
5	17	Languages	Automatic Language: Common. Bonus Languages: Any (other than secret languages, such as Druidic). Humans mingle with all kinds of other folk and thus can learn any language found in an area.
6	17	Favored Class	Any. When determining whether a multiclass human takes an experience point penalty, her highest-level class does not count.
7	18	Ability Adjustments	+2 Constitution, –2 Charisma: Dwarves are stout and tough but tend to be gruff and reserved.
8	18	Size	Medium: As Medium creatures, dwarves have no special bonuses or penalties due to their size.
9	18	Speed	Dwarf base land speed is 20 feet. However, dwarves can move at this speed even when wearing medium or heavy armor or whose speed is reduced in such conditions.
10	18	Darkvision	Dwarves can see in the dark up to 60 feet. Darkvision is black and white only, but it is otherwise like normal sight, and dwarves can function just fine with no light at all.
11	18	Stonecunning	This ability grants a dwarf a +2 racial bonus on Search checks to notice unusual stonework, such as sliding walls, stonework traps, new construction (even when built to match the old), unsafe stone surfaces, shaky stone ceilings, and the like. Something that isn’t stone but that is disguised as stone also counts as unusual stonework. A dwarf who merely comes within 10 feet of unusual stonework can make a Search check as if he were actively searching, and a dwarf can use the Search skill to find stonework traps as a rogue can. A dwarf can also intuit depth, sensing his approximate depth underground as naturally as a human can sense which way is up.
12	18	Weapon Familiarity	Dwarves may treat dwarven waraxes and dwarven urgroshes as martial weapons, rather than exotic weapons.
13	18	Stability	Dwarves are exceptionally stable on their feet. A dwarf gains a +4 bonus on ability checks made to resist being bull rushed or tripped when standing on the ground (but not when climbing, flying, riding, or otherwise not standing firmly on the ground).
14	18	Resistances	+2 racial bonus on saving throws against poison (Dwarves are hardy and resistant to toxins); +2 racial bonus on saving throws against spells and spell-like effects (dwarves have an innate resistance to magic spells).
15	18	Combat Bonuses	+1 racial bonus to attack rolls against orcs and goblinoids (Dwarves are trained in the special combat techniques that allow them to fight their common enemies more effectively); +4 dodge bonus to Armor Class against monsters of the giant type (This bonus represents special training that dwarves undergo, during which they learn tricks that previous generations developed in their battles with giants).
16	18	Skill Bonuses	+2 racial bonus on Appraise checks that are related to stone or metal items; +2 racial bonus on Craft checks that are related to stone or metal.
17	18	Languages	Automatic Languages: Common and Dwarven. Bonus Languages: Giant, Gnome, Goblin, Orc, Terran, and Undercommon. Dwarves are familiar with the languages of their enemies and of their subterranean allies.
18	18	Favored Class	Fighter. A multiclass dwarf’s fighter class does not count when determining whether he takes an experience point penalty for multiclassing.
19	19	Ability Adjustments	+2 Dexterity, –2 Constitution: Elves are graceful but frail. An elf’s grace makes her naturally better at stealth and archery.
20	19	Size	Medium: As Medium creatures, elves have no special bonuses or penalties due to their size.
21	19	Speed	Elf base land speed is 30 feet.
22	19	Immunities	Immunity to magic sleep effects, and a +2 racial saving throw bonus against enchantment spells or effects.
23	19	Low-light Vision	An elf can see twice as far as a human in starlight, moonlight, torchlight, and similar conditions of poor illumination. She retains the ability to distinguish color and detail under these conditions.
24	19	Weapon Proficiency	Elves receive the Martial Weapon Proficiency feats for the longsword, rapier, longbow (including composite longbow), and shortbow (including composite shortbow) as bonus feats. Elves esteem the arts of swordplay and archery, so all elves are familiar with these weapons.
25	19	Skill Bonuses	+2 racial bonus on Listen, Search, and Spot checks. An elf who merely passes within 5 feet of a secret or concealed door is entitled to a Search check to notice it as if she were actively looking for it.
26	19	Languages	Automatic Languages: Common and Elven. Bonus Languages: Draconic, Gnoll, Gnome, Goblin, Orc, and Sylvan.
27	19	Favored Class	Wizard. A multiclass elf’s wizard class does not count when determining whether she takes an experience point penalty for multiclassing.
28	20	Ability Adjustments	+2 Constitution, –2 Strength: Like dwarves, gnomes are tough, but they are small and therefore not as strong as larger humanoids.
29	20	Size	Small: As a Small creature, a gnome gains a +1 size bonus to Armor Class, a +1 size bonus on attack rolls, and a +4 size bonus on Hide checks, but he uses smaller weapons than humans use, and his lifting and carrying limits are three-quarters of those of a Medium character.
30	20	Speed	Gnome base land speed is 20 feet.
31	20	Low-light Vision	A gnome can see twice as far as a human in starlight, moonlight, torchlight, and similar conditions of poor illumination. He retains the ability to distinguish color and detail under these conditions.
32	20	Weapon Familiarity	Gnomes may treat gnome hooked hammers as martial weapons rather than exotic weapons.
33	20	Illusion Resistance	+2 racial bonus on saving throws against illusions: Gnomes are innately familiar with illusions of all kinds.
34	20	Illusion Affinity	Add +1 to the Difficulty Class for all saving throws against illusion spells cast by gnomes. Their innate familiarity with these effects make their illusions more difficult to see through. This adjustment stacks with those from similar effects, such as the Spell Focus feat.
35	20	Combat Bonuses	+1 racial bonus on attack rolls against kobolds and goblinoids (including goblins, hobgoblins, and bugbears): Gnomes battle these creatures frequently and practice special techniques for fighting them. +4 dodge bonus to Armor Class against monsters of the giant type (such as ogres, trolls, and hill giants).
36	20	Skill Bonuses	+2 racial bonus on Listen checks; +2 racial bonus on Craft (alchemy) checks.
37	20	Languages	Automatic Languages: Common and Gnome. Bonus Languages: Draconic, Dwarven, Elven, Giant, Goblin, and Orc. In addition, a gnome can use speak with a burrowing mammal (a badger, fox, rabbit, or the like, see below). This ability is innate to gnomes.
38	20	Spell-Like Abilities	1/day—speak with animals (burrowing mammal only, duration 1 minute). A gnome with a Charisma score of at least 10 also has the following spell-like abilities: 1/day—dancing lights, ghost sound, prestidigitation. Caster level 1st; save DC 10 + gnome’s Cha modifier + spell level.
39	20	Favored Class	Bard. A multiclass gnome’s bard class does not count when determining whether he takes an experience point penalty.
40	21	Size	Medium: As Medium creatures, half-elves have no special bonuses or penalties due to their size.
41	21	Speed	Half-elf base land speed is 30 feet.
42	21	Immunities	Immunity to sleep spells and similar magical effects, and a +2 racial bonus on saving throw against enchantment spells or effects.
43	21	Low-light Vision	A half-elf can see twice as far as a human in starlight, moonlight, torchlight, and similar conditions of poor illumination. She retains the ability to distinguish color and detail under these conditions.
44	21	Skill Bonuses	+1 racial bonus on Listen, Search, and Spot checks: A half-elf does not have the elf’s ability to notice secret doors simply by passing near them. Half-elves have keen senses, but not as keen as those of an elf. +2 racial bonus on Diplomacy and Gather Information checks: Half-elves get along naturally with all people.
45	21	Elven Blood	For all effects related to race, a half-elf is considered an elf. Half-elves, for example, are just as vulnerable to special effects that affect elves as their elf ancestors are, and they can use magic items that are only usable by elves.
46	21	Languages	Automatic Languages: Common and Elven. Bonus Languages: Any (other than secret languages, such as Druidic).
47	21	Favored Class	Any. When determining whether a multiclass half-elf takes an experience point penalty, her highest-level class does not count.
48	22	Ability Adjustments	+2 Strength, –2 Intelligence, –2 Charisma: Half-orcs are strong, but their orc lineage makes them dull and crude.
49	22	Size	Medium: As Medium creatures, half-orcs have no special bonuses or penalties due to their size.
50	22	Speed	Half-orc base land speed is 30 feet.
51	22	Darkvision	Half-orcs (and orcs) can see in the dark up to 60 feet. Darkvision is black and white only, but it is otherwise like normal sight, and half-orcs can function just fine with no light at all.
52	22	Orc Blood	For all effects related to race, a half-orc is considered an orc. Half-orcs, for example, are just as vulnerable to special effects that affect orcs as their orc ancestors are, and they can use magic items that are only usable by orcs.
53	22	Languages	Automatic Languages: Common and Orc. Bonus Languages: Draconic, Giant, Gnoll, Goblin, and Abyssal.
54	22	Favored Class	Barbarian. A multiclass half-orc’s barbarian class does not count when determining whether he takes an experience point penalty.
55	23	Ability Adjustments	+2 Dexterity, –2 Strength: Halflings are quick, agile, and good with ranged weapons, but they are small and therefore not as strong as other humanoids.
56	23	Size	Small: As a Small creature, a halfling gains a +1 size bonus to Armor Class, a +1 size bonus on attack rolls, and a +4 size bonus on Hide checks, but she uses smaller weapons than humans use, and her lifting and carrying limits are three-quarters of those of a Medium character.
57	23	Speed	Halfling base land speed is 20 feet.
58	23	Skill Bonuses	+2 racial bonus on Climb, Jump, and Move Silently checks; +2 racial bonus on Listen checks.
59	23	Save Bonuses	+1 racial bonus on all saving throws; +2 morale bonus on saving throws against fear.
60	23	Combat Bonuses	+1 racial bonus on attack rolls with a thrown weapon and slings.
61	23	Languages	Automatic Languages: Common and Halfling. Bonus Languages: Dwarven, Elven, Gnome, Goblin, and Orc.
62	23	Favored Class	Rogue. A multiclass halfling’s rogue class does not count when determining whether she take an experience point penalty for multiclassing.
\.


--
-- TOC entry 4016 (class 0 OID 35985)
-- Dependencies: 258
-- Data for Name: races; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.races (id, name, size, speed, type, source_id, last_updated, personality, physical_description, relations, alignment, lands, religion, language, names, adventurers) FROM stdin;
24	Aasimar	Medium	30	Outsider	8	2026-01-06 14:27:27.440514+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
25	Tiefling	Medium	30	Outsider	8	2026-01-06 14:27:27.440514+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
26	Drow	Medium	30	Humanoid	8	2026-01-06 14:27:27.440514+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
27	Orc	Medium	30	Humanoid	9	2026-01-06 14:27:27.440514+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
28	Bugbear	Medium	30	Humanoid	10	2026-01-06 14:27:59.344224+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
29	Gnoll	Medium	30	Humanoid	11	2026-01-06 14:27:59.344224+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
30	Hobgoblin	Medium	30	Humanoid	12	2026-01-06 14:27:59.344224+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
31	Kobold	Small	30	Humanoid	13	2026-01-06 14:27:59.344224+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
32	Lizardfolk	Medium	30	Humanoid	14	2026-01-06 14:27:59.344224+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
33	Troglodyte	Medium	30	Humanoid	16	2026-01-06 14:27:59.344224+01	\N	\N	\N	\N	\N	\N	\N	\N	\N
17	Human	Medium	30	Humanoid	1	2026-01-06 15:02:21.950156+01	Humans are the most adaptable, flexible, and ambitious people among the common races. They are diverse in their tastes, morals, customs, and habits. Others accuse them of having little respect for history, but it’s only natural that humans, with their relatively short life spans and constantly changing cultures, would have a shorter collective memory than dwarves, elves, gnomes, or halflings.	Humans typically stand from 5 feet to a little over 6 feet tall and weigh from 125 to 250 pounds, with men noticeably taller and heavier than women. Thanks to their penchant for migration and conquest, and to their short life spans, humans are more physically diverse than other common races. Their skin shades range from nearly black to very pale, their hair from black to blond (curly, kinky, or straight), and their facial hair (for men) from sparse to thick. Plenty of humans have a dash of nonhuman blood, and they may demonstrate hints of elf, orc, or other lineages. Members of this race are often ostentatious or unorthodox in their grooming and dress, sporting unusual hairstyles, fanciful clothes, tattoos, body piercings, and the like. Humans have short life spans, reaching adulthood at about age 15 and rarely living even a single century.	Just as readily as they mix with each other, humans mix with members of other races, among which they are known as “everyone’s second-best friends.” Humans serve as ambassadors, diplomats, magistrates, merchants, and functionaries of all kinds.	Humans tend toward no particular alignment, not even neutrality. The best and the worst are found among them.	Human lands are usually in flux, with new ideas, social changes, innovations, and new leaders constantly coming to the fore. Members of longer-lived races find human culture exciting but eventually a little wearying or even bewildering. Since humans lead such short lives, their leaders are all young compared to the political, religious, and military leaders among the other races. Even where individual humans are conservative traditionalists, human institutions change with the generations, adapting and evolving faster than parallel institutions among the elves, dwarves, gnomes, and halflings. Individually and as a group, humans are adaptable opportunists, and they stay on top of changing political dynamics. Human lands generally include relatively large numbers of nonhumans (compared, for instance, to the number of non-dwarves who live in dwarven lands).	Unlike members of the other common races, humans do not have a chief racial deity. Pelor, the sun god, is the most commonly worshiped deity in human lands, but he can claim nothing like the central place that the dwarves give Moradin or the elves give Corellon Larethian in their respective pantheons. Some humans are the most ardent and zealous adherents of a given religion, while others are the most impious people around.	Humans speak Common. They typically learn other languages as well, including obscure ones, and they are fond of sprinkling their speech with words borrowed from other tongues: Orc curses, Elven musical expressions, Dwarven military phrases, and so on.	Human names vary greatly. Without a unifying deity to give them a touchstone for their culture, and with such a fast breeding cycle, humans mutate socially at a fast rate. Human culture, therefore, is more diverse than other cultures, and no human names are truly typical. Some human parents give their children dwarven or elven names (pronounced more or less correctly).	Human adventurers are the most audacious, daring, and ambitious members of an audacious, daring, and ambitious race. A human can earn glory in the eyes of her fellows by amassing power, wealth, and fame. Humans, more than other people, champion causes rather than territories or groups.
18	Dwarf	Medium	20	Humanoid	2	2026-01-06 15:02:21.950156+01	Dwarves are slow to laugh or jest and suspicious of strangers, but they are generous to those few who earn their trust. Dwarves value gold, gems, jewelry, and art objects made with these precious materials, and they have been known to succumb to greed. They fight neither recklessly nor timidly, but with a careful courage and tenacity. Their sense of justice is strong, but at its worst it can turn into a thirst for vengeance. Among gnomes, who get along famously with dwarves, a mild oath is “If I’m lying, may I cross a dwarf.”	Dwarves stand only 4 to 4-1/2 feet tall, but they are so broad and compact that they are, on average, almost as heavy as humans. Dwarf men are slightly taller and noticeably heavier than dwarf women. Dwarves’ skin is typically deep tan or light brown, and their eyes are dark. Their hair is usually black, gray, or brown, and worn long. Dwarf men value their beards highly and groom them very carefully. Dwarves favor simple styles for their hair, beards, and clothes. Dwarves are considered adults at about age 40, and they can live to be more than 400 years old.	Dwarves get along fine with gnomes, and passably with humans, half-elves, and halflings. Dwarves say, “The difference between an acquaintance and a friend is about a hundred years.” Humans, with their short life spans, have a hard time forging truly strong bonds with dwarves. The best dwarf-human friendships are between a human and a dwarf who liked the human’s parents and grandparents. Dwarves fail to appreciate elves’ subtlety and art, regarding elves as unpredictable, fickle, and flighty. Still, elves and dwarves have, through the ages, found common cause in battles against orcs, goblins, and gnolls. Through many such joint campaigns, the elves have earned the dwarves’ grudging respect. Dwarves mistrust half-orcs in general, and the feeling is mutual. Luckily, dwarves are fair-minded, and they grant individual half-orcs the opportunity to prove themselves.	Dwarves are usually lawful, and they tend toward good. Adventuring dwarves are less likely to fit the common mold, however, since they’re more likely to be those who did not fit perfectly into dwarven society.	Dwarven kingdoms usually lie deep beneath the stony faces of mountains, where the dwarves mine gems and precious metals and forge items of wonder. Trustworthy members of other races are welcome in such settlements, though some parts of these lands are off limits even to them. Whatever wealth the dwarves can’t find in their mountains, they gain through trade. Dwarves dislike water travel, so enterprising humans frequently handle trade in dwarven goods when travel is along a water route. Dwarves in human lands are typically mercenaries, weaponsmiths, armorsmiths, jewelers, and artisans. Dwarf bodyguards are renowned for their courage and loyalty, and they are well rewarded for their virtues.	The chief deity of the dwarves is Moradin, the Soul Forger. He is the creator of the dwarves, and he expects his followers to work for the betterment of the dwarf race.	Dwarves speak Dwarven, which has its own runic script. Dwarven literature is marked by comprehensive histories of kingdoms and wars through the millennia. The Dwarven alphabet is also used (with minor variations) for the Gnome, Giant, Goblin, Orc, and Terran languages. Dwarves often speak the languages of their friends (humans and gnomes) and enemies. Some also learn Terran, the strange language of earth-based creatures such as xorn.	A dwarf’s name is granted to him by his clan elder, in accordance with tradition. Every proper dwarven name has been used and reused down through the generations. A dwarf’s name is not his own. It belongs to his clan. If he misuses it or brings shame to it, his clan will strip him of it. A dwarf stripped of his name is forbidden by dwarven law to use any dwarven name in its place.	A dwarven adventurer may be motivated by crusading zeal, a love of excitement, or simple greed. As long as his accomplishments bring honor to his clan, his deeds earn him respect and status. Defeating giants and claiming powerful magic weapons are sure ways for a dwarf to earn the respect of other dwarves.
19	Elf	Medium	30	Humanoid	3	2026-01-06 15:02:21.950156+01	Elves are more often amused than excited, and more likely to be curious than greedy. With such a long life span, they tend to keep a broad perspective on events, remaining aloof and unfazed by petty happenstance. When pursuing a goal, however, whether an adventurous mission or learning a new skill or art, they can be focused and relentless. They are slow to make friends and enemies, and even slower to forget them. They reply to petty insults with disdain and to serious insults with vengeance.	Elves are short and slim, standing about 4-1/2 to 5-1/2 feet tall and typically weighing 95 to 135 pounds, with elf men the same height as and only marginally heavier than elf women. They are graceful but frail. They tend to be pale-skinned and dark-haired, with deep green eyes. Elves have no facial or body hair. They prefer simple, comfortable clothes, especially in pastel blues and greens, and they enjoy simple yet elegant jewelry. Elves possess unearthly grace and fine features. Many humans and members of other races find them hauntingly beautiful. An elf reaches adulthood at about 110 years of age and can live to be more than 700 years old. Elves do not sleep, as members of the other common races do. Instead, an elf meditates in a deep trance for 4 hours a day. An elf resting in this fashion gains the same benefit that a human does from 8 hours of sleep. While meditating, an elf dreams, though these dreams are actually mental exercises that have become reflexive through years of practice.	Elves consider humans rather unrefined, halflings a bit staid, gnomes somewhat trivial, and dwarves not at all fun. They look on half-elves with some degree of pity, and they regard half-orcs with unrelenting suspicion. While haughty, elves are not particular the way halflings and dwarves can be, and they are generally pleasant and gracious even to those who fall short of elven standards (a category that encompasses just about everybody who’s not an elf).	Elves love freedom, variety, and self-expression, leaning strongly toward the gentler aspects of chaos. Generally, they value and protect others’ freedom as well as their own, and they are more often good than not.	Most elves live in woodland clans numbering less than two hundred souls. Their well-hidden villages blend into the trees, doing little harm to the forest. They hunt game, gather food, and grow vegetables, and their skill and magic allowing them to support themselves amply without the need for clearing and plowing land. Their contact with outsiders is usually limited, though some few elves make a good living trading finely worked elven clothes and crafts for the metals that elves have no interest in mining. Elves encountered in human lands are commonly wandering minstrels, favored artists, or sages. Human nobles compete for the services of elf instructors, who teach swordplay to their children.	Above all others, elves worship Corellon Larethian, the Protector and Preserver of life. Elven myth holds that it was from his blood, shed in battles with Gruumsh, the god of the orcs, that the elves first arose. Corellon is a patron of magical study, arts, dance, and poetry, as well as a powerful warrior god.	Elves speak a fluid language of subtle intonations and intricate grammar. While Elven literature is rich and varied, it is the language’s songs and poems that are most famous. Many bards learn Elven so they can add Elven ballads to their repertoires. Others simply memorize Elven songs by sound. The Elven script, as flowing as the spoken word, also serves as the script for Sylvan, the language of dryads and pixies, for Aquan, the language of water-based creatures, and for Undercommon, the language of the drow and other subterranean creatures.	When an elf declares herself an adult, usually some time after her hundredth birthday, she also selects a name. Those who knew her as a youngster may or may not continue to call her by her “child name,” and she may or may not care. An elf’s adult name is a unique creation, though it may reflect the names of those she admires or the names of others in her family. In addition, she bears her family name. Family names are combinations of regular Elven words; and some elves traveling among humans translate their names into Common while others use the Elven version.	Elves take up adventuring out of wanderlust. Life among humans moves at a pace that elves dislike: regimented from day to day but changing from decade to decade. Elves among humans, therefore, find careers that allow them to wander freely and set their own pace. Elves also enjoy demonstrating their prowess with the sword and bow or gaining greater magical powers, and adventuring allows them to do so. Good elves may also be rebels or crusaders.
20	Gnome	Small	20	Humanoid	4	2026-01-06 15:02:21.950156+01	Gnomes adore animals, beautiful gems, and jokes of all kinds. Members of this race have a great sense of humor, and while they love puns, jokes, and games, they relish tricks—the more intricate the better. They apply the same dedication to more practical arts, such as engineering, as they do to their pranks. Gnomes are inquisitive. They love to find things out by personal experience. At times they’re even reckless. Their curiosity makes them skilled engineers, since they are always trying new ways to build things. Sometimes a gnome pulls a prank just to see how the people involved will react.	Gnomes stand about 3 to 3-1/2 feet tall and weigh 40 to 45 pounds. Their skin ranges from dark tan to woody brown, their hair is fair, and their eyes can be any shade of blue. Gnome males prefer short, carefully trimmed beards. Gnomes generally wear leather or earth tones, and they decorate their clothes with intricate stitching or fine jewelry. Gnomes reach adulthood at about age 40, and they live about 350 years, though some can live almost 500 years.	Gnomes get along well with dwarves, who share their love of precious objects, their curiosity about mechanical devices, and their hatred of goblins and giants. They enjoy the company of halflings, especially those who are easygoing enough to put up with pranks and jests. Most gnomes are a little suspicious of the taller races—humans, elves, half-elves, and half-orcs—but they are rarely hostile or malicious.	Gnomes are most often good. Those who tend toward law are sages, engineers, researchers, scholars, investigators, or consultants. Those who tend toward chaos are minstrels, tricksters, wanderers, or fanciful jewelers. Gnomes are good-hearted, and even the tricksters among them are more playful than vicious. Evil gnomes are as rare as they are frightening.	Gnomes make their homes in hilly, wooded lands. They live underground but get more fresh air than dwarves do, enjoying the natural, living world on the surface whenever they can. Their homes are well hidden, by both clever construction and illusions. Those who come to visit and are welcome are ushered into the bright, warm burrows. Those who are not welcome never find the burrows in the first place. Gnomes who settle in human lands are commonly gemcutters, mechanics, sages, or tutors. Some human families retain gnome tutors. During his life, a gnome tutor can teach several generations of a single human family.	The chief gnome god is Garl Glittergold, the Watchful Protector. His clerics teach that gnomes are to cherish and support their communities. Pranks are seen as ways to lighten spirits and to keep gnomes humble, not as ways for pranksters to triumph over those they trick.	The Gnome language, which uses the Dwarven script, is renowned for its technical treatises and its catalogs of knowledge about the natural world. Human herbalists, naturalists, and engineers commonly learn Gnome in order to read the best books on their topics of study.	Gnomes love names, and most have half a dozen or so. As a gnome grows up, his mother gives him a name, his father gives him a name, his clan elder gives him a name, his aunts and uncles give him names, and he gains nicknames from just about anyone. Gnome names are typically variants on the names of ancestors or distant relatives, though some are purely new inventions. When dealing with humans and others who are rather “stuffy” about names, a gnome learns to act as if he has no more than three names: a personal name, a clan name, and a nickname. When deciding which of his several names to use among humans, a gnome generally chooses the one that’s the most fun to say. Gnome clan names are combinations of common Gnome words, and gnomes almost always translate them into Common when in human lands (or into Elven when in elven lands, and so on).	Gnomes are curious and impulsive. They may take up adventuring as a way to see the world or for the love of exploring. Lawful gnomes may adventure to set things right and to protect the innocent, demonstrating the same sense of duty toward society as a whole that gnomes generally exhibit toward their own enclaves. As lovers of gems and other fine items, some gnomes take to adventuring as a quick, if dangerous, path to wealth. Depending on his relations to his home clan, an adventuring gnome may be seen as a vagabond or even something of a traitor (for abandoning clan responsibilities).
21	Half-Elf	Medium	30	Humanoid	5	2026-01-06 15:02:21.950156+01	Most half-elves have the curiosity, inventiveness, and ambition of the human parent, along with the refined senses, love of nature, and artistic tastes of the elf parent.	To humans, half-elves look like elves. To elves, they look like humans—indeed, elves call them half-humans. Half-elf height ranges from under 5 feet to about 6 feet tall, and weight usually ranges from 100 to 180 pounds. Half-elf men are taller and heavier than half-elf women, but the difference is less pronounced than that found among humans. Half-elves are paler, fairer, and smoother-skinned than their human parents, but their actual skin tone, hair color, and other details vary just as human features do. Half-elves’ eyes are green, just as are those of their elf parents. A half-elf reaches adulthood at age 20 and can live to be over 180 years old.	Half-elves do well among both elves and humans, and they also get along well with dwarves, gnomes, and halflings. They have elven grace without elven aloofness, human energy without human boorishness. They make excellent ambassadors and go-betweens (except between elves and humans, since each side suspects the half-elf of favoring the other). In human lands where elves are distant or not on friendly terms with other races, however, half-elves are viewed with suspicion. Some half-elves show a marked disfavor toward half-orcs. Perhaps the similarities between themselves and half-orcs (a partly human lineage) makes these half-elves uncomfortable.	Half-elves share the chaotic bent of their elven heritage, but, like humans, they tend toward both good and evil in equal proportion. Like elves, they value personal freedom and creative expression, demonstrating neither love of leaders nor desire for followers. They chafe at rules, resent others’ demands, and sometimes prove unreliable, or at least unpredictable.	Half-elves have no lands of their own, though they are welcome in human cities and elven forests. In large cities, half-elves sometimes form small communities of their own.	Half-elves raised among elves follow elven deities, principally Corellon Larethian (god of the elves). Those raised among humans often follow Ehlonna (goddess of the woodlands).	Half-elves speak the languages they are born to, Common and Elven. Half-elves are slightly clumsy with the intricate Elven language, though only elves notice, and even so half-elves do better than nonelves.	Half-elves use either human or elven naming conventions. Ironically, a half-elf raised among humans is often given an elven name in honor of her heritage, just as a half-elf raised among elves often takes a human name.	Half-elves find themselves drawn to strange careers and unusual company. Taking up the life of an adventurer comes easily to many of them. Like elves, they are driven by wanderlust.
22	Half-Orc	Medium	30	Humanoid	6	2026-01-06 15:02:21.950156+01	Half-orcs tend to be short-tempered and sullen. They would rather act than ponder and would rather fight than argue. Those who are successful, however, are those with enough self-control to live in a civilized land, not the crazy ones. Half-orcs love simple pleasures such as feasting, drinking, boasting, singing, wrestling, drumming, and wild dancing. Refined enjoyments such as poetry, courtly dancing, and philosophy are lost on them.	Half-orcs stand between 6 and 7 feet tall and usually weigh between 180 and 250 pounds. A half-orc’s grayish pigmentation, sloping forehead, jutting jaw, prominent teeth, and coarse body hair make his lineage plain for all to see. Orcs like scars. They regard battle scars as tokens of pride and ornamental scars as things of beauty. Any half-orc who has lived among or near orcs has scars, whether they are marks of shame indicating servitude and identifying the half-orc’s former owner, or marks of pride recounting conquests and high status. Such a half-orc living among humans may either display or hide his scars, depending on his attitude toward them. Half-orcs mature a little faster than humans and age noticeably faster. They reach adulthood at age 14, and few live longer than 75 years.	Because orcs are the sworn enemies of dwarves and elves, half-orcs can have a rough time with members of these races. For that matter, orcs aren’t exactly on good terms with humans, halflings, or gnomes, either. Each half-orc finds a way to gain acceptance from those who hate or fear his orc cousins. Some half-orcs are reserved, trying not to draw attention to themselves. A few demonstrate piety and good-heartedness as publicly as they can (whether or not such demonstrations are genuine). Others simply try to be so tough that others have no choice but to accept them.	Half-orcs inherit a tendency toward chaos from their orc parents, but, like their human parents, they favor good and evil in equal proportions. Half-orcs raised among orcs and willing to live out their lives with them are usually the evil ones.	Half-orcs have no lands of their own, but they most often live among orcs. Of the other races, humans are the ones most likely to accept half-orcs, and half-orcs almost always live in human lands when not living among orc tribes.	Like orcs, many half-orcs worship Gruumsh, the chief orc god and archenemy of Corellon Larethian, god of the elves. While Gruumsh is evil, half-orc barbarians and fighters may worship him as a war god even if they are not evil themselves. Worshipers of Gruumsh who are tired of explaining themselves, or who don’t want to give humans a reason to distrust them, simply don’t make their religion public knowledge. Half-orcs who want to solidify their connection to their human heritage, on the other hand, follow human gods, and they may be outspoken in their shows of piety.	Orc, which has no alphabet of its own, uses Dwarven script on the rare occasions that someone writes something down. Orc writing turns up most frequently in graffiti.	A half-orc typically chooses a name that helps him make the impression that he wants to make. If he wants to fit in among humans, he chooses a human name. If he wants to intimidate others, he chooses a guttural orc name. A half-orc who has been raised entirely by humans has a human given name, but he may choose another name once he’s away from his hometown. Some half-orcs, of course, aren’t quite bright enough to choose a name this carefully.	Half-orcs living among humans are drawn almost invariably toward violent careers in which they can put their strength to good use. Frequently shunned from polite company, half-orcs often find acceptance and friendship among adventurers, many of whom are fellow wanderers and outsiders.
23	Halfling	Small	20	Humanoid	7	2026-01-06 15:02:21.950156+01	Halflings prefer trouble to boredom. They are notoriously curious. Relying on their ability to survive or escape danger, they demonstrate a daring that many larger people can’t match. Halflings clans are nomadic, wandering wherever circumstance and curiosity take them. Halflings enjoy wealth and the pleasure it can bring, and they tend to spend gold as quickly as they acquire it. Halflings are also famous collectors. While more orthodox halflings may collect weapons, books, or jewelry, some collect such objects as the hides of wild beasts—or even the beasts themselves.	Halflings stand about 3 feet tall and usually weigh between 30 and 35 pounds. Their skin is ruddy, their hair black and straight. They have brown or black eyes. Halfling men often have long sideburns, but beards are rare among them and mustaches almost unseen. They like to wear simple, comfortable, and practical clothes. A halfling reaches adulthood at the age of 20 and generally lives into the middle of her second century.	Halflings try to get along with everyone else. They are adept at fitting into a community of humans, dwarves, elves, or gnomes and making themselves valuable and welcome. Since human society changes faster than the societies of the longer-lived races, it is human society that most frequently offers halflings opportunities to exploit, and halflings are most often found in or around human lands.	Halflings tend to be neutral. While they are comfortable with change (a chaotic trait), they also tend to rely on intangible constants, such as clan ties and personal honor (a lawful trait).	Halflings have no lands of their own. Instead, they live in the lands of other races, where they can benefit from whatever resources those lands have to offer. Halflings often form tight-knit communities in human or dwarven cities. While they work readily with others, they often make friends only their own kind. Halflings also settle into secluded places where they set up self-reliant villages. Halfling communities, however, are known for picking up and moving en masse to some place that offers a new opportunity, such as a new mine that has just opened, or to a land where a devastating war has made skilled workers hard to find. If these opportunities are temporary, the community may pick up and move again once the opportunity is gone, or once a better one presents itself. Some halfling communities, on the other hand, take to traveling as a way of life, driving wagons or guiding boats from place to place, and maintaining no permanent home.	The chief halfling deity is Yondalla, the Blessed One, protector of the halflings. Yondalla promises blessings and protection to those who heed her guidance, defend their clans, and cherish their families. Halflings also recognize countless small gods, which they say rule over individual villages, forests, rivers, lakes, and so on. They pay homage to these deities to ensure safe journeys as they travel from place to place.	Halflings speak their own language, which uses the Common script. They write very little in their own language so, unlike dwarves, elves, and gnomes, they don’t have a rich body of written work. The halfling oral tradition, however, is very strong. While the Halfling language isn’t secret, halflings are loath to share it with others. Almost all halflings speak Common, since they use it to deal with the people in whose land they are living or through which they are traveling.	A halfling has a given name, a family name, and possibly a nickname. It would seem that family names are nothing more than nicknames that stuck so well they have been passed down through the generations.	Halflings often set out on their own to make their way in the world. Halfling adventurers are typically looking for a way to use their skills to gain wealth or status. The distinction between a halfling adventurer and a halfling out on her own looking for “a big score” can get blurry. For a halfling, adventuring is less of a career than an opportunity. While halfling opportunism can sometimes look like larceny or fraud to others, a halfling adventurer who learns to trust her fellows is worthy of trust in return.
\.


--
-- TOC entry 4018 (class 0 OID 35991)
-- Dependencies: 260
-- Data for Name: rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rules (id, category, subcategory, name, description, source_id, search_vector, last_updated) FROM stdin;
1	Combat	\N	Attack Roll	An attack roll represents your attempt to strike your opponent on your turn in a round. When you make an attack roll, you roll a d20 and add your attack bonus. (Other modifiers may also apply to this roll.) If your result equals or beats the target’s Armor Class, you hit and deal damage.	1	'add':30B 'also':37B 'appli':38B 'armor':51B 'attack':1A,4B,23B,32B 'attempt':8B 'beat':47B 'bonus':33B 'class':52B 'combat':58C 'd20':28B 'damag':57B 'deal':56B 'equal':45B 'hit':54B 'make':21B 'may':36B 'modifi':35B 'oppon':12B 'repres':6B 'result':44B 'roll':2A,5B,24B,26B,41B 'round':18B 'strike':10B 'target':49B 'turn':15B	2026-01-07 00:18:25.526552+01
2	Exploration	\N	Light and Vision	Characters need light to see. Bright light illuminates an area clearly. Shadowy illumination allows creatures to be seen but grants them concealment.	1	'allow':17B 'area':13B 'bright':9B 'charact':4B 'clear':14B 'conceal':25B 'creatur':18B 'explor':26C 'grant':23B 'illumin':11B,16B 'light':1A,6B,10B 'need':5B 'see':8B 'seen':21B 'shadowi':15B 'vision':3A	2026-01-07 00:18:25.526552+01
\.


--
-- TOC entry 4020 (class 0 OID 35997)
-- Dependencies: 262
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skills (id, name, key_attribute, trained_only, armor_check_penalty, description, source_id, last_updated) FROM stdin;
9	Concentration	Constitution	f	f	You are particularly good at focusing your mind.	1	2026-01-07 00:07:12.660111+01
10	Spellcraft	Intelligence	t	f	You are skilled at the art of casting spells and identifying magic.	1	2026-01-07 00:07:12.660111+01
11	Spot	Wisdom	f	f	Use this skill to notice bandits in ambush.	1	2026-01-07 00:07:12.660111+01
12	Listen	Wisdom	f	f	Use this skill to hear approaching enemies.	1	2026-01-07 00:07:12.660111+01
\.


--
-- TOC entry 4022 (class 0 OID 36005)
-- Dependencies: 264
-- Data for Name: source_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.source_entries (id, page, errata, book_id, last_updated) FROM stdin;
1	12	\N	3	2026-01-06 14:26:46.205597+01
2	14	\N	3	2026-01-06 14:26:46.205597+01
3	15	\N	3	2026-01-06 14:26:46.205597+01
4	18	\N	3	2026-01-06 14:26:46.205597+01
5	18	\N	3	2026-01-06 14:26:46.205597+01
6	18	\N	3	2026-01-06 14:26:46.205597+01
7	20	\N	3	2026-01-06 14:26:46.205597+01
8	170	\N	4	2026-01-06 14:26:46.205597+01
9	130	\N	5	2026-01-06 14:26:46.205597+01
10	29	\N	5	2026-01-06 14:26:46.205597+01
11	130	\N	5	2026-01-06 14:26:46.205597+01
12	153	\N	5	2026-01-06 14:26:46.205597+01
13	161	\N	5	2026-01-06 14:26:46.205597+01
14	27	\N	5	2026-01-06 14:26:46.205597+01
15	203	\N	5	2026-01-06 14:26:46.205597+01
16	246	\N	5	2026-01-06 14:26:46.205597+01
\.


--
-- TOC entry 4023 (class 0 OID 36010)
-- Dependencies: 265
-- Data for Name: source_tables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.source_tables (id, title, table_data) FROM stdin;
\.


--
-- TOC entry 4025 (class 0 OID 36016)
-- Dependencies: 267
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sources (id, name, abbreviation, published_year, is_core, last_updated) FROM stdin;
3	Player's Handbook v.3.5	PHB	2003	t	2026-01-06 14:03:39.343845+01
4	Dungeon Master's Guide v.3.5	DMG	2003	t	2026-01-06 14:03:39.343845+01
5	Monster Manual v.3.5	MM	2003	t	2026-01-06 14:03:39.343845+01
6	Miniatures Handbook	MH	2003	f	2026-01-06 14:03:39.343845+01
7	Book of Exalted Deeds	BED	2003	f	2026-01-06 14:03:39.343845+01
8	Draconomicon	Dra	2003	f	2026-01-06 14:03:39.343845+01
9	Complete Warrior	CW	2003	f	2026-01-06 14:03:39.343845+01
10	Unearthed Arcana	UA	2004	f	2026-01-06 14:03:39.343845+01
11	Expanded Psionics Handbook	XPH	2004	f	2026-01-06 14:03:39.343845+01
12	Complete Divine	CD	2004	f	2026-01-06 14:03:39.343845+01
13	Planar Handbook	PlH	2004	f	2026-01-06 14:03:39.343845+01
14	Races of Stone	RoS	2004	f	2026-01-06 14:03:39.343845+01
15	Monster Manual III	MM3	2004	f	2026-01-06 14:03:39.343845+01
16	Libris Mortis	LM	2004	f	2026-01-06 14:03:39.343845+01
17	Complete Arcane	CAr	2004	f	2026-01-06 14:03:39.343845+01
18	Complete Adventurer	CAd	2005	f	2026-01-06 14:03:59.611128+01
19	Lords of Madness	LoM	2005	f	2026-01-06 14:03:59.611128+01
20	Races of the Wild	RotW	2005	f	2026-01-06 14:03:59.611128+01
21	Sandstorm	San	2005	f	2026-01-06 14:03:59.611128+01
22	Monster Manual IV	MM4	2005	f	2026-01-06 14:03:59.611128+01
23	Heroes of Battle	HoB	2005	f	2026-01-06 14:03:59.611128+01
24	Dungeon Survival Guide	DSG	2005	f	2026-01-06 14:03:59.611128+01
25	Magic of Incarnum	MoI	2005	f	2026-01-06 14:03:59.611128+01
26	Heroes of Horror	HoH	2005	f	2026-01-06 14:03:59.611128+01
27	Spell Compendium	SpC	2005	f	2026-01-06 14:03:59.611128+01
28	Player's Handbook II	PHB2	2006	f	2026-01-06 14:03:59.611128+01
29	Complete Psionic	CPs	2006	f	2026-01-06 14:03:59.611128+01
30	Tome of Magic	ToM	2006	f	2026-01-06 14:03:59.611128+01
31	Fiendish Codex I: Hordes of the Abyss	FCI	2006	f	2026-01-06 14:03:59.611128+01
32	Monster Manual V	MM5	2006	f	2026-01-06 14:03:59.611128+01
33	Player's Guide to Destiny	PGtD	2006	f	2026-01-06 14:03:59.611128+01
34	Tome of Battle: The Book of Nine Swords	ToB	2006	f	2026-01-06 14:03:59.611128+01
35	Dragon Magic	DraM	2006	f	2026-01-06 14:03:59.611128+01
36	Complete Mage	CM	2006	f	2026-01-06 14:03:59.611128+01
37	Fiendish Codex II: Tyrants of the Nine Hells	FCII	2006	f	2026-01-06 14:03:59.611128+01
38	Complete Champion	CC	2007	f	2026-01-06 14:03:59.611128+01
39	Complete Scoundrel	CS	2007	f	2026-01-06 14:03:59.611128+01
40	Magic Item Compendium	MIC	2007	f	2026-01-06 14:03:59.611128+01
41	Expedition to the Demonweb Pits	EDP	2007	f	2026-01-06 14:03:59.611128+01
42	Rules Compendium	RC	2007	f	2026-01-06 14:03:59.611128+01
43	Elder Evils	EE	2007	f	2026-01-06 14:03:59.611128+01
\.


--
-- TOC entry 4028 (class 0 OID 36023)
-- Dependencies: 270
-- Data for Name: spell_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spell_levels (spell_id, level, class_id) FROM stdin;
5	1	2
6	1	5
\.


--
-- TOC entry 4029 (class 0 OID 36026)
-- Dependencies: 271
-- Data for Name: spells; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spells (id, name, school, subschool, descriptors, casting_time, spell_range, target, duration, saving_throw, spell_resistance, description, source_id, has_verbal_component, has_somatic_component, has_material_component, has_focus_component, has_xp_component, has_divine_focus_component, has_expensive_component, material_focus_description, gp_cost, xp_cost, search_vector, last_updated) FROM stdin;
5	Magic Missile	Evocation	Force	{Force}	1 standard action	Medium (100 ft. + 10 ft./level)	Up to five creatures	Instantaneous	None	t	A missile of magical energy darts forth from your fingertip.	1	t	t	f	f	f	f	f	\N	0	0	'dart':8B 'energi':7B 'fingertip':12B 'forth':9B 'magic':1A,6B 'missil':2A,4B	2026-01-07 00:07:12.660111+01
6	Cure Light Wounds	Conjuration	Healing	\N	1 standard action	Touch	Creature touched	Instantaneous	Will half (harmless)	t	Channels positive energy that cures 1d8 points of damage +1 point per caster level.	1	t	t	f	f	f	f	f	\N	0	0	'+1':13B '1d8':9B 'caster':16B 'channel':4B 'cure':1A,8B 'damag':12B 'energi':6B 'level':17B 'light':2A 'per':15B 'point':10B,14B 'posit':5B 'wound':3A	2026-01-07 00:07:12.660111+01
\.


--
-- TOC entry 4031 (class 0 OID 36042)
-- Dependencies: 273
-- Data for Name: spells_known_progression; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spells_known_progression (id, class_id, level, cantrips, first_grade, second_grade, third_grade, fourth_grade, fifth_grade, sixth_grade, seventh_grade, eighth_grade, ninth_grade) FROM stdin;
\.


--
-- TOC entry 4035 (class 0 OID 36429)
-- Dependencies: 280
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password_hash, email, created_at, last_login) FROM stdin;
3	testuser	hashed_secret_password_123	test@example.com	2026-01-07 00:18:25.526552+01	\N
4	dm_user	hashed_secret_password_456	dm@example.com	2026-01-07 00:18:25.526552+01	\N
\.


--
-- TOC entry 4033 (class 0 OID 36067)
-- Dependencies: 278
-- Data for Name: weapon_damage_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.weapon_damage_type (weapon_properties_id, damage_type_id) FROM stdin;
1	3
2	2
\.


--
-- TOC entry 4048 (class 0 OID 36579)
-- Dependencies: 293
-- Data for Name: weapon_properties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.weapon_properties (id, damage_id, critical_id, range, handedness, weapon_type, weapon_category) FROM stdin;
1	5	1	\N	1-handed	Martial	One-Handed Melee
2	4	2	60	2-handed	Martial	Ranged
\.


--
-- TOC entry 4151 (class 0 OID 0)
-- Dependencies: 294
-- Name: armor_properties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.armor_properties_id_seq', 2, true);


--
-- TOC entry 4152 (class 0 OID 0)
-- Dependencies: 302
-- Name: body_slots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.body_slots_id_seq', 14, true);


--
-- TOC entry 4153 (class 0 OID 0)
-- Dependencies: 296
-- Name: bonus_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bonus_types_id_seq', 15, true);


--
-- TOC entry 4154 (class 0 OID 0)
-- Dependencies: 216
-- Name: caster_progression_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.caster_progression_id_seq', 3, true);


--
-- TOC entry 4155 (class 0 OID 0)
-- Dependencies: 298
-- Name: character_feats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.character_feats_id_seq', 2, true);


--
-- TOC entry 4156 (class 0 OID 0)
-- Dependencies: 288
-- Name: character_inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.character_inventory_id_seq', 7, true);


--
-- TOC entry 4157 (class 0 OID 0)
-- Dependencies: 299
-- Name: character_skills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.character_skills_id_seq', 2, true);


--
-- TOC entry 4158 (class 0 OID 0)
-- Dependencies: 300
-- Name: character_spell_slots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.character_spell_slots_id_seq', 1, false);


--
-- TOC entry 4159 (class 0 OID 0)
-- Dependencies: 286
-- Name: character_spells_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.character_spells_id_seq', 1, true);


--
-- TOC entry 4160 (class 0 OID 0)
-- Dependencies: 281
-- Name: characters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.characters_id_seq', 4, true);


--
-- TOC entry 4161 (class 0 OID 0)
-- Dependencies: 218
-- Name: class_description_sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.class_description_sections_id_seq', 1, false);


--
-- TOC entry 4162 (class 0 OID 0)
-- Dependencies: 220
-- Name: class_features_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.class_features_id_seq', 1, false);


--
-- TOC entry 4163 (class 0 OID 0)
-- Dependencies: 222
-- Name: class_progression_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.class_progression_id_seq', 6, true);


--
-- TOC entry 4164 (class 0 OID 0)
-- Dependencies: 225
-- Name: classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.classes_id_seq', 5, true);


--
-- TOC entry 4165 (class 0 OID 0)
-- Dependencies: 227
-- Name: conditions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditions_id_seq', 2, true);


--
-- TOC entry 4166 (class 0 OID 0)
-- Dependencies: 309
-- Name: critical_combinations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.critical_combinations_id_seq', 2, true);


--
-- TOC entry 4167 (class 0 OID 0)
-- Dependencies: 231
-- Name: damage_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.damage_type_id_seq', 20, true);


--
-- TOC entry 4168 (class 0 OID 0)
-- Dependencies: 234
-- Name: domains_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.domains_id_seq', 2, true);


--
-- TOC entry 4169 (class 0 OID 0)
-- Dependencies: 237
-- Name: enchantments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.enchantments_id_seq', 2, true);


--
-- TOC entry 4170 (class 0 OID 0)
-- Dependencies: 239
-- Name: entity_tables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entity_tables_id_seq', 1, false);


--
-- TOC entry 4171 (class 0 OID 0)
-- Dependencies: 241
-- Name: entity_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entity_types_id_seq', 1, false);


--
-- TOC entry 4172 (class 0 OID 0)
-- Dependencies: 243
-- Name: feat_prereq_attribute_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.feat_prereq_attribute_id_seq', 3, true);


--
-- TOC entry 4173 (class 0 OID 0)
-- Dependencies: 245
-- Name: feat_prereq_feat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.feat_prereq_feat_id_seq', 1, false);


--
-- TOC entry 4174 (class 0 OID 0)
-- Dependencies: 247
-- Name: feat_prereq_skill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.feat_prereq_skill_id_seq', 1, false);


--
-- TOC entry 4175 (class 0 OID 0)
-- Dependencies: 249
-- Name: feats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.feats_id_seq', 2, true);


--
-- TOC entry 4176 (class 0 OID 0)
-- Dependencies: 251
-- Name: item_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_types_id_seq', 11, true);


--
-- TOC entry 4177 (class 0 OID 0)
-- Dependencies: 290
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_seq', 6, true);


--
-- TOC entry 4178 (class 0 OID 0)
-- Dependencies: 253
-- Name: monsters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.monsters_id_seq', 4, true);


--
-- TOC entry 4179 (class 0 OID 0)
-- Dependencies: 255
-- Name: npcs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.npcs_id_seq', 1, false);


--
-- TOC entry 4180 (class 0 OID 0)
-- Dependencies: 257
-- Name: race_features_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.race_features_id_seq', 62, true);


--
-- TOC entry 4181 (class 0 OID 0)
-- Dependencies: 259
-- Name: races_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.races_id_seq', 33, true);


--
-- TOC entry 4182 (class 0 OID 0)
-- Dependencies: 261
-- Name: rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rules_id_seq', 2, true);


--
-- TOC entry 4183 (class 0 OID 0)
-- Dependencies: 263
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.skills_id_seq', 12, true);


--
-- TOC entry 4184 (class 0 OID 0)
-- Dependencies: 266
-- Name: source_tables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.source_tables_id_seq', 1, false);


--
-- TOC entry 4185 (class 0 OID 0)
-- Dependencies: 268
-- Name: sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sources_id_seq', 16, true);


--
-- TOC entry 4186 (class 0 OID 0)
-- Dependencies: 269
-- Name: sources_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sources_id_seq1', 43, true);


--
-- TOC entry 4187 (class 0 OID 0)
-- Dependencies: 272
-- Name: spells_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.spells_id_seq', 6, true);


--
-- TOC entry 4188 (class 0 OID 0)
-- Dependencies: 274
-- Name: spells_known_progression_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.spells_known_progression_id_seq', 1, false);


--
-- TOC entry 4189 (class 0 OID 0)
-- Dependencies: 279
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- TOC entry 4190 (class 0 OID 0)
-- Dependencies: 292
-- Name: weapon_properties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.weapon_properties_id_seq', 2, true);


--
-- TOC entry 3736 (class 2606 OID 36601)
-- Name: armor_properties armor_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.armor_properties
    ADD CONSTRAINT armor_properties_pkey PRIMARY KEY (id);


--
-- TOC entry 3746 (class 2606 OID 36807)
-- Name: body_slots body_slots_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_slots
    ADD CONSTRAINT body_slots_name_key UNIQUE (name);


--
-- TOC entry 3748 (class 2606 OID 36805)
-- Name: body_slots body_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_slots
    ADD CONSTRAINT body_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 3738 (class 2606 OID 36717)
-- Name: bonus_types bonus_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus_types
    ADD CONSTRAINT bonus_types_name_key UNIQUE (name);


--
-- TOC entry 3740 (class 2606 OID 36715)
-- Name: bonus_types bonus_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus_types
    ADD CONSTRAINT bonus_types_pkey PRIMARY KEY (id);


--
-- TOC entry 3590 (class 2606 OID 36110)
-- Name: caster_progression caster_progression_class_id_level_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caster_progression
    ADD CONSTRAINT caster_progression_class_id_level_key UNIQUE (class_id, level);


--
-- TOC entry 3592 (class 2606 OID 36112)
-- Name: caster_progression caster_progression_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caster_progression
    ADD CONSTRAINT caster_progression_pkey PRIMARY KEY (id);


--
-- TOC entry 3711 (class 2606 OID 36473)
-- Name: character_classes character_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_classes
    ADD CONSTRAINT character_classes_pkey PRIMARY KEY (character_id, class_id);


--
-- TOC entry 3714 (class 2606 OID 36727)
-- Name: character_feats character_feats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_feats
    ADD CONSTRAINT character_feats_pkey PRIMARY KEY (id);


--
-- TOC entry 3723 (class 2606 OID 36546)
-- Name: character_inventory character_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_inventory
    ADD CONSTRAINT character_inventory_pkey PRIMARY KEY (id);


--
-- TOC entry 3717 (class 2606 OID 36738)
-- Name: character_skills character_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_skills
    ADD CONSTRAINT character_skills_pkey PRIMARY KEY (id);


--
-- TOC entry 3742 (class 2606 OID 36788)
-- Name: character_spell_slots character_spell_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_spell_slots
    ADD CONSTRAINT character_spell_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 3720 (class 2606 OID 36525)
-- Name: character_spells character_spells_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_spells
    ADD CONSTRAINT character_spells_pkey PRIMARY KEY (id);


--
-- TOC entry 3708 (class 2606 OID 36458)
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- TOC entry 3594 (class 2606 OID 36114)
-- Name: class_description_sections class_description_sections_class_id_section_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_description_sections
    ADD CONSTRAINT class_description_sections_class_id_section_name_key UNIQUE (class_id, section_name);


--
-- TOC entry 3596 (class 2606 OID 36116)
-- Name: class_description_sections class_description_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_description_sections
    ADD CONSTRAINT class_description_sections_pkey PRIMARY KEY (id);


--
-- TOC entry 3598 (class 2606 OID 36118)
-- Name: class_features class_features_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_features
    ADD CONSTRAINT class_features_pkey PRIMARY KEY (id);


--
-- TOC entry 3600 (class 2606 OID 36120)
-- Name: class_progression class_progression_class_id_level_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_progression
    ADD CONSTRAINT class_progression_class_id_level_key UNIQUE (class_id, level);


--
-- TOC entry 3602 (class 2606 OID 36122)
-- Name: class_progression class_progression_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_progression
    ADD CONSTRAINT class_progression_pkey PRIMARY KEY (id);


--
-- TOC entry 3604 (class 2606 OID 36124)
-- Name: class_skills class_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_skills
    ADD CONSTRAINT class_skills_pkey PRIMARY KEY (class_id, skill_id);


--
-- TOC entry 3606 (class 2606 OID 36126)
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- TOC entry 3609 (class 2606 OID 36128)
-- Name: conditions conditions_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_name_key UNIQUE (name);


--
-- TOC entry 3611 (class 2606 OID 36130)
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- TOC entry 3614 (class 2606 OID 36134)
-- Name: critical_combinations critical_combinations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.critical_combinations
    ADD CONSTRAINT critical_combinations_pkey PRIMARY KEY (id);


--
-- TOC entry 3616 (class 2606 OID 36136)
-- Name: damage_scaling damage_scaling_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.damage_scaling
    ADD CONSTRAINT damage_scaling_pkey PRIMARY KEY (id);


--
-- TOC entry 3618 (class 2606 OID 36138)
-- Name: damage_types damage_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.damage_types
    ADD CONSTRAINT damage_type_name_key UNIQUE (name);


--
-- TOC entry 3620 (class 2606 OID 36140)
-- Name: damage_types damage_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.damage_types
    ADD CONSTRAINT damage_type_pkey PRIMARY KEY (id);


--
-- TOC entry 3622 (class 2606 OID 36142)
-- Name: domain_spells domain_spells_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_spells
    ADD CONSTRAINT domain_spells_pkey PRIMARY KEY (domain_id, spell_id);


--
-- TOC entry 3624 (class 2606 OID 36144)
-- Name: domains domains_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_name_key UNIQUE (name);


--
-- TOC entry 3626 (class 2606 OID 36146)
-- Name: domains domains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- TOC entry 3628 (class 2606 OID 36148)
-- Name: enchantment_applicable_to enchantment_applicable_to_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantment_applicable_to
    ADD CONSTRAINT enchantment_applicable_to_pkey PRIMARY KEY (enchantment_id, item_type_id);


--
-- TOC entry 3630 (class 2606 OID 36150)
-- Name: enchantments enchantments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantments
    ADD CONSTRAINT enchantments_pkey PRIMARY KEY (id);


--
-- TOC entry 3633 (class 2606 OID 36152)
-- Name: entity_tables entity_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tables
    ADD CONSTRAINT entity_tables_pkey PRIMARY KEY (id);


--
-- TOC entry 3635 (class 2606 OID 36154)
-- Name: entity_types entity_types_display_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_display_name_key UNIQUE (display_name);


--
-- TOC entry 3637 (class 2606 OID 36156)
-- Name: entity_types entity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_pkey PRIMARY KEY (id);


--
-- TOC entry 3639 (class 2606 OID 36158)
-- Name: entity_types entity_types_table_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_table_name_key UNIQUE (table_name);


--
-- TOC entry 3641 (class 2606 OID 36160)
-- Name: feat_prereq_attribute feat_prereq_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_attribute
    ADD CONSTRAINT feat_prereq_attribute_pkey PRIMARY KEY (id);


--
-- TOC entry 3643 (class 2606 OID 36162)
-- Name: feat_prereq_feat feat_prereq_feat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_feat
    ADD CONSTRAINT feat_prereq_feat_pkey PRIMARY KEY (id);


--
-- TOC entry 3645 (class 2606 OID 36164)
-- Name: feat_prereq_skill feat_prereq_skill_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_skill
    ADD CONSTRAINT feat_prereq_skill_pkey PRIMARY KEY (id);


--
-- TOC entry 3647 (class 2606 OID 36166)
-- Name: feats feats_name_source_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feats
    ADD CONSTRAINT feats_name_source_id_key UNIQUE (name, source_id);


--
-- TOC entry 3649 (class 2606 OID 36168)
-- Name: feats feats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feats
    ADD CONSTRAINT feats_pkey PRIMARY KEY (id);


--
-- TOC entry 3654 (class 2606 OID 36170)
-- Name: item_types item_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_types
    ADD CONSTRAINT item_types_name_key UNIQUE (name);


--
-- TOC entry 3656 (class 2606 OID 36172)
-- Name: item_types item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- TOC entry 3732 (class 2606 OID 36567)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 3662 (class 2606 OID 36174)
-- Name: monsters monsters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monsters
    ADD CONSTRAINT monsters_pkey PRIMARY KEY (id);


--
-- TOC entry 3664 (class 2606 OID 36178)
-- Name: npcs npcs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npcs
    ADD CONSTRAINT npcs_pkey PRIMARY KEY (id);


--
-- TOC entry 3666 (class 2606 OID 36180)
-- Name: race_features race_features_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.race_features
    ADD CONSTRAINT race_features_pkey PRIMARY KEY (id);


--
-- TOC entry 3669 (class 2606 OID 36182)
-- Name: races races_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_pkey PRIMARY KEY (id);


--
-- TOC entry 3673 (class 2606 OID 36184)
-- Name: rules rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- TOC entry 3676 (class 2606 OID 36186)
-- Name: skills skills_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_name_key UNIQUE (name);


--
-- TOC entry 3678 (class 2606 OID 36188)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 3682 (class 2606 OID 36190)
-- Name: source_tables source_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_tables
    ADD CONSTRAINT source_tables_pkey PRIMARY KEY (id);


--
-- TOC entry 3680 (class 2606 OID 36192)
-- Name: source_entries sources_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_entries
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- TOC entry 3684 (class 2606 OID 36194)
-- Name: sources sources_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_pkey1 PRIMARY KEY (id);


--
-- TOC entry 3686 (class 2606 OID 36196)
-- Name: spell_levels spell_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spell_levels
    ADD CONSTRAINT spell_levels_pkey PRIMARY KEY (class_id, spell_id);


--
-- TOC entry 3696 (class 2606 OID 36198)
-- Name: spells_known_progression spells_known_progression_class_id_level_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_known_progression
    ADD CONSTRAINT spells_known_progression_class_id_level_key UNIQUE (class_id, level);


--
-- TOC entry 3698 (class 2606 OID 36200)
-- Name: spells_known_progression spells_known_progression_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_known_progression
    ADD CONSTRAINT spells_known_progression_pkey PRIMARY KEY (id);


--
-- TOC entry 3692 (class 2606 OID 36202)
-- Name: spells spells_name_source_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells
    ADD CONSTRAINT spells_name_source_id_key UNIQUE (name, source_id);


--
-- TOC entry 3694 (class 2606 OID 36204)
-- Name: spells spells_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells
    ADD CONSTRAINT spells_pkey PRIMARY KEY (id);


--
-- TOC entry 3744 (class 2606 OID 36790)
-- Name: character_spell_slots unique_char_slot_level; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_spell_slots
    ADD CONSTRAINT unique_char_slot_level UNIQUE (character_id, spell_level);


--
-- TOC entry 3702 (class 2606 OID 36441)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3704 (class 2606 OID 36437)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3706 (class 2606 OID 36439)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3700 (class 2606 OID 36206)
-- Name: weapon_damage_type weapon_damage_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_damage_type
    ADD CONSTRAINT weapon_damage_type_pkey PRIMARY KEY (weapon_properties_id, damage_type_id);


--
-- TOC entry 3734 (class 2606 OID 36584)
-- Name: weapon_properties weapon_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_properties
    ADD CONSTRAINT weapon_properties_pkey PRIMARY KEY (id);


--
-- TOC entry 3712 (class 1259 OID 36553)
-- Name: idx_character_classes_char_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_classes_char_id ON public.character_classes USING btree (character_id);


--
-- TOC entry 3715 (class 1259 OID 36554)
-- Name: idx_character_feats_char_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_feats_char_id ON public.character_feats USING btree (character_id);


--
-- TOC entry 3724 (class 1259 OID 36557)
-- Name: idx_character_inventory_char_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_inventory_char_id ON public.character_inventory USING btree (character_id);


--
-- TOC entry 3725 (class 1259 OID 36701)
-- Name: idx_character_inventory_enchantment_ids; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_inventory_enchantment_ids ON public.character_inventory USING gin (enchantment_ids);


--
-- TOC entry 3718 (class 1259 OID 36555)
-- Name: idx_character_skills_char_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_skills_char_id ON public.character_skills USING btree (character_id);


--
-- TOC entry 3721 (class 1259 OID 36556)
-- Name: idx_character_spells_char_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_spells_char_id ON public.character_spells USING btree (character_id);


--
-- TOC entry 3709 (class 1259 OID 36552)
-- Name: idx_characters_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_characters_user_id ON public.characters USING btree (user_id);


--
-- TOC entry 3607 (class 1259 OID 36647)
-- Name: idx_classes_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classes_name_lower ON public.classes USING btree (lower(name));


--
-- TOC entry 3612 (class 1259 OID 36210)
-- Name: idx_conditions_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_conditions_search ON public.conditions USING gin (search_vector);


--
-- TOC entry 3631 (class 1259 OID 36723)
-- Name: idx_enchantments_bonus_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_enchantments_bonus_type_id ON public.enchantments USING btree (bonus_type_id);


--
-- TOC entry 3650 (class 1259 OID 36644)
-- Name: idx_feats_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feats_name_lower ON public.feats USING btree (lower(name));


--
-- TOC entry 3651 (class 1259 OID 36211)
-- Name: idx_feats_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feats_search ON public.feats USING gin (search_vector);


--
-- TOC entry 3652 (class 1259 OID 36212)
-- Name: idx_feats_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feats_source_id ON public.feats USING btree (source_id);


--
-- TOC entry 3726 (class 1259 OID 36700)
-- Name: idx_items_enchantment_ids; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_enchantment_ids ON public.items USING gin (enchantment_ids);


--
-- TOC entry 3727 (class 1259 OID 36674)
-- Name: idx_items_item_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_item_type_id ON public.items USING btree (item_type_id);


--
-- TOC entry 3728 (class 1259 OID 36607)
-- Name: idx_items_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_name_lower ON public.items USING btree (lower(name));


--
-- TOC entry 3729 (class 1259 OID 36672)
-- Name: idx_items_properties_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_properties_id ON public.items USING btree (properties_id);


--
-- TOC entry 3730 (class 1259 OID 36673)
-- Name: idx_items_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_source_id ON public.items USING btree (source_id);


--
-- TOC entry 3657 (class 1259 OID 36215)
-- Name: idx_monsters_cr_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_monsters_cr_number ON public.monsters USING btree (cr_number);


--
-- TOC entry 3658 (class 1259 OID 36645)
-- Name: idx_monsters_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_monsters_name_lower ON public.monsters USING btree (lower(name));


--
-- TOC entry 3659 (class 1259 OID 36216)
-- Name: idx_monsters_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_monsters_search ON public.monsters USING gin (search_vector);


--
-- TOC entry 3660 (class 1259 OID 36217)
-- Name: idx_monsters_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_monsters_type ON public.monsters USING btree (type);


--
-- TOC entry 3667 (class 1259 OID 36648)
-- Name: idx_races_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_races_name_lower ON public.races USING btree (lower(name));


--
-- TOC entry 3670 (class 1259 OID 36218)
-- Name: idx_rules_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rules_category ON public.rules USING btree (category);


--
-- TOC entry 3671 (class 1259 OID 36219)
-- Name: idx_rules_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rules_search ON public.rules USING gin (search_vector);


--
-- TOC entry 3674 (class 1259 OID 36646)
-- Name: idx_skills_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_skills_name_lower ON public.skills USING btree (lower(name));


--
-- TOC entry 3687 (class 1259 OID 36643)
-- Name: idx_spells_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_spells_name_lower ON public.spells USING btree (lower(name));


--
-- TOC entry 3688 (class 1259 OID 36220)
-- Name: idx_spells_school; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_spells_school ON public.spells USING btree (school);


--
-- TOC entry 3689 (class 1259 OID 36221)
-- Name: idx_spells_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_spells_search ON public.spells USING gin (search_vector);


--
-- TOC entry 3690 (class 1259 OID 36222)
-- Name: idx_spells_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_spells_source_id ON public.spells USING btree (source_id);


--
-- TOC entry 3821 (class 2620 OID 36696)
-- Name: armor_properties track_armor_prop_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_armor_prop_updates AFTER UPDATE ON public.armor_properties FOR EACH ROW EXECUTE FUNCTION public.propagate_item_update();


--
-- TOC entry 3803 (class 2620 OID 36682)
-- Name: classes track_class_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_class_updates BEFORE UPDATE ON public.classes FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3804 (class 2620 OID 36692)
-- Name: conditions track_condition_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_condition_updates BEFORE UPDATE ON public.conditions FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3806 (class 2620 OID 36680)
-- Name: feats track_feat_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_feat_updates BEFORE UPDATE ON public.feats FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3818 (class 2620 OID 36678)
-- Name: items track_item_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_item_updates BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3808 (class 2620 OID 36681)
-- Name: monsters track_monster_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_monster_updates BEFORE UPDATE ON public.monsters FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3810 (class 2620 OID 36683)
-- Name: races track_race_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_race_updates BEFORE UPDATE ON public.races FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3811 (class 2620 OID 36691)
-- Name: rules track_rule_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_rule_updates BEFORE UPDATE ON public.rules FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3813 (class 2620 OID 36690)
-- Name: skills track_skill_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_skill_updates BEFORE UPDATE ON public.skills FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3814 (class 2620 OID 36693)
-- Name: source_entries track_source_entry_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_source_entry_updates BEFORE UPDATE ON public.source_entries FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3815 (class 2620 OID 36684)
-- Name: sources track_source_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_source_updates BEFORE UPDATE ON public.sources FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3816 (class 2620 OID 36679)
-- Name: spells track_spell_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_spell_updates BEFORE UPDATE ON public.spells FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3820 (class 2620 OID 36695)
-- Name: weapon_properties track_weapon_prop_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_weapon_prop_updates AFTER UPDATE ON public.weapon_properties FOR EACH ROW EXECUTE FUNCTION public.propagate_item_update();


--
-- TOC entry 3805 (class 2620 OID 36689)
-- Name: conditions tsvectorupdate_conditions; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tsvectorupdate_conditions BEFORE INSERT OR UPDATE ON public.conditions FOR EACH ROW EXECUTE FUNCTION public.conditions_search_vector_update();


--
-- TOC entry 3807 (class 2620 OID 36224)
-- Name: feats tsvectorupdate_feats; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tsvectorupdate_feats BEFORE INSERT OR UPDATE ON public.feats FOR EACH ROW EXECUTE FUNCTION public.feats_search_vector_update();


--
-- TOC entry 3819 (class 2620 OID 36685)
-- Name: items tsvectorupdate_items; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tsvectorupdate_items BEFORE INSERT OR UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.items_search_vector_update();


--
-- TOC entry 3809 (class 2620 OID 36226)
-- Name: monsters tsvectorupdate_monsters; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tsvectorupdate_monsters BEFORE INSERT OR UPDATE ON public.monsters FOR EACH ROW EXECUTE FUNCTION public.monsters_search_vector_update();


--
-- TOC entry 3812 (class 2620 OID 36687)
-- Name: rules tsvectorupdate_rules; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tsvectorupdate_rules BEFORE INSERT OR UPDATE ON public.rules FOR EACH ROW EXECUTE FUNCTION public.rules_search_vector_update();


--
-- TOC entry 3817 (class 2620 OID 36227)
-- Name: spells tsvectorupdate_spells; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tsvectorupdate_spells BEFORE INSERT OR UPDATE ON public.spells FOR EACH ROW EXECUTE FUNCTION public.spells_search_vector_update();


--
-- TOC entry 3749 (class 2606 OID 36233)
-- Name: caster_progression caster_progression_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caster_progression
    ADD CONSTRAINT caster_progression_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3786 (class 2606 OID 36474)
-- Name: character_classes character_classes_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_classes
    ADD CONSTRAINT character_classes_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 3787 (class 2606 OID 36479)
-- Name: character_classes character_classes_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_classes
    ADD CONSTRAINT character_classes_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id);


--
-- TOC entry 3788 (class 2606 OID 36491)
-- Name: character_feats character_feats_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_feats
    ADD CONSTRAINT character_feats_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 3789 (class 2606 OID 36496)
-- Name: character_feats character_feats_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_feats
    ADD CONSTRAINT character_feats_feat_id_fkey FOREIGN KEY (feat_id) REFERENCES public.feats(id);


--
-- TOC entry 3794 (class 2606 OID 36547)
-- Name: character_inventory character_inventory_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_inventory
    ADD CONSTRAINT character_inventory_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 3790 (class 2606 OID 36507)
-- Name: character_skills character_skills_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_skills
    ADD CONSTRAINT character_skills_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 3791 (class 2606 OID 36512)
-- Name: character_skills character_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_skills
    ADD CONSTRAINT character_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id);


--
-- TOC entry 3802 (class 2606 OID 36791)
-- Name: character_spell_slots character_spell_slots_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_spell_slots
    ADD CONSTRAINT character_spell_slots_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 3792 (class 2606 OID 36526)
-- Name: character_spells character_spells_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_spells
    ADD CONSTRAINT character_spells_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 3793 (class 2606 OID 36531)
-- Name: character_spells character_spells_spell_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_spells
    ADD CONSTRAINT character_spells_spell_id_fkey FOREIGN KEY (spell_id) REFERENCES public.spells(id);


--
-- TOC entry 3784 (class 2606 OID 36464)
-- Name: characters characters_race_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_race_id_fkey FOREIGN KEY (race_id) REFERENCES public.races(id);


--
-- TOC entry 3785 (class 2606 OID 36459)
-- Name: characters characters_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3750 (class 2606 OID 36238)
-- Name: class_description_sections class_description_sections_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_description_sections
    ADD CONSTRAINT class_description_sections_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3751 (class 2606 OID 36243)
-- Name: class_features class_features_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_features
    ADD CONSTRAINT class_features_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3752 (class 2606 OID 36248)
-- Name: class_progression class_progression_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_progression
    ADD CONSTRAINT class_progression_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3753 (class 2606 OID 36253)
-- Name: class_skills class_skills_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_skills
    ADD CONSTRAINT class_skills_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE;


--
-- TOC entry 3754 (class 2606 OID 36258)
-- Name: class_skills class_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_skills
    ADD CONSTRAINT class_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id) ON DELETE CASCADE;


--
-- TOC entry 3755 (class 2606 OID 36263)
-- Name: classes classes_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3756 (class 2606 OID 36268)
-- Name: conditions conditions_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id);


--
-- TOC entry 3757 (class 2606 OID 36278)
-- Name: domain_spells domain_spells_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_spells
    ADD CONSTRAINT domain_spells_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.domains(id) ON DELETE CASCADE;


--
-- TOC entry 3758 (class 2606 OID 36283)
-- Name: domain_spells domain_spells_spell_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_spells
    ADD CONSTRAINT domain_spells_spell_id_fkey FOREIGN KEY (spell_id) REFERENCES public.spells(id) ON DELETE CASCADE;


--
-- TOC entry 3759 (class 2606 OID 36288)
-- Name: domains domains_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id);


--
-- TOC entry 3760 (class 2606 OID 36293)
-- Name: enchantment_applicable_to enchantment_applicable_to_enchantment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantment_applicable_to
    ADD CONSTRAINT enchantment_applicable_to_enchantment_id_fkey FOREIGN KEY (enchantment_id) REFERENCES public.enchantments(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3761 (class 2606 OID 36298)
-- Name: enchantment_applicable_to enchantment_applicable_to_item_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantment_applicable_to
    ADD CONSTRAINT enchantment_applicable_to_item_type_id_fkey FOREIGN KEY (item_type_id) REFERENCES public.item_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3762 (class 2606 OID 36303)
-- Name: enchantments enchantments_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantments
    ADD CONSTRAINT enchantments_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3764 (class 2606 OID 36308)
-- Name: entity_tables entity_tables_entity_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tables
    ADD CONSTRAINT entity_tables_entity_type_id_fkey FOREIGN KEY (entity_type_id) REFERENCES public.entity_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3765 (class 2606 OID 36313)
-- Name: entity_tables entity_tables_source_table_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tables
    ADD CONSTRAINT entity_tables_source_table_id_fkey FOREIGN KEY (source_table_id) REFERENCES public.source_tables(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3766 (class 2606 OID 36318)
-- Name: feat_prereq_attribute feat_prereq_attribute_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_attribute
    ADD CONSTRAINT feat_prereq_attribute_feat_id_fkey FOREIGN KEY (feat_id) REFERENCES public.feats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3767 (class 2606 OID 36323)
-- Name: feat_prereq_feat feat_prereq_feat_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_feat
    ADD CONSTRAINT feat_prereq_feat_feat_id_fkey FOREIGN KEY (feat_id) REFERENCES public.feats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3768 (class 2606 OID 36328)
-- Name: feat_prereq_feat feat_prereq_feat_prereq_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_feat
    ADD CONSTRAINT feat_prereq_feat_prereq_feat_id_fkey FOREIGN KEY (prereq_feat_id) REFERENCES public.feats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3769 (class 2606 OID 36333)
-- Name: feat_prereq_skill feat_prereq_skill_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_skill
    ADD CONSTRAINT feat_prereq_skill_feat_id_fkey FOREIGN KEY (feat_id) REFERENCES public.feats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3770 (class 2606 OID 36338)
-- Name: feats feats_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feats
    ADD CONSTRAINT feats_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3795 (class 2606 OID 36602)
-- Name: character_inventory fk_character_inventory_item_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_inventory
    ADD CONSTRAINT fk_character_inventory_item_id FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- TOC entry 3763 (class 2606 OID 36718)
-- Name: enchantments fk_enchantments_bonus_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantments
    ADD CONSTRAINT fk_enchantments_bonus_type FOREIGN KEY (bonus_type_id) REFERENCES public.bonus_types(id);


--
-- TOC entry 3796 (class 2606 OID 36662)
-- Name: items fk_items_item_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_items_item_type FOREIGN KEY (item_type_id) REFERENCES public.item_types(id);


--
-- TOC entry 3782 (class 2606 OID 36633)
-- Name: weapon_damage_type fk_weapon_damage_type_properties; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_damage_type
    ADD CONSTRAINT fk_weapon_damage_type_properties FOREIGN KEY (weapon_properties_id) REFERENCES public.weapon_properties(id) ON DELETE CASCADE;


--
-- TOC entry 3797 (class 2606 OID 36573)
-- Name: items items_base_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_base_item_id_fkey FOREIGN KEY (base_item_id) REFERENCES public.items(id);


--
-- TOC entry 3798 (class 2606 OID 36808)
-- Name: items items_body_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_body_slot_id_fkey FOREIGN KEY (body_slot_id) REFERENCES public.body_slots(id);


--
-- TOC entry 3799 (class 2606 OID 36568)
-- Name: items items_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id);


--
-- TOC entry 3771 (class 2606 OID 36343)
-- Name: monsters monsters_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monsters
    ADD CONSTRAINT monsters_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3772 (class 2606 OID 36353)
-- Name: npcs npcs_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npcs
    ADD CONSTRAINT npcs_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3773 (class 2606 OID 36358)
-- Name: race_features race_features_race_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.race_features
    ADD CONSTRAINT race_features_race_id_fkey FOREIGN KEY (race_id) REFERENCES public.races(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3774 (class 2606 OID 36363)
-- Name: races races_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3775 (class 2606 OID 36368)
-- Name: rules rules_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id);


--
-- TOC entry 3776 (class 2606 OID 36373)
-- Name: skills skills_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id);


--
-- TOC entry 3777 (class 2606 OID 36378)
-- Name: source_entries source_entries_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_entries
    ADD CONSTRAINT source_entries_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.sources(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 3778 (class 2606 OID 36383)
-- Name: spell_levels spell_levels_class_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spell_levels
    ADD CONSTRAINT spell_levels_class_id_fk FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 3779 (class 2606 OID 36388)
-- Name: spell_levels spell_levels_spell_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spell_levels
    ADD CONSTRAINT spell_levels_spell_id_fkey FOREIGN KEY (spell_id) REFERENCES public.spells(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3781 (class 2606 OID 36393)
-- Name: spells_known_progression spells_known_progression_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_known_progression
    ADD CONSTRAINT spells_known_progression_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3780 (class 2606 OID 36398)
-- Name: spells spells_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells
    ADD CONSTRAINT spells_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3783 (class 2606 OID 36403)
-- Name: weapon_damage_type weapon_damage_type_damage_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_damage_type
    ADD CONSTRAINT weapon_damage_type_damage_type_id_fkey FOREIGN KEY (damage_type_id) REFERENCES public.damage_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3800 (class 2606 OID 36590)
-- Name: weapon_properties weapon_properties_critical_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_properties
    ADD CONSTRAINT weapon_properties_critical_id_fkey FOREIGN KEY (critical_id) REFERENCES public.critical_combinations(id);


--
-- TOC entry 3801 (class 2606 OID 36585)
-- Name: weapon_properties weapon_properties_damage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_properties
    ADD CONSTRAINT weapon_properties_damage_id_fkey FOREIGN KEY (damage_id) REFERENCES public.damage_scaling(id);


--
-- TOC entry 4065 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE armor_properties; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.armor_properties TO dnd_app_user;


--
-- TOC entry 4069 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE caster_progression; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.caster_progression TO dnd_app_user;


--
-- TOC entry 4071 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE character_classes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.character_classes TO dnd_app_user;


--
-- TOC entry 4072 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE character_feats; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.character_feats TO dnd_app_user;


--
-- TOC entry 4074 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE character_inventory; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.character_inventory TO dnd_app_user;


--
-- TOC entry 4076 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE character_skills; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.character_skills TO dnd_app_user;


--
-- TOC entry 4079 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE character_spells; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.character_spells TO dnd_app_user;


--
-- TOC entry 4081 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE characters; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.characters TO dnd_app_user;


--
-- TOC entry 4083 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE class_description_sections; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.class_description_sections TO dnd_app_user;


--
-- TOC entry 4085 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE class_features; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.class_features TO dnd_app_user;


--
-- TOC entry 4087 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE class_progression; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.class_progression TO dnd_app_user;


--
-- TOC entry 4089 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE class_skills; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.class_skills TO dnd_app_user;


--
-- TOC entry 4090 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE classes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.classes TO dnd_app_user;


--
-- TOC entry 4092 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE conditions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.conditions TO dnd_app_user;


--
-- TOC entry 4094 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE critical_combinations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.critical_combinations TO dnd_app_user;


--
-- TOC entry 4095 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE damage_scaling; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.damage_scaling TO dnd_app_user;


--
-- TOC entry 4096 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE damage_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.damage_types TO dnd_app_user;


--
-- TOC entry 4098 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE domain_spells; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.domain_spells TO dnd_app_user;


--
-- TOC entry 4099 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE domains; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.domains TO dnd_app_user;


--
-- TOC entry 4101 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE enchantment_applicable_to; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.enchantment_applicable_to TO dnd_app_user;


--
-- TOC entry 4102 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE enchantments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.enchantments TO dnd_app_user;


--
-- TOC entry 4104 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE entity_tables; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.entity_tables TO dnd_app_user;


--
-- TOC entry 4106 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE entity_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.entity_types TO dnd_app_user;


--
-- TOC entry 4108 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE feat_prereq_attribute; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.feat_prereq_attribute TO dnd_app_user;


--
-- TOC entry 4110 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE feat_prereq_feat; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.feat_prereq_feat TO dnd_app_user;


--
-- TOC entry 4112 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE feat_prereq_skill; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.feat_prereq_skill TO dnd_app_user;


--
-- TOC entry 4114 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE feats; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.feats TO dnd_app_user;


--
-- TOC entry 4116 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE item_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.item_types TO dnd_app_user;


--
-- TOC entry 4118 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.items TO dnd_app_user;


--
-- TOC entry 4120 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE monsters; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.monsters TO dnd_app_user;


--
-- TOC entry 4122 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE npcs; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.npcs TO dnd_app_user;


--
-- TOC entry 4124 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE race_features; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.race_features TO dnd_app_user;


--
-- TOC entry 4126 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE races; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.races TO dnd_app_user;


--
-- TOC entry 4128 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE rules; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.rules TO dnd_app_user;


--
-- TOC entry 4130 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE skills; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.skills TO dnd_app_user;


--
-- TOC entry 4132 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE source_entries; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.source_entries TO dnd_app_user;


--
-- TOC entry 4133 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE source_tables; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.source_tables TO dnd_app_user;


--
-- TOC entry 4135 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE sources; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.sources TO dnd_app_user;


--
-- TOC entry 4138 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE spell_levels; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.spell_levels TO dnd_app_user;


--
-- TOC entry 4139 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE spells; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.spells TO dnd_app_user;


--
-- TOC entry 4141 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE spells_known_progression; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.spells_known_progression TO dnd_app_user;


--
-- TOC entry 4143 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.users TO dnd_app_user;


--
-- TOC entry 4145 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE view_feat_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_feat_details TO dnd_app_user;


--
-- TOC entry 4146 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE weapon_properties; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.weapon_properties TO dnd_app_user;


--
-- TOC entry 4147 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE view_monster_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_monster_details TO dnd_app_user;


--
-- TOC entry 4148 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE view_spell_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_spell_details TO dnd_app_user;


--
-- TOC entry 4149 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE weapon_damage_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.weapon_damage_type TO dnd_app_user;


-- Completed on 2026-01-07 16:37:18 CET

--
-- PostgreSQL database dump complete
--

\unrestrict KfLY6u2zhjTjhdw85hbHDKceyhe9bcMkY9f97acfes28II7vmBskHagul8zB359

