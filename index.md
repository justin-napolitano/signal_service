+++
title = "Self-Hosted Signal Gateway with Docker on Ubuntu"
date = "2025-10-21"
description = "A minimal, headless Signal messaging gateway built with Docker Compose and Flask."
author = "Justin Napolitano"
taxonomies.categories = ["projects"]
taxonomies.tags = ["linux","ubuntu","docker","signal","automation","self-hosted","notifications"]
[extra]
toc = true
featured = false
reaction = false
+++

This document describes how to deploy a self-hosted **Signal notification gateway** on Ubuntu using Docker Compose.  
The service allows any local process or script to send messages to Signal through a simple HTTP interface.

---

## Overview

The gateway uses two containers:

| Service | Description | Port |
|----------|--------------|------|
| **signal-api** | Provides REST access to Signal via [`signal-cli-rest-api`](https://github.com/bbernhard/signal-cli-rest-api) | 8085 (localhost) |
| **notifier-gateway** | Lightweight Flask service that accepts POST requests and forwards them to Signal | 8787 (localhost) |

---

## Directory structure

```
signal_service/
├─ docker-compose.yml
├─ .env
├─ signal-cli/            # Persistent Signal link data
└─ notifier-gateway/
   ├─ Dockerfile
   └─ app.py
```

---

## Environment configuration

`.env` (located in the same directory as `docker-compose.yml`):

```bash
TZ=America/New_York
SIGNAL_API_MODE=native
SIGNAL_DATA_DIR=./signal-cli

SIGNAL_NUMBER=+1YOUR_SIGNAL_NUMBER
GATEWAY_TOKEN=$(openssl rand -hex 32)
GATEWAY_PORT=8787
```

`GATEWAY_TOKEN` is an arbitrary shared secret used for authentication.  
Generate a random value with:

```bash
openssl rand -hex 32
```

---

## Docker Compose configuration

```yaml
version: "3.9"

services:
  signal-api:
    image: bbernhard/signal-cli-rest-api:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:8085:8080"
    env_file:
      - .env
    environment:
      MODE: "${SIGNAL_API_MODE:-native}"
      TZ: "${TZ:-UTC}"
    volumes:
      - "${SIGNAL_DATA_DIR:-./signal-cli}:/home/.local/share/signal-cli"

  notifier-gateway:
    build: ./notifier-gateway
    restart: unless-stopped
    env_file:
      - .env
    environment:
      SIGNAL_API_BASE: "http://signal-api:8080"
      SIGNAL_NUMBER: "${SIGNAL_NUMBER}"
      GATEWAY_TOKEN: "${GATEWAY_TOKEN}"
      TZ: "${TZ:-UTC}"
    ports:
      - "127.0.0.1:${GATEWAY_PORT:-8787}:8787"
    depends_on:
      - signal-api
```

---

## Building and running

```bash
docker compose build
docker compose up -d
docker compose ps
```

---

## Linking the Signal account

The Signal API must be linked as a secondary device.

1. Start the API container:
   ```bash
   docker compose up -d signal-api
   ```
2. Create an SSH tunnel from a local machine:
   ```bash
   ssh -N -L 8085:127.0.0.1:8085 user@your-server
   ```
3. In a browser on the local machine, open:
   ```
   http://localhost:8085/v1/qrcodelink?device_name=notifier
   ```
4. On the phone:  
   **Signal → Settings → Linked Devices → + → Scan QR code**

Once linked, close the tunnel. The link is stored in `signal-cli/` and persists across restarts.

---

## Health check

Verify both services are running:

```bash
docker compose ps
curl http://127.0.0.1:8787/healthz
```

---

## Sending a message

If the `.env` file is already sourced into the shell:

```bash
curl -X POST "http://127.0.0.1:${GATEWAY_PORT}/notify"   -H "Authorization: Bearer ${GATEWAY_TOKEN}"   -H "Content-Type: application/json"   -d "{
    \"to\": \"${SIGNAL_NUMBER}\",
    \"message\": \"Signal gateway test message\"
  }"
```

The message should appear on the registered Signal device.

---

## systemd integration

Create `/etc/systemd/system/signal-notifier.service`:

```ini
[Unit]
Description=Signal Notifier Gateway
After=network-online.target docker.service
Wants=network-online.target docker.service

[Service]
User=cobra
Group=docker
WorkingDirectory=/home/cobra/Repos/justin-napolitano/signal_service
Environment=COMPOSE_PROJECT_NAME=signal_service
EnvironmentFile=/home/cobra/Repos/justin-napolitano/signal_service/.env
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable signal-notifier
sudo systemctl start signal-notifier
```

The containers will start automatically after reboot.  
Each container has `restart: unless-stopped`, ensuring resilience if either service crashes.

---

## Security considerations

- All ports are bound to `127.0.0.1`; no external exposure is required.  
- Use a strong random `GATEWAY_TOKEN`.  
- Back up `signal-cli/` after linking; it contains the device keys.  
- Restrict access to `.env` and the Docker socket.

---

## Integration examples

The gateway can receive POST requests from any local service or script.

**Example:**

```bash
curl -sS -X POST http://127.0.0.1:8787/notify   -H "Authorization: Bearer ${GATEWAY_TOKEN}"   -H "Content-Type: application/json"   -d "{
    \"to\": \"${SIGNAL_NUMBER}\",
    \"message\": \"Deployment complete\"
  }"
```

Use this for system monitoring, CI/CD notifications, or personal automation.

---

## Summary

This setup provides a persistent, self-contained Signal gateway with:

- Dockerized isolation and automatic restarts  
- Local-only network exposure  
- Simple HTTP interface for messaging  
- Boot persistence via systemd  

Once configured, it requires no user interaction and can serve as a central messaging hub for any automation or monitoring process.
