USE ROLE DBT_ROLE;
USE WAREHOUSE DBT_WH;
USE DATABASE DBT_SNOWFLAKE_DEV;
USE SCHEMA RAW;


-- ─────────────────────────────────────────
-- TABLE 1: NETFLIX_TITLES
-- 8,809 rows | 12 columns
-- ─────────────────────────────────────────
CREATE OR REPLACE TABLE DBT_SNOWFLAKE_DEV.RAW.NETFLIX_TITLES (
    SHOW_ID         VARCHAR(10),        -- e.g. s1, s2
    TYPE            VARCHAR(10),        -- Movie / TV Show
    TITLE           VARCHAR(150),       -- max found: 104
    DIRECTOR        VARCHAR(250),       -- max found: 208, nullable
    CAST            VARCHAR(1000),      -- max found: 771, nullable
    COUNTRY         VARCHAR(200),       -- max found: 123, nullable
    DATE_ADDED      VARCHAR(25),        -- e.g. "September 25, 2021"
    RELEASE_YEAR    NUMBER(4,0),        -- e.g. 2021
    RATING          VARCHAR(15),        -- e.g. PG-13, TV-MA
    DURATION        VARCHAR(20),        -- e.g. "90 min" or "2 Seasons"
    LISTED_IN       VARCHAR(150),       -- genres, max found: 79
    DESCRIPTION     VARCHAR(500)        -- max found: 248
);


-- ─────────────────────────────────────────
-- TABLE 2: CREDITS
-- 77,801 rows | 5 columns
-- ─────────────────────────────────────────
CREATE OR REPLACE TABLE DBT_SNOWFLAKE_DEV.RAW.CREDITS (
    PERSON_ID       NUMBER(10,0),       -- numeric person identifier
    ID              VARCHAR(15),        -- show/movie id e.g. tm84618
    NAME            VARCHAR(100),       -- actor/director name, max: 73
    CHARACTER       VARCHAR(300),       -- character name, max: 298, nullable
    ROLE            VARCHAR(15)         -- ACTOR or DIRECTOR
);