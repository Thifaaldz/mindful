Product Requirements Document (PRD)

Nama Produk: MindfulApp Platform
Versi Dokumen: 1.0
Tanggal: 2026-08-23
Pemilik Produk: Product Manager
Tim Pengembang: Tim Engineering, Tim Desain UX/UI, Tim QA

---

1. Ringkasan Produk

MindfulApp adalah platform digital berbasis web dan mobile yang dirancang untuk memberdayakan guru dalam mempraktikkan mindfulness dan meningkatkan kesejahteraan mereka. Platform ini berfungsi sebagai panduan interaktif, jurnal digital, dasbor analitik, dan alat observasi siswa dalam satu ekosistem yang terintegrasi. Produk ini memungkinkan guru untuk melacak kemajuan pribadi mereka, mengakses alat bantu krisis, dan memantau kesejahteraan siswa, yang pada akhirnya menciptakan lingkungan belajar yang lebih kondusif.

2. Tujuan Produk

1. Menyediakan Panduan Praktis: Mengubah protokol mindfulness (5 langkah) menjadi fitur aplikasi yang interaktif dan mudah diikuti.
2. Membangun Kebiasaan: Mendorong konsistensi melalui Digital Logbook harian dan fitur pengingat.
3. Memberikan Visibilitas: Memvisualisasikan data kemajuan individu melalui Dashboard untuk memotivasi pengguna dan menunjukkan efektivitas program.
4. Mendukung Pengambilan Keputusan Guru: Memudahkan guru dalam mencatat dan mendeteksi dini tanda-tanda krisis pada siswa melalui Checklist dan sistem flagging.
5. Menjadi Alat Pertolongan Pertama: Menyediakan akses cepat ke teknik intervensi krisis (STOP, Grounding) di situasi yang membutuhkan.

3. Ruang Lingkup Produk (Fitur)

3.1. Modul Latihan Mindfulness (Panduan Interaktif)

· Deskripsi: Panduan langkah demi langkah untuk sesi mindfulness (5-10 menit) berdasarkan protokol yang ada.
· Fitur:
  · Langkah 1-7: Menampilkan instruksi teks singkat per langkah.
  · Pengatur Waktu (Timer): Timer hitung mundur yang dapat disesuaikan untuk setiap langkah (misal: 5 menit untuk "Perhatikan Napas").
  · Penghitung (Counter): Tombol "+1" untuk mencatat jumlah distraksi atau intervensi tanpa mengganggu fokus (misal: pada Langkah 4 & 5).
  · Mode Audio (Opsional): Panduan suara (guided meditation) untuk membantu pengguna yang lebih menyukai format audio.
· User Story: "Sebagai seorang guru, saya ingin mengikuti sesi mindfulness dengan panduan visual dan timer yang jelas, serta dapat mencatat distraksi saya dengan mudah, sehingga saya bisa fokus pada latihan tanpa harus mengingat langkah atau menghitung secara manual."

3.2. Digital Logbook

· Deskripsi: Jurnal harian untuk mencatat metrik dan refleksi setelah sesi mindfulness.
· Fitur:
  · Input Data Otomatis: Durasi latihan dan skor distraksi/intervensi dari modul latihan terisi otomatis.
  · Skala Ketenangan: Slider interaktif (1-10) untuk menilai kondisi "Sebelum" dan "Sesudah" latihan.
  · Catatan Refleksi: Kolom teks terbuka untuk menjawab pertanyaan panduan (misal: "Apa yang dirasakan tubuh saat ini?").
  · Riwayat (History): Menampilkan logbook entri hari-hari sebelumnya dalam format kalender atau daftar.
· User Story: "Sebagai seorang guru, saya ingin mencatat semua metrik latihan saya di satu tempat dengan cepat dan mudah, sehingga saya bisa melihat riwayat dan pola perkembangan saya."

3.3. Educator's Dashboard

· Deskripsi: Halaman utama yang menampilkan visualisasi data kemajuan pengguna.
· Fitur:
  · Ringkasan Statistik: Menampilkan total sesi, rata-rata skor ketenangan, dan rata-rata distraksi dalam seminggu/bulan terakhir.
  · Grafik Tren: Grafik garis yang menunjukkan tren "Skala Ketenangan" dari waktu ke waktu untuk memvisualisasikan progress rate (seperti pada halaman 8).
  · Pencapaian (Badge): Memberikan badge atau lencana motivasi untuk pencapaian tertentu (misal: "10 Hari Berturut-turut", "Peningkatan 20%").
  · Taktik Cepat: Bagian akses cepat ke "Taktik Mindful Lecturing" dan "Intervensi Krisis".
