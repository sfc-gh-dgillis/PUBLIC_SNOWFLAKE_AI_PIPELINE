#!/usr/bin/env bash

# Validate Homebrew installation
if command -v brew >/dev/null 2>&1; then
  echo "Homebrew is installed."
else
  echo "Homebrew is not installed."
  echo "To install Homebrew, run:"
  # shellcheck disable=SC2016
  echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
fi
