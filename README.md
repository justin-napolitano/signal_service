# Signal Notifier Gateway

A self-hosted **Signal notification gateway** built with Docker Compose.  
This project provides a lightweight, headless service for sending messages to Signal via simple HTTP POST requests.

---

## Overview

The stack includes two containers:

| Service | Description | Port |
|----------|--------------|------|
| **signal-api** | [`signal-cli-rest-api`](https://github.com/bbernhard/signal-cli-rest-api) container providing REST access to Signal | 8085 (localhost) |
| **notifier-gateway** | Flask service that exposes a `/notify` endpoint and forwards messages to Signal | 8787 (localhost) |

The gateway is intended for automation and internal systems that need reliable push notifications without relying on third-party APIs.

---

## Features

- Self-hosted; no external dependencies  
- REST endpoint for sending messages or attachments  
- Secure access via Bearer token  
- Automatic restart with `restart: unless-stopped`  
- systemd integration for boot persistence  
- Tested on Ubuntu 22.04+

---

## Quick start

### 1. Clone the repository

```bash
git clone https://github.com/<yourname>/signal_service.git
cd signal_service
```

### 2. Create `.env`

```bash
TZ=America/New_York
SIGNAL_API_MODE=native
SIGNAL_DATA_DIR=./signal-cli

SIGNAL_NUMBER=+1YOUR_SIGNAL_NUMBER
GATEWAY_TOKEN=$(openssl rand -hex 32)
GATEWAY_PORT=8787
```

### 3. Build and run

```bash
docker compose build
docker compose up -d
```

### 4. Link your Signal account

```bash
ssh -N -L 8085:127.0.0.1:8085 user@your-server
```

Open in browser:
```
http://localhost:8085/v1/qrcodelink?device_name=notifier
```
Then on your phone:
> Signal → Settings → Linked Devices → + → Scan QR code

The linked session is stored in `signal-cli/`.

---

## Send a test message

If you have sourced `.env`:

```bash
curl -X POST "http://127.0.0.1:${GATEWAY_PORT}/notify"   -H "Authorization: Bearer ${GATEWAY_TOKEN}"   -H "Content-Type: application/json"   -d "{
    \"to\": \"${SIGNAL_NUMBER}\",
    \"message\": \"Signal gateway test message\"
  }"
```

---

## Service management (systemd)

To enable automatic startup at boot:

```bash
sudo nano /etc/systemd/system/signal-notifier.service
```

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

---

## Security notes

- Bind all ports to `127.0.0.1` unless needed externally.  
- Rotate `GATEWAY_TOKEN` regularly.  
- Limit permissions on `.env` and `signal-cli/`.  
- Avoid exposing the service publicly.

---

## Example integrations

```bash
curl -sS -X POST http://127.0.0.1:8787/notify   -H "Authorization: Bearer ${GATEWAY_TOKEN}"   -H "Content-Type: application/json"   -d "{
    \"to\": \"${SIGNAL_NUMBER}\",
    \"message\": \"Build complete on $(hostname)\"
  }"
```

This allows for integration with:

- CI/CD pipelines  
- Monitoring or alerting systems  
- Personal scripts or cron jobs

---

## License

This project is released under the [MIT License](LICENSE).

---

**Author:** Justin Napolitano  
**Last updated:** October 2025
