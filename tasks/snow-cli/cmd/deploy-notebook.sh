#!/usr/bin/env bash
set -euo pipefail

# Deploys a notebook to Snowflake using the Snow CLI
# Usage: ./deploy-notebook.sh PROJECT_DIR

if [ $# -lt 1 ]; then
    echo "Usage: $0 PROJECT_DIR"
    echo "Example: $0 ../../output/iceberg_v3_notebook"
    exit 1
fi

PROJECT_DIR="$1"

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory not found at $PROJECT_DIR"
    exit 1
fi

# Check if snowflake.yml exists in the project directory
if [ ! -f "$PROJECT_DIR/snowflake.yml" ]; then
    echo "Error: snowflake.yml not found in $PROJECT_DIR"
    exit 1
fi

echo "Deploying notebook to Snowflake..."
echo "  Project: $PROJECT_DIR"
echo "  Connection: $CLI_CONNECTION_NAME"
echo ""

# Deploy the notebook using snow CLI with project path
snow notebook deploy --connection "$CLI_CONNECTION_NAME" --replace --project "$PROJECT_DIR"

if [ $? -eq 0 ]; then
    echo ""
    echo "Notebook deployed successfully"
else
    echo ""
    echo "Failed to deploy notebook"
    exit 1
fi
