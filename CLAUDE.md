# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub Actions job-container image (Go Toolbox Builder) for building production-grade Go binaries and distroless container images. It is NOT a Go application itself - it's infrastructure tooling.

## Architecture

The repository provides two Docker images working in a CI pipeline:

1. **Toolbox Image** (`Dockerfile`) - Based on `golang:1.25`, used as a GitHub Actions job container to run GoReleaser builds via `task build:prod`

2. **Distroless Runtime Image** (`Dockerfile.distroless`) - Based on `gcr.io/distroless/static-debian13:nonroot`, minimal production image containing only the compiled binary

### CI Flow
```
Toolbox Job Container → GoReleaser builds static binaries → artifacts
                                                              ↓
Runner Job → builds distroless image with binary → pushes to GHCR
```

## Usage Context

This image is consumed by other repositories in their GitHub Actions workflows:

```yaml
container:
  image: ghcr.io/<org>/go-toolbox:1.0.0

steps:
  - run: task build:prod
```

## Taskfile Commands

Projects using this toolbox typically define these tasks:

| Task | Description |
|------|-------------|
| `build:dev` | Build development snapshot with GoReleaser |
| `build:prod` | Build production snapshot with GoReleaser |
| `release` | Create production release (requires git tag) |
| `release:snapshot` | Create snapshot release (no tag required) |
| `release:check` | Validate GoReleaser configuration |

## Toolbox Dockerfile Dependencies

### Base Image
- `golang:1.25` - Official Go image with full toolchain

### System Packages
- `git` - Version control
- `ca-certificates` - SSL/TLS certificates
- `curl` - HTTP client for downloads
- `unzip` - Archive extraction
- `bash` - Shell
- `make` - Build automation

### Go Tools (version-pinned)
| Tool | Version | Purpose |
|------|---------|---------|
| `task` | 3.39.2 | Task runner - executes build tasks |
| `goreleaser` | 2.6.1 | Release automation for Go projects |
| `sqlc` | 1.27.0 | Type-safe SQL code generator |
| `protoc-gen-go` | 1.28.0 | Protocol Buffer Go code generator |
| `protoc-gen-go-grpc` | 1.2.0 | gRPC Go code generator |

### Binary Tools
| Tool | Version | Purpose |
|------|---------|---------|
| `protoc` | 33.4 | Protocol Buffer compiler |

### Build Args
- `HTTP_PROXY` / `HTTPS_PROXY` - Proxy support for corporate environments
- `TASK_VERSION` - Task runner version
- `GORELEASER_VERSION` - GoReleaser version
- `SQLC_VERSION` - SQLC version
- `PROTOC_VERSION` - Protocol Buffer compiler version
- `PROTOC_GEN_GO_VERSION` - protoc-gen-go version
- `PROTOC_GEN_GO_GRPC_VERSION` - protoc-gen-go-grpc version

### Build Requirements
- CGO disabled (`CGO_ENABLED=0`) for static binaries
- Linux target (`GOOS=linux`, `GOARCH=amd64`)
- Git credentials configured at runtime for private modules

### Distroless Runtime Image
- `gcr.io/distroless/static-debian13:nonroot` - Minimal base with SSL certificates
- Runs as `nonroot:nonroot` user
- No shell, no package manager

## Key Files

- `Dockerfile` - Toolbox builder image definition
- `Dockerfile.distroless` - Minimal production runtime image template
- `.github/workflows/ci.yml` - CI pipeline configuration

## Environment Variables (when used in workflows)

- `GOPRIVATE` - For private Go modules (e.g., `github.com/<ORG>/*`)
- `GONOSUMDB` - Skip checksum for private modules
- `GIT_TERMINAL_PROMPT` - Set to `0` to disable git credential prompts
- `GH_PAT` - GitHub Personal Access Token for private repo access
- `GITHUB_OWNER` - Organization/owner for GoReleaser builds
