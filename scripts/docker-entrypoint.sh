#!/bin/sh
set -e

ENV_FILE="${ENV_FILE:-/app/.env}"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC2046
  VARS=$(grep -v '^#' "$ENV_FILE" | xargs)
  if [ -n "$VARS" ]; then
    export $VARS
  fi
fi

PORT="${MCP_PORT:-37373}"
CONFIG_PATH="${MCP_CONFIG_PATH:-/app/config/mcp-hub.json}"

exec mcp-hub --port "$PORT" --config "$CONFIG_PATH" "$@"
