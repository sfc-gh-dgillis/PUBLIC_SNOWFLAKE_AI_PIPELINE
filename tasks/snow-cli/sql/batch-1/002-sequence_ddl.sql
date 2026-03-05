USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

-- Create sequences
CREATE SEQUENCE IF NOT EXISTS gen_ai_fsi.asset_management.fomc_sentiment_analysis_demo_full_text_sequence;
CREATE SEQUENCE IF NOT EXISTS gen_ai_fsi.asset_management.fomc_sentiment_analysis_demo_chunk_sequence;
