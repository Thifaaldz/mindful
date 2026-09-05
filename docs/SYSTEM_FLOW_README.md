# README Alur Sistem MindfulEdu

Dokumen ini menjelaskan alur sistem MindfulEdu pada kondisi aplikasi saat ini. Fokus dokumen ini adalah alur kerja sistem, fungsi setiap role, hubungan antar fitur, dan bagaimana data mengalir dari aplikasi mobile ke backend Laravel, service AI Python/FastAPI, lalu kembali ke pengguna.

Dokumen ini dapat digunakan sebagai acuan untuk:

- memahami flow utama aplikasi;
- menjelaskan fungsi role guru, siswa, dan orang tua;
- memahami workflow activity, check-in, check-out, analisis burnout, rekomendasi, dan toolkit;
- membantu developer baru memahami sistem tanpa membaca seluruh source code terlebih dahulu;
- menjadi dokumen pendukung presentasi, skripsi, atau dokumentasi produk.

---

## 1. Gambaran Umum Sistem

MindfulEdu adalah aplikasi pemantauan aktivitas dan kondisi pengguna berbasis jurnal refleksi, analisis burnout, dan rekomendasi latihan mindfulness.

Sistem memiliki tiga jenis pengguna:

1. Guru
2. Siswa
3. Orang tua

Masing-masing role memiliki flow, batas akses, tampilan, dan fungsi yang berbeda.

Secara teknis, sistem terdiri dari:

| Komponen | Fungsi |
|---|---|
| Flutter Mobile App | Antarmuka utama pengguna guru, siswa, dan orang tua |
| Laravel Backend | Pusat autentikasi, role access, data aktivitas, jurnal, analisis, dan admin |
| Python/FastAPI AI Service | Pendukung analisis burnout dan rekomendasi mindfulness |
| MariaDB | Penyimpanan data utama |
| Filament Admin Panel | Dashboard admin untuk monitoring data |
| Website Landing Page | Halaman publik dan download APK |

---

## 2. Prinsip Utama Arsitektur

Prinsip sistem MindfulEdu:

1. Laravel menjadi pusat kendali utama.
2. Flutter hanya menjadi client aplikasi mobile.
3. Python/FastAPI hanya menangani analisis dan rekomendasi AI.
4. Semua data tetap disimpan dan dikelola di Laravel/MariaDB.
5. Role access dijaga agar data guru, siswa, dan orang tua tidak bercampur.
6. Hasil analisis disimpan sebagai snapshot agar tidak selalu memanggil AI ulang.
7. Rekomendasi latihan mindfulness harus mengarah ke teknik yang tersedia di sistem.
8. Aplikasi tidak menampilkan rumus teknis internal kepada pengguna umum.

---

## 3. Alur Besar Sistem

Alur umum MindfulEdu:

```text
Pengguna membuka aplikasi
  -> memilih role
  -> login atau register
  -> melengkapi profil
  -> membuat atau mengikuti aktivitas
  -> check-in sebelum aktivitas
  -> menjalankan aktivitas
  -> check-out dan menulis jurnal
  -> sistem melakukan review jurnal
  -> sistem membuat analisis burnout
  -> sistem memberikan rekomendasi teknik mindfulness
  -> pengguna menjalankan latihan mindfulness
  -> pengguna mengisi evaluasi latihan
  -> history tersimpan
```

Alur data teknis:

```text
Flutter App
  -> Laravel API
  -> MariaDB
  -> Python/FastAPI AI Service jika perlu analisis AI
  -> Laravel menyimpan hasil analisis
  -> Flutter menampilkan hasil ke pengguna
```

---

## 4. Role Dalam Sistem

### 4.1 Guru

Guru adalah pengguna yang berfokus pada:

- pencatatan aktivitas mengajar dan non-mengajar;
- check-in kondisi sebelum aktivitas;
- check-out dan jurnal setelah aktivitas;
- analisis burnout pribadi;
- membuat activity mengajar untuk siswa;
- melihat observasi siswa pada activity kelas;
- memakai toolkit mindfulness;
- menerima rekomendasi teknik mindfulness.

Menu guru:

| Menu | Fungsi |
|---|---|
| Beranda | Ringkasan aktivitas, status, dan shortcut |
| Aktivitas | Membuat, mengedit, membatalkan, check-in, check-out activity |
| Analisis | Melihat analisis harian, mingguan, bulanan |
| Toolkit | Membuka pengetahuan dan latihan mindfulness |
| Profil | Edit profil, avatar, reminder, login history, logout |

Tema guru menggunakan warna hijau.

### 4.2 Siswa

Siswa adalah pengguna yang berfokus pada:

