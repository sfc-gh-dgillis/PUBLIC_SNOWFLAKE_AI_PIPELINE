USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

-- create a stream on the directory
CREATE STREAM IF NOT EXISTS gen_ai_fsi.asset_management.asset_management_stream
    ON directory(@gen_ai_fsi.asset_management.fomc_sentiment_analysis_demo);
