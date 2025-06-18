CREATE DATABASE IF NOT EXISTS GEN_AI_FSI;

CREATE SCHEMA IF NOT EXISTS GEN_AI_FSI.asset_management;

USE SCHEMA GEN_AI_FSI.asset_management;

--create stage fed_logic;
CREATE STAGE IF NOT EXISTS gen_ai_fsi.asset_management.fed_logic
    DIRECTORY = (ENABLE = TRUE);

--create stage fed_pdf;
CREATE STAGE gen_ai_fsi.asset_management.FED_PDF 
    DIRECTORY = ( ENABLE = true ) 
    ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' );

-- create a stream on the directory
CREATE STREAM IF NOT EXISTS gen_ai_fsi.asset_management.asset_management_stream on DIRECTORY(@gen_ai_fsi.asset_management.fed_pdf);

-- Create sequences
CREATE SEQUENCE IF NOT EXISTS gen_ai_fsi.asset_management.fed_pdf_full_text_sequence;
CREATE SEQUENCE IF NOT EXISTS gen_ai_fsi.asset_management.fed_pdf_chunk_sequence;

--store model data for meta analysis
CREATE TABLE IF NOT EXISTS gen_ai_fsi.asset_management.models (
    model          VARCHAR,
    context_window INT
);

--insert values into models table
INSERT INTO gen_ai_fsi.asset_management.models (model, context_window)
VALUES ('mistral-large', 32000),
       ('reka-flash', 100000),
       ('reka-core', 32000),
       ('jamba-instruct', 256000),
       ('mixtral-8x7b', 32000),
       ('llama2-70b-chat', 4096),
       ('llama3-8b', 8000),
       ('llama3-70b', 8000),
       ('llama3.1-8b', 128000),
       ('llama3.1-70b', 128000),
       ('llama3.1-405b', 128000),
       ('mistral-7b', 32000),
       ('gemma-7b', 8000);

--create our full text table
CREATE TABLE IF NOT EXISTS gen_ai_fsi.asset_management.pdf_full_text (
    id            NUMBER(19, 0),
    relative_path VARCHAR(16777216),
    size          NUMBER(38, 0),
    last_modified TIMESTAMP_TZ(3),
    md5           VARCHAR(16777216),
    etag          VARCHAR(16777216),
    file_url      VARCHAR(16777216),
    file_text     VARCHAR(16777216),
    file_date     DATE,
    sentiment     VARIANT
);

CREATE TABLE IF NOT EXISTS gen_ai_fsi.asset_management.pdf_chunks (
    id            NUMBER(19, 0),
    full_text_fk  NUMBER(19, 0),
    relative_path VARCHAR(16777216),
    file_date     DATE,
    chunk         VARCHAR(16777216)
);

-- In order to go to the public internet and download the PDFs,
-- we need a network rule and external access integration.

-- create the network rule
CREATE OR REPLACE NETWORK RULE gen_ai_fsi.asset_management.fed_reserve
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('www.federalreserve.gov');

-- add the network rule to external access integration
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION fed_reserve_access_integration
  ALLOWED_NETWORK_RULES = (FED_RESERVE)
  ENABLED = TRUE;

-- create the scraping SPROC
CREATE OR REPLACE PROCEDURE gen_ai_fsi.asset_management.get_fed_pdfs()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = 3.9
PACKAGES = ('snowflake-snowpark-python', 'requests', 'bs4', 'snowflake')
EXTERNAL_ACCESS_INTEGRATIONS = ("FED_RESERVE_ACCESS_INTEGRATION")
HANDLER='main'
EXECUTE AS CALLER
AS $$

import snowflake.snowpark as snowpark
import requests 
from bs4 import BeautifulSoup
from io import BytesIO

import requests
from bs4 import BeautifulSoup
from io import BytesIO

def get_all_fomc_pdfs():
    try:
        response = requests.get('https://www.federalreserve.gov/monetarypolicy/fomccalendars.htm')
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        pdf_links = []
        for link in soup.find_all('a', href=True):
            href = link['href']
            if 'fomcminutes' in href and href.endswith('.pdf'):
            # if href.endswith('.pdf'):
                if not href.startswith('http'):
                    href = 'https://www.federalreserve.gov' + href
                pdf_links.append(href)
        return pdf_links
    except requests.RequestException as e:
        print(f"Error fetching the FOMC statement page: {e}")
        return ['no new links']

def main(session):
    database = 'GEN_AI_FSI'
    schema = 'asset_management'
    stage = 'FED_PDF'

    downloaded_files = []
    already_downloaded_files = []

    # Get all PDF links from the website
    pdfs = get_all_fomc_pdfs()
    
    # Get all files already in your stage
    query = f'LIST @{database}.{schema}.{stage}'
    stage_files = session.sql(query).collect()
    stage_files = [row['name'] for row in stage_files]
    
    # Set the stage path
    stage_path = f'@{database}.{schema}.{stage}/'
    
    # Download new files and categorize existing ones
    for pdf in pdfs:
        filename = pdf.split('/')[-1]
        
        # Check if the file is an FOMC minutes PDF and not already downloaded
        if 'fomcminutes' in filename and ('fed_pdf/' + filename not in stage_files):
            try:
                response = requests.get(pdf)
                response.raise_for_status() # Raise an exception for bad status codes
                full_file_name = stage_path + filename
                file_data = response.content
                buffer = BytesIO(file_data)
                session.file.put_stream(buffer, full_file_name, auto_compress=False, overwrite=False)
                downloaded_files.append(filename)
                print(f"{filename}:\t downloading")
            except requests.RequestException as e:
                print(f"Error downloading {filename}: {e}")
                # Optionally, you could add this to a separate error list
        else:
            already_downloaded_files.append(filename)
            print(f"{filename}:\t already downloaded")
            
    # Format the output as a single string
    output_string = "## Downloaded Files\n"
    if downloaded_files:
        output_string += ",\n".join(downloaded_files)
    else:
        output_string += "No new FOMC minutes PDFs were downloaded."

    output_string += "\n\n ## Already Downloaded Files\n"
    if already_downloaded_files:
        output_string += ", ".join(already_downloaded_files)
    else:
        output_string += "No FOMC minutes PDFs were found that were already downloaded or did not match the 'fomcminutes' criteria."
        
    return output_string
$$;