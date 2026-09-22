#!/usr/bin/env bash
#
# init.sh — bootstrap sekali-jalan untuk repo BARU hasil "Use this template".
# JANGAN dijalankan di repo template itu sendiri (github.com/tertua/go-template).
#
# Yang dilakukan:
#   1. Ganti module path di go.mod + semua import .go
#   2. Opsional: --no-example menghapus contoh domain Book (controller/model/query,
#      route /book*, credential book:*, dan test route) agar project mulai bersih
#   3. Ganti README.md dengan README minimal project baru
#   4. Ganti baris copyright di LICENSE dengan nama/tahun sendiri (teks Apache tetap)
#   5. Reset git history (opsional) lalu hapus script ini sendiri
#
# Pemakaian:
#   ./init.sh --module github.com/tertua/namaproject --author "Nama Kamu" [--name namaproject] [--no-git] [--no-example] [--yes]
#
set -euo pipefail

TEMPLATE_MODULE="github.com/tertua/go-template"

die() { echo "ERROR: $*" >&2; exit 1; }

MODULE=""
NAME=""
AUTHOR=""
RESET_GIT="yes"
NO_EXAMPLE="no"
ASSUME_YES="no"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --module) MODULE="${2:-}"; shift 2 ;;
    --name)   NAME="${2:-}"; shift 2 ;;
    --author) AUTHOR="${2:-}"; shift 2 ;;
    --no-git) RESET_GIT="no"; shift ;;
    --no-example) NO_EXAMPLE="yes"; shift ;;
    --yes)    ASSUME_YES="yes"; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) die "argumen tidak dikenal: $1 (lihat --help)" ;;
  esac
done

[[ -f go.mod ]] || die "go.mod tidak ditemukan — jalankan dari root repo project baru"
grep -q "$TEMPLATE_MODULE" go.mod || die "go.mod tidak mengandung $TEMPLATE_MODULE — repo ini sepertinya bukan hasil template"

[[ -z "$MODULE" ]] && read -rp "Module path baru (mis. github.com/tertua/namaproject): " MODULE
[[ -z "$MODULE" ]] && die "--module wajib diisi"
[[ "$MODULE" == "$TEMPLATE_MODULE" ]] && die "module baru sama dengan module template"

if [[ -z "$NAME" ]]; then
  NAME="$(basename "$MODULE")"
  read -rp "Nama project [$NAME]: " input || true
  [[ -n "${input:-}" ]] && NAME="$input"
fi

if [[ -z "$AUTHOR" ]]; then
  read -rp "Nama author untuk LICENSE: " AUTHOR
  [[ -z "$AUTHOR" ]] && die "--author wajib diisi"
fi

YEAR="$(date +%Y)"

echo ""
echo "Akan bootstrap dengan:"
echo "  module : $MODULE"
echo "  nama   : $NAME"
echo "  author : $AUTHOR ($YEAR)"
echo "  git    : $RESET_GIT"
echo "  contoh : $([[ "$NO_EXAMPLE" == "yes" ]] && echo "hapus Book" || echo "pertahankan Book")"
echo ""
if [[ "$ASSUME_YES" != "yes" ]]; then
  read -rp "Lanjut? [y/N]: " confirm || true
  [[ "${confirm:-}" == [yY] ]] || die "dibatalkan"
fi

# 1. Ganti module path.
go mod edit -module "$MODULE"
grep -rl "$TEMPLATE_MODULE" --include="*.go" . | xargs sed -i "s|$TEMPLATE_MODULE|$MODULE|g"
go mod tidy

# 1b. Opsional: hapus contoh domain Book agar project mulai bersih.
# Auth user (sign up/in/out + renew token) dipertahankan.
if [[ "$NO_EXAMPLE" == "yes" ]]; then
  echo "Menghapus contoh Book..."
  rm -f app/controllers/book_controller.go app/models/book_model.go app/queries/book_query.go \
    pkg/repository/book_credentials.go pkg/routes/public_routes_test.go pkg/routes/private_routes_test.go

  cat > pkg/routes/public_routes.go <<EOF
package routes

import (
	"$MODULE/app/controllers"
	"github.com/gofiber/fiber/v3"
)

