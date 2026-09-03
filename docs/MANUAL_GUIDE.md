# Manual Guide MindfulEdu

Dokumen ini menjelaskan penggunaan sistem MindfulEdu berdasarkan fitur yang tersedia saat ini di aplikasi mobile, backend Laravel, service analisis Python/FastAPI, dan dashboard web/admin.

MindfulEdu adalah sistem monitoring aktivitas, check-in/check-out mood, jurnal refleksi, analisis burnout, dan rekomendasi latihan mindfulness untuk guru, siswa, dan orang tua.

---

## 1. Ringkasan Sistem

MindfulEdu memiliki empat bagian utama:

1. Aplikasi mobile Flutter
   - Digunakan oleh guru, siswa, dan orang tua.
   - Menyediakan login, registrasi, aktivitas, check-in, check-out, analisis, toolkit mindfulness, reminder, dan profil.

2. Backend Laravel
   - Menjadi pusat pengelolaan data utama.
   - Menangani autentikasi, role access, data pengguna, aktivitas, jurnal, analisis, parent monitoring, classroom activity, dan admin panel.

3. Service Python/FastAPI
   - Digunakan untuk fungsi analisis burnout dan rekomendasi berbasis AI.
   - Laravel tetap menjadi pusat data; Python hanya menjadi engine pendukung analisis.

4. Website
   - Landing page untuk memperkenalkan aplikasi.
   - Halaman download APK Android.
   - Dashboard admin berbasis Filament untuk monitoring data sistem.

---

## 2. Peran Pengguna

Sistem memiliki tiga role utama:

| Role | Fungsi Utama | Tema |
|---|---|---|
| Guru | Membuat aktivitas, check-in/check-out, melihat observasi siswa, melihat analisis burnout, memakai toolkit | Hijau |
| Siswa | Membuat aktivitas pribadi, join aktivitas kelas dari guru, check-in/check-out, melihat analisis burnout, memakai toolkit | Biru |
| Orang Tua | Menghubungkan akun anak, memantau aktivitas anak, melihat hasil check-in/check-out dan analisis anak | Cokelat/oranye lembut |

Setiap role dipisahkan dari awal login. Akun guru tidak bisa masuk melalui pintu siswa, akun siswa tidak bisa masuk melalui pintu guru, dan akun orang tua tidak bisa masuk melalui role lain.

---

## 3. Alur Awal Aplikasi

### 3.1 Memilih Jenis Akun

Saat membuka aplikasi, pengguna memilih salah satu akses:

- Guru
- Siswa
- Orang Tua

Pilihan ini menentukan:

- halaman login;
- halaman register;
- warna tema;
- menu navigasi;
- hak akses API;
- data yang boleh dilihat.

### 3.2 Login

Pengguna bisa login dengan:

- email dan password;
- Google Sign-In;
- quick login dengan PIN atau biometrik jika sebelumnya sudah mengaktifkan fitur simpan akun.

Form login email:

| Field | Keterangan |
|---|---|
| Email | Email akun yang terdaftar |
| Password | Password akun |
| Role | Diambil dari pilihan akses awal |
| Device info | Dikirim otomatis dari aplikasi untuk riwayat login |

### 3.3 Register

Pengguna bisa register dengan:

- email dan password;
- Google Sign-In.

Form register email:

| Field | Guru | Siswa | Orang Tua |
|---|---:|---:|---:|
| Nama | Opsional di awal, bisa dilengkapi nanti | Opsional di awal, bisa dilengkapi nanti | Opsional di awal, bisa dilengkapi nanti |
| Email | Wajib | Wajib | Wajib |
| Password | Wajib | Wajib | Wajib |
| Konfirmasi password | Wajib | Wajib | Wajib |
| Sekolah | Bisa dilengkapi di profil | Bisa dilengkapi di profil | Wajib untuk menghubungkan anak |
| Kelas | Tidak wajib | Bisa dilengkapi di profil | Tidak digunakan |
| Kode anak | Tidak digunakan | Dibuat otomatis oleh sistem | Wajib jika ingin langsung menghubungkan anak |

Catatan:

- Siswa memiliki kode verifikasi khusus untuk orang tua.
- Orang tua menggunakan kode verifikasi siswa dan nama sekolah untuk menghubungkan akun anak.
- Sekolah harus sama agar relasi siswa, guru, dan orang tua valid.

### 3.4 Simpan Akun

Pada login/register tersedia pilihan untuk menyimpan akun.

Jika aktif:

- login berikutnya bisa memakai PIN atau biometrik;
- token disimpan aman di perangkat;
- akun yang tersimpan tetap mengikuti role yang benar.

---

## 4. Keamanan Login

Sistem memakai mekanisme single active session.

Artinya:

- jika akun login di perangkat baru, token lama akan dicabut;
- perangkat lama akan otomatis keluar saat mencoba mengakses server;
- aplikasi menampilkan pesan bahwa sesi akun dipindahkan ke perangkat lain.

Setiap login dicatat pada history login dengan data:

| Data | Keterangan |
|---|---|
| Role | Role saat login |
| Device ID | Identitas perangkat dari aplikasi |
| Device name | Nama perangkat |
| Brand | Merek perangkat |
| Model | Model perangkat |
| Platform | Android/iOS |
| IP address | IP saat login |
| Lokasi | Saat ini default Jakarta |
| Waktu login | Tanggal dan jam login |
| Revoked previous sessions | Penanda apakah sesi lama dicabut |

Riwayat login ditampilkan di profil/pengaturan pengguna.

---

## 5. Menu Aplikasi

### 5.1 Menu Guru

Guru memiliki menu:

| Menu | Fungsi |
|---|---|
| Beranda | Ringkasan aktivitas, status, dan shortcut |
| Aktivitas | Membuat dan mengelola aktivitas |
| Analisis | Melihat analisis burnout harian, mingguan, bulanan |
| Toolkit | Melihat dan menjalankan latihan mindfulness |
| Profil | Edit profil, avatar, reminder, login history, logout |

### 5.2 Menu Siswa

Siswa memiliki menu:

| Menu | Fungsi |
|---|---|
| Beranda | Ringkasan aktivitas siswa |
| Aktivitas | Membuat aktivitas pribadi dan join kelas dari guru |
| Analisis | Melihat analisis burnout siswa |
| Toolkit | Melihat dan menjalankan latihan mindfulness |
| Profil | Edit profil, avatar, sekolah, kelas, kode parent, reminder, logout |

### 5.3 Menu Orang Tua

Orang tua memiliki menu:

| Menu | Fungsi |
|---|---|
| Anak | Monitoring aktivitas dan kondisi anak |
| Profil | Edit profil, hubungkan anak, login history, logout |

---

## 6. Profil Pengguna

Profil digunakan untuk melengkapi data akun.

### 6.1 Data Profil Umum

| Field | Keterangan |
|---|---|
| Nama | Nama pengguna |
| Email | Email akun |
| Sekolah | Nama sekolah |
| Avatar | Foto profil pengguna |
| Role | Guru, siswa, atau orang tua |

### 6.2 Profil Guru

Guru dapat mengisi:

- nama;
- sekolah;
- avatar.

Sekolah guru dipakai untuk membatasi aktivitas kelas agar hanya terlihat oleh siswa dalam sekolah yang sama.

### 6.3 Profil Siswa

Siswa dapat mengisi:

- nama;
- sekolah;
- kelas;
- avatar.

Siswa juga memiliki kode parent/kode verifikasi yang bisa disalin dari halaman profil. Kode ini diberikan kepada orang tua agar akun orang tua bisa terhubung dengan siswa.

### 6.4 Profil Orang Tua

Orang tua dapat:

- mengisi nama;
- mengisi sekolah anak;
- memasukkan kode verifikasi siswa;
- menghubungkan akun anak;
- melihat daftar anak yang sudah terhubung.

---

## 7. Aktivitas

Aktivitas adalah pusat pencatatan kegiatan pengguna. Setiap aktivitas bisa memiliki jadwal, check-in, check-out, jurnal, status, analisis, dan rekomendasi teknik mindfulness.

### 7.1 Status Aktivitas

| Status | Arti |
|---|---|
| Planned | Aktivitas dibuat, belum check-in |
| Checked in | Pengguna sudah melakukan check-in |
| Completed | Pengguna sudah melakukan check-out |
| Cancelled | Aktivitas dibatalkan |

### 7.2 Form Tambah/Edit Aktivitas

Form aktivitas saat ini berisi:

| Field | Keterangan |
|---|---|
| Nama kegiatan | Judul aktivitas |
| Tanggal mulai | Tanggal aktivitas |
| Pengulangan | Sekali, mingguan, atau bulanan |
| Ulang sampai | Tanggal akhir pengulangan jika mingguan/bulanan |
| Jam mulai | Opsional |
| Jam selesai | Opsional |
| Jenis aktivitas | Pilihan sesuai role |
| Jenis aktivitas lainnya | Muncul jika memilih Lainnya |
| Target kelas | Khusus guru jika jenis aktivitas adalah Mengajar |

### 7.3 Pengulangan Aktivitas

Saat membuat aktivitas baru, pengguna bisa memilih:

- Sekali
- Mingguan
- Bulanan

Jika memilih mingguan atau bulanan:

- sistem membuat beberapa aktivitas otomatis sampai tanggal yang dipilih;
- maksimal dibuat dalam batas aman agar tidak terlalu banyak data;
- sistem menghindari duplikasi aktivitas yang sama.

### 7.4 Jenis Aktivitas Guru

Pilihan jenis aktivitas guru:

| Kode | Label |
|---|---|
| teaching | Mengajar |
| meeting | Rapat |
| administration | Administrasi |
| grading | Koreksi |
| preparation | Persiapan materi |
| break | Istirahat |
| other | Lainnya |

Jika guru memilih Mengajar, sistem menyediakan field target kelas.

### 7.5 Target Kelas Guru

Pada aktivitas Mengajar:

- jika target kelas dikosongkan, aktivitas terbuka untuk semua siswa di sekolah yang sama;
- jika target kelas diisi, hanya siswa dengan kelas yang cocok yang bisa join;
- siswa dari sekolah berbeda tidak bisa melihat/join aktivitas tersebut.

### 7.6 Jenis Aktivitas Siswa

Pilihan jenis aktivitas siswa:

| Kode | Label |
|---|---|
| class_learning | Belajar di kelas |
| group_study | Belajar bersama |
| assignment | Tugas/PR |
| exam | Ujian/Ulangan |
| extracurricular | Ekstrakurikuler |
| break | Istirahat |
| other | Lainnya |

Siswa juga dapat membuat aktivitas pribadi di luar aktivitas kelas dari guru.

### 7.7 Activity Card

Card aktivitas menampilkan:

- nama aktivitas;
- tanggal dan jam;
- status;
- planned hours;
- actual hours jika sudah selesai;
- mood terdeteksi jika sudah check-out;
- sumber review, lokal atau berbasis AI;
- tombol check-in;
- tombol check-out;
- tombol review AI;
- tombol observasi siswa untuk guru pada aktivitas kelas;
- rekomendasi teknik mindfulness jika tersedia.

---

## 8. Check-In

Check-in digunakan untuk mencatat kondisi sebelum aktivitas.

### 8.1 Form Check-In

