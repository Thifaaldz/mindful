# README Penjabaran Sistem MindfulEdu Detail

Dokumen ini menjelaskan MindfulEdu sebagai sistem: tujuan, aktor, fitur, alur data, komponen teknis, analisis burnout, rekomendasi AI/rule, dan kegiatan mindfulness yang tersedia.

Dokumen ini berbeda dari manual guide video. File ini dipakai untuk memahami sistem secara konseptual dan teknis.

---

## 1. Ringkasan Sistem

MindfulEdu adalah aplikasi pendamping sekolah untuk mencatat aktivitas harian, mood, jurnal reflektif, analisis burnout, dan rekomendasi latihan mindfulness.

Sistem ini terdiri dari:

- website publik untuk pendaftaran sekolah dan download APK;
- aplikasi Flutter untuk guru, siswa, dan parent;
- Laravel API untuk autentikasi, activity, jurnal, analisis, parent monitoring, dan admin;
- Filament Admin Panel untuk super admin dan admin sekolah;
- Python/FastAPI service untuk membantu analisis dan rekomendasi;
- MariaDB sebagai database utama;
- local notification di aplikasi mobile untuk reminder.

MindfulEdu bukan alat diagnosis medis. Hasil analisis digunakan sebagai pendukung refleksi dan monitoring, bukan pengganti pemeriksaan profesional.

---

## 2. Tujuan Sistem

Tujuan utama:

- membantu sekolah mengelola pengguna berdasarkan sekolah dan kelas;
- membantu guru mencatat aktivitas mengajar dan memahami kondisi diri;
- membantu siswa membaca hubungan aktivitas, mood, dan jurnal;
- membantu parent memantau kondisi anak secara terbatas;
- membantu admin sekolah melakukan approval dan monitoring data sekolah;
- memberi rekomendasi mindfulness yang sesuai dengan kondisi pengguna;
- menyediakan data ringkas untuk observasi dan evaluasi harian.

Masalah yang diselesaikan:

| Masalah | Solusi MindfulEdu |
|---|---|
| Activity harian tidak tercatat rapi | Activity tracking dengan status planned, checked-in, completed |
| Kondisi mood sulit dipantau | Check-in dan check-out mood |
| Refleksi pengguna tidak terdokumentasi | Jurnal check-out |
| Guru sulit melihat kondisi siswa di kelas | Observasi siswa pada activity kelas |
| Orang tua tidak punya ringkasan kondisi anak | Parent monitoring |
| Rekomendasi pemulihan tidak terarah | Toolkit dan rekomendasi mindfulness |
| Data sekolah bercampur | Role dan scope berdasarkan sekolah |

---

## 3. Aktor dan Role

| Role | Fungsi Utama |
|---|---|
| Super Admin | Mengelola semua sekolah dan seluruh data sistem |
| Admin Sekolah | Mengelola data sekolahnya sendiri |
| Guru | Membuat activity, check-in/check-out, jurnal, analisis, observasi siswa |
| Siswa | Membuat activity, join activity kelas, check-in/check-out, jurnal, analisis |
| Parent | Menghubungkan anak dan memantau ringkasan kondisi anak |

Aturan akses:

- super admin dapat melihat semua data;
- admin sekolah hanya melihat data sekolahnya;
- guru hanya melihat data activity sendiri dan observasi siswa pada activity kelas miliknya;
- siswa hanya melihat data dirinya dan activity kelas yang sesuai;
- parent hanya melihat anak yang sudah terhubung;
- data antar sekolah dipisahkan.

---

## 4. Komponen Teknis

| Komponen | Fungsi |
|---|---|
| Website publik | Landing page, pendaftaran sekolah, download APK |
| Flutter app | Antarmuka guru, siswa, parent |
| Laravel API | Backend utama mobile dan web |
| Filament Admin | Dashboard super admin dan admin sekolah |
| FastAPI ML Service | Analisis teks, scoring tambahan, rekomendasi |
| MariaDB | Penyimpanan data utama |
| Docker Compose | Menjalankan nginx, php, db, dan ml |
| Local Notification | Reminder harian dan reminder activity di perangkat |

Target production:

```text
Website      : https://mindfulapps.pkmueu.online
API Mobile   : https://mindfulapps.pkmueu.online/api
Download APK : https://mindfulapps.pkmueu.online/download/android
Admin Panel  : https://mindfulapps.pkmueu.online/admin
```

Alur teknis:

