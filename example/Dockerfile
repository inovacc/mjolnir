# Build stage using mjolnir
FROM ghcr.io/inovacc/mjolnir:latest AS builder

ARG GITHUB_OWNER=inovacc
ENV GITHUB_OWNER=${GITHUB_OWNER}

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN task build:prod

# Production stage using distroless
FROM gcr.io/distroless/static-debian13:nonroot

COPY --from=builder /src/dist/example_linux_amd64_v1 /app

USER nonroot:nonroot
EXPOSE 8080

ENTRYPOINT ["/app"]