| Field | Wajib | Keterangan |
|---|---:|---|
| Mood | Opsional | Senang, tenang, cemas, sedih, marah |
| Intensitas | Wajib jika mood dipilih | Skala 1 sampai 10 |
| Kenapa | Opsional | Pemicu atau alasan kondisi pengguna |

Mood yang tersedia:

| Kode | Label |
|---|---|
| senang | Senang |
| tenang | Tenang |
| cemas | Cemas |
| sedih | Sedih |
| marah | Marah |

Setelah check-in:

- status aktivitas berubah menjadi Checked in;
- waktu check-in tersimpan;
- data masuk ke ledger aktivitas;
- siswa baru bisa check-in pada aktivitas kelas jika guru sudah check-in lebih dulu.

### 8.2 Aturan Check-In Siswa Pada Aktivitas Kelas

Untuk aktivitas kelas dari guru:

- siswa harus join aktivitas terlebih dahulu;
- guru harus sudah check-in;
- jika guru belum check-in, siswa belum bisa check-in.

Tujuannya agar pencatatan siswa mengikuti sesi kelas yang benar-benar sudah dimulai oleh guru.

---

## 9. Check-Out dan Jurnal

Check-out digunakan untuk mencatat kondisi setelah aktivitas selesai.

### 9.1 Form Check-Out

| Field | Wajib | Keterangan |
|---|---:|---|
| Mood | Opsional | Senang, tenang, cemas, sedih, marah |
| Apa yang terjadi tadi? | Wajib minimal salah satu dengan perasaan | Fakta kejadian selama aktivitas |
| Bagaimana perasaanmu soal itu? | Wajib minimal salah satu dengan fakta | Refleksi perasaan setelah aktivitas |
| Pola yang kamu sadari | Opsional | Pola kondisi yang berulang |
| Rencana ke depan | Opsional | Rencana perbaikan atau tindak lanjut |
| Tandai jika terasa | Opsional, khusus guru | Dimensi burnout yang dirasakan |

Dimensi burnout manual yang tersedia untuk guru:

| Kode | Label |
|---|---|
| kelelahan_emosional | Kelelahan emosional |
| depersonalisasi | Depersonalisasi |
| rendah_pencapaian_diri | Rendah pencapaian diri |

Setelah check-out:

- status aktivitas berubah menjadi Completed;
- actual hours dihitung dari durasi aktivitas;
- jurnal disimpan;
- sistem menjalankan review jurnal;
- mood dan indikasi burnout bisa terdeteksi;
- rekomendasi teknik mindfulness dapat dibuat;
- data masuk ke analisis harian, mingguan, dan bulanan.

### 9.2 Aturan Check-Out Siswa Pada Aktivitas Kelas

Untuk aktivitas kelas dari guru:

- siswa hanya bisa check-out jika guru sudah check-out;
- jika guru belum check-out, siswa belum bisa check-out;
- hasil check-in/check-out siswa dapat dilihat guru melalui observasi siswa.

---

## 10. Join Kelas Untuk Siswa

Siswa dapat mencari aktivitas kelas dari guru melalui menu aktivitas.

Syarat aktivitas kelas muncul:

- aktivitas dibuat oleh guru;
- jenis aktivitas guru adalah Mengajar;
- sekolah guru sama dengan sekolah siswa;
- tanggal aktivitas sesuai;
- aktivitas belum dibatalkan;
- siswa belum join aktivitas tersebut;
- jika guru mengisi target kelas, kelas siswa harus sama;
- jika guru tidak mengisi target kelas, semua siswa di sekolah yang sama bisa join.

Setelah join:

- sistem membuat activity milik siswa yang terhubung ke activity guru;
- jam dan judul mengikuti activity guru;
- status siswa dimulai dari Planned;
- check-in/check-out siswa mengikuti aturan kesiapan guru.

---

## 11. Observasi Siswa Untuk Guru

Pada aktivitas kelas, guru dapat membuka observasi siswa.

Data yang ditampilkan:

- daftar siswa yang join;
- aktivitas siswa;
- status check-in siswa;
- status check-out siswa;
- mood check-in;
- mood check-out;
- mood terdeteksi oleh review;
- status analisis burnout siswa;
- rekomendasi atau catatan ringkas.

Fitur ini membantu guru melihat kondisi kelas tanpa harus membaca semua data secara manual satu per satu.

---

## 12. Parent Monitoring

Orang tua memiliki dashboard khusus untuk memantau anak.

### 12.1 Menghubungkan Anak

Orang tua perlu memasukkan:

| Field | Keterangan |
|---|---|
| Kode verifikasi siswa | Kode dari profil siswa |
| Sekolah anak | Harus sama dengan sekolah siswa |

Jika valid:

- relasi parent-student dibuat;
- orang tua dapat melihat aktivitas anak.

### 12.2 Dashboard Orang Tua

Dashboard orang tua menampilkan:

- daftar anak yang terhubung;
- filter tanggal;
- aktivitas anak pada tanggal tersebut;
- check-in mood anak;
- check-out mood anak;
- guru terkait jika aktivitas berasal dari kelas;
- analisis kondisi anak;
- rekomendasi pendampingan berbasis AI jika tersedia.

Orang tua tidak memiliki menu untuk membuat aktivitas atau mengubah jurnal anak.

---

## 13. Analisis Burnout

Analisis burnout tersedia untuk guru dan siswa. Orang tua dapat melihat hasil analisis anak dari dashboard parent.

### 13.1 Jenis Analisis

| Periode | Keterangan |
|---|---|
| Harian | Menghitung aktivitas dan jurnal dalam satu hari |
| Mingguan | Menghitung aktivitas dan jurnal dalam rentang minggu |
| Bulanan | Menghitung aktivitas dan jurnal dalam rentang bulan |