- pencatatan aktivitas belajar pribadi;
- mengikuti activity kelas dari guru;
- check-in sebelum belajar;
- check-out dan jurnal setelah belajar;
- analisis burnout siswa;
- rekomendasi teknik mindfulness;
- toolkit mindfulness;
- kode verifikasi untuk orang tua.

Menu siswa:

| Menu | Fungsi |
|---|---|
| Beranda | Ringkasan aktivitas siswa |
| Aktivitas | Membuat aktivitas pribadi dan join aktivitas kelas guru |
| Analisis | Melihat analisis burnout siswa |
| Toolkit | Membuka pengetahuan dan latihan mindfulness |
| Profil | Edit profil, avatar, sekolah, kelas, kode parent, reminder, logout |

Tema siswa menggunakan warna biru.

### 4.3 Orang Tua

Orang tua adalah pengguna yang berfokus pada monitoring anak.

Orang tua dapat:

- login/register sebagai parent;
- menghubungkan akun anak memakai kode verifikasi siswa;
- melihat aktivitas anak;
- melihat check-in dan check-out anak;
- melihat analisis anak;
- melihat rekomendasi pendampingan.

Menu orang tua:

| Menu | Fungsi |
|---|---|
| Anak | Dashboard monitoring anak |
| Profil | Edit profil, hubungkan anak, login history, logout |

Tema orang tua menggunakan warna cokelat/oranye lembut.

---

## 5. Alur Auth dan Akses Role

### 5.1 Pilih Role

Sebelum login, pengguna memilih akses:

```text
Guru
Siswa
Orang Tua
```

Pilihan role menentukan:

- form login/register;
- tema warna;
- halaman setelah login;
- API yang boleh diakses;
- menu navigasi;
- data yang boleh ditampilkan.

### 5.2 Register Email

Alur register email:

```text
Pilih role
  -> isi email dan password
  -> isi data role tertentu jika diperlukan
  -> Laravel validasi data
  -> Laravel membuat user
  -> Laravel assign role
  -> Laravel membuat token login
  -> Flutter masuk ke shell sesuai role
```

Data utama register:

| Field | Guru | Siswa | Orang Tua |
|---|---:|---:|---:|
| Nama | Opsional | Opsional | Opsional |
| Email | Wajib | Wajib | Wajib |
| Password | Wajib | Wajib | Wajib |
| Konfirmasi password | Wajib | Wajib | Wajib |
| Sekolah | Bisa dilengkapi nanti | Bisa dilengkapi nanti | Wajib untuk link anak |
| Kelas | Tidak wajib | Bisa dilengkapi nanti | Tidak digunakan |
| Kode siswa | Tidak digunakan | Dibuat sistem | Dipakai untuk link anak |

### 5.3 Login Email

Alur login email:

```text
Pilih role
  -> isi email dan password
  -> Laravel cek kredensial
  -> Laravel cek apakah role akun sesuai
  -> Laravel hapus token lama user
  -> Laravel buat token baru
  -> Laravel simpan login history
  -> Flutter masuk sesuai role
```

Jika pengguna memilih role yang salah, login ditolak.

Contoh:

```text
Akun guru tidak bisa login melalui akses siswa.
Akun siswa tidak bisa login melalui akses guru.
Akun parent tidak bisa login melalui akses guru atau siswa.
```

### 5.4 Google Sign-In

Alur Google Sign-In:

```text
Pilih role
  -> pilih login/register dengan Google
  -> Flutter meminta token Google
  -> Laravel validasi token Google
  -> Laravel cek atau membuat akun
  -> Laravel assign role jika akun baru
  -> Laravel cek role jika akun lama
  -> Laravel membuat token Sanctum
  -> Flutter masuk sesuai role
```

### 5.5 Quick Login PIN/Biometrik

Jika pengguna mengaktifkan simpan akun:

```text
Token dan ringkasan akun disimpan aman di perangkat
  -> user membuka app kembali
  -> user memilih role yang sama
  -> user menggunakan PIN/biometrik
  -> app memakai token tersimpan
  -> jika token masih valid, user masuk
```

Jika token sudah dicabut karena login di perangkat lain, aplikasi meminta login ulang.

### 5.6 Single Active Session

Sistem menjaga agar satu akun hanya aktif pada satu perangkat.

Alurnya:

```text
User login di perangkat A
  -> token A aktif
User login di perangkat B
  -> Laravel menghapus token lama
  -> token B aktif
Perangkat A mengakses API
  -> token A tidak valid
  -> app otomatis keluar atau menampilkan pesan sesi dipindahkan
```

Login history menyimpan:

- role;
- device id;
- device name;
- device brand;
- device model;
- platform;
- IP address;
- lokasi default;
- waktu login;
- apakah sesi lama dicabut.

---

## 6. Alur Profil

### 6.1 Profil Guru

