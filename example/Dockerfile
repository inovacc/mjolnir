# Build stage using go-toolbox
FROM ghcr.io/inovacc/go-toolbox:latest AS builder

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN task build:prod

# Production stage using distroless
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /src/dist/example_linux_amd64_v1 /app

USER nonroot:nonroot
EXPOSE 8080

ENTRYPOINT ["/app"]
