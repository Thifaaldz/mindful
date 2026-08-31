# MindfulEdu

MindfulEdu adalah sistem mindfulness pendidikan untuk membantu guru melakukan latihan mindfulness, mencatat logbook harian, memantau observasi siswa, dan mengakses toolkit intervensi kelas. Project ini terdiri dari backend Laravel, admin panel Filament, landing page download aplikasi, dan aplikasi mobile Flutter.

Domain production:

```text
https://mindfuledu.pkmueu.online
```

Panduan deploy lengkap tersedia di:

[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## Fitur Utama

- Landing page informasi sistem dan tombol download APK.
- Login/register berbasis Laravel Sanctum.
- Role pengguna: super admin, admin/user, teacher, student.
- Dashboard guru berisi total sesi, rata-rata ketenangan, distraksi, grafik tren, badge, dan akses cepat.
- Sesi mindfulness 7 langkah dengan timer, counter distraksi, dan mode audio/guided meditation.
- Digital logbook harian dengan skala ketenangan, refleksi, dan kuesioner singkat.
- Riwayat logbook.
- Reminder latihan harian.
- Observasi siswa berbasis Psychological First Aid: perasaan, perilaku, tubuh, teman, belajar.
- Status observasi: hijau, kuning, merah.
- Catatan kasus dan rekomendasi tindakan.
- Toolkit intervensi: STOP, Grounding 3-2-1, dan Taktik Mindful Lecturing.
- Admin panel Filament untuk mengelola data user, kelas, sesi, observasi, badge, dan tactic.
- Aplikasi student untuk melihat riwayat observasi.

## Tech Stack

Backend:

- Laravel
- Laravel Sanctum
- Filament Admin Panel
- MariaDB
- Nginx
- Docker Compose

Mobile:

- Flutter
- Dart
- Native Android build

Frontend Web:

- Blade landing page
- Vite/Tailwind assets untuk Laravel dan Filament

Infrastructure:

- AWS EC2 Ubuntu
- Hostinger DNS
- Let's Encrypt SSL

## Struktur Folder

```text
mindfulledu-2026/
├── db/                  # konfigurasi dan volume database lokal
├── docs/                # PRD, design reference, dan deployment guide
├── mindfuledu/          # aplikasi mobile Flutter
├── nginx/               # Dockerfile dan konfigurasi nginx
├── php/                 # Dockerfile PHP-FPM
├── src/                 # aplikasi Laravel
│   ├── app/
│   ├── database/
│   ├── public/
│   ├── resources/
│   └── routes/
├── docker-compose.yml
└── README.md
```

## Akun Dummy

Semua password default:

```text
password
```

Admin:

```text
admin@admin.com
```

Guru:

```text
guru@mindfuledu.test
guru.bima@mindfuledu.test
guru.rani@mindfuledu.test
```

Siswa:

```text
siswa@mindfuledu.test
budi@mindfuledu.test
citra@mindfuledu.test
dewi@mindfuledu.test
eko@mindfuledu.test
farah@mindfuledu.test
gilang@mindfuledu.test
```

## URL Penting

Production:

```text
Landing page: https://mindfuledu.pkmueu.online
Admin panel:  https://mindfuledu.pkmueu.online/admin
API base:     https://mindfuledu.pkmueu.online/api
Download APK: https://mindfuledu.pkmueu.online/download/android
```

Local default:

```text
Landing page: https://mindfulledu.test
Admin panel:  https://mindfulledu.test/admin
API base:     https://mindfulledu.test/api
```

Catatan nama domain:

- Production memakai `mindfuledu.pkmueu.online`.
- Local bawaan nginx masih memakai `mindfulledu.test`.
- Jangan tertukar antara `mindfuledu` dan `mindfulledu`.

## Menjalankan Backend Secara Lokal

### 1. Tambahkan Host Lokal

Tambahkan ke `/etc/hosts`:

```text
127.0.0.1 mindfulledu.test
```

### 2. Buat SSL Lokal Jika Belum Ada

Folder `nginx/ssl` tidak ikut Git karena berisi file lokal/sensitif. Buat ulang:

```bash
mkdir -p nginx/ssl
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout nginx/ssl/mindfulledu.test.key \
  -out nginx/ssl/mindfulledu.test.crt \
  -subj "/CN=mindfulledu.test"
```

### 3. Siapkan File Env Laravel

```bash
cp src/.env.example src/.env
```

Edit `src/.env`:

```env
APP_NAME=MindfulEdu
APP_ENV=local
APP_DEBUG=true
APP_URL=https://mindfulledu.test
ASSET_URL=https://mindfulledu.test
ASSET_PREFIX=

DB_CONNECTION=mariadb
DB_HOST=db
DB_PORT=3306
DB_DATABASE=mindfulledu
DB_USERNAME=root
DB_PASSWORD=p455w0rd
```

### 4. Jalankan Container

```bash
docker compose up -d --build
docker compose ps
```

### 5. Install Dependency Laravel

```bash
docker compose exec php composer install
```

### 6. Setup Laravel

```bash
docker compose exec php php artisan key:generate --force
docker compose exec php php artisan migrate:fresh --seed --force
docker compose exec php php artisan filament:assets
docker compose exec php php artisan vendor:publish --tag=filament-assets --force
docker compose exec php php artisan optimize:clear
```

### 7. Cek Backend

```bash
curl -k -I https://mindfulledu.test
curl -k -I https://mindfulledu.test/admin
curl -k -I https://mindfulledu.test/css/filament/filament/app.css
```

## Menjalankan Mobile Flutter

Masuk ke folder Flutter:

```bash
cd mindfuledu
flutter pub get
```

Jalankan analyzer:

```bash
flutter analyze
```

Jalankan test:

```bash
flutter test
```

Jalankan aplikasi ke device:

```bash
flutter devices
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=https://mindfulledu.test/api
```

Untuk Android physical device yang mengakses server production:

```bash
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=https://mindfuledu.pkmueu.online/api
```

Build APK release production:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://mindfuledu.pkmueu.online/api
```

Hasil APK:

```text
mindfuledu/build/app/outputs/flutter-apk/app-release.apk
```

## APK Download Landing Page

Route download:

```text
/download/android
```

Route ini mencari file:

```text
src/public/downloads/mindfuledu.apk
```

APK tidak ikut GitHub karena ukurannya lebih dari limit GitHub `100 MB`. Untuk production, upload APK manual ke server:

```bash
scp -i /path/ke/thifaal.pem \
mindfuledu/build/app/outputs/flutter-apk/app-release.apk \
ubuntu@54.173.29.189:/home/ubuntu/mindful/src/public/downloads/mindfuledu.apk
```

Jika memakai AWS browser SSH dan tidak bisa upload langsung, upload APK dulu ke Google Drive atau GitHub Release, lalu download dari EC2:

```bash
cd ~/mindful
mkdir -p src/public/downloads
wget -O src/public/downloads/mindfuledu.apk "LINK_DOWNLOAD_APK"
```

Cek:

```bash
curl -I https://mindfuledu.pkmueu.online/download/android
```

Harus `200 OK`.

## API Endpoint

Public:

```text
POST /api/register
POST /api/login
```

Authenticated:

```text
POST /api/logout
GET  /api/me
GET  /api/questionnaire/latest
POST /api/questionnaire/responses
GET  /api/reminder-preference
PUT  /api/reminder-preference
GET  /api/students/{studentId}/observations
```

Teacher only:

```text
GET  /api/dashboard
GET  /api/mindfulness-sessions
POST /api/mindfulness-sessions
GET  /api/mindfulness-sessions/{id}
PUT  /api/mindfulness-sessions/{id}
GET  /api/toolkit/tactics
GET  /api/toolkit/tactics/bookmarked
POST /api/toolkit/tactics/{tactic}/bookmark
GET  /api/classes
GET  /api/classes/{classId}/students
POST /api/observations
GET  /api/observations/flagged
```

Contoh login:

```bash
curl -k -X POST https://mindfulledu.test/api/login \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"email":"guru@mindfuledu.test","password":"password"}'
```

## Deploy Production Singkat

Panduan detail ada di:

[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

Ringkasan:

```bash
cd ~
git clone https://github.com/Thifaaldz/mindful.git mindful
cd ~/mindful
cp src/.env.example src/.env
nano src/.env
nano nginx/default.conf
nano docker-compose.yml
docker compose down
sudo certbot certonly --standalone -d mindfuledu.pkmueu.online
docker compose up -d --build
docker compose exec php composer install --no-dev --optimize-autoloader
docker compose exec php php artisan key:generate --force
docker compose exec php php artisan migrate --force
docker compose exec php php artisan db:seed --force
docker compose exec php php artisan filament:assets
docker compose exec php php artisan vendor:publish --tag=filament-assets --force
docker compose exec php php artisan optimize:clear
docker compose restart php nginx
```

Untuk deploy pertama dan database kosong:

```bash
docker compose exec php php artisan migrate:fresh --seed --force
```

## Update Production Setelah Ada Perubahan Kode

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

Jika APK berubah, upload ulang:

```text
src/public/downloads/mindfuledu.apk
```

## Git dan File yang Tidak Boleh Dipush

File berikut tidak boleh dipush:

```text
.env
.DS_Store
nginx/ssl/*.crt
nginx/ssl/*.key
src/public/downloads/*.apk
db/data/
src/vendor/
```

Alasan:

- `.env` berisi konfigurasi rahasia.
- SSL key bersifat rahasia.
- APK melewati limit GitHub.
- Database volume tidak boleh masuk repository.
- `vendor/` dibuat ulang dengan `composer install`.

Jika GitHub menolak push karena file besar:

```bash
git rm --cached -- src/public/downloads/mindfuledu.apk
git add .gitignore src/public/downloads/.gitkeep
git commit --amend --no-edit
git push
```

## Troubleshooting

### Certbot Timeout

Error:

```text
Timeout during connect (likely firewall problem)
```

Fix:

- Pastikan DNS `mindfuledu.pkmueu.online` mengarah ke IP EC2.
- Pastikan AWS Security Group membuka port `80` dan `443`.
- Matikan Docker sementara agar port `80` kosong.

```bash
docker compose down
dig +short mindfuledu.pkmueu.online
sudo ss -ltnp | grep ':80'
sudo certbot certonly --standalone -d mindfuledu.pkmueu.online
```

### Nginx Exited karena SSL Belum Ada

Error:

```text
cannot load certificate "/etc/letsencrypt/live/mindfuledu.pkmueu.online/fullchain.pem"
```

Fix:

```bash
docker compose down
sudo certbot certonly --standalone -d mindfuledu.pkmueu.online
docker compose up -d --build
```

### `vendor/autoload.php` Tidak Ada

Error:

```text
Failed opening required '/var/www/html/vendor/autoload.php'
```

Fix:

```bash
docker compose exec php composer install --no-dev --optimize-autoloader
```

### Seeder Gagal karena Tabel `users` Tidak Ada

Error:

```text
Table 'mindfulledu.users' doesn't exist
```

Fix untuk deploy awal:

```bash
docker compose exec php php artisan migrate:fresh --seed --force
```

### `/admin` Tidak Ada CSS

Cek:

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

Lalu:

```bash
docker compose exec php php artisan optimize:clear
docker compose exec php php artisan filament:assets
docker compose exec php php artisan vendor:publish --tag=filament-assets --force
docker compose restart php nginx
```

### Download APK 404

Penyebab:

```text
src/public/downloads/mindfuledu.apk
```

belum ada di server.

Fix:

```bash
ls -lah src/public/downloads
```

Upload atau download APK ke:

```text
src/public/downloads/mindfuledu.apk
```

### Flutter Tidak Ada di EC2

Error:

```text
Command 'flutter' not found
```

Artinya Flutter belum diinstall di EC2. Cara paling mudah adalah build APK dari laptop lalu upload ke EC2. Jika tetap ingin build di EC2, install Flutter SDK dan Android SDK terlebih dahulu.

### URL Salah karena Format Markdown

Jangan tulis:

```bash
--dart-define=API_BASE_URL=[https://mindfuledu.pkmueu.online/api](https://mindfuledu.pkmueu.online/api)
```

Yang benar:

```bash
--dart-define=API_BASE_URL=https://mindfuledu.pkmueu.online/api
```

## Checklist Cepat

```text
[ ] DNS A record mindfuledu -> IP EC2
[ ] Security Group buka SSH 22, HTTP 80, HTTPS 443
[ ] src/.env production benar
[ ] nginx/default.conf memakai domain production
[ ] docker-compose.yml mount /etc/letsencrypt
[ ] certbot sukses
[ ] docker compose up -d --build
[ ] composer install selesai
[ ] migrate dan seed selesai
[ ] Filament assets dipublish
[ ] Landing page 200 OK
[ ] /admin CSS masuk
[ ] APK tersedia di src/public/downloads/mindfuledu.apk
[ ] /download/android 200 OK
[ ] APK mobile dibuild dengan API_BASE_URL production
```
