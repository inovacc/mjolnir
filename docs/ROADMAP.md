# Roadmap

## Phase 1: Foundation [COMPLETE]
> Core CI container image with Go, Node.js, Python, Rust toolchains

- [x] Debian and Alpine image variants
- [x] Multi-stage builds with pre-built binaries
- [x] Mythology-themed build metadata and tagging
- [x] CI pipeline with hadolint linting
- [x] Trivy security scanning on tag pushes
- [x] Scheduled bi-weekly rebuilds
- [x] Example projects (Go, Rust, TypeScript, Python)
- [x] Tools table generator for container inspection

## Phase 2: Hardening [IN PROGRESS]
> Improve consistency, security, and CI reliability

- [x] Standardize pnpm installation (corepack on both variants)
- [x] Standardize yq installation (mikefarah/yq binary on both variants)
- [x] Pin Trivy action version (v0.35.0 — supply chain attack mitigation)
- [x] Add Trivy scanning to scheduled builds
- [x] Fix distroless base in Go example (debian12)
- [ ] Add smoke tests for all tools (verify each binary works post-build)
- [ ] Add SBOM generation to CI (syft is installed but not wired to CI)
- [ ] Add cosign image signing to CI (cosign is installed but not wired to CI)
- [ ] Add image size tracking to CI

## Phase 3: Expansion [NOT STARTED]
> More tools, more architectures, more examples

- [ ] Add more tools (Issue #1) — candidates: protoc, crane, ko, trivy CLI, helm
- [ ] Pin tool versions via Dockerfile ARGs for reproducible builds
- [ ] Multi-arch support (linux/arm64)
- [ ] Add more example projects (C/C++, monorepo, multi-language)

## Progress

| Phase | Status | Completion |
|-------|--------|------------|
| Phase 1: Foundation | COMPLETE | 100% |
| Phase 2: Hardening | IN PROGRESS | 55% |
| Phase 3: Expansion | NOT STARTED | 0% |
