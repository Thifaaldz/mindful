# README Alur Flow Sistem MindfulEdu

Dokumen ini menjelaskan alur sistem MindfulEdu pada kondisi terbaru, dimulai dari pendaftaran sekolah sampai pengguna memakai fitur activity, check-in, check-out, jurnal, analisa burnout, rekomendasi mindfulness, parent monitoring, dan dashboard admin.

Dokumen ini bisa dipakai sebagai:

- panduan memahami sistem secara menyeluruh;
- bahan penjelasan untuk pengguna, admin sekolah, dan super admin;
- acuan presentasi atau dokumentasi skripsi;
- pegangan developer saat melanjutkan pengembangan.

---

## 1. Identitas Sistem

MindfulEdu adalah sistem monitoring aktivitas dan kondisi pengguna yang membantu guru, siswa, dan orang tua memahami pola aktivitas, emosi, beban harian, serta kebutuhan pemulihan melalui jurnal reflektif, analisa burnout, dan rekomendasi latihan mindfulness.

Target production saat ini:

```text
Website       : https://mindfulapps.pkmueu.online
API Mobile    : https://mindfulapps.pkmueu.online/api
Download APK  : https://mindfulapps.pkmueu.online/download/android
Server Path   : /home/ubuntu/mindful
Database      : mindfuledu
Container     : mindfuledu_nginx, mindfuledu_php, mindfuledu_db, mindfuledu_ml
```

Catatan:

- MindfulEdu bukan alat diagnosis medis.
- Analisa burnout digunakan sebagai pendukung refleksi.
- Rekomendasi mindfulness digunakan sebagai latihan pendamping, bukan pengganti bantuan profesional.

---

## 2. Komponen Sistem

Sistem terdiri dari beberapa komponen utama.

| Komponen | Fungsi |
|---|---|
| Website publik | Pendaftaran sekolah, landing page, dan download APK |
| Aplikasi Flutter | Aplikasi utama untuk guru, siswa, dan orang tua |
| Laravel API | Autentikasi, role access, activity, jurnal, analisa, parent monitoring, dan admin |
| Filament Admin Panel | Dashboard super admin dan admin sekolah |
| Python/FastAPI Service | Pendukung proses analisa dan rekomendasi |
| MariaDB | Database utama |
| Local Notification Flutter | Reminder harian, check-in, dan check-out di perangkat |

Alur teknis ringkas:

```text
Website / Flutter
  -> Laravel API
  -> MariaDB
  -> Service Analisa Python/FastAPI jika dibutuhkan
  -> Laravel menyimpan hasil
  -> Flutter / Admin Panel menampilkan hasil
```

---

## 3. Role Sistem

MindfulEdu memiliki beberapa role dengan fungsi berbeda.

| Role | Akses Utama |
|---|---|
| Super Admin | Mengelola semua sekolah, admin sekolah, guru, siswa, parent, activity, analisa, dan data sistem |
| Admin Sekolah | Mengelola data dalam sekolahnya sendiri |
| Guru | Membuat activity, check-in, check-out, melihat analisa diri, dan observasi siswa |
| Siswa | Membuat activity pribadi, join activity kelas, check-in, check-out, melihat analisa diri |
| Parent | Menghubungkan anak dan memantau activity, mood, analisa, serta rekomendasi pendampingan anak |

Prinsip pemisahan akses:

- data sekolah tidak boleh bercampur antar sekolah;
- guru hanya melihat data yang relevan dengan sekolah dan activity kelasnya;
- siswa hanya melihat activity dirinya dan activity kelas yang sesuai;
- parent hanya melihat anak yang sudah terhubung;
- admin sekolah hanya mengelola data sekolahnya sendiri;
- super admin dapat melihat semua data.

---

## 4. Flow Besar Dari Awal Sampai Akhir

Flow utama sistem:

```text
Sekolah mendaftar lewat website
  -> Super admin meninjau pendaftaran sekolah
  -> Sekolah disetujui
  -> Admin sekolah dibuat atau diaktifkan
  -> Admin sekolah login ke dashboard sekolah
  -> Admin sekolah membuat/mengelola kelas
  -> Guru dan siswa register dari aplikasi
  -> Guru dan siswa menunggu approval admin sekolah
  -> Admin sekolah approve akun guru/siswa
  -> Guru dan siswa login ke aplikasi
  -> Guru membuat activity kelas atau pribadi
  -> Siswa membuat activity pribadi atau join activity kelas
  -> Pengguna melakukan check-in
  -> Pengguna melakukan check-out dan mengisi jurnal
  -> Sistem membuat analisa dan rekomendasi
  -> Pengguna melihat hasil analisa
  -> Pengguna membuka toolkit mindfulness
  -> Pengguna menjalankan guided mindfulness
  -> Pengguna mengisi evaluasi latihan
  -> Parent memantau anak jika sudah terhubung
  -> Admin melihat data sesuai scope akses
```

---

## 5. Flow Pendaftaran Sekolah

Pendaftaran sekolah dilakukan dari website publik, bukan dari aplikasi mobile.

Alur:

```text
Pihak sekolah membuka website
  -> masuk ke form daftar sekolah
  -> mengisi data sekolah dan kontak penanggung jawab
  -> memilih provinsi, kota/kabupaten, lalu kecamatan secara bertingkat
  -> submit pendaftaran
  -> status sekolah menjadi pending
  -> super admin meninjau data
  -> super admin approve atau reject
```

