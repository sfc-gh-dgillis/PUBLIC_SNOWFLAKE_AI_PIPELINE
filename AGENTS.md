# AGENTS.md

## Project Overview

This repository demonstrates how to build AI-infused data pipelines using Snowflake Cortex for Financial Services. The demo focuses on analyzing Federal Open Market Committee (FOMC) meeting minutes to automatically generate hawkish/dovish/neutral economic sentiment signals using Cortex Complete, and provides a RAG-powered chat interface using Cortex Search for deeper document comprehension.

## Key Files

| File | Purpose |
|------|---------|
| `001-AI_Pipeline_Setup.SQL` | SQL setup script to create database objects, stages, streams, sequences, tables, network rules, and stored procedures |
| `2_AI_Pipeline.ipynb` | Core AI pipeline notebook demonstrating PDF ingestion, text extraction with AI_PARSE_DOCUMENT, prompt engineering, and sentiment analysis with Cortex Complete |
| `3_AI_Cortex_Search.ipynb` | RAG demo using Cortex Search for document chunking, embedding, and a Streamlit chat interface |
| `4_AI_Pipeline_Industrialization.ipynb` | Enterprise-ready pipeline automation using streams and tasks for continuous ingestion and scoring |
| `FOMC_DOCS/` | Sample FOMC meeting minutes PDFs for testing |
| `README.md` | Project overview and suggested learning path |

## Snowflake Research Instructions

**CRITICAL**: When researching or answering questions about Snowflake capabilities, features, or best practices, ALWAYS use `cortex search docs` before relying on training knowledge.

```bash
# Search Snowflake documentation
cortex search docs "<query>"

# Examples
cortex search docs "Interactive Tables"
cortex search docs "Dynamic Tables incremental"
cortex search docs "Snowpipe Streaming Kafka"
```

### Why This Matters

- Training data may be outdated
- Snowflake releases new features frequently (monthly+)
- Documentation reflects current GA and Preview features
- Avoid confidently stating something is "not possible" when it may now be supported

### When to Search

- Any question about Snowflake features or capabilities
- Before claiming something is or isn't supported
- When discussing competitive positioning vs Databricks, Spark, Flink
- When recommending architecture patterns
- Before saying "Snowflake can't do X"

### Do NOT

- Rely solely on training knowledge for Snowflake capabilities
- State limitations without verifying against current docs
- Dismiss requirements as "unrealistic" without checking current features

## Useful Commands

| Command | Purpose |
|---------|---------|
| `cortex search docs "<query>"` | Search Snowflake product documentation |
| `cortex connections list` | List available Snowflake connections |
| `cortex semantic-views search "<query>"` | Search for semantic views |

## Code Style

- Markdown files use standard GitHub-flavored Markdown
- Tables preferred for structured information
- Keep documents self-contained (each scenario doc should work standalone)
