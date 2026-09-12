# Knowledge Aplikasi MindfulEdu Terbaru

Dokumen ini menjelaskan kondisi sistem MindfulEdu saat ini secara menyeluruh: tujuan aplikasi, role pengguna, fungsi setiap modul, alur manual guide, analisis burnout, rekomendasi mindfulness, dan batasan akses data.

Dokumen ini dipakai sebagai:

- bahan penjabaran sistem untuk presentasi;
- pegangan membuat video manual guide;
- knowledge base fitur aplikasi;
- acuan menjelaskan fungsi sistem kepada sekolah, guru, siswa, parent, dan penguji.

---

## 1. Ringkasan Aplikasi

MindfulEdu adalah aplikasi pendamping sekolah untuk mencatat activity harian, mood, jurnal reflektif, analisis burnout, dan rekomendasi latihan mindfulness.

MindfulEdu membantu:

- sekolah mengelola data guru, siswa, parent, kelas, dan approval;
- guru mencatat activity mengajar dan memahami kondisi diri;
- siswa memahami aktivitas belajar, mood, dan pola jurnal;
- parent memantau kondisi anak yang sudah terhubung;
- admin sekolah menjaga data sekolahnya tetap rapi;
- super admin mengelola seluruh sistem lintas sekolah.

Catatan penting:

- MindfulEdu bukan alat diagnosis medis.
- Analisis burnout adalah indikator refleksi dan monitoring.
- Rekomendasi mindfulness adalah latihan pendamping, bukan pengganti bantuan profesional.

Target production:

```text
Website      : https://mindfulapps.pkmueu.online
API Mobile   : https://mindfulapps.pkmueu.online/api
Download APK : https://mindfulapps.pkmueu.online/download/android
Admin Panel  : https://mindfulapps.pkmueu.online/admin
```

---

## 2. Status Sistem Saat Ini

Kondisi terbaru sistem:

- website publik aktif untuk landing page, pendaftaran sekolah, dan download APK;
- aplikasi Flutter dipakai oleh guru, siswa, dan parent;
- admin panel Filament dipakai oleh super admin dan admin sekolah;
- backend Laravel menjadi pusat API, role access, activity, analisis, dan dashboard;
- Python/FastAPI berjalan sebagai service pendukung analisis dan rekomendasi;
- MariaDB menyimpan data utama;
- rekomendasi pada Home Analisis dan Screen Analisis sudah disatukan memakai sumber harian yang sama;
- rekomendasi utama tidak lagi dibedakan per activity pada tampilan utama analisis;
- activity review tetap membantu membuat narasi/kesimpulan, tetapi rekomendasi utama mengikuti kesimpulan harian;
- jika snapshot analisis harian masih valid, preview analisis memakai snapshot itu agar Home dan Screen Analisis konsisten;
- jika belum ada skor harian, Home tidak menampilkan rekomendasi lama dari snapshot lain.

---

## 3. Komponen Sistem

| Komponen | Fungsi |
|---|---|
| Website publik | Landing page, pendaftaran sekolah, dan download APK |
| Flutter Mobile App | Aplikasi utama untuk guru, siswa, dan parent |
| Laravel API | Autentikasi, role, activity, jurnal, analisis, parent, dan classroom |
| Filament Admin Panel | Dashboard super admin dan admin sekolah |
| Python/FastAPI ML Service | Pendukung scoring, narasi, dan rekomendasi analisis |
| MariaDB | Database utama |
| Docker Compose | Menjalankan `nginx`, `php`, `db`, dan `ml` |
| Local Notification | Reminder harian, check-in, dan check-out di perangkat |

Alur teknis:

```text
Website / Flutter
  -> Laravel API
  -> MariaDB
  -> FastAPI ML Service jika analisis membutuhkan scoring/narasi tambahan
  -> Laravel menyimpan snapshot hasil analisis
  -> Flutter dan Admin Panel menampilkan hasil sesuai role
```

---

## 4. Role dan Hak Akses

