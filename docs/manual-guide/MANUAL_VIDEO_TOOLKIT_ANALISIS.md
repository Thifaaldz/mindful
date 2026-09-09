# Manual Video Analisis dan Toolkit Mindfulness MindfulEdu

Dokumen ini adalah panduan video khusus fitur Analisis Burnout dan Toolkit Mindfulness. Fitur ini terutama digunakan oleh guru dan siswa, sedangkan parent melihat hasil analisis anak melalui dashboard parent.

---

## 1. Tujuan Fitur

Analisis dan Toolkit membantu pengguna memahami hubungan antara aktivitas, mood, jurnal, beban harian, dan kebutuhan pemulihan.

Fitur ini digunakan untuk:

- melihat skor burnout;
- melihat kategori hijau, kuning, atau merah;
- memahami faktor dominan;
- membaca review per activity;
- membuka rekomendasi teknik mindfulness;
- menjalankan guided practice step-by-step.

---

## 2. Alur Analisis

```text
User membuat activity
  -> user check-in
  -> user check-out dan isi jurnal
  -> sistem menganalisis jurnal
  -> user membuka menu Analisis
  -> memilih periode
  -> menekan tombol Analisis
  -> sistem menghitung skor
  -> sistem menampilkan rekomendasi
```

---

## 3. Data Yang Dipakai Analisis

| Data | Fungsi |
|---|---|
| Activity | Sumber aktivitas pengguna |
| Planned hours | Durasi rencana |
| Actual hours | Durasi aktual dari check-in/check-out |
| Intensity factor | Bobot aktivitas berdasarkan jenis/judul |
| Mood check-in | Kondisi awal |
| Intensitas check-in | Kekuatan mood awal |
| Mood check-out | Kondisi akhir |
| Jurnal | Fakta, perasaan, pola, dan rencana |
| Burnout tags | Tag manual guru |
| Auto burnout tags | Tag otomatis dari analisis jurnal |
| Self report | Tambahan refleksi guru jika tersedia |

---

## 4. Periode Analisis

| Periode | Rentang | Kapasitas |
|---|---|---:|
| Harian | Tanggal yang dipilih | 8 jam |
| Mingguan | 7 hari terakhir sampai tanggal yang dipilih | 56 jam |
| Bulanan | 30 hari terakhir sampai tanggal yang dipilih | 240 jam |

Rumus workload:

```text
Workload Score = min(100, total(actual_hours x intensity_factor) / kapasitas_periode x 100)
```

Rumus final:

```text
Final Score = min(100, 50% workload + 50% wellbeing)
```

Kategori:

| Kategori | Rentang | Makna |
|---|---:|---|
| Hijau | 0 - 39.99 | Kondisi relatif stabil |
| Kuning | 40 - 69.99 | Ada tanda perlu jeda |
| Merah | 70 - 100 | Beban/tekanan tinggi dan perlu perhatian |

---

## 5. Hal Yang Ditampilkan Pada Screen Analisis

| Bagian | Fungsi |
|---|---|
| Filter periode | Memilih harian, mingguan, atau bulanan |
| Tombol Analisis | Menjalankan analisis manual |
| Skor risiko | Menampilkan final burnout risk score |
| Kategori | Hijau, kuning, atau merah |
| Workload score | Skor dari beban aktivitas aktual |
| Wellbeing score | Skor dari mood, jurnal, dan self report |
| Dominant factors | Alasan utama skor/rekomendasi |
| Activity breakdown | Detail aktivitas dalam periode |
| Journal reviews | Review jurnal per activity |
| Rekomendasi | Teknik mindfulness yang disarankan |
| History | Riwayat analisis sebelumnya |

---

## 6. Rekomendasi Mindfulness

Rekomendasi utama screen analisis mengikuti category dan dominant factors periode, bukan activity terakhir saja. Activity terakhir tetap disimpan sebagai detail `latest_activity_review`.

Prioritas rekomendasi:

| Kondisi | Teknik |
|---|---|
| Crisis flag | Grounding 3-2-1 |
| Self report guru tinggi | Body Scan Meditation |
| Jurnal banyak tekanan | Sitting Meditation |
| Mood checkout negatif | Body Scan Singkat |
| Activity intensif/padat | Mindful Movement |
| Kategori hijau siswa | Jeda Napas 3 Menit |
| Kategori hijau guru | Awareness of Breathing |

---

## 7. Alur Toolkit

```text
Buka menu Toolkit
  -> pilih teknik
  -> lihat detail teknik
  -> bookmark jika perlu
  -> tekan Mulai
  -> ikuti step guided practice
  -> dengarkan TTS
  -> selesai
  -> isi evaluasi latihan
```

Fungsi setiap bagian:

| Bagian | Fungsi |
|---|---|
| List teknik | Menampilkan semua teknik mindfulness |
| Detail teknik | Menjelaskan tujuan dan knowledge teknik |
| Bookmark | Menyimpan teknik favorit |
| Guided practice | Menjalankan step latihan |
| Timer | Mengatur durasi tiap step |
| TTS | Membacakan instruksi |
| Evaluasi | Mencatat kondisi setelah latihan |

---

## 8. Teknik Yang Perlu Ditunjukkan Dalam Video

| Teknik | Cocok Untuk |
|---|---|
| Mindful Breathing | Menjaga napas dan fokus |
| Body Scan Meditation | Lelah fisik atau tegang |
| Sitting Meditation | Banyak pikiran atau jurnal berat |
| Mindful Movement | Aktivitas padat dan tubuh kaku |
| Walking Meditation | Butuh bergerak sadar |
| Teknik STOP | Marah atau impulsif |
| Grounding 3-2-1 | Cemas atau panik |
| Napas 4-7-8 | Tegang atau sulit tenang |
| Awareness of Breathing | Kondisi hijau/stabil |
| RAIN | Emosi berat |
| Jurnal Reflektif Harian | Refleksi harian |

---

## 9. Naskah Video Analisis

```text
Setelah pengguna melakukan check-in, check-out, dan menulis jurnal, data tersebut masuk ke menu Analisis. Pada halaman ini pengguna dapat memilih periode harian, mingguan, atau bulanan. Sistem menghitung workload dari durasi aktual dikali intensity factor, lalu menggabungkannya dengan wellbeing score dari mood dan jurnal.

Hasil akhirnya berupa skor dan kategori hijau, kuning, atau merah. Sistem juga memberikan rekomendasi mindfulness yang sesuai dengan faktor dominan pada periode tersebut.
```

---

## 10. Naskah Video Toolkit

```text
Pada menu Toolkit, pengguna dapat memilih teknik mindfulness. Setiap teknik memiliki penjelasan, knowledge, durasi, dan langkah latihan. Ketika latihan dimulai, aplikasi menampilkan step-by-step dengan timer dan suara panduan. Setelah selesai, pengguna dapat mengisi evaluasi untuk mencatat perubahan kondisi setelah latihan.
```

---

## 11. Checklist Akhir Video

```text
[ ] Activity sudah completed
[ ] Jurnal sudah diisi
[ ] Menu Analisis bisa dibuka
[ ] Periode harian tampil
[ ] Periode mingguan tampil
[ ] Periode bulanan tampil
[ ] Tombol Analisis berjalan
[ ] Skor dan kategori tampil
[ ] Activity breakdown tampil
[ ] Journal reviews tampil
[ ] Rekomendasi mindfulness tampil
[ ] Toolkit bisa dibuka
[ ] Detail teknik tampil
[ ] Guided practice berjalan
[ ] TTS berjalan
[ ] Evaluasi latihan tampil
```

