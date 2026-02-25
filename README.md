# FOMC Sentiment Analysis Demo - Setup Guide

This guide provides instructions to deploy the FOMC Sentiment Analysis demo using [Task](https://taskfile.dev), the modern Task runner. For manual deployment, see [Manual Setup](#manual-setup).

## Overview

This demo showcases an AI-infused data pipeline for Financial Services built on Snowflake, featuring:

- **Snowflake Cortex Complete** for LLM-powered sentiment analysis (hawkish/dovish/neutral signals)
- **Cortex Search** for RAG-powered document Q&A
- **AI_PARSE_DOCUMENT** for native PDF text extraction
- **Streams and Tasks** for automated, continuous ingestion pipelines
- **Streamlit in Snowflake** for interactive visualization and chat interfaces

The system automatically ingests Federal Open Market Committee (FOMC) meeting minutes, extracts text, and generates economic sentiment signals using prompt engineering and LLM analysis.

### Use Case

Portfolio teams at asset managers need to quickly comprehend FOMC statements to anticipate Federal Reserve monetary policy decisions. This demo automates:

1. **Signal Generation**: Classify FOMC documents as Hawkish, Dovish, or Neutral
2. **Document Q&A**: Ask targeted questions about specific meeting minutes via RAG

### Authors

- [John Heisler](https://www.linkedin.com/in/jheisler/)
- [Garrett Frere](https://www.linkedin.com/in/garrett-frere/)

## Prerequisites

### Required

1. **Snowflake Account** with ACCOUNTADMIN role (or SYSADMIN + ACCOUNTADMIN for external access integration)

### For Automated Setup (Task Runner)

2. **Snowflake CLI** installed and configured
3. **Task** (Go Task Runner) installed
4. **Python 3.x** installed (for utility scripts)

### For Manual Setup

2. Access to Snowsight UI

### Validate Prerequisites (Automated Setup Only)

You can validate that Snowflake CLI is installed correctly:

```bash
task validate-prerequisites:snowcli
```

## Setup (Automated)

The following steps use the automated Task runner and require the **ACCOUNTADMIN** role (or SYSADMIN with CREATE DATABASE privileges, plus ACCOUNTADMIN for external access integration). For manual setup, see [Manual Setup](#manual-setup).

### Step 1: Configure Environment

Create a `.env/demo.env` file based on the template (`.env/demo.env_template`):

```bash
# The Snowflake connection name configured in snow-cli for keypair authentication.
CLI_CONNECTION_NAME=your_connection_name_here

# All objects are created in this database and schema.
DEMO_DATABASE_NAME=yourdbnamehere
DEMO_SCHEMA_NAME=yourdbnamehere.yourschemanamehere

# The internal named stage used to upload files for the demo.
INTERNAL_NAMED_STAGE=@yourdbnamehere.yourschemanamehere.yourinternalnamedstagenamehere

# The task which runs the file upload and streamlit app deploy runs from the snow-cli directory.
# The upload and streamlit directories are relative to that.
FILE_UPLOAD_DIR="../../upload"
STREAMLIT_APP_DIR=streamlit

# Snowflake Demo Configuration
DEMO_WAREHOUSE_NAME=demo_s_wh
```

### Step 2: Infrastructure Initialization (Batch-0)

```bash
task snow-cli:sort-and-process-sql-folder SQL_SORT_PROCESS_DIR=sql/batch-0 CLI_CONNECTION_NAME=$CLI_CONNECTION_NAME
```

This creates:

- `demo_s_wh` warehouse
- `GEN_AI_FSI` database
- `ASSET_MANAGEMENT` schema

### Step 3: Schema Objects (Batch-1)

```bash
task snow-cli:sort-and-process-sql-folder SQL_SORT_PROCESS_DIR=sql/batch-1 CLI_CONNECTION_NAME=$CLI_CONNECTION_NAME
```

This creates:

- Tables (`PDF_FULL_TEXT`, `PDF_CHUNKS`, `MODELS`)
- Sequences for ID generation
- Internal stages (`FED_PDF`, `FED_LOGIC`)
- Streams for CDC on the stage directory
- Network rules for Federal Reserve website access
- External access integration (`FED_RESERVE_ACCESS_INTEGRATION`)
- `GET_FED_PDFS` stored procedure for PDF download

### Step 4: Upload Sample FOMC Documents

```bash
task snow-cli:upload-files-to-internal-named-stage \
  FILE_UPLOAD_DIR=$FILE_UPLOAD_DIR \
  CLI_CONNECTION_NAME=$CLI_CONNECTION_NAME \
  INTERNAL_NAMED_STAGE=$INTERNAL_NAMED_STAGE
```

Or manually upload files from the `FOMC_DOCS/` directory via Snowsight.

## Demo Deployment

### Deploy the Notebooks

The primary demo experience is through Snowflake Notebooks. Deploy them using:

```bash
task demo-up
```

This command:

1. Generates notebooks from templates (substituting environment variables)
2. Deploys notebooks to Snowflake

### What Gets Created

The deployment creates the following Snowflake objects:

#### Database & Schema

- Database: `GEN_AI_FSI`
- Schema: `ASSET_MANAGEMENT`

#### Tables

| Table | Purpose |
|-------|---------|
| `PDF_FULL_TEXT` | Stores extracted PDF text with FILE type, sentiment analysis results |
| `PDF_CHUNKS` | Chunked text for RAG/Cortex Search |
| `PDF_FULL_TEXT_MARKDOWN_AWARE` | Markdown-aware text extraction for improved chunking |
| `PDF_CHUNKS_MARKDOWN_AWARE` | Markdown-aware chunks for Cortex Search |
| `MODELS` | LLM model metadata |

#### Stages

| Stage | Purpose |
|-------|---------|
| `FED_PDF` | Internal stage for FOMC PDF documents with directory enabled |
| `FED_LOGIC` | Internal stage for UDF dependencies |

#### Streams

| Stream | Purpose |
|--------|---------|
| `ASSET_MANAGEMENT_STREAM` | CDC stream on `FED_PDF` stage directory for new file detection |
| `FOMC_STREAM` | CDC stream for pipeline automation |

#### Functions & Procedures

| Object | Type | Purpose |
|--------|------|---------|
| `GET_FED_PDFS` | Stored Procedure | Downloads FOMC PDFs from Federal Reserve website to stage |
| `GENERATE_SENTIMENT_PROMPT` | UDF | Generates expert economist prompt for sentiment analysis |
| `GENERATE_PROMPT` | SQL Function | Simplified prompt generator for AI_COMPLETE |

#### Tasks (Created in Industrialization Notebook)

| Task | Purpose |
|------|---------|
| `DOWNLOAD_FED_PDF_TO_STAGE` | Scheduled task to download new FOMC PDFs hourly |
| `LOAD_FED_PDFS_STAGE_TO_TABLE` | Triggered task to process new PDFs and generate sentiment |

#### Cortex Services (Created in Search Notebook)

| Service | Purpose |
|---------|---------|
| `SEARCH_FED_MARKDOWN_AWARE` | Cortex Search service for RAG-powered document Q&A |

#### External Access

| Object | Purpose |
|--------|---------|
| `FED_RESERVE` | Network rule allowing egress to `www.federalreserve.gov` |
| `FED_RESERVE_ACCESS_INTEGRATION` | External access integration for PDF download |

## Using the Demo

### Notebook Learning Path

1. **`2_AI_Pipeline.ipynb`** - Core AI pipeline demonstrating:
   - PDF text extraction with `AI_PARSE_DOCUMENT`
   - Prompt engineering for economic sentiment analysis
   - LLM inference with `AI_COMPLETE` and structured outputs
   - Interactive Streamlit visualization

2. **`3_AI_Cortex_Search.ipynb`** - RAG demo demonstrating:
   - Markdown-aware text chunking with `SPLIT_TEXT_RECURSIVE_CHARACTER`
   - Cortex Search service creation
   - Chat interface for document Q&A

3. **`4_AI_Pipeline_Industrialization.ipynb`** - Enterprise automation:
   - Automated PDF download from Federal Reserve website
   - Stream-based CDC for new file detection
   - Task-based pipeline orchestration
   - Continuous sentiment scoring

### Sample Questions (Cortex Search Chat)

Once the Cortex Search service is deployed, you can ask questions like:

**Economic Outlook:**
- "What is the Fed's current view on inflation?"
- "Are there concerns about employment levels?"
- "What factors are driving policy decisions?"

**Policy Signals:**
- "Is the committee leaning toward rate increases or cuts?"
- "What language suggests hawkish sentiment?"
- "Are there any dissenting opinions?"

**Specific Topics:**
- "What did the committee say about housing markets?"
- "How is the labor market being characterized?"
- "What international factors were discussed?"

### Sample Files

The demo includes sample FOMC PDFs in the `FOMC_DOCS/` directory:

| File | Description |
|------|-------------|
| `fomcminutes20240501.pdf` | May 2024 FOMC Meeting Minutes |
| `fomcminutes20240612.pdf` | June 2024 FOMC Meeting Minutes |
| `fomcminutes20240731.pdf` | July 2024 FOMC Meeting Minutes |
| `monetary20240501a1.pdf` | May 2024 Monetary Policy Report |
| `monetary20240612a1.pdf` | June 2024 Monetary Policy Report |
| `monetary20240731a1.pdf` | July 2024 Monetary Policy Report |

### Enabling External Access in Notebooks

Before running the industrialization notebook:

1. Click the three dots in the top right corner of Snowsight
2. Select **Notebook Settings**
3. Select the **External Access** tab
4. Toggle on `FED_RESERVE_ACCESS_INTEGRATION`

### Required Notebook Packages

Install the following packages in your notebook environment:

- `bs4`
- `joblib`
- `json5`
- `pandas`
- `python-dotenv`
- `requests`
- `snowflake`
- `snowflake-ml-python`
- `snowflake-snowpark-python`

## Teardown

### Remove the Demo

To completely remove the demo and all created objects:

```bash
task demo-down
```

This will drop the database specified in `DATABASE_NAME` and all its contents.

## Architecture

### Data Flow

```
Federal Reserve Website
        │
        ▼ (GET_FED_PDFS stored procedure)
    FED_PDF Stage
        │
        ▼ (FOMC_STREAM CDC)
   AI_PARSE_DOCUMENT
        │
        ├──────────────────────┐
        ▼                      ▼
  PDF_FULL_TEXT          PDF_CHUNKS
        │                      │
        ▼                      ▼
   AI_COMPLETE           Cortex Search
  (Sentiment)               (RAG)
        │                      │
        ▼                      ▼
  Hawkish/Dovish/       Chat Interface
  Neutral Signal
```

### Key Technologies

| Technology | Purpose |
|------------|---------|
| **AI_PARSE_DOCUMENT** | Native PDF text extraction with layout preservation |
| **AI_COMPLETE** | LLM inference with structured JSON output |
| **Cortex Search** | Vector search for RAG with automatic embedding |
| **SPLIT_TEXT_RECURSIVE_CHARACTER** | Markdown-aware text chunking |
| **Streams** | Change data capture on stage directories |
| **Tasks** | Scheduled and triggered pipeline automation |
| **External Access** | Secure egress to Federal Reserve website |

## Manual Setup

If you prefer not to use the Task runner, follow these steps using Snowsight:

### Step 1: Create Infrastructure

Run the following SQL as SYSADMIN:

```sql
-- Create warehouse
CREATE OR REPLACE WAREHOUSE demo_s_wh
    WITH WAREHOUSE_SIZE = SMALL
    INITIALLY_SUSPENDED = TRUE;

-- Create database and schema
CREATE DATABASE IF NOT EXISTS gen_ai_fsi
    COMMENT = 'FSI Gen AI Demo Database';

CREATE SCHEMA IF NOT EXISTS gen_ai_fsi.asset_management
    COMMENT = 'Schema for managing asset data for FSI Gen AI Demo';
```

### Step 2: Create Schema Objects

Run the SQL files in `tasks/snow-cli/sql/batch-1/` in numeric order. These require ACCOUNTADMIN for the external access integration:

- `001-table_ddl.sql` - Tables and sequences
- `002-sequence_ddl.sql` - ID sequences
- `003-stage_ddl.sql` - Internal stages
- `004-stream_ddl.sql` - CDC streams
- `005-network_external_access_ddl.sql` - Network rule and external access integration (requires ACCOUNTADMIN)
- `006-stored_proc_ddl.sql` - PDF download stored procedure

### Step 3: Upload FOMC Documents

1. Navigate to Snowsight → Data → Databases → GEN_AI_FSI → ASSET_MANAGEMENT → Stages → FED_PDF
2. Upload PDF files from the `FOMC_DOCS/` directory

### Step 4: Run Notebooks

1. Import notebooks from `tasks/snow-cli/notebook/template/` into Snowsight
2. Update database/schema references as needed
3. Execute cells sequentially

## Additional Resources

- [AI-Infused Pipelines with Snowflake Cortex (Medium Article)](https://medium.com/snowflake/ai-infused-pipelines-with-snowflake-cortex-6a7954f2078d)
- [Cortex Complete Documentation](https://docs.snowflake.com/en/sql-reference/functions/complete-snowflake-cortex)
- [Cortex Search Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [AI_PARSE_DOCUMENT Documentation](https://docs.snowflake.com/en/sql-reference/functions/ai_parse_document)
- [Loading Files into Stage through Snowflake UI](https://snowflakewiki.medium.com/loading-files-into-stage-through-snowflake-ui-the-complete-guide-321b135f6175)

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| External access integration not available | Ensure ACCOUNTADMIN role is used; check that the integration is enabled in notebook settings |
| PDF download fails | Verify network rule allows `www.federalreserve.gov`; check external access integration is enabled |
| Stream has no data | Run `ALTER STAGE FED_PDF REFRESH;` to update the directory table |
| Cortex Search not returning results | Verify the search service was created successfully; check that chunks table has data |
| Task not running | Verify `SYSTEM$STREAM_HAS_DATA` returns TRUE; check task is resumed |

### Useful Diagnostic Queries

```sql
-- Check stage contents
SELECT * FROM DIRECTORY(@GEN_AI_FSI.ASSET_MANAGEMENT.FED_PDF);

-- Check stream for new files
SELECT * FROM FOMC_STREAM WHERE METADATA$ACTION = 'INSERT';

-- Verify extracted text
SELECT RELATIVE_PATH, FILE_DATE, LEFT(FILE_TEXT, 500) FROM PDF_FULL_TEXT;

-- Check sentiment results
SELECT 
    RELATIVE_PATH,
    FILE_DATE,
    SENTIMENT:Signal::STRING AS signal,
    SENTIMENT:Signal_Summary::STRING AS reasoning
FROM PDF_FULL_TEXT
ORDER BY FILE_DATE DESC;
```
