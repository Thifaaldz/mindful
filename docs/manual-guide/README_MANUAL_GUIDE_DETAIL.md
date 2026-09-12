# README Manual Guide Video Detail MindfulEdu

Dokumen ini adalah rancangan manual guide video MindfulEdu secara lengkap. Fokusnya adalah apa yang perlu ditampilkan di layar, urutan rekaman, narasi yang bisa dibacakan, dan fungsi yang harus dijelaskan untuk setiap role.

Dokumen ini berbeda dari README perkenalan sistem. File ini khusus untuk kebutuhan membuat video panduan penggunaan aplikasi.

Untuk knowledge aplikasi terbaru, gunakan juga:

```text
docs/manual-guide/README_KNOWLEDGE_APLIKASI_TERBARU.md
```

---

## 1. Tujuan Manual Guide

Manual guide dibuat agar pengguna baru memahami cara memakai MindfulEdu dari awal sampai akhir.

Target penonton:

- pihak sekolah yang ingin mendaftarkan sekolah;
- super admin yang mengelola seluruh sekolah;
- admin sekolah yang mengelola guru, siswa, parent, kelas, dan approval;
- guru yang mencatat activity dan memantau kondisi siswa;
- siswa yang mencatat activity, jurnal, analisis, dan mindfulness;
- parent yang memantau anak;
- penguji, dosen, atau stakeholder yang ingin melihat flow sistem.

Status terbaru yang harus disebutkan dalam video:

- rekomendasi di Home Analisis dan Screen Analisis sudah satu sumber;
- rekomendasi utama memakai kesimpulan harian/periode, bukan rekomendasi utama per activity;
- admin sekolah hanya mengelola user sekolahnya sendiri;
- approval guru/siswa tidak mengirim email otomatis;
- sekolah pada proses lengkapi akun dibuat terkunci jika sudah dipilih saat register;
- FastAPI berjalan sebagai service pendukung analisis;
- toolkit berisi teknik utama dan teknik tambahan seperti STOP, Grounding 3-2-1, Napas 4-7-8, RAIN, dan Jurnal Reflektif Harian.

Hasil akhir video yang disarankan:

```text
Video 1  - Perkenalan aplikasi dan tujuan sistem
Video 2  - Pendaftaran sekolah dan approval super admin
Video 3  - Manual super admin
Video 4  - Manual admin sekolah
Video 5  - Manual guru
Video 6  - Manual siswa
Video 7  - Manual parent
Video 8  - Manual analisis dan toolkit mindfulness
Video 9  - Flow lengkap dari sekolah sampai rekomendasi mindfulness
```

---

## 2. Persiapan Sebelum Rekaman

Checklist teknis:

```text
[ ] Website bisa dibuka
[ ] Admin panel bisa dibuka
[ ] API mobile aktif
[ ] APK terbaru sudah terpasang
[ ] Akun demo tersedia
[ ] Data sekolah demo tersedia
[ ] Data kelas demo tersedia
[ ] Data activity demo tersedia
[ ] Data analisis demo tersedia
[ ] Notifikasi, TTS, dan guided practice sudah dites
```

Hal yang jangan ditampilkan:

- file `.env`;
- API key;
- Google client secret;
- file `.pem`;
- password asli;
- terminal yang menampilkan credential production;
- data pribadi user real.

Gunakan akun demo atau data seeder ketika rekaman.

---

## 3. Alur Besar Video

Flow utama yang sebaiknya dijadikan cerita video:

```text
Sekolah daftar dari website
  -> super admin approve sekolah
  -> super admin membuat admin sekolah
  -> admin sekolah membuat kelas
  -> guru register di aplikasi
  -> siswa register di aplikasi
  -> admin sekolah approve guru dan siswa
  -> guru membuat activity mengajar
  -> siswa join activity kelas
  -> guru check-in
  -> siswa check-in
  -> guru check-out
  -> siswa check-out dan menulis jurnal
  -> sistem membuat analisis burnout
  -> sistem memberi rekomendasi mindfulness
  -> pengguna menjalankan guided practice
  -> parent memantau activity dan kondisi anak
```

Narasi pembuka:

```text
MindfulEdu adalah sistem pendamping sekolah untuk mencatat aktivitas, mood, jurnal reflektif, analisis burnout, dan rekomendasi mindfulness. Sistem ini dipakai oleh sekolah, guru, siswa, dan orang tua dengan akses yang berbeda sesuai role.
```

