# README Manual Guide Video MindfulEdu

Dokumen ini adalah panduan pembuatan video manual penggunaan MindfulEdu berdasarkan fitur sistem saat ini. Formatnya dibuat sebagai alur rekaman, naskah singkat, dan checklist fungsi yang perlu ditunjukkan untuk setiap role.

Dokumen ini bisa dipakai untuk:

- video tutorial siswa;
- video tutorial guru;
- video tutorial parent/orang tua;
- video tutorial admin sekolah;
- video tutorial super admin;
- bahan demo presentasi sistem.

Target production:

```text
Website      : https://mindfulapps.pkmueu.online
API Mobile   : https://mindfulapps.pkmueu.online/api
Download APK : https://mindfulapps.pkmueu.online/download/android
Admin Panel  : https://mindfulapps.pkmueu.online/admin
```

Catatan penting:

- Jangan menampilkan password asli, API key, file `.env`, atau file `.pem` di video.
- Jika memakai akun demo, gunakan data dummy.
- Jika menampilkan analisis burnout, jelaskan bahwa hasilnya adalah pendukung refleksi, bukan diagnosis medis.
- Approval akun guru/siswa dilakukan oleh super admin atau admin sekolah terkait, dan tidak perlu mengirim email otomatis.

---

## 1. Struktur Video Yang Disarankan

Ada dua pilihan format video.

| Format | Cocok Untuk | Isi |
|---|---|---|
| 1 video panjang | Presentasi sistem lengkap | Semua role dari awal sampai akhir |
| 5 video pendek | Tutorial pengguna | Satu video untuk tiap role |

Urutan video panjang yang disarankan:

```text
Opening
  -> gambaran sistem
  -> pendaftaran sekolah
  -> super admin
  -> admin sekolah
  -> guru
  -> siswa
  -> parent
  -> analisis dan rekomendasi
  -> penutup
```

Estimasi durasi:

| Bagian | Durasi |
|---|---:|
| Opening sistem | 1 menit |
| Pendaftaran sekolah | 2 menit |
| Super admin | 3 menit |
| Admin sekolah | 4 menit |
| Guru | 6 menit |
| Siswa | 6 menit |
| Parent | 4 menit |
| Analisis dan toolkit | 4 menit |
| Penutup | 1 menit |
| Total | 31 menit |

---

## 2. Opening Video

Tujuan opening:

- memperkenalkan MindfulEdu;
- menjelaskan siapa saja role di sistem;
- menjelaskan masalah yang dibantu oleh sistem.

Naskah singkat:

```text
MindfulEdu adalah aplikasi untuk membantu sekolah memantau aktivitas, mood, jurnal refleksi, analisis burnout, dan rekomendasi latihan mindfulness untuk guru, siswa, dan orang tua.

Di sistem ini ada beberapa role: super admin, admin sekolah, guru, siswa, dan parent. Setiap role punya akses yang berbeda agar data sekolah, guru, siswa, dan orang tua tetap terpisah sesuai hak aksesnya.
```

Yang ditampilkan:

- landing page MindfulEdu;
- tombol download APK;
- halaman admin login;
- cuplikan aplikasi mobile.

---

## 3. Video Pendaftaran Sekolah

Role yang digunakan:

```text
Pihak sekolah / calon sekolah
```

Tujuan:

- menunjukkan cara sekolah mendaftar dari website;
- menunjukkan bahwa sekolah perlu menunggu approval.

Alur rekaman:

```text
Buka website MindfulEdu
  -> klik daftar sekolah
  -> isi identitas sekolah
  -> pilih provinsi
  -> pilih kota/kabupaten berdasarkan provinsi
  -> pilih kecamatan berdasarkan kota/kabupaten
  -> isi kontak penanggung jawab
  -> submit
  -> tampil pesan berhasil/pending
```

Field yang perlu dijelaskan:

| Field | Fungsi |
|---|---|
| Nama sekolah | Identitas sekolah yang akan tampil di sistem |
| NPSN | Nomor pokok sekolah nasional |
| Jenjang | SD, SMP, SMA, atau jenjang lain |
| Status sekolah | Negeri atau swasta |
| Alamat | Lokasi detail sekolah |
| Provinsi | Pilihan wilayah level pertama |
| Kota/Kabupaten | Pilihan otomatis sesuai provinsi |
| Kecamatan | Pilihan otomatis sesuai kota/kabupaten |
| Nama kontak | Penanggung jawab pendaftaran |
| Jabatan kontak | Posisi penanggung jawab |
| Email kontak | Email yang bisa dihubungi |
| Nomor telepon | Nomor kontak sekolah |