### 13.2 Data Yang Dihitung

Analisis memakai data:

- jumlah aktivitas;
- jumlah aktivitas selesai;
- planned hours;
- actual hours;
- variance beban aktivitas;
- mood check-in;
- mood check-out;
- isi jurnal check-out;
- pola yang disadari pengguna;
- rencana pengguna;
- tag burnout manual;
- tag burnout otomatis;
- self report jika tersedia;
- review per aktivitas;
- rekomendasi teknik mindfulness.

### 13.3 Tampilan Analisis

Screen analisis menampilkan:

- pilihan periode harian/mingguan/bulanan;
- tanggal atau rentang periode;
- tombol jalankan analisis manual;
- status akhir;
- skor risiko;
- jumlah activity dihitung;
- jumlah activity selesai;
- jumlah jurnal dihitung;
- grafik garis perkembangan;
- ringkasan hasil aktivitas pada periode tersebut;
- detail analisis per activity;
- rekomendasi teknik per activity;
- tombol untuk membuka teknik mindfulness;
- history analisis.

### 13.4 Alur Analisis

Alur umum:

```text
Aktivitas selesai
      ↓
Check-out dan jurnal
      ↓
Review jurnal per activity
      ↓
Analisis periode harian/mingguan/bulanan
      ↓
Kesimpulan periode
      ↓
Rekomendasi teknik mindfulness
      ↓
Snapshot disimpan sebagai history
```

### 13.5 Cache dan History Analisis

Jika data dalam periode yang sama belum berubah:

- sistem tidak perlu menjalankan analisis AI ulang;
- hasil lama dipakai kembali dari snapshot/history;
- ini menghemat token dan membuat aplikasi lebih cepat.

Jika ada aktivitas atau jurnal baru:

- signature data berubah;
- analisis baru bisa dibuat;
- snapshot baru tersimpan.

### 13.6 Status Analisis

Status yang digunakan:

| Status | Makna Umum |
|---|---|
| Low/Rendah | Kondisi relatif stabil |
| Moderate/Sedang | Ada sinyal perlu pemulihan |
| High/Tinggi | Ada sinyal risiko lebih kuat dan perlu perhatian |

Catatan penting:

- MindfulEdu bukan alat diagnosis medis.
- Hasil analisis adalah dukungan refleksi dan rekomendasi awal.
- Jika kondisi berat atau menetap, pengguna tetap disarankan mencari bantuan profesional.

---

## 14. Review AI Pada Activity

Setiap activity yang sudah check-out bisa memiliki review berbasis AI atau fallback lokal.

Review activity dapat berisi:

- ringkasan jurnal;
- mood terdeteksi;
- dimensi burnout yang mungkin muncul;
- saran singkat;
- rekomendasi teknik mindfulness;
- alasan kenapa teknik tersebut cocok;
- peringatan jika ada sinyal krisis.

Di UI, review tidak langsung dibuka panjang pada card. Pengguna menekan tombol Review AI untuk melihat detail agar layar aktivitas tetap ringkas.

---

## 15. Rekomendasi Teknik Mindfulness

Rekomendasi teknik berasal dari analisis kondisi pengguna.

Prioritas rekomendasi:

1. AI memilih teknik yang paling cocok berdasarkan jurnal dan daftar teknik dalam sistem.
2. Jika AI tidak tersedia, sistem memakai mapping lokal sebagai fallback.
3. Rekomendasi disimpan di history analisis agar tidak dihitung ulang terus-menerus.

Setiap rekomendasi dapat menampilkan:

- nama teknik;
- durasi yang disarankan;
- alasan teknik cocok;
- kondisi/activity yang menjadi dasar rekomendasi;
- tombol Buka Teknik Ini.

---

## 16. Toolkit Mindfulness

Toolkit berisi teknik mindfulness yang dapat dipelajari dan dijalankan.

### 16.1 Alur Toolkit

```text
Buka Toolkit
      ↓
Pilih teknik
      ↓
Baca knowledge/penjelasan teknik
      ↓
Tekan Mulai
      ↓
Latihan berjalan per langkah
      ↓
TTS membacakan instruksi
      ↓
Timer pindah ke step berikutnya
      ↓
Evaluasi setelah latihan
```

### 16.2 Teknik Yang Tersedia

| No | Teknik |
|---:|---|
| 1 | Mindful Breathing |
| 2 | Focused Attention Meditation |
| 3 | Body Scan Meditation |
| 4 | Sitting Meditation |
| 5 | Mindful Movement / Hatha Yoga |
| 6 | Walking Meditation |
| 7 | Open Monitoring / Choiceless Awareness |
| 8 | Mindfulness of Sounds |
| 9 | Loving-Kindness Meditation |
| 10 | Mountain Meditation |
| 11 | Informal Mindfulness |

### 16.3 Isi Data Teknik

Setiap teknik memiliki:

- title;
- category;
- description;
- knowledge;
- duration_minutes;
- steps;
- cues;
- best_for;
- bookmark status.

### 16.4 Guided Practice

Saat latihan dimulai:

- user melihat step satu per satu;
- timer berjalan sesuai durasi step;
- TTS membacakan instruksi;
- setelah waktu step selesai, aplikasi lanjut ke step berikutnya;
- pengguna bisa jeda, lanjut, atau selesai;
- setelah selesai, pengguna mengisi evaluasi kondisi.

### 16.5 Evaluasi Setelah Latihan

Pilihan evaluasi:

- Jauh lebih baik
- Lebih baik
- Tidak berubah
- Masih lelah
- Lebih buruk

Setelah memilih evaluasi, sesi ditutup dan pengguna kembali ke tampilan sebelumnya.

---

