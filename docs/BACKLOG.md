# Backlog

## Priority Scale
- **P1**: Critical — blocks users or security risk
- **P2**: Important — significant improvement
- **P3**: Nice to have — polish and extras

## Active Items

| ID | Priority | Item | Description | Phase |
|----|----------|------|-------------|-------|
| B-001 | P1 | Smoke tests for all tools | Automated verification that each tool binary works after build. Current CI only runs `cat /etc/mjolnir/TOOLS_TABLE`. | Phase 2 |
| B-002 | P1 | SBOM generation in CI | Wire syft to generate and attach SBOMs to published images. Tool is already installed. | Phase 2 |
| B-003 | P1 | Cosign image signing in CI | Wire cosign to sign images after push. Tool is already installed. Enables consumers to verify authenticity. | Phase 2 |
| B-004 | P2 | Add more tools (Issue #1) | Candidates: protoc binary, crane (OCI manipulation), ko (Go containers), trivy CLI, helm. | Phase 3 |
| B-005 | P2 | Pin tool versions via ARGs | 95% of tools fetch `@latest`. Add `ARG` pins for reproducible builds. | Phase 3 |
| B-006 | P2 | Image size tracking | Track image size over time in CI. Detect bloat. Compare Alpine vs Debian. | Phase 2 |
| B-007 | P2 | Multi-arch support (arm64) | Build linux/arm64 images for ARM CI runners (GitHub, Graviton). | Phase 3 |
| B-008 | P3 | More example projects | Add C/C++, monorepo, and multi-language examples. | Phase 3 |

## Resolved

| ID | Item | Resolved | Notes |
|----|------|----------|-------|
| B-009 | Standardize pnpm installation | 2026-03-28 | Alpine now uses corepack (matching Debian) |
| B-010 | Standardize yq installation | 2026-03-28 | Alpine now downloads mikefarah/yq binary (matching Debian) |
| B-011 | Pin Trivy action version | 2026-03-28 | Pinned to v0.35.0 (supply chain attack mitigation) |
| B-012 | Add Trivy to scheduled builds | 2026-03-28 | Both Debian and Alpine jobs now scan + upload SARIF |
| B-013 | Fix Go example distroless base | 2026-03-28 | Changed from debian13 to debian12 |