· User Story: "Sebagai seorang guru, saya ingin melihat visualisasi kemajuan saya dalam bentuk grafik yang mudah dipahami, sehingga saya bisa melihat dampak latihan saya dan tetap termotivasi."

3.4. Toolkit Intervensi & Kelas

· Deskripsi: Perpustakaan alat bantu yang dapat diakses kapan saja.
· Fitur:
  · Teknik STOP: Menampilkan panduan 4 langkah dengan tampilan penuh ("Full-screen mode") untuk digunakan saat krisis.
  · Grounding 3-2-1: Panduan interaktif dengan prompt untuk mengisi 3 hal dilihat, 2 hal didengar, 1 hal dirasakan.
  · Taktik Mindful Lecturing: Kumpulan kartu tips (Single-Tasking, Tempo Stabil, Jeda Sengaja, Cek Pemahaman) yang dapat disimpan (bookmark).
· User Story: "Sebagai seorang guru, saya ingin bisa membuka panduan teknik STOP atau Grounding dalam satu atau dua ketukan layar, sehingga saya bisa menenangkan diri dengan cepat di tengah situasi kelas yang menegangkan."

3.5. Modul Observasi Siswa (Psychological First Aid - PFA)

· Deskripsi: Alat untuk mencatat dan memantau kesejahteraan siswa.
· Fitur:
  · Daftar Siswa: Menampilkan daftar siswa dari kelas yang diampu.
  · Checklist Harian (FR-04): Formulir cepat untuk menilai siswa pada 5 area (Perasaan, Perilaku, Tubuh, Teman, Belajar) dengan status: Hijau (Baik), Kuning (Perubahan Ringan/Menetap), Merah (Risiko Keselamatan).
  · Catatan Kasus (Notes): Kolom untuk mencatat observasi spesifik atau riwayat perubahan.
  · Sistem Flagging & Alert: Notifikasi atau penanda visual (misal: ikon peringatan) pada daftar siswa yang statusnya "Merah" atau "Kuning" menetap.
  · Rekomendasi Tindakan: Menampilkan panduan tindakan berdasarkan status (misal: "Dekati dengan tenang" untuk Kuning, "Rujuk ke layanan bantuan segera" untuk Merah).
· User Story: "Sebagai seorang guru, saya ingin mencatat observasi kesejahteraan siswa dengan cepat dan terstruktur, serta mendapatkan peringatan dini jika ada siswa yang menunjukkan tanda-tanda krisis, sehingga saya bisa melakukan intervensi yang tepat dan tepat waktu."

4. Desain Antarmuka & Pengalaman (UX/UI)

· Prinsip Desain:
  · Tenang & Bersih: Menggunakan palet warna netral dan menenangkan (biru muda, hijau, putih), tipografi yang mudah dibaca, dan banyak white space untuk mengurangi beban kognitif.
  · Intuitif: Navigasi yang sederhana dengan ikon yang jelas dan label teks. Fitur-fitur penting (Logbook, Dashboard, Toolkit) dapat diakses dari bottom navigation bar.
  · Ramah Pengguna (User-Friendly): Proses input data yang minimalis (gunakan slider, tombol besar, dan pilihan cepat) untuk mendorong penggunaan rutin tanpa rasa terbebani.
· Aliran Pengguna (User Flow) Utama:
  1. Login -> Dashboard (Melihat ringkasan).
  2. Melakukan Latihan: Dashboard -> Mulai Sesi -> Ikuti Panduan (Timer & Counter) -> Selesai -> Otomatis masuk ke Logbook.
  3. Mengisi Logbook: Isi Skala & Refleksi -> Simpan -> Kembali ke Dashboard.
  4. Mengamati Siswa: Menu "Observasi" -> Pilih Kelas & Siswa -> Isi Checklist -> Simpan.
  5. Mengakses Toolkit: Menu "Toolkit" -> Pilih "STOP", "Grounding", atau "Taktik".

5. Spesifikasi Teknis (Non-Fungsional)

· Platform: Aplikasi Web Responsif (Mobile-First) dan Aplikasi Mobile Native (iOS & Android).
· Arsitektur: Cloud-based (misal: AWS, GCP) untuk skalabilitas.
· Database:
  · Tabel users: Data guru (nama, email, sekolah, kelas yang diampu).
  · Tabel mindfulness_sessions: Data sesi (user_id, timestamp, duration, distraction_score, calmness_before, calmness_after, reflection).
  · Tabel student_observations: Data observasi (user_id, student_id, timestamp, perasaan, perilaku, tubuh, teman, belajar, status, notes).
· Autentikasi & Keamanan:
  · Login menggunakan email dan password (dengan verifikasi 2FA opsional).
  · Role-Based Access Control (RBAC): Admin dapat melihat data agregat semua guru; Guru hanya dapat melihat data diri sendiri dan siswa di kelasnya.
  · Enkripsi data sensitif (siswa).
  · Kepatuhan terhadap regulasi perlindungan data (misal: GDPR, atau UU PDP Indonesia).