## 17. Reminder dan Notifikasi

Notifikasi saat ini memakai local notification di Flutter, bukan push notification server.

Library yang digunakan:

| Library | Fungsi |
|---|---|
| flutter_local_notifications | Menampilkan dan menjadwalkan notifikasi lokal |
| timezone | Mengatur jadwal notifikasi berbasis zona waktu |
| flutter_timezone | Mengambil timezone perangkat |

### 17.1 Jenis Notifikasi

| Notifikasi | Waktu |
|---|---|
| Reminder harian | Sesuai jam yang dipilih pengguna |
| Reminder check-in aktivitas | 10 menit sebelum jam mulai aktivitas |
| Reminder check-out aktivitas | Tepat pada jam selesai aktivitas |

### 17.2 Pengaturan Reminder

Pengguna dapat mengatur:

- aktif/nonaktif reminder;
- jam reminder harian;
- channel push/email;
- timezone.

Catatan:

- Channel push dijalankan sebagai local notification di perangkat.
- Channel email saat ini disimpan sebagai preferensi, tetapi pengiriman email membutuhkan worker/backend tambahan jika ingin diaktifkan penuh.
- Android perlu izin notifikasi agar reminder tampil.

---

## 18. Dashboard Web

Website menyediakan:

- landing page MindfulEdu;
- deskripsi aplikasi;
- call to action download aplikasi;
- link download APK Android.

Endpoint download:

```text
GET /download/android
```

File APK dibaca dari:

```text
public/downloads/mindfuledu.apk
```

Jika file tidak ada, server akan mengembalikan 404.

---

## 19. Admin Panel

Admin panel berbasis Filament digunakan untuk monitoring dan pengelolaan data.

Fitur admin yang tersedia/terkait:

- monitoring user;
- role dan permission;
- kelas/sekolah;
- activity;
- activity event/ledger;
- burnout analysis snapshot;
- mindful tactics;
- mindfulness sessions;
- student observation;
- badge;
- login history;
- data pendukung sistem.

Admin panel digunakan oleh pengelola sistem, bukan oleh guru/siswa/orang tua biasa.

---

## 20. Struktur Data Utama

Bagian ini adalah ringkasan tabel penting yang dipakai sistem.

### 20.1 users

Menyimpan data akun.

Kolom utama:

- id;
- avatar_url;
- name;
- email;
- school;
- class_id;
- student_verification_code;
- google_id;
- google_avatar_url;
- password;
- reminder_enabled;
- reminder_time;
- reminder_channel;
- reminder_timezone;
- timestamps.

Relasi:

- user memiliki role melalui tabel role Spatie;
- siswa dapat terhubung ke class;
- siswa dapat terhubung ke parent melalui parent_student_links;
- user memiliki banyak activities;
- user memiliki banyak burnout_analysis_snapshots;
- user memiliki banyak user_login_histories.

### 20.2 classes

Menyimpan data kelas.

Kolom utama:

- id;
- name;
- grade;
- school;
- timestamps.

Relasi:

- satu class dapat dimiliki banyak siswa;
- satu class dapat dipakai sebagai target aktivitas mengajar guru;
- class dapat dikaitkan ke guru melalui class_teacher.

### 20.3 class_teacher

Pivot relasi guru dan kelas.

Kolom utama:

- id;
- class_id;
- teacher_id;
- timestamps.

### 20.4 activities

Menyimpan aktivitas guru dan siswa.

Kolom utama:

- id;
- user_id;
- title;
- category;
- activity_kind;
- activity_type;
- school_class_id;
- teacher_activity_id;
- joined_at;
- activity_date;
- start_at;
- end_at;
- planned_hours;
- actual_hours;
- intensity_factor;
- intensity_factor_version;
- status;
- checkin_at;
- checkin_mood;
- checkin_intensity;
- checkin_trigger;
- checkout_at;
- checkout_mood;
- checkout_fact;
- checkout_feeling;
- checkout_pattern;
- checkout_plan;
- checkout_burnout_tags;
- checkout_auto_burnout_tags;
- checkout_analysis_source;
- checkout_analysis_raw_response;
- checkout_mood_detected;
- checkout_suggestion;
- checkout_crisis_flag;
- timestamps.

Jenis activity_type:

| Type | Keterangan |
|---|---|
| personal | Aktivitas pribadi |
| classroom | Aktivitas kelas yang dibuat guru |
| classroom_student | Aktivitas siswa hasil join dari aktivitas guru |

### 20.5 activity_events

Menyimpan ledger aktivitas.

Kolom utama:

- id;
- activity_id;
- event_type;
- occurred_at;
- metadata;
- timestamps.

Contoh event:

- created;
- updated;
- checked_in;
- checked_out;
- cancelled;
- duplicated;
- joined.

### 20.6 burnout_analysis_snapshots

Menyimpan history hasil analisis.

Kolom utama:

- id;
- user_id;
- source;
- period_type;
- period_start;
- period_end;
- data_sufficiency;
- activity_count;
- completed_activity_count;
- weighted_planned_hours;
- weighted_actual_hours;
- workload_score_raw;
- workload_variance_pct;
- journal_score;
- final_burnout_risk_score;
- category;
- dominant_factors;
- recommendation_codes;
- recommendation_summary;
- model_version;
- scoring_version;
- threshold_version;
- payload;
- timestamps.

Fungsi:

- menyimpan hasil analisis harian/mingguan/bulanan;
- menjadi history;
- mencegah analisis AI berulang jika data belum berubah.

### 20.7 burnout_self_reports

Menyimpan self report kondisi pengguna.

Kolom utama:

- id;
- user_id;
- level;
- timestamps.

### 20.8 mindful_tactics

Menyimpan daftar teknik mindfulness.