---

## 4. Video Perkenalan Aplikasi

Durasi saran: 3 sampai 5 menit.

Yang ditampilkan:

- landing page MindfulEdu;
- tombol daftar sekolah;
- tombol download aplikasi;
- gambaran admin panel;
- gambaran aplikasi mobile;
- gambaran analisis dan toolkit mindfulness.

Poin narasi:

- MindfulEdu bukan alat diagnosis medis;
- sistem membantu refleksi dan monitoring kondisi harian;
- data utama berasal dari activity, check-in, check-out, jurnal, dan evaluasi mindfulness;
- rekomendasi latihan diberikan berdasarkan pola activity, mood, jurnal, dan faktor dominan.

Script singkat:

```text
MindfulEdu membantu sekolah memantau aktivitas dan kondisi pengguna secara terstruktur. Guru dan siswa mencatat activity, melakukan check-in mood sebelum kegiatan, check-out setelah kegiatan, lalu menulis jurnal. Dari data tersebut, sistem membuat analisis burnout dan menyarankan latihan mindfulness yang sesuai.
```

---

## 5. Video Pendaftaran Sekolah

Durasi saran: 4 sampai 6 menit.

Yang ditampilkan:

- buka website publik;
- masuk ke halaman daftar sekolah;
- isi nama sekolah, NPSN, jenjang, status, alamat, kontak;
- pilih provinsi;
- pilih kota/kabupaten yang muncul sesuai provinsi;
- pilih kecamatan yang muncul sesuai kota/kabupaten;
- submit pendaftaran;
- tampil status atau pesan berhasil.

Flow:

```text
Buka website
  -> pilih Daftarkan Sekolah
  -> isi data sekolah
  -> pilih provinsi
  -> pilih kota/kabupaten
  -> pilih kecamatan
  -> isi kontak penanggung jawab
  -> kirim pendaftaran
  -> sekolah masuk status pending
```

Poin penting:

- pendaftaran sekolah dilakukan dari website, bukan dari aplikasi mobile;
- pilihan wilayah memakai nested choice;
- kota/kabupaten terkunci sampai provinsi dipilih;
- kecamatan terkunci sampai kota/kabupaten dipilih;
- sekolah belum bisa dipakai sebelum approved.

Script:

```text
Pihak sekolah mengisi form pendaftaran dari website. Data wilayah dibuat bertingkat, sehingga setelah memilih provinsi, sistem hanya menampilkan kota atau kabupaten dari provinsi tersebut. Setelah kota dipilih, sistem menampilkan kecamatan yang sesuai. Setelah dikirim, status sekolah menjadi pending dan menunggu review super admin.
```

Checklist scene:

```text
[ ] Form daftar sekolah tampil
[ ] Nested provinsi, kota/kabupaten, kecamatan berjalan
[ ] Submit berhasil
[ ] Data masuk ke dashboard super admin
```

---

## 6. Video Super Admin

Durasi saran: 8 sampai 12 menit.

Tujuan role:

Super admin mengelola seluruh sistem lintas sekolah. Super admin bisa melihat pendaftaran sekolah, sekolah approved, admin sekolah, guru, siswa, parent, activity, analisis, dan data mindfulness.

Flow rekaman:

```text
Buka /admin
  -> login sebagai super admin
  -> buka School Registrations
  -> review sekolah pending
  -> approve sekolah
  -> buka Schools
  -> pastikan sekolah muncul
  -> buka School Admins
  -> buat admin sekolah
  -> buka Classes jika perlu
  -> cek modul guru, siswa, parent, activity, analisis, toolkit
```

Modul yang dijelaskan:

| Modul | Fungsi Dalam Video |
|---|---|
| School Registrations | Menerima dan meninjau sekolah baru |
| Schools | Mengelola sekolah yang sudah approved |
| School Admins | Membuat admin sekolah |
| Classes | Melihat atau membuat kelas |
| Teacher Registrations | Melihat pendaftaran guru |
| Student Registrations | Melihat pendaftaran siswa |
| Teacher Data | Melihat data guru |
| Student Data | Melihat data siswa |
| Parent Management | Melihat parent dan relasi anak |
| Teacher Activities | Melihat aktivitas guru |
| Student Activities | Melihat aktivitas siswa |
| Teacher Burnout Analysis | Melihat hasil analisis guru |
| Student Burnout Analysis | Melihat hasil analisis siswa |
| Student Observations | Melihat observasi siswa dari activity kelas |
| Mindful Tactics | Mengelola teknik mindfulness |
| Mindfulness Sessions | Melihat riwayat latihan mindfulness |
| Login Histories | Melihat histori login |