· Kinerja:
  · Waktu muat halaman < 3 detik.
  · Dapat menangani hingga 10.000 pengguna aktif secara bersamaan.
· Notifikasi: Dukungan untuk push notification (mobile) atau email reminder untuk mengingatkan latihan harian.

6. Persyaratan Fungsional Detail (User Stories)

ID Modul User Story Acceptance Criteria
US-01 Latihan Sebagai guru, saya dapat memulai sesi latihan mindfulness 10 menit. - Tombol "Mulai Latihan" tersedia di Dashboard. - Timer menghitung mundur dari 10:00. - Panduan langkah 1-7 ditampilkan secara bergantian.
US-02 Latihan Sebagai guru, saya dapat mencatat jumlah distraksi selama latihan. - Tombol "+ Distraksi" tersedia dan terlihat di layar latihan. - Setiap klik menambah angka pada counter "Skor Distraksi".
US-03 Logbook Sebagai guru, saya dapat menilai tingkat ketenangan saya sebelum dan sesudah latihan. - Slider 1-10 tersedia untuk input "Sebelum" dan "Sesudah". - Nilai dari slider tersimpan di database.
US-04 Dashboard Sebagai guru, saya dapat melihat grafik tren ketenangan saya selama 7 hari terakhir. - Grafik garis ditampilkan di Dashboard utama. - Sumbu X adalah tanggal, sumbu Y adalah skor ketenangan (1-10).
US-05 Observasi Sebagai guru, saya dapat memilih seorang siswa dan mengisi checklist kesejahteraannya. - Daftar siswa dapat diakses dari modul Observasi. - Checklist 5 area tersedia dan dapat dipilih statusnya (Hijau/Kuning/Merah). - Tombol "Simpan" menyimpan data ke database.
US-06 Toolkit Sebagai guru, saya dapat mengakses panduan "Teknik STOP" dalam mode layar penuh. - Kartu "STOP" di Toolkit dapat diklik. - Membuka halaman baru dengan 4 langkah STOP dalam font besar dan latar belakang menenangkan.

7. Rencana Pengukuran & Analitik Produk

Produk akan mengumpulkan data untuk mengukur keberhasilan program dan produk itu sendiri:

· Adopsi Harian (Daily Active Users - DAU): Jumlah guru yang login dan menyelesaikan setidaknya satu sesi/mengisi logbook per hari.
· Retensi Mingguan (Weekly Retention): Persentase guru yang menggunakan produk setidaknya 3 kali dalam seminggu setelah 1 bulan.
· Rata-rata Durasi Sesi: Rata-rata waktu yang dihabiskan pengguna dalam satu sesi latihan.
· Tingkat Penyelesaian (Completion Rate): Persentase pengguna yang memulai dan menyelesaikan sesi latihan penuh.
· Perubahan Skor Ketenangan: Rata-rata delta (peningkatan) antara skor "Sebelum" dan "Sesudah" di seluruh pengguna.
· Penggunaan Fitur Krisis: Frekuensi akses ke Teknik STOP dan Grounding sebagai indikator potensi stres guru.
· Jumlah Observasi Siswa: Total checklist siswa yang diisi, dan persentase siswa yang teridentifikasi dengan status Kuning/Merah.

8. Risiko & Mitigasi

Risiko Dampak Mitigasi
Rendahnya Adopsi Guru Program gagal mencapai tujuan. - Melibatkan guru dalam proses desain awal (UX research). - Memberikan insentif (sertifikat, poin) dan dukungan manajemen. - Membuat antarmuka yang sangat sederhana dan cepat.
Data Pribadi Bocor Kehilangan kepercayaan dan masalah hukum. - Menerapkan enkripsi data yang kuat. - Melakukan audit keamanan rutin. - Membuat kebijakan privasi yang jelas dan disetujui pengguna.
Pengguna Merasa Terbebani Pengguna berhenti menggunakan produk. - Menekankan desain yang minimalis. - Menawarkan opsi sesi singkat (3 menit). - Menghindari notifikasi yang mengganggu.
Sistem Tidak Stabil (Down) Gangguan pada rutinitas pengguna. - Menggunakan infrastruktur cloud yang andal dengan auto-scaling. - Memiliki rencana pemulihan bencana (disaster recovery).
Interpretasi Status Siswa Guru salah menilai (over/under estimate) kondisi siswa. - Menyediakan panduan deskriptif untuk setiap status (Hijau, Kuning, Merah). - Mengadakan pelatihan singkat tentang penggunaan alat observasi.