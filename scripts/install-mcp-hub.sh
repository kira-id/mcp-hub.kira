#!/bin/bash

cd mcp-hub
bun install
bun run build   # ensure dist/cli.js now exists
bun link
mcp-hub --help
