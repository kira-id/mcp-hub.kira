#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HUB_DIR="${REPO_ROOT}/mcp-hub"
BIN_NAME="mcp-hub"
TARGET="${HUB_DIR}/dist/cli.js"
LINK_PATH="/usr/local/bin/${BIN_NAME}"

# Ensure puppeteer is available for the puppeteer MCP server.
if ! (cd "${REPO_ROOT}" && npm ls puppeteer >/dev/null 2>&1); then
  echo "Installing puppeteer for MCP servers..."
  (cd "${REPO_ROOT}" && npm install -g puppeteer)
fi

cd "${HUB_DIR}"
npm install
npm run build

if [[ ! -f "${TARGET}" ]]; then
  echo "Error: expected ${TARGET} after build, but it was not found." >&2
  exit 1
fi

chmod +x "${TARGET}"

if [[ -w "$(dirname "${LINK_PATH}")" ]]; then
  ln -sf "${TARGET}" "${LINK_PATH}"
else
  if command -v sudo >/dev/null 2>&1; then
    sudo ln -sf "${TARGET}" "${LINK_PATH}"
  else
    echo "Error: cannot write to $(dirname "${LINK_PATH}"). Run this script with sudo or ensure write access." >&2
    exit 1
  fi
fi

echo "Linked ${LINK_PATH} -> ${TARGET}"
"${LINK_PATH}" --help || true
