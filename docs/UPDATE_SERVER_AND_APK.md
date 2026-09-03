# Panduan Update Server dan Upload APK MindfulEdu

Dokumen ini dipakai setiap kali ingin update aplikasi MindfulEdu di server AWS, build APK Flutter terbaru, lalu upload APK agar bisa di-download dari website.

Target production saat ini:

```text
Domain web    : https://mindfullapps.pkmueu.online
API mobile    : https://mindfullapps.pkmueu.online/api
Download APK  : https://mindfullapps.pkmueu.online/download/android
Public IP EC2 : 16.78.35.91
SSH user      : ubuntu
Server path   : /home/ubuntu/mindful
Local root    : /home/kumadz/Documents/Project/mindfulledu-2026
Flutter app   : /home/kumadz/Documents/Project/mindfulledu-2026/mindfuledu
```

Catatan keamanan:

- Jangan commit `.env`, API key Gemini, client secret Google, atau file `.pem`.
- API key Gemini cukup disimpan di server pada `ml-service/.env`.
- Google OAuth client secret tidak dibutuhkan oleh APK Flutter.
- APK Flutter memakai `GOOGLE_SERVER_CLIENT_ID`, bukan client secret.

## 1. Cek DNS dan Security Group

Di DNS Hostinger untuk `pkmueu.online`, record yang dibutuhkan:

```text
Type : A
Name : mindfullapps
Value: 16.78.35.91
TTL  : 300
```

Cek dari terminal:

```bash
dig +short mindfullapps.pkmueu.online
```

Harus keluar:

```text
16.78.35.91
```

Di AWS Security Group, pastikan inbound rule terbuka:

```text
SSH    TCP 22   IP kamu atau 0.0.0.0/0 sementara
HTTP   TCP 80   0.0.0.0/0
HTTPS  TCP 443  0.0.0.0/0
```

## 2. Masuk ke Server

Dari laptop lokal:

```bash
chmod 400 ~/Downloads/mindfullness.pem
ssh -i ~/Downloads/mindfullness.pem ubuntu@16.78.35.91
```

Kalau muncul:

```text
WARNING: UNPROTECTED PRIVATE KEY FILE
```

jalankan lagi:

```bash
chmod 400 ~/Downloads/mindfullness.pem
```

## 3. Pull Kode Terbaru di Server

Masuk folder project:

```bash
cd ~/mindful
```

Cek kondisi repo:

```bash
git status
git log -1 --oneline
```

Kalau tidak ada perubahan lokal di server:

```bash
git pull origin main
git log -1 --oneline
```

Kalau ada perubahan lokal di server dan belum yakin itu apa, simpan dulu:

```bash
git stash push -m "server-local-before-deploy-$(date +%F-%H%M)"
git pull origin main
```

## 4. Cek `.env` Laravel

Edit:

```bash
nano src/.env
```

Pastikan nilai penting production seperti ini:

```env
APP_NAME=MindfulEdu
APP_ENV=production
APP_DEBUG=false
APP_TIMEZONE=Asia/Jakarta
APP_URL=https://mindfullapps.pkmueu.online
ASSET_URL=https://mindfullapps.pkmueu.online
ASSET_PREFIX=

DB_CONNECTION=mariadb
DB_HOST=db
DB_PORT=3306
DB_DATABASE=mindfulledu
DB_USERNAME=root
DB_PASSWORD=p455w0rd

SESSION_DRIVER=database
QUEUE_CONNECTION=database
CACHE_STORE=file

MINDFULEDU_ML_URL=http://ml:8000
GOOGLE_CLIENT_ID=772190179768-lc0qvgp76q531djrnb2n7q93cttm23v9.apps.googleusercontent.com
```

Penting:

- Pakai `CACHE_STORE=file` agar `php artisan optimize:clear` tidak error karena tabel `cache` belum ada.
- Jangan tulis URL dalam format markdown seperti `[https://...](https://...)`.
- `GOOGLE_CLIENT_ID` di Laravel memakai Web OAuth client ID.

## 5. Cek `.env` Gemini untuk Python FastAPI

Edit:

```bash
nano ml-service/.env
```

Formatnya:

```env
GEMINI_API_KEY=ISI_API_KEY_DI_SERVER
GEMINI_MODEL=gemini-3.5-flash-lite
GEMINI_TIMEOUT_SECONDS=20
```

Cara aman memasukkan API key tanpa tampil di layar:

```bash
read -s GEMINI_API_KEY
printf "\nGEMINI_API_KEY=%s\nGEMINI_MODEL=gemini-3.5-flash-lite\nGEMINI_TIMEOUT_SECONDS=20\n" "$GEMINI_API_KEY" > ml-service/.env
chmod 600 ml-service/.env
```

## 6. Cek Nginx Production

Setelah `git pull`, cek:

```bash
nano nginx/default.conf
```

Pastikan `server_name` memakai domain production, bukan `mindfulledu.test`.