Script:

```text
Super admin adalah pengelola pusat. Pada halaman ini, super admin dapat menyetujui sekolah baru, membuat admin sekolah, dan memantau data utama seluruh sistem. Data sekolah tetap dipisahkan, tetapi super admin memiliki akses penuh untuk kebutuhan pengawasan.
```

---

## 7. Video Admin Sekolah

Durasi saran: 8 sampai 12 menit.

Tujuan role:

Admin sekolah mengelola data di sekolahnya sendiri. Admin sekolah tidak mengelola sekolah lain.

Flow rekaman:

```text
Login admin sekolah
  -> cek profil sekolah
  -> buat kelas
  -> buka Teacher Registrations
  -> approve guru
  -> buka Student Registrations
  -> approve siswa
  -> cek Teacher Data dan Student Data
  -> cek Parent Management
  -> cek Activity dan Analisis
```

Poin penting:

- approval guru/siswa hanya masuk ke super admin dan admin sekolah terkait;
- admin sekolah lain tidak melihat guru/siswa dari sekolah berbeda;
- guru dan siswa pending belum bisa login;
- admin sekolah bisa membantu reset password user sekolahnya;
- approval tidak perlu mengirim email jika sistem dipakai dengan konfirmasi pribadi.

Script:

```text
Admin sekolah bertugas merapikan data internal sekolah. Setelah guru atau siswa mendaftar, data mereka masuk ke daftar pending sekolah terkait. Admin sekolah dapat mengecek data tersebut, lalu approve atau reject. Setelah approved, pengguna baru bisa login ke aplikasi.
```

Checklist scene:

```text
[ ] Admin sekolah login
[ ] Hanya data sekolahnya sendiri yang tampil
[ ] Kelas dibuat
[ ] Guru pending tampil
[ ] Siswa pending tampil
[ ] Approval berhasil
[ ] Guru/siswa bisa login setelah approved
```

---

## 8. Video Guru

Durasi saran: 10 sampai 15 menit.

Tujuan role:

Guru memakai MindfulEdu untuk mencatat aktivitas mengajar dan aktivitas pribadi, check-in/check-out mood, menulis jurnal, melihat analisis, memakai toolkit mindfulness, dan melihat observasi siswa pada activity kelas.

Flow rekaman:

```text
Pilih role Guru
  -> register email atau Google
  -> pilih sekolah approved
  -> tunggu approval
  -> login setelah approved
  -> lengkapi akun
  -> buat activity pribadi
  -> buat activity mengajar
  -> pilih target kelas
  -> check-in
  -> check-out dan isi jurnal
  -> buka analisis
  -> buka rekomendasi mindfulness
  -> buka observasi siswa
```

Activity guru:

| Jenis | Fungsi |
|---|---|
| Mengajar | Activity kelas yang bisa dijoin siswa |
| Rapat | Mencatat rapat |
| Administrasi | Mencatat administrasi |
| Koreksi | Mencatat koreksi tugas/ujian |
| Persiapan materi | Mencatat persiapan pembelajaran |
| Istirahat | Mencatat jeda pemulihan |
| Lainnya | Activity bebas |

Script activity:

```text
Guru dapat membuat activity pribadi atau activity mengajar. Jika memilih activity mengajar, guru dapat menentukan target kelas. Activity tersebut akan muncul di aplikasi siswa yang sekolah dan kelasnya sesuai.
```

Script check-in:

```text
Check-in digunakan untuk mencatat kondisi sebelum activity dimulai. Guru memilih mood, intensitas, dan dapat menulis alasan singkat. Pada activity kelas, check-in guru menjadi tanda bahwa kegiatan sudah dimulai sehingga siswa dapat ikut check-in.
```

Script check-out:

```text
Check-out digunakan untuk menutup activity. Guru memilih mood akhir, mengisi jurnal refleksi, dan dapat memilih tag burnout jika merasa ada kelelahan emosional, depersonalisasi, atau rendah pencapaian diri. Data ini dipakai untuk analisis dan rekomendasi mindfulness.
```

