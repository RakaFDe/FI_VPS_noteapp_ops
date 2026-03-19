#pastikan env sudah sesuai
set -e

cd "$(dirname "$0")"

echo "Pull repo ops terbaru"
git pull

echo "Pull images"
docker compose pull

echo "Run database migration"
docker compose --profile migration up --abort-on-container-exit migrate

echo "Jalankan compose"
docker compose up -d --remove-orphans

echo "Clean unused images / Prune image"
docker image prune -f

echo "Deploy finished"