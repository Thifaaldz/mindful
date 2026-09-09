# Perkenalan Aplikasi MindfulEdu

Dokumen ini dipakai sebagai bahan pembuka video, presentasi, atau dokumentasi umum MindfulEdu. Isinya menjelaskan tujuan aplikasi, pengguna sistem, fitur utama, dan gambaran alur dari awal sampai akhir.

---

## 1. Apa Itu MindfulEdu

MindfulEdu adalah aplikasi pendamping sekolah untuk mencatat aktivitas harian, mood, jurnal refleksi, analisis burnout, dan rekomendasi latihan mindfulness.

Aplikasi ini membantu:

- guru memahami beban aktivitas dan kondisi emosional setelah mengajar atau menjalankan tugas sekolah;
- siswa memahami kondisi belajar, mood, dan aktivitas harian;
- orang tua memantau aktivitas dan kondisi anak secara terbatas;
- admin sekolah mengelola data pengguna di sekolahnya;
- super admin mengelola ekosistem sekolah di seluruh sistem.

MindfulEdu bukan alat diagnosis medis. Analisis burnout yang ditampilkan adalah indikator pendukung refleksi dan pemantauan, bukan pengganti bantuan profesional.

---

## 2. Tujuan Sistem

Tujuan utama MindfulEdu:

| Tujuan | Penjelasan |
|---|---|
| Monitoring aktivitas | Mencatat aktivitas guru dan siswa berdasarkan jadwal dan realisasi |
| Monitoring mood | Mencatat mood sebelum dan setelah aktivitas |
| Refleksi harian | Membantu pengguna menulis pengalaman, perasaan, pola, dan rencana |
| Analisis burnout | Mengolah aktivitas, mood, jurnal, dan self report menjadi skor risiko |
| Rekomendasi mindfulness | Memberikan teknik latihan yang sesuai dengan kondisi pengguna |
| Observasi siswa | Membantu guru melihat kondisi siswa pada activity kelas |
| Parent monitoring | Membantu orang tua memantau anak yang sudah terhubung |
| Administrasi sekolah | Mengatur sekolah, kelas, guru, siswa, dan parent berdasarkan scope akses |

---

## 3. Pengguna Sistem

MindfulEdu memiliki lima role utama.

| Role | Fungsi Ringkas |
|---|---|
| Super Admin | Mengelola semua sekolah dan seluruh data sistem |
| Admin Sekolah | Mengelola data sekolahnya sendiri |
| Guru | Membuat activity, check-in, check-out, analisis, toolkit, dan observasi siswa |
| Siswa | Membuat/join activity, check-in, check-out, analisis, toolkit, dan kode parent |
| Parent | Menghubungkan anak dan memantau aktivitas serta analisis anak |

Setiap role memiliki hak akses yang berbeda. Data sekolah tidak dicampur antar sekolah.

---

## 4. Komponen Sistem

| Komponen | Fungsi |
|---|---|
| Website publik | Landing page, pendaftaran sekolah, dan download APK |
| Aplikasi Flutter | Aplikasi utama untuk guru, siswa, dan parent |
| Laravel API | Autentikasi, activity, jurnal, analisis, parent, classroom, dan admin |
| Filament Admin Panel | Dashboard super admin dan admin sekolah |
| Python/FastAPI | Service pendukung analisis jurnal dan burnout |
| MariaDB | Database utama |
| Local Notification | Reminder harian, check-in, dan check-out di perangkat |

Target production:

```text
Website      : https://mindfulapps.pkmueu.online
API Mobile   : https://mindfulapps.pkmueu.online/api
Download APK : https://mindfulapps.pkmueu.online/download/android
Admin Panel  : https://mindfulapps.pkmueu.online/admin
```

---

## 5. Alur Besar Sistem

Alur sistem dari awal:

```text
Sekolah daftar dari website
  -> super admin review pendaftaran
  -> sekolah approved
  -> super admin membuat admin sekolah
  -> admin sekolah membuat kelas
  -> guru dan siswa register dari aplikasi
  -> guru/siswa menunggu approval
  -> admin sekolah approve guru/siswa
  -> guru/siswa login
  -> guru membuat activity kelas atau pribadi
  -> siswa membuat activity pribadi atau join activity kelas
  -> pengguna check-in
  -> pengguna check-out dan isi jurnal
  -> sistem membuat review dan analisis
  -> sistem memberi rekomendasi mindfulness
  -> pengguna menjalankan guided practice
  -> parent memantau anak jika sudah terhubung
```

---

## 6. Fitur Utama

### 6.1 Pendaftaran Sekolah

Sekolah mendaftar melalui website publik. Form pendaftaran memakai pilihan wilayah bertingkat:

