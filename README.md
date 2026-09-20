# go-template

<img src="https://img.shields.io/badge/Go-1.27+-00ADD8?style=for-the-badge&logo=go" alt="go version" />&nbsp;<a href="https://goreportcard.com/report/github.com/tertua/go-template" target="_blank"><img src="https://img.shields.io/badge/Go_report-A+-success?style=for-the-badge&logo=none" alt="go report" /></a>&nbsp;<img src="https://img.shields.io/badge/license-Apache_2.0-red?style=for-the-badge&logo=none" alt="license" />

Template backend Go siap pakai untuk memulai project apapun: REST API dengan auth JWT, database, cache, migrasi, dan Swagger docs. Klik **Use this template** untuk project baru.

Stack: Go 1.27, [Fiber v3](https://gofiber.io/), PostgreSQL (`pgx/v5`) / MySQL, Redis, JWT, Swagger, Docker.

## ⚡️ Quick start

1. Buat project baru dari template ini (tombol **Use this template**), lalu clone.
2. Salin `.env.example` menjadi `.env` dan isi sesuai kebutuhan.
3. Install [Docker](https://www.docker.com/get-started) dan tools berikut:

   - [golang-migrate/migrate](https://github.com/golang-migrate/migrate#cli-usage) untuk menjalankan migrasi
   - [swag](https://github.com/swaggo/swag) untuk generate Swagger docs (`make swag`)
   - [gosec](https://github.com/securego/gosec), [go-critic](https://github.com/go-critic/go-critic), [golangci-lint](https://github.com/golangci/golangci-lint) untuk cek kualitas kode (dipakai oleh `make test`)

4. Jalankan semuanya (Postgres + Redis + app + migrasi):

```bash
make docker.run
```

5. Buka Swagger: [127.0.0.1:5000/swagger/index.html](http://127.0.0.1:5000/swagger/index.html)

Perintah lain: `make migrate.up`, `make migrate.down`, `make build`, `make test`, `make docker.stop`. Lihat `Makefile` untuk daftar lengkap.

## 🗄 Struktur

- `./app` — business logic saja: `controllers` (dipakai routes), `models`, `queries` (query SQL per model)
- `./docs` — hasil generate Swagger (`swag init`), jangan edit manual
- `./pkg` — kode spesifik project: `configs`, `middleware` (CORS, logger, JWT), `repository` (konstanta credential), `routes` (public/private/swagger/404), `utils`
- `./platform` — level platform: `cache` (Redis), `database` (Postgres/MySQL via `sqlx`), `migrations` (file SQL `up`/`down`)
- `main.go` — wiring app, middleware, routes; `STAGE_STATUS=prod` mengaktifkan graceful shutdown

Contoh bawaan: register/login user (`/api/v1/user/sign/*`), renew token, dan CRUD book (`/api/v1/book*`, butuh JWT + credential `book:create/update/delete`). Hapus/ganti sesuai kebutuhan project.

## ⚙️ Konfigurasi

Semua via `.env` (lihat `.env.example`). Yang wajib diganti untuk project baru: `JWT_SECRET_KEY`, `JWT_REFRESH_KEY`, kredensial `DB_*`, dan nama container di `Makefile` bila perlu.

## ⚠️ License

Apache 2.0. Karya asli &copy; [Vic Shóstak](https://shostak.dev/) & Create Go App Contributors (lihat `LICENSE`); modifikasi oleh pemilik repo ini.