Alur profil guru:

```text
Guru masuk aplikasi
  -> buka Profil
  -> isi nama
  -> isi sekolah
  -> upload avatar
  -> data disimpan ke Laravel
```

Sekolah guru penting untuk activity kelas. Siswa hanya dapat melihat activity guru jika sekolahnya sama.

### 6.2 Profil Siswa

Alur profil siswa:

```text
Siswa masuk aplikasi
  -> buka Profil
  -> isi nama
  -> isi sekolah
  -> isi kelas
  -> upload avatar
  -> salin kode parent jika diperlukan
```

Kode parent/kode verifikasi siswa digunakan agar orang tua bisa menghubungkan akun.

### 6.3 Profil Orang Tua

Alur profil orang tua:

```text
Orang tua masuk aplikasi
  -> buka Profil
  -> isi data orang tua
  -> masukkan kode siswa
  -> masukkan sekolah anak
  -> Laravel validasi kode dan sekolah
  -> akun parent terhubung ke siswa
```

Jika sekolah tidak sama, relasi tidak dibuat.

---

## 7. Alur Activity

Activity adalah data inti yang menghubungkan jadwal, check-in, check-out, jurnal, analisis, dan rekomendasi.

### 7.1 Status Activity

| Status | Arti |
|---|---|
| planned | Activity dibuat, belum check-in |
| checked_in | User sudah check-in |
| completed | User sudah check-out |
| cancelled | Activity dibatalkan |

### 7.2 Form Activity

Form activity berisi:

| Field | Fungsi |
|---|---|
| Nama kegiatan | Judul activity |
| Tanggal mulai | Tanggal activity |
| Pengulangan | Sekali, mingguan, bulanan |
| Ulang sampai | Batas pengulangan |
| Jam mulai | Jadwal mulai activity |
| Jam selesai | Jadwal selesai activity |
| Jenis activity | Kategori sesuai role |
| Jenis activity lainnya | Input bebas jika memilih Lainnya |
| Target kelas | Khusus guru saat memilih Mengajar |

### 7.3 Activity Guru

Jenis activity guru:

| Kode | Nama |
|---|---|
| teaching | Mengajar |
| meeting | Rapat |
| administration | Administrasi |
| grading | Koreksi |
| preparation | Persiapan materi |
| break | Istirahat |
| other | Lainnya |

Jika guru memilih `teaching`, activity bisa menjadi activity kelas.

### 7.4 Activity Siswa

Jenis activity siswa:

| Kode | Nama |
|---|---|
| class_learning | Belajar di kelas |
| group_study | Belajar bersama |
| assignment | Tugas/PR |
| exam | Ujian/Ulangan |
| extracurricular | Ekstrakurikuler |
| break | Istirahat |
| other | Lainnya |

Siswa bisa membuat activity pribadi dan juga join activity kelas dari guru.

### 7.5 Activity Type

Sistem memiliki tiga tipe activity:

| Type | Penjelasan |
|---|---|
| personal | Activity pribadi guru atau siswa |
| classroom | Activity mengajar yang dibuat guru |
| classroom_student | Activity siswa hasil join dari activity guru |

### 7.6 Alur Buat Activity Pribadi

```text
User membuka menu Aktivitas
  -> klik tambah
  -> isi nama, tanggal, jam, jenis
  -> simpan
  -> Flutter mengirim POST /activities
  -> Laravel membuat activity
  -> activity muncul di list
  -> reminder check-in/check-out dijadwalkan jika jam tersedia
```

### 7.7 Alur Edit Activity

```text
User membuka activity
  -> klik edit
  -> ubah data
  -> simpan
  -> Flutter mengirim PUT /activities/{id}
  -> Laravel update data activity
  -> Flutter mengganti card lama dengan data terbaru
```

### 7.8 Alur Cancel Activity

```text
User membuka activity
  -> klik cancel
  -> Laravel mengubah status menjadi cancelled
  -> activity tidak dihitung sebagai completed
  -> list diperbarui sesuai filter
```

### 7.9 Alur Duplicate Activity

```text
User memilih duplicate
  -> memilih tanggal baru
  -> Laravel membuat activity baru dari data lama
  -> status kembali planned
  -> check-in/check-out lama tidak ikut disalin
```

### 7.10 Alur Repeat Activity

Saat membuat activity, user bisa memilih:

- sekali;
- mingguan;
- bulanan.

Alurnya:

```text
User memilih repeat mingguan/bulanan
  -> user memilih tanggal akhir
  -> Flutter menghitung estimasi jumlah activity
  -> Laravel membuat beberapa activity
  -> Laravel melewati data yang dianggap duplikat
  -> response memberi jumlah created dan skipped
```

---

## 8. Alur Check-In

