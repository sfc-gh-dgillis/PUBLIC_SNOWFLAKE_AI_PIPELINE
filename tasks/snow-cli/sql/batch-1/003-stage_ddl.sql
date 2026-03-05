USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

--create stage fomc_sentiment_analysis_demo;
CREATE STAGE IF NOT EXISTS gen_ai_fsi.asset_management.fomc_sentiment_analysis_demo
    DIRECTORY = ( ENABLE = true )
    ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' );
