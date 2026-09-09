# Manual Video Siswa MindfulEdu

Dokumen ini adalah panduan video khusus role Siswa.

---

## 1. Tujuan Role

Siswa memakai MindfulEdu untuk mencatat aktivitas belajar, join activity kelas dari guru, melakukan check-in/check-out mood, menulis jurnal refleksi, melihat analisis burnout, memakai toolkit mindfulness, dan membagikan kode parent kepada orang tua.

---

## 2. Alur Video Singkat

```text
Pilih role Siswa
  -> register
  -> pilih sekolah dan kelas
  -> menunggu approval admin sekolah
  -> login setelah approved
  -> buat activity pribadi
  -> join activity kelas
  -> check-in
  -> check-out dan isi jurnal
  -> lihat analisis
  -> buka rekomendasi mindfulness
  -> lihat kode parent
```

---

## 3. Register Siswa

Yang ditampilkan:

- pilih role Siswa;
- daftar dengan email atau Google;
- isi data akun;
- pilih sekolah approved;
- pilih kelas;
- submit;
- pesan pending approval.

Naskah:

```text
Siswa mendaftar melalui aplikasi mobile. Siswa memilih sekolah dan kelas yang sesuai. Setelah pendaftaran, akun siswa akan menunggu approval dari admin sekolah terkait sebelum bisa login.
```

Checklist:

```text
[ ] Role Siswa dipilih
[ ] Form register tampil
[ ] Sekolah approved bisa dipilih
[ ] Kelas sekolah tampil
[ ] Register berhasil
[ ] Pesan pending approval tampil
```

---

## 4. Login dan Dashboard Siswa

Yang ditampilkan:

- login siswa;
- dashboard siswa.

Dashboard siswa menampilkan:

- activity pribadi;
- activity kelas yang sudah dijoin;
- status check-in/check-out;
- ringkasan mood;
- hasil analisis terbaru;
- rekomendasi mindfulness;
- shortcut ke activity, analisis, toolkit, dan profil.

Naskah:

```text
Setelah disetujui admin sekolah, siswa dapat login. Dashboard siswa menampilkan aktivitas dan kondisi terbaru agar siswa bisa memantau kegiatan hariannya.
```

---

## 5. Membuat Activity Pribadi

Alur:

```text
Buka menu Aktivitas
  -> tambah activity
  -> isi nama activity
  -> pilih tanggal
  -> isi jam mulai dan selesai
  -> pilih jenis activity
  -> simpan
```

Jenis activity siswa:

| Jenis | Fungsi |
|---|---|
| Belajar di kelas | Mencatat belajar di kelas |
| Belajar bersama | Mencatat study group |
| Tugas/PR | Mencatat tugas |
| Ujian/Ulangan | Mencatat ujian |
| Ekstrakurikuler | Mencatat kegiatan luar kelas |
| Istirahat | Mencatat jeda |
| Lainnya | Activity bebas |

---

## 6. Join Activity Kelas

Activity kelas dibuat oleh guru.

Alur:

```text
Guru membuat activity Mengajar
  -> siswa membuka activity kelas tersedia
  -> siswa memilih activity
  -> tekan Join
  -> activity masuk ke daftar siswa
```

Syarat activity kelas muncul:

- activity dibuat guru;
- jenis activity adalah Mengajar;
- sekolah guru sama dengan sekolah siswa;
- activity belum cancelled;
- siswa belum join;
- jika guru memilih target kelas, kelas siswa harus sama.

Naskah:

```text
Selain membuat activity pribadi, siswa juga bisa join activity kelas dari guru. Activity kelas hanya muncul jika sekolah dan kelas siswa sesuai dengan target guru.
```

---

## 7. Check-In Siswa

Alur activity pribadi:

```text
Buka activity
  -> tekan Check-in
  -> pilih mood
  -> isi intensitas
  -> submit
```

Alur activity kelas:

```text
Siswa join activity kelas
  -> menunggu guru check-in
  -> siswa check-in setelah guru mulai
```

Catatan:

- siswa tidak bisa check-in activity kelas sebelum guru check-in;
- mood dan intensitas membantu analisis kondisi siswa.

---

## 8. Check-Out dan Jurnal Siswa

Alur:

```text
Buka activity checked-in
  -> tekan Check-out
  -> pilih mood akhir
  -> isi fakta kejadian
  -> isi perasaan
  -> isi pola
  -> isi rencana
  -> submit
```

Aturan activity kelas:

- siswa tidak bisa check-out sebelum guru check-out;
- setelah guru check-out, siswa bisa check-out dan mengisi jurnal;
- hasil activity kelas dapat dilihat guru pada menu observasi.

Naskah:

```text
Setelah activity selesai, siswa mengisi check-out dan jurnal. Jurnal membantu sistem membaca kondisi siswa setelah aktivitas dan membuat rekomendasi mindfulness yang sesuai.
```

---

## 9. Analisis Siswa

Alur:

```text
Buka menu Analisis
  -> pilih periode
  -> tekan Analisis
  -> lihat kategori
  -> lihat skor
  -> lihat review activity
  -> buka rekomendasi mindfulness
```

Periode:

| Periode | Rentang | Kapasitas |
|---|---|---:|
| Harian | Tanggal dipilih | 8 jam |
| Mingguan | 7 hari terakhir | 56 jam |
| Bulanan | 30 hari terakhir | 240 jam |

Kategori:

| Kategori | Makna |
|---|---|
| Hijau | Kondisi relatif stabil |
| Kuning | Ada tanda perlu jeda/pemulihan |
| Merah | Beban atau tekanan tinggi dan perlu perhatian |

---

## 10. Toolkit Mindfulness Siswa

Alur:

```text
Buka Toolkit
  -> pilih teknik
  -> lihat detail
  -> mulai guided practice
  -> ikuti step
  -> isi evaluasi selesai latihan
```

Fungsi:

- membantu fokus sebelum belajar;
- membantu menenangkan diri setelah activity berat;
- membantu siswa mengenali pola emosi;
- mendukung kebiasaan refleksi.

---

## 11. Kode Parent

Alur:

```text
Buka Profil
  -> lihat kode verifikasi siswa
  -> salin kode
  -> berikan kode kepada parent
```

Fungsi kode parent:

- menghubungkan akun parent dengan siswa;
- memastikan parent hanya melihat anak yang valid;
- parent juga harus memasukkan sekolah yang sesuai.

---

## 12. Checklist Akhir Video Siswa

```text
[ ] Register siswa berhasil
[ ] Sekolah dan kelas bisa dipilih
[ ] Pesan pending approval tampil
[ ] Siswa approved bisa login
[ ] Dashboard siswa tampil
[ ] Activity pribadi bisa dibuat
[ ] Activity kelas tersedia tampil
[ ] Siswa bisa join activity kelas
[ ] Gate check-in mengikuti guru
[ ] Gate check-out mengikuti guru
[ ] Jurnal siswa tersimpan
[ ] Analisis siswa tampil
[ ] Rekomendasi mindfulness bisa dibuka
[ ] Kode parent tampil
```

