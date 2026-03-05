#!/usr/bin/env bash
set -euo pipefail

# Deploys all notebooks from output subdirectories to Snowflake
# Usage: ./deploy-all-notebooks.sh [--base-dir <dir>]

BASE_DIR="notebook/output"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --base-dir)
            BASE_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if output directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo "Error: Output directory not found at $BASE_DIR"
    exit 1
fi

# Find all subdirectories with snowflake.yml
NOTEBOOK_DIRS=()
for dir in "$BASE_DIR"/*/; do
    if [ -f "${dir}snowflake.yml" ]; then
        NOTEBOOK_DIRS+=("$dir")
    fi
done

if [ ${#NOTEBOOK_DIRS[@]} -eq 0 ]; then
    echo "Error: No notebook projects found in $BASE_DIR (looking for snowflake.yml)"
    exit 1
fi

echo "Found ${#NOTEBOOK_DIRS[@]} notebook(s) to deploy"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0

for dir in "${NOTEBOOK_DIRS[@]}"; do
    # Remove trailing slash for display
    PROJECT_NAME=$(basename "$dir")
    echo "Deploying: $PROJECT_NAME"
    
    if snow notebook deploy --connection "$CLI_CONNECTION_NAME" --replace --project "$dir"; then
        echo "  Success"
        ((SUCCESS_COUNT++))
    else
        echo "  Failed"
        ((FAIL_COUNT++))
    fi
    echo ""
done

echo "Deployment complete: $SUCCESS_COUNT succeeded, $FAIL_COUNT failed"

if [ $FAIL_COUNT -gt 0 ]; then
    exit 1
fi
