# ============================================================
# OpenClaw Docker Image (Render Compatible - Debian/glibc)
# ============================================================

FROM node:20-bookworm-slim

LABEL maintainer="OpenClaw Community"
LABEL description="OpenClaw - Your Personal AI Assistant"
LABEL version="1.0.0-render-debian"

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    jq \
    tzdata \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ENV TZ=Asia/Ho_Chi_Minh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

RUN npm install -g openclaw@latest

RUN mkdir -p /root/.openclaw/logs \
    /root/.openclaw/data \
    /root/.openclaw/skills \
    /root/.openclaw/backups

COPY examples/config.example.yaml /root/.openclaw/config.yaml.example
COPY examples/skills/ /root/.openclaw/skills/

VOLUME ["/root/.openclaw"]

ENV PORT=18789
EXPOSE 18789

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD openclaw health || exit 1

CMD ["sh", "-c", "openclaw gateway --bind 0.0.0.0 --port ${PORT}"]
