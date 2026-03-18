#pastikan env sudah sesuai
set -e

echo "Pull repo ops terbaru"
git pull

echo "Pull images"
docker compose pull

echo "Run database migration"
docker compose --profile migration up migrate

echo "Jalankan compose"
docker compose up -d

echo "Clean unused images / Prune image"
docker image prune -f

echo "Deploy finished"