Naskah singkat:

```text
Sekolah mendaftar melalui website publik. Pada bagian wilayah, pilihan dibuat bertingkat. Setelah provinsi dipilih, kota atau kabupaten akan muncul sesuai provinsi tersebut. Setelah kota dipilih, kecamatan akan muncul sesuai kota atau kabupatennya. Setelah form dikirim, status sekolah menjadi pending dan perlu disetujui oleh super admin.
```

Checklist:

```text
[ ] Website bisa dibuka
[ ] Form daftar sekolah tampil
[ ] Dropdown provinsi tampil
[ ] Kota/kabupaten mengikuti provinsi
[ ] Kecamatan mengikuti kota/kabupaten
[ ] Submit berhasil
[ ] Status pendaftaran menjadi pending
```

---

## 4. Video Super Admin

Role:

```text
Super Admin
```

Fungsi utama:

- mengelola seluruh sistem;
- approve/reject sekolah;
- membuat admin sekolah;
- melihat data semua sekolah;
- memantau guru, siswa, parent, activity, analisis, observasi, dan data mindfulness.

Alur rekaman:

```text
Buka /admin
  -> login sebagai super admin
  -> buka School Registrations
  -> cek data sekolah pending
  -> approve sekolah
  -> buka Schools
  -> pastikan sekolah sudah approved
  -> buka School Admins
  -> buat admin sekolah untuk sekolah tersebut
  -> lihat data guru/siswa/parent/activity/analisis
```

Menu yang perlu ditunjukkan:

| Menu | Fungsi Video |
|---|---|
| School Registrations | Meninjau sekolah yang mendaftar |
| Schools | Melihat/mengelola sekolah approved |
| School Admins | Membuat admin sekolah |
| Classes | Melihat/mengelola kelas |
| Teacher Registrations | Melihat guru yang pending |
| Student Registrations | Melihat siswa yang pending |
| Teacher Data | Data guru seluruh sekolah |
| Student Data | Data siswa seluruh sekolah |
| Parent Management | Data parent |
| Teacher Activities | Aktivitas guru |
| Student Activities | Aktivitas siswa |
| Teacher Burnout Analysis | Hasil analisis guru |
| Student Burnout Analysis | Hasil analisis siswa |
| Student Observations | Observasi siswa dari activity kelas |
| Mindful Tactics | Daftar teknik mindfulness |
| Mindfulness Sessions | Riwayat sesi mindfulness |
| Badges | Data badge |
| Login Histories | Riwayat login |

Naskah singkat:

```text
Super admin adalah pengelola pusat. Setelah sekolah mendaftar, super admin mengecek data sekolah lalu menyetujui atau menolak. Jika sekolah disetujui, super admin dapat membuat admin sekolah. Super admin juga bisa melihat seluruh data lintas sekolah untuk kebutuhan monitoring sistem.
```

Checklist:

```text
[ ] Login super admin berhasil
[ ] Sekolah pending terlihat
[ ] Sekolah bisa di-approve
[ ] Admin sekolah bisa dibuat
[ ] Data dashboard lintas sekolah tampil
[ ] Data guru/siswa/parent/activity/analisis bisa dipantau
```

---

## 5. Video Admin Sekolah

Role:

```text
Admin Sekolah
```

Fungsi utama:

- mengelola satu sekolah sendiri;
- membuat kelas;
- approve/reject akun guru dan siswa;
- reset/mengubah password user sekolah jika diperlukan;
- memantau activity dan analisis dalam sekolahnya.

Alur rekaman:

```text
Buka /admin
  -> login sebagai admin sekolah
  -> lihat dashboard sekolah
  -> buka School Profile
  -> buka Classes
  -> buat kelas baru
  -> buka Teacher Registrations
  -> approve guru dari sekolah yang sama
  -> buka Student Registrations
  -> approve siswa dari sekolah yang sama
  -> cek Teacher Data dan Student Data
  -> cek activity dan analisis sekolah
```

