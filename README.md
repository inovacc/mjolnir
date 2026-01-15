# ⚡ Mjolnir

> **The hammer for every build**

[![GHCR](https://img.shields.io/badge/GHCR-ghcr.io%2Finovacc%2Fmjolnir-blue?logo=docker)](https://github.com/inovacc/mjolnir/pkgs/container/mjolnir)
[![CI Workflow](https://github.com/inovacc/mjolnir/actions/workflows/ci.yml/badge.svg)](https://github.com/inovacc/mjolnir/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/inovacc/mjolnir)](LICENSE)

A powerful multi-language build container for GitHub Actions. Forge your builds with the power of gods.

```bash
# Debian-based (default)
docker pull ghcr.io/inovacc/mjolnir:latest

# Alpine-based (smaller image)
docker pull ghcr.io/inovacc/mjolnir:alpine
```

## Features

- **Multi-language Support** - Go, Node.js, Python, Rust toolchains
- **GoReleaser** - Build static Linux Go binaries
- **Task** - Task runner for build automation
- **Protobuf** - Protocol Buffer compiler with Go plugins
- **SQLC** - Type-safe SQL code generator
- **Security** - Hadolint linting + Trivy vulnerability scanning
- **Scheduled Builds** - Automatic bi-weekly rebuilds for security updates

## Image Flavors

| Flavor | Base | Tag | Size |
|--------|------|-----|------|
| Debian | `golang:1.25` | `latest`, `debian` | ~1.6GB |
| Alpine | `golang:1.25-alpine` | `alpine` | ~700MB |

## Included Tools

### Go Ecosystem

| Tool | Version | Purpose |
|------|---------|---------|
| Go | 1.25 | Go toolchain |
| Task | latest | Task runner |
| GoReleaser | latest | Release automation |
| SQLC | latest | SQL code generator |
| Protoc | 33.4 | Protocol Buffer compiler |
| protoc-gen-go | latest | Go protobuf generator |
| protoc-gen-go-grpc | latest | Go gRPC generator |

### Node.js Ecosystem

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | OS package | JavaScript runtime |
| npm | OS package | Package manager |
| pnpm | latest | Fast package manager |
| bun | latest | Fast JavaScript runtime |

### Other Languages

| Tool | Version | Purpose |
|------|---------|---------|
| Python 3 | OS package | Python runtime |
| GCC | OS package | C/C++ compiler |
| Rust (rustc) | stable | Rust compiler |
| Cargo | stable | Rust package manager |

## Image Tagging

Images use mythology-themed tags with Go version, flavor suffix, and divine names:

```
<go-version><flavor>-<figure>-<realm>
```

### Tag Format

| Component | Alpine | Debian | Purpose |
|-----------|--------|--------|---------|
| Go version | `1.25` | `1.25` | Go toolchain version |
| Flavor | `A` | `D` | Alpine or Debian |
| Figure | `thor` | `thor` | Mythological figure |
| Realm | `asgard` | `asgard` | Divine realm/attribute |

**Examples:**
- Alpine: `ghcr.io/inovacc/mjolnir:1.25A-thor-asgard`
- Debian: `ghcr.io/inovacc/mjolnir:1.25D-zeus-olympus`

### Available Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest Debian build |
| `debian` | Latest Debian build |
| `alpine` | Latest Alpine build |
| `1.25D-<figure>-<realm>` | Specific Debian build |
| `1.25A-<figure>-<realm>` | Specific Alpine build |
| `x.y.z` | Semantic version release |

### Local Tag Generation

```bash
# Generate tags
task taggen              # Full Debian tag: 1.25D-odin-valhalla
task taggen:alpine       # Full Alpine tag: 1.25A-odin-valhalla
task taggen:debian       # Full Debian tag: 1.25D-odin-valhalla
task taggen:name         # Random name only: odin-valhalla

# Build images
task docker:build:debian  # Build Debian image
task docker:build:alpine  # Build Alpine image
task docker:build:both    # Build both with same name
```

## Quick Start

### Use as GitHub Actions Job Container

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/inovacc/mjolnir:latest
    steps:
      - uses: actions/checkout@v4
      - run: task build:prod
```

### Use Alpine for Faster Pulls

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/inovacc/mjolnir:alpine
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
      image: ghcr.io/inovacc/mjolnir:latest
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
taggen → lint ──────────────────────┐
           ├── build-debian ────────┼── security → release
           └── build-alpine ────────┘
```

| Job | Description |
|-----|-------------|
| `taggen` | Generate consistent mythology name for both builds |
| `lint` | Hadolint Dockerfile best practices |
| `build-debian` | Build Debian image and verify tools |
| `build-alpine` | Build Alpine image and verify tools |
| `security` | Trivy vulnerability scan (CRITICAL, HIGH) |
| `release` | Push to GHCR (on tags only) |

### Scheduled Builds

Images are automatically rebuilt on the 1st and 15th of each month to include:
- Latest Go tool versions
- Security patches from base images
- Updated dependencies

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

## Mythology

Mjolnir (pronounced "mee-ol-neer") is Thor's hammer in Norse mythology - a weapon of immense power forged by dwarven blacksmiths. Like the legendary hammer, this container forges your builds with divine precision.

Image tags draw from world mythology:
- **Norse**: Thor, Odin, Freya, Asgard, Valhalla
- **Greek**: Zeus, Athena, Apollo, Olympus
- **Roman**: Jupiter, Mars, Venus
- **Egyptian**: Ra, Anubis, Isis
- **Celtic**: Dagda, Morrigan, Lugh

## License

[MIT](LICENSE)
