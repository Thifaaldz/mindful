# MindfulEdu 2026

MindfulEdu adalah aplikasi mindfulness dan burnout monitoring untuk lingkungan sekolah. Sistem ini dipakai oleh tiga role utama: guru, siswa, dan orang tua. Guru dapat membuat aktivitas pribadi atau aktivitas kelas, siswa dapat mengikuti aktivitas kelas dari guru dan mencatat kondisi dirinya, sedangkan orang tua dapat memantau perkembangan anak melalui kode verifikasi siswa.

Project ini memakai Laravel sebagai pusat backend utama, FastAPI/Python sebagai service analisis dan rekomendasi, MariaDB sebagai database, Nginx sebagai web server, dan Flutter sebagai aplikasi mobile.

## Ringkasan Fitur

- Login/register berbasis email dan Google.
- Pemisahan akses role: `teacher`, `student`, dan `parent`.
- Dashboard role-based dengan theme berbeda.
- Activity ledger harian untuk guru dan siswa.
- Activity guru bertipe kelas, dengan target kelas opsional.
- Jika target kelas kosong, activity tersedia untuk seluruh siswa di sekolah yang sama.
- Jika target kelas diisi, hanya siswa kelas tersebut yang dapat melihat dan join.
- Siswa tidak dapat check-in sebelum guru check-in pada activity kelas.
- Siswa tidak dapat check-out sebelum guru check-out pada activity kelas.
- Check-in mood dan intensitas.
- Check-out jurnal reflektif: fakta, perasaan, pola, rencana, dan tag burnout.
- Analisis burnout harian, mingguan, dan bulanan.
- Review jurnal dan rekomendasi mindfulness berbasis FastAPI, rule engine, dan Gemini jika API key aktif.
- Cache hasil analisis agar token AI tidak boros.
- Toolkit mindfulness berisi knowledge, step latihan, timer, TTS, dan rekomendasi teknik.
- Profile siswa dengan upload avatar, edit sekolah/kelas, dan salin kode parent.
- Dashboard parent untuk monitoring aktivitas dan analisis anak.
- Admin panel Filament untuk pengelolaan data.
- Landing/download APK melalui website.

## Arsitektur

```text
mindfulledu-2026/
├── docker-compose.yml          # Orkestrasi local/production Docker
├── db/                         # Data dan konfigurasi MariaDB
├── docs/                       # Dokumentasi tambahan
├── ml-service/                 # FastAPI Python untuk ML/rule/Gemini
├── nginx/                      # Konfigurasi Nginx dan SSL
├── php/                        # Dockerfile dan entrypoint Laravel PHP-FPM
├── src/                        # Backend Laravel
│   ├── app/
│   │   ├── Http/Controllers/Api/
│   │   ├── Models/
│   │   └── Services/
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   ├── public/
│   ├── resources/
│   └── routes/api.php
└── mindfuledu/                 # Aplikasi mobile Flutter
    ├── lib/
    │   ├── core/
    │   ├── screens/
    │   └── widgets/
    └── pubspec.yaml
```

## Tech Stack

Backend:

- Laravel
- Laravel Sanctum
- Spatie Laravel Permission
- Filament Admin Panel
- MariaDB
- Nginx
- Docker Compose

ML/AI Service:

- FastAPI
- Python
- Gemini API untuk journal review dan rekomendasi mindfulness
- Rule-based fallback saat Gemini/API service tidak tersedia

Mobile:

- Flutter
- Dart
- Google Sign-In
- Secure storage
- Local auth untuk PIN/biometrik
- TTS untuk guided mindfulness tools

## Domain dan URL

Production saat ini dapat diarahkan ke:

```text
Web/API:      https://mindfullapps.pkmueu.online
API base:     https://mindfullapps.pkmueu.online/api
Download APK: https://mindfullapps.pkmueu.online/download/android
```

Local default:

```text
Web/API:      https://mindfulledu.test
API base:     https://mindfulledu.test/api
FastAPI ML:   http://localhost:18000
MariaDB host: localhost:13306
```