Menu yang perlu ditunjukkan:

| Menu | Fungsi Video |
|---|---|
| School Profile | Melihat data sekolah admin |
| Classes | Membuat dan mengelola kelas |
| Teacher Registrations | Approve/reject guru sekolah terkait |
| Student Registrations | Approve/reject siswa sekolah terkait |
| Teacher Data | Melihat guru di sekolah sendiri |
| Student Data | Melihat siswa di sekolah sendiri |
| Parent Management | Melihat parent yang terhubung dengan siswa sekolah |
| Teacher Activities | Monitoring aktivitas guru sekolah |
| Student Activities | Monitoring aktivitas siswa sekolah |
| Teacher Burnout Analysis | Monitoring analisis guru sekolah |
| Student Burnout Analysis | Monitoring analisis siswa sekolah |
| Student Observations | Melihat observasi siswa pada aktivitas kelas |

Naskah singkat:

```text
Admin sekolah hanya melihat data sekolahnya sendiri. Ketika guru atau siswa mendaftar dan memilih sekolah ini, akun mereka akan masuk ke daftar pending. Admin sekolah dapat menyetujui akun tersebut agar pengguna bisa login ke aplikasi.
```

Aturan approval:

- guru/siswa hanya masuk ke admin sekolah yang dipilih saat registrasi;
- super admin tetap bisa melihat semua pendaftaran;
- admin sekolah tidak melihat pending user dari sekolah lain;
- proses approval tidak perlu mengirim email otomatis.

Checklist:

```text
[ ] Admin sekolah login berhasil
[ ] Dashboard hanya menampilkan data sekolah sendiri
[ ] Kelas bisa dibuat
[ ] Guru pending sekolah sendiri terlihat
[ ] Siswa pending sekolah sendiri terlihat
[ ] Approve akun berhasil
[ ] Data user approved muncul di Teacher Data/Student Data
```

---

## 6. Video Guru

Role:

```text
Guru
```

Fungsi utama:

- register dan menunggu approval;
- login setelah approved;
- melengkapi profil;
- membuat activity pribadi;
- membuat activity mengajar untuk kelas;
- check-in sebelum activity;
- check-out dan isi jurnal setelah activity;
- melihat analisis burnout;
- melihat rekomendasi mindfulness;
- menjalankan toolkit;
- melihat observasi siswa pada activity kelas.

Alur rekaman register guru:

```text
Buka aplikasi
  -> pilih role Guru
  -> daftar dengan email atau Google
  -> isi data akun
  -> pilih sekolah approved
  -> submit
  -> muncul pesan menunggu approval
  -> admin sekolah approve
  -> guru login
```

Alur rekaman activity guru:

```text
Guru login
  -> buka menu Aktivitas
  -> tambah activity
  -> pilih jenis activity
  -> jika Mengajar, pilih target kelas
  -> simpan
  -> activity tampil di daftar
  -> tekan Check-in
  -> pilih mood dan intensitas
  -> submit
  -> setelah selesai, tekan Check-out
  -> isi mood akhir dan jurnal
  -> submit
  -> review dan rekomendasi muncul
```

Jenis activity guru:

| Jenis | Fungsi |
|---|---|
| Mengajar | Activity kelas yang bisa dijoin siswa |
| Rapat | Mencatat kegiatan rapat |
| Administrasi | Mencatat tugas administrasi |
| Koreksi | Mencatat kegiatan koreksi |
| Persiapan materi | Mencatat persiapan mengajar |
| Istirahat | Mencatat jeda/pemulihan |
| Lainnya | Activity bebas |

Alur rekaman observasi siswa:

```text
Guru membuat activity Mengajar
  -> siswa join activity
  -> guru check-in
  -> siswa check-in
  -> guru check-out
  -> siswa check-out dan isi jurnal
  -> guru buka Observasi Siswa
  -> guru melihat status dan kondisi siswa
```

Data observasi siswa yang ditampilkan:

| Data | Fungsi |
|---|---|
| Nama siswa | Identitas siswa yang join |
| Status activity | Planned, checked in, completed, atau cancelled |
| Mood check-in | Kondisi awal siswa |
| Alasan check-in | Pemicu awal jika diisi |
| Mood check-out | Kondisi akhir siswa |
| Jurnal siswa | Refleksi siswa setelah aktivitas |
| Analisis siswa | Ringkasan kondisi siswa |
| Rekomendasi | Teknik mindfulness yang disarankan |

