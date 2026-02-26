# Finote Deployment — Docker Compose Guide

## Overview

Dokumen ini menjelaskan cara menjalankan deployment Finote menggunakan Docker Compose serta pengelolaan PostgreSQL volume pada VPS.

Deployment terdiri dari:

* PostgreSQL database container
* Database migration job
* Backend application container
* Docker named volume untuk persistensi data database

---

# Deployment Flow

## Update Deployment

1. Pull perubahan repository deployment.
git pull

2. Pull image terbaru dari registry.
docker compose pull

3. Jalankan database migration (jika ada perubahan schema).
docker compose --profile migration up migrate

4. Jalankan seluruh service.
docker compose up -d

---

# PostgreSQL Data Management

## Penting

Container dan data adalah hal berbeda.

* Container dapat dihapus tanpa kehilangan data
* Data disimpan pada Docker volume
* Volume harus dikelola dengan hati-hati

---

# Existing PostgreSQL Container Handling

Jika sebelumnya PostgreSQL sudah berjalan menggunakan docker run, terdapat tiga skenario penggunaan.

---

## Case 1 — Menggunakan Data Lama

Gunakan jika ingin mempertahankan database lama.

Langkah:

1. Stop container PostgreSQL lama.
docker stop finote-postgres

2. Jangan hapus volume lama.

3. Gunakan nama volume lama pada docker-compose.

Tujuan:

* data database tetap digunakan
* tidak terjadi re-initialisasi database

Catatan:
Volume lama biasanya memiliki nama random (anonymous volume).

---

## Case 2 — Clean Start (Database Baru)

Gunakan jika ingin reset database sepenuhnya.

Langkah:

1. Stop dan hapus container lama.
docker stop finote-postgres
docker rm finote-postgres

2. Hapus volume lama.
docker volume rm <volume_name>

3. Jalankan docker compose.

Tujuan:

* database kosong
* fresh initialization
* semua data lama dihapus

Peringatan:
Proses ini menghapus seluruh data database secara permanen.

---

## Case 3 — Volume Baru (Data Lama Tetap Disimpan)

Gunakan jika ingin deployment baru tanpa menghapus data lama.

Langkah:

1. Stop dan hapus container lama.
docker stop finote-postgres
docker rm finote-postgres

2. Jangan hapus volume lama.
3. Jalankan docker compose.

Hasil:

* Docker membuat volume baru
* data lama tetap tersedia sebagai backup
* sistem berjalan dengan database baru

Ini adalah pendekatan paling aman saat migrasi deployment.

---

# Docker Volume Management

## Melihat semua volume

docker volume ls

## Melihat detail volume

docker volume inspect <volume_name>

## Melihat voluem yang di pakai container

docker inspect <container>
cek pada bagian / baris volume

---

# Best Practice Production

## Gunakan Named Volume

Hindari anonymous volume dengan nama random.

Gunakan volume bernama agar:

* mudah backup
* mudah restore
* mudah dipindahkan
* lebih konsisten untuk production
* lebih mudah diintegrasikan ke orchestration system

Contoh volume yang direkomendasikan:

finote_pgdata

---

## Jangan Menjalankan Dua PostgreSQL Container dengan Nama Sama

Pastikan container lama dihentikan sebelum menjalankan Docker Compose.

Jika tidak, deployment akan gagal karena konflik container name.

---

# Database Migration Behavior

Migration dijalankan sebagai job terpisah sebelum backend berjalan.

Flow deployment:

PostgreSQL start
→ Migration dijalankan
→ Backend start

Migration tidak memerlukan backend berjalan terlebih dahulu.

---

# Troubleshooting

## Cek container status

docker compose ps

## Cek log service

docker compose logs -f

---

# Notes

* File `.env` tidak disimpan di repository.
* `.env` harus dibuat manual pada VPS.
* Environment variable berisi konfigurasi production dan kredensial database.