## Environment

Laravel env berada di:

```text
src/.env
```

FastAPI env berada di:

```text
ml-service/.env
```

Contoh env Laravel penting:

```env
APP_NAME=MindfulEdu
APP_ENV=local
APP_DEBUG=true
APP_URL=https://mindfulledu.test

DB_CONNECTION=mariadb
DB_HOST=db
DB_PORT=3306
DB_DATABASE=mindfulledu
DB_USERNAME=root
DB_PASSWORD=p455w0rd

MINDFULEDU_ML_URL=http://ml:8000
GOOGLE_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
```

Contoh env FastAPI:

```env
GEMINI_API_KEY=your-gemini-api-key
GEMINI_MODEL=gemini-3.1-flash-lite
GEMINI_TIMEOUT_SECONDS=8
```

Jangan commit API key asli ke GitHub.

## Menjalankan Local Dengan Docker

Tambahkan host lokal:

```bash
sudo sh -c 'echo "127.0.0.1 mindfulledu.test" >> /etc/hosts'
```

Buat SSL lokal jika belum ada:

```bash
mkdir -p nginx/ssl
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout nginx/ssl/mindfulledu.test.key \
  -out nginx/ssl/mindfulledu.test.crt \
  -subj "/CN=mindfulledu.test"
```

Jalankan container:

```bash
docker compose up -d --build
docker compose ps
```

Setup Laravel:

```bash
docker compose exec php composer install
docker compose exec php php artisan key:generate --force
docker compose exec php php artisan migrate --force
docker compose exec php php artisan db:seed --force
docker compose exec php php artisan storage:link
docker compose exec php php artisan optimize:clear
```

Reset database local:

```bash
docker compose exec php php artisan migrate:fresh --seed --force
```

## Menjalankan Flutter

Masuk ke folder aplikasi:

```bash
cd mindfuledu
flutter pub get
```

Run ke device/emulator:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://mindfulledu.test/api \
  --dart-define=API_FALLBACK_URLS=https://mindfulledu.test/api,https://10.0.2.2/api
```

Build APK release production:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://mindfullapps.pkmueu.online/api \
  --dart-define=API_FALLBACK_URLS=https://mindfullapps.pkmueu.online/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
```

Hasil APK:

```text
mindfuledu/build/app/outputs/flutter-apk/app-release.apk
```

## Deploy APK Untuk Download Website

Upload APK ke server:

```bash
scp -i /path/to/mindfullness.pem \
  mindfuledu/build/app/outputs/flutter-apk/app-release.apk \
  ubuntu@16.78.35.91:/home/ubuntu/mindfuledu.apk
```

Pindahkan ke folder publik Nginx/Laravel sesuai konfigurasi server:

```bash
sudo mkdir -p /var/www/html/download
sudo mv /home/ubuntu/mindfuledu.apk /var/www/html/download/mindfuledu.apk
sudo chmod 644 /var/www/html/download/mindfuledu.apk
```

Jika download route diarahkan dari Laravel, simpan juga di:

```bash
mkdir -p src/public/downloads
cp /home/ubuntu/mindfuledu.apk src/public/downloads/mindfuledu.apk
```

Cek:

```bash
curl -I https://mindfullapps.pkmueu.online/download/android
```

## Role dan Akses

`teacher`:

- Login melalui akses guru.
- Membuat activity pribadi.
- Membuat activity kelas bertipe `Mengajar`.
- Menentukan target kelas, misalnya `5A`.
- Melakukan check-in dan check-out sebagai pembuka akses siswa.
- Melihat observasi siswa pada activity kelas.
- Mengisi self report burnout.

`student`:

- Login melalui akses siswa.
- Mengisi profile sekolah dan kelas.
- Membuat activity pribadi siswa.
- Mencari activity kelas dari guru dalam sekolah yang sama.
- Join activity kelas.
- Check-in hanya setelah guru check-in.
- Check-out hanya setelah guru check-out.
- Melihat analisis burnout diri sendiri.
- Menyalin kode verifikasi parent dari profile.