Script observasi:

```text
Setelah siswa join dan menyelesaikan activity kelas, guru dapat membuka observasi siswa. Guru melihat mood check-in, mood check-out, jurnal, dan ringkasan kondisi siswa yang terkait dengan activity miliknya.
```

---

## 9. Video Siswa

Durasi saran: 10 sampai 15 menit.

Tujuan role:

Siswa memakai MindfulEdu untuk mencatat kegiatan belajar, join activity kelas, check-in/check-out mood, menulis jurnal, melihat analisis, memakai toolkit mindfulness, dan membagikan kode parent.

Flow rekaman:

```text
Pilih role Siswa
  -> register email atau Google
  -> pilih sekolah dan kelas
  -> tunggu approval
  -> login setelah approved
  -> buat activity pribadi
  -> buka activity kelas tersedia
  -> join activity guru
  -> check-in setelah guru check-in
  -> check-out setelah guru check-out
  -> isi jurnal
  -> buka analisis
  -> buka rekomendasi mindfulness
  -> buka profil dan lihat kode parent
```

Activity siswa:

| Jenis | Fungsi |
|---|---|
| Belajar di kelas | Kegiatan belajar formal |
| Belajar bersama | Diskusi atau kerja kelompok |
| Tugas/PR | Mengerjakan tugas |
| Ujian/Ulangan | Kegiatan evaluasi |
| Ekstrakurikuler | Kegiatan luar kelas |
| Istirahat | Jeda pemulihan |
| Lainnya | Activity bebas |

Script:

```text
Siswa bisa membuat activity pribadi dan juga join activity kelas dari guru. Pada activity kelas, siswa menunggu guru check-in terlebih dahulu. Setelah activity selesai, siswa check-out dan menulis jurnal agar sistem bisa membaca kondisi setelah kegiatan.
```

Poin yang harus diperlihatkan:

- activity kelas hanya muncul jika sekolah dan kelas sesuai;
- siswa tidak bisa check-in sebelum guru check-in;
- siswa tidak bisa check-out sebelum guru check-out;
- jurnal siswa dapat membantu guru melihat observasi kelas;
- kode parent ada di profil siswa untuk menghubungkan orang tua.

---

## 10. Video Parent

Durasi saran: 6 sampai 10 menit.

Tujuan role:

Parent memantau kondisi anak secara terbatas. Parent tidak membuat activity anak dan tidak mengedit jurnal anak.

Flow rekaman:

```text
Parent register atau login
  -> buka dashboard parent
  -> tambah anak
  -> masukkan kode siswa
  -> pilih sekolah anak
  -> validasi
  -> pilih anak
  -> pilih tanggal
  -> lihat activity anak
  -> lihat mood check-in dan check-out
  -> lihat analisis anak
  -> lihat rekomendasi pendampingan
```

Script:

```text
Parent dapat menghubungkan akun dengan anak memakai kode dari profil siswa. Setelah terhubung, parent dapat melihat activity anak, mood sebelum dan sesudah kegiatan, hasil analisis, dan rekomendasi pendampingan. Parent hanya melihat anak yang sudah terhubung.
```

Batasan yang perlu dijelaskan:

- parent tidak bisa melihat siswa lain;
- parent tidak bisa mengubah activity atau jurnal anak;
- parent perlu kode siswa dan sekolah yang benar;
- data parent dipakai untuk monitoring, bukan penilaian akademik.

---

## 11. Video Analisis Burnout

Durasi saran: 8 sampai 12 menit.

Yang ditampilkan:

- buat atau buka activity yang sudah completed;
- buka menu Analisis;
- pilih Harian;
- tekan Analisis;
- lihat skor, kategori, workload, wellbeing, dominant factors;
- pilih Mingguan;
- pilih Bulanan;
- buka history analisis;
- buka rekomendasi mindfulness.

Data yang dipakai:

| Data | Fungsi |
|---|---|
| Activity | Dasar daftar kegiatan |
| Planned hours | Durasi rencana |
| Actual hours | Durasi aktual dari check-in/check-out |
| Intensity factor | Bobot activity |
| Mood check-in | Kondisi awal |
| Mood check-out | Kondisi akhir |
| Jurnal | Fakta, perasaan, pola, rencana |
| Burnout tags | Tag manual guru |
| Self report | Tambahan kondisi guru |

