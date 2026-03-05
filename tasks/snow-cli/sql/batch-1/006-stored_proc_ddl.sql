USE DATABASE gen_ai_fsi;
USE SCHEMA gen_ai_fsi.asset_management;
USE ROLE accountadmin;

-- create the scraping SPROC
CREATE PROCEDURE IF NOT EXISTS gen_ai_fsi.asset_management.get_fed_pdfs()
    RETURNS VARCHAR
    LANGUAGE PYTHON
    RUNTIME_VERSION = 3.9
    PACKAGES = ('snowflake-snowpark-python','requests','bs4','snowflake')
    EXTERNAL_ACCESS_INTEGRATIONS = ("FED_RESERVE_ACCESS_INTEGRATION")
    HANDLER = 'main'
    EXECUTE AS CALLER
AS
$$
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
    stage = 'fomc_sentiment_analysis_demo'

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
        if 'fomcminutes' in filename and ('fomc_sentiment_analysis_demo/' + filename not in stage_files):
            try:
                response = requests.get(pdf)
                response.raise_for_status()  # Raise an exception for bad status codes
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