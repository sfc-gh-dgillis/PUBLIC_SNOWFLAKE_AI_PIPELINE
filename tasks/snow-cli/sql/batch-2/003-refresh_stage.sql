USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

ALTER STAGE gen_ai_fsi.asset_management.fed_logic REFRESH;

ALTER STAGE gen_ai_fsi.asset_management.fed_pdf REFRESH;