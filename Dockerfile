FROM node:20-slim

WORKDIR /app

# Prime the MCP hub build environment
COPY mcp-hub/package*.json ./mcp-hub/
RUN npm ci --prefix ./mcp-hub

# Copy the remaining project files
COPY . .

# Build the bundled mcp-hub CLI and create a convenient shim on PATH
RUN npm run build --prefix ./mcp-hub \
  && ln -sf /app/mcp-hub/dist/cli.js /usr/local/bin/mcp-hub \
  && chmod +x /usr/local/bin/mcp-hub

# Copy the startup script that loads .env values then launches the hub
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 37373

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
