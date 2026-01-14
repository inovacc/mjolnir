# Go Toolbox Builder

[![GHCR](https://img.shields.io/badge/GHCR-ghcr.io%2Finovacc%2Fgo--toolbox-blue?logo=docker)](https://github.com/inovacc/go-toolbox/pkgs/container/go-toolbox)
[![CI Workflow](https://github.com/inovacc/go-toolbox/actions/workflows/ci.yml/badge.svg)](https://github.com/inovacc/go-toolbox/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/inovacc/go-toolbox)](LICENSE)

A hardened GitHub Actions job-container image for building production-grade Go binaries.

```bash
docker pull ghcr.io/inovacc/go-toolbox:latest
```

## Features

- **GoReleaser** - Build static Linux Go binaries
- **Task** - Task runner for build automation
- **Protobuf** - Protocol Buffer compiler with Go plugins
- **SQLC** - Type-safe SQL code generator
- **Security** - Hadolint linting + Trivy vulnerability scanning

## Included Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Go | 1.25 | Go toolchain |
| Task | 3.39.2 | Task runner |
| GoReleaser | 2.6.1 | Release automation |
| SQLC | 1.27.0 | SQL code generator |
| Protoc | 33.4 | Protocol Buffer compiler |
| protoc-gen-go | 1.28.0 | Go protobuf generator |
| protoc-gen-go-grpc | 1.2.0 | Go gRPC generator |

## Quick Start

### Use as GitHub Actions Job Container

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

### Use with Private Modules

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/inovacc/go-toolbox:latest
      env:
        GOPRIVATE: github.com/your-org/*
        GONOSUMDB: github.com/your-org/*
    steps:
      - uses: actions/checkout@v4

      - name: Configure git auth
        env:
          GH_PAT: ${{ secrets.GH_PAT }}
        run: |
          git config --global url."https://${GH_PAT}@github.com/".insteadOf "https://github.com/"

      - run: task build:prod
```

## Creating Distroless Production Images

After building your Go binary, create a minimal production image:

```dockerfile
FROM gcr.io/distroless/static-debian13:nonroot
ARG BIN_PATH=dist/myapp
COPY ${BIN_PATH} /app
USER nonroot:nonroot
ENTRYPOINT ["/app"]
```

**Why distroless?**
- No shell, no package manager = minimal attack surface
- ~2MB base image vs ~100MB+ for alpine
- No CVE noise from unused packages
- Runs as non-root by default

## CI Pipeline

```
lint → build → security → release
```

| Job | Description |
|-----|-------------|
| `lint` | Hadolint Dockerfile best practices |
| `build` | Build image and verify all tools |
| `security` | Trivy vulnerability scan (CRITICAL, HIGH) |
| `release` | Push to GHCR (on tags only) |

## Sample Taskfile

```yaml
version: 3

tasks:
  build:dev:
    desc: Build development snapshot
    cmds:
      - goreleaser build --snapshot --clean

  build:prod:
    desc: Build production snapshot
    cmds:
      - goreleaser build --snapshot --clean

  release:
    desc: Create production release (requires git tag)
    cmds:
      - goreleaser release --clean
```

## License

[MIT](LICENSE)
