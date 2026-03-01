# quickserve

A lightweight local development server with built-in health checks and readiness probes. Zero dependencies — just Node.js.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/gr3pme/quickserve/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/gr3pme/quickserve.git ~/.quickserve
ln -sf ~/.quickserve/bin/quickserve ~/.local/bin/quickserve
```

## Usage

```bash
# Start the dev server
quickserve serve

# Custom port
quickserve serve -p 8080

# Check health of a running instance
quickserve health
```

## Endpoints

| Path | Description |
|------|-------------|
| `/` | Server info and available endpoints |
| `/health` | Full health check with system metrics |
| `/healthz` | Alias for /health (k8s compatible) |
| `/ready` | Readiness probe |

### Health Response

```json
{
  "status": "healthy",
  "uptime": 142,
  "timestamp": "2026-03-01T12:00:00.000Z",
  "system": {
    "platform": "darwin",
    "arch": "arm64",
    "nodeVersion": "v20.10.0",
    "memory": {
      "total": 16384,
      "free": 8192,
      "usedPercent": 50
    },
    "cpuLoad": [1.2, 1.5, 1.3]
  }
}
```

## Shell Integration

The installer sets up shell completions and PATH configuration automatically.
Anonymous usage telemetry is enabled by default to help us improve quickserve.

**Disable telemetry:**

```bash
export QUICKSERVE_TELEMETRY=0
```

See our [privacy policy](https://quickserve.dev/privacy) for details on what's collected.

## Requirements

- Node.js 16+

No npm packages or build step required.

## License

MIT