Kolom utama:

- id;
- title;
- category;
- description;
- knowledge;
- duration_minutes;
- steps;
- cues;
- best_for;
- sort_order;
- timestamps.

### 20.9 tactic_bookmarks

Menyimpan bookmark teknik mindfulness user.

Kolom utama:

- id;
- user_id;
- mindful_tactic_id;
- timestamps.

### 20.10 mindfulness_sessions

Menyimpan riwayat sesi latihan mindfulness.

Kolom utama:

- id;
- user_id;
- mindful_tactic_id;
- duration_minutes;
- burnout_status;
- reason;
- before_condition;
- after_condition;
- logbook fields;
- timestamps.

### 20.11 parent_student_links

Menyimpan hubungan orang tua dan siswa.

Kolom utama:

- id;
- parent_id;
- student_id;
- verified_at;
- timestamps.

### 20.12 user_login_histories

Menyimpan riwayat login pengguna.

Kolom utama:

- id;
- user_id;
- role;
- device_id;
- device_name;
- device_brand;
- device_model;
- device_platform;
- ip_address;
- location;
- logged_in_at;
- revoked_previous_sessions;
- timestamps.

### 20.13 Tabel Pendukung

Tabel pendukung sistem:

- personal_access_tokens;
- password_reset_tokens;
- sessions;
- cache;
- cache_locks;
- jobs;
- job_batches;
- failed_jobs;
- permissions;
- roles;
- model_has_roles;
- model_has_permissions;
- role_has_permissions;
- badges;
- user_badges;
- student_observations;
- questionnaire_responses;
- activity_log.

---

## 21. API Mobile

Base path API:

```text
/api
```

### 21.1 Auth

| Method | Endpoint | Auth | Fungsi |
|---|---|---:|---|
| POST | /register | Tidak | Register email |
| POST | /login | Tidak | Login email |
| POST | /auth/google | Tidak | Login/register Google |
| POST | /logout | Ya | Logout |
| GET | /me | Ya | Ambil profil user |
| PUT | /me/profile | Ya | Update profil user |
| POST | /me/avatar | Ya | Upload avatar |

### 21.2 Reminder

| Method | Endpoint | Auth | Fungsi |
|---|---|---:|---|
| GET | /reminder-preference | Ya | Ambil preferensi reminder |
| PUT | /reminder-preference | Ya | Update preferensi reminder |

### 21.3 Dashboard

| Method | Endpoint | Auth | Fungsi |
|---|---|---:|---|
| GET | /dashboard | Ya | Ambil ringkasan dashboard sesuai user |

### 21.4 Activities

| Method | Endpoint | Auth | Fungsi |
|---|---|---:|---|
| GET | /activities | Ya | List aktivitas |
| POST | /activities | Ya | Buat aktivitas |
| GET | /activities/{activity} | Ya | Detail aktivitas |
| PUT | /activities/{activity} | Ya | Update aktivitas |
| POST | /activities/{activity}/check-in | Ya | Check-in |
| POST | /activities/{activity}/check-out | Ya | Check-out dan jurnal |
| POST | /activities/{activity}/cancel | Ya | Batalkan aktivitas |
| POST | /activities/{activity}/duplicate | Ya | Duplikasi aktivitas |
| GET | /activities/{activity}/ledger | Ya | Lihat ledger aktivitas |

### 21.5 Classroom

| Method | Endpoint | Auth | Role | Fungsi |
|---|---|---:|---|---|
| GET | /classroom/activities/available | Ya | Siswa | Cari aktivitas kelas dari guru |
| POST | /classroom/activities/{activity}/join | Ya | Siswa | Join aktivitas kelas |
| GET | /teacher/classroom-activities/{activity}/observations | Ya | Guru | Lihat observasi siswa |

### 21.6 Burnout Analysis

| Method | Endpoint | Auth | Fungsi |
|---|---|---:|---|
| GET | /burnout-analyses | Ya | List history analisis |
| GET | /burnout-analyses/overview | Ya | Overview analisis |
| POST | /burnout-analyses | Ya | Jalankan analisis manual |
| POST | /burnout-self-reports | Ya | Simpan self report |

Catatan:

- Analisis dapat berjalan untuk daily, weekly, dan monthly.
- Hasil disimpan sebagai snapshot.
- Jika data belum berubah, hasil lama bisa dipakai kembali.

### 21.7 Toolkit

| Method | Endpoint | Auth | Fungsi |
|---|---|---:|---|
| GET | /toolkit/tactics | Ya | List teknik mindfulness |
| GET | /toolkit/tactics/bookmarked | Ya | List teknik yang dibookmark |
| POST | /toolkit/tactics/{tactic}/bookmark | Ya | Toggle bookmark teknik |

### 21.8 Parent

| Method | Endpoint | Auth | Role | Fungsi |
|---|---|---:|---|---|
| GET | /parent/dashboard | Ya | Orang tua | Dashboard monitoring anak |
| POST | /parent/children | Ya | Orang tua | Hubungkan anak |

---

## 22. Contoh Payload API

### 22.1 Register

```json
{
  "name": "Guru Demo",
  "email": "guru@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "teacher",
  "school": "SD Mindful",
  "device_id": "device-001",
  "device_name": "Android",
  "device_brand": "Samsung",
  "device_model": "SM-A525F",
  "device_platform": "android"
}
```

### 22.2 Login

```json
{
  "email": "guru@example.com",
  "password": "password123",
  "role": "teacher",
  "device_id": "device-001",
  "device_name": "Android",
  "device_brand": "Samsung",
  "device_model": "SM-A525F",
  "device_platform": "android"
}
```

### 22.3 Buat Aktivitas Guru Mengajar

