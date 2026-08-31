# Panduan Deploy MindfulEdu ke AWS EC2

Dokumen ini berisi langkah deploy dari awal sampai aplikasi bisa diakses lewat domain:

```text
https://mindfuledu.pkmueu.online
```

Struktur project:

```text
mindfulledu-2026/
├── docker-compose.yml
├── nginx/
├── php/
├── src/          # Laravel backend + landing page + admin
└── mindfuledu/  # Flutter mobile app
```

## 1. Persiapan DNS

Di panel DNS Hostinger untuk domain `pkmueu.online`, tambahkan record:

```text
Type: A
Name: mindfuledu
Value: 54.173.29.189
TTL: 300 atau default
```

Hasil akhirnya:

```text
mindfuledu.pkmueu.online -> 54.173.29.189
```

Cek dari terminal:

```bash
dig +short mindfuledu.pkmueu.online
```

Harus keluar:

```text
54.173.29.189
```

## 2. AWS Security Group

Di EC2 instance, buka security group yang dipakai instance. Tambahkan inbound rules:

```text
SSH    TCP 22   IP kamu atau 0.0.0.0/0 sementara
HTTP   TCP 80   0.0.0.0/0
HTTPS  TCP 443  0.0.0.0/0
```

Catatan:

- Port `80` wajib terbuka untuk validasi SSL Let's Encrypt.
- Port `443` wajib terbuka untuk HTTPS.
- Jangan hapus SSH `22`, karena nanti tidak bisa masuk server lagi.

## 3. Masuk ke EC2

Kalau pakai terminal lokal:

```bash
chmod 400 thifaal.pem
ssh -i thifaal.pem ubuntu@54.173.29.189
```

Kalau pakai AWS Console, buka **EC2 Instance Connect** sebagai user:

```text
ubuntu
```

## 4. Install Docker dan Tool Dasar

Di EC2:

```bash
sudo apt update
sudo apt install -y git docker.io docker-compose-v2 certbot dnsutils curl
sudo usermod -aG docker ubuntu
newgrp docker
```

Cek:

```bash
docker --version
docker compose version
```

## 5. Clone Repository

```bash
cd ~
git clone https://github.com/Thifaaldz/mindful.git mindful
cd ~/mindful
```

## 6. Konfigurasi Laravel `.env`

Buat file env:

```bash
cp src/.env.example src/.env
nano src/.env
```

Ubah nilai penting ini:

```env
APP_NAME=MindfulEdu
APP_ENV=production
APP_DEBUG=false
APP_URL=https://mindfuledu.pkmueu.online
ASSET_URL=https://mindfuledu.pkmueu.online
ASSET_PREFIX=

DB_CONNECTION=mariadb
DB_HOST=db
DB_PORT=3306
DB_DATABASE=mindfulledu
DB_USERNAME=root
DB_PASSWORD=p455w0rd
```

Penting:

- Jangan tulis URL pakai format markdown seperti `[https://...](https://...)`.
- Jangan pakai domain lama `mindfulledu.test`.
- Domain production yang benar adalah `mindfuledu.pkmueu.online`.

## 7. Konfigurasi Nginx untuk HTTPS

Edit:

```bash
nano nginx/default.conf
```

Isi production:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name mindfuledu.pkmueu.online;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_tokens off;

    server_name mindfuledu.pkmueu.online;
    root /var/www/html/public;

    index index.php index.html;

    ssl_certificate /etc/letsencrypt/live/mindfuledu.pkmueu.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mindfuledu.pkmueu.online/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

## 8. Konfigurasi Docker Compose untuk SSL

Edit:

```bash
nano docker-compose.yml
```

Di service `nginx`, pastikan volumes SSL memakai Let's Encrypt:

```yaml
nginx:
  build:
    context: ./nginx
  container_name: mindfulledu_nginx
  ports:
    - "443:443"
    - "80:80"
  volumes:
    - ./src:/var/www/html
    - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    - /etc/letsencrypt:/etc/letsencrypt:ro
  depends_on:
    - php
```

## 9. Ambil SSL Certificate

Pastikan Docker belum jalan agar port `80` kosong:

```bash
cd ~/mindful
docker compose down
sudo ss -ltnp | grep ':80'
```

Kalau tidak ada output, port `80` kosong.