Alur rekaman analisis guru:

```text
Buka menu Analisis
  -> pilih Harian, Mingguan, atau Bulanan
  -> tekan tombol Analisis
  -> lihat skor dan kategori
  -> lihat ringkasan workload dan wellbeing
  -> lihat journal reviews
  -> buka rekomendasi teknik mindfulness
```

Catatan rumus analisis saat ini:

```text
Harian   : tanggal dipilih, kapasitas 8 jam
Mingguan : 7 hari terakhir, kapasitas 56 jam
Bulanan  : 30 hari terakhir, kapasitas 240 jam
Final    : 50% workload + 50% wellbeing
```

Checklist:

```text
[ ] Guru pending tidak bisa login sebelum approved
[ ] Guru approved bisa login
[ ] Guru bisa membuat activity pribadi
[ ] Guru bisa membuat activity Mengajar
[ ] Target kelas membatasi siswa yang bisa join
[ ] Guru bisa check-in
[ ] Guru bisa check-out dan isi jurnal
[ ] Review activity muncul
[ ] Analisis harian/mingguan/bulanan tampil
[ ] Rekomendasi mindfulness bisa dibuka
[ ] Observasi siswa tampil pada activity kelas
```

---

## 7. Video Siswa

Role:

```text
Siswa
```

Fungsi utama:

- register dan menunggu approval;
- login setelah approved;
- melengkapi profil sekolah dan kelas;
- membuat activity pribadi;
- melihat activity kelas dari guru;
- join activity kelas;
- check-in dan check-out;
- mengisi jurnal;
- melihat analisis burnout;
- membuka rekomendasi mindfulness;
- menggunakan toolkit;
- memberikan kode parent kepada orang tua.

Alur rekaman register siswa:

```text
Buka aplikasi
  -> pilih role Siswa
  -> daftar dengan email atau Google
  -> isi data akun
  -> pilih sekolah approved
  -> pilih kelas
  -> submit
  -> muncul pesan menunggu approval
  -> admin sekolah approve
  -> siswa login
```

Alur rekaman activity pribadi siswa:

```text
Siswa login
  -> buka menu Aktivitas
  -> tambah activity
  -> isi nama, tanggal, jam, dan jenis activity
  -> simpan
  -> check-in sebelum mulai
  -> check-out setelah selesai
  -> isi jurnal
  -> lihat review/rekomendasi
```

Jenis activity siswa:

| Jenis | Fungsi |
|---|---|
| Belajar di kelas | Mencatat kegiatan belajar |
| Belajar bersama | Mencatat study group |
| Tugas/PR | Mencatat pengerjaan tugas |
| Ujian/Ulangan | Mencatat ujian |
| Ekstrakurikuler | Mencatat kegiatan luar kelas |
| Istirahat | Mencatat jeda |
| Lainnya | Activity bebas |

Alur rekaman join activity kelas:

```text
Guru membuat activity Mengajar
  -> siswa buka activity kelas tersedia
  -> siswa memilih activity yang sesuai sekolah/kelas
  -> siswa tekan Join
  -> activity masuk ke daftar siswa
  -> siswa menunggu guru check-in
  -> siswa check-in
  -> siswa menunggu guru check-out
  -> siswa check-out dan isi jurnal
```

Aturan activity kelas:

- activity hanya muncul jika sekolah siswa sama dengan sekolah guru;
- jika guru memilih target kelas, hanya siswa kelas itu yang bisa join;
- siswa tidak bisa check-in sebelum guru check-in;
- siswa tidak bisa check-out sebelum guru check-out.

Alur rekaman analisis siswa:

```text
Buka menu Analisis
  -> pilih periode
  -> tekan Analisis
  -> lihat kategori hijau/kuning/merah
  -> lihat activity breakdown
  -> buka rekomendasi mindfulness
```

Alur rekaman kode parent:

```text
Buka Profil
  -> lihat kode verifikasi siswa
  -> salin kode
  -> berikan kode kepada parent
```

Checklist:

