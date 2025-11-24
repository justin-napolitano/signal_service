---
slug: github-signal-service-writing-overview
id: github-signal-service-writing-overview
title: 'Signal Service: A Self-Hosted Notification Gateway'
repo: justin-napolitano/signal_service
githubUrl: https://github.com/justin-napolitano/signal_service
generatedAt: '2025-11-24T17:59:51.076Z'
source: github-auto
summary: >-
  I've built a self-hosted notification gateway for Signal that I like to call
  Signal Service. This project allows you to send messages using Signal through
  simple HTTP POST requests. It’s lightweight, runs in Docker, and doesn’t have
  any external dependencies, which is a relief in a world of complex
  installations.
tags: []
seoPrimaryKeyword: ''
seoSecondaryKeywords: []
seoOptimized: false
topicFamily: null
topicFamilyConfidence: null
kind: writing
entryLayout: writing
showInProjects: false
showInNotes: false
showInWriting: true
showInLogs: false
---

I've built a self-hosted notification gateway for Signal that I like to call Signal Service. This project allows you to send messages using Signal through simple HTTP POST requests. It’s lightweight, runs in Docker, and doesn’t have any external dependencies, which is a relief in a world of complex installations.

## Why Signal Service Exists

I started this project because I saw a gap for a straightforward way to send notifications via Signal without needing to rely on third-party services. Many notification systems exist, but they often come with steep learning curves or frequent downtime. I wanted something reliable, easy to set up, and flexible enough for my needs. That's when I thought, why not build my own?

## Key Design Decisions

I went with Docker Compose for this project. Docker allows me to encapsulate all dependencies and configurations into containers. Here’s what influenced my design choices:

- **Simplicity:** I kept the architecture straightforward. A single Flask app serves the notification gateway, which talks to a Signal API container.
- **Security:** Access is managed via Bearer token authentication, ensuring that only authorized requests can send messages. 
- **Persistence:** By using a dedicated directory for storing Signal session data, I ensure that the linked status is maintained across container restarts.
- **Tested Environment:** Although it's designed to be OS-agnostic, I focused on ensuring compatibility with Ubuntu 22.04 since it's widely used in server setups.

## Tech Stack

Here's a rundown of the tools and languages used in Signal Service:

- **Python with Flask:** This serves as the backbone of the notification gateway. The simplicity of Flask makes it easy to create REST APIs while keeping the overhead low.
- **Docker Compose:** It handles orchestration, making deployment and scaling straightforward.
- **signal-cli-rest-api:** This container provides the interface for interaction with the Signal API.

## Getting Started with Signal Service

Setting up Signal Service is straightforward. Here’s what you need to do:

### Prerequisites

1. Install Docker and Docker Compose.
2. You’ll need OpenSSL for token generation.

### Installation Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/justin-napolitano/signal_service.git
   cd signal_service
   ```

2. **Create a .env file** based on the example provided. Here’s a simple starter:

   ```dotenv
   TZ=America/New_York
   SIGNAL_API_MODE=native
   SIGNAL_DATA_DIR=./signal-cli
   SIGNAL_NUMBER=+1YOUR_SIGNAL_NUMBER
   GATEWAY_TOKEN=$(openssl rand -hex 32)
   GATEWAY_PORT=8787
   ```

3. **Build and start the services:**

   ```bash
   docker compose build
   docker compose up -d
   ```

4. **Link your Signal account:** Set up an SSH tunnel to connect securely and visit the QR code link in your browser to complete integration.

After your account is linked, all session data will be saved, easing future interactions.

## Project Structure

The layout of Signal Service is clean and intuitive:

```
signal_service/
├─ docker-compose.yml          # Configuration for Docker services
├─ .env                        # Environment variables (keep it private!)
├─ signal-cli/                 # Persisted Signal link data
└─ notifier-gateway/
   ├─ Dockerfile               # Definition for the Flask service
   └─ app.py                   # Implementation of the API
```

- The **`docker-compose.yml`** file includes two services: the Signal API container for REST access and the notifier gateway utilizing Flask.
- The **`.env`** file holds sensitive credentials and configuration details.
- The **`signal-cli/`** directory handles persistent session data.
- The **`app.py`** file includes endpoints for notifications and health checks, all protected by access tokens.

## Tradeoffs and Limitations

Every project has its tradeoffs. Here are a few I’ve encountered:

- **Limited Features:** Right now, the focus is on outbound messages. Inbound message handling is partially implemented but not well-documented. This could be a dealbreaker for complex use cases.
- **Security Enhancements Needed:** Although Bearer tokens are a good start, adding TLS support would significantly improve security.
- **Group Messaging:** Currently, only one-on-one messaging is supported. Group chats are the next logical step.
  
## Future Work / Roadmap

I’ve got a solid list of features I’d like to tackle next:

- Full support for inbound message forwarding to external services.
- Enhanced security with TLS and better token management.
- Support for group messaging and a wider variety of attachment types.
- More detailed documentation with usage examples and potentially client libraries.
- Broaden compatibility beyond Ubuntu 22.04.
- Implement automated tests and CI/CD pipelines for robust updates.

## Conclusion

Signal Service is my answer to efficient, self-hosted notifications using Signal. Its simplicity and reliability have served me well, but there’s always room for improvement. If you want to join me on this journey of building and refining the project, check it out at [GitHub](https://github.com/justin-napolitano/signal_service).

I also share updates and thoughts on projects like this on social platforms. So, if you want to stay in the loop, catch me on Mastodon, Bluesky, or Twitter/X. Let’s keep the conversation going!
