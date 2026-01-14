# Go Toolbox Builder

🚀 Go Production Builder – GitHub Actions Toolbox

A hardened GitHub Actions job-container image for building production-grade Go binaries and distroless container images.

This repository provides a standardized Go toolbox builder image designed to run as a GitHub Actions job container, execute task build:production (GoReleaser), and generate minimal distroless production images ready for Kubernetes and cloud deployment.

Production GitHub Actions toolbox for GoReleaser + distroless images.

✨ What it does

Builds static Linux Go binaries using GoReleaser

Supports private GitHub repositories and modules

Produces ultra-minimal distroless images (static-debian13:nonroot)

Fully reproducible and version-pinned toolchain

CI-first, Docker-socket-free design (secure by default)

Optimized for large multi-repo enterprise environments

🛡️ Security & Compliance

No credentials baked into image layers

Secure ephemeral secret handling with BuildKit secrets

Distroless runtime = no shell, no package manager, no CVE noise

Rootless container execution (nonroot)

🧩 CI Architecture
GitHub Actions
┌──────────────┐
│ Toolbox Job  │ → GoReleaser builds static binaries
└──────┬───────┘
│  artifacts
┌──────▼───────┐
│ Runner Job   │ → distroless image build + push to GHCR
└──────────────┘

🐳 Runtime Image Example
FROM gcr.io/distroless/static-debian13:nonroot
COPY dist/myapp /myapp
ENTRYPOINT ["/myapp"]

🧪 Typical workflow
container:
image: ghcr.io/<org>/go-toolbox-builder:1.0.0

steps:
- uses: actions/checkout@v4
- run: task build:production


Dockerfile.distroless

````docker
# ----------------
# GOOGLE DISTROLESS WITH SSL
# ----------------
FROM gcr.io/distroless/static-debian13:nonroot

# Path INSIDE the build context, passed by build arg
ARG BIN_PATH=dist/myapp

COPY ${BIN_PATH} /myapp

EXPOSE 3005

USER nonroot:nonroot

CMD ["./main"]
````

GitHub Actions workflow: build with GoReleaser in job container, then build image on runner

````yaml
name: build

on:
push:
branches: [ "main" ]

jobs:
build-dist:
runs-on: ubuntu-latest
container:
image: ghcr.io/<org>/<repo>/go-toolbox:1.0.0
env:
# For private modules (adjust org)
GOPRIVATE: github.com/<ORG>/*
GONOSUMDB: github.com/<ORG>/*
GIT_TERMINAL_PROMPT: "0"
steps:
- uses: actions/checkout@v4

      # If you need to fetch private deps across repos, prefer a PAT:
      - name: Configure git auth for private modules
        if: ${{ secrets.GH_PAT != '' }}
        shell: bash
        env:
          GH_PAT: ${{ secrets.GH_PAT }}
        run: |
          git config --global url."https://${GH_PAT}:x-oauth-basic@github.com/".insteadOf "https://github.com/"

      - name: Build production (GoReleaser via Task)
        run: task build:production

      - name: Upload dist artifacts
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

build-image:
runs-on: ubuntu-latest
needs: build-dist
permissions:
contents: read
packages: write
steps:
- uses: actions/checkout@v4

      - uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/

      # Find the produced linux binary path (first match)
      - name: Detect linux binary path
        id: bin
        shell: bash
        run: |
          set -euo pipefail
          # Look for an executable named exactly "myapp" inside dist/
          BIN="$(find dist -type f -name myapp -perm -111 | head -n 1)"
          if [ -z "${BIN}" ]; then
            echo "Could not find executable 'myapp' inside dist/"
            find dist -maxdepth 3 -type f -print
            exit 1
          fi
          echo "bin_path=${BIN}" >> "$GITHUB_OUTPUT"
          echo "Detected: ${BIN}"

      - uses: docker/setup-buildx-action@v3

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build & push distroless image
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile.distroless
          push: true
          build-args: |
            BIN_PATH=${{ steps.bin.outputs.bin_path }}
          tags: |
            ghcr.io/<org>/<repo>:${{ github.sha }}
            ghcr.io/<org>/<repo>:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
````

````yaml
version: 3

vars:
  MAIN_PACKAGE: .
  GITHUB_OWNER:
    sh: echo "${GITHUB_OWNER:-github.com/your-org}"

tasks:
  # === INFORMATION ===
  default:
    desc: List all available tasks
    cmds:
      - task --list

  # === BUILD TASKS ===
  build:dev:
    desc: Build development snapshot with goreleaser
    deps: [ generate ]
    env:
      GITHUB_OWNER: "{{.GITHUB_OWNER}}"
    cmds:
      - goreleaser build --snapshot --clean

  build:prod:
    desc: Build production snapshot with goreleaser
    deps: [ generate ]
    env:
      GITHUB_OWNER: "{{.GITHUB_OWNER}}"
    cmds:
      - goreleaser --snapshot --skip-publish,announce --rm-dist

  # === RELEASE TASKS ===
  release:
    desc: Create a production release with goreleaser (requires git tag)
    deps: [ generate ]
    env:
      GITHUB_OWNER: "{{.GITHUB_OWNER}}"
    cmds:
      - goreleaser release --clean

  release:snapshot:
    desc: Create a snapshot release (no git tag required)
    deps: [ generate ]
    env:
      GITHUB_OWNER: "{{.GITHUB_OWNER}}"
    cmds:
      - goreleaser release --snapshot --clean

  release:check:
    desc: Validate goreleaser configuration
    env:
      GITHUB_OWNER: "{{.GITHUB_OWNER}}"
    cmds:
      - goreleaser check
````