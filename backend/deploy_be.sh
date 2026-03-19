#pastikan env sudah sesuai
set -e

cd "$(dirname "$0")"

echo "Sync repo ops terbaru"
git fetch origin
git reset --hard origin/main

#echo "Pull repo ops terbaru"
#git pull

echo "Pull images"
docker compose --env-file .env --env-file image.env pull

echo "Run database migration"
docker compose --env-file .env --env-file image.env --profile migration up --abort-on-container-exit migrate

echo "Jalankan compose"
docker compose --env-file .env --env-file image.env up -d --remove-orphans

echo "Clean unused images / Prune image"
docker image prune -f

echo "* Deploy finished *"