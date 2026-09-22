FROM golang:1.27-alpine AS builder

LABEL maintainer="Candro Aleandro <admin@tanet.eu.org> (https://tanet.eu.org/)"

# Move to working directory (/build).
WORKDIR /build

# Copy and download dependency using go mod.
COPY go.mod go.sum ./
RUN go mod download

# Copy the code into the container.
COPY . .

# Set necessary environment variables needed for our image and build the API server.
# NOTE: glebarez/sqlite (modernc) is pure Go, so CGO_ENABLED=0 works on scratch/alpine.
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -ldflags="-s -w" -o apiserver .

FROM alpine:3.21

# CA certs + timezone needed for PostgreSQL TLS and time handling.
RUN apk --no-cache add ca-certificates tzdata \
	&& addgroup -S app && adduser -S app -G app

WORKDIR /app

# Copy only the binary — never bake .env into the image.
# Provide config at runtime: `docker run --env-file .env ...` or via compose.
COPY --from=builder /build/apiserver ./

USER app

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
	CMD wget -qO- http://127.0.0.1:5000/healthz || exit 1

# Command to run when starting the container.
ENTRYPOINT ["./apiserver"]