| Role | Fungsi Utama |
|---|---|
| Super Admin | Mengelola semua sekolah, admin sekolah, guru, siswa, parent, activity, analisis, dan data sistem |
| Admin Sekolah | Mengelola guru, siswa, parent, kelas, approval, activity, dan analisis khusus sekolahnya |
| Guru | Membuat activity, check-in, check-out, jurnal, melihat analisis, toolkit, dan observasi siswa |
| Siswa | Membuat activity, join activity kelas, check-in, check-out, jurnal, melihat analisis, toolkit, dan kode parent |
| Parent | Menghubungkan anak dan memantau activity, mood, analisis, serta rekomendasi pendampingan anak |

Aturan scope data:

- super admin dapat melihat semua data;
- admin sekolah hanya melihat dan mengelola data sekolahnya sendiri;
- admin sekolah dapat CRUD guru, siswa, dan parent dalam sekolahnya sendiri;
- admin sekolah tidak boleh memindahkan user ke sekolah lain;
- admin sekolah tidak boleh melihat atau mengubah data sekolah lain;
- guru hanya melihat activity sendiri dan observasi siswa dari activity kelas miliknya;
- siswa hanya melihat activity pribadi dan activity kelas yang sesuai sekolah/kelasnya;
- parent hanya melihat anak yang sudah terhubung melalui kode siswa.

---

## 5. Alur Besar Sistem

```text
Sekolah daftar dari website
  -> super admin review pendaftaran
  -> sekolah approved
  -> super admin membuat admin sekolah
  -> admin sekolah membuat kelas
  -> guru dan siswa register dari aplikasi
  -> akun guru/siswa masuk pending
  -> admin sekolah approve guru/siswa sekolahnya
  -> guru/siswa login
  -> guru membuat activity pribadi atau mengajar
  -> siswa membuat activity pribadi atau join activity kelas
  -> pengguna check-in sebelum activity
  -> pengguna check-out dan menulis jurnal
  -> sistem membaca mood, jurnal, durasi, dan intensity factor
  -> sistem membuat analisis burnout harian/mingguan/bulanan
  -> sistem memberi rekomendasi mindfulness harian
  -> pengguna membuka toolkit dan menjalankan guided practice
  -> parent memantau anak jika sudah terhubung
  -> admin sekolah dan super admin memantau data sesuai scope
```

---

## 6. Pendaftaran Sekolah

Pendaftaran sekolah dilakukan dari website publik.

Data yang diisi:

| Field | Keterangan |
|---|---|
| Nama sekolah | Nama resmi sekolah |
| NPSN | Nomor pokok sekolah jika ada |
| Jenjang | SD, SMP, SMA, atau lainnya |
| Status sekolah | Negeri atau swasta |
| Alamat | Alamat lengkap sekolah |
| Provinsi | Dipilih dari nested wilayah Indonesia |
| Kota/Kabupaten | Muncul sesuai provinsi |
| Kecamatan | Muncul sesuai kota/kabupaten |
| Nama kontak | Penanggung jawab pendaftaran |
| Jabatan kontak | Jabatan penanggung jawab |
| Email kontak | Email yang dapat dihubungi |
| Nomor telepon | Nomor kontak sekolah |

Nested choice wilayah:

```text
Pilih Provinsi
  -> Kota/Kabupaten terbuka sesuai provinsi
  -> pilih Kota/Kabupaten
  -> Kecamatan terbuka sesuai kota/kabupaten
  -> submit pendaftaran
```

Status sekolah:

| Status | Makna |
|---|---|
| Pending | Sekolah baru daftar dan menunggu review |
| Approved | Sekolah diterima dan bisa dipakai untuk register |
| Rejected | Sekolah ditolak atau data belum valid |

---

## 7. Admin Panel

### 7.1 Super Admin

Super admin mengelola pusat sistem.

Fungsi utama:

- review pendaftaran sekolah;
- approve/reject sekolah;
- membuat dan mengelola admin sekolah;
- melihat semua sekolah dan kelas;
- melihat data guru, siswa, parent;
- melihat activity guru/siswa;
- melihat analisis guru/siswa;
- melihat observasi siswa;
- melihat login history;
- mengelola mindful tactics, badges, dan data pendukung.

