USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE accountadmin;

--store model data for meta analysis
CREATE TABLE IF NOT EXISTS gen_ai_fsi.asset_management.models (
    model          VARCHAR,
    context_window INT
);

--create our full text table
CREATE TABLE IF NOT EXISTS gen_ai_fsi.asset_management.pdf_full_text (
    id                       NUMBER(19, 0),
    fomc_file                FILE,
    fomc_file_date           DATE,
    extracted_content_object OBJECT,
    extracted_text           VARCHAR,
    sentiment                VARIANT
);

--enable change tracking for Cortex Search incremental refresh
ALTER TABLE gen_ai_fsi.asset_management.pdf_full_text
    SET DATA_RETENTION_TIME_IN_DAYS = 1;

CREATE TABLE IF NOT EXISTS gen_ai_fsi.asset_management.pdf_chunks (
    id             NUMBER(19, 0),
    full_text_fk   NUMBER(19, 0),
    relative_path  VARCHAR,
    fomc_file_date DATE,
    chunk          VARCHAR
);

--enable change tracking for Cortex Search incremental refresh
ALTER TABLE gen_ai_fsi.asset_management.pdf_chunks
    SET DATA_RETENTION_TIME_IN_DAYS = 1;