`parent`:

- Login melalui akses orang tua.
- Menautkan anak memakai kode verifikasi siswa dan nama sekolah.
- Melihat activity, check-in, check-out, analisis, dan rekomendasi anak.

## Akun Demo

Password default dari seeder umumnya:

```text
password
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

Admin:

```text
admin@admin.com
```

## Struktur Database Utama

### users

Menyimpan akun semua role.

| Kolom | Fungsi |
| --- | --- |
| `id` | Primary key |
| `avatar_url` | Avatar upload lokal |
| `name` | Nama pengguna |
| `email` | Email unik |
| `password` | Password hash |
| `school` | Nama sekolah |
| `class_id` | Relasi siswa ke `classes.id` |
| `student_verification_code` | Kode siswa untuk parent |
| `google_id` | ID akun Google |
| `google_avatar_url` | Avatar Google |
| `profile_completed` | Status profile lengkap |
| `reminder_enabled` | Reminder aktif/tidak |
| `reminder_time` | Jam reminder |
| `reminder_channel` | `push` atau `email` |
| `reminder_timezone` | Timezone reminder |
| `last_reminder_sent_at` | Waktu reminder terakhir |

Role user dikelola oleh tabel Spatie Permission: `roles`, `permissions`, `model_has_roles`, `model_has_permissions`, dan `role_has_permissions`.

### classes

Menyimpan kelas sekolah.

| Kolom | Fungsi |
| --- | --- |
| `id` | Primary key |
| `name` | Nama kelas, contoh `5A` |
| `grade` | Tingkat kelas, contoh `5` |
| `school` | Sekolah pemilik kelas |

### class_teacher

Pivot guru dan kelas.

| Kolom | Fungsi |
| --- | --- |
| `teacher_id` | Relasi ke `users.id` role guru |
| `class_id` | Relasi ke `classes.id` |

### activities

Tabel inti activity ledger guru dan siswa.

| Kolom | Fungsi |
| --- | --- |
| `id` | Primary key |
| `user_id` | Pemilik activity |
| `title` | Nama activity |
| `category` | Kategori lama, sekarang opsional |
| `activity_kind` | Jenis activity baru, contoh `Mengajar`, `Belajar bersama` |
| `activity_type` | `personal`, `classroom`, atau `classroom_student` |
| `school_class_id` | Target kelas activity guru, nullable untuk semua siswa sekolah |
| `teacher_activity_id` | Relasi activity siswa ke activity guru |
| `joined_at` | Waktu siswa join activity guru |
| `activity_date` | Tanggal activity |
| `start_at` | Jam mulai |
| `end_at` | Jam selesai |
| `planned_hours` | Durasi rencana |
| `actual_hours` | Durasi aktual dari check-in sampai check-out |
| `intensity_factor` | Faktor intensitas activity |
| `intensity_factor_version` | Versi rule intensitas |
| `status` | `planned`, `checked_in`, `completed`, `cancelled` |
| `checkin_at` | Waktu check-in |
| `checkin_mood` | Mood check-in |
| `checkin_intensity` | Intensitas mood 1-10 |
| `checkin_trigger` | Trigger/konteks check-in |
| `checkout_at` | Waktu check-out |
| `checkout_mood` | Mood check-out |
| `checkout_fact` | Fakta jurnal |
| `checkout_feeling` | Perasaan jurnal |
| `checkout_pattern` | Pola yang disadari |
| `checkout_plan` | Rencana setelah activity |
| `checkout_burnout_tags` | Tag burnout manual |
| `checkout_auto_burnout_tags` | Tag burnout hasil AI/rule |
| `checkout_analysis_source` | Sumber analisis journal: `gemini`, `mock`, `php-fallback`, dll |
| `checkout_analysis_raw_response` | Raw response AI jika ada |
| `checkout_mood_detected` | Mood terdeteksi oleh AI/rule |
| `checkout_suggestion` | Saran journal |
| `checkout_crisis_flag` | Flag indikasi krisis |

### activity_events

Audit trail activity.

| Kolom | Fungsi |
| --- | --- |
| `activity_id` | Relasi ke `activities.id` |
| `event_type` | Event, contoh `activity_created`, `check_in_submitted` |
| `occurred_at` | Waktu event |
| `metadata` | Detail event JSON |

### burnout_analysis_snapshots

Riwayat hasil analisis burnout.

| Kolom | Fungsi |
| --- | --- |
| `user_id` | Pemilik analisis |
| `source` | Sumber trigger, contoh `manual`, `parent_dashboard` |
| `period_type` | `daily`, `weekly`, `monthly` |
| `period_start` | Awal periode |
| `period_end` | Akhir periode |
| `data_sufficiency` | Data cukup untuk skor final |
| `activity_count` | Jumlah activity periode |
| `completed_activity_count` | Jumlah activity selesai |
| `weighted_planned_hours` | Jam rencana berbobot |
| `weighted_actual_hours` | Jam aktual berbobot |
| `workload_score_raw` | Skor beban kerja/belajar |
| `workload_variance_pct` | Selisih aktual vs rencana |
| `journal_score` | Skor wellbeing dari check-in/check-out/journal |
| `final_burnout_risk_score` | Skor akhir burnout |
| `category` | `hijau`, `kuning`, `merah` |
| `dominant_factors` | Faktor dominan |
| `recommendation_codes` | Kode rekomendasi |
| `recommendation_summary` | Feedback dan tactic yang disarankan |
| `model_version` | Versi model/rule |
| `scoring_version` | Versi scoring |
| `threshold_version` | Versi threshold |
| `payload` | Breakdown, review journal, cache key, dan metadata |

### burnout_self_reports

Self report guru untuk menambah konteks analisis.

| Kolom | Fungsi |
| --- | --- |
| `user_id` | Guru |
| `level` | Level 0-10 |

### parent_student_links

Relasi parent dengan siswa.

| Kolom | Fungsi |
| --- | --- |
| `parent_id` | User role parent |
| `student_id` | User role student |
| `verified_at` | Waktu verifikasi kode |

### mindful_tactics

Master toolkit mindfulness.

| Kolom | Fungsi |
| --- | --- |
| `title` | Nama teknik |
| `category` | Kode/kategori teknik |
| `description` | Deskripsi pendek |
| `knowledge` | Materi edukasi sebelum mulai latihan |
| `duration_minutes` | Durasi latihan |
| `steps` | Langkah-langkah latihan JSON |
| `cues` | Cue/pengingat TTS JSON |
| `best_for` | Kondisi yang cocok untuk teknik ini |
| `sort_order` | Urutan tampil |

### tactic_bookmarks

Bookmark toolkit per user.

| Kolom | Fungsi |
| --- | --- |
| `user_id` | User |
| `mindful_tactic_id` | Teknik mindfulness |

### mindfulness_sessions

Riwayat guided mindfulness session.

| Kolom | Fungsi |
| --- | --- |
| `user_id` | Pemilik session |
| `started_at` | Waktu mulai |
| `completed_at` | Waktu selesai |
| `duration_seconds` | Durasi detik |
| `distraction_score` | Jumlah distraksi |
| `calmness_before` | Skor tenang sebelum |
| `calmness_after` | Skor tenang sesudah |
| `reflection` | Refleksi |
| `body_note` | Catatan tubuh |
| `helpful_note` | Hal yang membantu |
| `logbook_answers` | Jawaban logbook JSON |
| `status` | `in_progress` atau `completed` |

### student_observations

Observasi manual siswa oleh guru.

| Kolom | Fungsi |
| --- | --- |
| `teacher_id` | Guru pengobservasi |
| `student_id` | Siswa |
| `class_id` | Kelas |
| `observed_on` | Tanggal observasi |
| `perasaan` | Status hijau/kuning/merah |
| `perilaku` | Status hijau/kuning/merah |
| `tubuh` | Status hijau/kuning/merah |
| `teman` | Status hijau/kuning/merah |
| `belajar` | Status hijau/kuning/merah |
| `status` | Status akhir |
| `notes` | Catatan guru |

### badges dan user_badges

Sistem badge/achievement user.

### questionnaire_responses

Riwayat kuesioner.

| Kolom | Fungsi |
| --- | --- |
| `user_id` | User |
| `respondent_profile` | Profil responden JSON |
| `answers` | Jawaban JSON |
| `overall_score` | Skor total |
| `percentage_score` | Persentase skor |
| `comment` | Komentar |
| `submitted_at` | Waktu submit |

### personal_access_tokens

Token Laravel Sanctum untuk mobile API.

## Activity Type dan Logic Kelas

Nilai `activity_type`:

```text
personal           Activity pribadi guru/siswa
classroom          Activity kelas yang dibuat guru
classroom_student  Salinan activity kelas setelah siswa join
```

Logic activity kelas:

- Guru membuat activity dengan `activity_kind = Mengajar`.
- Jika `school_class_name` kosong, `school_class_id` null dan activity terbuka untuk semua siswa dengan sekolah sama.
- Jika `school_class_name = 5A`, sistem mencari/membuat kelas `5A` di sekolah guru.
- Siswa hanya melihat activity kelas dari guru dengan sekolah yang sama.
- Siswa hanya melihat activity kelas spesifik jika `users.class_id` sama dengan `activities.school_class_id`.
- Saat siswa join, sistem membuat activity baru untuk siswa dengan `teacher_activity_id` mengarah ke activity guru.
- Siswa check-in ditolak jika `teacherActivity.checkin_at` masih null.
- Siswa check-out ditolak jika `teacherActivity.checkout_at` masih null.

## Burnout Analysis

Analisis burnout memakai data activity dalam periode:

- `daily`
- `weekly`
- `monthly`

Data yang dihitung:

- jumlah activity
- jumlah completed activity
- weighted planned hours
- weighted actual hours
- workload score
- journal/wellbeing score
- final burnout risk score
- category hijau/kuning/merah
- dominant factors
- review journal
- rekomendasi mindfulness

Rumus utama:

```text
Final Score = 50% Workload Score + 50% Wellbeing Score
```

Catatan:

- Activity selesai memakai nilai terbesar dari `actual_hours` dan `planned_hours`.
- Activity belum selesai memakai `planned_hours`.
- Jurnal check-out dibutuhkan agar data dianggap cukup untuk final score.
- Jika ada crisis flag, score dinaikkan minimal ke risiko merah.
- Hasil manual analysis disimpan di `burnout_analysis_snapshots`.
- Jika data periode sama, analisis menggunakan cache snapshot agar tidak memanggil AI berulang.

## Gemini dan FastAPI

Laravel memanggil FastAPI melalui:

```env
MINDFULEDU_ML_URL=http://ml:8000
```

Endpoint Python:

```text
GET  /health
POST /analyze/journal
POST /score/burnout
POST /recommendation/burnout
```

Gemini dipakai di Python jika `GEMINI_API_KEY` tersedia:

- `/analyze/journal` mencoba Gemini untuk mendeteksi mood, suggestion, crisis flag, dan burnout dimension.
- `/score/burnout` menghitung skor secara deterministic/rule-based, lalu meminta Gemini memilih rekomendasi mindfulness dari katalog sistem.
- Jika Gemini gagal/offline, service fallback ke rule lokal.

Cek Gemini API manual:

```bash
export GEMINI_API_KEY="your-gemini-api-key"

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Berikan satu kalimat motivasi singkat untuk guru yang lelah setelah mengajar."
      }]
    }]
  }'
