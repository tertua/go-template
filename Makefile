.PHONY: clean critic security lint test build build.fast run swag help \
	compose.up compose.up.postgres compose.down compose.logs \
	docker.run docker.network docker.fiber docker.fiber.build docker.postgres docker.redis \
	docker.stop docker.stop.fiber docker.stop.postgres docker.stop.redis

APP_NAME = apiserver
BUILD_DIR = $(PWD)/build

help:
	@echo "Targets:"
	@echo "  run                  dev cepat: swag init + go run (tanpa gate test/lint)"
	@echo "  build                release: full gate (critic/security/lint/test) + binary"
	@echo "  build.fast           binary cepat tanpa gate"
	@echo "  test                 gate kualitas + go test"
	@echo "  swag                 regenerate Swagger docs"
	@echo "  compose.up           app (SQLite) + redis via compose"
	@echo "  compose.up.postgres  app + redis + postgres via compose (butuh SQL_DSN)"
	@echo "  compose.down         stop semua service compose"
	@echo "  docker.*             legacy (deprecated, pakai compose.*)"

clean:
	rm -rf ./build

critic:
	gocritic check -enableAll ./...

security:
	gosec ./...

lint:
	golangci-lint run ./...

test: clean critic security lint
	go test -v -timeout 30s -coverprofile=cover.out -cover ./...
	go tool cover -func=cover.out

build: test
	CGO_ENABLED=0 go build -ldflags="-w -s" -o $(BUILD_DIR)/$(APP_NAME) main.go

build.fast:
	CGO_ENABLED=0 go build -ldflags="-w -s" -o $(BUILD_DIR)/$(APP_NAME) main.go

# Dev loop cepat: regenerate docs lalu jalan langsung (tanpa gate berat).
run: swag
	go run .

compose.up:
	docker compose up --build -d
	@echo "SQLite mode: pastikan SQL_DSN kosong di .env. Swagger: http://127.0.0.1:5000/swagger/index.html"

compose.up.postgres:
	@echo "Postgres mode: pastikan SQL_DSN=postgres://... di .env."
	docker compose --profile postgres up --build -d

compose.down:
	docker compose --profile postgres down

compose.logs:
	docker compose logs -f

# --- Legacy (deprecated, dipertahankan untuk kompatibilitas) ---
docker.run: docker.network docker.postgres swag docker.fiber docker.redis

docker.network:
	docker network inspect template-network >/dev/null 2>&1 || \
	docker network create -d bridge template-network

docker.fiber.build:
	docker build -t apiserver .

docker.fiber: docker.fiber.build
	docker run --rm -d \
		--name template-fiber \
		--network template-network \
		-p 5000:5000 \
		--env-file .env \
		apiserver

docker.postgres:
	docker run --rm -d \
		--name template-postgres \
		--network template-network \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=password \
		-e POSTGRES_DB=postgres \
		-v ${HOME}/dev-postgres/data/:/var/lib/postgresql/data \
		-p 5432:5432 \
		postgres

docker.redis:
	docker run --rm -d \
		--name template-redis \
		--network template-network \
		-p 6379:6379 \
		redis

docker.stop: docker.stop.fiber docker.stop.postgres docker.stop.redis

docker.stop.fiber:
	docker stop template-fiber

docker.stop.postgres:
	docker stop template-postgres

docker.stop.redis:
	docker stop template-redis

swag:
	go run github.com/swaggo/swag/cmd/swag@v1.16.6 init
