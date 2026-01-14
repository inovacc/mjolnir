FROM golang:1.25

ARG HTTP_PROXY=
ARG HTTPS_PROXY=
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates curl unzip bash make \
    && rm -rf /var/lib/apt/lists/*

# ---- pin versions (adjust as you like) ----
ARG SQLC_VERSION=1.27.0
ARG TASK_VERSION=3.39.2
ARG GORELEASER_VERSION=2.6.1

ARG PROTOC_VERSION=33.4
ARG PROTOC_GEN_GO_VERSION=1.28.0
ARG PROTOC_GEN_GO_GRPC_VERSION=1.2.0

RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc@v${SQLC_VERSION} \
 && go install github.com/go-task/task/v3/cmd/task@v${TASK_VERSION} \
 && go install github.com/goreleaser/goreleaser/v2@v${GORELEASER_VERSION} \
 && go install google.golang.org/protobuf/cmd/protoc-gen-go@v${PROTOC_GEN_GO_VERSION} \
 && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${PROTOC_GEN_GO_GRPC_VERSION}

RUN PROTOC_ZIP="protoc-${PROTOC_VERSION}-linux-x86_64.zip" \
 && curl -fL -o "${PROTOC_ZIP}" \
      "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC_ZIP}" \
 && unzip -o "${PROTOC_ZIP}" -d /usr/local bin/protoc \
 && unzip -o "${PROTOC_ZIP}" -d /usr/local 'include/*' \
 && rm -f "${PROTOC_ZIP}"

ENV PATH="/go/bin:${PATH}"

# Let GitHub Actions control how steps run
CMD ["bash", "-c", "go version && task --version && sqlc version && goreleaser --version && protoc --version && protoc-gen-go --version && protoc-gen-go-grpc --version"]