Check-in adalah pencatatan kondisi sebelum activity dimulai.

### 8.1 Form Check-In

| Field | Wajib | Keterangan |
|---|---:|---|
| Mood | Opsional | Senang, tenang, cemas, sedih, marah |
| Intensitas | Wajib jika mood dipilih | Skala 1 sampai 10 |
| Kenapa | Opsional | Pemicu kondisi sebelum activity |

### 8.2 Alur Check-In Normal

```text
User membuka activity planned
  -> klik Check-in
  -> pilih mood
  -> pilih intensitas
  -> isi alasan jika perlu
  -> simpan
  -> Laravel menyimpan checkin_at, mood, intensity, trigger
  -> status activity menjadi checked_in
  -> activity event dicatat
```

### 8.3 Output Check-In

Setelah check-in:

- status activity berubah;
- waktu check-in tersimpan;
- mood awal tersimpan;
- trigger awal tersimpan;
- activity masuk ledger;
- card activity diperbarui di aplikasi.

---

## 9. Alur Check-Out dan Jurnal

Check-out adalah pencatatan kondisi setelah activity selesai.

### 9.1 Form Check-Out

| Field | Wajib | Keterangan |
|---|---:|---|
| Mood | Opsional | Mood setelah activity |
| Apa yang terjadi tadi? | Minimal salah satu dengan perasaan | Fakta kejadian |
| Bagaimana perasaanmu soal itu? | Minimal salah satu dengan fakta | Respons emosional |
| Pola yang kamu sadari | Opsional | Pola yang berulang |
| Rencana ke depan | Opsional | Langkah berikutnya |
| Tandai jika terasa | Opsional, khusus guru | Dimensi burnout |

### 9.2 Alur Check-Out

```text
User membuka activity checked_in
  -> klik Check-out
  -> isi mood setelah activity
  -> isi fakta/perasaan
  -> isi pola dan rencana jika ada
  -> guru dapat memilih tag burnout manual
  -> simpan
  -> Laravel menyimpan jurnal
  -> Laravel menjalankan review jurnal
  -> Laravel menyimpan hasil review
  -> status activity menjadi completed
```

### 9.3 Output Check-Out

Setelah check-out:

- checkout_at tersimpan;
- actual_hours dihitung;
- jurnal tersimpan;
- mood detected dapat muncul;
- suggestion/review muncul;
- burnout tag otomatis dapat muncul;
- recommendation technique dapat muncul;
- activity dihitung dalam analisis.

---

## 10. Alur Activity Kelas Guru dan Siswa

Activity kelas menghubungkan guru dan siswa.

### 10.1 Guru Membuat Activity Mengajar

Alur:

```text
Guru membuka Aktivitas
  -> tambah activity
  -> memilih jenis Mengajar
  -> mengisi target kelas atau mengosongkan
  -> simpan
  -> Laravel membuat activity_type classroom
```

Aturan target kelas:

| Kondisi | Dampak |
|---|---|
| Target kelas kosong | Semua siswa di sekolah yang sama bisa join |
| Target kelas diisi | Hanya siswa dengan kelas yang sama bisa join |
| Sekolah berbeda | Siswa tidak bisa melihat/join |

### 10.2 Siswa Mencari Activity Kelas

Alur:

```text
Siswa membuka menu Aktivitas
  -> klik cari kelas dari guru
  -> Flutter meminta daftar activity available
  -> Laravel mencari activity classroom yang sesuai sekolah/kelas
  -> siswa memilih activity
  -> siswa klik join
```

### 10.3 Siswa Join Activity Kelas

Saat siswa join:

```text
Laravel membuat activity baru milik siswa
  -> activity_type = classroom_student
  -> teacher_activity_id terisi
  -> jadwal mengikuti activity guru
  -> class mengikuti target activity guru jika ada
```

### 10.4 Aturan Check-In Siswa

Siswa tidak bisa check-in sebelum guru check-in.

Alurnya:

```text
Siswa klik check-in activity kelas
  -> Laravel cek teacher_activity_id
  -> Laravel cek apakah teacher activity sudah checkin_at
  -> jika belum, request ditolak
  -> jika sudah, siswa boleh check-in
```

Pesan kondisi:

```text
Menunggu guru melakukan check-in.
```

### 10.5 Aturan Check-Out Siswa

Siswa tidak bisa check-out sebelum guru check-out.

Alurnya:

```text
Siswa klik check-out activity kelas
  -> Laravel cek teacher activity
  -> Laravel cek apakah teacher activity sudah checkout_at
  -> jika belum, request ditolak
  -> jika sudah, siswa boleh check-out
```

Pesan kondisi:

```text
Menunggu guru melakukan check-out.
```

### 10.6 Guru Melihat Observasi Siswa

