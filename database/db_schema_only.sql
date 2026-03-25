--
-- PostgreSQL database dump
--

\restrict pn00q5ObSJqfIQ0kPvjd2upjHXgzFRQtQkglHM0CsnxxRzqVjAmwqbyobVbUPg8

-- Dumped from database version 13.22 (Debian 13.22-0+deb11u1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

-- Started on 2026-03-25 23:03:36 CET

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
-- TOC entry 6 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 25961)
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- TOC entry 772 (class 1247 OID 26041)
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
-- TOC entry 775 (class 1247 OID 26052)
-- Name: dnd_attributes; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.dnd_attributes AS ENUM (
    'Strength',
    'Dexterity',
    'Constitution',
    'Intelligence',
    'Wisdom',
    'Charisma',
    'None'
);


ALTER TYPE public.dnd_attributes OWNER TO postgres;

--
-- TOC entry 778 (class 1247 OID 26066)
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
-- TOC entry 781 (class 1247 OID 26078)
-- Name: weapon_handedness_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.weapon_handedness_enum AS ENUM (
    '1-handed',
    '2-handed',
    'versatile'
);


ALTER TYPE public.weapon_handedness_enum OWNER TO postgres;

--
-- TOC entry 784 (class 1247 OID 26086)
-- Name: weapon_side_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.weapon_side_enum AS ENUM (
    'primary',
    'secondary'
);


ALTER TYPE public.weapon_side_enum OWNER TO postgres;

--
-- TOC entry 787 (class 1247 OID 26092)
-- Name: weapon_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.weapon_type_enum AS ENUM (
    'Simple',
    'Martial',
    'Exotic'
);


ALTER TYPE public.weapon_type_enum OWNER TO postgres;

--
-- TOC entry 345 (class 1255 OID 26099)
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
-- TOC entry 346 (class 1255 OID 26100)
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
-- TOC entry 307 (class 1259 OID 27476)
-- Name: adventurer_armor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurer_armor (
    id integer NOT NULL,
    adventurer_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer DEFAULT 1,
    is_equipped boolean DEFAULT false,
    is_identified boolean DEFAULT false,
    is_masterwork boolean DEFAULT false,
    enhancement_bonus integer DEFAULT 0,
    enchantment_ids integer[] DEFAULT '{}'::integer[],
    override_caster_level integer,
    custom_name text,
    notes text
);


ALTER TABLE public.adventurer_armor OWNER TO postgres;

--
-- TOC entry 306 (class 1259 OID 27474)
-- Name: adventurer_armor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adventurer_armor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adventurer_armor_id_seq OWNER TO postgres;

--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 306
-- Name: adventurer_armor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adventurer_armor_id_seq OWNED BY public.adventurer_armor.id;


--
-- TOC entry 201 (class 1259 OID 26113)
-- Name: adventurer_classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurer_classes (
    adventurer_id integer NOT NULL,
    class_id integer NOT NULL,
    class_level integer NOT NULL
);


ALTER TABLE public.adventurer_classes OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 26116)
-- Name: adventurer_feats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurer_feats (
    adventurer_id integer NOT NULL,
    feat_id integer NOT NULL,
    note text,
    id integer NOT NULL
);


ALTER TABLE public.adventurer_feats OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 26122)
-- Name: adventurer_feats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adventurer_feats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adventurer_feats_id_seq OWNER TO postgres;

--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 203
-- Name: adventurer_feats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adventurer_feats_id_seq OWNED BY public.adventurer_feats.id;


--
-- TOC entry 309 (class 1259 OID 27503)
-- Name: adventurer_gear; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurer_gear (
    id integer NOT NULL,
    adventurer_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer DEFAULT 1,
    is_equipped boolean DEFAULT false,
    is_identified boolean DEFAULT false,
    enhancement_bonus integer DEFAULT 0,
    enchantment_ids integer[] DEFAULT '{}'::integer[],
    override_caster_level integer,
    current_charges integer,
    custom_name text,
    notes text
);


ALTER TABLE public.adventurer_gear OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 27501)
-- Name: adventurer_gear_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adventurer_gear_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adventurer_gear_id_seq OWNER TO postgres;

--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 308
-- Name: adventurer_gear_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adventurer_gear_id_seq OWNED BY public.adventurer_gear.id;


--
-- TOC entry 311 (class 1259 OID 27529)
-- Name: adventurer_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurer_items (
    id integer NOT NULL,
    adventurer_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer DEFAULT 1,
    is_identified boolean DEFAULT false,
    custom_name text,
    notes text
);


ALTER TABLE public.adventurer_items OWNER TO postgres;

--
-- TOC entry 310 (class 1259 OID 27527)
-- Name: adventurer_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adventurer_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adventurer_items_id_seq OWNER TO postgres;

--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 310
-- Name: adventurer_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adventurer_items_id_seq OWNED BY public.adventurer_items.id;


--
-- TOC entry 204 (class 1259 OID 26134)
-- Name: adventurer_skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurer_skills (
    adventurer_id integer NOT NULL,
    skill_id integer NOT NULL,
    ranks numeric(4,1) DEFAULT 0 NOT NULL,
    id integer NOT NULL,
    sub_skill text
);


ALTER TABLE public.adventurer_skills OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 26141)
-- Name: adventurer_skills_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adventurer_skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adventurer_skills_id_seq OWNER TO postgres;

--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 205
-- Name: adventurer_skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adventurer_skills_id_seq OWNED BY public.adventurer_skills.id;


--
-- TOC entry 206 (class 1259 OID 26143)
-- Name: adventurer_spell_slots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurer_spell_slots (
    id integer NOT NULL,
    adventurer_id integer NOT NULL,
    spell_level integer NOT NULL,
    slots_used integer DEFAULT 0
);


ALTER TABLE public.adventurer_spell_slots OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 26147)
-- Name: adventurer_spell_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adventurer_spell_slots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adventurer_spell_slots_id_seq OWNER TO postgres;

--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 207
-- Name: adventurer_spell_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adventurer_spell_slots_id_seq OWNED BY public.adventurer_spell_slots.id;


--
-- TOC entry 208 (class 1259 OID 26149)
-- Name: adventurer_spells; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurer_spells (
    id integer NOT NULL,
    adventurer_id integer,
    spell_id integer,
    is_prepared boolean DEFAULT false,
    is_known boolean DEFAULT true,
    notes text,
    prepared_count integer DEFAULT 0
);


ALTER TABLE public.adventurer_spells OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 26158)
-- Name: adventurer_spells_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adventurer_spells_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adventurer_spells_id_seq OWNER TO postgres;

--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 209
-- Name: adventurer_spells_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adventurer_spells_id_seq OWNED BY public.adventurer_spells.id;


--
-- TOC entry 305 (class 1259 OID 27449)
-- Name: adventurer_weapons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurer_weapons (
    id integer NOT NULL,
    adventurer_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer DEFAULT 1,
    is_equipped boolean DEFAULT false,
    is_identified boolean DEFAULT false,
    is_masterwork boolean DEFAULT false,
    enhancement_bonus integer DEFAULT 0,
    enchantment_ids integer[] DEFAULT '{}'::integer[],
    override_caster_level integer,
    current_charges integer,
    custom_name text,
    notes text
);


ALTER TABLE public.adventurer_weapons OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 27447)
-- Name: adventurer_weapons_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adventurer_weapons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adventurer_weapons_id_seq OWNER TO postgres;

--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 304
-- Name: adventurer_weapons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adventurer_weapons_id_seq OWNED BY public.adventurer_weapons.id;


--
-- TOC entry 210 (class 1259 OID 26172)
-- Name: adventurers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adventurers (
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


ALTER TABLE public.adventurers OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 26186)
-- Name: adventurers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adventurers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adventurers_id_seq OWNER TO postgres;

--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 211
-- Name: adventurers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adventurers_id_seq OWNED BY public.adventurers.id;


--
-- TOC entry 212 (class 1259 OID 26188)
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
-- TOC entry 213 (class 1259 OID 26192)
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
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 213
-- Name: armor_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.armor_properties_id_seq OWNED BY public.armor_properties.id;


--
-- TOC entry 214 (class 1259 OID 26194)
-- Name: body_slots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.body_slots (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.body_slots OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 26200)
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
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 215
-- Name: body_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.body_slots_id_seq OWNED BY public.body_slots.id;


--
-- TOC entry 216 (class 1259 OID 26202)
-- Name: bonus_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bonus_types (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.bonus_types OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 26208)
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
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 217
-- Name: bonus_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bonus_types_id_seq OWNED BY public.bonus_types.id;


--
-- TOC entry 218 (class 1259 OID 26216)
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
-- TOC entry 219 (class 1259 OID 26222)
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
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 219
-- Name: class_description_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_description_sections_id_seq OWNED BY public.class_description_sections.id;


--
-- TOC entry 220 (class 1259 OID 26224)
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
-- TOC entry 221 (class 1259 OID 26230)
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
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 221
-- Name: class_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_features_id_seq OWNED BY public.class_features.id;


--
-- TOC entry 222 (class 1259 OID 26232)
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
-- TOC entry 223 (class 1259 OID 26239)
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
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 223
-- Name: class_progression_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_progression_id_seq OWNED BY public.class_progression.id;


--
-- TOC entry 224 (class 1259 OID 26241)
-- Name: class_skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_skills (
    class_id integer NOT NULL,
    skill_id integer NOT NULL
);


ALTER TABLE public.class_skills OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 26244)
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
-- TOC entry 226 (class 1259 OID 26253)
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
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 226
-- Name: classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.classes_id_seq OWNED BY public.classes.id;


--
-- TOC entry 227 (class 1259 OID 26255)
-- Name: conditions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conditions (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    source_id integer,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.conditions OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 26262)
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
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 228
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conditions_id_seq OWNED BY public.conditions.id;


