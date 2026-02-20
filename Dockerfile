# ============================================================
# OpenClaw Docker Image (Render Compatible - Debian/glibc)
# Fixes node-llama-cpp Alpine build failures
# ============================================================

FROM node:20-bookworm-slim

LABEL maintainer="OpenClaw Community"
LABEL description="OpenClaw - Your Personal AI Assistant"
LABEL version="1.0.0-render-debian"

# Install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    jq \
    tzdata \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Set timezone (optional)
ENV TZ=Asia/Ho_Chi_Minh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Create config directories
RUN mkdir -p /root/.openclaw/logs \
    /root/.openclaw/data \
    /root/.openclaw/skills \
    /root/.openclaw/backups

# Copy default config & skills (if exist in repo)
COPY examples/config.example.yaml /root/.openclaw/config.yaml.example
COPY examples/skills/ /root/.openclaw/skills/

# Note: Render free tier filesystem is ephemeral (not persistent)
VOLUME ["/root/.openclaw"]

# Render provides PORT; we default to 18789
ENV PORT=18789
EXPOSE 18789

# Health check (won't break deploy if endpoint differs; it's container-local)
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD openclaw health || exit 1

# Run OpenClaw Gateway in foreground (Render needs a single foreground process)
CMD ["sh", "-c", "openclaw gateway --bind 0.0.0.0 --port ${PORT}"]
