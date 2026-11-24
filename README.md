# Forgejo Docker Setup

Self-hosted Forgejo with a Forgejo Actions runner, running in containers.

## Prerequisites

- Podman and Podman Compose installed
- Add `127.0.0.1 forgejo.local` to your hosts file:
  - **Windows:** `C:\Windows\System32\drivers\etc\hosts`
  - **Linux/Mac:** `/etc/hosts`

## Quick Start

```bash
cp .env.example .env     # set the admin password and runner secret

# Start Forgejo + runner
podman compose up -d

# Watch startup logs
podman logs -f forgejo
```

Access Forgejo at: `http://forgejo.local:3000`

**Default login:**
- Username: `FORGEJO_ADMIN_USER` in `.env`
- Password: `FORGEJO_ADMIN_PASSWORD` in `.env`

## Configuration

### Environment Variables (.env)

| Variable | Description |
|----------|-------------|
| `FORGEJO_HOSTNAME` | Hostname for Forgejo (must match hosts file) |
| `FORGEJO_HTTP_PORT` | HTTP port (same inside and outside the container) |
| `FORGEJO_SSH_PORT` | SSH port for git operations |
| `TZ` | Timezone |
| `FORGEJO_ADMIN_USER` | Admin username (created on first boot; `admin` is reserved) |
| `FORGEJO_ADMIN_PASSWORD` | Admin password (first boot only) |
| `FORGEJO_ADMIN_EMAIL` | Admin email |
| `FORGEJO_RUNNER_SECRET` | Shared runner secret, 40 hex chars (`openssl rand -hex 20`) |

### Forgejo Configuration (app.ini)

Any `app.ini` setting can be set as an env var in `docker-compose.yaml`:
`FORGEJO__<section>__<KEY>`, e.g. `FORGEJO__service__DISABLE_REGISTRATION: 'true'`.
Then apply:

```bash
podman compose up -d
```

## Reset / Troubleshooting

### Reset Admin Password

```bash
podman exec -u git forgejo forgejo admin user change-password --username forgejo-admin --password 'NewPassword123!'
```

### Full Reset (Delete All Data)

```bash
podman compose down -v
podman compose up -d
```

### View Logs

```bash
podman logs -f forgejo
```

## Ports

| Service | Container Port | Host Port |
|---------|---------------|-----------|
| HTTP | 3000 | 3000 |
| SSH | 22 | 2222 |

## Git SSH Access

```bash
git clone ssh://git@forgejo.local:2222/username/repo.git
```

## Forgejo Runner

A Forgejo Actions runner container is included for CI/CD.

### Auto-Registration

On startup Forgejo registers `FORGEJO_RUNNER_SECRET`, and the runner uses the same secret to register itself. It will:

1. Wait for Forgejo to be available
2. Register itself as an instance-wide runner
3. Start processing jobs

```bash
podman logs -f forgejo-runner
```

Workflows go in `.forgejo/workflows/` and use `runs-on: docker` (or `ubuntu-latest`). Labels live in `config/runner.yaml`.

### Re-register Runner

```bash
podman compose rm -sf forgejo-runner
podman volume rm forgejo_forgejo_runner
podman compose up -d
```