### 7.2 Admin Sekolah

Admin sekolah hanya mengelola data sekolahnya sendiri.

Fungsi utama:

- melihat/mengelola profil sekolah sendiri;
- membuat dan mengelola kelas;
- approve/reject guru dan siswa yang mendaftar ke sekolahnya;
- CRUD guru sekolahnya;
- CRUD siswa sekolahnya;
- CRUD parent yang terkait dengan siswa sekolahnya;
- reset/mengelola password user sekolahnya jika dibutuhkan;
- melihat activity dan analisis user sekolahnya;
- melihat observasi siswa dalam scope sekolahnya.

Batasan admin sekolah:

- tidak bisa melihat sekolah lain;
- tidak bisa mengubah sekolah user ke sekolah lain;
- tidak bisa approve user dari sekolah lain;
- tidak mengirim email otomatis saat approval jika proses pemberitahuan dilakukan manual/pribadi.

---

## 8. Mobile App

### 8.1 Register

Guru dan siswa register dari aplikasi mobile.

Alur:

```text
Pilih role
  -> daftar email/password atau Google
  -> pilih sekolah approved
  -> siswa memilih kelas
  -> submit register
  -> akun pending
  -> admin sekolah approve
  -> user bisa login
```

Parent register dari aplikasi, lalu menghubungkan anak setelah login.

### 8.2 Lengkapi Akun

Setelah register/login, pengguna dapat melengkapi profil. Untuk user yang sudah memilih sekolah saat register, sekolah ditampilkan sebagai informasi terkunci dan tidak bisa diganti sembarangan dari aplikasi.

Tujuannya:

- menjaga data sekolah tetap konsisten;
- approval tetap sesuai sekolah pendaftaran;
- mencegah user pindah sekolah tanpa proses admin.

### 8.3 Login

Login berbasis role:

```text
Pilih role
  -> email/password atau Google
  -> backend cek role, credential, dan approval
  -> token dibuat
  -> sesi lama dicabut
  -> dashboard role terbuka
```

Aturan:

- guru tidak bisa login sebagai siswa;
- siswa tidak bisa login sebagai guru;
- parent tidak bisa masuk melalui role guru/siswa;
- guru/siswa pending tidak bisa login;
- satu akun hanya memiliki satu sesi aktif.

---

## 9. Activity

Activity adalah pusat data MindfulEdu.

Status activity:

| Status | Makna |
|---|---|
| Planned | Activity dibuat dan belum check-in |
| Checked in | Activity sedang berjalan |
| Completed | Activity sudah check-out dan punya data akhir |
| Cancelled | Activity dibatalkan |

Data activity:

- judul;
- tanggal;
- jam mulai;
- jam selesai;
- jenis activity;
- planned hours;
- actual hours;
- intensity factor;
- mood check-in;
- intensitas mood awal;
- alasan check-in;
- mood check-out;
- jurnal check-out;
- review activity;
- ledger perubahan.

Activity guru:

- activity pribadi;
- activity mengajar;
- activity mengajar dapat diarahkan ke kelas tertentu.

Activity siswa:

- activity pribadi;
- activity kelas dari guru yang dijoin siswa.

Aturan activity kelas:

- siswa hanya melihat activity dari sekolah yang sama;
- jika guru memilih target kelas, hanya siswa kelas itu yang melihat;
- siswa belum bisa check-in sebelum guru check-in;
- siswa belum bisa check-out sebelum guru check-out;
- observasi siswa muncul dari activity kelas yang diikuti.

---

## 10. Check-In, Check-Out, dan Jurnal

### 10.1 Check-In

Check-in mencatat kondisi sebelum activity.

Data check-in:

- mood awal;
- intensitas mood;
- alasan atau pemicu.

Mood:

| Mood | Makna Umum |
|---|---|
| Senang | Positif |
| Tenang | Stabil |
| Cemas | Perlu diperhatikan |
| Sedih | Perlu diperhatikan |
| Marah | Perlu diperhatikan |

### 10.2 Check-Out