Jalankan Certbot:

```bash
sudo certbot certonly --standalone -d mindfuledu.pkmueu.online
```

Jika sukses, cek:

```bash
sudo ls -lah /etc/letsencrypt/live/mindfuledu.pkmueu.online/
```

Harus ada:

```text
fullchain.pem
privkey.pem
```

## 10. Jalankan Container

```bash
cd ~/mindful
docker compose up -d --build
docker compose ps
```

Harus ada 3 container hidup:

```text
mindfulledu_db
mindfulledu_php
mindfulledu_nginx
```

## 11. Install Dependency Laravel

Folder `src/vendor/` tidak ikut GitHub, jadi wajib install di server:

```bash
docker compose exec php composer install --no-dev --optimize-autoloader
```

Jika error permission:

```bash
sudo chown -R ubuntu:ubuntu src
docker compose exec php composer install --no-dev --optimize-autoloader
```

## 12. Setup Laravel

Untuk deploy pertama:

```bash
docker compose exec php php artisan key:generate --force
docker compose exec php php artisan migrate --force
docker compose exec php php artisan db:seed --force
docker compose exec php php artisan optimize:clear
```

Jika database deploy awal kacau, misalnya seed gagal karena tabel `users` tidak ada:

```bash
docker compose exec php php artisan migrate:fresh --seed --force
docker compose exec php php artisan optimize:clear
```

Jangan pakai `migrate:fresh` kalau sudah ada data production yang ingin dipertahankan.

## 13. Publish Asset Admin Filament

Jalankan:

```bash
docker compose exec php php artisan filament:assets
docker compose exec php php artisan vendor:publish --tag=filament-assets --force
docker compose exec php php artisan optimize:clear
docker compose restart php nginx
```

Cek asset:

```bash
curl -I https://mindfuledu.pkmueu.online/css/filament/filament/app.css
curl -I https://mindfuledu.pkmueu.online/build/manifest.json
```

Harus `200 OK`.

## 14. Cek Website

```bash
curl -I https://mindfuledu.pkmueu.online
curl -I https://mindfuledu.pkmueu.online/admin
curl -I https://mindfuledu.pkmueu.online/api/me
```

Buka di browser:

```text
https://mindfuledu.pkmueu.online
https://mindfuledu.pkmueu.online/admin
```

## 15. Upload APK untuk Tombol Download

APK tidak ikut GitHub karena ukuran file melebihi limit GitHub `100 MB`. Landing page akan 404 kalau file ini belum ada:

```text
src/public/downloads/mindfuledu.apk
```

### Opsi A: Upload dari Laptop via SCP

Build APK di laptop lokal:

```bash
cd /home/kumadz/Documents/Project/mindfulledu-2026/mindfuledu
flutter build apk --release --dart-define=API_BASE_URL=https://mindfuledu.pkmueu.online/api
```

Upload:

```bash
scp -i /path/ke/thifaal.pem \
build/app/outputs/flutter-apk/app-release.apk \
ubuntu@54.173.29.189:/home/ubuntu/mindful/src/public/downloads/mindfuledu.apk
```

### Opsi B: Jika Pakai AWS Browser SSH

Karena EC2 Instance Connect dari browser tidak bisa upload file langsung, upload APK ke Google Drive atau GitHub Release dulu, lalu download dari EC2.

Contoh Google Drive:

```bash
cd ~/mindful
mkdir -p src/public/downloads
sudo apt install -y python3-pip
pip3 install gdown --break-system-packages
gdown "https://drive.google.com/uc?id=FILE_ID" -O src/public/downloads/mindfuledu.apk
```

Contoh direct link:

```bash
wget -O src/public/downloads/mindfuledu.apk "LINK_DOWNLOAD_APK"
```

Cek:

```bash
ls -lah src/public/downloads/mindfuledu.apk
curl -I https://mindfuledu.pkmueu.online/download/android
```

Jika benar, hasil download route:

```text
HTTP/1.1 200 OK
Content-Disposition: attachment; filename=MindfulEdu.apk
```

## 16. Update Deploy Setelah Ada Perubahan Kode

Di EC2:

```bash
cd ~/mindful
git pull
docker compose up -d --build
docker compose exec php composer install --no-dev --optimize-autoloader
docker compose exec php php artisan migrate --force
docker compose exec php php artisan filament:assets
docker compose exec php php artisan optimize:clear
docker compose restart php nginx
```

