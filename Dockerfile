# ============================================================
# OpenClaw Docker Image (Render Compatible Version)
# ============================================================

FROM node:22-alpine

LABEL maintainer="OpenClaw Community"
LABEL description="OpenClaw - Your Personal AI Assistant"
LABEL version="1.0.0-render"

# Install basic dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    tzdata

# Set timezone (optional)
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create working directory
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

# Volume (note: Render free does NOT persist this)
VOLUME ["/root/.openclaw"]

# Render requires dynamic port
ENV PORT=18789

# Expose port (Render will override via PORT env)
EXPOSE 18789

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD openclaw health || exit 1

# IMPORTANT: Run Gateway in foreground (NO daemon mode)
CMD ["sh", "-c", "openclaw gateway --bind 0.0.0.0 --port ${PORT}"]
