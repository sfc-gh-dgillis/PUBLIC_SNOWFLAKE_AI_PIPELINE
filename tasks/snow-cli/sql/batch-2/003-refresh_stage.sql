USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

ALTER STAGE gen_ai_fsi.asset_management.fomc_sentiment_analysis_demo REFRESH;