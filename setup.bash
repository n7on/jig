#!/usr/bin/env bash
set -euo pipefail

_GRIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_GRIM_USER_DIR="$HOME/.grim"

# Check for uv
if ! command -v uv &>/dev/null; then
    echo "Error: uv is not installed. Install it from https://docs.astral.sh/uv/getting-started/installation/" >&2
    exit 1
fi

# Create ~/.grim/ if needed
if [[ ! -d "$_GRIM_USER_DIR" ]]; then
    echo "Creating $_GRIM_USER_DIR..."
    mkdir -p "$_GRIM_USER_DIR"
fi

# Copy config.env.example to ~/.grim/config.env if not already there
if [[ ! -f "$_GRIM_USER_DIR/config.env" ]]; then
    echo "Creating $_GRIM_USER_DIR/config.env from example..."
    cp "$_GRIM_DIR/config.env.example" "$_GRIM_USER_DIR/config.env"
    echo "Edit $_GRIM_USER_DIR/config.env to configure grim."
fi

# Install/update Python dependencies
echo "Installing Python dependencies..."
cd "$_GRIM_DIR"
uv sync

echo ""
echo "Setup complete. Add the following line to your .bashrc:"
echo ""
echo "  source $_GRIM_DIR/src/init.bash"