Periode analisis:

| Periode | Rentang | Kapasitas |
|---|---|---:|
| Harian | Tanggal dipilih | 8 jam |
| Mingguan | 7 hari terakhir | 56 jam |
| Bulanan | 30 hari terakhir | 240 jam |

Script:

```text
Analisis burnout membaca activity yang sudah selesai. Sistem menghitung workload dari actual hours dikali intensity factor, lalu menggabungkannya dengan wellbeing score dari mood dan jurnal. Hasilnya berupa skor, kategori hijau, kuning, atau merah, faktor dominan, dan rekomendasi mindfulness.
```

Catatan narasi:

- mood positif seperti senang ke senang tidak otomatis menaikkan wellbeing risk;
- activity positif tetap masuk riwayat aktivitas;
- skor workload tetap dihitung karena activity tetap memakai waktu dan energi;
- kesimpulan harian menjelaskan kondisi berdasarkan kegiatan hari ini, bukan hanya activity terakhir.

---

## 12. Video Toolkit Mindfulness

Durasi saran: 10 sampai 15 menit.

Flow rekaman:

```text
Buka menu Toolkit
  -> lihat daftar teknik
  -> buka detail teknik
  -> baca tujuan dan knowledge
  -> bookmark teknik
  -> tekan Mulai
  -> ikuti guided practice step-by-step
  -> dengarkan TTS
  -> selesai
  -> isi evaluasi latihan
```

Fungsi screen:

| Bagian | Fungsi |
|---|---|
| List teknik | Menampilkan seluruh teknik mindfulness |
| Detail teknik | Menjelaskan fungsi, knowledge, durasi, dan step |
| Bookmark | Menandai teknik favorit |
| Guided practice | Latihan step-by-step |
| Timer | Mengatur durasi step |
| TTS | Membacakan instruksi |
| Evaluasi | Mencatat perubahan kondisi setelah latihan |

Script:

```text
Toolkit Mindfulness berisi teknik latihan yang dapat dipakai sesuai kondisi pengguna. Setiap teknik memiliki penjelasan, durasi, step latihan, dan panduan suara. Setelah latihan selesai, pengguna mengisi evaluasi untuk mencatat apakah kondisinya membaik, tetap, atau masih membutuhkan jeda.
```

---

## 13. Daftar Kegiatan Mindfulness Di Sistem

Bagian ini wajib masuk ke video analisis/toolkit atau video perkenalan.

| No | Teknik | Category | Durasi | Cocok Untuk |
|---:|---|---|---:|---|
| 1 | Teknik STOP | `stop_technique` | 2 menit | Marah, cemas, konflik, impulsif |
| 2 | Grounding 3-2-1 | `grounding_321` | 3 menit | Cemas, panik, kewalahan |
| 3 | Napas 4-7-8 | `breathing_478` | 5 menit | Tegang, stres, sulit tenang |
| 4 | Jeda Napas 3 Menit | `breathing_space_3min` | 3 menit | Transisi aktivitas, fokus, tekanan ringan |
| 5 | Awareness of Breathing | `maintain_breath_awareness` | 3 menit | Kondisi stabil, fokus, menjaga ritme |
| 6 | Mindful Breathing | `mindful_breathing` | 5 menit | Sulit fokus, pikiran ramai, jeda setelah aktivitas |
| 7 | Focused Attention Meditation | `focused_attention` | 5 menit | Distraksi, konsentrasi belajar |
| 8 | Sitting Meditation | `sitting_meditation` | 10 menit | Banyak pikiran, stres, kewalahan |
| 9 | Body Scan Singkat | `body_scan_micro` | 10 menit | Lelah, tegang, mood negatif |
| 10 | Body Scan Penuh | `body_scan_full` | 20 menit | Burnout tinggi, pemulihan panjang |
| 11 | Mindful Movement | `mindful_movement` | 10 menit | Pegal, duduk lama, lelah fisik |
| 12 | Walking Meditation | `walking_meditation` | 5 menit | Jenuh, gelisah, butuh bergerak |
| 13 | Open Monitoring | `open_monitoring` | 10 menit | Overwhelmed, emosi bercampur |
| 14 | Mindfulness of Sounds | `mindfulness_of_sounds` | 5 menit | Grounding, sulit fokus pada napas |
| 15 | RAIN | `rain_self_compassion` | 7 menit | Sedih, marah, frustrasi, emosi berat |
| 16 | Loving-Kindness Meditation | `loving_kindness` | 7 menit | Konflik, self-compassion, rendah pencapaian diri |
| 17 | Mountain Meditation | `mountain_meditation` | 15 menit | Emosi naik turun, perubahan, tekanan tinggi |
| 18 | Informal Mindfulness | `informal_mindfulness` | 3 menit | Rutinitas harian, waktu terbatas |
| 19 | Jurnal Reflektif Harian | `reflective_journal` | 5 menit | Refleksi, membaca pola, menutup hari |

