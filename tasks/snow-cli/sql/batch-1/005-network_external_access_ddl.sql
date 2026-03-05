USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE ACCOUNTADMIN;

-- In order to go to the public internet and download the PDFs,
-- we need a network rule and external access integration.

-- create the network rule
CREATE NETWORK RULE IF NOT EXISTS gen_ai_fsi.asset_management.fed_reserve
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('www.federalreserve.gov');

-- add the network rule to external access integration
CREATE EXTERNAL ACCESS INTEGRATION IF NOT EXISTS fed_reserve_access_integration
  ALLOWED_NETWORK_RULES = (FED_RESERVE)
  ENABLED = TRUE;