Data pendaftaran sekolah:

| Field | Keterangan |
|---|---|
| Nama sekolah | Nama resmi sekolah |
| NPSN | Nomor pokok sekolah nasional jika ada |
| Jenjang pendidikan | Contoh SD, SMP, SMA |
| Status sekolah | Negeri atau swasta |
| Alamat | Alamat lengkap |
| Provinsi | Dipilih dari dropdown wilayah Indonesia |
| Kota/Kabupaten | Muncul otomatis sesuai provinsi yang dipilih |
| Kecamatan | Muncul otomatis sesuai kota/kabupaten yang dipilih |
| Nama kontak | Penanggung jawab pendaftaran |
| Jabatan kontak | Jabatan penanggung jawab |
| Email kontak | Email yang bisa dihubungi |
| Nomor telepon | Nomor kontak sekolah |

Status pendaftaran sekolah:

| Status | Arti |
|---|---|
| Pending | Sekolah baru mendaftar dan menunggu review |
| Approved | Sekolah diterima dan bisa dipakai untuk register pengguna |
| Rejected | Sekolah ditolak atau data belum valid |

Setelah sekolah approved:

- sekolah muncul pada pilihan sekolah di aplikasi;
- admin sekolah dapat dibuat atau diaktifkan;
- guru dan siswa dapat register memilih sekolah tersebut;
- kelas dapat dibuat untuk sekolah tersebut.

Catatan nested choice wilayah:

- pilihan kota/kabupaten terkunci sampai provinsi dipilih;
- pilihan kecamatan terkunci sampai kota/kabupaten dipilih;
- data wilayah diambil melalui endpoint Laravel agar form website tidak menyimpan data wilayah terlalu besar;
- nilai yang disimpan ke database tetap berupa nama provinsi, kota/kabupaten, dan kecamatan.

---

## 6. Flow Super Admin

Super admin adalah pengelola pusat sistem.

Alur kerja super admin:

```text
Super admin login ke dashboard
  -> membuka kategori sekolah
  -> meninjau pendaftaran sekolah
  -> approve sekolah valid
  -> membuat admin sekolah
  -> memantau data guru, siswa, parent, activity, dan analisa
```

Fungsi super admin:

| Modul | Fungsi |
|---|---|
| School Registrations | Meninjau pendaftaran sekolah yang masuk |
| Schools | Mengelola sekolah approved |
| School Admins | Membuat dan mengelola admin sekolah |
| Teacher Registrations | Melihat pendaftaran guru |
| Student Registrations | Melihat pendaftaran siswa |
| Teacher Data | Melihat dan mengelola data guru |
| Student Data | Melihat dan mengelola data siswa |
| Parent Management | Melihat data parent |
| Teacher Activities | Melihat activity guru |
| Student Activities | Melihat activity siswa |
| Teacher Burnout Analysis | Melihat analisa guru |
| Student Burnout Analysis | Melihat analisa siswa |
| Student Observations | Melihat observasi siswa |
| Mindful Tactics | Mengelola daftar teknik mindfulness |
| Mindfulness Sessions | Melihat sesi latihan pengguna |
| Badges | Mengelola badge |
| Login Histories | Melihat riwayat login |

Kategori dashboard super admin:

```text
Sekolah
  -> School Registrations
  -> Schools
  -> School Admins
  -> Classes

Guru
  -> Teacher Registrations
  -> Teacher Data
  -> Teacher Activities
  -> Teacher Burnout Analysis

Siswa
  -> Student Registrations
  -> Student Data
  -> Student Activities
  -> Student Burnout Analysis
  -> Student Observations

Parent
  -> Parent Management

Mindfulness
  -> Mindful Tactics
  -> Mindfulness Sessions
```

---

## 7. Flow Admin Sekolah

Admin sekolah hanya mengelola data sekolahnya sendiri.

Alur kerja:

```text
Admin sekolah login
  -> membuka dashboard sekolah
  -> melengkapi data sekolah jika perlu
  -> membuat kelas
  -> meninjau pendaftaran guru dan siswa
  -> approve atau reject akun
  -> mengelola password user jika user lupa password
  -> memantau activity, analisa, parent, dan observasi siswa
```

Fungsi admin sekolah:

| Modul | Fungsi |
|---|---|
| School Profile | Melihat/mengelola profil sekolah |
| Classes | Membuat kelas dalam sekolah |
| Teacher Registrations | Approve/reject guru sekolah tersebut |
| Student Registrations | Approve/reject siswa sekolah tersebut |
| Teacher Data | Mengelola data guru sekolah |
| Student Data | Mengelola data siswa sekolah |
| Parent Management | Melihat parent yang terhubung dengan siswa sekolah |
| Teacher Activities | Melihat activity guru sekolah |
| Student Activities | Melihat activity siswa sekolah |
| Teacher Burnout Analysis | Melihat analisa guru sekolah |
| Student Burnout Analysis | Melihat analisa siswa sekolah |
| Student Observations | Melihat observasi siswa pada activity kelas |
| Password Management | Mengubah password guru/siswa jika lupa |

Aturan penting:

- admin sekolah tidak melihat data sekolah lain;
- admin sekolah dapat membantu reset password user di sekolahnya;
- akun guru/siswa belum bisa login sebelum approved;
- admin sekolah dapat menata kelas agar activity mengajar bisa ditargetkan.

