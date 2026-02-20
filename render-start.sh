#!/usr/bin/env bash
set -e

# Render will provide PORT, but we will set it to 18789 in Render settings.
export OPENCLAW_GATEWAY_PORT="${PORT:-18789}"

# Start OpenClaw Gateway and bind to all interfaces (required for Render)
exec openclaw gateway --bind 0.0.0.0 --port "$OPENCLAW_GATEWAY_PORT"