```

## REST API

Base URL:

```text
https://mindfullapps.pkmueu.online/api
```

Header authenticated request:

```http
Accept: application/json
Authorization: Bearer {token}
```

### Auth

| Method | Endpoint | Auth | Role | Fungsi |
| --- | --- | --- | --- | --- |
| POST | `/register` | No | teacher/student/parent | Register email |
| POST | `/login` | No | teacher/student/parent | Login email |
| POST | `/auth/google` | No | teacher/student/parent | Login/register Google |
| POST | `/logout` | Yes | all | Logout token saat ini |
| GET | `/me` | Yes | all | Ambil profile user |
| PUT | `/me/profile` | Yes | all | Update profile |
| POST | `/me/avatar` | Yes | all | Upload avatar |

Register body:

```json
{
  "name": "Guru Demo",
  "email": "guru@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "teacher",
  "school": "SDN Harmoni",
  "class_name": null,
  "student_verification_code": null
}
```

Login body:

```json
{
  "email": "guru@mindfuledu.test",
  "password": "password",
  "role": "teacher"
}
```

Google body:

```json
{
  "id_token": "google-id-token-from-mobile",
  "role": "student"
}
```

Profile update body:

```json
{
  "name": "Budi",
  "role": "student",
  "school": "SDN Harmoni",
  "class_name": "5A"
}
```

Parent profile/register membutuhkan:

```json
{
  "role": "parent",
  "school": "SDN Harmoni",
  "student_verification_code": "STU-ABCDEFGH"
}
```

### Dashboard dan Reminder

| Method | Endpoint | Auth | Role | Fungsi |
| --- | --- | --- | --- | --- |
| GET | `/dashboard` | Yes | teacher/student | Ringkasan aktivitas user |
| GET | `/reminder-preference` | Yes | all | Ambil pengaturan reminder |
| PUT | `/reminder-preference` | Yes | all | Update reminder |

Reminder body:

```json
{
  "enabled": true,
  "time": "07:00",
  "channel": "push",
  "timezone": "Asia/Jakarta"
}
```

### Activities

| Method | Endpoint | Auth | Role | Fungsi |
| --- | --- | --- | --- | --- |
| GET | `/activities?date=YYYY-MM-DD` | Yes | teacher/student | List activity harian |
| POST | `/activities` | Yes | teacher/student | Buat activity |
| GET | `/activities/{id}` | Yes | owner | Detail activity dan event |
| PUT | `/activities/{id}` | Yes | owner | Update activity |
| POST | `/activities/{id}/check-in` | Yes | owner | Submit check-in |
| POST | `/activities/{id}/check-out` | Yes | owner | Submit check-out journal |
| POST | `/activities/{id}/cancel` | Yes | owner | Cancel activity |
| POST | `/activities/{id}/duplicate` | Yes | owner | Duplikasi activity |
| GET | `/activities/{id}/ledger` | Yes | owner | Audit event activity |

Create personal activity:

```json
{
  "title": "Belajar bersama",
  "activity_date": "2026-09-02",
  "start_time": "08:00",
  "end_time": "09:00",
  "activity_kind": "Belajar bersama",
  "activity_type": "personal",
  "repeat_type": "none"
}
```

Create teacher classroom activity untuk semua siswa sekolah:

```json
{
  "title": "Mengajar literasi sekolah",
  "activity_date": "2026-09-02",
  "start_time": "10:00",
  "end_time": "11:00",
  "activity_kind": "Mengajar",
  "activity_type": "classroom"
}
```

Create teacher classroom activity khusus kelas:

```json
{
  "title": "Mengajar IPA",
  "activity_date": "2026-09-02",
  "start_time": "08:00",
  "end_time": "09:00",
  "activity_kind": "Mengajar",
  "activity_type": "classroom",
  "school_class_name": "5A"
}
```

Repeat activity:

```json
{
  "title": "Belajar matematika",
  "activity_date": "2026-09-02",
  "start_time": "08:00",
  "end_time": "09:00",
  "activity_kind": "Belajar di kelas",
  "activity_type": "personal",
  "repeat_type": "weekly",
  "repeat_until": "2026-09-30"
}
```

Check-in body:

```json
{
  "mood": "senang",
  "intensity": 4,
  "trigger": "Siap mengikuti pelajaran"
}
```

Mood check-in valid:

```text
senang, tenang, cemas, sedih, marah
```

Check-out body:

```json
{
  "mood": "cemas",
  "fact": "Materi hari ini cukup padat.",
  "feeling": "Saya sedikit cemas karena takut tertinggal.",
  "pattern": "Saya mudah panik saat tugas menumpuk.",
  "plan": "Saya akan mengulang materi pelan-pelan.",
  "burnout_tags": ["kelelahan_emosional"]
}
```

Burnout tag valid:

```text
kelelahan_emosional
depersonalisasi
rendah_pencapaian_diri
```

Response `/activities` untuk activity siswa dari kelas membawa `classroom_gate`:

```json
{
  "classroom_gate": {
    "teacher_activity_id": 10,
    "teacher_checkin_available": true,
    "teacher_checkout_available": false,
    "can_student_check_in": true,
    "can_student_check_out": false,
    "message": "Menunggu guru melakukan check-out."
  }
}
```

### Classroom

| Method | Endpoint | Auth | Role | Fungsi |
| --- | --- | --- | --- | --- |
| GET | `/classroom/activities/available?date=YYYY-MM-DD` | Yes | student | Activity kelas yang bisa di-join |
| POST | `/classroom/activities/{activity}/join` | Yes | student | Join activity guru |
| GET | `/teacher/classroom-activities/{activity}/observations` | Yes | teacher | Observasi siswa pada activity kelas |

Available classroom response:

```json
{
  "date": "2026-09-02",
  "activities": [
    {
      "id": 10,
      "title": "Mengajar IPA",
      "activity_type": "classroom",
      "activity_kind": "Mengajar",
      "teacher_checkin_available": false,
      "teacher_checkout_available": false,
      "teacher": {
        "id": 1,
        "name": "Guru Demo",
        "school": "SDN Harmoni"
      },
      "class": {
        "id": 2,
        "name": "5A",
        "school": "SDN Harmoni"
      }
    }
  ]
}
```

Join response:

```json
{
  "activity": {
    "activity_type": "classroom_student",
    "teacher_activity_id": 10,
    "classroom_gate": {
      "can_student_check_in": false,
      "message": "Menunggu guru melakukan check-in."
    }
  }
}
```

### Burnout Analysis

| Method | Endpoint | Auth | Role | Fungsi |
| --- | --- | --- | --- | --- |
| GET | `/burnout-analyses` | Yes | teacher/student | Riwayat analisis |
| GET | `/burnout-analyses/overview` | Yes | teacher/student | Overview analisis dan graph history |
| POST | `/burnout-analyses` | Yes | teacher/student | Jalankan analisis manual |
| POST | `/burnout-self-reports` | Yes | teacher | Tambah self-report guru |

Create analysis body:

```json
{
  "period_type": "daily",
  "date": "2026-09-02"
}
```

`period_type` valid:

```text
daily, weekly, monthly
```

Self report body:

```json
{
  "level": 7
}
```

### Toolkit

| Method | Endpoint | Auth | Role | Fungsi |
| --- | --- | --- | --- | --- |
| GET | `/toolkit/tactics` | Yes | all | List teknik mindfulness |
| GET | `/toolkit/tactics/bookmarked` | Yes | all | List bookmark user |
| POST | `/toolkit/tactics/{tactic}/bookmark` | Yes | all | Toggle bookmark |

Toolkit item:

```json
{
  "id": 1,
  "title": "Body Scan Singkat",
  "category": "body_scan_micro",
  "description": "Latihan menyadari sensasi tubuh.",
  "knowledge": "Materi edukasi sebelum mulai.",
  "duration_minutes": 5,
  "steps": ["Duduk nyaman", "Sadari napas"],
  "cues": ["Lanjut ke bagian tubuh berikutnya"],
  "best_for": ["lelah", "cemas"],
  "is_bookmarked": false
}
```

### Parent

| Method | Endpoint | Auth | Role | Fungsi |
| --- | --- | --- | --- | --- |
| GET | `/parent/dashboard?date=YYYY-MM-DD` | Yes | parent | Monitoring anak |
| POST | `/parent/children` | Yes | parent | Tautkan anak |

Link child body:

```json
{
  "student_verification_code": "STU-ABCDEFGH",
  "school": "SDN Harmoni"
}
```

## FastAPI Endpoints

Base local Docker internal:

```text
http://ml:8000
```

Base host:

```text
http://localhost:18000
```

| Method | Endpoint | Fungsi |
| --- | --- | --- |
| GET | `/health` | Health check ML service |
| POST | `/analyze/journal` | Analisis satu jurnal |
| POST | `/score/burnout` | Hitung score dan rekomendasi periode |
| POST | `/recommendation/burnout` | Rekomendasi mindfulness dari category/factor |

Analyze journal body:

```json
{
  "fact": "Pelajaran cukup padat.",
  "feeling": "Saya cemas.",
  "pattern": "Mudah panik saat tugas banyak.",
  "plan": "Mengulang materi pelan-pelan.",
  "burnout_tags": ["kelelahan_emosional"]
}
```

## Testing

Backend:

```bash
docker compose exec -T php php artisan test
```

Test penting yang mencakup flow utama:

```bash
docker compose exec -T php php artisan test \
  tests/Feature/AuthFlowTest.php \
  tests/Feature/ActivityLedgerTest.php