```text
[ ] Siswa pending tidak bisa login sebelum approved
[ ] Siswa approved bisa login
[ ] Siswa bisa membuat activity pribadi
[ ] Siswa bisa melihat activity kelas sesuai sekolah/kelas
[ ] Siswa bisa join activity kelas
[ ] Gate check-in mengikuti guru
[ ] Gate check-out mengikuti guru
[ ] Jurnal siswa tersimpan
[ ] Analisis siswa tampil
[ ] Rekomendasi mindfulness bisa dibuka
[ ] Kode parent tampil di profil
```

---

## 8. Video Parent / Orang Tua

Role:

```text
Parent
```

Fungsi utama:

- register/login sebagai orang tua;
- menghubungkan anak memakai kode siswa;
- melihat dashboard anak;
- memantau activity anak;
- melihat mood check-in/check-out anak;
- melihat analisis burnout anak;
- melihat rekomendasi pendampingan.

Alur rekaman register parent:

```text
Buka aplikasi
  -> pilih role Orang Tua
  -> daftar dengan email atau Google
  -> login
```

Alur rekaman menghubungkan anak:

```text
Parent login
  -> buka menu Anak atau Profil
  -> tekan tambah/hubungkan anak
  -> masukkan kode verifikasi siswa
  -> masukkan/pilih sekolah anak
  -> submit
  -> anak muncul di daftar monitoring
```

Data yang dilihat parent:

| Data | Fungsi |
|---|---|
| Daftar anak | Anak yang sudah terhubung |
| Filter tanggal | Memilih tanggal aktivitas anak |
| Activity anak | Kegiatan anak pada tanggal tertentu |
| Mood check-in | Kondisi anak sebelum activity |
| Mood check-out | Kondisi anak setelah activity |
| Guru terkait | Guru jika activity berasal dari kelas |
| Analisis anak | Ringkasan kondisi anak |
| Rekomendasi | Saran pendampingan yang relevan |

Batasan parent:

- parent tidak membuat activity anak;
- parent tidak mengedit jurnal anak;
- parent tidak approve akun;
- parent hanya melihat anak yang sudah terhubung;
- parent tidak melihat siswa lain.

Naskah singkat:

```text
Parent menggunakan MindfulEdu untuk memantau kondisi anak secara terbatas. Parent perlu kode verifikasi dari profil siswa dan sekolah yang sesuai. Setelah terhubung, parent bisa melihat aktivitas, mood, analisis, dan rekomendasi pendampingan anak.
```

Checklist:

```text
[ ] Parent bisa login
[ ] Parent bisa memasukkan kode siswa
[ ] Sekolah harus cocok dengan data siswa
[ ] Anak muncul di dashboard parent
[ ] Activity anak tampil
[ ] Mood check-in/check-out anak tampil
[ ] Analisis dan rekomendasi anak tampil
```

---

## 9. Video Toolkit Mindfulness

Role:

```text
Guru dan Siswa
```

Fungsi utama:

- melihat daftar teknik mindfulness;
- membuka detail teknik;
- menjalankan guided practice step-by-step;
- mendengar instruksi TTS;
- menyimpan bookmark;
- mengisi evaluasi setelah latihan.

Alur rekaman:

```text
Buka menu Toolkit
  -> lihat daftar teknik
  -> pilih salah satu teknik
  -> baca ringkasan dan knowledge
  -> tekan Mulai
  -> ikuti step latihan
  -> dengarkan TTS
  -> selesai
  -> isi evaluasi kondisi setelah latihan
```

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
| 11 | Mindful Drinking |
| 12 | Mindful Eating |
| 13 | Mindful Walking to Class |
| 14 | Teknik STOP |
| 15 | Grounding 3-2-1 |
| 16 | Napas 4-7-8 |
| 17 | Jeda Napas 3 Menit |
| 18 | Awareness of Breathing |
| 19 | RAIN |
| 20 | Jurnal Reflektif Harian |

Catatan video:

- Tampilkan teknik yang punya avatar animasi.
- Jika ada teknik yang belum punya gambar, tampilkan fallback visual dan catat sebagai kebutuhan asset.
- Jangan terlalu lama di tiap step; cukup tunjukkan bahwa step, timer, dan TTS berjalan.

Checklist:

```text
[ ] List teknik tampil
[ ] Detail teknik tampil
[ ] Bookmark bisa ditekan
[ ] Guided practice berjalan
[ ] Step berpindah
[ ] TTS aktif
[ ] Evaluasi selesai latihan tampil
```

---

## 10. Video Reminder dan Profil

Role:

```text
Guru, Siswa, Parent
```

Fungsi profil:

| Role | Fungsi Profil |
|---|---|
| Guru | Edit nama, sekolah, avatar, password, reminder, login history |
| Siswa | Edit nama, sekolah, kelas, avatar, password, reminder, kode parent |
| Parent | Edit nama, avatar, password, login history, daftar anak |

Alur rekaman profil:

```text
Buka Profil
  -> lihat data akun
  -> ubah nama/avatar jika perlu
  -> buka update password
  -> lihat login history
  -> logout
```

Alur rekaman reminder:

```text
Buka Profil atau Pengaturan
  -> aktifkan reminder
  -> pilih jam reminder harian
  -> izinkan notifikasi perangkat
  -> simpan
```

Jenis reminder:

| Reminder | Waktu |
|---|---|
| Reminder harian | Sesuai pilihan user |
| Reminder check-in | 10 menit sebelum activity |
| Reminder check-out | Saat jam activity selesai |

Catatan:

- reminder menggunakan local notification di aplikasi;
- jika permission notifikasi ditolak, reminder tidak tampil;
- jika aplikasi dihapus, jadwal lokal hilang.

---

## 11. Alur Demo Lengkap End-to-End

Gunakan urutan ini jika ingin membuat satu video demo lengkap.

```text
1. Buka website MindfulEdu.
2. Daftarkan sekolah baru.
3. Login super admin.
4. Approve sekolah.
5. Buat admin sekolah.
6. Login admin sekolah.
7. Buat kelas.
8. Register guru dari aplikasi.
9. Register siswa dari aplikasi.
10. Admin sekolah approve guru dan siswa.
11. Guru login.
12. Guru membuat activity Mengajar untuk kelas.
13. Siswa login.
14. Siswa join activity kelas.
15. Guru check-in.
16. Siswa check-in.
17. Guru check-out dan isi jurnal.
18. Siswa check-out dan isi jurnal.
19. Guru melihat observasi siswa.
20. Guru membuka analisis.
21. Siswa membuka analisis.
22. Guru/siswa membuka rekomendasi mindfulness.
23. Guru/siswa menjalankan guided practice.
24. Siswa membuka profil dan menyalin kode parent.
25. Parent login.
26. Parent menghubungkan anak.
27. Parent melihat dashboard monitoring anak.
28. Admin sekolah memantau data sekolah.
29. Super admin memantau data seluruh sistem.
```

---

## 12. Checklist Sebelum Rekaman

```text
[ ] Server production aktif
[ ] Website bisa dibuka
[ ] APK terbaru sudah terinstall
[ ] Akun demo siap
[ ] Sekolah demo approved
[ ] Kelas demo tersedia
[ ] Guru demo approved
[ ] Siswa demo approved
[ ] Parent demo siap
[ ] Activity demo belum dipakai atau sudah disiapkan
[ ] Notifikasi Android sudah diizinkan jika ingin demo reminder
[ ] Jangan tampilkan data rahasia
```

Endpoint cepat untuk cek:

```bash
curl -I https://mindfulapps.pkmueu.online
curl -I https://mindfulapps.pkmueu.online/admin
curl -I https://mindfulapps.pkmueu.online/api/me
curl -I https://mindfulapps.pkmueu.online/download/android
```

Hasil normal:

```text
/            -> 200 OK
/admin       -> 302 Found atau halaman login admin
/api/me      -> 401 Unauthorized jika belum login
/download/android -> 200 OK jika APK sudah tersedia
```

---

## 13. Naskah Penutup

```text
Dengan alur ini, MindfulEdu membantu sekolah mengatur pengguna, membantu guru dan siswa mencatat aktivitas serta kondisi harian, dan membantu orang tua memantau anak secara relevan. Data check-in, check-out, jurnal, dan aktivitas digunakan untuk membuat analisis burnout dan rekomendasi latihan mindfulness yang bisa langsung dipraktikkan di aplikasi.
```

