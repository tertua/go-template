#!/usr/bin/env bash
#
# init.sh — bootstrap sekali-jalan untuk repo BARU hasil "Use this template".
# JANGAN dijalankan di repo template itu sendiri (github.com/tertua/go-template).
#
# Yang dilakukan:
#   1. Ganti module path di go.mod + semua import .go
#   2. Ganti README.md dengan README minimal project baru
#   3. Ganti baris copyright di LICENSE dengan nama/tahun sendiri (teks Apache tetap)
#   4. Reset git history (opsional) lalu hapus script ini sendiri
#
# Pemakaian:
#   ./init.sh --module github.com/tertua/namaproject --author "Nama Kamu" [--name namaproject] [--no-git] [--yes]
#
set -euo pipefail

TEMPLATE_MODULE="github.com/tertua/go-template"

die() { echo "ERROR: $*" >&2; exit 1; }

MODULE=""
NAME=""
AUTHOR=""
RESET_GIT="yes"
ASSUME_YES="no"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --module) MODULE="${2:-}"; shift 2 ;;
    --name)   NAME="${2:-}"; shift 2 ;;
    --author) AUTHOR="${2:-}"; shift 2 ;;
    --no-git) RESET_GIT="no"; shift ;;
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
echo ""
if [[ "$ASSUME_YES" != "yes" ]]; then
  read -rp "Lanjut? [y/N]: " confirm || true
  [[ "${confirm:-}" == [yY] ]] || die "dibatalkan"
fi

# 1. Ganti module path.
go mod edit -module "$MODULE"
grep -rl "$TEMPLATE_MODULE" --include="*.go" . | xargs sed -i "s|$TEMPLATE_MODULE|$MODULE|g"
go mod tidy

# Sanity check: pastikan masih compile.
go build ./... || die "go build gagal setelah rename module"

# 2. README minimal.
cat > README.md <<EOF
# $NAME

Project Go baru dari template [tertua/go-template](https://github.com/tertua/go-template).

## Quick start

1. Salin \`.env.example\` menjadi \`.env\` dan isi sesuai kebutuhan.
2. Jalankan: \`make docker.run\`
3. Buka Swagger: http://127.0.0.1:5000/swagger/index.html

## Perintah

\`make migrate.up\` / \`make migrate.down\` / \`make build\` / \`make test\` / \`make docker.stop\`
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
