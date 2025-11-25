---
slug: github-signal-service
id: github-signal-service
title: Self-Hosted Signal Notification Gateway with Docker Compose
repo: justin-napolitano/signal_service
githubUrl: https://github.com/justin-napolitano/signal_service
generatedAt: '2025-11-24T21:36:22.289Z'
source: github-auto
summary: >-
  Build a lightweight Signal notification service using Docker Compose, featuring REST access and
  secure authentication.
tags:
  - docker-compose
  - flask
  - signal-cli
  - python
  - self-hosted
seoPrimaryKeyword: self-hosted signal notification gateway
seoSecondaryKeywords:
  - docker signal service
  - signal-cli integration
  - flask notification service
  - http POST signal
  - secure message gateway
seoOptimized: true
topicFamily: automation
topicFamilyConfidence: 0.9
kind: project
entryLayout: project
showInProjects: true
showInNotes: false
showInWriting: false
showInLogs: false
---

A self-hosted Signal notification gateway built with Docker Compose. This project provides a lightweight, headless service for sending messages to Signal via simple HTTP POST requests.

---

## Features

- Self-hosted; no external dependencies
- REST endpoint for sending messages or attachments
- Secure access via Bearer token authentication
- Automatic restart with `restart: unless-stopped`
- systemd integration for boot persistence (assumed)
- Tested on Ubuntu 22.04+

---

## Tech Stack

- Python (Flask) for the notifier gateway service
- Docker Compose for container orchestration
- `signal-cli-rest-api` container for Signal REST access

---

## Getting Started

### Prerequisites

- Docker and Docker Compose installed
- OpenSSL for token generation

### Installation and Run

1. Clone the repository

```bash
git clone https://github.com/justin-napolitano/signal_service.git
cd signal_service
```

2. Create `.env` file based on `env-example` (or use the example below)

```bash
TZ=America/New_York
SIGNAL_API_MODE=native
SIGNAL_DATA_DIR=./signal-cli

SIGNAL_NUMBER=+1YOUR_SIGNAL_NUMBER
GATEWAY_TOKEN=$(openssl rand -hex 32)
GATEWAY_PORT=8787
```

3. Build and start the services

```bash
docker compose build
docker compose up -d
```

4. Link your Signal account

Set up an SSH tunnel to forward the Signal API port:

```bash
ssh -N -L 8085:127.0.0.1:8085 user@your-server
```

Open in your browser:

```
http://localhost:8085/v1/qrcodelink?device_name=notifier
```

Then on your phone:

- Open Signal → Settings → Linked Devices → + → Scan QR code

The linked session data is persisted in the `signal-cli/` directory.

---

## Project Structure

```
signal_service/
├─ docker-compose.yml          # Docker Compose configuration
├─ .env                       # Environment variables (not committed)
├─ signal-cli/                # Persistent Signal link data
└─ notifier-gateway/
   ├─ Dockerfile              # Dockerfile for notifier gateway
   └─ app.py                  # Flask app implementing notification API
```

- `docker-compose.yml` defines two services: `signal-api` (Signal REST API container) and `notifier-gateway` (Flask service).
- `.env` contains configuration variables such as Signal number, tokens, and ports.
- `signal-cli/` stores persistent Signal session data.
- `notifier-gateway/app.py` implements `/notify` and `/healthz` endpoints with token-based authentication.

---

## Future Work / Roadmap

- Add support for inbound message forwarding to an external service (partially implemented but not documented).
- Enhance security with TLS support and improved token management.
- Add support for group messaging and richer attachment types.
- Provide detailed usage examples and client libraries.
- Extend platform support beyond Ubuntu 22.04.
- Add automated tests and CI/CD pipelines.

---

## License

_Assumed MIT or similar open source license (not specified)._

