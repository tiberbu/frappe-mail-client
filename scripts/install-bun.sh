#!/bin/bash

if ! command -v bun &> /dev/null && [ ! -f "$HOME/.bun/bin/bun" ]; then
  echo "Bun not found. Installing..."
  curl -fsSL https://bun.sh/install | bash
else
  echo "Bun is already installed"
fi
