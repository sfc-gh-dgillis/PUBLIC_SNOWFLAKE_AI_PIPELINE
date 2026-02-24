USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

--create stage fed_logic;
CREATE STAGE IF NOT EXISTS gen_ai_fsi.asset_management.fed_logic
    DIRECTORY = (ENABLE = TRUE);

--create stage fed_pdf;
CREATE STAGE gen_ai_fsi.asset_management.fed_pdf
    DIRECTORY = ( ENABLE = true )
    ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' );