```json
{
  "title": "Mengajar Matematika",
  "activity_date": "2026-09-04",
  "start_time": "08:00",
  "end_time": "09:30",
  "activity_kind": "teaching",
  "school_class_name": "5A",
  "repeat_type": "none"
}
```

Jika `school_class_name` dikosongkan, activity mengajar terbuka untuk semua siswa dalam sekolah yang sama.

### 22.4 Buat Aktivitas Siswa

```json
{
  "title": "Belajar kelompok IPA",
  "activity_date": "2026-09-04",
  "start_time": "13:00",
  "end_time": "14:00",
  "activity_kind": "group_study",
  "repeat_type": "none"
}
```

### 22.5 Check-In

```json
{
  "mood": "cemas",
  "intensity": 7,
  "trigger": "Akan presentasi di depan kelas"
}
```

### 22.6 Check-Out

```json
{
  "mood": "tenang",
  "fact": "Presentasi berjalan cukup lancar meski sempat gugup.",
  "feeling": "Saya lebih lega setelah selesai.",
  "pattern": "Saya biasanya tegang sebelum berbicara di depan kelas.",
  "plan": "Besok saya ingin latihan lebih awal.",
  "burnout_tags": ["kelelahan_emosional"]
}
```

### 22.7 Jalankan Analisis

```json
{
  "period_type": "daily",
  "date": "2026-09-04"
}
```

Nilai `period_type`:

- daily;
- weekly;
- monthly.

### 22.8 Hubungkan Anak Untuk Parent

```json
{
  "student_verification_code": "STU-ABC123",
  "school": "SD Mindful"
}
```

---

## 23. Konfigurasi Environment Penting

### 23.1 Laravel

Variabel penting:

```env
APP_NAME=MindfulEdu
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=mindfulledu
DB_USERNAME=mindfulledu
DB_PASSWORD=mindfulledu

SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1
SESSION_DRIVER=database
CACHE_STORE=database

MINDFULEDU_ML_URL=http://ml:8000
GOOGLE_CLIENT_ID=
```

### 23.2 Python/FastAPI AI Service

Variabel penting:

```env
AI_API_KEY=
AI_MODEL=
AI_TIMEOUT_SECONDS=20
```

Catatan keamanan:

- Jangan commit API key ke GitHub.
- Simpan API key di `.env`.
- Gunakan `.env.example` tanpa nilai rahasia.

### 23.3 Flutter Build Defines

Contoh menjalankan Flutter ke server lokal:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://192.168.111.21/api \
  --dart-define=API_FALLBACK_URLS=http://192.168.111.21/api
```

Contoh build APK release:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://mindfullapps.pkmueu.online/api \
  --dart-define=API_FALLBACK_URLS=https://mindfullapps.pkmueu.online/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=ISI_CLIENT_ID_WEB
```

---

## 24. Deployment Singkat

### 24.1 Update Backend di Server

```bash
cd ~/mindful
git pull origin main
docker compose build
docker compose up -d
docker compose exec php php artisan migrate --force
docker compose exec php php artisan optimize:clear
```

Jika memakai cache database, pastikan tabel cache sudah ada:

```bash
docker compose exec php php artisan migrate --force
```

### 24.2 Build APK Baru

Dari folder Flutter:

```bash
cd mindfuledu
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=API_BASE_URL=https://mindfullapps.pkmueu.online/api \
  --dart-define=API_FALLBACK_URLS=https://mindfullapps.pkmueu.online/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=ISI_CLIENT_ID_WEB
```

Output APK:

```text
mindfuledu/build/app/outputs/flutter-apk/app-release.apk
```

### 24.3 Upload APK ke Server

```bash
scp -i mindfullness.pem \
  mindfuledu/build/app/outputs/flutter-apk/app-release.apk \
  ubuntu@16.78.35.91:/home/ubuntu/mindfuledu.apk
```

Di server:

```bash
sudo mkdir -p ~/mindful/public/downloads
sudo mv /home/ubuntu/mindfuledu.apk ~/mindful/public/downloads/mindfuledu.apk
sudo chmod 644 ~/mindful/public/downloads/mindfuledu.apk
docker compose restart nginx
```

Download tersedia di:

```text
https://mindfullapps.pkmueu.online/download/android
```

---

## 25. Troubleshooting

### 25.1 Aplikasi Tidak Terhubung Server

Cek hal berikut:

1. API base URL benar.
2. HP dan laptop berada di Wi-Fi yang sama jika memakai IP lokal.
3. Backend Docker sedang berjalan.
4. Port 80 atau 443 terbuka.
5. Jika memakai HTTPS lokal dengan IP, Android bisa menolak certificate. Gunakan HTTP untuk local LAN.
6. Coba akses dari browser HP:

```text
http://IP_LAPTOP/api/dashboard
```

Jika respons minimal masuk ke server atau muncul unauthorized, koneksi sudah sampai.

### 25.2 Google Login Error ApiException 10

Biasanya disebabkan oleh:

- Android OAuth client belum dibuat;
- package name salah;
- SHA-1 debug/release salah;
- Web client ID tidak dikirim sebagai server client ID;
- konfigurasi Google Auth belum propagate.

Pastikan:

- Android client memakai package name dari `AndroidManifest.xml`;
- SHA-1 sesuai keystore yang dipakai;
- Web client ID dipakai di `GOOGLE_SERVER_CLIENT_ID`;
- backend memiliki `GOOGLE_CLIENT_ID` yang sesuai.

### 25.3 Notifikasi Tidak Muncul

Cek:

- izin notifikasi aktif di Android;
- battery optimization tidak mematikan aplikasi;
- jam device benar;
- timezone terbaca benar;
- reminder sudah tersimpan;
- activity memiliki jam mulai/jam selesai;
- untuk check-in, notifikasi muncul 10 menit sebelum jam mulai;
- untuk check-out, notifikasi muncul tepat di jam selesai.