--
-- TOC entry 229 (class 1259 OID 26264)
-- Name: critical_combinations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.critical_combinations (
    id integer NOT NULL,
    crit_range integer,
    crit_damage integer NOT NULL
);


ALTER TABLE public.critical_combinations OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 26267)
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
-- TOC entry 231 (class 1259 OID 26269)
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
-- TOC entry 232 (class 1259 OID 26275)
-- Name: damage_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.damage_types (
    id integer NOT NULL,
    name text NOT NULL,
    category text
);


ALTER TABLE public.damage_types OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 26281)
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
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 233
-- Name: damage_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.damage_type_id_seq OWNED BY public.damage_types.id;


--
-- TOC entry 234 (class 1259 OID 26283)
-- Name: domain_spells; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.domain_spells (
    domain_id integer NOT NULL,
    spell_id integer NOT NULL,
    level integer NOT NULL
);


ALTER TABLE public.domain_spells OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 26286)
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
-- TOC entry 236 (class 1259 OID 26292)
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
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 236
-- Name: domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.domains_id_seq OWNED BY public.domains.id;


--
-- TOC entry 303 (class 1259 OID 27432)
-- Name: enchantment_applicable_to; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enchantment_applicable_to (
    enchantment_id integer NOT NULL,
    item_type_id integer NOT NULL
);


ALTER TABLE public.enchantment_applicable_to OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 27407)
-- Name: enchantments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enchantments (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    bonus_value integer DEFAULT 0,
    flat_cost_gp integer DEFAULT 0,
    creation_cost_gp integer DEFAULT 0,
    creation_cost_xp integer DEFAULT 0,
    prerequisites jsonb DEFAULT '{}'::jsonb,
    caster_level integer,
    source_id integer NOT NULL,
    bonus_type_id integer NOT NULL,
    CONSTRAINT check_value_logic CHECK (((bonus_value >= 0) AND (flat_cost_gp >= 0)))
);


ALTER TABLE public.enchantments OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 27405)
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
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 301
-- Name: enchantments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.enchantments_id_seq OWNED BY public.enchantments.id;


--
-- TOC entry 237 (class 1259 OID 26305)
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
-- TOC entry 238 (class 1259 OID 26308)
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
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 238
-- Name: entity_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_tables_id_seq OWNED BY public.entity_tables.id;


--
-- TOC entry 239 (class 1259 OID 26310)
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
-- TOC entry 240 (class 1259 OID 26314)
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
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 240
-- Name: entity_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entity_types_id_seq OWNED BY public.entity_types.id;


--
-- TOC entry 241 (class 1259 OID 26321)
-- Name: feat_prereq_feat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feat_prereq_feat (
    id integer NOT NULL,
    feat_id integer NOT NULL,
    prereq_feat_id integer NOT NULL,
    set_index integer DEFAULT 1
);


ALTER TABLE public.feat_prereq_feat OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 26324)
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
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 242
-- Name: feat_prereq_feat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feat_prereq_feat_id_seq OWNED BY public.feat_prereq_feat.id;


--
-- TOC entry 295 (class 1259 OID 27313)
-- Name: feat_prereq_numeric; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feat_prereq_numeric (
    id integer NOT NULL,
    feat_id integer NOT NULL,
    set_index integer DEFAULT 1,
    category text NOT NULL,
    key text NOT NULL,
    value integer NOT NULL
);


ALTER TABLE public.feat_prereq_numeric OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 27311)
-- Name: feat_prereq_numeric_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feat_prereq_numeric_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feat_prereq_numeric_id_seq OWNER TO postgres;

--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 294
-- Name: feat_prereq_numeric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feat_prereq_numeric_id_seq OWNED BY public.feat_prereq_numeric.id;


--
-- TOC entry 297 (class 1259 OID 27330)
-- Name: feat_prereq_special; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feat_prereq_special (
    id integer NOT NULL,
    feat_id integer NOT NULL,
    set_index integer DEFAULT 1,
    requirement text NOT NULL
);


ALTER TABLE public.feat_prereq_special OWNER TO postgres;

--
-- TOC entry 296 (class 1259 OID 27328)
-- Name: feat_prereq_special_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feat_prereq_special_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feat_prereq_special_id_seq OWNER TO postgres;

--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 296
-- Name: feat_prereq_special_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feat_prereq_special_id_seq OWNED BY public.feat_prereq_special.id;


--
-- TOC entry 243 (class 1259 OID 26334)
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
    last_updated timestamp with time zone DEFAULT now(),
    is_multiple boolean DEFAULT false,
    is_stack boolean DEFAULT false,
    choice_text text
);


ALTER TABLE public.feats OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 26341)
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
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 244
-- Name: feats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feats_id_seq OWNED BY public.feats.id;


--
-- TOC entry 245 (class 1259 OID 26343)
-- Name: item_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_types (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.item_types OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 26349)
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
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 246
-- Name: item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.item_types_id_seq OWNED BY public.item_types.id;


--
-- TOC entry 300 (class 1259 OID 27359)
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    price integer,
    weight numeric(6,2),
    caster_level integer,
    item_type_id integer NOT NULL,
    source_id integer,
    body_slot_id integer,
    base_item_id integer,
    is_unique boolean DEFAULT false,
    enhancement_bonus integer DEFAULT 0,
    enchantment_ids integer[],
    weapon_stats_id integer,
    armor_stats_id integer,
    image_url text,
    last_updated timestamp with time zone DEFAULT now(),
    CONSTRAINT check_exclusive_stats CHECK ((((weapon_stats_id IS NOT NULL) AND (armor_stats_id IS NULL)) OR ((weapon_stats_id IS NULL) AND (armor_stats_id IS NOT NULL)) OR ((weapon_stats_id IS NULL) AND (armor_stats_id IS NULL))))
);


ALTER TABLE public.items OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 27357)
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
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 299
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- TOC entry 247 (class 1259 OID 26361)
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
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.monsters OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 26368)
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
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 248
-- Name: monsters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.monsters_id_seq OWNED BY public.monsters.id;


--
-- TOC entry 249 (class 1259 OID 26370)
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
-- TOC entry 250 (class 1259 OID 26376)
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
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 250
-- Name: npcs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.npcs_id_seq OWNED BY public.npcs.id;


--
-- TOC entry 251 (class 1259 OID 26378)
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
-- TOC entry 252 (class 1259 OID 26384)
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
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 252
-- Name: race_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.race_features_id_seq OWNED BY public.race_features.id;


--
-- TOC entry 253 (class 1259 OID 26386)
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
-- TOC entry 254 (class 1259 OID 26393)
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
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 254
-- Name: races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.races_id_seq OWNED BY public.races.id;


--
-- TOC entry 292 (class 1259 OID 27191)
-- Name: restricted_slots_progression; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.restricted_slots_progression (
    id integer NOT NULL,
    progression_id integer NOT NULL,
    first_grade_res integer DEFAULT 0,
    second_grade_res integer DEFAULT 0,
    third_grade_res integer DEFAULT 0,
    fourth_grade_res integer DEFAULT 0,
    fifth_grade_res integer DEFAULT 0,
    sixth_grade_res integer DEFAULT 0,
    seventh_grade_res integer DEFAULT 0,
    eighth_grade_res integer DEFAULT 0,
    ninth_grade_res integer DEFAULT 0,
    restriction_note character varying(100)
);


ALTER TABLE public.restricted_slots_progression OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 27189)
-- Name: restricted_slots_progression_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.restricted_slots_progression_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.restricted_slots_progression_id_seq OWNER TO postgres;

--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 291
-- Name: restricted_slots_progression_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.restricted_slots_progression_id_seq OWNED BY public.restricted_slots_progression.id;


--
-- TOC entry 255 (class 1259 OID 26395)
-- Name: rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rules (
    id integer NOT NULL,
    category text NOT NULL,
    subcategory text,
    name text NOT NULL,
    description text NOT NULL,
    source_id integer,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.rules OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 26402)
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
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 256
-- Name: rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rules_id_seq OWNED BY public.rules.id;


--
-- TOC entry 257 (class 1259 OID 26404)
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
    last_updated timestamp with time zone DEFAULT now(),
    is_psionic boolean DEFAULT false NOT NULL,
    properties jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 26413)
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
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 258
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.skills_id_seq OWNED BY public.skills.id;


--
-- TOC entry 259 (class 1259 OID 26415)
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
-- TOC entry 260 (class 1259 OID 26422)
-- Name: source_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.source_tables (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    table_data jsonb NOT NULL
);


ALTER TABLE public.source_tables OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 26428)
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
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 261
-- Name: source_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.source_tables_id_seq OWNED BY public.source_tables.id;


--
-- TOC entry 262 (class 1259 OID 26430)
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
-- TOC entry 263 (class 1259 OID 26437)
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
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 263
-- Name: sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sources_id_seq OWNED BY public.source_entries.id;


--
-- TOC entry 264 (class 1259 OID 26439)
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
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 264
-- Name: sources_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sources_id_seq1 OWNED BY public.sources.id;


--
-- TOC entry 265 (class 1259 OID 26441)
-- Name: spell_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spell_levels (
    spell_id integer NOT NULL,
    level integer,
    class_id integer NOT NULL
);


ALTER TABLE public.spell_levels OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 26444)
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
    last_updated timestamp with time zone DEFAULT now(),
    area text,
    effect text,
    mechanics jsonb
);


ALTER TABLE public.spells OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 26461)
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
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 267
-- Name: spells_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spells_id_seq OWNED BY public.spells.id;


--
-- TOC entry 268 (class 1259 OID 26463)
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
-- TOC entry 269 (class 1259 OID 26467)
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
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 269
-- Name: spells_known_progression_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spells_known_progression_id_seq OWNED BY public.spells_known_progression.id;


--
-- TOC entry 290 (class 1259 OID 27175)
-- Name: spells_per_day_progression; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spells_per_day_progression (
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
    CONSTRAINT spells_per_day_progression_level_check CHECK (((level >= 1) AND (level <= 20)))
);


