#!/usr/bin/env bash

# Validate Snowflake CLI installation
if command -v snow >/dev/null 2>&1; then
  echo "Snowflake CLI (snow) is installed."
else
  echo "Snowflake CLI (snow) is not installed."
  echo "To install Snowflake CLI, follow the instructions at:"
  echo "https://docs.snowflake.com/en/developer-guide/snowflake-cli/installation/installation"
fi