---

## 8. Flow Register Pengguna Di Aplikasi

Register guru, siswa, dan parent dilakukan dari aplikasi mobile.

### 8.1 Register Email

Alur register email:

```text
Pengguna membuka aplikasi
  -> memilih role
  -> memilih daftar dengan email
  -> mengisi nama, email, password, dan data role
  -> memilih sekolah jika role guru/siswa
  -> memilih kelas jika role siswa
  -> submit register
  -> sistem membuat akun
  -> jika guru/siswa, akun berstatus pending
  -> aplikasi menampilkan pesan menunggu approval admin sekolah
  -> pengguna kembali ke halaman login
```

Data umum:

| Field | Guru | Siswa | Parent |
|---|---:|---:|---:|
| Nama | Wajib/opsional sesuai form | Wajib/opsional sesuai form | Wajib/opsional sesuai form |
| Email | Wajib | Wajib | Wajib |
| Password | Wajib | Wajib | Wajib |
| Sekolah | Wajib | Wajib | Wajib untuk link anak |
| Kelas | Tidak wajib | Wajib/opsional sesuai sekolah | Tidak digunakan |
| Kode siswa | Tidak digunakan | Dibuat sistem | Dipakai parent untuk link anak |

Hasil register:

| Role | Status awal | Bisa langsung login? |
|---|---|---:|
| Guru | Pending approval | Tidak |
| Siswa | Pending approval | Tidak |
| Parent | Approved | Ya, jika data link anak valid |

### 8.2 Register Google

Register Google tetap meminta password agar pengguna juga bisa login memakai email dan password di perangkat lain.

Alur:

```text
Pengguna memilih role
  -> memilih daftar dengan Google
  -> memilih akun Google
  -> aplikasi mengambil data Google
  -> pengguna mengisi password akun MindfulEdu
  -> pengguna memilih sekolah
  -> siswa memilih kelas jika dibutuhkan
  -> submit register
  -> akun dibuat dengan google_id dan password
  -> jika guru/siswa, akun menunggu approval
  -> aplikasi kembali ke halaman login
```

Manfaat password pada register Google:

- pengguna tetap bisa login menggunakan Google setelah approved;
- pengguna juga bisa login manual dengan email Google dan password yang dibuat;
- jika pindah perangkat, pengguna tidak tergantung pada login Google saja.

### 8.3 Pesan Setelah Register

Untuk guru dan siswa:

```text
Terima kasih sudah daftar. Akun Anda menunggu approval admin sekolah.
Silakan login kembali setelah akun disetujui.
```

Untuk parent:

```text
Akun berhasil dibuat. Silakan login untuk memantau anak.
```

---

## 9. Flow Approval Akun Guru dan Siswa

Guru dan siswa tidak bisa masuk dashboard aplikasi sebelum approved.

Alur:

```text
Guru/siswa register
  -> status akun pending
  -> admin sekolah membuka Teacher/Student Registrations
  -> admin sekolah cek data akun
  -> admin approve atau reject
  -> jika approved, akun bisa login
  -> jika rejected, akun tidak bisa login
```

Saat user pending mencoba login:

```text
Akun Anda masih menunggu approval admin sekolah.
```

Approval dilakukan dari dashboard admin, bukan dari aplikasi mobile.

---

## 10. Flow Login

Login selalu berbasis role.

Alur login email:

```text
Pengguna memilih role
  -> memasukkan email dan password
  -> aplikasi mengirim request login
  -> Laravel mengecek email, password, role, dan approval
  -> jika valid, token dibuat
  -> token lama akun tersebut dicabut
  -> aplikasi masuk ke dashboard sesuai role
```

Alur login Google:

```text
Pengguna memilih role
  -> memilih login Google
  -> aplikasi mengambil id token Google
  -> Laravel mencari akun yang sudah terdaftar
  -> Laravel mengecek role dan approval
  -> jika valid, token dibuat
  -> aplikasi masuk dashboard
```

Aturan login:

- role login harus sama dengan role akun;
- guru tidak bisa login melalui pintu siswa;
- siswa tidak bisa login melalui pintu guru;
- parent tidak bisa login melalui pintu guru/siswa;
- akun pending tidak bisa login;
- satu akun hanya memiliki satu sesi aktif.

---

## 11. Keamanan Sesi dan Login History

Sistem memakai single active session.

Artinya:

- jika akun login di perangkat baru, token lama dicabut;
- perangkat lama akan keluar saat mengakses API lagi;
- login baru dicatat ke login history.

Data login history:

| Data | Keterangan |
|---|---|
| Role | Role saat login |
| Device ID | Identitas perangkat |
| Device name | Nama perangkat |
| Brand | Merek perangkat |
| Model | Model perangkat |
| Platform | Android/iOS |
| IP address | IP login |
| Lokasi | Default Jakarta |
| Waktu login | Waktu login |
| Revoked previous sessions | Apakah sesi lama dicabut |

---

## 12. Flow Dashboard Aplikasi

Dashboard aplikasi berbeda sesuai role.

### 12.1 Dashboard Guru

Guru melihat:

- ringkasan activity hari ini;
- activity yang belum check-in;
- activity yang sedang berjalan;
- activity yang selesai;
- hasil analisa terbaru;
- rekomendasi mindfulness;
- shortcut ke activity, analisa, toolkit, dan profil.

### 12.2 Dashboard Siswa