```

Flutter:

```bash
cd mindfuledu
flutter analyze
flutter test
```

PHP syntax check:

```bash
docker compose exec -T php php -l app/Http/Controllers/Api/ActivityController.php
docker compose exec -T php php -l app/Http/Controllers/Api/ClassroomActivityController.php
```

## Docker Services

| Service | Container | Port | Fungsi |
| --- | --- | --- | --- |
| `nginx` | `mindfulledu_nginx` | `80`, `443` | Web server Laravel |
| `php` | `mindfulledu_php` | internal `9000` | PHP-FPM Laravel |
| `db` | `mindfulledu_db` | `13306 -> 3306` | MariaDB |
| `ml` | `mindfulledu_ml` | `18000 -> 8000` | FastAPI ML/Gemini |

Command umum:

```bash
docker compose ps
docker compose logs -f php
docker compose logs -f nginx
docker compose logs -f ml
docker compose exec php php artisan optimize:clear
docker compose down
docker compose up -d --build
```

## Catatan Google Sign-In

Android Google Sign-In membutuhkan OAuth Client tipe Android dengan:

- Package name sesuai `AndroidManifest.xml`.
- SHA-1 debug atau release sesuai APK yang dipakai.
- Web client ID dipakai sebagai `GOOGLE_SERVER_CLIENT_ID` di Flutter dan `GOOGLE_CLIENT_ID` di Laravel.

Build dengan define:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://mindfullapps.pkmueu.online/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
```

