# Manual Video Guru MindfulEdu

Dokumen ini adalah panduan video khusus role Guru.

---

## 1. Tujuan Role

Guru memakai MindfulEdu untuk mencatat aktivitas mengajar dan aktivitas pribadi, melakukan check-in/check-out mood, menulis jurnal refleksi, melihat analisis burnout, menjalankan latihan mindfulness, dan memantau observasi siswa pada activity kelas.

---

## 2. Alur Video Singkat

```text
Pilih role Guru
  -> register
  -> menunggu approval admin sekolah
  -> login setelah approved
  -> lengkapi profil
  -> buat activity pribadi
  -> buat activity mengajar
  -> check-in
  -> check-out dan isi jurnal
  -> lihat analisis
  -> buka rekomendasi mindfulness
  -> lihat observasi siswa
```

---

## 3. Register Guru

Yang ditampilkan:

- pilih role Guru;
- daftar dengan email atau Google;
- isi data akun;
- pilih sekolah approved;
- submit;
- pesan menunggu approval.

Naskah:

```text
Guru melakukan pendaftaran dari aplikasi mobile. Setelah memilih sekolah, akun guru belum langsung aktif. Akun akan masuk ke daftar pending dan perlu disetujui oleh admin sekolah terkait atau super admin.
```

Checklist:

```text
[ ] Role Guru dipilih
[ ] Form register tampil
[ ] Sekolah approved bisa dipilih
[ ] Register berhasil
[ ] Pesan pending approval tampil
```

---

## 4. Login Guru

Yang ditampilkan:

- login email/password atau Google;
- dashboard guru.

Naskah:

```text
Setelah akun guru disetujui, guru dapat login. Jika akun masih pending, aplikasi akan menolak login dan menampilkan pesan menunggu approval.
```

Fungsi dashboard guru:

- ringkasan activity hari ini;
- activity yang belum check-in;
- activity yang sedang berjalan;
- activity selesai;
- analisis terbaru;
- rekomendasi mindfulness;
- shortcut ke activity, analisis, toolkit, dan profil.

---

## 5. Membuat Activity Guru

### 5.1 Activity Pribadi

Alur:

```text
Buka menu Aktivitas
  -> tambah activity
  -> isi judul
  -> pilih tanggal
  -> isi jam mulai dan selesai
  -> pilih jenis activity
  -> simpan
```

Jenis activity guru:

| Jenis | Fungsi |
|---|---|
| Mengajar | Activity kelas yang dapat dijoin siswa |
| Rapat | Mencatat kegiatan rapat |
| Administrasi | Mencatat pekerjaan administrasi |
| Koreksi | Mencatat koreksi tugas/ujian |
| Persiapan materi | Mencatat persiapan mengajar |
| Istirahat | Mencatat jeda pemulihan |
| Lainnya | Activity bebas |

### 5.2 Activity Mengajar

Alur:

```text
Tambah activity
  -> pilih jenis Mengajar
  -> pilih target kelas jika diperlukan
  -> simpan
  -> activity tersedia untuk siswa yang sesuai
```

Aturan:

- jika target kelas diisi, hanya siswa kelas itu yang dapat join;
- jika target kelas kosong, semua siswa satu sekolah dapat melihat activity;
- siswa dari sekolah lain tidak dapat melihat activity tersebut.

---

## 6. Check-In Guru

Tujuan check-in:

- mencatat kondisi sebelum activity;
- menyimpan mood awal;
- menjadi tanda activity dimulai.

Alur:

```text
Buka activity
  -> tekan Check-in
  -> pilih mood
  -> isi intensitas
  -> isi alasan jika perlu
  -> submit
```

Mood:

| Mood | Keterangan |
|---|---|
| Senang | Kondisi positif |
| Tenang | Kondisi stabil |
| Cemas | Kondisi negatif |
| Sedih | Kondisi negatif |
| Marah | Kondisi negatif |

Catatan:

- pada activity kelas, siswa baru bisa check-in setelah guru check-in;
- check-in masuk ke riwayat activity.

---

## 7. Check-Out dan Jurnal Guru

Tujuan check-out:

- menutup activity;
- menghitung actual hours;
- mencatat mood akhir;
- menyimpan jurnal refleksi;
- memicu review dan rekomendasi.

Alur:

```text
Buka activity checked-in
  -> tekan Check-out
  -> pilih mood akhir
  -> isi fakta kejadian
  -> isi perasaan
  -> isi pola yang disadari
  -> isi rencana
  -> pilih tag burnout jika terasa
  -> submit
```

Field jurnal:

| Field | Fungsi |
|---|---|
| Fakta | Apa yang terjadi selama activity |
| Perasaan | Bagaimana perasaan setelah activity |
| Pola | Pola yang mulai terlihat |
| Rencana | Langkah kecil berikutnya |
| Tag burnout | Penanda burnout manual khusus guru |

Tag burnout guru:

- kelelahan emosional;
- depersonalisasi;
- rendah pencapaian diri.

---

## 8. Analisis Guru

Alur:

```text
Buka menu Analisis
  -> pilih Harian, Mingguan, atau Bulanan
  -> tekan Analisis
  -> lihat kategori
  -> lihat skor
  -> lihat activity breakdown
  -> lihat journal reviews
  -> buka rekomendasi mindfulness
```

Periode:

| Periode | Rentang | Kapasitas |
|---|---|---:|
| Harian | Tanggal dipilih | 8 jam |
| Mingguan | 7 hari terakhir | 56 jam |
| Bulanan | 30 hari terakhir | 240 jam |

Yang ditampilkan:

- kategori hijau/kuning/merah;
- final burnout risk score;
- workload score;
- wellbeing score;
- jumlah activity;
- jumlah jurnal;
- dominant factors;
- rekomendasi utama periode;
- review per activity.

---

## 9. Toolkit Mindfulness Guru

Alur:

```text
Buka Toolkit
  -> pilih teknik
  -> baca detail teknik
  -> tekan Mulai
  -> ikuti step-by-step
  -> dengarkan TTS
  -> isi evaluasi setelah latihan
```

Fungsi:

- membantu pemulihan setelah aktivitas padat;
- memberi latihan singkat sesuai rekomendasi;
- menyimpan riwayat sesi latihan.

---

## 10. Observasi Siswa

Alur:

```text
Guru membuat activity Mengajar
  -> siswa join
  -> guru check-in
  -> siswa check-in
  -> guru check-out
  -> siswa check-out dan isi jurnal
  -> guru buka Observasi Siswa
```

Data yang dilihat guru:

- nama siswa;
- status activity siswa;
- mood check-in siswa;
- alasan check-in;
- mood check-out siswa;
- jurnal siswa;
- analisis siswa;
- rekomendasi siswa.

Batasan:

- guru hanya melihat siswa yang join activity kelas miliknya;
- guru tidak melihat activity pribadi siswa yang tidak terkait kelas;
- guru sekolah lain tidak bisa melihat data tersebut.

---

## 11. Checklist Akhir Video Guru

```text
[ ] Register guru berhasil
[ ] Pesan pending approval tampil
[ ] Guru approved bisa login
[ ] Dashboard guru tampil
[ ] Activity pribadi bisa dibuat
[ ] Activity Mengajar bisa dibuat
[ ] Target kelas bisa dipilih
[ ] Check-in berhasil
[ ] Check-out dan jurnal berhasil
[ ] Analisis tampil
[ ] Rekomendasi mindfulness bisa dibuka
[ ] Guided practice berjalan
[ ] Observasi siswa tampil
```