ALTER TABLE public.spells_per_day_progression OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 27173)
-- Name: spells_per_day_progression_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.spells_per_day_progression_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.spells_per_day_progression_id_seq OWNER TO postgres;

--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 289
-- Name: spells_per_day_progression_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spells_per_day_progression_id_seq OWNED BY public.spells_per_day_progression.id;


--
-- TOC entry 270 (class 1259 OID 26469)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password_hash text NOT NULL,
    email text,
    created_at timestamp with time zone DEFAULT now(),
    last_login timestamp with time zone,
    role character varying(20) DEFAULT 'player'::character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 26477)
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
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 271
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 277 (class 1259 OID 26543)
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
-- TOC entry 313 (class 1259 OID 27562)
-- Name: view_adventurer_detailed_export; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_adventurer_detailed_export AS
 SELECT a.id AS adventurer_id,
    a.user_id,
    a.name,
    row_to_json(a.*) AS base_stats,
    row_to_json(r.*) AS race_details,
    ( SELECT COALESCE(json_agg(json_build_object('adventurer_class_info', row_to_json(ac.*), 'class_details', row_to_json(c.*))), '[]'::json) AS "coalesce"
           FROM (public.adventurer_classes ac
             JOIN public.classes c ON ((ac.class_id = c.id)))
          WHERE (ac.adventurer_id = a.id)) AS classes,
    ( SELECT COALESCE(json_agg(json_build_object('adventurer_skill_info', row_to_json(ask.*), 'skill_details', row_to_json(s.*))), '[]'::json) AS "coalesce"
           FROM (public.adventurer_skills ask
             JOIN public.skills s ON ((ask.skill_id = s.id)))
          WHERE (ask.adventurer_id = a.id)) AS skills,
    ( SELECT COALESCE(json_agg(json_build_object('adventurer_feat_info', row_to_json(af.*), 'feat_details', row_to_json(f.*))), '[]'::json) AS "coalesce"
           FROM (public.adventurer_feats af
             JOIN public.feats f ON ((af.feat_id = f.id)))
          WHERE (af.adventurer_id = a.id)) AS feats,
    ( SELECT COALESCE(json_agg(json_build_object('instance_info', row_to_json(aw.*), 'base_item', row_to_json(i.*), 'weapon_stats', row_to_json(wp.*), 'damage_scaling', row_to_json(ds.*), 'critical_stats', row_to_json(cc.*), 'enchantments', ( SELECT COALESCE(json_agg(row_to_json(enc.*)), '[]'::json) AS "coalesce"
                   FROM public.enchantments enc
                  WHERE (enc.id = ANY (aw.enchantment_ids))))), '[]'::json) AS "coalesce"
           FROM ((((public.adventurer_weapons aw
             JOIN public.items i ON ((aw.item_id = i.id)))
             LEFT JOIN public.weapon_properties wp ON ((i.weapon_stats_id = wp.id)))
             LEFT JOIN public.damage_scaling ds ON ((wp.damage_id = ds.id)))
             LEFT JOIN public.critical_combinations cc ON ((wp.critical_id = cc.id)))
          WHERE (aw.adventurer_id = a.id)) AS weapons,
    ( SELECT COALESCE(json_agg(json_build_object('instance_info', row_to_json(aa.*), 'base_item', row_to_json(i.*), 'armor_stats', row_to_json(ap.*), 'enchantments', ( SELECT COALESCE(json_agg(row_to_json(enc.*)), '[]'::json) AS "coalesce"
                   FROM public.enchantments enc
                  WHERE (enc.id = ANY (aa.enchantment_ids))))), '[]'::json) AS "coalesce"
           FROM ((public.adventurer_armor aa
             JOIN public.items i ON ((aa.item_id = i.id)))
             LEFT JOIN public.armor_properties ap ON ((i.armor_stats_id = ap.id)))
          WHERE (aa.adventurer_id = a.id)) AS armor,
    ( SELECT COALESCE(json_agg(json_build_object('instance_info', row_to_json(ag.*), 'base_item', row_to_json(i.*), 'enchantments', ( SELECT COALESCE(json_agg(row_to_json(enc.*)), '[]'::json) AS "coalesce"
                   FROM public.enchantments enc
                  WHERE (enc.id = ANY (ag.enchantment_ids))))), '[]'::json) AS "coalesce"
           FROM (public.adventurer_gear ag
             JOIN public.items i ON ((ag.item_id = i.id)))
          WHERE (ag.adventurer_id = a.id)) AS gear,
    ( SELECT COALESCE(json_agg(json_build_object('instance_info', row_to_json(ai.*), 'base_item', row_to_json(i.*))), '[]'::json) AS "coalesce"
           FROM (public.adventurer_items ai
             JOIN public.items i ON ((ai.item_id = i.id)))
          WHERE (ai.adventurer_id = a.id)) AS items,
    ( SELECT COALESCE(json_agg(json_build_object('adventurer_spell_info', row_to_json(asp.*), 'spell_details', row_to_json(sp.*))), '[]'::json) AS "coalesce"
           FROM (public.adventurer_spells asp
             JOIN public.spells sp ON ((asp.spell_id = sp.id)))
          WHERE (asp.adventurer_id = a.id)) AS spells,
    ( SELECT COALESCE(json_agg(row_to_json(ass.*)), '[]'::json) AS "coalesce"
           FROM public.adventurer_spell_slots ass
          WHERE (ass.adventurer_id = a.id)) AS spell_slots
   FROM (public.adventurers a
     LEFT JOIN public.races r ON ((a.race_id = r.id)));


ALTER VIEW public.view_adventurer_detailed_export OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 27552)
-- Name: view_adventurer_overview; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_adventurer_overview AS
 SELECT a.id AS adventurer_id,
    a.user_id,
    a.name,
    COALESCE(string_agg(((c.name || ' '::text) || ac.class_level), ' / '::text), 'No Class'::text) AS class_summary,
    COALESCE(sum(ac.class_level), (0)::bigint) AS total_level
   FROM ((public.adventurers a
     LEFT JOIN public.adventurer_classes ac ON ((a.id = ac.adventurer_id)))
     LEFT JOIN public.classes c ON ((ac.class_id = c.id)))
  GROUP BY a.id, a.user_id, a.name;