Siswa melihat:

- activity pribadi;
- activity kelas yang sudah dijoin;
- status check-in/check-out;
- ringkasan mood;
- hasil analisa terbaru;
- rekomendasi mindfulness;
- shortcut ke activity, analisa, toolkit, dan profil.

### 12.3 Dashboard Parent

Parent melihat:

- daftar anak yang terhubung;
- activity anak pada tanggal tertentu;
- mood check-in anak;
- mood check-out anak;
- hasil analisa burnout anak;
- rekomendasi pendampingan untuk anak.

---

## 13. Flow Activity Guru

Guru dapat membuat activity pribadi dan activity mengajar.

Alur activity guru:

```text
Guru login
  -> buka menu Activity
  -> tambah activity
  -> isi judul, tanggal, jam mulai, jam selesai, jenis activity
  -> jika Mengajar, pilih target kelas jika perlu
  -> simpan
  -> activity muncul di daftar guru
  -> jika activity classroom, siswa yang sesuai dapat melihat dan join
```

Jenis activity guru:

| Kode | Label |
|---|---|
| teaching | Mengajar |
| meeting | Rapat |
| administration | Administrasi |
| grading | Koreksi |
| preparation | Persiapan materi |
| break | Istirahat |
| other | Lainnya |

Activity mengajar:

- jika target kelas dipilih, hanya siswa kelas tersebut yang bisa join;
- jika target kelas kosong, semua siswa dalam sekolah yang sama bisa join;
- siswa dari sekolah lain tidak bisa melihat activity tersebut.

Status activity:

| Status | Arti |
|---|---|
| Planned | Activity dibuat, belum check-in |
| Checked in | Pengguna sudah check-in |
| Completed | Pengguna sudah check-out |
| Cancelled | Activity dibatalkan |

---

## 14. Flow Activity Siswa

Siswa memiliki dua sumber activity.

| Sumber | Keterangan |
|---|---|
| Activity pribadi | Dibuat sendiri oleh siswa |
| Activity kelas | Dibuat guru lalu dijoin oleh siswa |

Alur activity pribadi:

```text
Siswa login
  -> buka menu Activity
  -> tambah activity
  -> isi judul, tanggal, jam, dan jenis activity
  -> simpan
  -> activity muncul sebagai activity pribadi siswa
```

Jenis activity siswa:

| Kode | Label |
|---|---|
| class_learning | Belajar di kelas |
| group_study | Belajar bersama |
| assignment | Tugas/PR |
| exam | Ujian/Ulangan |
| extracurricular | Ekstrakurikuler |
| break | Istirahat |
| other | Lainnya |

---

## 15. Flow Join Activity Kelas

Siswa dapat join activity kelas yang dibuat guru.

Alur:

```text
Guru membuat activity Mengajar
  -> activity tersimpan sebagai classroom
  -> siswa membuka daftar activity kelas tersedia
  -> sistem filter berdasarkan sekolah dan kelas
  -> siswa memilih join
  -> sistem membuat activity siswa yang terhubung ke activity guru
  -> siswa dapat check-in setelah guru check-in
```

Syarat activity kelas muncul untuk siswa:

- activity dibuat oleh guru;
- jenis activity adalah Mengajar;
- activity belum cancelled;
- sekolah guru sama dengan sekolah siswa;
- jika guru memilih target kelas, kelas siswa harus sama;
- jika target kelas kosong, semua siswa satu sekolah bisa melihat;
- siswa belum join activity tersebut.

Activity siswa hasil join menyimpan `teacher_activity_id` agar hubungan guru-siswa tetap tercatat.

---

## 16. Flow Check-In

Check-in mencatat kondisi sebelum activity.

Alur:

```text
Pengguna membuka activity
  -> menekan Check-in
  -> memilih mood jika ingin
  -> mengisi intensitas jika mood dipilih
  -> menulis alasan/pemicu jika ada
  -> submit
  -> status activity berubah menjadi Checked in
```

Field check-in:

| Field | Keterangan |
|---|---|
| Mood | Senang, tenang, cemas, sedih, marah |
| Intensitas | Skala 1 sampai 10 jika mood dipilih |
| Alasan | Pemicu atau kondisi sebelum activity |

Aturan activity kelas:

- siswa tidak bisa check-in sebelum guru check-in;
- jika guru belum check-in, aplikasi menampilkan pesan bahwa activity belum dimulai oleh guru;
- setelah guru check-in, siswa yang sudah join dapat check-in.

---

## 17. Flow Check-Out dan Jurnal

Check-out mencatat kondisi setelah activity selesai.

Alur:

```text
Pengguna membuka activity yang sudah check-in
  -> menekan Check-out
  -> memilih mood setelah activity
  -> mengisi jurnal refleksi
  -> submit
  -> activity berubah menjadi Completed
  -> sistem menjalankan review jurnal
  -> hasil tersimpan untuk analisa dan rekomendasi
```

Field check-out:

| Field | Keterangan |
|---|---|
| Mood | Mood setelah activity |
| Apa yang terjadi tadi? | Fakta kejadian selama activity |
| Bagaimana perasaanmu soal itu? | Refleksi perasaan |
| Pola yang disadari | Pola kondisi yang muncul |
| Rencana ke depan | Rencana perbaikan |
| Tag burnout | Khusus guru, jika merasa ada dimensi burnout tertentu |

Minimal salah satu dari fakta atau perasaan harus diisi.