Jika APK berubah, upload ulang `mindfuledu.apk` ke:

```text
~/mindful/src/public/downloads/mindfuledu.apk
```

## Troubleshooting

### 1. Certbot Timeout

Error:

```text
Timeout during connect (likely firewall problem)
```

Penyebab:

- Security Group belum buka port `80`.
- DNS belum mengarah ke IP EC2.
- Port `80` sedang dipakai container nginx.

Fix:

```bash
dig +short mindfuledu.pkmueu.online
docker compose down
sudo ss -ltnp | grep ':80'
sudo certbot certonly --standalone -d mindfuledu.pkmueu.online
```

Pastikan Security Group punya:

```text
HTTP 80 0.0.0.0/0
HTTPS 443 0.0.0.0/0
SSH 22 IP kamu
```

### 2. Nginx Exited karena SSL Tidak Ada

Error:

```text
cannot load certificate "/etc/letsencrypt/live/mindfuledu.pkmueu.online/fullchain.pem"
```

Penyebab:

- Certbot belum sukses.
- `docker-compose.yml` belum mount `/etc/letsencrypt`.

Fix:

```bash
docker compose down
sudo certbot certonly --standalone -d mindfuledu.pkmueu.online
sudo ls -lah /etc/letsencrypt/live/mindfuledu.pkmueu.online/
docker compose up -d --build
```

### 3. `vendor/autoload.php` Tidak Ada

Error:

```text
Failed opening required '/var/www/html/vendor/autoload.php'
```

Penyebab:

- Dependency Laravel belum di-install di server.

Fix:

```bash
docker compose exec php composer install --no-dev --optimize-autoloader
```

### 4. Seeder Gagal: Table `users` Tidak Ada

Error:

```text
Table 'mindfulledu.users' doesn't exist
```

Fix untuk deploy awal:

```bash
docker compose exec php php artisan migrate:fresh --seed --force
```

### 5. Landing Page Download APK 404

Penyebab:

- File APK belum ada di server.

Cek:

```bash
ls -lah ~/mindful/src/public/downloads/mindfuledu.apk
```

Fix:

- Upload APK ke `src/public/downloads/mindfuledu.apk`.

### 6. `/admin` CSS Tidak Masuk

Cek env:

```bash
grep -E "APP_URL|ASSET_URL|ASSET_PREFIX|APP_ENV|APP_DEBUG" src/.env
```

Harus:

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://mindfuledu.pkmueu.online
ASSET_URL=https://mindfuledu.pkmueu.online
ASSET_PREFIX=
```

Fix:

```bash
docker compose exec php php artisan optimize:clear
docker compose exec php php artisan filament:assets
docker compose exec php php artisan vendor:publish --tag=filament-assets --force
docker compose restart php nginx
```

Lalu hard refresh browser:

```text
Ctrl + Shift + R
```

### 7. Salah Menulis URL di Command

Jangan tulis:

```bash
--dart-define=API_BASE_URL=[https://mindfuledu.pkmueu.online/api](https://mindfuledu.pkmueu.online/api)
```

Yang benar:

```bash
--dart-define=API_BASE_URL=https://mindfuledu.pkmueu.online/api
```

### 8. Flutter Tidak Ada di EC2

Kalau muncul:

```text
Command 'flutter' not found
```

Artinya Flutter belum terinstall di EC2. Lebih mudah build APK dari laptop lalu upload. Jika harus build di EC2, install Flutter dan Android SDK terlebih dahulu.

## Checklist Deploy Singkat

```text
[ ] DNS A record mindfuledu -> IP EC2
[ ] Security Group buka 22, 80, 443
[ ] Clone repo di EC2
[ ] src/.env production benar
[ ] nginx/default.conf pakai domain production
[ ] docker-compose mount /etc/letsencrypt
[ ] certbot sukses
[ ] docker compose up -d --build
[ ] composer install
[ ] artisan key:generate
[ ] artisan migrate/seed
[ ] filament assets publish
[ ] landing page 200 OK
[ ] admin page CSS masuk
[ ] APK tersedia di src/public/downloads/mindfuledu.apk
[ ] /download/android 200 OK
```