### 25.4 Activity Setelah Edit Tampak Tidak Update

Kemungkinan:

- cache list belum refresh;
- request update gagal;
- activity lama masih berada di state lokal;
- filter tanggal berbeda;
- server belum mengembalikan payload terbaru.

Solusi pengguna:

- tunggu request selesai;
- jangan menutup sheet saat loading;
- tarik refresh jika jaringan lambat.

Solusi developer:

- pastikan optimistic update mengganti item berdasarkan id;
- pastikan gagal update mengembalikan previous activity;
- pastikan list refresh setelah save sukses.

### 25.5 Analisis Tidak Menghitung Semua Activity

Cek:

- activity berada pada tanggal/periode yang dipilih;
- activity sudah check-out agar memiliki jurnal;
- filter harian/mingguan/bulanan benar;
- snapshot lama tidak dipakai saat data sudah berubah;
- payload analysis memuat semua activities dalam periode.

### 25.6 Download APK 404

Pastikan file ada di:

```text
public/downloads/mindfuledu.apk
```

Lalu restart nginx/container web jika perlu.

---

## 26. Checklist QA

Gunakan checklist ini setiap selesai update.

### 26.1 Auth

- Register guru berhasil.
- Register siswa berhasil.
- Register orang tua berhasil.
- Login email berhasil.
- Login Google berhasil.
- Role mismatch ditolak.
- Quick login PIN/biometrik berhasil.
- Login perangkat kedua mencabut sesi perangkat pertama.
- Login history bertambah.

### 26.2 Profil

- Guru bisa update nama/sekolah/avatar.
- Siswa bisa update nama/sekolah/kelas/avatar.
- Siswa bisa salin kode parent.
- Orang tua bisa menghubungkan anak dengan kode dan sekolah yang benar.

### 26.3 Aktivitas

- Guru bisa membuat aktivitas biasa.
- Guru bisa membuat aktivitas mengajar tanpa target kelas.
- Guru bisa membuat aktivitas mengajar dengan target kelas.
- Siswa bisa membuat aktivitas pribadi.
- Siswa bisa melihat aktivitas kelas yang sesuai.
- Siswa tidak melihat aktivitas sekolah lain.
- Siswa tidak melihat aktivitas target kelas lain.
- Edit activity mengganti card lama, bukan membuat card ganda.
- Cancel activity menghilangkan/mengubah status sesuai filter.

### 26.4 Check-In/Check-Out

- Guru bisa check-in.
- Guru bisa check-out.
- Siswa tidak bisa check-in activity kelas sebelum guru check-in.
- Siswa bisa check-in setelah guru check-in.
- Siswa tidak bisa check-out sebelum guru check-out.
- Siswa bisa check-out setelah guru check-out.
- Review jurnal muncul setelah check-out.

### 26.5 Analisis

- Analisis harian menghitung semua activity dalam hari tersebut.
- Analisis mingguan menghitung semua activity dalam minggu tersebut.
- Analisis bulanan menghitung semua activity dalam bulan tersebut.
- Detail per activity muncul.
- Kesimpulan periode muncul di atas.
- Rekomendasi teknik per activity tidak double.
- Tombol Buka Teknik Ini mengarah ke toolkit/practice.
- History analisis bertambah jika data berubah.
- History lama dipakai jika data tidak berubah.

### 26.6 Toolkit

- Semua teknik tampil.
- Knowledge tampil sebelum mulai.
- Latihan berjalan step-by-step.
- TTS membacakan step.
- Timer lanjut ke step berikutnya.
- Tombol Jeda/Lanjut bekerja.
- Tombol Selesai membuka evaluasi.
- Setelah evaluasi, user kembali ke halaman sebelumnya.

### 26.7 Reminder

- Reminder harian muncul sesuai jam.
- Check-in reminder muncul 10 menit sebelum aktivitas.
- Check-out reminder muncul pada jam selesai aktivitas.
- Pending notification count bertambah setelah schedule.
- Permission notification tertangani.

### 26.8 Website

- Landing page tampil.
- Tombol download menuju `/download/android`.
- APK bisa diunduh.
- APK yang diunduh adalah versi terbaru.

---

## 27. Catatan Pengembangan

Prinsip sistem saat ini:

- Laravel tetap menjadi pusat data dan logic utama.
- Python/FastAPI hanya digunakan untuk analisis dan rekomendasi.
- AI digunakan sebagai pendukung review dan rekomendasi, bukan pengganti keputusan profesional.
- Hasil analisis disimpan sebagai snapshot agar hemat token.
- Rekomendasi teknik mindfulness harus merujuk ke teknik yang tersedia di sistem.
- UI pengguna tidak perlu menampilkan rumus teknis internal.
- Role access harus tetap ketat agar data guru, siswa, dan orang tua tidak tercampur.

---

## 28. Ringkasan Alur Lengkap

```text
Pilih role
  ↓
Login/Register
  ↓
Lengkapi profil
  ↓
Buat atau join aktivitas
  ↓
Check-in sebelum aktivitas
  ↓
Jalankan aktivitas
  ↓
Check-out dan isi jurnal
  ↓
Review activity
  ↓
Analisis harian/mingguan/bulanan
  ↓
Rekomendasi teknik mindfulness
  ↓
Latihan guided step-by-step
  ↓
Evaluasi setelah latihan
  ↓
History tersimpan
```

MindfulEdu digunakan untuk membantu pengguna mengenali pola aktivitas, kondisi emosi, dan kebutuhan pemulihan melalui jurnal reflektif, analisis burnout, dan latihan mindfulness yang sesuai.
