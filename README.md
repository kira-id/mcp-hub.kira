# MCP Hub Setup

This repository contains a ready-to-run [mcp-hub](https://www.npmjs.com/package/mcp-hub) configuration that aggregates multiple MCP servers behind a single endpoint.

## Files

- `config/mcp-hub.json` — Hub configuration that starts each STDIO MCP server with `bunx`
- `.env.example` — Copy to `.env` and fill in the required API tokens

## Prerequisites

- Node.js 18 or newer
- `bun` (recommended) or `npm`

```bash
# Setup
curl -fsSL https://bun.sh/install | bash
# reload your shell profile so bun (and bunx) are on PATH
source ~/.bashrc
# if you use zsh
# source ~/.zshrc
```

Install the hub globally (only needs to be done once per machine):

```bash
./scripts/install-mcp-hub.sh
```

## Local Usage

1. Copy the environment template and populate secrets:
   ```bash
   cp .env.example .env
   # edit .env with your real tokens
   ```
2. Run the hub:
   ```bash
   export $(grep -v '^#' .env | xargs) && mcp-hub --port 37373 --config $(pwd)/config/mcp-hub.json
   ```
3. Point MCP clients (Claude Desktop, Cline, etc.) to `http://<host>:37373/mcp`.

Or add to codex config:

````
experimental_use_rmcp_client = true

[mcp_servers.kira]
url = "http://localhost:37373/mcp"
````

## Auth Token Handling

- **Local development** — use `.env` (gitignored) or shell exports.
- **Shared hosts** — prefer a secret manager (1Password, AWS SSM, Doppler, etc.) and reference them with `${cmd: ...}` in the config if you do not want tokens on disk.
- **Per-user access** — set `MCP_HUB_ENV` before launching the hub so injected values stay isolated per user:
  ```bash
  MCP_HUB_ENV='{"CONTEXT7_API_KEY":"...","UNSPLASH_ACCESS_KEY":"..."}' \
  mcp-hub --port 37373 --config /path/to/config/mcp-hub.json
  ```
- Rotate API keys periodically and restart the hub (`POST /api/restart` or restart the process) to pick up new values.

## Deployment Ideas

- **Systemd service** (Linux)
  1. Create a dedicated user (e.g. `mcp`) that owns the project directory and `.env` file.
  2. Drop a unit in `/etc/systemd/system/mcp-hub.service`:
     ```ini
     [Unit]
     Description=MCP Hub
     After=network.target

     [Service]
     Type=simple
     WorkingDirectory=/home/mcp/projects/kira-mcp-hub
     EnvironmentFile=/home/mcp/projects/kira-mcp-hub/.env
     ExecStart=/usr/local/bin/mcp-hub --port 37373 --config /home/mcp/projects/kira-mcp-hub/config/mcp-hub.json
     Restart=on-failure

     [Install]
     WantedBy=multi-user.target
     ```
  3. Enable and start it: `sudo systemctl enable --now mcp-hub`.
- **Docker** — wrap a minimal Node image, copy the config, and inject secrets with Docker secrets or environment variables.

Monitor the hub with `/api/health` or the SSE stream at `/api/events` to confirm all servers remain connected.
