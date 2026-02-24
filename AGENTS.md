# AGENTS.md

## Project Overview

This repository contains 
## Key Files

| File       | Purpose         |
|------------|-----------------|
| `file1.md` | Some purpose    |
| `file2.md` | Another purpose |
| `file3.md`     | higher purpose  |

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