```text
Website / Flutter
  -> Laravel API
  -> MariaDB
  -> FastAPI ML Service jika analisis membutuhkan bantuan
  -> Laravel menyimpan hasil
  -> Flutter / Admin Panel menampilkan hasil
```

---

## 5. Alur Sistem Dari Awal Sampai Akhir

```text
Sekolah daftar di website
  -> super admin review pendaftaran
  -> super admin approve sekolah
  -> super admin membuat admin sekolah
  -> admin sekolah membuat kelas
  -> guru dan siswa register di aplikasi
  -> akun guru/siswa masuk pending
  -> admin sekolah approve akun
  -> guru dan siswa login
  -> guru membuat activity kelas
  -> siswa join activity kelas
  -> guru dan siswa check-in
  -> guru dan siswa check-out
  -> jurnal tersimpan
  -> sistem membuat review activity
  -> sistem membuat analisis burnout
  -> sistem memberi rekomendasi mindfulness
  -> pengguna menjalankan guided practice
  -> parent memantau anak jika sudah terhubung
```

---

## 6. Pendaftaran Sekolah

Pendaftaran sekolah dilakukan dari website publik.

Data yang dikirim:

| Field | Fungsi |
|---|---|
| Nama sekolah | Identitas sekolah |
| NPSN | Nomor pokok sekolah jika ada |
| Jenjang | SD, SMP, SMA, atau lainnya |
| Status sekolah | Negeri atau swasta |
| Alamat | Alamat lengkap |
| Provinsi | Wilayah tingkat provinsi |
| Kota/Kabupaten | Wilayah tingkat kota/kabupaten |
| Kecamatan | Wilayah tingkat kecamatan |
| Nama kontak | Penanggung jawab |
| Jabatan kontak | Jabatan kontak |
| Email kontak | Kontak email |
| Nomor telepon | Kontak telepon |

Nested choice wilayah:

```text
Pilih provinsi
  -> sistem memuat kota/kabupaten sesuai provinsi
  -> pilih kota/kabupaten
  -> sistem memuat kecamatan sesuai kota/kabupaten
  -> pilih kecamatan
```

Endpoint wilayah:

```text
GET /regions/provinces
GET /regions/regencies/{provinceCode}
GET /regions/districts/{regencyCode}
```

Status sekolah:

| Status | Makna |
|---|---|
| Pending | Baru daftar dan menunggu review |
| Approved | Diterima dan bisa dipakai register |
| Rejected | Ditolak atau perlu perbaikan data |

---

## 7. Register dan Approval Pengguna

Guru dan siswa:

```text
Register aplikasi
  -> pilih sekolah
  -> siswa memilih kelas
  -> akun dibuat pending
  -> admin sekolah atau super admin approve
  -> akun bisa login
```

Parent:

```text
Register aplikasi
  -> login
  -> hubungkan anak dengan kode siswa dan sekolah
  -> parent bisa melihat monitoring anak
```

Aturan:

- guru/siswa pending tidak bisa login;
- approval guru/siswa hanya relevan untuk sekolah tempat user mendaftar;
- admin sekolah lain tidak melihat request dari sekolah berbeda;
- approval tidak harus mengirim email jika proses pemberitahuan dilakukan secara pribadi;
- register Google tetap dapat memakai password agar akun bisa login manual.

---

## 8. Login dan Sesi

Login berbasis role:

```text
Pengguna memilih role
  -> login email/password atau Google
  -> sistem cek role, credential, dan approval
  -> token dibuat
  -> sesi lama dicabut
  -> pengguna masuk dashboard role
```

Prinsip keamanan sesi:

- satu akun hanya memiliki satu sesi aktif;
- token lama dicabut saat login baru;
- login dicatat ke login history;
- role mismatch ditolak.

---

## 9. Activity Tracking

Activity adalah pusat data sistem.

Status activity:

| Status | Makna |
|---|---|
| Planned | Activity dibuat, belum check-in |
| Checked in | Activity sedang berjalan |
| Completed | Activity selesai dan sudah check-out |
| Cancelled | Activity dibatalkan |

Data activity:

- judul activity;
- category/jenis activity;
- tanggal;
- jam mulai dan selesai;
- planned hours;
- actual hours;
- intensity factor;
- mood check-in;
- intensitas mood awal;
- alasan check-in;
- mood check-out;
- jurnal check-out;
- review activity;
- rekomendasi mindfulness.

