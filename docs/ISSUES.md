# Known Issues

## Open

| ID | Severity | Issue | Workaround |
|----|----------|-------|------------|
| I-001 | Low | glix version display shows "installed" instead of actual version | Falls back gracefully; `glix version` attempted first in v1.11.0 |
| I-002 | Info | GitHub Issue #1 — "more tools" requested | See BACKLOG B-004 for candidate list |
| I-003 | Info | No automated smoke tests — broken tool installs only caught by manual inspection | CI verifies container runs and displays tools table, but doesn't test each binary |

## Resolved

| ID | Issue | Resolved | Fix |
|----|-------|----------|-----|
| I-004 | pnpm installed differently on Alpine (npm) vs Debian (corepack) | 2026-03-28 | Standardized to corepack on both |
| I-005 | yq on Alpine was python-yq wrapper, not mikefarah/yq | 2026-03-28 | Alpine now downloads mikefarah/yq binary |
| I-006 | Trivy action used `@master` (unpinned, supply chain risk) | 2026-03-28 | Pinned to `@v0.35.0` |
| I-007 | Scheduled builds had no security scanning | 2026-03-28 | Added Trivy scan + SARIF upload to both jobs |
| I-008 | Go example used `static-debian13:nonroot` (not yet stable) | 2026-03-28 | Changed to `static-debian12:nonroot` |
