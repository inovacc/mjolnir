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
# Dockerfile). Downloads are verified against each release's own published
# SHA256 checksums before install (H-01b). Three tools (sqlc, docker, yq)
# publish no simple checksums file and remain version-pinned only; each logs
# a WARN so the gap is visible. TODO: add checksum coverage for those.
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

# ---------------------------------------------------------------------------
# Checksum helpers
# ---------------------------------------------------------------------------

# Verify $1 (a local file) against $2 (expected lowercase sha256 hex).
verify_sha256() {
    local file="$1" expected="$2"
    if [ -z "$expected" ]; then
        echo "ERROR: empty expected checksum for $file" >&2
        exit 1
    fi
    echo "${expected}  ${file}" | sha256sum -c - >/dev/null
    # Log to stderr: this function runs inside a $(...) capture, so anything on
    # stdout would be swallowed into the caller's variable.
    echo "  verified sha256 $(basename "$file")" >&2
}

# Extract the sha256 for asset $2 from a checksums file at URL $1.
# Handles both "<hash>  file" and "<hash>  *file" (binary marker) lines.
sha_from_sumsfile() {
    local sums_url="$1" asset="$2" hash
    hash=$(curl -sSfL "$sums_url" | awk -v a="$asset" '$2 == a || $2 == "*"a {print $1; exit}')
    if [ -z "$hash" ]; then
        echo "ERROR: no checksum for '$asset' in $sums_url" >&2
        exit 1
    fi
    printf '%s' "$hash"
}

# Extract the single sha256 from a one-line .sha256 file at URL $1.
sha_from_single() {
    curl -sSfL "$1" | awk '{print $1; exit}'
}

# Download $1 to a temp file, verify against expected sha $2, echo the path.
download_verify() {
    local url="$1" expected="$2" tmp
    tmp="$(mktemp)"
    curl -sSfL -o "$tmp" "$url"
    verify_sha256 "$tmp" "$expected"
    printf '%s' "$tmp"
}

GH="https://github.com"

# --- Go-toolchain prebuilt binaries into /go/bin ---------------------------

# goreleaser (tar.gz, checksums.txt)
asset="goreleaser_Linux_x86_64.tar.gz"
tmp="$(download_verify "${GH}/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/${asset}" \
    "$(sha_from_sumsfile "${GH}/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/checksums.txt" "$asset")")"
tar xz -C "$GOBIN" -f "$tmp" goreleaser
rm -f "$tmp"

# golangci-lint (tar.gz, binary nested one dir deep)
asset="golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.tar.gz"
tmp="$(download_verify "${GH}/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/${asset}" \
    "$(sha_from_sumsfile "${GH}/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-checksums.txt" "$asset")")"
tar xz -C "$GOBIN" -f "$tmp" --strip-components=1 "golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64/golangci-lint"
rm -f "$tmp"

# syft (tar.gz)
asset="syft_${SYFT_VERSION}_linux_amd64.tar.gz"
tmp="$(download_verify "${GH}/anchore/syft/releases/download/v${SYFT_VERSION}/${asset}" \
    "$(sha_from_sumsfile "${GH}/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_checksums.txt" "$asset")")"
tar xz -C "$GOBIN" -f "$tmp" syft
rm -f "$tmp"

# cosign (raw binary)
asset="cosign-linux-amd64"
tmp="$(download_verify "${GH}/sigstore/cosign/releases/download/v${COSIGN_VERSION}/${asset}" \
    "$(sha_from_sumsfile "${GH}/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign_checksums.txt" "$asset")")"
install -m 0755 "$tmp" "$GOBIN/cosign"
rm -f "$tmp"

# gitleaks (tar.gz)
asset="gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"
tmp="$(download_verify "${GH}/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/${asset}" \
    "$(sha_from_sumsfile "${GH}/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_checksums.txt" "$asset")")"
tar xz -C "$GOBIN" -f "$tmp" gitleaks
rm -f "$tmp"