Alur:

```text
Guru membuka activity classroom
  -> klik Observasi siswa
  -> Laravel mengambil semua activity siswa yang join
  -> Laravel mengirim data check-in, check-out, dan analisis siswa
  -> Flutter menampilkan daftar observasi
```

Data observasi:

- nama siswa;
- kelas siswa;
- status activity siswa;
- mood check-in;
- mood check-out;
- mood detected;
- status analisis;
- rekomendasi.

---

## 11. Alur Parent Monitoring

### 11.1 Hubungkan Anak

Alur:

```text
Siswa membuka Profil
  -> siswa menyalin kode parent
  -> kode diberikan ke orang tua
  -> orang tua register/login sebagai parent
  -> orang tua memasukkan kode siswa dan sekolah
  -> Laravel validasi kode
  -> Laravel validasi sekolah
  -> parent_student_links dibuat
```

Jika kode tidak ditemukan, request ditolak.

Jika sekolah berbeda, request ditolak.

### 11.2 Dashboard Orang Tua

Alur:

```text
Parent membuka menu Anak
  -> Flutter meminta parent dashboard
  -> Laravel mengambil daftar anak terhubung
  -> Laravel mengambil activity anak sesuai tanggal
  -> Laravel mengambil analisis anak
  -> Flutter menampilkan monitoring
```

Data yang ditampilkan:

- daftar anak;
- sekolah anak;
- kelas anak;
- activity anak pada tanggal terpilih;
- mood check-in;
- mood check-out;
- guru terkait jika activity berasal dari kelas;
- status analisis;
- rekomendasi pendampingan.

Parent hanya memantau. Parent tidak membuat activity dan tidak mengubah jurnal anak.

---

## 12. Alur Analisis Burnout

Analisis burnout digunakan untuk memahami kondisi pengguna berdasarkan activity dan jurnal.

### 12.1 Jenis Periode

| Periode | Fungsi |
|---|---|
| daily | Analisis satu hari |
| weekly | Analisis satu minggu |
| monthly | Analisis satu bulan |

### 12.2 Data Masuk Analisis

Data yang digunakan:

- activity dalam periode;
- activity completed;
- planned hours;
- actual hours;
- mood check-in;
- mood check-out;
- check-in trigger;
- checkout fact;
- checkout feeling;
- checkout pattern;
- checkout plan;
- burnout tags manual;
- burnout tags otomatis;
- review jurnal per activity;
- rekomendasi teknik mindfulness;
- self report jika tersedia.

### 12.3 Alur Analisis Manual

```text
User membuka menu Analisis
  -> memilih Harian/Mingguan/Bulanan
  -> memilih tanggal/periode
  -> klik Jalankan Manual
  -> Flutter mengirim POST /burnout-analyses
  -> Laravel mengambil data activity dan jurnal
  -> Laravel cek snapshot/cache
  -> jika data sama, hasil lama dipakai
  -> jika data berubah, Laravel meminta bantuan AI service
  -> hasil disimpan ke burnout_analysis_snapshots
  -> Flutter menampilkan hasil
```

### 12.4 Alur Analisis Otomatis

Analisis juga dapat muncul otomatis dari:

- dashboard;
- parent dashboard;
- overview analisis;
- review activity setelah check-out.

Alurnya:

```text
Data activity/jurnal tersedia
  -> backend membuat preview/overview
  -> jika snapshot cocok, hasil lama dipakai
  -> jika perlu, sistem membuat analisis baru
```

### 12.5 Output Analisis

Output analisis meliputi:

- status akhir;
- skor risiko;
- jumlah activity dihitung;
- jumlah activity selesai;
- jumlah jurnal dihitung;
- faktor dominan;
- ringkasan periode;
- detail per activity;
- rekomendasi teknik;
- alasan rekomendasi;
- history snapshot.

### 12.6 Analisis Per Activity

Pada screen analisis, sistem menampilkan:

```text
Kesimpulan periode di bagian atas
  -> daftar activity yang dihitung
  -> review/detail masing-masing activity
  -> rekomendasi teknik per activity
  -> tombol membuka teknik
```

Tujuannya agar pengguna memahami:

- activity mana yang paling memengaruhi kondisi;
- kenapa status akhir muncul;
- latihan apa yang cocok untuk setiap kondisi;
- langkah pemulihan yang bisa dilakukan.

### 12.7 History Analisis

Setiap hasil analisis disimpan sebagai snapshot.

Manfaat:

- user dapat melihat riwayat;
- sistem tidak selalu memanggil AI ulang;
- analisis lama tetap bisa dibaca;
- token lebih hemat;
- performa lebih ringan.

---

## 13. Alur Review AI Activity

Review AI activity berjalan setelah check-out.