```text
Provinsi -> Kota/Kabupaten -> Kecamatan
```

Setelah submit, sekolah berstatus pending sampai disetujui super admin.

### 6.2 Approval Akun

Guru dan siswa yang register belum langsung bisa login. Akun mereka harus disetujui oleh admin sekolah terkait atau super admin.

Aturan:

- guru/siswa pending tidak bisa login;
- approval guru/siswa hanya terlihat pada sekolah yang sesuai;
- super admin dapat melihat semua pendaftaran;
- approval tidak mengirim email otomatis.

### 6.3 Activity Tracking

Activity digunakan untuk mencatat kegiatan guru dan siswa.

Activity memiliki:

- judul;
- tanggal;
- jam mulai;
- jam selesai;
- jenis activity;
- status;
- planned hours;
- actual hours;
- mood check-in;
- mood check-out;
- jurnal;
- rekomendasi mindfulness.

### 6.4 Check-In

Check-in mencatat kondisi sebelum activity.

Data yang dicatat:

- mood awal;
- intensitas mood;
- alasan/pemicu.

### 6.5 Check-Out dan Jurnal

Check-out mencatat kondisi setelah activity.

Data yang dicatat:

- mood akhir;
- fakta kejadian;
- perasaan;
- pola yang disadari;
- rencana ke depan;
- tag burnout khusus guru.

### 6.6 Analisis Burnout

Analisis menggabungkan workload dan wellbeing.

Periode saat ini:

| Periode | Rentang | Kapasitas |
|---|---|---:|
| Harian | Tanggal dipilih | 8 jam |
| Mingguan | 7 hari terakhir | 56 jam |
| Bulanan | 30 hari terakhir | 240 jam |

Formula ringkas:

```text
Workload Score = min(100, total(actual_hours x intensity_factor) / kapasitas_periode x 100)
Final Score = min(100, 50% workload + 50% wellbeing)
```

Kategori:

| Kategori | Rentang |
|---|---:|
| Hijau | 0 - 39.99 |
| Kuning | 40 - 69.99 |
| Merah | 70 - 100 |

### 6.7 Toolkit Mindfulness

Toolkit berisi teknik mindfulness yang bisa dijalankan step-by-step. Beberapa teknik memiliki avatar animasi dan TTS.

Contoh teknik:

- Mindful Breathing;
- Body Scan Meditation;
- Sitting Meditation;
- Mindful Movement;
- Walking Meditation;
- Teknik STOP;
- Grounding 3-2-1;
- Napas 4-7-8;
- RAIN;
- Jurnal Reflektif Harian.

### 6.8 Observasi Siswa

Guru dapat melihat observasi siswa pada activity kelas yang dibuat oleh guru tersebut.

Data yang terlihat:

- siswa yang join;
- status activity;
- mood check-in;
- mood check-out;
- jurnal;
- ringkasan analisis;
- rekomendasi.

### 6.9 Parent Monitoring

Parent dapat memantau anak setelah memasukkan kode verifikasi siswa dan sekolah yang sesuai.

Parent dapat melihat:

- daftar anak;
- activity anak;
- mood anak;
- analisis burnout anak;
- rekomendasi pendampingan.

Parent tidak dapat mengubah activity atau jurnal anak.

---

## 7. Naskah Opening Video

```text
MindfulEdu adalah aplikasi pendamping sekolah untuk membantu guru, siswa, dan orang tua memahami aktivitas harian, mood, jurnal refleksi, serta kondisi burnout. Sistem ini dimulai dari pendaftaran sekolah, approval akun, pencatatan activity, check-in, check-out, analisis, hingga rekomendasi latihan mindfulness.

Di dalam aplikasi ini, guru dan siswa dapat mencatat aktivitas dan kondisi dirinya. Orang tua dapat memantau anak secara terbatas. Admin sekolah mengelola data sekolahnya sendiri, sedangkan super admin mengelola seluruh sistem.

Analisis di MindfulEdu bukan diagnosis medis, tetapi alat bantu refleksi agar pengguna lebih sadar terhadap pola aktivitas dan kebutuhan pemulihan.
```

---

## 8. Checklist Video Perkenalan

```text
[ ] Tampilkan landing page
[ ] Jelaskan tujuan MindfulEdu
[ ] Jelaskan role pengguna
[ ] Tampilkan flow besar sistem
[ ] Tampilkan cuplikan aplikasi mobile
[ ] Tampilkan admin panel
[ ] Jelaskan activity, check-in, check-out, jurnal
[ ] Jelaskan analisis burnout
[ ] Jelaskan rekomendasi mindfulness
[ ] Jelaskan parent monitoring
[ ] Tutup dengan manfaat sistem
```

