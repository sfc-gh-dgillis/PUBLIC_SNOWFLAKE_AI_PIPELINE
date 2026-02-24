USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

--store model data for meta analysis
CREATE TABLE IF NOT EXISTS gen_ai_fsi.asset_management.models (
    model          VARCHAR,
    context_window INT
);

--create our full text table
CREATE TABLE IF NOT EXISTS gen_ai_fsi.asset_management.pdf_full_text (
    id            NUMBER(19, 0),
    relative_path VARCHAR(16777216),
    size          NUMBER(38, 0),
    last_modified TIMESTAMP_TZ(3),
    md5           VARCHAR(16777216),
    etag          VARCHAR(16777216),
    file_url      VARCHAR(16777216),
    file_text     VARCHAR(16777216),
    file_date     DATE,
    sentiment     VARIANT
);

--enable change tracking for Cortex Search incremental refresh
ALTER TABLE gen_ai_fsi.asset_management.pdf_full_text SET DATA_RETENTION_TIME_IN_DAYS = 1;

CREATE TABLE IF NOT EXISTS gen_ai_fsi.asset_management.pdf_chunks (
    id            NUMBER(19, 0),
    full_text_fk  NUMBER(19, 0),
    relative_path VARCHAR(16777216),
    file_date     DATE,
    chunk         VARCHAR(16777216)
);

--enable change tracking for Cortex Search incremental refresh
ALTER TABLE gen_ai_fsi.asset_management.pdf_chunks SET DATA_RETENTION_TIME_IN_DAYS = 1;