Alur:

```text
User check-out
  -> Laravel menyimpan jurnal
  -> Laravel mengirim konteks jurnal ke service analisis jika tersedia
  -> service mengembalikan review
  -> Laravel menyimpan mood detected, suggestion, tags, dan raw response
  -> Flutter menampilkan tombol Review AI
```

Isi review:

- ringkasan kondisi;
- mood terdeteksi;
- dimensi burnout yang mungkin muncul;
- saran penurunan beban;
- teknik mindfulness yang cocok;
- alasan teknik tersebut dipilih;
- tanda peringatan jika ada sinyal krisis.

Jika service AI tidak tersedia, sistem menggunakan fallback lokal.

---

## 14. Alur Rekomendasi Teknik Mindfulness

Rekomendasi teknik harus sesuai dengan teknik yang tersedia di sistem.

Alur:

```text
Jurnal dan activity dianalisis
  -> sistem membaca daftar teknik mindfulness
  -> AI memilih teknik paling sesuai
  -> jika AI tidak tersedia, fallback lokal memilih teknik
  -> hasil rekomendasi disimpan
  -> Flutter menampilkan tombol Buka Teknik Ini
```

Contoh:

```text
Activity memunculkan cemas dan banyak pikiran
  -> sistem merekomendasikan Sitting Meditation
  -> alasan: membantu menyadari pikiran dan emosi tanpa langsung bereaksi
```

---

## 15. Alur Toolkit Mindfulness

Toolkit adalah tempat pengguna belajar dan menjalankan teknik mindfulness.

### 15.1 Buka Toolkit

Alur:

```text
User membuka Toolkit
  -> Flutter meminta GET /toolkit/tactics
  -> Laravel mengambil mindful_tactics
  -> Flutter menampilkan daftar teknik
```

### 15.2 Baca Knowledge

Sebelum latihan, pengguna membaca:

- nama teknik;
- kategori;
- deskripsi;
- knowledge;
- cocok untuk kondisi apa;
- durasi;
- langkah latihan.

### 15.3 Mulai Latihan

Alur:

```text
User klik Mulai
  -> screen guided practice terbuka
  -> step pertama tampil
  -> timer berjalan
  -> TTS membacakan instruksi
  -> saat waktu step selesai, lanjut ke step berikutnya
  -> user bisa pause/resume/selesai
```

### 15.4 Evaluasi Latihan

Setelah latihan selesai:

```text
User memilih kondisi setelah latihan
  -> Jauh lebih baik
  -> Lebih baik
  -> Tidak berubah
  -> Masih lelah
  -> Lebih buruk
```

Setelah memilih evaluasi, user kembali ke halaman sebelumnya.

### 15.5 Teknik Yang Tersedia

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

---

## 16. Alur Reminder dan Notifikasi

Notifikasi pada aplikasi saat ini berjalan sebagai local notification di perangkat.

### 16.1 Reminder Harian

Alur:

```text
User membuka pengaturan reminder
  -> user aktifkan reminder
  -> user memilih jam
  -> Flutter menyimpan preferensi ke Laravel
  -> Flutter menjadwalkan notifikasi lokal harian
```

### 16.2 Reminder Activity

Jika activity memiliki jam:

| Reminder | Waktu |
|---|---|
| Check-in | 10 menit sebelum jam mulai |
| Check-out | Tepat pada jam selesai |

Alur:

```text
Activity dibuat atau diperbarui
  -> Flutter membaca start_at dan end_at
  -> Flutter menjadwalkan notifikasi check-in/check-out
  -> Android menampilkan notifikasi sesuai jadwal
```

Syarat:

- izin notifikasi Android aktif;
- jam perangkat benar;
- timezone perangkat benar;
- aplikasi tidak dibatasi battery optimization secara ekstrem;
- activity memiliki jam mulai atau jam selesai.

---

## 17. Alur Dashboard

### 17.1 Dashboard Guru

Dashboard guru menampilkan:

- ringkasan activity;
- jumlah planned;
- jumlah completed;
- status analisis;
- shortcut ke activity;
- shortcut ke analisis;
- shortcut ke toolkit;
- shortcut ke profil.

### 17.2 Dashboard Siswa

Dashboard siswa menampilkan:

- ringkasan activity siswa;
- activity selesai;
- status kondisi;
- shortcut activity;
- shortcut cari kelas;
- informasi activity kelas jika ada.

### 17.3 Dashboard Orang Tua

Dashboard orang tua menampilkan:

- daftar anak;
- aktivitas anak berdasarkan tanggal;
- check-in mood anak;
- check-out mood anak;
- guru terkait;
- analisis anak;
- rekomendasi pendampingan.

---

## 18. Alur Website

Website publik memiliki dua fungsi utama:

