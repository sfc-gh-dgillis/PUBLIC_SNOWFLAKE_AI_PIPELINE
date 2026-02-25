#!/usr/bin/env bash
set -euo pipefail

# Generates Snowflake notebooks from templates by substituting variables
#
# Usage:
#   ./generate-notebook.sh --all                           # Generate all notebooks
#   ./generate-notebook.sh --all --base-dir <dir>          # Generate all with custom base dir
#   ./generate-notebook.sh TEMPLATE_FILE OUTPUT_FILE       # Generate single notebook

show_usage() {
    echo "Usage:"
    echo "  $0 --all [--base-dir <dir>]           Generate all notebooks from template subdirectories"
    echo "  $0 TEMPLATE_FILE OUTPUT_FILE          Generate a single notebook"
    echo ""
    echo "Examples:"
    echo "  $0 --all"
    echo "  $0 --all --base-dir notebook"
    echo "  $0 notebook/template/2_AI_Pipeline/2_AI_Pipeline_template.ipynb notebook/output/2_AI_Pipeline/2_AI_Pipeline.ipynb"
}

if [ $# -lt 1 ]; then
    show_usage
    exit 1
fi

# Check if --all mode
if [ "$1" = "--all" ] || [ "$1" = "-a" ]; then
    shift
    # Pass remaining args (like --base-dir) to Python script
    python3 cmd/generate-notebook.py --all "$@"
else
    # Single notebook mode (backward compatible)
    if [ $# -lt 2 ]; then
        show_usage
        exit 1
    fi

    TEMPLATE_FILE="$1"
    OUTPUT_FILE="$2"

    # Check if template file exists
    if [ ! -f "$TEMPLATE_FILE" ]; then
        echo "Error: Template file not found at $TEMPLATE_FILE"
        exit 1
    fi

    python3 cmd/generate-notebook.py --template "$TEMPLATE_FILE" --output "$OUTPUT_FILE"
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "Notebook generation completed successfully"
else
    echo ""
    echo "Failed to generate notebook(s)"
    exit 1
fi
