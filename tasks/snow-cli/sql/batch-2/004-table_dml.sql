USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

--insert values into models table (updated model list)
INSERT INTO gen_ai_fsi.asset_management.models (model, context_window)
VALUES ('mistral-large2', 128000),
       ('claude-3-5-sonnet', 200000),
       ('llama3.1-8b', 128000),
       ('llama3.1-70b', 128000),
       ('llama3.1-405b', 128000),
       ('llama3.2-3b', 128000),
       ('llama3.3-70b', 128000),
       ('snowflake-arctic', 4096),
       ('mixtral-8x7b', 32000),
       ('mistral-7b', 32000);