1. Memperkenalkan aplikasi MindfulEdu.
2. Menyediakan download APK Android.

Alur download:

```text
User membuka landing page
  -> user klik download
  -> browser menuju /download/android
  -> Laravel mencari file APK
  -> jika file ada, APK diunduh
  -> jika file tidak ada, server memberi 404
```

Lokasi file APK:

```text
src/public/downloads/mindfuledu.apk
```

---

## 19. Alur Admin Panel

Admin panel digunakan pengelola sistem.

Fungsi admin:

- melihat user;
- melihat role dan permission;
- mengelola class/sekolah;
- melihat activity;
- melihat ledger activity;
- melihat burnout analysis snapshot;
- melihat mindful tactics;
- melihat mindfulness sessions;
- melihat student observation;
- melihat badge;
- melihat login history;
- monitoring kondisi platform.

Admin panel tidak digunakan oleh user umum.

---

## 20. Endpoint API Utama

Base path:

```text
/api
```

### 20.1 Auth

| Method | Endpoint | Fungsi |
|---|---|---|
| POST | /register | Register email |
| POST | /login | Login email |
| POST | /auth/google | Login/register Google |
| POST | /logout | Logout |
| GET | /me | Ambil profil |
| PUT | /me/profile | Update profil |
| POST | /me/avatar | Upload avatar |

### 20.2 Activity

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /activities | List activity |
| POST | /activities | Buat activity |
| GET | /activities/{activity} | Detail activity |
| PUT | /activities/{activity} | Update activity |
| POST | /activities/{activity}/check-in | Check-in |
| POST | /activities/{activity}/check-out | Check-out dan jurnal |
| POST | /activities/{activity}/cancel | Cancel activity |
| POST | /activities/{activity}/duplicate | Duplicate activity |
| GET | /activities/{activity}/ledger | Ledger activity |

### 20.3 Classroom

| Method | Endpoint | Role | Fungsi |
|---|---|---|---|
| GET | /classroom/activities/available | Siswa | Cari activity kelas |
| POST | /classroom/activities/{activity}/join | Siswa | Join activity kelas |
| GET | /teacher/classroom-activities/{activity}/observations | Guru | Observasi siswa |

### 20.4 Analysis

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /burnout-analyses | History analisis |
| GET | /burnout-analyses/overview | Overview analisis |
| POST | /burnout-analyses | Jalankan analisis |
| POST | /burnout-self-reports | Simpan self report |

### 20.5 Toolkit

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /toolkit/tactics | List teknik mindfulness |
| GET | /toolkit/tactics/bookmarked | List bookmark |
| POST | /toolkit/tactics/{tactic}/bookmark | Toggle bookmark |

### 20.6 Parent

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /parent/dashboard | Dashboard parent |
| POST | /parent/children | Hubungkan anak |

### 20.7 Reminder

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | /reminder-preference | Ambil preferensi reminder |
| PUT | /reminder-preference | Update preferensi reminder |

---

## 21. Alur Data Database Utama

### 21.1 User dan Role

```text
users
  -> model_has_roles
  -> roles
```

User menyimpan profil dasar. Role menentukan akses guru, siswa, atau parent.

### 21.2 Siswa dan Kelas

```text
users.class_id
  -> classes.id
```

Siswa dapat memiliki kelas. Kelas dipakai untuk filter activity mengajar.

### 21.3 Parent dan Anak

```text
parent_student_links.parent_id
  -> users.id parent

parent_student_links.student_id
  -> users.id student
```

Relasi dibuat setelah kode siswa dan sekolah valid.

### 21.4 Activity dan Ledger

```text
activities
  -> activity_events
```

Activity menyimpan data utama. Activity events menyimpan riwayat tindakan.

### 21.5 Activity Guru dan Activity Siswa

```text
activities.id guru classroom
  -> activities.teacher_activity_id siswa classroom_student
```

Activity siswa hasil join selalu mengarah ke activity guru.

### 21.6 Analisis

```text
activities + journals
  -> burnout_analysis_snapshots
```

Snapshot menyimpan hasil analisis berdasarkan periode.

### 21.7 Toolkit

```text
mindful_tactics
  -> tactic_bookmarks
  -> mindfulness_sessions
```

Mindful tactics menyimpan teknik. Bookmark dan session menyimpan interaksi user dengan teknik.

---

## 22. Workflow Lengkap Per Role

### 22.1 Workflow Guru

```text
Guru register/login
  -> lengkapi profil sekolah
  -> buat activity
  -> jika mengajar, pilih target kelas atau kosongkan
  -> check-in sebelum activity
  -> siswa mulai bisa check-in jika activity kelas
  -> guru menjalankan activity
  -> guru check-out dan menulis jurnal
  -> siswa mulai bisa check-out jika activity kelas
  -> sistem review jurnal guru
  -> sistem analisis burnout guru
  -> guru melihat rekomendasi teknik
  -> guru membuka toolkit
  -> guru melihat observasi siswa jika activity kelas
```

