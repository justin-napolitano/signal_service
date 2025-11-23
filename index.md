---
slug: "github-signal-service"
title: "signal_service"
repo: "justin-napolitano/signal_service"
githubUrl: "https://github.com/justin-napolitano/signal_service"
generatedAt: "2025-11-23T09:37:57.679724Z"
source: "github-auto"
---


# Signal Notifier Gateway: Technical Overview and Implementation Notes

This project implements a self-hosted Signal notification gateway designed to provide internal systems and automation scripts a reliable method to send messages through Signal without relying on third-party services. It leverages Docker Compose to orchestrate two containers: a `signal-cli-rest-api` container exposing a REST interface to Signal, and a lightweight Flask-based notifier gateway that accepts HTTP POST requests and forwards them to Signal.

## Motivation and Problem Statement

Signal is a secure messaging platform widely used for private communication. However, integrating Signal messaging into automated workflows or internal systems is non-trivial due to the lack of an official public API. This project addresses the problem by using the open-source `signal-cli-rest-api` project, which wraps the Signal CLI in a RESTful interface, and providing a minimal gateway service to simplify usage and secure access.

The goal is to enable local processes or scripts to send Signal messages through a simple HTTP endpoint with token-based authentication, suitable for automation and internal notification purposes.

## Architecture and Components

### signal-cli-rest-api Container

This container runs the `signal-cli-rest-api` project, which exposes Signal functionality over a REST API on port 8080 inside the container. It mounts a persistent volume (`signal-cli/`) to store Signal session data, allowing the Signal account to remain linked across restarts.

The container is configured to bind to localhost only (`127.0.0.1:8085` on the host), restricting external access.

### notifier-gateway Container

A Flask application that exposes two main endpoints:

- `/notify` (POST): Accepts JSON payloads containing `to` (recipient number or group ID), `message`, and optional `attachments`. It authenticates requests using a Bearer token defined in the environment variable `GATEWAY_TOKEN`. Upon validation, it forwards the message to the `signal-cli-rest-api` service.

- `/healthz` (GET): Basic health check endpoint returning HTTP 200.

The gateway container depends on `signal-api` and communicates with it over the Docker network.

## Configuration and Environment

Configuration is managed via environment variables defined in a `.env` file:

- `SIGNAL_NUMBER`: The Signal phone number linked to the service.
- `GATEWAY_TOKEN`: Shared secret for authenticating requests to the notifier gateway.
- `GATEWAY_PORT`: Port on which the notifier gateway listens (default 8787).
- `SIGNAL_API_MODE`, `SIGNAL_DATA_DIR`, `TZ`: Additional configuration for the Signal API container.

The `.env` file is injected into both containers.

## Usage and Workflow

1. Clone the repository and create the `.env` file with appropriate values.
2. Build and start the containers using Docker Compose.
3. Establish an SSH tunnel to forward the Signal API port to localhost.
4. Link your Signal account by scanning the QR code exposed by the Signal API.
5. Send messages by POSTing to the `/notify` endpoint with a valid token.

Example curl command:

```bash
curl -X POST "http://127.0.0.1:${GATEWAY_PORT}/notify" \
  -H "Authorization: Bearer ${GATEWAY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"to": "${SIGNAL_NUMBER}", "message": "Test message"}'
```

## Implementation Details

- The notifier gateway uses Flask and Python's `requests` library to forward messages.
- Authentication is enforced by checking the `Authorization` header against the shared token.
- Attachments can be included as URLs, which the Signal API attempts to download.
- The Signal session data is persisted outside containers to maintain linkage.
- The service listens only on localhost ports to limit exposure.

## Observations and Assumptions

- The project assumes Ubuntu 22.04+ as the host OS.
- systemd integration is mentioned but not detailed; presumably, the service can be run as a systemd service for persistence.
- There is partial code suggesting inbound message forwarding to an external `assistant-core` service, but this is not fully documented or enabled.
- Security relies on a shared secret token; no TLS termination is included by default.

## Potential Improvements

- Implement inbound message handling and forwarding to external systems.
- Add TLS support to secure HTTP endpoints.
- Improve token management, possibly with rotating tokens or OAuth.
- Provide client libraries or SDKs for easier integration.
- Add logging and monitoring capabilities.
- Include automated tests and continuous integration.

## Conclusion

This project provides a practical, minimal solution for integrating Signal messaging into internal automation workflows. By leveraging containerization and a REST API wrapper around Signal CLI, it abstracts the complexity of Signal's native client and enables secure, programmatic message sending. The design prioritizes simplicity, local control, and minimal dependencies, making it suitable for self-hosted environments.

Future work can enhance security, inbound message processing, and usability to better support production use cases.