Check-out menutup activity dan mencatat kondisi setelah activity.

Data check-out:

- mood akhir;
- fakta kejadian;
- perasaan;
- pola yang disadari;
- rencana berikutnya;
- tag burnout untuk guru jika relevan.

### 10.3 Jurnal

Jurnal dipakai untuk membaca konteks, bukan hanya angka.

Contoh hal yang dibaca sistem:

- apakah mood memburuk atau membaik;
- apakah ada kata tekanan seperti lelah, marah, cemas, kewalahan;
- apakah pengguna menulis pola yang berulang;
- apakah ada rencana pemulihan;
- apakah ada tag burnout guru.

---

## 11. Analisis Burnout

Analisis membaca activity selesai, durasi aktual, intensity factor, mood, jurnal, burnout tags, dan self report jika ada.

Versi scoring:

```text
scoring-v2.5-edumindful
```

Periode:

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
| Kuning | 40 - 69.99 | Ada tanda perlu jeda atau pemulihan |
| Merah | 70 - 100 | Beban/tekanan tinggi dan perlu perhatian |

Catatan perhitungan:

- mood positif seperti senang ke senang tidak otomatis menaikkan risiko wellbeing;
- activity positif tetap masuk riwayat dan workload jika memang memakai waktu/energi;
- risk floor tidak dibuat angka kaku, tetapi menyesuaikan faktor dominan dan journal score;
- FastAPI dapat membantu scoring dan rekomendasi;
- Laravel tetap punya fallback rule jika ML service tidak mengembalikan hasil.

---

## 12. Rekomendasi Analisis

Rekomendasi utama saat ini dibuat sebagai rekomendasi harian/periode, bukan rekomendasi utama per activity di tampilan Home dan Screen Analisis.

Prinsip terbaru:

- Home Analisis dan Screen Analisis memakai sumber rekomendasi yang sama;
- rekomendasi berasal dari preview/snapshot harian yang valid;
- jika user menekan tombol Analisis dan snapshot masih sesuai data activity terbaru, preview akan memakai snapshot itu;
- jika belum ada skor harian, Home tidak memakai rekomendasi lama dari hari/periode lain;
- activity review tetap membantu membuat narasi kondisi, tetapi saran teknik utama mengikuti kesimpulan harian;
- kesimpulan menjelaskan kondisi berdasarkan seluruh activity dalam periode, mood, jurnal, workload, dan faktor dominan.

Isi rekomendasi:

- headline;
- action;
- practice title;
- practice;
- analysis review;
- reason;
- codes;
- tactic reference jika tersedia.

Contoh mapping rekomendasi:

| Kondisi Dominan | Teknik Yang Bisa Disarankan |
|---|---|
| Butuh jeda cepat, impulsif, marah | Teknik STOP |
| Cemas, panik, kewalahan | Grounding 3-2-1 |
| Tegang, sulit tenang | Napas 4-7-8 |
| Tekanan ringan, transisi aktivitas | Jeda Napas 3 Menit |
| Stabil/hijau dan butuh maintenance | Awareness of Breathing |
| Sulit fokus | Mindful Breathing atau Focused Attention |
| Lelah tubuh | Body Scan Meditation |
| Banyak pikiran | Sitting Meditation atau Open Monitoring |
| Tubuh kaku/activity padat | Mindful Movement |
| Butuh jeda aktif | Walking Meditation |
| Emosi berat, sedih, marah, frustrasi | RAIN atau Loving-Kindness |
| Emosi naik turun | Mountain Meditation |
| Waktu terbatas | Informal Mindfulness |
| Perlu membaca pola harian | Jurnal Reflektif Harian |

---

## 13. Toolkit Mindfulness

Toolkit berisi teknik mindfulness yang bisa dibuka dari aplikasi. Teknik memiliki knowledge, durasi, step, timer, TTS jika perangkat mendukung, bookmark, dan evaluasi setelah latihan.

Teknik utama:

| No | Teknik | Fungsi |
|---:|---|---|
| 1 | Mindful Breathing | Kembali ke napas sebagai anchor |
| 2 | Focused Attention Meditation | Melatih fokus pada satu objek |
| 3 | Body Scan Meditation | Membaca sensasi tubuh |
| 4 | Sitting Meditation | Duduk sadar dengan napas, tubuh, suara, pikiran, dan emosi |
| 5 | Mindful Movement / Hatha Yoga | Gerakan ringan dengan kesadaran tubuh |
| 6 | Walking Meditation | Jeda aktif dengan berjalan sadar |
| 7 | Open Monitoring | Mengamati pikiran, suara, emosi, dan sensasi |
| 8 | Mindfulness of Sounds | Grounding melalui suara |
| 9 | Loving-Kindness Meditation | Melatih kebaikan pada diri dan orang lain |
| 10 | Mountain Meditation | Melatih stabilitas menghadapi perubahan |
| 11 | Informal Mindfulness | Latihan mindfulness dalam aktivitas sehari-hari |

Teknik tambahan:

| No | Teknik | Fungsi |
|---:|---|---|
| 12 | Teknik STOP | Jeda cepat sebelum bereaksi |
| 13 | Grounding 3-2-1 | Kembali ke lingkungan nyata |
| 14 | Napas 4-7-8 | Menenangkan tubuh lewat pola napas |
| 15 | Jeda Napas 3 Menit | Transisi singkat antar aktivitas |
| 16 | Awareness of Breathing | Menjaga perhatian pada napas natural |
| 17 | RAIN | Mengenali dan merawat emosi berat |
| 18 | Jurnal Reflektif Harian | Membaca pola hari dan rencana lembut |

Informal Mindfulness dapat dipahami sebagai latihan yang dipecah menjadi:

- Mindful Drinking;
- Mindful Eating;
- Mindful Walking to Class.

---

## 14. Observasi Siswa

Observasi siswa tersedia untuk guru dari activity kelas.

Alur:

```text
Guru membuat activity mengajar
  -> siswa join activity
  -> guru check-in
  -> siswa check-in
  -> guru check-out
  -> siswa check-out dan isi jurnal
  -> guru membuka observasi siswa
```

Data yang dilihat guru:

- nama siswa;
- status activity siswa;
- mood check-in siswa;
- alasan check-in siswa;
- mood check-out siswa;
- jurnal siswa;
- ringkasan kondisi siswa pada activity tersebut.

Batasan:

- guru hanya melihat siswa yang join activity kelas miliknya;
- guru tidak melihat activity pribadi siswa yang tidak terkait kelas;
- guru dari sekolah lain tidak dapat melihat observasi tersebut.

---

## 15. Parent Monitoring

Parent memantau anak yang sudah terhubung.

Cara menghubungkan anak:

```text
Siswa membuka profil
  -> siswa melihat/menyalin kode parent
  -> parent memasukkan kode siswa
  -> parent memilih sekolah anak
  -> sistem validasi
  -> anak terhubung
```

Data yang dilihat parent:

- daftar anak;
- activity anak per tanggal;
- mood check-in;
- mood check-out;
- analisis burnout anak;
- rekomendasi pendampingan.

Batasan:

- parent tidak membuat activity anak;
- parent tidak mengedit jurnal anak;
- parent tidak melihat siswa lain;
- parent hanya melihat anak yang sudah terhubung.

---

## 16. Manual Guide Per Role

### 16.1 Video Perkenalan

Tampilkan:

- landing page;
- tujuan aplikasi;
- role pengguna;
- alur besar sistem;
- cuplikan aplikasi mobile;
- cuplikan admin panel;
- analisis dan toolkit.

### 16.2 Video Super Admin

Tampilkan:

- login admin panel;
- review pendaftaran sekolah;
- approve sekolah;
- membuat admin sekolah;
- monitoring data lintas sekolah;
- melihat activity dan analisis.

### 16.3 Video Admin Sekolah

Tampilkan:

- login admin sekolah;
- profil sekolah;
- CRUD kelas;
- approve guru/siswa;
- CRUD guru/siswa/parent sekolah sendiri;
- monitoring activity dan analisis sekolah sendiri.

### 16.4 Video Guru