// PublicRoutes func for describe group of public routes.
func PublicRoutes(a *fiber.App) {
	// Create routes group.
	route := a.Group("/api/v1")

	// Routes for POST method:
	route.Post("/user/sign/up", controllers.UserSignUp) // register a new user
	route.Post("/user/sign/in", controllers.UserSignIn) // auth, return Access & Refresh tokens

	// TODO: tambah route public project di sini.
}
EOF

  cat > pkg/routes/private_routes.go <<EOF
package routes

import (
	"$MODULE/app/controllers"
	"$MODULE/pkg/middleware"
	"github.com/gofiber/fiber/v3"
)

// PrivateRoutes func for describe group of private routes.
func PrivateRoutes(a *fiber.App) {
	// Create routes group.
	route := a.Group("/api/v1")

	// Routes for POST method:
	route.Post("/user/sign/out", middleware.JWTProtected(), controllers.UserSignOut) // de-authorization user
	route.Post("/token/renew", middleware.JWTProtected(), controllers.RenewTokens)   // renew Access & Refresh tokens

	// TODO: tambah route private project di sini.
}
EOF

  cat > pkg/utils/credentials.go <<EOF
package utils

import (
	"fmt"

	"$MODULE/pkg/repository"
)

// GetCredentialsByRole func for getting credentials from a role name.
// Contoh Book sudah dihapus (--no-example): semua role mulai tanpa credential.
// TODO: definisikan credential project di sini (mis. "project:read").
func GetCredentialsByRole(role string) ([]string, error) {
	switch role {
	case repository.AdminRoleName:
		return []string{}, nil
	case repository.ModeratorRoleName:
		return []string{}, nil
	case repository.UserRoleName:
		return []string{}, nil
	default:
		return nil, fmt.Errorf("role '%v' does not exist", role)
	}
}
EOF

  cat > platform/database/open_db_connection.go <<EOF
package database

import (
	"sync"

	"$MODULE/app/models"
	"$MODULE/app/queries"
	"gorm.io/gorm"
)

// Queries struct for collect all app queries.
type Queries struct {
	*queries.UserQueries // load queries from User model
	// TODO: tambah query model project di sini.
}

var (
	sharedDB  *gorm.DB
	sharedErr error
	dbOnce    sync.Once
)

// openShared opens the database handle once per process.
func openShared() (*gorm.DB, error) {
	dbOnce.Do(func() {
		sharedDB, sharedErr = chooseDB("SQL_DSN")
	})
	return sharedDB, sharedErr
}

// OpenDBConnection func for opening database connection.
func OpenDBConnection() (*Queries, error) {
	db, err := openShared()
	if err != nil {
		return nil, err
	}

	return &Queries{
		// Set queries from models:
		UserQueries: &queries.UserQueries{DB: db}, // from User model
	}, nil
}

// Migrate creates or updates tables from models.
func Migrate() error {
	db, err := openShared()
	if err != nil {
		return err
	}

	return db.AutoMigrate(
		&models.User{},
	)
}
EOF

  go mod tidy
fi

# Sanity check: pastikan masih compile.
go build ./... || die "go build gagal setelah rename module"

# 2. README minimal.
cat > README.md <<EOF
# $NAME

Project Go baru dari template [tertua/go-template](https://github.com/tertua/go-template).

## Quick start

1. Salin \`.env.example\` menjadi \`.env\` dan isi sesuai kebutuhan.
2. Jalankan: \`make run\` (lokal, SQLite) atau \`make compose.up\` / \`make compose.up.postgres\`
3. Buka Swagger: http://127.0.0.1:5000/swagger/index.html

## Perintah

\`make run\` / \`make build\` / \`make test\` / \`make swag\` / \`make compose.down\`
EOF

# 3. Copyright LICENSE atas nama sendiri (isi lisensi Apache tidak diubah).
sed -i -E "s/^ *Copyright .*/   Copyright $YEAR $AUTHOR/" LICENSE
grep -q "Copyright $YEAR $AUTHOR" LICENSE || die "gagal update baris copyright di LICENSE"

# 4. Reset git history (opsional).
if [[ "$RESET_GIT" == "yes" ]]; then
  rm -rf .git
  git init -qb main 2>/dev/null || git init -q
  git add -A
  git commit -qm "Initial commit from tertua/go-template" || die "git commit gagal (cek git config user.name/user.email)"
fi

# 5. Hapus diri sendiri — tugas selesai.
rm -f ./init.sh

echo ""
echo "Selesai. Module: $MODULE | README + LICENSE direset | init.sh dihapus."
