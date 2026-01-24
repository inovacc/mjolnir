#!/bin/bash
# Generate tools version table for mjolnir container

set -e

OUTPUT_FILE="${1:-/etc/mjolnir/TOOLS_TABLE}"

# Helper function to get version
get_version() {
    local cmd="$1"
    local version
    version=$($cmd 2>/dev/null | head -1) || version="not found"
    echo "$version"
}

# Build the table
cat > "$OUTPUT_FILE" << 'HEADER'
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MJOLNIR - Tools Table                             │
└─────────────────────────────────────────────────────────────────────────────┘
HEADER

# Build info
BUILD_TAG=$(cat /etc/mjolnir/BUILD_TAG 2>/dev/null || echo "unknown")
BUILD_VERSION=$(cat /etc/mjolnir/BUILD_VERSION 2>/dev/null || echo "unknown")
BUILD_NAME=$(cat /etc/mjolnir/BUILD_NAME 2>/dev/null || echo "unknown")

cat >> "$OUTPUT_FILE" << EOF

Build Tag:     $BUILD_TAG
Build Version: $BUILD_VERSION
Build Name:    $BUILD_NAME

EOF

# Languages & Runtimes
cat >> "$OUTPUT_FILE" << 'EOF'
┌─────────────────────────────────────────────────────────────────────────────┐
│ Languages & Runtimes                                                        │
├──────────────────┬──────────────────────────────────────────────────────────┤
EOF

printf "│ %-16s │ %-56s │\n" "Go" "$(go version | awk '{print $3}' | sed 's/go//')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "Rust" "$(rustc --version | awk '{print $2}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "Node.js" "$(node --version | sed 's/v//')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "Python" "$(python3 --version | awk '{print $2}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "Bun" "$(bun --version)" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
└──────────────────┴──────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ Package Managers                                                            │
├──────────────────┬──────────────────────────────────────────────────────────┤
EOF

printf "│ %-16s │ %-56s │\n" "npm" "$(npm --version)" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "pnpm" "$(pnpm --version)" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "pip" "$(pip3 --version | awk '{print $2}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "cargo" "$(cargo --version | awk '{print $2}')" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
└──────────────────┴──────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ Build Tools                                                                 │
├──────────────────┬──────────────────────────────────────────────────────────┤
EOF

printf "│ %-16s │ %-56s │\n" "Task" "$(task --version | head -1)" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "GCC" "$(gcc --version | head -1 | awk '{print $NF}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "GoReleaser" "$(goreleaser --version 2>&1 | grep GitVersion | awk '{print $2}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "TypeScript" "$(tsc --version | awk '{print $2}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "air" "$(air -v 2>&1 | grep -oP 'v[\d.]+')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "xc" "$(xc -version | awk '{print $3}')" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
└──────────────────┴──────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ Code Generation                                                             │
├──────────────────┬──────────────────────────────────────────────────────────┤
EOF

printf "│ %-16s │ %-56s │\n" "sqlc" "$(sqlc version)" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "buf" "$(buf --version)" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "protoc-gen-go" "$(protoc-gen-go --version | awk '{print $2}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "protoc-go-grpc" "$(protoc-gen-go-grpc --version | awk '{print $2}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "mockgen" "$(mockgen --version | awk '{print $NF}')" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
└──────────────────┴──────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ Security & Signing                                                          │
├──────────────────┬──────────────────────────────────────────────────────────┤
EOF

printf "│ %-16s │ %-56s │\n" "gitleaks" "$(gitleaks version)" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "cosign" "$(cosign version 2>&1 | grep GitVersion | awk '{print $2}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "syft" "$(syft --version 2>&1 | sed 's/syft //')" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
└──────────────────┴──────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ Containers & Linting                                                        │
├──────────────────┬──────────────────────────────────────────────────────────┤
EOF

printf "│ %-16s │ %-56s │\n" "Docker CLI" "$(docker --version | awk '{print $3}' | tr -d ',')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "hadolint" "$(hadolint --version | awk '{print $4}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "golangci-lint" "$(golangci-lint --version | awk '{print $4}')" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
└──────────────────┴──────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ Data Processing                                                             │
├──────────────────┬──────────────────────────────────────────────────────────┤
EOF

printf "│ %-16s │ %-56s │\n" "jq" "$(jq --version | sed 's/jq-//')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "yq" "$(yq --version | awk '{print $NF}')" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
└──────────────────┴──────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ Utilities                                                                   │
├──────────────────┬──────────────────────────────────────────────────────────┤
EOF

printf "│ %-16s │ %-56s │\n" "git" "$(git --version | awk '{print $3}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "curl" "$(curl --version | head -1 | awk '{print $2}')" >> "$OUTPUT_FILE"
printf "│ %-16s │ %-56s │\n" "glix" "$(which glix >/dev/null 2>&1 && echo 'installed' || echo 'not found')" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
└──────────────────┴──────────────────────────────────────────────────────────┘
EOF

echo "Tools table generated at $OUTPUT_FILE"