---

## 14. Step Kegiatan Mindfulness Untuk Narasi Video

### 14.1 Teknik STOP

```text
1. Stop: hentikan aktivitas sejenak.
2. Take a Breath: tarik dan hembuskan napas perlahan.
3. Observe: amati tubuh, pikiran, emosi, dan dorongan.
4. Proceed: lanjutkan dengan tindakan yang lebih sadar.
```

### 14.2 Grounding 3-2-1

```text
1. Sebutkan tiga hal yang terlihat.
2. Sebutkan dua suara yang terdengar.
3. Sebutkan satu sensasi fisik.
4. Tarik napas pelan dan biarkan tubuh menetap.
```

### 14.3 Napas 4-7-8

```text
1. Duduk nyaman.
2. Tarik napas 4 hitungan.
3. Tahan napas lembut 7 hitungan.
4. Hembuskan napas 8 hitungan.
5. Ulangi beberapa siklus.
```

### 14.4 Jeda Napas 3 Menit

```text
1. Menit pertama: sadari kondisi saat ini.
2. Menit kedua: fokus pada napas.
3. Menit ketiga: perluas kesadaran ke tubuh.
4. Tutup dengan niat sederhana.
```

### 14.5 Awareness of Breathing

```text
1. Duduk stabil.
2. Rasakan napas masuk.
3. Rasakan napas keluar.
4. Kembali ke napas saat terdistraksi.
5. Akhiri dengan satu napas panjang.
```

### 14.6 Mindful Breathing

```text
1. Siapkan tubuh.
2. Sadari napas masuk dan keluar.
3. Saat terdistraksi, kembali perlahan.
4. Tutup dengan menyadari tubuh dan lingkungan.
```

### 14.7 Focused Attention Meditation

```text
1. Pilih anchor perhatian.
2. Pertahankan fokus pada anchor.
3. Label distraksi lalu kembali.
4. Tutup dengan menyadari tubuh.
```

### 14.8 Body Scan Singkat dan Penuh

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

### 14.9 Sitting Meditation

```text
1. Posisi tubuh.
2. Napas.
3. Sensasi tubuh.
4. Suara.
5. Pikiran.
6. Emosi.
7. Penutup.
```

### 14.10 Mindful Movement

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

### 14.11 Walking Meditation

```text
1. Berdiri dan sadari kontak kaki.
2. Mulai berjalan.
3. Sadari angkat, gerak, dan sentuh.
4. Sadari gerakan seluruh tubuh.
5. Hubungkan napas dan langkah.
6. Sadari lingkungan.
7. Perlambat, berhenti, dan tutup sesi.
```

### 14.12 Open Monitoring

```text
1. Stabilkan melalui napas.
2. Buka awareness ke tubuh.
3. Sadari suara.
4. Sadari pikiran dan emosi.
5. Biarkan pengalaman datang dan pergi.
6. Kembali ke napas.
```

### 14.13 Mindfulness of Sounds

```text
1. Persiapan.
2. Dengarkan suara dekat.
3. Dengarkan suara jauh.
4. Sadari suara muncul, berubah, dan menghilang.
5. Kembali ke napas.
```

### 14.14 RAIN

```text
1. Recognize: kenali emosi.
2. Allow: izinkan emosi hadir.
3. Investigate: rasakan emosi di tubuh.
4. Nurture: beri kalimat baik untuk diri.
5. Pilih langkah kecil yang aman.
```

### 14.15 Loving-Kindness Meditation

```text
1. Stabilkan diri.
2. Arahkan kebaikan kepada diri sendiri.
3. Arahkan niat baik kepada orang yang dipercaya.
4. Perluas kebaikan jika nyaman.
5. Kembali ke napas dan tutup.
```