## Troubleshooting

Permission SSH key terlalu terbuka:

```bash
chmod 400 mindfullness.pem
ssh -i mindfullness.pem ubuntu@16.78.35.91
```

Docker migration duplicate column:

```bash
docker compose exec php php artisan migrate:status
docker compose exec php php artisan optimize:clear
```

Untuk local development jika database boleh reset:

```bash
docker compose exec php php artisan migrate:fresh --seed --force
```

APK blank screen:

- Pastikan APK dibuild dengan `API_BASE_URL` production yang benar.
- Pastikan endpoint `/api` bisa diakses dari HP.
- Pastikan SSL domain valid.
- Cek log Android:

```bash
adb logcat | grep -i flutter
```

Gemini tidak jalan:

```bash
docker compose exec ml sh -lc 'echo ${GEMINI_MODEL:-empty}; test -n "$GEMINI_API_KEY" && echo GEMINI_API_KEY=set || echo GEMINI_API_KEY=empty'
docker compose logs -f ml
```

## Security Notes

- Jangan commit file `.env`.
- Jangan commit Gemini API key, Google Client Secret, private key `.pem`, atau credential production.
- API mobile memakai Sanctum token.
- Parent hanya bisa link anak jika kode siswa dan sekolah cocok.
- Siswa hanya dapat join activity kelas dari sekolah yang sama.
- Activity kelas spesifik hanya tersedia untuk siswa di kelas yang sama.