Output guru:

- daftar activity;
- jurnal per activity;
- review activity;
- status burnout;
- rekomendasi teknik mindfulness;
- observasi siswa;
- history analisis.

### 22.2 Workflow Siswa

```text
Siswa register/login
  -> lengkapi profil sekolah dan kelas
  -> buat activity pribadi atau cari kelas guru
  -> join activity kelas
  -> menunggu guru check-in jika activity kelas
  -> check-in
  -> mengikuti activity
  -> menunggu guru check-out jika activity kelas
  -> check-out dan menulis jurnal
  -> sistem review jurnal siswa
  -> sistem analisis burnout siswa
  -> siswa mendapat rekomendasi teknik
  -> siswa membuka toolkit
  -> siswa membagikan kode parent jika perlu
```

Output siswa:

- daftar activity pribadi;
- daftar activity kelas yang diikuti;
- jurnal siswa;
- review activity;
- status burnout siswa;
- rekomendasi teknik mindfulness;
- kode parent;
- history analisis.

### 22.3 Workflow Orang Tua

```text
Parent register/login
  -> masukkan kode siswa dan sekolah
  -> sistem menghubungkan parent dengan siswa
  -> parent membuka dashboard anak
  -> parent memilih tanggal
  -> parent melihat activity anak
  -> parent melihat mood check-in/check-out anak
  -> parent membaca analisis anak
  -> parent melihat rekomendasi pendampingan
```

Output parent:

- daftar anak terhubung;
- aktivitas anak;
- check-in/check-out anak;
- hasil analisis anak;
- rekomendasi pendampingan.

---

## 23. Kondisi Penting dan Aturan Sistem

### 23.1 Role Tidak Boleh Tertukar

Setiap akun hanya boleh masuk melalui role yang sesuai.

### 23.2 Siswa Harus Satu Sekolah

Activity kelas hanya dapat diakses siswa dari sekolah yang sama dengan guru.

### 23.3 Target Kelas Membatasi Activity

Jika guru mengisi target kelas, hanya siswa dari kelas tersebut yang dapat join.

### 23.4 Guru Mengontrol Waktu Check-In/Check-Out Kelas

Untuk activity kelas:

- siswa tidak bisa check-in sebelum guru check-in;
- siswa tidak bisa check-out sebelum guru check-out.

### 23.5 Activity Completed Menjadi Sumber Analisis Utama

Activity yang sudah check-out memiliki jurnal dan lebih kuat untuk dianalisis.

### 23.6 Snapshot Mencegah AI Berjalan Berulang

Jika data tidak berubah, analisis lama bisa digunakan ulang.

### 23.7 Reminder Berjalan di Perangkat

Notifikasi jadwal activity dan reminder harian dijalankan oleh mobile app, bukan server push.

---

## 24. Ringkasan Output Sistem

MindfulEdu menghasilkan beberapa output utama:

| Output | Sumber | Dilihat Oleh |
|---|---|---|
| Activity list | Input user | Guru, siswa |
| Check-in mood | Form check-in | Guru, siswa, parent untuk anak |
| Check-out journal | Form check-out | Guru, siswa, parent untuk anak |
| Review activity | Jurnal dan AI/fallback | Guru, siswa |
| Observasi siswa | Activity kelas | Guru |
| Analisis burnout | Activity dan jurnal | Guru, siswa, parent untuk anak |
| Rekomendasi teknik | Analisis dan toolkit | Guru, siswa, parent sebagai saran |
| Guided practice | Toolkit | Guru, siswa |
| Login history | Auth | Semua role di profil |
| APK download | Website | Publik |

---

## 25. Ringkasan Akhir

MindfulEdu berjalan dengan alur:

```text
Role-based access
  -> activity tracking
  -> mood check-in
  -> reflective check-out journal
  -> journal review
  -> burnout analysis
  -> mindfulness recommendation
  -> guided mindfulness practice
  -> evaluation and history
```

Guru menggunakan sistem untuk memahami kondisi diri dan melihat observasi siswa.

Siswa menggunakan sistem untuk memahami kondisi belajar, emosi, dan kebutuhan pemulihan.

Orang tua menggunakan sistem untuk memantau perkembangan anak dan memberi dukungan yang lebih tepat.

Laravel menjadi pusat pengelolaan data, Flutter menjadi aplikasi pengguna, Python/FastAPI menjadi pendukung analisis dan rekomendasi, dan website menjadi pintu publik untuk pengenalan aplikasi serta download APK.