Activity guru:

- activity pribadi;
- activity mengajar;
- activity mengajar dapat ditargetkan ke kelas tertentu.

Activity siswa:

- activity pribadi;
- activity kelas dari guru yang dijoin siswa.

---

## 10. Check-In

Check-in mencatat kondisi sebelum activity.

Flow:

```text
Buka activity
  -> tekan Check-in
  -> pilih mood
  -> isi intensitas
  -> isi alasan jika perlu
  -> submit
```

Mood:

| Mood | Makna Analisis |
|---|---|
| Senang | Positif |
| Tenang | Stabil |
| Cemas | Negatif |
| Sedih | Negatif |
| Marah | Negatif |

Pada activity kelas:

- siswa belum bisa check-in sebelum guru check-in;
- check-in guru menjadi tanda activity kelas dimulai.

---

## 11. Check-Out dan Jurnal

Check-out menutup activity dan memicu data analisis.

Flow:

```text
Buka activity checked-in
  -> tekan Check-out
  -> pilih mood akhir
  -> isi jurnal
  -> submit
  -> activity menjadi completed
  -> review activity diproses
```

Field jurnal:

| Field | Fungsi |
|---|---|
| Fakta | Apa yang terjadi |
| Perasaan | Bagaimana perasaan pengguna |
| Pola | Pola yang disadari |
| Rencana | Langkah berikutnya |
| Tag burnout | Khusus guru jika ada dimensi burnout |

Pada activity kelas:

- siswa belum bisa check-out sebelum guru check-out;
- setelah guru check-out, siswa dapat check-out dan isi jurnal;
- hasil siswa dapat muncul pada observasi guru.

---

## 12. Analisis Burnout

Analisis membaca activity selesai, durasi aktual, intensity factor, mood, jurnal, burnout tags, dan self report jika ada.

Versi perhitungan:

```text
scoring-v2.5-edumindful
```

Kapasitas:

| Periode | Rentang | Kapasitas |
|---|---|---:|
| Harian | 1 tanggal | 8 jam |
| Mingguan | 7 hari terakhir | 56 jam |
| Bulanan | 30 hari terakhir | 240 jam |

Formula workload:

```text
Workload Score = min(100, total(actual_hours x intensity_factor) / kapasitas_periode x 100)
```

Formula final:

```text
Final Score = min(100, 50% workload_score + 50% wellbeing_score)
```

Kategori:

| Kategori | Rentang | Makna |
|---|---:|---|
| Hijau | 0 - 39.99 | Kondisi relatif stabil |
| Kuning | 40 - 69.99 | Ada tanda perlu jeda |
| Merah | 70 - 100 | Beban atau tekanan tinggi |

Catatan:

- activity positif tetap masuk riwayat dan workload jika sudah selesai;
- mood positif tidak otomatis menambah risiko wellbeing;
- kesimpulan harian dibuat berdasarkan kegiatan hari ini;
- hasil analisis disimpan sebagai snapshot untuk history.

---

## 13. Rekomendasi Sistem

Rekomendasi dibuat dari faktor dominan dalam periode.

Contoh faktor:

- workload padat;
- workload melebihi kapasitas;
- mood check-out negatif;
- jurnal mengandung tekanan;
- burnout tag guru;
- self report guru tinggi;
- crisis flag;
- kondisi stabil/hijau.

Contoh mapping:

| Kondisi | Rekomendasi |
|---|---|
| Cemas atau panik | Grounding 3-2-1 |
| Tegang atau sulit tenang | Napas 4-7-8 |
| Butuh jeda cepat | Teknik STOP |
| Kondisi hijau siswa | Jeda Napas 3 Menit |
| Kondisi hijau guru | Awareness of Breathing |
| Sulit fokus | Mindful Breathing atau Focused Attention |
| Mood negatif setelah activity | Body Scan Singkat |
| Burnout tinggi | Body Scan Penuh |
| Activity padat atau tubuh kaku | Mindful Movement |
| Jenuh dan butuh bergerak | Walking Meditation |
| Banyak pikiran | Sitting Meditation |
| Pikiran dan emosi bercampur | Open Monitoring |
| Sulit fokus pada napas | Mindfulness of Sounds |
| Sedih, marah, frustrasi | RAIN |
| Konflik atau rendah pencapaian diri | Loving-Kindness |
| Emosi naik turun | Mountain Meditation |
| Waktu terbatas | Informal Mindfulness |
| Perlu membaca pola harian | Jurnal Reflektif Harian |