Aturan activity kelas:

- siswa tidak bisa check-out sebelum guru check-out;
- jika guru belum check-out, siswa diminta menunggu activity guru selesai;
- setelah guru check-out, siswa dapat check-out dan isi jurnal.

---

## 18. Review Activity

Setelah check-out, sistem membuat review activity.

Review dapat berisi:

- ringkasan jurnal;
- indikasi kondisi pengguna;
- dimensi burnout yang mungkin muncul;
- saran singkat;
- rekomendasi teknik mindfulness;
- alasan rekomendasi.

Di aplikasi, istilah yang ditampilkan ke pengguna diarahkan menjadi:

```text
Analisa
Rekomendasi
Review
Saran
```

Bukan nama provider atau istilah teknis mesin.

---

## 19. Flow Analisa Burnout

Analisa burnout dapat dilakukan harian, mingguan, dan bulanan.

Alur:

```text
Activity selesai
  -> jurnal tersimpan
  -> review activity tersimpan
  -> pengguna membuka menu Analisa
  -> memilih periode harian, mingguan, atau bulanan
  -> sistem menghitung data activity dan jurnal
  -> hasil analisa disimpan sebagai snapshot
  -> aplikasi menampilkan status, skor, faktor dominan, dan rekomendasi
```

Jenis periode:

| Periode | Fungsi |
|---|---|
| Harian | Melihat kondisi satu tanggal |
| Mingguan | Melihat pola satu minggu |
| Bulanan | Melihat kecenderungan satu bulan |

Data yang dianalisa:

- jumlah activity;
- activity selesai;
- planned hours;
- actual hours;
- selisih rencana dan realisasi;
- mood check-in;
- mood check-out;
- jurnal check-out;
- pola dan rencana pengguna;
- tag burnout manual;
- hasil review activity;
- rekomendasi mindfulness.

Status hasil analisa:

| Status | Makna |
|---|---|
| Rendah | Kondisi relatif stabil |
| Sedang | Ada tanda perlu pemulihan |
| Tinggi | Ada tanda beban tinggi dan perlu perhatian |

---

## 20. Snapshot dan Cache Analisa

Hasil analisa disimpan sebagai snapshot.

Tujuannya:

- menyimpan history analisa;
- mempercepat tampilan aplikasi;
- menghindari proses analisa berulang jika data belum berubah;
- menjaga hasil lama tetap dapat dilihat.

Alur snapshot:

```text
Sistem membaca activity dalam periode
  -> membuat signature data
  -> cek snapshot lama
  -> jika data sama, gunakan snapshot lama
  -> jika data berubah, buat analisa baru
  -> simpan snapshot baru
```

Snapshot digunakan untuk:

- history analisa pengguna;
- dashboard guru/siswa;
- dashboard parent untuk anak;
- admin panel.

---

## 21. Flow Rekomendasi Mindfulness

Rekomendasi mindfulness muncul dari hasil review activity dan analisa burnout.

Alur:

```text
Jurnal dan activity dianalisa
  -> sistem menentukan kondisi dominan
  -> sistem mencocokkan dengan teknik mindfulness
  -> rekomendasi muncul di activity atau halaman analisa
  -> pengguna dapat membuka teknik tersebut di Toolkit
```

Contoh mapping:

| Kondisi | Rekomendasi |
|---|---|
| Sulit fokus | Mindful Breathing atau Focused Attention |
| Lelah fisik | Body Scan |
| Pegal/kaku | Mindful Movement |
| Banyak pikiran | Sitting Meditation |
| Overwhelmed | Open Monitoring |
| Frustrasi | Loving-Kindness |
| Emosi tidak stabil | Mountain Meditation |
| Butuh grounding | Mindfulness of Sounds |
| Jenuh/duduk lama | Walking Meditation |

---

## 22. Flow Toolkit Mindfulness

Toolkit berisi teknik mindfulness yang bisa dibuka pengguna.

Teknik yang tersedia:

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

Alur toolkit:

```text
Pengguna membuka Toolkit
  -> memilih teknik
  -> membaca penjelasan
  -> menekan Mulai
  -> guided practice berjalan step-by-step
  -> instruksi dibacakan menggunakan TTS
  -> timer berpindah ke langkah berikutnya
  -> pengguna menyelesaikan latihan
  -> pengguna mengisi evaluasi setelah latihan
```

Setiap teknik memiliki:

- judul;
- kategori;
- deskripsi;
- knowledge;
- durasi;
- langkah latihan;
- cue/instruksi;
- kondisi yang cocok;
- bookmark.

Evaluasi setelah latihan:

| Pilihan | Arti |
|---|---|
| Jauh lebih baik | Kondisi membaik signifikan |
| Lebih baik | Kondisi membaik |
| Tidak berubah | Tidak ada perubahan terasa |
| Masih lelah | Masih butuh istirahat |
| Lebih buruk | Latihan tidak cocok atau perlu berhenti |

---

## 23. Flow Observasi Siswa Oleh Guru

Observasi siswa muncul dari activity kelas.

Alur:

```text
Guru membuat activity Mengajar
  -> siswa join activity
  -> guru check-in
  -> siswa check-in
  -> guru check-out
  -> siswa check-out dan isi jurnal
  -> guru membuka Observasi Siswa
  -> sistem menampilkan detail kondisi siswa pada activity tersebut
```

Data yang bisa dilihat guru:

- nama siswa;
- status activity siswa;
- waktu check-in siswa;
- mood check-in siswa;
- alasan mood check-in;
- waktu check-out siswa;
- mood check-out siswa;
- isi jurnal siswa;
- ringkasan analisa activity siswa;
- rekomendasi untuk siswa.

Tujuannya:

- guru mengetahui kondisi siswa setelah aktivitas kelas;
- guru tidak perlu membuka data mentah satu per satu;
- guru bisa melihat pola umum kelas;
- guru dapat memberi dukungan sesuai kebutuhan.

Batasan:

- guru hanya melihat siswa yang join activity kelas miliknya;
- guru tidak melihat activity pribadi siswa yang tidak terkait kelasnya;
- guru dari sekolah lain tidak dapat melihat observasi tersebut.

---

## 24. Flow Parent Monitoring

Parent memantau anak yang sudah terhubung.

Alur:

```text
Parent login
  -> membuka menu Anak
  -> memilih siswa yang terhubung
  -> memilih tanggal
  -> melihat daftar activity anak
  -> melihat mood check-in
  -> melihat mood check-out
  -> melihat analisa burnout
  -> melihat rekomendasi pendampingan
```

Cara menghubungkan anak:

```text
Siswa membuka profil
  -> menyalin kode verifikasi siswa
  -> memberikan kode ke parent
  -> parent memasukkan kode dan sekolah anak
  -> sistem validasi kode dan sekolah
  -> jika valid, parent terhubung dengan siswa
```

Data yang dilihat parent:

- daftar anak terhubung;
- activity anak per tanggal;
- guru terkait jika activity berasal dari kelas;
- mood check-in;
- mood check-out;
- hasil analisa anak;
- rekomendasi pendampingan.

Batasan parent:

- parent tidak membuat activity anak;
- parent tidak mengedit jurnal anak;
- parent tidak melihat siswa lain;
- parent hanya melihat anak yang sudah terhubung.

---

## 25. Flow Reminder dan Notifikasi

Notifikasi saat ini memakai local notification di aplikasi Flutter.

Library:

| Library | Fungsi |
|---|---|
| flutter_local_notifications | Menampilkan dan menjadwalkan notifikasi lokal |
| timezone | Menjadwalkan berdasarkan timezone |
| flutter_timezone | Mengambil timezone perangkat |

Jenis reminder:

| Jenis | Waktu |
|---|---|
| Reminder harian | Sesuai jam pilihan pengguna |
| Reminder check-in activity | 10 menit sebelum jam mulai |
| Reminder check-out activity | Tepat pada jam selesai |

Alur:

```text
Pengguna mengaktifkan reminder
  -> aplikasi meminta izin notifikasi
  -> aplikasi membaca timezone perangkat
  -> reminder dijadwalkan secara lokal
  -> notifikasi muncul sesuai jadwal
```

Catatan:

- notifikasi bukan push notification server;
- jika aplikasi dihapus, jadwal lokal hilang;
- jika permission notifikasi ditolak, reminder tidak tampil;
- battery optimization Android dapat memengaruhi notifikasi.

---

## 26. Flow Profil dan Password

Setiap pengguna dapat mengelola profil.

Data profil:

- nama;
- email;
- sekolah;
- kelas untuk siswa;
- avatar;
- kode parent untuk siswa;
- riwayat login;
- pengaturan reminder.

Flow update password di aplikasi:

```text
Pengguna login
  -> buka Profil
  -> buka Update Password
  -> isi password lama
  -> isi password baru
  -> konfirmasi password baru
  -> submit
  -> password akun berubah
```

Flow reset password oleh admin sekolah:

```text
User lupa password
  -> user menghubungi admin sekolah
  -> admin sekolah membuka data user
  -> admin mengganti password user
  -> user login memakai password baru
  -> user dapat mengganti password lagi dari aplikasi
```

Flow jika admin lupa password:

```text
Admin sekolah lupa password
  -> admin memakai fitur lupa password melalui email
  -> sistem mengirim email reset password
  -> admin membuat password baru
  -> admin login kembali
```

---

## 27. Flow Website Publik

Website publik memiliki beberapa fungsi.

| Halaman | Fungsi |
|---|---|
| Landing page | Mengenalkan MindfulEdu |
| Register School | Form pendaftaran sekolah |
| Download Android | Mengunduh APK terbaru |
| Admin Login | Masuk dashboard Filament |

Endpoint penting:

```text
GET  /
GET  /register-school
POST /register-school
GET  /download/android
GET  /admin
```

Download APK membaca file dari:

```text
src/public/downloads/mindfuledu.apk
```

Jika file tidak ada, endpoint download akan mengembalikan `404`.

---

## 28. API Utama Mobile

Base path:

```text
/api
```

Endpoint public:

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /public/schools | List sekolah approved |
| GET | /public/schools/{school}/classes | List kelas sekolah |

Endpoint auth:

| Method | Endpoint | Fungsi |
|---|---|---|
| POST | /register | Register email |
| POST | /register/google | Register Google dengan password |
| POST | /login | Login email |
| POST | /auth/google | Login Google |
| POST | /logout | Logout |
| GET | /me | Ambil profil |
| PUT | /me/profile | Update profil |
| POST | /me/avatar | Upload avatar |
| PUT | /me/password | Update password aplikasi |

