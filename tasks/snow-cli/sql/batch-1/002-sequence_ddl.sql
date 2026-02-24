USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

-- Create sequences
CREATE SEQUENCE IF NOT EXISTS gen_ai_fsi.asset_management.fed_pdf_full_text_sequence;
CREATE SEQUENCE IF NOT EXISTS gen_ai_fsi.asset_management.fed_pdf_chunk_sequence;