---

## 14. Kegiatan Mindfulness Di Sistem

### 14.1 Teknik STOP

Fungsi: jeda cepat agar pengguna tidak langsung bereaksi saat emosi naik.

Step:

```text
1. Stop.
2. Take a breath.
3. Observe.
4. Proceed.
```

Cocok untuk:

- marah;
- cemas;
- konflik;
- reaksi impulsif.

### 14.2 Grounding 3-2-1

Fungsi: mengembalikan perhatian ke lingkungan nyata.

Step:

```text
1. Lihat tiga hal.
2. Dengar dua suara.
3. Rasakan satu sensasi tubuh.
4. Tenangkan tubuh dengan napas pelan.
```

Cocok untuk:

- cemas;
- panik;
- kewalahan;
- pikiran terlalu penuh.

### 14.3 Napas 4-7-8

Fungsi: menenangkan tubuh dengan pola napas terstruktur.

Step:

```text
1. Posisi nyaman.
2. Tarik napas 4 hitungan.
3. Tahan napas 7 hitungan.
4. Hembuskan 8 hitungan.
5. Ulangi.
```

Cocok untuk:

- tegang;
- stres;
- sulit tidur;
- tubuh terlalu aktif.

### 14.4 Jeda Napas 3 Menit

Fungsi: transisi pendek antara satu aktivitas dan aktivitas lain.

Step:

```text
1. Sadari kondisi.
2. Fokus napas.
3. Perluas perhatian ke tubuh.
4. Tutup dengan niat lembut.
```

Cocok untuk:

- sebelum kelas;
- setelah aktivitas berat;
- tekanan ringan;
- butuh fokus ulang.

### 14.5 Awareness of Breathing

Fungsi: menjaga perhatian pada napas natural tanpa mengubahnya.

Step:

```text
1. Duduk stabil.
2. Sadari napas masuk.
3. Sadari napas keluar.
4. Kembali dari distraksi.
5. Tutup dengan napas panjang.
```

Cocok untuk:

- kondisi stabil;
- latihan dasar;
- menjaga fokus;
- menjaga ritme harian.

### 14.6 Mindful Breathing

Fungsi: memakai napas sebagai anchor perhatian.

Step:

```text
1. Persiapan tubuh.
2. Sadari napas.
3. Kembali dari distraksi.
4. Penutup.
```

Cocok untuk:

- sulit fokus;
- pikiran ramai;
- stres ringan;
- jeda setelah activity.

### 14.7 Focused Attention Meditation

Fungsi: mempertahankan perhatian pada satu anchor.

Step:

```text
1. Pilih anchor.
2. Pertahankan fokus.
3. Label distraksi dan kembali.
4. Penutup.
```

Cocok untuk:

- distraksi;
- sulit konsentrasi;
- fokus belajar;
- kebiasaan berpindah perhatian.

### 14.8 Body Scan Singkat

Fungsi: memindai tubuh untuk membaca ketegangan.

Step:

```text
1. Persiapan.
2. Kaki.
3. Tungkai.
4. Panggul dan punggung bawah.
5. Perut.
6. Dada.
7. Tangan dan lengan.
8. Bahu dan leher.
9. Wajah dan kepala.
10. Seluruh tubuh.
```

Cocok untuk:

- lelah;
- mood negatif;
- tubuh tegang;
- pemulihan singkat.

### 14.9 Body Scan Penuh

Fungsi: pemulihan lebih panjang saat sinyal burnout tinggi.

Step sama dengan body scan singkat, tetapi durasi lebih panjang dan ritme lebih pelan.

Cocok untuk:

- burnout tinggi;
- kelelahan emosional;
- pemulihan panjang;
- tekanan besar.

### 14.10 Sitting Meditation

Fungsi: menyadari napas, tubuh, suara, pikiran, dan emosi.

Step:

```text
1. Posisi tubuh.
2. Napas.
3. Sensasi tubuh.
4. Suara.
5. Pikiran.
6. Emosi.
7. Penutup.
```

Cocok untuk:

- banyak pikiran;
- stres;
- emosi bercampur;
- kewalahan.

### 14.11 Mindful Movement

Fungsi: peregangan ringan dengan perhatian penuh.

Step:

```text
1. Grounding.
2. Bahu naik-turun.
3. Putar bahu.
4. Angkat tangan.
5. Leher kanan-kiri.
6. Punggung atas.
7. Pinggang dan kaki.
8. Penutup.
```