Endpoint reminder:

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /reminder-preference | Ambil preferensi reminder |
| PUT | /reminder-preference | Update preferensi reminder |

Endpoint activity:

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /activities | List activity |
| POST | /activities | Buat activity |
| GET | /activities/{activity} | Detail activity |
| PUT | /activities/{activity} | Update activity |
| POST | /activities/{activity}/check-in | Check-in |
| POST | /activities/{activity}/check-out | Check-out |
| POST | /activities/{activity}/cancel | Cancel activity |
| POST | /activities/{activity}/duplicate | Duplicate activity |
| GET | /activities/{activity}/ledger | Riwayat event activity |

Endpoint classroom:

| Method | Endpoint | Role | Fungsi |
|---|---|---|---|
| GET | /classroom/activities/available | Siswa | Activity kelas tersedia |
| POST | /classroom/activities/{activity}/join | Siswa | Join activity kelas |
| GET | /teacher/classroom-activities/{activity}/observations | Guru | Observasi siswa |

Endpoint analisa:

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /burnout-analyses | List history analisa |
| GET | /burnout-analyses/overview | Ringkasan analisa |
| POST | /burnout-analyses | Jalankan analisa |
| POST | /burnout-self-reports | Simpan self report |

Endpoint toolkit:

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /toolkit/tactics | List teknik mindfulness |
| GET | /toolkit/tactics/bookmarked | List bookmark |
| POST | /toolkit/tactics/{tactic}/bookmark | Toggle bookmark |

Endpoint parent:

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /parent/dashboard | Dashboard parent |
| POST | /parent/children | Hubungkan anak |

---

## 29. Struktur Data Utama

Tabel utama:

| Tabel | Fungsi |
|---|---|
| schools | Data sekolah dan status approval |
| users | Data akun semua role |
| classes | Data kelas sekolah |
| class_teacher | Relasi guru dengan kelas |
| activities | Data activity, check-in, check-out, jurnal |
| activity_events | Ledger perubahan activity |
| burnout_analysis_snapshots | History hasil analisa |
| burnout_self_reports | Self report pengguna |
| mindful_tactics | Daftar teknik mindfulness |
| tactic_bookmarks | Bookmark teknik user |
| mindfulness_sessions | Riwayat latihan mindfulness |
| parent_student_links | Relasi parent dan siswa |
| user_login_histories | Riwayat login |
| badges | Data badge |
| user_badges | Badge milik user |
| student_observations | Data observasi siswa |

Relasi inti:

```text
School
  -> has many Users
  -> has many Classes
  -> has many Activities

User
  -> belongs to School
  -> may belong to Class
  -> has many Activities
  -> has many Burnout Analysis Snapshots
  -> has many Mindfulness Sessions

Teacher Activity
  -> may have target Class
  -> has many Student Joined Activities

Parent
  -> links to Student through parent_student_links
```

---

## 30. Data Seeder Untuk Testing

Seeder menyediakan akun testing.

Password default:

```text
password
```

Super admin:

| Role | Email |
|---|---|
| Super Admin | admin@admin.com |

Admin sekolah:

| Sekolah | Email |
|---|---|
| SDN Contoh 1 | admin@sdncontoh1.test |
| SDN Contoh 2 | admin@sdncontoh2.test |

Contoh guru:

| Nama | Email | Sekolah | Kelas |
|---|---|---|---|
| Bu Sari | guru@mindfuledu.test | SDN Contoh 1 | 5A |
| Pak Bima | guru.bima@mindfuledu.test | SDN Contoh 1 | 5B |
| Bu Dina | guru.dina@mindfuledu.test | SDN Contoh 1 | 5A |
| Pak Rizal | guru.rizal@mindfuledu.test | SDN Contoh 1 | 5B |
| Bu Maya | guru.maya@mindfuledu.test | SDN Contoh 1 | 5A |
| Pak Andi | guru.andi@mindfuledu.test | SDN Contoh 1 | 5B |
| Bu Rani | guru.rani@mindfuledu.test | SDN Contoh 2 | 6A |

Contoh siswa:

| Nama | Email | Sekolah | Kelas |
|---|---|---|---|
| Ani | siswa@mindfuledu.test | SDN Contoh 1 | 5A |
| Budi | budi@mindfuledu.test | SDN Contoh 1 | 5A |
| Citra | citra@mindfuledu.test | SDN Contoh 1 | 5A |
| Dewi | dewi@mindfuledu.test | SDN Contoh 1 | 5B |
| Eko | eko@mindfuledu.test | SDN Contoh 1 | 5B |
| Farah | farah@mindfuledu.test | SDN Contoh 2 | 6A |
| Gilang | gilang@mindfuledu.test | SDN Contoh 2 | 6A |

Contoh parent:

| Nama | Email | Terhubung ke |
|---|---|---|
| Orang Tua Ani | parent@mindfuledu.test | Ani |
| Orang Tua Budi | parent.budi@mindfuledu.test | Budi |
| Orang Tua Citra | parent.citra@mindfuledu.test | Citra |
| Orang Tua Dewi | parent.dewi@mindfuledu.test | Dewi |
| Orang Tua Eko | parent.eko@mindfuledu.test | Eko |

---

## 31. Contoh Flow Lengkap Sekolah Baru

Contoh dari awal sampai pengguna memakai aplikasi:

```text
1. SDN Contoh 1 daftar sekolah di website.
2. Super admin membuka dashboard dan approve sekolah.
3. Super admin membuat admin sekolah untuk SDN Contoh 1.
4. Admin sekolah login.
5. Admin sekolah membuat kelas 5A dan 5B.
6. Guru register di aplikasi dan memilih SDN Contoh 1.
7. Siswa register di aplikasi dan memilih SDN Contoh 1 serta kelas 5A.
8. Admin sekolah approve akun guru dan siswa.
9. Guru login ke aplikasi.
10. Guru membuat activity Mengajar Matematika untuk kelas 5A.
11. Siswa login dan melihat activity kelas tersedia.
12. Siswa join activity Mengajar Matematika.
13. Guru check-in saat kelas dimulai.
14. Siswa check-in setelah guru check-in.
15. Guru check-out saat kelas selesai.
16. Siswa check-out dan mengisi jurnal.
17. Sistem membuat review dan analisa.
18. Guru melihat observasi siswa.
19. Siswa melihat hasil analisa dan rekomendasi.
20. Siswa menjalankan latihan mindfulness dari Toolkit.
21. Parent menghubungkan akun anak memakai kode siswa.
22. Parent melihat activity, mood, analisa, dan rekomendasi pendampingan anak.
23. Admin sekolah memantau data sekolah melalui dashboard.
24. Super admin tetap bisa memantau seluruh sekolah.
```

---

## 32. Checklist QA Flow Sistem

Gunakan checklist ini setelah update.

### Sekolah dan Admin

- Sekolah bisa daftar dari website.
- Pendaftaran sekolah masuk sebagai pending.
- Super admin bisa approve sekolah.
- Super admin bisa membuat admin sekolah.
- Admin sekolah hanya melihat sekolahnya sendiri.
- Admin sekolah bisa membuat kelas.

### Register dan Approval

- Guru register email dengan sekolah.
- Siswa register email dengan sekolah dan kelas.
- Register Google tetap meminta password.
- Setelah register guru/siswa, aplikasi kembali ke login.
- Guru/siswa pending tidak bisa login.
- Admin sekolah bisa approve guru/siswa.
- Guru/siswa approved bisa login.
- Role mismatch ditolak.

### Activity

- Guru bisa membuat activity personal.
- Guru bisa membuat activity mengajar.
- Target kelas membatasi siswa yang bisa join.
- Siswa bisa membuat activity pribadi.
- Siswa bisa melihat activity kelas yang sesuai.
- Siswa bisa join activity kelas.
- Edit activity memperbarui card lama.
- Cancel activity tidak meninggalkan data stale di UI.

### Check-In dan Check-Out

- Guru bisa check-in.
- Siswa tidak bisa check-in sebelum guru check-in.
- Siswa bisa check-in setelah guru check-in.
- Guru bisa check-out.
- Siswa tidak bisa check-out sebelum guru check-out.
- Siswa bisa check-out setelah guru check-out.
- Jurnal check-out tersimpan.

### Analisa dan Rekomendasi

- Review activity muncul setelah check-out.
- Analisa harian berjalan.
- Analisa mingguan berjalan.
- Analisa bulanan berjalan.
- Snapshot tersimpan.
- Rekomendasi mindfulness muncul.
- Tombol rekomendasi membuka teknik yang sesuai.

### Guru dan Observasi

- Guru bisa membuka observasi siswa pada activity kelas.
- Mood check-in siswa tampil.
- Alasan check-in siswa tampil.
- Mood check-out siswa tampil.
- Jurnal siswa tampil.
- Ringkasan analisa dan rekomendasi tampil.

### Parent

- Siswa dapat melihat kode parent.
- Parent bisa menghubungkan anak dengan kode dan sekolah yang benar.
- Parent tidak bisa menghubungkan anak dari sekolah yang salah.
- Parent melihat activity anak.
- Parent melihat mood check-in/check-out anak.
- Parent melihat analisa burnout anak.
- Parent melihat rekomendasi pendampingan.

### Toolkit dan Reminder

- Semua teknik mindfulness tampil.
- Guided practice berjalan step-by-step.
- TTS membacakan instruksi.
- Evaluasi setelah latihan tersimpan.
- Reminder harian muncul.
- Reminder check-in muncul 10 menit sebelum activity.
- Reminder check-out muncul tepat saat jam selesai.

---

## 33. Ringkasan Fungsi Semua Sistem

MindfulEdu menjalankan siklus berikut:

```text
Daftarkan sekolah
  -> approve sekolah
  -> buat admin sekolah
  -> kelola kelas
  -> register guru/siswa/parent
  -> approve guru/siswa
  -> login role-based
  -> activity tracking
  -> check-in mood
  -> check-out jurnal
  -> review activity
  -> analisa burnout
  -> rekomendasi mindfulness
  -> guided practice
  -> evaluasi latihan
  -> observasi siswa
  -> parent monitoring
  -> admin monitoring
```

Dengan flow ini, sistem membantu:

- sekolah mengelola akses pengguna;
- guru memantau aktivitas dan kondisi diri serta siswa;
- siswa memahami kondisi belajar dan emosinya;
- parent memantau anak secara terbatas dan relevan;
- admin sekolah menjaga data sekolah tetap rapi;
- super admin menjaga keseluruhan ekosistem tetap terkontrol.

MindfulEdu berperan sebagai sistem pendamping untuk refleksi, pemantauan, dan rekomendasi pemulihan berbasis mindfulness.
