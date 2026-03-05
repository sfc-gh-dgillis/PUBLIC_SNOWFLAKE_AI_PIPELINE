USE ROLE sysadmin;

CREATE DATABASE IF NOT EXISTS gen_ai_fsi
    COMMENT = 'FSI Gen AI Demo Database';

CREATE SCHEMA IF NOT EXISTS gen_ai_fsi.asset_management
    COMMENT = 'Schema for managing asset data for FSI Gen AI Demo';