Tampilkan:

- register guru;
- menunggu approval;
- login;
- activity pribadi;
- activity mengajar;
- check-in;
- check-out dan jurnal;
- analisis;
- toolkit;
- observasi siswa.

### 16.5 Video Siswa

Tampilkan:

- register siswa;
- pilih sekolah dan kelas;
- menunggu approval;
- activity pribadi;
- join activity kelas;
- check-in/check-out;
- jurnal;
- analisis;
- toolkit;
- kode parent.

### 16.6 Video Parent

Tampilkan:

- register/login parent;
- hubungkan anak;
- pilih tanggal;
- lihat activity anak;
- lihat mood anak;
- lihat analisis dan rekomendasi pendampingan.

---

## 17. Fungsi Utama Sistem

| Fungsi | Penjelasan |
|---|---|
| School registration | Sekolah daftar dari website dan menunggu approval |
| Role-based access | Setiap role punya akses dan scope data berbeda |
| User approval | Guru/siswa harus approved sebelum login |
| CRUD sekolah | Super admin mengelola sekolah dan admin sekolah |
| CRUD user sekolah | Admin sekolah mengelola guru, siswa, parent sekolahnya |
| Class management | Kelas dipakai untuk scope activity kelas |
| Activity tracking | Mencatat rencana dan realisasi aktivitas |
| Mood tracking | Mencatat mood sebelum dan sesudah activity |
| Journal reflection | Membaca kejadian, perasaan, pola, dan rencana |
| Burnout analysis | Menghitung workload dan wellbeing |
| Recommendation | Memberikan saran mindfulness harian/periode |
| Toolkit mindfulness | Menjalankan guided practice |
| Student observation | Guru melihat kondisi siswa pada activity kelas |
| Parent monitoring | Parent memantau anak yang terhubung |
| Login history | Riwayat login dan single active session |
| Reminder | Notifikasi lokal untuk harian/check-in/check-out |

---

## 18. Checklist QA Sistem Saat Ini

```text
[ ] Website publik bisa dibuka
[ ] Download APK berjalan
[ ] Sekolah bisa daftar
[ ] Nested wilayah provinsi/kota/kecamatan berjalan
[ ] Super admin bisa approve sekolah
[ ] Super admin bisa membuat admin sekolah
[ ] Admin sekolah hanya melihat sekolah sendiri
[ ] Admin sekolah bisa CRUD guru/siswa/parent sekolahnya
[ ] Guru register dan pending
[ ] Siswa register dan pending
[ ] Admin sekolah approve guru/siswa sesuai sekolah
[ ] Approval tidak mengirim email otomatis
[ ] Sekolah di lengkapi akun tidak bisa diganti sembarangan
[ ] Guru bisa membuat activity mengajar
[ ] Siswa bisa join activity kelas sesuai kelas/sekolah
[ ] Check-in/check-out berjalan sesuai aturan guru-siswa
[ ] Jurnal tersimpan
[ ] Analisis harian berjalan
[ ] Analisis mingguan berjalan
[ ] Analisis bulanan berjalan
[ ] Home Analisis dan Screen Analisis menampilkan rekomendasi yang sama
[ ] Toolkit bisa dibuka
[ ] Guided practice step-by-step berjalan
[ ] Avatar animasi tampil pada teknik yang sudah punya asset
[ ] Parent bisa link anak
[ ] Parent melihat monitoring anak
```

---

## 19. Ringkasan Akhir

MindfulEdu saat ini adalah sistem terpadu untuk:

```text
pendaftaran sekolah
  -> approval sekolah
  -> manajemen admin sekolah
  -> manajemen kelas dan user
  -> register dan approval guru/siswa
  -> activity tracking
  -> mood dan jurnal
  -> analisis burnout
  -> rekomendasi mindfulness harian
  -> guided practice
  -> observasi siswa
  -> parent monitoring
```

Nilai utama sistem adalah menghubungkan aktivitas harian, kondisi emosional, refleksi pengguna, dan latihan mindfulness dalam satu alur yang dapat dipahami oleh sekolah, guru, siswa, dan parent.