# task (tar.gz)
asset="task_linux_amd64.tar.gz"
tmp="$(download_verify "${GH}/go-task/task/releases/download/v${TASK_VERSION}/${asset}" \
    "$(sha_from_sumsfile "${GH}/go-task/task/releases/download/v${TASK_VERSION}/task_checksums.txt" "$asset")")"
tar xz -C "$GOBIN" -f "$tmp" task
rm -f "$tmp"

# buf (raw binary, sha256.txt)
asset="buf-Linux-x86_64"
tmp="$(download_verify "${GH}/bufbuild/buf/releases/download/v${BUF_VERSION}/${asset}" \
    "$(sha_from_sumsfile "${GH}/bufbuild/buf/releases/download/v${BUF_VERSION}/sha256.txt" "$asset")")"
install -m 0755 "$tmp" "$GOBIN/buf"
rm -f "$tmp"

# sqlc (tar.gz) -- no upstream checksums file published; version-pinned only.
echo "WARN: sqlc ${SQLC_VERSION} installed without checksum (no upstream checksums file)" >&2
curl -sSfL "${GH}/sqlc-dev/sqlc/releases/download/v${SQLC_VERSION}/sqlc_${SQLC_VERSION}_linux_amd64.tar.gz" \
    | tar xz -C "$GOBIN" sqlc

# --- Node tooling, Bun, Rust, hadolint, yq, docker into /usr/local/bin -----

# corepack ships with the Debian node image but not the Alpine one, so install
# it explicitly to keep this script libc-agnostic.
npm install -g corepack
corepack enable
corepack prepare "pnpm@${PNPM_VERSION}" --activate
npm install -g "typescript@${TYPESCRIPT_VERSION}"

# bun (libc-specific artifact, SHASUMS256.txt)
asset="${BUN_ASSET}.zip"
tmp="$(download_verify "${GH}/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/${asset}" \
    "$(sha_from_sumsfile "${GH}/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/SHASUMS256.txt" "$asset")")"
unzip -q "$tmp" -d /tmp
mv "/tmp/${BUN_ASSET}/bun" "$LOCALBIN/bun"
chmod +x "$LOCALBIN/bun"
rm -rf "$tmp" "/tmp/${BUN_ASSET}"

# rust (libc-specific rustup-init, verified via its .sha256 sidecar).
# rustup-init dispatches on its own argv[0], so the binary MUST be named
# "rustup-init" -- an mktemp name makes it treat the filename as a proxy and
# fail with "unknown proxy name". Download to a fixed path instead of the
# generic download_verify helper.
rustup_base="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${RUST_TARGET}"
curl -fsSL -o /tmp/rustup-init "${rustup_base}/rustup-init"
verify_sha256 /tmp/rustup-init "$(sha_from_single "${rustup_base}/rustup-init.sha256")"
chmod +x /tmp/rustup-init
/tmp/rustup-init -y --no-modify-path --default-toolchain "${RUST_VERSION}"
rm -f /tmp/rustup-init
mv /root/.cargo/bin/* "$LOCALBIN/"
mv /root/.rustup /usr/local/rustup

# hadolint (raw binary, .sha256 sidecar)
tmp="$(download_verify "${GH}/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64" \
    "$(sha_from_single "${GH}/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64.sha256")")"
install -m 0755 "$tmp" "$LOCALBIN/hadolint"
rm -f "$tmp"

# yq (raw binary) -- checksums file uses a non-standard multi-column format;
# version-pinned only for now. TODO: parse yq checksums_hashes_order.
echo "WARN: yq ${YQ_VERSION} installed without checksum (non-standard checksums format)" >&2
curl -fsSL -o "$LOCALBIN/yq" "${GH}/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64"
chmod +x "$LOCALBIN/yq"

# docker CLI (static) -- no upstream checksums file published; version-pinned.
echo "WARN: docker ${DOCKER_VERSION} installed without checksum (no upstream checksums file)" >&2
curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" | tar xz -C /tmp
mv /tmp/docker/docker "$LOCALBIN/docker"
rm -rf /tmp/docker

echo "install-tools.sh: all prebuilt tools installed ($LIBC)"
