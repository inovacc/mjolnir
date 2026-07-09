#!/usr/bin/env bash
# ============================================================================
# Shared prebuilt-tool installer for the mjolnir images (Debian + Alpine).
#
# Both Dockerfiles COPY and RUN this single script so a tool add/bump is a
# one-place change instead of two synchronized edits (H-06). The only
# per-image difference is the libc, passed as $1 (gnu | musl), which selects
# the bun and rustup artifact variants.
#
# Tool versions are read from the environment (declared as ARG in each
# Dockerfile). Checksum verification of these downloads is added separately
# in H-01b, on top of this shared script.
# ============================================================================
set -euo pipefail

LIBC="${1:?usage: install-tools.sh <gnu|musl>}"
case "$LIBC" in
    gnu)  BUN_ASSET="bun-linux-x64"      ; RUST_TARGET="x86_64-unknown-linux-gnu"  ;;
    musl) BUN_ASSET="bun-linux-x64-musl" ; RUST_TARGET="x86_64-unknown-linux-musl" ;;
    *)    echo "ERROR: libc must be 'gnu' or 'musl', got '$LIBC'" >&2 ; exit 1     ;;
esac

# Required version variables (fail early if a Dockerfile forgot to pass one).
: "${GORELEASER_VERSION:?}" "${GOLANGCI_LINT_VERSION:?}" "${SYFT_VERSION:?}"
: "${COSIGN_VERSION:?}" "${GITLEAKS_VERSION:?}" "${SQLC_VERSION:?}"
: "${TASK_VERSION:?}" "${BUF_VERSION:?}" "${HADOLINT_VERSION:?}"
: "${YQ_VERSION:?}" "${BUN_VERSION:?}" "${PNPM_VERSION:?}"
: "${TYPESCRIPT_VERSION:?}" "${RUSTUP_VERSION:?}" "${RUST_VERSION:?}"
: "${DOCKER_VERSION:?}"

GOBIN=/go/bin
LOCALBIN=/usr/local/bin

# --- Go-toolchain prebuilt binaries into /go/bin ---------------------------

# goreleaser
curl -sSfL "https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz" \
    | tar xz -C "$GOBIN" goreleaser

# golangci-lint (binary nested one dir deep in the tarball)
curl -sSfL "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.tar.gz" \
    | tar xz -C "$GOBIN" --strip-components=1 "golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64/golangci-lint"

# syft
curl -sSfL "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_amd64.tar.gz" \
    | tar xz -C "$GOBIN" syft

# cosign
curl -sSfL -o "$GOBIN/cosign" "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64"
chmod +x "$GOBIN/cosign"

# gitleaks
curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
    | tar xz -C "$GOBIN" gitleaks

# sqlc
curl -sSfL "https://github.com/sqlc-dev/sqlc/releases/download/v${SQLC_VERSION}/sqlc_${SQLC_VERSION}_linux_amd64.tar.gz" \
    | tar xz -C "$GOBIN" sqlc

# task
curl -sSfL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz" \
    | tar xz -C "$GOBIN" task

# buf
curl -sSfL -o "$GOBIN/buf" "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64"
chmod +x "$GOBIN/buf"

# --- Node tooling, Bun, Rust, hadolint, yq, docker into /usr/local/bin -----

# corepack ships with the Debian node image but not the Alpine one, so install
# it explicitly to keep this script libc-agnostic.
npm install -g corepack
corepack enable
corepack prepare "pnpm@${PNPM_VERSION}" --activate
npm install -g "typescript@${TYPESCRIPT_VERSION}"

# bun (libc-specific artifact)
curl -fsSL -o /tmp/bun.zip "https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/${BUN_ASSET}.zip"
unzip -q /tmp/bun.zip -d /tmp
mv "/tmp/${BUN_ASSET}/bun" "$LOCALBIN/bun"
chmod +x "$LOCALBIN/bun"
rm -rf /tmp/bun.zip "/tmp/${BUN_ASSET}"

# rust (libc-specific rustup-init target)
curl -fsSL -o /tmp/rustup-init "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${RUST_TARGET}/rustup-init"
chmod +x /tmp/rustup-init
/tmp/rustup-init -y --no-modify-path --default-toolchain "${RUST_VERSION}"
rm -f /tmp/rustup-init
mv /root/.cargo/bin/* "$LOCALBIN/"
mv /root/.rustup /usr/local/rustup

# hadolint
curl -fsSL -o "$LOCALBIN/hadolint" "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64"
chmod +x "$LOCALBIN/hadolint"

# yq
curl -fsSL -o "$LOCALBIN/yq" "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64"
chmod +x "$LOCALBIN/yq"

# docker CLI (static)
curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" | tar xz -C /tmp
mv /tmp/docker/docker "$LOCALBIN/docker"
rm -rf /tmp/docker

echo "install-tools.sh: all prebuilt tools installed ($LIBC)"
