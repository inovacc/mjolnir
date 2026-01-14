# Go Toolbox Example API

A minimal Go web API demonstrating how to use [go-toolbox](https://github.com/inovacc/go-toolbox) for building production-grade Docker images.

## Project Structure

```
example/
├── main.go              # Application entrypoint
├── cmd/root.go          # Cobra CLI root command
├── internal/api/api.go  # HTTP server and handlers
├── Dockerfile           # Multi-stage build (go-toolbox + distroless)
├── Taskfile.yml         # Build automation
├── .goreleaser.yml      # Release configuration
└── go.mod
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Root endpoint |
| GET | `/health` | Health check with version info |
| GET | `/api/hello` | Hello World |
| GET | `/api/hello/{name}` | Personalized greeting |

## Quick Start

### Run Locally

```bash
task run
```

### Build with Docker

```bash
# Build image
task docker:build

# Run container
task docker:run

# Test endpoints
curl http://localhost:8080/health
curl http://localhost:8080/api/hello/World
```

### Build Binary Only

```bash
# Development build (current platform)
task build:dev

# Production build (Linux amd64/arm64)
task build:prod
```

## Using in GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/inovacc/go-toolbox:latest
    steps:
      - uses: actions/checkout@v4
      - run: task build:prod
```

## Docker Image Details

The Dockerfile uses a multi-stage build:

1. **Builder stage**: Uses `ghcr.io/inovacc/go-toolbox` with GoReleaser
2. **Production stage**: Uses `gcr.io/distroless/static-debian12:nonroot`

Final image size: ~5MB
