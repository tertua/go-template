# go-template

<img src="https://img.shields.io/badge/Go-1.27+-00ADD8?style=for-the-badge&logo=go" alt="go version" />&nbsp;<a href="https://goreportcard.com/report/github.com/tertua/go-template" target="_blank"><img src="https://img.shields.io/badge/Go_report-A+-success?style=for-the-badge&logo=none" alt="go report" /></a>&nbsp;<img src="https://img.shields.io/badge/license-Apache_2.0-red?style=for-the-badge&logo=none" alt="license" />

Template backend Go siap pakai untuk memulai project apapun: REST API dengan auth JWT, database, cache, dan Swagger docs. Klik **Use this template** untuk project baru.

Stack: Go 1.27, [Fiber v3](https://gofiber.io/), PostgreSQL / SQLite (via GORM, tanpa migrasi manual), Redis, JWT, Swagger, Docker.

## ⚡️ Quick start

1. Buat project baru dari template ini (tombol **Use this template**), lalu clone.
2. Bootstrap sekali-jalan (ganti module path, reset README+LICENSE, bersihkan git history):

```bash
./init.sh --module github.com/tertua/namaproject --author "Nama Kamu"
```

3. Salin `.env.example` menjadi `.env` dan isi sesuai kebutuhan.
3. Tanpa `SQL_DSN`, app memakai SQLite lokal zero-config (`SQLITE_PATH`, default `./data/go-template.db`) — cocok untuk dev/proyek kecil. Isi `SQL_DSN=postgres://...` untuk PostgreSQL produksi. Install [Docker](https://www.docker.com/get-started) dan tools berikut:

   - Swagger docs via `make swag` (hermetic: `go run swag@v1.16.6`, tanpa install global)
   - [gosec](https://github.com/securego/gosec), [go-critic](https://github.com/go-critic/go-critic), [golangci-lint](https://github.com/golangci/golangci-lint) untuk cek kualitas kode (dipakai oleh `make test`)

4. Jalankan (pilih satu):

```bash
make run                  # lokal, SQLite zero-config
make compose.up           # app + redis (SQLite)
make compose.up.postgres  # app + redis + postgres (isi SQL_DSN dulu)
```

5. Buka Swagger: [127.0.0.1:5000/swagger/index.html](http://127.0.0.1:5000/swagger/index.html), cek sehat: `curl 127.0.0.1:5000/healthz`

Perintah lain: `make build`, `make build.fast`, `make test`, `make swag`, `make compose.down`. Target `docker.*` legacy (deprecated). Lihat `make help` dan `Makefile` untuk daftar lengkap.

## 🗄 Struktur

- `./app` — business logic saja: `controllers` (dipakai routes), `models`, `queries` (query SQL per model)
- `./docs` — hasil generate Swagger (`swag init`), jangan edit manual
- `./pkg` — kode spesifik project: `configs`, `middleware` (CORS, logger, JWT), `repository` (konstanta credential), `routes` (public/private/swagger/404), `utils`
- `./platform` — level platform: `cache` (Redis), `database` (PostgreSQL/SQLite via GORM + `AutoMigrate`)
- `main.go` — wiring app, middleware, routes; `STAGE_STATUS=prod` mengaktifkan graceful shutdown

Contoh bawaan: register/login user (`/api/v1/user/sign/*`), renew token, dan CRUD book (`/api/v1/book*`, butuh JWT + credential `book:create/update/delete`). Hapus/ganti sesuai kebutuhan project.

## ⚙️ Konfigurasi

Semua via `.env` (lihat `.env.example`). Yang wajib diganti untuk project baru: `JWT_SECRET_KEY`, `JWT_REFRESH_KEY`, `SQL_DSN`/`SQLITE_PATH` untuk produksi, dan nama container di `Makefile` bila perlu.

## ⚠️ License

Apache 2.0. Karya asli &copy; [Vic Shóstak](https://shostak.dev/) & Create Go App Contributors (lihat `LICENSE`); modifikasi oleh pemilik repo ini.
