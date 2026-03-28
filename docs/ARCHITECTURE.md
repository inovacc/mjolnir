# Architecture

## System Overview

```mermaid
graph TD
    subgraph "Source Repository"
        DF_D[Dockerfile.debian]
        DF_A[Dockerfile.alpine]
        TG[scripts/taggen.sh]
        TT[scripts/generate-tools-table.sh]
        TF[Taskfile.yml]
    end

    subgraph "CI/CD"
        LINT[hadolint lint]
        BUILD_D[Build Debian]
        BUILD_A[Build Alpine]
        SCAN[Trivy Scan]
        PUSH[Push to GHCR]
        SCHED[Scheduled Rebuild<br/>1st & 15th monthly]
    end

    subgraph "GHCR Registry"
        IMG_D["ghcr.io/inovacc/mjolnir:latest"]
        IMG_A["ghcr.io/inovacc/mjolnir:latest-alpine"]
        IMG_V["ghcr.io/inovacc/mjolnir:x.y.z"]
    end

    subgraph "Consumer CI"
        GHA[GitHub Actions]
        OTHER[Other CI systems]
    end

    DF_D --> LINT --> BUILD_D
    DF_A --> LINT --> BUILD_A
    BUILD_D --> SCAN --> PUSH --> IMG_D & IMG_V
    BUILD_A --> SCAN --> PUSH --> IMG_A
    SCHED --> BUILD_D & BUILD_A
    IMG_D --> GHA & OTHER
    IMG_A --> GHA & OTHER
    TG --> BUILD_D & BUILD_A
    TT --> BUILD_D & BUILD_A
```

## Build Process

```mermaid
graph LR
    subgraph "Stage 1: Compile Go Tools"
        GO_INSTALL["go install @latest<br/>protoc-gen-go<br/>protoc-gen-go-grpc<br/>mockgen, air, xc<br/>govulncheck, glix"]
    end

    subgraph "Stage 2: Assemble Image"
        APT["OS packages<br/>git, curl, jq, gcc, python3"]
        BINS["Pre-built binaries<br/>goreleaser, cosign, gitleaks<br/>sqlc, buf, hadolint, yq"]
        RUNTIMES["Language runtimes<br/>Node.js, pnpm, bun<br/>Rust, TypeScript"]
        DOCKER["Docker CLI<br/>v27.5.1"]
        META["Build metadata<br/>/etc/mjolnir/*"]
    end

    GO_INSTALL --> APT --> BINS --> RUNTIMES --> DOCKER --> META
```

## Project Structure

```
mjolnir/
├── Dockerfile.debian          # Debian-based image (default)
├── Dockerfile.alpine          # Alpine-based image (smaller)
├── Taskfile.yml               # Local build/dev tasks
├── CLAUDE.md                  # Project conventions
├── README.md                  # User-facing documentation
├── LICENSE                    # MIT license
├── scripts/
│   ├── generate-tools-table.sh  # Builds ASCII tools table at build time
│   └── taggen.sh                # Mythology-themed tag generator
├── examples/
│   ├── go/                    # GoReleaser + Cobra example
│   ├── rust/                  # Actix-web example
│   ├── typescript/            # Bun example
│   └── python/                # FastAPI example
├── docs/
│   ├── ARCHITECTURE.md        # This file
│   ├── ROADMAP.md             # Development phases
│   ├── BACKLOG.md             # Prioritized work items
│   └── ISSUES.md              # Known issues
└── .github/workflows/
    ├── ci.yml                 # Main CI pipeline (tag + PR)
    └── scheduled-build.yml    # Bi-weekly rebuilds
```

## Tool Installation Methods

| Method | Tools | Reproducibility |
|--------|-------|-----------------|
| `go install @latest` | protoc-gen-go, protoc-gen-go-grpc, mockgen, air, xc, govulncheck, glix | Low (unpinned) |
| GitHub Releases API (`latest`) | goreleaser, cosign, gitleaks, sqlc, buf, hadolint, yq | Low (unpinned) |
| Install scripts (`latest`) | golangci-lint, syft, task, bun | Low (unpinned) |
| OS package manager | git, curl, jq, python3, Node.js, npm, gcc | Medium (base image pins) |
| Pinned version | Docker CLI (27.5.1), TypeScript (5.9.3) | High |
| Channel | Rust (stable), Go (1.25.x) | Medium |