ALTER VIEW public.view_adventurer_overview OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 26512)
-- Name: view_class_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_class_details AS
 SELECT c.id,
    c.name,
    c.is_prestige,
    c.skill_points,
    c.alignment,
    c.num_dice,
    c.dice_type,
    c.main_attr,
    src.name AS book_name,
    src.abbreviation AS book_abbr,
    se.page
   FROM ((public.classes c
     LEFT JOIN public.source_entries se ON ((c.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_class_details OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 26517)
-- Name: view_class_search; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_class_search AS
 SELECT c.id,
    c.name,
    c.main_attr,
    src.name AS book_name
   FROM ((public.classes c
     LEFT JOIN public.source_entries se ON ((c.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_class_search OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 26521)
-- Name: view_condition_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_condition_details AS
 SELECT c.id,
    c.name,
    c.description,
    src.name AS book_name,
    src.abbreviation AS book_abbr,
    se.page
   FROM ((public.conditions c
     LEFT JOIN public.source_entries se ON ((c.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_condition_details OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 26525)
-- Name: view_condition_search; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_condition_search AS
 SELECT c.id,
    c.name,
    src.name AS book_name
   FROM ((public.conditions c
     LEFT JOIN public.source_entries se ON ((c.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_condition_search OWNER TO postgres;

--
-- TOC entry 298 (class 1259 OID 27351)
-- Name: view_feat_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_feat_details AS
 SELECT f.id,
    f.name,
    f.feat_type,
    f.benefit,
    f.normal,
    f.special,
    f.choice_text,
    f.is_multiple,
    f.is_stack,
    src.name AS source_name,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('attribute', p.key, 'value', p.value, 'set_index', p.set_index) ORDER BY p.set_index, p.key) AS jsonb_agg
           FROM public.feat_prereq_numeric p
          WHERE ((p.feat_id = f.id) AND (p.category = 'ATTRIBUTE'::text))), '[]'::jsonb) AS prereq_attributes,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('skill', p.key, 'ranks', p.value, 'set_index', p.set_index) ORDER BY p.set_index, p.key) AS jsonb_agg
           FROM public.feat_prereq_numeric p
          WHERE ((p.feat_id = f.id) AND (p.category = 'SKILL'::text))), '[]'::jsonb) AS prereq_skills,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('id', pf.id, 'name', pf.name, 'set_index', pp.set_index) ORDER BY pp.set_index, pf.name) AS jsonb_agg
           FROM (public.feat_prereq_feat pp
             JOIN public.feats pf ON ((pp.prereq_feat_id = pf.id)))
          WHERE (pp.feat_id = f.id)), '[]'::jsonb) AS prereq_feats,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('stat', p.key, 'value', p.value, 'set_index', p.set_index) ORDER BY p.set_index, p.key) AS jsonb_agg
           FROM public.feat_prereq_numeric p
          WHERE ((p.feat_id = f.id) AND (p.category = 'STAT'::text))), '[]'::jsonb) AS prereq_stats,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('type', p.category, 'name', p.key, 'value', p.value, 'set_index', p.set_index) ORDER BY p.set_index, p.key) AS jsonb_agg
           FROM public.feat_prereq_numeric p
          WHERE ((p.feat_id = f.id) AND (p.category <> ALL (ARRAY['ATTRIBUTE'::text, 'SKILL'::text, 'STAT'::text])))), '[]'::jsonb) AS prereq_other_numeric,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('requirement', p.requirement, 'set_index', p.set_index) ORDER BY p.set_index) AS jsonb_agg
           FROM public.feat_prereq_special p
          WHERE (p.feat_id = f.id)), '[]'::jsonb) AS prereq_special
   FROM ((public.feats f
     LEFT JOIN public.source_entries se ON ((f.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_feat_details OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 26534)
-- Name: view_feat_search; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_feat_search AS
 SELECT f.id,
    f.name,
    f.feat_type,
    src.name AS book_name
   FROM ((public.feats f
     LEFT JOIN public.source_entries se ON ((f.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_feat_search OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 26556)
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
    m.description,
    m.num_dice,
    m.dice_type,
    m.bonus,
    src.name AS book_name,
    src.abbreviation AS book_abbr,
    se.page
   FROM ((public.monsters m
     LEFT JOIN public.source_entries se ON ((m.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_monster_details OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 26561)
-- Name: view_monster_search; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_monster_search AS
 SELECT m.id,
    m.name,
    m.type,
    src.name AS book_name
   FROM ((public.monsters m
     LEFT JOIN public.source_entries se ON ((m.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_monster_search OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 26565)
-- Name: view_race_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_race_details AS
 SELECT r.id,
    r.name,
    r.size,
    r.speed,
    r.type,
    r.personality,
    r.physical_description,
    r.relations,
    r.alignment,
    r.lands,
    r.religion,
    r.language,
    r.names,
    r.adventurers,
    src.name AS book_name,
    src.abbreviation AS book_abbr,
    se.page
   FROM ((public.races r
     LEFT JOIN public.source_entries se ON ((r.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_race_details OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 26570)
-- Name: view_race_search; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_race_search AS
 SELECT r.id,
    r.name,
    r.type,
    r.size,
    src.name AS book_name
   FROM ((public.races r
     LEFT JOIN public.source_entries se ON ((r.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_race_search OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 26575)
-- Name: view_rule_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_rule_details AS
 SELECT r.id,
    r.category,
    r.subcategory,
    r.name,
    r.description,
    src.name AS book_name,
    src.abbreviation AS book_abbr,
    se.page
   FROM ((public.rules r
     LEFT JOIN public.source_entries se ON ((r.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_rule_details OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 26579)
-- Name: view_rule_search; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_rule_search AS
 SELECT r.id,
    r.name,
    r.category,
    src.name AS book_name
   FROM ((public.rules r
     LEFT JOIN public.source_entries se ON ((r.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_rule_search OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 27304)
-- Name: view_skill_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_skill_details AS
 SELECT s.id,
    s.name,
    s.key_attribute,
    s.trained_only,
    s.armor_check_penalty,
    s.is_psionic,
    s.description,
    s.properties,
    src.name AS book_name,
    src.abbreviation AS book_abbr,
    se.page
   FROM ((public.skills s
     LEFT JOIN public.source_entries se ON ((s.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_skill_details OWNER TO postgres;

--
-- TOC entry 284 (class 1259 OID 26588)
-- Name: view_skill_search; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_skill_search AS
 SELECT s.id,
    s.name,
    s.key_attribute,
    src.name AS book_name
   FROM ((public.skills s
     LEFT JOIN public.source_entries se ON ((s.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_skill_search OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 26592)
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
    s.area,
    s.effect,
    s.mechanics,
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
    se.page,
    src.name AS book_name,
    src.abbreviation AS book_abbr,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('class', c.name, 'level', sl.level)) AS jsonb_agg
           FROM (public.spell_levels sl
             JOIN public.classes c ON ((sl.class_id = c.id)))
          WHERE (sl.spell_id = s.id)), '[]'::jsonb) AS classes,
    COALESCE(( SELECT jsonb_agg(jsonb_build_object('domain', d.name, 'level', ds.level)) AS jsonb_agg
           FROM (public.domain_spells ds
             JOIN public.domains d ON ((ds.domain_id = d.id)))
          WHERE (ds.spell_id = s.id)), '[]'::jsonb) AS domains
   FROM ((public.spells s
     JOIN public.source_entries se ON ((s.source_id = se.id)))
     JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_spell_details OWNER TO postgres;

--
-- TOC entry 286 (class 1259 OID 26597)
-- Name: view_spell_search; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_spell_search AS
 SELECT s.id,
    s.name,
    s.school,
    src.name AS book_name
   FROM ((public.spells s
     LEFT JOIN public.source_entries se ON ((s.source_id = se.id)))
     LEFT JOIN public.sources src ON ((se.book_id = src.id)));


ALTER VIEW public.view_spell_search OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 26607)
-- Name: weapon_damage_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weapon_damage_type (
    weapon_properties_id integer NOT NULL,
    damage_type_id integer NOT NULL
);


ALTER TABLE public.weapon_damage_type OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 26610)
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
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 288
-- Name: weapon_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.weapon_properties_id_seq OWNED BY public.weapon_properties.id;


--
-- TOC entry 3426 (class 2604 OID 27479)
-- Name: adventurer_armor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_armor ALTER COLUMN id SET DEFAULT nextval('public.adventurer_armor_id_seq'::regclass);


--
-- TOC entry 3315 (class 2604 OID 26613)
-- Name: adventurer_feats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_feats ALTER COLUMN id SET DEFAULT nextval('public.adventurer_feats_id_seq'::regclass);


--
-- TOC entry 3433 (class 2604 OID 27506)
-- Name: adventurer_gear id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_gear ALTER COLUMN id SET DEFAULT nextval('public.adventurer_gear_id_seq'::regclass);


--
-- TOC entry 3439 (class 2604 OID 27532)
-- Name: adventurer_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_items ALTER COLUMN id SET DEFAULT nextval('public.adventurer_items_id_seq'::regclass);


--
-- TOC entry 3317 (class 2604 OID 26615)
-- Name: adventurer_skills id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_skills ALTER COLUMN id SET DEFAULT nextval('public.adventurer_skills_id_seq'::regclass);


--
-- TOC entry 3318 (class 2604 OID 26616)
-- Name: adventurer_spell_slots id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_spell_slots ALTER COLUMN id SET DEFAULT nextval('public.adventurer_spell_slots_id_seq'::regclass);


--
-- TOC entry 3320 (class 2604 OID 26617)
-- Name: adventurer_spells id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_spells ALTER COLUMN id SET DEFAULT nextval('public.adventurer_spells_id_seq'::regclass);


--
-- TOC entry 3419 (class 2604 OID 27452)
-- Name: adventurer_weapons id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_weapons ALTER COLUMN id SET DEFAULT nextval('public.adventurer_weapons_id_seq'::regclass);


--
-- TOC entry 3324 (class 2604 OID 26619)
-- Name: adventurers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurers ALTER COLUMN id SET DEFAULT nextval('public.adventurers_id_seq'::regclass);


--
-- TOC entry 3333 (class 2604 OID 26620)
-- Name: armor_properties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.armor_properties ALTER COLUMN id SET DEFAULT nextval('public.armor_properties_id_seq'::regclass);


--
-- TOC entry 3335 (class 2604 OID 26621)
-- Name: body_slots id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_slots ALTER COLUMN id SET DEFAULT nextval('public.body_slots_id_seq'::regclass);


--
-- TOC entry 3336 (class 2604 OID 26622)
-- Name: bonus_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus_types ALTER COLUMN id SET DEFAULT nextval('public.bonus_types_id_seq'::regclass);


--
-- TOC entry 3337 (class 2604 OID 26624)
-- Name: class_description_sections id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_description_sections ALTER COLUMN id SET DEFAULT nextval('public.class_description_sections_id_seq'::regclass);


--
-- TOC entry 3338 (class 2604 OID 26625)
-- Name: class_features id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_features ALTER COLUMN id SET DEFAULT nextval('public.class_features_id_seq'::regclass);


--
-- TOC entry 3339 (class 2604 OID 26626)
-- Name: class_progression id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_progression ALTER COLUMN id SET DEFAULT nextval('public.class_progression_id_seq'::regclass);


--
-- TOC entry 3340 (class 2604 OID 26627)
-- Name: classes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes ALTER COLUMN id SET DEFAULT nextval('public.classes_id_seq'::regclass);


--
-- TOC entry 3344 (class 2604 OID 26628)
-- Name: conditions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions ALTER COLUMN id SET DEFAULT nextval('public.conditions_id_seq'::regclass);


--
-- TOC entry 3346 (class 2604 OID 26629)
-- Name: damage_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.damage_types ALTER COLUMN id SET DEFAULT nextval('public.damage_type_id_seq'::regclass);


--
-- TOC entry 3347 (class 2604 OID 26630)
-- Name: domains id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domains ALTER COLUMN id SET DEFAULT nextval('public.domains_id_seq'::regclass);


--
-- TOC entry 3413 (class 2604 OID 27410)
-- Name: enchantments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantments ALTER COLUMN id SET DEFAULT nextval('public.enchantments_id_seq'::regclass);


--
-- TOC entry 3348 (class 2604 OID 26632)
-- Name: entity_tables id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tables ALTER COLUMN id SET DEFAULT nextval('public.entity_tables_id_seq'::regclass);


--
-- TOC entry 3349 (class 2604 OID 26633)
-- Name: entity_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types ALTER COLUMN id SET DEFAULT nextval('public.entity_types_id_seq'::regclass);


--
-- TOC entry 3351 (class 2604 OID 26635)
-- Name: feat_prereq_feat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_feat ALTER COLUMN id SET DEFAULT nextval('public.feat_prereq_feat_id_seq'::regclass);


--
-- TOC entry 3405 (class 2604 OID 27316)
-- Name: feat_prereq_numeric id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_numeric ALTER COLUMN id SET DEFAULT nextval('public.feat_prereq_numeric_id_seq'::regclass);


--
-- TOC entry 3407 (class 2604 OID 27333)
-- Name: feat_prereq_special id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_special ALTER COLUMN id SET DEFAULT nextval('public.feat_prereq_special_id_seq'::regclass);


--
-- TOC entry 3353 (class 2604 OID 26637)
-- Name: feats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feats ALTER COLUMN id SET DEFAULT nextval('public.feats_id_seq'::regclass);


--
-- TOC entry 3357 (class 2604 OID 26638)
-- Name: item_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_types ALTER COLUMN id SET DEFAULT nextval('public.item_types_id_seq'::regclass);


--
-- TOC entry 3409 (class 2604 OID 27362)
-- Name: items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- TOC entry 3358 (class 2604 OID 26640)
-- Name: monsters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monsters ALTER COLUMN id SET DEFAULT nextval('public.monsters_id_seq'::regclass);


--
-- TOC entry 3360 (class 2604 OID 26641)
-- Name: npcs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npcs ALTER COLUMN id SET DEFAULT nextval('public.npcs_id_seq'::regclass);


--
-- TOC entry 3361 (class 2604 OID 26642)
-- Name: race_features id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.race_features ALTER COLUMN id SET DEFAULT nextval('public.race_features_id_seq'::regclass);


--
-- TOC entry 3362 (class 2604 OID 26643)
-- Name: races id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.races ALTER COLUMN id SET DEFAULT nextval('public.races_id_seq'::regclass);


--
-- TOC entry 3395 (class 2604 OID 27194)
-- Name: restricted_slots_progression id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restricted_slots_progression ALTER COLUMN id SET DEFAULT nextval('public.restricted_slots_progression_id_seq'::regclass);


--
-- TOC entry 3364 (class 2604 OID 26644)
-- Name: rules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rules ALTER COLUMN id SET DEFAULT nextval('public.rules_id_seq'::regclass);


--
-- TOC entry 3366 (class 2604 OID 26645)
-- Name: skills id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills ALTER COLUMN id SET DEFAULT nextval('public.skills_id_seq'::regclass);


--
-- TOC entry 3372 (class 2604 OID 26646)
-- Name: source_entries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_entries ALTER COLUMN id SET DEFAULT nextval('public.sources_id_seq'::regclass);


--
-- TOC entry 3374 (class 2604 OID 26647)
-- Name: source_tables id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_tables ALTER COLUMN id SET DEFAULT nextval('public.source_tables_id_seq'::regclass);


--
-- TOC entry 3375 (class 2604 OID 26648)
-- Name: sources id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sources ALTER COLUMN id SET DEFAULT nextval('public.sources_id_seq1'::regclass);


--
-- TOC entry 3377 (class 2604 OID 26649)
-- Name: spells id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells ALTER COLUMN id SET DEFAULT nextval('public.spells_id_seq'::regclass);


--
-- TOC entry 3389 (class 2604 OID 26650)
-- Name: spells_known_progression id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_known_progression ALTER COLUMN id SET DEFAULT nextval('public.spells_known_progression_id_seq'::regclass);


--
-- TOC entry 3394 (class 2604 OID 27178)
-- Name: spells_per_day_progression id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_per_day_progression ALTER COLUMN id SET DEFAULT nextval('public.spells_per_day_progression_id_seq'::regclass);


--
-- TOC entry 3390 (class 2604 OID 26651)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3393 (class 2604 OID 26652)
-- Name: weapon_properties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_properties ALTER COLUMN id SET DEFAULT nextval('public.weapon_properties_id_seq'::regclass);


--
-- TOC entry 3603 (class 2606 OID 27490)
-- Name: adventurer_armor adventurer_armor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_armor
    ADD CONSTRAINT adventurer_armor_pkey PRIMARY KEY (id);


--
-- TOC entry 3605 (class 2606 OID 27516)
-- Name: adventurer_gear adventurer_gear_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_gear
    ADD CONSTRAINT adventurer_gear_pkey PRIMARY KEY (id);


--
-- TOC entry 3607 (class 2606 OID 27539)
-- Name: adventurer_items adventurer_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_items
    ADD CONSTRAINT adventurer_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3601 (class 2606 OID 27463)
-- Name: adventurer_weapons adventurer_weapons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_weapons
    ADD CONSTRAINT adventurer_weapons_pkey PRIMARY KEY (id);


--
-- TOC entry 3467 (class 2606 OID 26702)
-- Name: armor_properties armor_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.armor_properties
    ADD CONSTRAINT armor_properties_pkey PRIMARY KEY (id);


--
-- TOC entry 3469 (class 2606 OID 26704)
-- Name: body_slots body_slots_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_slots
    ADD CONSTRAINT body_slots_name_key UNIQUE (name);


--
-- TOC entry 3471 (class 2606 OID 26706)
-- Name: body_slots body_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_slots
    ADD CONSTRAINT body_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 3473 (class 2606 OID 26708)
-- Name: bonus_types bonus_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus_types
    ADD CONSTRAINT bonus_types_name_key UNIQUE (name);


--
-- TOC entry 3475 (class 2606 OID 26710)
-- Name: bonus_types bonus_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus_types
    ADD CONSTRAINT bonus_types_pkey PRIMARY KEY (id);


--
-- TOC entry 3448 (class 2606 OID 26718)
-- Name: adventurer_classes character_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_classes
    ADD CONSTRAINT character_classes_pkey PRIMARY KEY (adventurer_id, class_id);


--
-- TOC entry 3451 (class 2606 OID 26720)
-- Name: adventurer_feats character_feats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_feats
    ADD CONSTRAINT character_feats_pkey PRIMARY KEY (id);


--
-- TOC entry 3454 (class 2606 OID 26724)
-- Name: adventurer_skills character_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_skills
    ADD CONSTRAINT character_skills_pkey PRIMARY KEY (id);


--
-- TOC entry 3457 (class 2606 OID 26726)
-- Name: adventurer_spell_slots character_spell_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_spell_slots
    ADD CONSTRAINT character_spell_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 3461 (class 2606 OID 26728)
-- Name: adventurer_spells character_spells_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_spells
    ADD CONSTRAINT character_spells_pkey PRIMARY KEY (id);


--
-- TOC entry 3464 (class 2606 OID 26732)
-- Name: adventurers characters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurers
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- TOC entry 3477 (class 2606 OID 26734)
-- Name: class_description_sections class_description_sections_class_id_section_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_description_sections
    ADD CONSTRAINT class_description_sections_class_id_section_name_key UNIQUE (class_id, section_name);


--
-- TOC entry 3479 (class 2606 OID 26736)
-- Name: class_description_sections class_description_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_description_sections
    ADD CONSTRAINT class_description_sections_pkey PRIMARY KEY (id);


--
-- TOC entry 3481 (class 2606 OID 26738)
-- Name: class_features class_features_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_features
    ADD CONSTRAINT class_features_pkey PRIMARY KEY (id);


--
-- TOC entry 3483 (class 2606 OID 26740)
-- Name: class_progression class_progression_class_id_level_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_progression
    ADD CONSTRAINT class_progression_class_id_level_key UNIQUE (class_id, level);


--
-- TOC entry 3485 (class 2606 OID 26742)
-- Name: class_progression class_progression_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_progression
    ADD CONSTRAINT class_progression_pkey PRIMARY KEY (id);


--
-- TOC entry 3487 (class 2606 OID 26744)
-- Name: class_skills class_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_skills
    ADD CONSTRAINT class_skills_pkey PRIMARY KEY (class_id, skill_id);


--
-- TOC entry 3489 (class 2606 OID 26746)
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- TOC entry 3492 (class 2606 OID 26748)
-- Name: conditions conditions_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_name_key UNIQUE (name);


--
-- TOC entry 3494 (class 2606 OID 26750)
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- TOC entry 3496 (class 2606 OID 26752)
-- Name: critical_combinations critical_combinations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.critical_combinations
    ADD CONSTRAINT critical_combinations_pkey PRIMARY KEY (id);


--
-- TOC entry 3498 (class 2606 OID 26754)
-- Name: damage_scaling damage_scaling_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.damage_scaling
    ADD CONSTRAINT damage_scaling_pkey PRIMARY KEY (id);


--
-- TOC entry 3500 (class 2606 OID 26756)
-- Name: damage_types damage_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.damage_types
    ADD CONSTRAINT damage_type_name_key UNIQUE (name);


--
-- TOC entry 3502 (class 2606 OID 26758)
-- Name: damage_types damage_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.damage_types
    ADD CONSTRAINT damage_type_pkey PRIMARY KEY (id);


--
-- TOC entry 3504 (class 2606 OID 26760)
-- Name: domain_spells domain_spells_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_spells
    ADD CONSTRAINT domain_spells_pkey PRIMARY KEY (domain_id, spell_id);


--
-- TOC entry 3506 (class 2606 OID 26762)
-- Name: domains domains_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_name_key UNIQUE (name);


--
-- TOC entry 3508 (class 2606 OID 26764)
-- Name: domains domains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- TOC entry 3599 (class 2606 OID 27436)
-- Name: enchantment_applicable_to enchantment_applicable_to_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantment_applicable_to
    ADD CONSTRAINT enchantment_applicable_to_pkey PRIMARY KEY (enchantment_id, item_type_id);


--
-- TOC entry 3597 (class 2606 OID 27421)
-- Name: enchantments enchantments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantments
    ADD CONSTRAINT enchantments_pkey PRIMARY KEY (id);


--
-- TOC entry 3510 (class 2606 OID 26770)
-- Name: entity_tables entity_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tables
    ADD CONSTRAINT entity_tables_pkey PRIMARY KEY (id);


--
-- TOC entry 3512 (class 2606 OID 26772)
-- Name: entity_types entity_types_display_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_display_name_key UNIQUE (display_name);


--
-- TOC entry 3514 (class 2606 OID 26774)
-- Name: entity_types entity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_pkey PRIMARY KEY (id);


--
-- TOC entry 3516 (class 2606 OID 26776)
-- Name: entity_types entity_types_table_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_types
    ADD CONSTRAINT entity_types_table_name_key UNIQUE (table_name);


--
-- TOC entry 3518 (class 2606 OID 26780)
-- Name: feat_prereq_feat feat_prereq_feat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_feat
    ADD CONSTRAINT feat_prereq_feat_pkey PRIMARY KEY (id);


--
-- TOC entry 3588 (class 2606 OID 27322)
-- Name: feat_prereq_numeric feat_prereq_numeric_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_numeric
    ADD CONSTRAINT feat_prereq_numeric_pkey PRIMARY KEY (id);


--
-- TOC entry 3590 (class 2606 OID 27339)
-- Name: feat_prereq_special feat_prereq_special_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_special
    ADD CONSTRAINT feat_prereq_special_pkey PRIMARY KEY (id);


--
-- TOC entry 3520 (class 2606 OID 26784)
-- Name: feats feats_name_source_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feats
    ADD CONSTRAINT feats_name_source_id_key UNIQUE (name, source_id);


--
-- TOC entry 3522 (class 2606 OID 26786)
-- Name: feats feats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feats
    ADD CONSTRAINT feats_pkey PRIMARY KEY (id);


--
-- TOC entry 3526 (class 2606 OID 26788)
-- Name: item_types item_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_types
    ADD CONSTRAINT item_types_name_key UNIQUE (name);


--
-- TOC entry 3528 (class 2606 OID 26790)
-- Name: item_types item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- TOC entry 3595 (class 2606 OID 27371)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 3533 (class 2606 OID 26794)
-- Name: monsters monsters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monsters
    ADD CONSTRAINT monsters_pkey PRIMARY KEY (id);


--
-- TOC entry 3535 (class 2606 OID 26796)
-- Name: npcs npcs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npcs
    ADD CONSTRAINT npcs_pkey PRIMARY KEY (id);


--
-- TOC entry 3537 (class 2606 OID 26798)
-- Name: race_features race_features_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.race_features
    ADD CONSTRAINT race_features_pkey PRIMARY KEY (id);


--
-- TOC entry 3540 (class 2606 OID 26800)
-- Name: races races_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_pkey PRIMARY KEY (id);


--
-- TOC entry 3586 (class 2606 OID 27205)
-- Name: restricted_slots_progression restricted_slots_progression_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restricted_slots_progression
    ADD CONSTRAINT restricted_slots_progression_pkey PRIMARY KEY (id);


--
-- TOC entry 3543 (class 2606 OID 26802)
-- Name: rules rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- TOC entry 3547 (class 2606 OID 26804)
-- Name: skills skills_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_name_key UNIQUE (name);


--
-- TOC entry 3549 (class 2606 OID 26806)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 3555 (class 2606 OID 26808)
-- Name: source_tables source_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_tables
    ADD CONSTRAINT source_tables_pkey PRIMARY KEY (id);


--
-- TOC entry 3551 (class 2606 OID 26810)
-- Name: source_entries sources_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_entries
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- TOC entry 3557 (class 2606 OID 26812)
-- Name: sources sources_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_pkey1 PRIMARY KEY (id);


--
-- TOC entry 3559 (class 2606 OID 26814)
-- Name: spell_levels spell_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spell_levels
    ADD CONSTRAINT spell_levels_pkey PRIMARY KEY (class_id, spell_id);


--
-- TOC entry 3568 (class 2606 OID 26816)
-- Name: spells_known_progression spells_known_progression_class_id_level_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_known_progression
    ADD CONSTRAINT spells_known_progression_class_id_level_key UNIQUE (class_id, level);


--
-- TOC entry 3570 (class 2606 OID 26818)
-- Name: spells_known_progression spells_known_progression_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_known_progression
    ADD CONSTRAINT spells_known_progression_pkey PRIMARY KEY (id);


--
-- TOC entry 3564 (class 2606 OID 26820)
-- Name: spells spells_name_source_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells
    ADD CONSTRAINT spells_name_source_id_key UNIQUE (name, source_id);


--
-- TOC entry 3582 (class 2606 OID 27181)
-- Name: spells_per_day_progression spells_per_day_progression_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_per_day_progression
    ADD CONSTRAINT spells_per_day_progression_pkey PRIMARY KEY (id);


--
-- TOC entry 3566 (class 2606 OID 26822)
-- Name: spells spells_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells
    ADD CONSTRAINT spells_pkey PRIMARY KEY (id);


--
-- TOC entry 3553 (class 2606 OID 26824)
-- Name: source_entries unique_book_page; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_entries
    ADD CONSTRAINT unique_book_page UNIQUE (book_id, page);


--
-- TOC entry 3459 (class 2606 OID 26826)
-- Name: adventurer_spell_slots unique_char_slot_level; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_spell_slots
    ADD CONSTRAINT unique_char_slot_level UNIQUE (adventurer_id, spell_level);


--
-- TOC entry 3584 (class 2606 OID 27183)
-- Name: spells_per_day_progression uq_class_level_per_day; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_per_day_progression
    ADD CONSTRAINT uq_class_level_per_day UNIQUE (class_id, level);


--
-- TOC entry 3572 (class 2606 OID 26828)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3574 (class 2606 OID 26830)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3576 (class 2606 OID 26832)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3580 (class 2606 OID 26834)
-- Name: weapon_damage_type weapon_damage_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_damage_type
    ADD CONSTRAINT weapon_damage_type_pkey PRIMARY KEY (weapon_properties_id, damage_type_id);


--
-- TOC entry 3578 (class 2606 OID 26836)
-- Name: weapon_properties weapon_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_properties
    ADD CONSTRAINT weapon_properties_pkey PRIMARY KEY (id);


--
-- TOC entry 3449 (class 1259 OID 26837)
-- Name: idx_character_classes_char_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_classes_char_id ON public.adventurer_classes USING btree (adventurer_id);


--
-- TOC entry 3452 (class 1259 OID 26838)
-- Name: idx_character_feats_char_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_feats_char_id ON public.adventurer_feats USING btree (adventurer_id);


--
-- TOC entry 3455 (class 1259 OID 26839)
-- Name: idx_character_skills_char_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_skills_char_id ON public.adventurer_skills USING btree (adventurer_id);


--
-- TOC entry 3462 (class 1259 OID 26840)
-- Name: idx_character_spells_char_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_character_spells_char_id ON public.adventurer_spells USING btree (adventurer_id);


--
-- TOC entry 3465 (class 1259 OID 26841)
-- Name: idx_characters_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_characters_user_id ON public.adventurers USING btree (user_id);


--
-- TOC entry 3490 (class 1259 OID 26842)
-- Name: idx_classes_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classes_name_lower ON public.classes USING btree (lower(name));


--
-- TOC entry 3523 (class 1259 OID 26844)
-- Name: idx_feats_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feats_name_lower ON public.feats USING btree (lower(name));


--
-- TOC entry 3524 (class 1259 OID 26845)
-- Name: idx_feats_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feats_source_id ON public.feats USING btree (source_id);


--
-- TOC entry 3591 (class 1259 OID 27404)
-- Name: idx_items_enchantments; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_enchantments ON public.items USING gin (enchantment_ids);


--
-- TOC entry 3592 (class 1259 OID 27402)
-- Name: idx_items_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_name ON public.items USING btree (name);


--
-- TOC entry 3593 (class 1259 OID 27403)
-- Name: idx_items_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_type ON public.items USING btree (item_type_id);


--
-- TOC entry 3529 (class 1259 OID 26851)
-- Name: idx_monsters_cr_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_monsters_cr_number ON public.monsters USING btree (cr_number);


--
-- TOC entry 3530 (class 1259 OID 26852)
-- Name: idx_monsters_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_monsters_name_lower ON public.monsters USING btree (lower(name));


--
-- TOC entry 3531 (class 1259 OID 26853)
-- Name: idx_monsters_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_monsters_type ON public.monsters USING btree (type);


--
-- TOC entry 3538 (class 1259 OID 26854)
-- Name: idx_races_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_races_name_lower ON public.races USING btree (lower(name));


--
-- TOC entry 3541 (class 1259 OID 26855)
-- Name: idx_rules_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rules_category ON public.rules USING btree (category);


--
-- TOC entry 3544 (class 1259 OID 26856)
-- Name: idx_skills_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_skills_name_lower ON public.skills USING btree (lower(name));


--
-- TOC entry 3545 (class 1259 OID 27213)
-- Name: idx_skills_properties; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_skills_properties ON public.skills USING gin (properties);


--
-- TOC entry 3560 (class 1259 OID 26857)
-- Name: idx_spells_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_spells_name_lower ON public.spells USING btree (lower(name));


--
-- TOC entry 3561 (class 1259 OID 26858)
-- Name: idx_spells_school; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_spells_school ON public.spells USING btree (school);


--
-- TOC entry 3562 (class 1259 OID 26859)
-- Name: idx_spells_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_spells_source_id ON public.spells USING btree (source_id);


--
-- TOC entry 3671 (class 2620 OID 26860)
-- Name: armor_properties track_armor_prop_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_armor_prop_updates AFTER UPDATE ON public.armor_properties FOR EACH ROW EXECUTE FUNCTION public.propagate_item_update();


--
-- TOC entry 3672 (class 2620 OID 26861)
-- Name: classes track_class_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_class_updates BEFORE UPDATE ON public.classes FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3673 (class 2620 OID 26862)
-- Name: feats track_feat_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_feat_updates BEFORE UPDATE ON public.feats FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3674 (class 2620 OID 26864)
-- Name: monsters track_monster_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_monster_updates BEFORE UPDATE ON public.monsters FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3675 (class 2620 OID 26865)
-- Name: races track_race_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_race_updates BEFORE UPDATE ON public.races FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3676 (class 2620 OID 26866)
-- Name: rules track_rule_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_rule_updates BEFORE UPDATE ON public.rules FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3677 (class 2620 OID 26867)
-- Name: skills track_skill_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_skill_updates BEFORE UPDATE ON public.skills FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3678 (class 2620 OID 26868)
-- Name: source_entries track_source_entry_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_source_entry_updates BEFORE UPDATE ON public.source_entries FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3679 (class 2620 OID 26869)
-- Name: sources track_source_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_source_updates BEFORE UPDATE ON public.sources FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3680 (class 2620 OID 26870)
-- Name: spells track_spell_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_spell_updates BEFORE UPDATE ON public.spells FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3681 (class 2620 OID 26871)
-- Name: weapon_properties track_weapon_prop_updates; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER track_weapon_prop_updates AFTER UPDATE ON public.weapon_properties FOR EACH ROW EXECUTE FUNCTION public.propagate_item_update();


--
-- TOC entry 3682 (class 2620 OID 27551)
-- Name: items update_items_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_items_modtime BEFORE UPDATE ON public.items FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 3608 (class 2606 OID 26887)
-- Name: adventurer_classes character_classes_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_classes
    ADD CONSTRAINT character_classes_character_id_fkey FOREIGN KEY (adventurer_id) REFERENCES public.adventurers(id) ON DELETE CASCADE;


--
-- TOC entry 3609 (class 2606 OID 26892)
-- Name: adventurer_classes character_classes_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_classes
    ADD CONSTRAINT character_classes_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id);


--
-- TOC entry 3610 (class 2606 OID 26897)
-- Name: adventurer_feats character_feats_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_feats
    ADD CONSTRAINT character_feats_character_id_fkey FOREIGN KEY (adventurer_id) REFERENCES public.adventurers(id) ON DELETE CASCADE;


--
-- TOC entry 3611 (class 2606 OID 26902)
-- Name: adventurer_feats character_feats_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_feats
    ADD CONSTRAINT character_feats_feat_id_fkey FOREIGN KEY (feat_id) REFERENCES public.feats(id);


--
-- TOC entry 3612 (class 2606 OID 26917)
-- Name: adventurer_skills character_skills_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_skills
    ADD CONSTRAINT character_skills_character_id_fkey FOREIGN KEY (adventurer_id) REFERENCES public.adventurers(id) ON DELETE CASCADE;


--
-- TOC entry 3613 (class 2606 OID 26922)
-- Name: adventurer_skills character_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_skills
    ADD CONSTRAINT character_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id);


--
-- TOC entry 3614 (class 2606 OID 26927)
-- Name: adventurer_spell_slots character_spell_slots_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_spell_slots
    ADD CONSTRAINT character_spell_slots_character_id_fkey FOREIGN KEY (adventurer_id) REFERENCES public.adventurers(id) ON DELETE CASCADE;


--
-- TOC entry 3615 (class 2606 OID 26932)
-- Name: adventurer_spells character_spells_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_spells
    ADD CONSTRAINT character_spells_character_id_fkey FOREIGN KEY (adventurer_id) REFERENCES public.adventurers(id) ON DELETE CASCADE;


--
-- TOC entry 3616 (class 2606 OID 26937)
-- Name: adventurer_spells character_spells_spell_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_spells
    ADD CONSTRAINT character_spells_spell_id_fkey FOREIGN KEY (spell_id) REFERENCES public.spells(id);


--
-- TOC entry 3617 (class 2606 OID 26952)
-- Name: adventurers characters_race_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurers
    ADD CONSTRAINT characters_race_id_fkey FOREIGN KEY (race_id) REFERENCES public.races(id);


--
-- TOC entry 3618 (class 2606 OID 26957)
-- Name: adventurers characters_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurers
    ADD CONSTRAINT characters_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3619 (class 2606 OID 26962)
-- Name: class_description_sections class_description_sections_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_description_sections
    ADD CONSTRAINT class_description_sections_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3620 (class 2606 OID 26967)
-- Name: class_features class_features_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_features
    ADD CONSTRAINT class_features_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3621 (class 2606 OID 26972)
-- Name: class_progression class_progression_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_progression
    ADD CONSTRAINT class_progression_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3622 (class 2606 OID 26977)
-- Name: class_skills class_skills_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_skills
    ADD CONSTRAINT class_skills_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE;


--
-- TOC entry 3623 (class 2606 OID 26982)
-- Name: class_skills class_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_skills
    ADD CONSTRAINT class_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id) ON DELETE CASCADE;


--
-- TOC entry 3624 (class 2606 OID 26987)
-- Name: classes classes_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3625 (class 2606 OID 26992)
-- Name: conditions conditions_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id);


--
-- TOC entry 3626 (class 2606 OID 26997)
-- Name: domain_spells domain_spells_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_spells
    ADD CONSTRAINT domain_spells_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.domains(id) ON DELETE CASCADE;


--
-- TOC entry 3627 (class 2606 OID 27002)
-- Name: domain_spells domain_spells_spell_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_spells
    ADD CONSTRAINT domain_spells_spell_id_fkey FOREIGN KEY (spell_id) REFERENCES public.spells(id) ON DELETE CASCADE;


--
-- TOC entry 3628 (class 2606 OID 27007)
-- Name: domains domains_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id);


--
-- TOC entry 3661 (class 2606 OID 27437)
-- Name: enchantment_applicable_to enchantment_applicable_to_enchantment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantment_applicable_to
    ADD CONSTRAINT enchantment_applicable_to_enchantment_id_fkey FOREIGN KEY (enchantment_id) REFERENCES public.enchantments(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3662 (class 2606 OID 27442)
-- Name: enchantment_applicable_to enchantment_applicable_to_item_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantment_applicable_to
    ADD CONSTRAINT enchantment_applicable_to_item_type_id_fkey FOREIGN KEY (item_type_id) REFERENCES public.item_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3629 (class 2606 OID 27027)
-- Name: entity_tables entity_tables_entity_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tables
    ADD CONSTRAINT entity_tables_entity_type_id_fkey FOREIGN KEY (entity_type_id) REFERENCES public.entity_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3630 (class 2606 OID 27032)
-- Name: entity_tables entity_tables_source_table_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tables
    ADD CONSTRAINT entity_tables_source_table_id_fkey FOREIGN KEY (source_table_id) REFERENCES public.source_tables(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3631 (class 2606 OID 27042)
-- Name: feat_prereq_feat feat_prereq_feat_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_feat
    ADD CONSTRAINT feat_prereq_feat_feat_id_fkey FOREIGN KEY (feat_id) REFERENCES public.feats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3632 (class 2606 OID 27047)
-- Name: feat_prereq_feat feat_prereq_feat_prereq_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_feat
    ADD CONSTRAINT feat_prereq_feat_prereq_feat_id_fkey FOREIGN KEY (prereq_feat_id) REFERENCES public.feats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3651 (class 2606 OID 27323)
-- Name: feat_prereq_numeric feat_prereq_numeric_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_numeric
    ADD CONSTRAINT feat_prereq_numeric_feat_id_fkey FOREIGN KEY (feat_id) REFERENCES public.feats(id) ON DELETE CASCADE;


--
-- TOC entry 3652 (class 2606 OID 27340)
-- Name: feat_prereq_special feat_prereq_special_feat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feat_prereq_special
    ADD CONSTRAINT feat_prereq_special_feat_id_fkey FOREIGN KEY (feat_id) REFERENCES public.feats(id) ON DELETE CASCADE;


--
-- TOC entry 3633 (class 2606 OID 27057)
-- Name: feats feats_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feats
    ADD CONSTRAINT feats_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3665 (class 2606 OID 27491)
-- Name: adventurer_armor fk_armor_adventurer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_armor
    ADD CONSTRAINT fk_armor_adventurer FOREIGN KEY (adventurer_id) REFERENCES public.adventurers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3666 (class 2606 OID 27496)
-- Name: adventurer_armor fk_armor_item; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_armor
    ADD CONSTRAINT fk_armor_item FOREIGN KEY (item_id) REFERENCES public.items(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3649 (class 2606 OID 27184)
-- Name: spells_per_day_progression fk_class_per_day; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_per_day_progression
    ADD CONSTRAINT fk_class_per_day FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE RESTRICT;


--
-- TOC entry 3659 (class 2606 OID 27427)
-- Name: enchantments fk_enchantments_bonus_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantments
    ADD CONSTRAINT fk_enchantments_bonus_type FOREIGN KEY (bonus_type_id) REFERENCES public.bonus_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3660 (class 2606 OID 27422)
-- Name: enchantments fk_enchantments_source; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enchantments
    ADD CONSTRAINT fk_enchantments_source FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3667 (class 2606 OID 27517)
-- Name: adventurer_gear fk_gear_adventurer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_gear
    ADD CONSTRAINT fk_gear_adventurer FOREIGN KEY (adventurer_id) REFERENCES public.adventurers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3668 (class 2606 OID 27522)
-- Name: adventurer_gear fk_gear_item; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_gear
    ADD CONSTRAINT fk_gear_item FOREIGN KEY (item_id) REFERENCES public.items(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3669 (class 2606 OID 27540)
-- Name: adventurer_items fk_items_adventurer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_items
    ADD CONSTRAINT fk_items_adventurer FOREIGN KEY (adventurer_id) REFERENCES public.adventurers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3653 (class 2606 OID 27397)
-- Name: items fk_items_armor_stats; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_items_armor_stats FOREIGN KEY (armor_stats_id) REFERENCES public.armor_properties(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3654 (class 2606 OID 27387)
-- Name: items fk_items_base_item; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_items_base_item FOREIGN KEY (base_item_id) REFERENCES public.items(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3655 (class 2606 OID 27382)
-- Name: items fk_items_body_slot; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_items_body_slot FOREIGN KEY (body_slot_id) REFERENCES public.body_slots(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3670 (class 2606 OID 27545)
-- Name: adventurer_items fk_items_item; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_items
    ADD CONSTRAINT fk_items_item FOREIGN KEY (item_id) REFERENCES public.items(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3656 (class 2606 OID 27372)
-- Name: items fk_items_item_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_items_item_type FOREIGN KEY (item_type_id) REFERENCES public.item_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3657 (class 2606 OID 27377)
-- Name: items fk_items_source; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_items_source FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3658 (class 2606 OID 27392)
-- Name: items fk_items_weapon_stats; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_items_weapon_stats FOREIGN KEY (weapon_stats_id) REFERENCES public.weapon_properties(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3650 (class 2606 OID 27206)
-- Name: restricted_slots_progression fk_progression; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restricted_slots_progression
    ADD CONSTRAINT fk_progression FOREIGN KEY (progression_id) REFERENCES public.spells_per_day_progression(id) ON DELETE RESTRICT;


--
-- TOC entry 3647 (class 2606 OID 27072)
-- Name: weapon_damage_type fk_weapon_damage_type_properties; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_damage_type
    ADD CONSTRAINT fk_weapon_damage_type_properties FOREIGN KEY (weapon_properties_id) REFERENCES public.weapon_properties(id) ON DELETE CASCADE;


--
-- TOC entry 3663 (class 2606 OID 27464)
-- Name: adventurer_weapons fk_weapons_adventurer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_weapons
    ADD CONSTRAINT fk_weapons_adventurer FOREIGN KEY (adventurer_id) REFERENCES public.adventurers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3664 (class 2606 OID 27469)
-- Name: adventurer_weapons fk_weapons_item; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adventurer_weapons
    ADD CONSTRAINT fk_weapons_item FOREIGN KEY (item_id) REFERENCES public.items(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3634 (class 2606 OID 27092)
-- Name: monsters monsters_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monsters
    ADD CONSTRAINT monsters_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3635 (class 2606 OID 27097)
-- Name: npcs npcs_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.npcs
    ADD CONSTRAINT npcs_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3636 (class 2606 OID 27102)
-- Name: race_features race_features_race_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.race_features
    ADD CONSTRAINT race_features_race_id_fkey FOREIGN KEY (race_id) REFERENCES public.races(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3637 (class 2606 OID 27107)
-- Name: races races_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3638 (class 2606 OID 27112)
-- Name: rules rules_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id);


--
-- TOC entry 3639 (class 2606 OID 27117)
-- Name: skills skills_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id);


--
-- TOC entry 3640 (class 2606 OID 27122)
-- Name: source_entries source_entries_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_entries
    ADD CONSTRAINT source_entries_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.sources(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 3641 (class 2606 OID 27127)
-- Name: spell_levels spell_levels_class_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spell_levels
    ADD CONSTRAINT spell_levels_class_id_fk FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 3642 (class 2606 OID 27132)
-- Name: spell_levels spell_levels_spell_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spell_levels
    ADD CONSTRAINT spell_levels_spell_id_fkey FOREIGN KEY (spell_id) REFERENCES public.spells(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3644 (class 2606 OID 27137)
-- Name: spells_known_progression spells_known_progression_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells_known_progression
    ADD CONSTRAINT spells_known_progression_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3643 (class 2606 OID 27142)
-- Name: spells spells_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spells
    ADD CONSTRAINT spells_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_entries(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3648 (class 2606 OID 27147)
-- Name: weapon_damage_type weapon_damage_type_damage_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_damage_type
    ADD CONSTRAINT weapon_damage_type_damage_type_id_fkey FOREIGN KEY (damage_type_id) REFERENCES public.damage_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3645 (class 2606 OID 27152)
-- Name: weapon_properties weapon_properties_critical_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_properties
    ADD CONSTRAINT weapon_properties_critical_id_fkey FOREIGN KEY (critical_id) REFERENCES public.critical_combinations(id);


--
-- TOC entry 3646 (class 2606 OID 27157)
-- Name: weapon_properties weapon_properties_damage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapon_properties
    ADD CONSTRAINT weapon_properties_damage_id_fkey FOREIGN KEY (damage_id) REFERENCES public.damage_scaling(id);


--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT USAGE ON SCHEMA public TO dnd_auth_role;
GRANT USAGE ON SCHEMA public TO dnd_player_role;


--
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE adventurer_classes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.adventurer_classes TO dnd_player_role;


--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE adventurer_feats; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.adventurer_feats TO dnd_player_role;


--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 203
-- Name: SEQUENCE adventurer_feats_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.adventurer_feats_id_seq TO dnd_player_role;


--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE adventurer_skills; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.adventurer_skills TO dnd_player_role;


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 205
-- Name: SEQUENCE adventurer_skills_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.adventurer_skills_id_seq TO dnd_player_role;


--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE adventurer_spell_slots; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.adventurer_spell_slots TO dnd_player_role;


--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 207
-- Name: SEQUENCE adventurer_spell_slots_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.adventurer_spell_slots_id_seq TO dnd_player_role;


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE adventurer_spells; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.adventurer_spells TO dnd_player_role;


--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 209
-- Name: SEQUENCE adventurer_spells_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.adventurer_spells_id_seq TO dnd_player_role;


--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE adventurers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.adventurers TO dnd_player_role;


--
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 211
-- Name: SEQUENCE adventurers_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.adventurers_id_seq TO dnd_player_role;


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE armor_properties; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.armor_properties TO dnd_player_role;


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE body_slots; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.body_slots TO dnd_player_role;
GRANT SELECT ON TABLE public.body_slots TO dnd_gm_role;


--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE bonus_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.bonus_types TO dnd_player_role;
GRANT SELECT ON TABLE public.bonus_types TO dnd_gm_role;


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE class_description_sections; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.class_description_sections TO dnd_player_role;


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE class_features; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.class_features TO dnd_player_role;


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE class_progression; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.class_progression TO dnd_player_role;


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE class_skills; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.class_skills TO dnd_player_role;


--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE classes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.classes TO dnd_player_role;


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE conditions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.conditions TO dnd_player_role;


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE critical_combinations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.critical_combinations TO dnd_player_role;


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE damage_scaling; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.damage_scaling TO dnd_player_role;


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE damage_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.damage_types TO dnd_player_role;


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE domain_spells; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.domain_spells TO dnd_player_role;


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE domains; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.domains TO dnd_player_role;


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE entity_tables; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.entity_tables TO dnd_player_role;


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE entity_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.entity_types TO dnd_player_role;


--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE feat_prereq_feat; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.feat_prereq_feat TO dnd_player_role;


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE feats; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.feats TO dnd_player_role;


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE item_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.item_types TO dnd_player_role;


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE monsters; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.monsters TO dnd_gm_role;


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE npcs; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.npcs TO dnd_gm_role;


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE race_features; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.race_features TO dnd_player_role;


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE races; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.races TO dnd_player_role;


--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 255
-- Name: TABLE rules; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.rules TO dnd_player_role;


--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE skills; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.skills TO dnd_player_role;


--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE source_entries; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.source_entries TO dnd_player_role;


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE source_tables; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.source_tables TO dnd_player_role;


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE sources; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.sources TO dnd_player_role;


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE spell_levels; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.spell_levels TO dnd_player_role;


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE spells; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.spells TO dnd_player_role;


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE spells_known_progression; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.spells_known_progression TO dnd_player_role;


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.users TO dnd_auth_role;


--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 271
-- Name: SEQUENCE users_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.users_id_seq TO dnd_auth_role;


--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE weapon_properties; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.weapon_properties TO dnd_player_role;


--
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 313
-- Name: TABLE view_adventurer_detailed_export; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_adventurer_detailed_export TO dnd_player_role;


--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 312
-- Name: TABLE view_adventurer_overview; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_adventurer_overview TO dnd_player_role;


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE view_class_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_class_details TO dnd_player_role;
GRANT SELECT ON TABLE public.view_class_details TO dnd_gm_role;


--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE view_class_search; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_class_search TO dnd_player_role;
GRANT SELECT ON TABLE public.view_class_search TO dnd_gm_role;


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE view_condition_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_condition_details TO dnd_player_role;
GRANT SELECT ON TABLE public.view_condition_details TO dnd_gm_role;


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE view_condition_search; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_condition_search TO dnd_player_role;
GRANT SELECT ON TABLE public.view_condition_search TO dnd_gm_role;


--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE view_feat_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_feat_details TO dnd_gm_role;
GRANT SELECT ON TABLE public.view_feat_details TO dnd_player_role;


--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE view_feat_search; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_feat_search TO dnd_player_role;
GRANT SELECT ON TABLE public.view_feat_search TO dnd_gm_role;


--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE view_monster_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_monster_details TO dnd_gm_role;


--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE view_monster_search; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_monster_search TO dnd_gm_role;


--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE view_race_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_race_details TO dnd_player_role;
GRANT SELECT ON TABLE public.view_race_details TO dnd_gm_role;


--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE view_race_search; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_race_search TO dnd_player_role;
GRANT SELECT ON TABLE public.view_race_search TO dnd_gm_role;


--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE view_rule_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_rule_details TO dnd_player_role;
GRANT SELECT ON TABLE public.view_rule_details TO dnd_gm_role;


--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE view_rule_search; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_rule_search TO dnd_player_role;
GRANT SELECT ON TABLE public.view_rule_search TO dnd_gm_role;


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE view_skill_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_skill_details TO dnd_gm_role;
GRANT SELECT ON TABLE public.view_skill_details TO dnd_player_role;


--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE view_skill_search; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_skill_search TO dnd_player_role;
GRANT SELECT ON TABLE public.view_skill_search TO dnd_gm_role;


--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE view_spell_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_spell_details TO dnd_player_role;
GRANT SELECT ON TABLE public.view_spell_details TO dnd_gm_role;


--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE view_spell_search; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.view_spell_search TO dnd_player_role;
GRANT SELECT ON TABLE public.view_spell_search TO dnd_gm_role;


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE weapon_damage_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.weapon_damage_type TO dnd_player_role;


-- Completed on 2026-03-25 23:03:41 CET

--
-- PostgreSQL database dump complete
--

\unrestrict pn00q5ObSJqfIQ0kPvjd2upjHXgzFRQtQkglHM0CsnxxRzqVjAmwqbyobVbUPg8