### 14.16 Mountain Meditation

```text
1. Persiapan dan napas.
2. Visualisasi gunung.
3. Bayangkan perubahan cuaca.
4. Hubungkan dengan pikiran dan emosi yang berubah.
5. Rasakan kestabilan tubuh.
6. Tutup sesi.
```

### 14.17 Informal Mindfulness

Informal Mindfulness dapat dijelaskan sebagai latihan harian yang dipecah menjadi tiga pilihan.

Mindful Drinking:

```text
1. Pegang gelas dan sadari suhu.
2. Perhatikan warna dan aroma.
3. Minum perlahan.
4. Sadari sensasi setelah menelan.
```

Mindful Eating:

```text
1. Perhatikan makanan.
2. Ambil satu suapan.
3. Kunyah perlahan.
4. Sadari rasa dan tekstur.
5. Sadari kondisi tubuh.
```

Mindful Walking to Class:

```text
1. Sadari langkah kaki.
2. Sadari napas selama berjalan.
3. Sadari lingkungan sekitar.
```

### 14.18 Jurnal Reflektif Harian

```text
1. Tulis satu hal yang menguras energi.
2. Tulis perasaan dominan.
3. Tulis pola yang terlihat.
4. Tulis satu hal kecil yang bisa dilepas atau ditunda.
5. Tulis rencana lembut untuk besok.
```

---

## 15. Video Flow Lengkap

Durasi saran: 15 sampai 25 menit.

Gunakan cerita contoh:

```text
SDN Contoh 1 mendaftarkan sekolah.
Super admin approve sekolah.
Super admin membuat admin SDN Contoh 1.
Admin sekolah membuat kelas 5A.
Guru mendaftar dan memilih SDN Contoh 1.
Siswa mendaftar dan memilih SDN Contoh 1 kelas 5A.
Admin sekolah approve guru dan siswa.
Guru membuat activity Mengajar Matematika untuk kelas 5A.
Siswa join activity tersebut.
Guru check-in.
Siswa check-in.
Guru check-out.
Siswa check-out dan menulis jurnal.
Sistem menampilkan analisis dan rekomendasi.
Siswa menjalankan latihan mindfulness.
Parent menghubungkan anak dan melihat monitoring.
```

Narasi penutup:

```text
Dengan alur ini, MindfulEdu menghubungkan aktivitas harian, kondisi emosional, jurnal reflektif, analisis burnout, rekomendasi mindfulness, observasi guru, dan monitoring parent dalam satu sistem yang terstruktur.
```

---

## 16. Checklist QA Sebelum Video Final

```text
[ ] Website landing page tampil
[ ] Form pendaftaran sekolah berhasil
[ ] Nested wilayah berjalan
[ ] Super admin bisa approve sekolah
[ ] Super admin bisa membuat admin sekolah
[ ] Admin sekolah bisa membuat kelas
[ ] Guru register dan pending
[ ] Siswa register dan pending
[ ] Admin sekolah approve guru/siswa
[ ] Guru login
[ ] Siswa login
[ ] Guru membuat activity kelas
[ ] Siswa join activity kelas
[ ] Check-in guru berjalan
[ ] Check-in siswa berjalan setelah guru
[ ] Check-out guru berjalan
[ ] Check-out siswa berjalan setelah guru
[ ] Jurnal tersimpan
[ ] Analisis harian berjalan
[ ] Analisis mingguan berjalan
[ ] Analisis bulanan berjalan
[ ] Rekomendasi mindfulness tampil
[ ] Toolkit tampil
[ ] Guided practice tampil step-by-step
[ ] TTS berjalan jika perangkat mendukung
[ ] Evaluasi latihan tampil
[ ] Parent bisa link anak
[ ] Parent melihat activity dan analisis anak
```

---

## 17. Output File Video Yang Disarankan

```text
01_perkenalan_mindfuledu.mp4
02_pendaftaran_sekolah.mp4
03_manual_super_admin.mp4
04_manual_admin_sekolah.mp4
05_manual_guru.mp4
06_manual_siswa.mp4
07_manual_parent.mp4
08_analisis_dan_toolkit_mindfulness.mp4
09_flow_lengkap_mindfuledu.mp4
```

Dokumen pendamping per role tetap tersedia di folder `docs/manual-guide/` jika membutuhkan script yang lebih spesifik untuk masing-masing video.