Cocok untuk:

- duduk lama;
- tubuh kaku;
- lelah fisik;
- aktivitas padat.

### 14.12 Walking Meditation

Fungsi: berjalan pelan sambil menyadari tubuh, langkah, napas, dan lingkungan.

Step:

```text
1. Berdiri dan sadari kontak kaki.
2. Mulai berjalan.
3. Sadari angkat, gerak, dan sentuh.
4. Sadari gerakan seluruh tubuh.
5. Hubungkan napas dan langkah.
6. Sadari lingkungan.
7. Perlambat, berhenti, dan tutup sesi.
```

Cocok untuk:

- jenuh;
- gelisah;
- butuh bergerak;
- transisi antar kelas.

### 14.13 Open Monitoring

Fungsi: mengamati pengalaman yang muncul tanpa memilih atau langsung bereaksi.

Step:

```text
1. Stabilkan melalui napas.
2. Kesadaran tubuh.
3. Sadari suara.
4. Sadari pikiran dan emosi.
5. Kesadaran terbuka.
6. Kembali dan tutup sesi.
```

Cocok untuk:

- overwhelmed;
- pikiran ramai;
- emosi bercampur;
- latihan non-reactivity.

### 14.14 Mindfulness of Sounds

Fungsi: memakai suara sebagai anchor perhatian.

Step:

```text
1. Persiapan.
2. Suara dekat.
3. Suara jauh.
4. Suara muncul, berubah, dan menghilang.
5. Kembali ke napas.
```

Cocok untuk:

- grounding;
- sulit fokus pada napas;
- latihan ringan;
- pikiran bergerak terus.

### 14.15 RAIN

Fungsi: membantu pengguna menghadapi emosi berat dengan self-compassion.

Step:

```text
1. Recognize: kenali emosi.
2. Allow: izinkan emosi hadir.
3. Investigate: rasakan di tubuh.
4. Nurture: beri kalimat baik untuk diri.
5. Pilih langkah kecil yang aman.
```

Cocok untuk:

- sedih;
- marah;
- frustrasi;
- keras pada diri sendiri.

### 14.16 Loving-Kindness Meditation

Fungsi: melatih niat baik untuk diri sendiri dan orang lain.

Step:

```text
1. Stabilkan diri.
2. Kebaikan kepada diri.
3. Orang yang dipercaya.
4. Perluas kebaikan.
5. Penutup.
```

Cocok untuk:

- konflik;
- rendah pencapaian diri;
- sedih;
- butuh self-compassion.

### 14.17 Mountain Meditation

Fungsi: memakai visualisasi gunung untuk melatih kestabilan saat kondisi berubah.

Step:

```text
1. Persiapan dan napas.
2. Visualisasi gunung.
3. Perubahan cuaca.
4. Pikiran dan emosi berubah.
5. Kestabilan tubuh.
6. Penutup.
```

Cocok untuk:

- tekanan tinggi;
- emosi naik turun;
- perubahan besar;
- latihan acceptance.

### 14.18 Informal Mindfulness

Fungsi: membawa mindfulness ke aktivitas sehari-hari.

Sub-teknik:

| Sub-teknik | Step |
|---|---|
| Mindful Drinking | Pegang gelas, perhatikan warna/aroma, minum perlahan, sadari sensasi |
| Mindful Eating | Perhatikan makanan, satu suapan, kunyah perlahan, sadari rasa/tekstur, sadari tubuh |
| Mindful Walking to Class | Sadari langkah, sadari napas, sadari lingkungan |

Cocok untuk:

- waktu terbatas;
- rutinitas harian;
- prevention;
- maintenance.

### 14.19 Jurnal Reflektif Harian

Fungsi: membaca pengalaman harian melalui tulisan.

Step:

```text
1. Fakta hari ini.
2. Perasaan dominan.
3. Pola terlihat.
4. Lepaskan hal kecil.
5. Rencana besok.
```

Cocok untuk:

- refleksi;
- membaca pola;
- menutup hari;
- setelah check-out.

---

## 15. Parent Monitoring

Parent melihat data anak yang sudah terhubung.

Flow:

```text
Siswa melihat kode parent di profil
  -> parent memasukkan kode dan sekolah anak
  -> sistem validasi
  -> parent terhubung
  -> parent melihat activity, mood, analisis, dan rekomendasi anak
```