Contoh konfigurasi production:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name mindfullapps.pkmueu.online;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_tokens off;

    server_name mindfullapps.pkmueu.online;
    root /var/www/html/public;

    index index.php index.html;

    ssl_certificate     /etc/nginx/ssl/mindfullapps.pkmueu.online.crt;
    ssl_certificate_key /etc/nginx/ssl/mindfullapps.pkmueu.online.key;

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

Kalau server memakai Let's Encrypt langsung dari `/etc/letsencrypt`, sesuaikan path certificate dengan setup server kamu. Yang penting domain dan file certificate cocok.

## 7. Rebuild Docker di Server

Dari server:

```bash
cd ~/mindful
docker compose up -d --build
docker compose ps
```

Container normal yang harus hidup:

```text
mindfulledu_nginx
mindfulledu_php
mindfulledu_db
mindfulledu_ml
```

Empat container itu normal:

- `nginx` untuk website dan HTTPS.
- `php` untuk Laravel API, admin, dan landing page.
- `db` untuk MariaDB.
- `ml` untuk FastAPI Python, analisis burnout, dan rekomendasi berbasis AI.

## 8. Jalankan Command Laravel Setelah Pull

Masih di server:

```bash
cd ~/mindful
docker compose exec php composer install --no-dev --optimize-autoloader
docker compose exec php php artisan migrate --force
docker compose exec php php artisan filament:assets
docker compose exec php php artisan vendor:publish --tag=filament-assets --force
docker compose exec php php artisan storage:link || true
docker compose exec php php artisan optimize:clear
docker compose restart php nginx ml
```

Kalau `optimize:clear` error:

```text
Table 'mindfulledu.cache' doesn't exist
```

fix cepat:

```bash
sed -i 's/^CACHE_STORE=.*/CACHE_STORE=file/' src/.env
docker compose exec php php artisan optimize:clear
docker compose restart php nginx
```

## 9. Test Server Setelah Update

Jalankan:

```bash
curl -I https://mindfullapps.pkmueu.online
curl -I https://mindfullapps.pkmueu.online/admin
curl -I https://mindfullapps.pkmueu.online/up
curl -I https://mindfullapps.pkmueu.online/api/me
```

Catatan:

- `/`, `/admin`, dan `/up` harus berhasil.
- `/api/me` boleh `401 Unauthorized` jika belum login. Itu berarti API hidup.

Test FastAPI:

```bash
curl http://127.0.0.1:18000/health
```

Harus ada response status `ok`.

## 10. Build APK Release dari Laptop Lokal

Pindah ke repo lokal:

```bash
cd /home/kumadz/Documents/Project/mindfulledu-2026
git pull origin main
cd mindfuledu
```

Build APK:

```bash
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=API_BASE_URL=https://mindfullapps.pkmueu.online/api \
  --dart-define=API_FALLBACK_URLS=https://mindfullapps.pkmueu.online/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=772190179768-lc0qvgp76q531djrnb2n7q93cttm23v9.apps.googleusercontent.com
```

Hasil APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Kalau muncul warning:

```text
source value 8 is obsolete
target value 8 is obsolete
```

itu masih aman selama hasil akhirnya:

```text
Built build/app/outputs/flutter-apk/app-release.apk
```

Kalau muncul `Invalid depfile`, bersihkan build:

```bash
flutter clean
rm -rf .dart_tool build
flutter pub get
flutter build apk --release \
  --dart-define=API_BASE_URL=https://mindfullapps.pkmueu.online/api \
  --dart-define=API_FALLBACK_URLS=https://mindfullapps.pkmueu.online/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=772190179768-lc0qvgp76q531djrnb2n7q93cttm23v9.apps.googleusercontent.com
```

## 11. Upload APK ke Server

Dari folder Flutter lokal:

```bash
cd /home/kumadz/Documents/Project/mindfulledu-2026/mindfuledu
```

Upload APK:

```bash
scp -i ~/Downloads/mindfullness.pem \
  build/app/outputs/flutter-apk/app-release.apk \
  ubuntu@16.78.35.91:/home/ubuntu/mindfuledu.apk
```

Masuk server:

```bash
ssh -i ~/Downloads/mindfullness.pem ubuntu@16.78.35.91
```

Pindahkan APK ke folder public Laravel:

```bash
cd ~/mindful
mkdir -p src/public/downloads
cp /home/ubuntu/mindfuledu.apk src/public/downloads/mindfuledu.apk
chmod 644 src/public/downloads/mindfuledu.apk
ls -lh src/public/downloads/mindfuledu.apk
```

Path wajib:

```text
/home/ubuntu/mindful/src/public/downloads/mindfuledu.apk
```

Jangan taruh di:

```text
/var/www/html/download
```

karena route website membaca dari `src/public/downloads/mindfuledu.apk`.

## 12. Test Tombol Download APK

Jalankan:

```bash
curl -I https://mindfullapps.pkmueu.online/download/android
```

Kalau benar, hasilnya `200 OK`.

Kalau masih `404`, cek:

```bash
ls -lh ~/mindful/src/public/downloads/mindfuledu.apk
docker compose restart nginx php
curl -I https://mindfullapps.pkmueu.online/download/android
```

## 13. Install dan Test APK di HP

Download dari:

```text
https://mindfullapps.pkmueu.online/download/android
```

Jika APK stuck di layar hitam setelah update:

1. Uninstall aplikasi lama dari HP.
2. Install APK terbaru lagi.
3. Pastikan APK dibuild dengan API production:

```text
https://mindfullapps.pkmueu.online/api
```

Kalau test pakai ADB:

```bash
adb shell pm list packages | grep -i mindful
adb uninstall NAMA_PACKAGE_DARI_HASIL_DI_ATAS
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 14. Checklist Update Cepat

```text
[ ] Local code sudah push ke GitHub
[ ] SSH ke server sukses
[ ] cd ~/mindful
[ ] git pull origin main
[ ] src/.env production benar
[ ] ml-service/.env berisi GEMINI_API_KEY
[ ] nginx/default.conf domain production benar
[ ] docker compose up -d --build
[ ] composer install
[ ] php artisan migrate --force
[ ] php artisan optimize:clear
[ ] docker compose restart php nginx ml
[ ] Website /admin bisa dibuka
[ ] API /api/me reachable
[ ] FastAPI /health ok
[ ] Flutter build APK release sukses
[ ] APK upload ke src/public/downloads/mindfuledu.apk
[ ] /download/android 200 OK
[ ] APK berhasil login dan connect ke server
```

## 15. Troubleshooting

### Server tidak bisa SSH

```bash
chmod 400 ~/Downloads/mindfullness.pem
ssh -i ~/Downloads/mindfullness.pem ubuntu@16.78.35.91
```

Cek juga Security Group port `22`.

### Website 502 atau 500

```bash
cd ~/mindful
docker compose ps
docker compose logs --tail=120 nginx
docker compose logs --tail=120 php
docker compose logs --tail=120 ml
docker compose restart php nginx ml
```

### Database migration error duplicate column

Biasanya terjadi karena database sudah punya kolom dari deploy sebelumnya.

Cek migration:

```bash
docker compose exec php php artisan migrate:status
```

Jangan pakai `migrate:fresh` di production kalau data mau dipertahankan.

### APK download masih versi lama

Cek ukuran dan waktu file:

```bash
ls -lh ~/mindful/src/public/downloads/mindfuledu.apk
```

Upload ulang APK, lalu test:

```bash
curl -I https://mindfullapps.pkmueu.online/download/android
```

### Aplikasi tidak terhubung server

Pastikan build production tidak memakai IP lokal seperti `192.168.x.x`.

Untuk production harus:

```bash
--dart-define=API_BASE_URL=https://mindfullapps.pkmueu.online/api
--dart-define=API_FALLBACK_URLS=https://mindfullapps.pkmueu.online/api
```

### Login Google gagal error 10

Pastikan Google Cloud punya dua OAuth client:

- Web application client ID untuk `GOOGLE_SERVER_CLIENT_ID` dan `GOOGLE_CLIENT_ID` di Laravel.
- Android client ID dengan package name dan SHA-1 debug/release yang benar.

Untuk APK release, SHA-1 harus sesuai keystore release yang dipakai build.

## 16. Command Ringkas

Update server:

```bash
ssh -i ~/Downloads/mindfullness.pem ubuntu@16.78.35.91
cd ~/mindful
git pull origin main
docker compose up -d --build
docker compose exec php composer install --no-dev --optimize-autoloader
docker compose exec php php artisan migrate --force
docker compose exec php php artisan filament:assets
docker compose exec php php artisan vendor:publish --tag=filament-assets --force
docker compose exec php php artisan storage:link || true
docker compose exec php php artisan optimize:clear
docker compose restart php nginx ml
curl -I https://mindfullapps.pkmueu.online
curl -I https://mindfullapps.pkmueu.online/download/android
```

Build dan upload APK dari lokal:

```bash
cd /home/kumadz/Documents/Project/mindfulledu-2026
git pull origin main
cd mindfuledu
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=API_BASE_URL=https://mindfullapps.pkmueu.online/api \
  --dart-define=API_FALLBACK_URLS=https://mindfullapps.pkmueu.online/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=772190179768-lc0qvgp76q531djrnb2n7q93cttm23v9.apps.googleusercontent.com
scp -i ~/Downloads/mindfullness.pem \
  build/app/outputs/flutter-apk/app-release.apk \
  ubuntu@16.78.35.91:/home/ubuntu/mindfuledu.apk
ssh -i ~/Downloads/mindfullness.pem ubuntu@16.78.35.91
cd ~/mindful
mkdir -p src/public/downloads
cp /home/ubuntu/mindfuledu.apk src/public/downloads/mindfuledu.apk
chmod 644 src/public/downloads/mindfuledu.apk
curl -I https://mindfullapps.pkmueu.online/download/android
```