Data yang dilihat:

- daftar anak;
- activity anak per tanggal;
- mood check-in;
- mood check-out;
- analisis burnout;
- rekomendasi pendampingan;
- guru terkait jika activity berasal dari kelas.

Batasan:

- parent tidak membuat activity;
- parent tidak mengedit jurnal;
- parent tidak melihat anak lain;
- parent hanya melihat ringkasan relevan.

---

## 16. Observasi Siswa Oleh Guru

Observasi siswa berasal dari activity kelas.

Flow:

```text
Guru membuat activity mengajar
  -> siswa join activity
  -> guru check-in
  -> siswa check-in
  -> guru check-out
  -> siswa check-out dan isi jurnal
  -> guru membuka observasi siswa
```

Data observasi:

- nama siswa;
- status activity;
- waktu check-in;
- mood check-in;
- alasan check-in;
- waktu check-out;
- mood check-out;
- jurnal siswa;
- ringkasan analisis activity;
- rekomendasi untuk siswa.

---

## 17. Reminder dan Notifikasi

Notifikasi menggunakan local notification di aplikasi Flutter.

Jenis:

| Reminder | Waktu |
|---|---|
| Reminder harian | Sesuai preferensi pengguna |
| Reminder check-in | 10 menit sebelum activity dimulai |
| Reminder check-out | Saat jam selesai activity |

Catatan:

- bukan push notification server;
- jadwal hilang jika aplikasi dihapus;
- permission notifikasi harus aktif;
- battery optimization Android dapat memengaruhi notifikasi.

---

## 18. Data Utama Sistem

| Tabel | Fungsi |
|---|---|
| schools | Data sekolah |
| users | Akun semua role |
| classes | Data kelas |
| class_teacher | Relasi guru dan kelas |
| activities | Activity, check-in, check-out, jurnal |
| activity_events | Ledger perubahan activity |
| burnout_analysis_snapshots | History hasil analisis |
| burnout_self_reports | Self report guru |
| mindful_tactics | Daftar teknik mindfulness |
| tactic_bookmarks | Bookmark teknik |
| mindfulness_sessions | Riwayat latihan |
| parent_student_links | Relasi parent dan siswa |
| user_login_histories | Riwayat login |
| badges | Badge |
| user_badges | Badge user |
| student_observations | Observasi siswa |

---

## 19. API Utama

Endpoint publik:

```text
GET  /api/public/schools
GET  /api/public/schools/{school}/classes
POST /api/register
POST /api/register/google
POST /api/login
POST /api/auth/google
```

Endpoint user login:

```text
GET  /api/me
PUT  /api/me/profile
POST /api/me/avatar
PUT  /api/me/password
POST /api/logout
```

Endpoint activity:

```text
GET  /api/activities
POST /api/activities
GET  /api/activities/{activity}
PUT  /api/activities/{activity}
POST /api/activities/{activity}/check-in
POST /api/activities/{activity}/check-out
POST /api/activities/{activity}/cancel
POST /api/activities/{activity}/duplicate
GET  /api/activities/{activity}/ledger
```

Endpoint classroom:

```text
GET  /api/classroom/activities/available
POST /api/classroom/activities/{activity}/join
GET  /api/teacher/classroom-activities/{activity}/observations
```

Endpoint analisis dan toolkit:

```text
GET  /api/burnout-analyses
GET  /api/burnout-analyses/overview
POST /api/burnout-analyses
POST /api/burnout-self-reports
GET  /api/toolkit/tactics
GET  /api/toolkit/tactics/bookmarked
POST /api/toolkit/tactics/{tactic}/bookmark
```

Endpoint parent:

```text
GET  /api/parent/dashboard
POST /api/parent/children
```

---

## 20. Ringkasan Akhir

MindfulEdu menjalankan siklus:

```text
Daftar sekolah
  -> approval sekolah
  -> pengelolaan admin dan kelas
  -> register guru/siswa/parent
  -> approval guru/siswa
  -> activity tracking
  -> check-in mood
  -> check-out jurnal
  -> review activity
  -> analisis burnout
  -> rekomendasi mindfulness
  -> guided practice
  -> evaluasi latihan
  -> observasi siswa
  -> parent monitoring
  -> admin monitoring
```

Dengan siklus ini, sistem membantu sekolah, guru, siswa, dan parent memahami aktivitas harian serta kondisi pengguna secara lebih rapi, reflektif, dan terarah.
