# README Perhitungan Analisis dan Rekomendasi MindfulEdu

Dokumen ini menjelaskan estimasi perhitungan yang dipakai sistem MindfulEdu untuk membaca activity, mood check-in, mood check-out, jurnal, skor burnout, dan rekomendasi mindfulness.

Dokumen ini bersifat teknis-operasional. Nilai di bawah adalah estimasi berdasarkan rule aplikasi saat ini, bukan diagnosis medis.

Versi perhitungan saat ini:

```text
scoring-v2.5-edumindful
```

---

## 1. Ringkasan Alur Perhitungan

Alur utama:

```text
User membuat activity
  -> sistem menghitung durasi rencana dan intensity factor
  -> user check-in dan memilih mood awal + intensitas
  -> user check-out, memilih mood akhir, dan mengisi jurnal
  -> jurnal dianalisis untuk mood terdeteksi, kata tekanan, dimensi burnout, dan sinyal krisis
  -> activity mendapat skor risiko activity
  -> analisis harian/mingguan/bulanan menghitung workload score dari TAH x IF
  -> sistem menghitung wellbeing score dari mood, jurnal, dimensi burnout, dan self report
  -> final burnout risk score dibuat
  -> rekomendasi mindfulness utama mengikuti category dan dominant factors periode tersebut
```

Formula workload:

```text
Burnout_Daily = (TAH x IF) / Max_Daily_Capacity x 100%

Burnout_Weekly =
  Σ(TAH_harian x IF_rata-rata_harian)
  / (7 x Max_Daily_Capacity)
  x 100%

Burnout_Monthly =
  Σ(TAH_harian x IF_rata-rata_harian)
  / (30 x Max_Daily_Capacity)
  x 100%
```

Di sistem, nilai tersebut disimpan sebagai `workload_score_raw`. Setelah itu final score tetap digabung dengan sinyal wellbeing:

```text
Final Score = 50% x min(100, Workload Score) + 50% x Wellbeing Score
```

Syarat final score dihitung:

- minimal ada satu activity selesai;
- activity memiliki check-out;
- activity memiliki jurnal/mood/review yang bisa dibaca.

Jika belum cukup data, sistem menampilkan status `Data belum cukup` dan menyarankan user melengkapi check-in, check-out, dan jurnal.

Aturan hijau/positif gaya edumindful:

- activity `senang -> senang`, `senang -> tenang`, atau mood stabil positif tidak menambah `Wellbeing Score` jika jurnal tidak punya kata tekanan;
- workload dari durasi aktual tetap dihitung karena aktivitas tetap memakai energi;
- activity tetap masuk `activity_count`, `completed_activity_count`, `journal_count`, `activity_breakdown`, dan `journal_reviews`;
- final score tidak dipaksa menjadi 0 selama sudah ada check-out/jurnal;
- contoh activity positif 2 jam mengajar: `Workload = 2 x 1.4 / 8 x 100 = 35`, `Wellbeing = 0`, `Final = 17.5`, kategori tetap hijau.

---

## 2. Data Yang Dipakai

| Data | Sumber | Dipakai Untuk |
|---|---|---|
| Judul activity | Form activity | Intensity factor berdasarkan keyword |
| Category activity | Form activity | Intensity factor berdasarkan keyword |
| Jam mulai dan selesai | Form activity | Planned hours |
| Waktu check-in/check-out | Tombol check-in/check-out | Actual hours |
| Mood check-in | Check-in | Mood awal dan negative ratio |
| Intensitas check-in | Check-in | Bobot tekanan mood awal |
| Mood check-out | Check-out | Mood akhir dan negative ratio |
| Fakta jurnal | Check-out | Deteksi tekanan dan mood |
| Perasaan jurnal | Check-out | Deteksi tekanan dan mood |
| Pola jurnal | Check-out | Deteksi tekanan dan pola burnout |
| Rencana jurnal | Check-out | Deteksi tekanan dan pola burnout |
| Burnout tags | Check-out guru | Dimensi burnout manual |
| Self report guru | Menu self report | Tambahan tekanan untuk guru |

---

## 3. Mood Yang Dikenali

Mood yang bisa dipilih pada check-in dan check-out:

| Mood | Status Dalam Perhitungan |
|---|---|
| senang | Tidak negatif |
| tenang | Tidak negatif |
| cemas | Negatif |
| sedih | Negatif |
| marah | Negatif |

Mood tambahan yang bisa terdeteksi dari jurnal oleh service analisis:

| Mood Terdeteksi | Contoh Kata Kunci |
|---|---|
| cemas | cemas, khawatir, gugup, takut, deg-degan, panik |
| sedih | sedih, kecewa, putus asa, menangis, murung, sepi |
| marah | marah, kesal, jengkel, benci, emosi |
| senang | senang, bahagia, gembira, semangat, seru, asik |
| lelah | lelah, capek, ngantuk, burnout, pusing, stres, stress |
| netral | Jika tidak ada keyword mood yang kuat |

Catatan:

- `lelah` tidak dipilih langsung dari tombol mood saat ini, tetapi bisa terdeteksi dari jurnal dan dihitung sebagai checkout negatif.
- Jika Gemini aktif, Gemini boleh menentukan mood terdeteksi selama nilainya termasuk daftar valid.
- Jika Gemini gagal/offline, sistem memakai keyword fallback lokal.

---

## 4. Kata Kunci Jurnal

### 4.1 Kata Tekanan

Jika jurnal memuat kata berikut, activity dianggap memiliki sinyal tekanan:

```text
lelah, capek, stres, stress, tertekan, pusing, cemas, takut,
marah, sedih, kewalahan, burnout, jenuh
```

Dampak:

- check-out bisa dianggap negatif walaupun mood akhir bukan `cemas/sedih/marah`;
- menambah bobot pada `Wellbeing Score`;
- menambah poin pada `Activity Risk Score`;
- bisa memunculkan dominant factor `journal_pressure_terms`.

### 4.2 Dimensi Burnout

| Dimensi | Kata Kunci |
|---|---|
| kelelahan_emosional | lelah, capek, habis energi, terkuras, menguras, kelelahan, burnout, ngantuk, pusing |
| depersonalisasi | sinis, malas, percuma, cuek, acuh, tidak peduli, masa bodoh |
| rendah_pencapaian_diri | gagal, tidak berarti, tidak kompeten, meragukan, tidak becus, sia-sia, tidak berguna |

Dampak:

- setiap dimensi memberi tambahan pada `Activity Risk Score`;
- jika separuh atau lebih jurnal dalam periode punya tekanan/dimensi, sistem memberi factor `journal_pressure_terms`;
- dimensi tertentu bisa mengarahkan rekomendasi activity ke teknik tertentu.

### 4.3 Sinyal Krisis

Kata/frasa krisis:

```text
bunuh diri, mengakhiri hidup, ingin mati, ingin hilang saja,
menyakiti diri, melukai diri, tidak ingin hidup
```

Dampak:

- activity risk minimal menjadi 85;
- final period score minimal menjadi 75;
- kategori otomatis menjadi `merah`;
- rekomendasi utama diarahkan ke `Grounding 3-2-1` dan dukungan manusia.

---

## 5. Intensity Factor Activity

Saat activity dibuat, sistem membaca judul dan category untuk memberi `intensity_factor`.

| Keyword Pada Judul/Category | Intensity Factor |
|---|---:|
| ulangan, ujian | 1.6 |
| matematika, mtk | 1.5 |
| mengajar, rapat, koreksi | 1.4 |
| olahraga | 1.2 |
| istirahat, santai | 0.5 |
| tidur | 0.4 |
| selain keyword di atas | 1.0 |

Jika ada beberapa keyword, rule yang ditemukan lebih dulu dipakai.

Contoh:

| Activity | Durasi | IF | Weighted Hours |
|---|---:|---:|---:|
| Belajar biasa | 2 jam | 1.0 | 2.0 |
| Matematika | 2 jam | 1.5 | 3.0 |
| Ujian Matematika | 2 jam | 1.6 | 3.2 |
| Istirahat | 1 jam | 0.5 | 0.5 |

---

## 6. Workload Score

Kapasitas harian default:

```text
8 jam per hari
```

Formula:

```text
Workload Score = min(100, weighted actual hours / period capacity hours x 100)
```

Period capacity:

| Periode | Rentang Data | Kapasitas |
|---|---|---:|
| Harian | Tanggal yang dipilih | 8 jam |
| Mingguan | 7 hari terakhir sampai tanggal yang dipilih | 7 x 8 jam = 56 jam |
| Bulanan | 30 hari terakhir sampai tanggal yang dipilih | 30 x 8 jam = 240 jam |

Perbedaan dari versi lama MindfulEdu:

| Periode | Versi Lama MindfulEdu | Versi v2.5 Edumindful |
|---|---|---|
| Mingguan | Minggu kalender saat ini | 7 hari terakhir |
| Kapasitas mingguan | 7 x 8 = 56 jam | 7 x 8 = 56 jam |
| Bulanan | Bulan kalender saat ini | 30 hari terakhir |
| Kapasitas bulanan | Hari aktif selesai x 8 jam | 30 x 8 = 240 jam |

Actual hours:

- hanya activity yang sudah check-out dan punya `actual_hours` yang menaikkan workload score;
- activity planned/checked-in tetap tampil di daftar activity, tetapi belum menaikkan skor burnout aktual;
- `weighted_actual_hours = actual_hours x intensity_factor`.

Planned hours tetap disimpan sebagai `weighted_planned_hours` untuk membandingkan rencana dan realisasi.

Contoh harian:

| Weighted Hours | Workload Score |
|---:|---:|
| 2 jam | 25 |
| 4 jam | 50 |
| 6 jam | 75 |
| 8 jam | 100 |
| 10 jam | 125, tetapi final memakai min(100, workload) |

---

## 7. Wellbeing Score

Wellbeing Score membaca tekanan dari mood, intensitas, perubahan mood, kata jurnal, dimensi burnout, dan self report guru.

Formula:

```text
Wellbeing Score =
  negative_ratio x 35
  + average_negative_intensity x 15
  + worsening_ratio x 15
  + dimension_density x 20
  + self_report_component x 15
```

Jika tidak ada self report guru:

```text
self_report_component = negative_ratio
```

Sehingga tanpa self report:

```text
Wellbeing Score =
  negative_ratio x 50
  + average_negative_intensity x 15
  + worsening_ratio x 15
  + dimension_density x 20
```

Komponen:

| Komponen | Cara Hitung |
|---|---|
| negative_ratio | Jumlah sesi negatif / total sesi check-in + check-out |
| average_negative_intensity | Rata-rata bobot intensitas negatif |
| worsening_ratio | max(0, rasio checkout negatif - rasio checkin negatif) |
| dimension_density | Proporsi jurnal yang punya kata tekanan atau dimensi burnout |
| self_report_component | Rata-rata level self report guru / 10 |

Bobot intensitas negatif:

| Kondisi | Nilai |
|---|---:|
| Check-in negatif intensity 1 | 0.1 |
| Check-in negatif intensity 5 | 0.5 |
| Check-in negatif intensity 10 | 1.0 |
| Check-out negatif karena mood cemas/sedih/marah | 0.7 |
| Check-out negatif karena mood terdeteksi lelah | 0.7 |
| Check-out negatif karena kata tekanan saja | 0.5 |

---

## 8. Estimasi Mood Awal Ke Mood Akhir

Estimasi berikut memakai asumsi:

- hanya 1 activity;
- intensity check-in negatif = 5;
- tidak ada self report;
- tidak ada kata tekanan tambahan di jurnal;
- tidak ada dimensi burnout;
- tidak ada crisis flag.

Tabel ini adalah estimasi `Wellbeing Score`, bukan final score.

| Mood Awal \ Mood Akhir | senang | tenang | cemas | sedih | marah |
|---|---:|---:|---:|---:|---:|
| senang | 0 | 0 | 50.5 | 50.5 | 50.5 |
| tenang | 0 | 0 | 50.5 | 50.5 | 50.5 |
| cemas | 32.5 | 32.5 | 59.0 | 59.0 | 59.0 |
| sedih | 32.5 | 32.5 | 59.0 | 59.0 | 59.0 |
| marah | 32.5 | 32.5 | 59.0 | 59.0 | 59.0 |

Catatan:

- nilai `0` pada kombinasi hijau seperti `senang -> senang` berarti tidak ada tekanan wellbeing;
- final score tetap dapat naik dari workload aktual, walaupun biasanya masih hijau jika durasi dan IF tidak tinggi;
- aktivitas positif tetap tercatat sebagai aktivitas, jurnal, review, dan breakdown.

Contoh yang ditanyakan:

```text
Mood awal senang -> mood akhir marah
negative_ratio = 1 checkout negatif / 2 sesi = 0.5
average_negative_intensity = 0.7
worsening_ratio = 1 - 0 = 1
dimension_density = 0

Wellbeing = 0.5 x 50 + 0.7 x 15 + 1 x 15
          = 25 + 10.5 + 15
          = 50.5
```

Jika jurnal juga berisi kata tekanan seperti `lelah`, `stres`, `kewalahan`, maka `dimension_density` biasanya menjadi 1 untuk activity tunggal.

| Kondisi Tambahan Jurnal | Estimasi Wellbeing |
|---|---:|
| senang -> marah tanpa kata tekanan tambahan | 50.5 |
| senang -> marah dengan kata tekanan/dimensi | 70.5 |
| senang -> tenang tetapi jurnal berisi tekanan | 67.5 |
| cemas -> tenang tetapi jurnal berisi tekanan | 77.5 |
| cemas -> marah dengan kata tekanan/dimensi | 79.0 |
| ada kata krisis | minimal 85 pada wellbeing/service ML dan final period minimal merah |

---

## 9. Activity Risk Score

Setiap activity juga punya skor risiko sendiri untuk breakdown dan journal review.

Formula ringkas:

```text
Activity Risk Score =
  base workload activity
  + mood check-in negatif
  + mood check-out negatif
  + kata tekanan jurnal
  + dimensi burnout
  + crisis floor
```

Detail:

| Komponen | Poin |
|---|---:|
| Base workload activity | min(35, effective_hours x IF / 8 x 100) |
| Check-in cemas/sedih/marah | 10 + intensity/10 x 10 |
| Check-out cemas/sedih/marah | +20 |
| Check-out negatif karena mood | skor minimal dinaikkan ke 40 |
| Jurnal berisi kata tekanan | +12 |
| Setiap dimensi burnout | +10, maksimal +20 |
| Crisis flag | skor minimal 85 |
| Maksimal skor activity | 100 |

Sinyal burnout pada activity:

- mood check-in `cemas`, `sedih`, atau `marah`;
- mood check-out atau mood terdeteksi `cemas`, `sedih`, `marah`, atau `lelah`;
- jurnal berisi kata tekanan;
- ada dimensi burnout manual/otomatis;
- ada crisis flag.

Jika tidak ada sinyal di atas, contoh `senang -> senang` dengan jurnal positif tetap mendapat skor workload activity. Skor ini biasanya kecil sampai sedang dan tetap berada di kategori hijau selama durasi/IF tidak tinggi.

Contoh `senang -> marah`:

| Durasi/IF | Base | Mood Poin | Floor | Activity Score |
|---|---:|---:|---:|---:|
| 1 jam, IF 1.0 | 12.5 | +20 | minimal 40 | 40 |
| 2 jam, IF 1.0 | 25.0 | +20 | tidak perlu floor | 45 |
| 2 jam, IF 1.5 | 35.0 | +20 | tidak perlu floor | 55 |
| 2 jam, IF 1.5 + jurnal stres | 35.0 | +20 +12 | tidak perlu floor | 67 |
| 2 jam, IF 1.5 + stres + 1 dimensi | 35.0 | +20 +12 +10 | tidak perlu floor | 77 |

---

## 10. Final Score dan Kategori

Kategori final:

| Kategori | Rentang Score | Makna |
|---|---:|---|
| hijau | 0 - 39.99 | Beban dan jurnal relatif terkendali |
| kuning | 40 - 69.99 | Ada tanda tekanan atau perlu pemulihan |
| merah | 70 - 100 | Beban/jurnal tinggi dan perlu perhatian |

Risk floor:

- jika ada `checkout_negative_mood`, `journal_pressure_terms`, `teacher_self_report_high`, atau `high_wellbeing_pressure`, score minimal dinaikkan ke 40;
- jika ada crisis flag, final score minimal 75 dan kategori menjadi merah.

Catatan hijau:

- mood positif tidak menambah tekanan wellbeing;
- workload tetap menambah final score;
- kategori tetap hijau selama final score berada di bawah 40.

Contoh final:

```text
Activity 2 jam biasa, senang -> marah
Workload = 2 / 8 x 100 = 25
Wellbeing = 50.5
Final = 0.5 x 25 + 0.5 x 50.5 = 37.75
Risk floor karena checkout negative mood -> minimal 40
Kategori = kuning
```

```text
Activity 2 jam matematika, senang -> marah, jurnal berisi stres
Weighted hours = 2 x 1.5 = 3
Workload = 3 / 8 x 100 = 37.5
Wellbeing = 70.5
Final = 0.5 x 37.5 + 0.5 x 70.5 = 54
Kategori = kuning
```

```text
4 activity intensif masing-masing 2 jam, IF 1.5
Weighted hours = 12
Workload = min(100, 12 / 8 x 100) = 100
Jika wellbeing juga tinggi, kategori bisa merah
```

---

## 11. Dominant Factors

Dominant factors adalah alasan utama kenapa sistem memberi kategori/rekomendasi tertentu.

| Factor | Kondisi Muncul |
|---|---|
| workload_over_capacity | Tidak muncul pada v2.5 karena Workload Score sudah dicap maksimal 100 |
| dense_workload | Workload Score >= 80 |
| high_wellbeing_pressure | Wellbeing Score >= 70 |
| teacher_self_report_high | Rata-rata self report guru >= 7 |
| crisis_flag | Ada kata/frasa krisis |
| checkout_negative_mood | >= 50% jurnal check-out negatif |
| journal_pressure_terms | >= 50% jurnal punya kata tekanan atau dimensi burnout |
| consecutive_high_intensity | Minimal 2 activity selesai dengan IF >= 1.5 |
| late_activity | Ada activity selesai dengan jam akhir >= 18.00 |
| balanced_period | Tidak ada faktor dominan lain |

---

## 12. Rekomendasi Berdasarkan Periode

Pada versi terbaru, rekomendasi utama di screen analisis mengikuti category dan dominant factors pada periode analisis, bukan activity terakhir saja.

Artinya:

- sistem membaca seluruh activity dalam periode;
- activity positif/stabil tetap menjadi konteks aktivitas dan tetap masuk review;
- activity terakhir yang punya jurnal hanya ditampilkan sebagai `latest_activity_review`;
- `latest_activity_review` tidak menimpa rekomendasi utama periode;
- jika tidak ada sinyal burnout, rekomendasi berupa latihan maintenance seperti Awareness of Breathing atau Jeda Napas 3 Menit.

Fallback rule activity jika ada sinyal burnout:

| Kondisi Activity/Jurnal | Rekomendasi |
|---|---|
| Ada crisis flag | Grounding 3-2-1 |
| Mood terdeteksi/checkout `marah` | Teknik STOP |
| Dimensi `kelelahan_emosional` atau mood `lelah` | Body Scan Singkat |
| Mood terdeteksi/checkout `cemas` | Napas 4-7-8 |
| Mood terdeteksi/checkout `sedih` | Loving-Kindness Meditation |
| Dimensi `rendah_pencapaian_diri` | Loving-Kindness Meditation |
| Mood terdeteksi/checkout `senang` | Informal Mindfulness |
| Selain kondisi di atas | Mindful Breathing |

Catatan production:

- service FastAPI juga punya rule fallback yang sangat mirip;
- jika Gemini aktif, Gemini dapat memilih teknik dari katalog yang diizinkan;
- backend tetap menormalisasi agar teknik yang keluar ada di katalog MindfulEdu.

---

## 13. Matrix Rekomendasi

Sistem menghitung rekomendasi periode berdasarkan category dan dominant factors.

Rule prioritas periode:

| Prioritas | Kondisi | Practice Code |
|---:|---|---|
| 1 | crisis_flag | grounding_321 |
| 2 | teacher_self_report_high | body_scan_full |
| 3 | journal_pressure_terms | sitting_meditation |
| 4 | checkout_negative_mood | body_scan_micro |
| 5 | consecutive_high_intensity atau dense_workload | mindful_movement |
| 6 | merah untuk siswa | grounding_321 |
| 7 | merah untuk guru/role lain | body_scan_full |
| 8 | kuning | body_scan_micro |
| 9 | hijau untuk siswa | breathing_space_3min |
| 10 | hijau untuk guru | maintain_breath_awareness |
| 11 | data belum cukup/default | breathing_space_3min |

Pada tampilan analisis terbaru, teknik utama diarahkan oleh category dan dominant factors periode tersebut.

---

## 14. Daftar Teknik Mindfulness

| Code | Teknik | Durasi | Biasanya Cocok Untuk |
|---|---|---:|---|
| stop_technique | Teknik STOP | 2 menit | marah, impulsif, konflik, cemas |
| grounding_321 | Grounding 3-2-1 | 3 menit | cemas, panik, krisis, kewalahan |
| breathing_478 | Napas 4-7-8 | 5 menit | cemas, tegang, sulit tidur, stres |
| breathing_space_3min | Jeda Napas 3 Menit | 3 menit | transisi aktivitas, fokus, tekanan ringan |
| maintain_breath_awareness | Awareness of Breathing | 3 menit | kondisi hijau, fokus, ritme stabil |
| mindful_breathing | Mindful Breathing | 5 menit | netral, sulit fokus, latihan awal |
| focused_attention | Focused Attention Meditation | 5 menit | distraksi, sulit konsentrasi |
| sitting_meditation | Sitting Meditation | 10 menit | jurnal tekanan, banyak pikiran, kewalahan |
| body_scan_micro | Body Scan Singkat | 10 menit | mood negatif, lelah, pemulihan |
| body_scan_full | Body Scan Penuh | 20 menit | tekanan tinggi, self report guru tinggi |
| mindful_movement | Mindful Movement | 10 menit | workload padat, pegal, duduk lama |
| walking_meditation | Walking Meditation | 5 menit | jenuh, butuh jeda aktif |
| open_monitoring | Open Monitoring | 10 menit | pikiran ramai, emosi bercampur |
| mindfulness_of_sounds | Mindfulness of Sounds | 5 menit | grounding melalui suara |
| rain_self_compassion | RAIN | 7 menit | emosi berat, frustrasi, self-compassion |
| loving_kindness | Loving-Kindness Meditation | 7 menit | sedih, rendah pencapaian diri, konflik |
| mountain_meditation | Mountain Meditation | 15 menit | emosi naik turun, tekanan tinggi |
| informal_mindfulness | Informal Mindfulness | 3 menit | mood senang/stabil, maintenance |
| reflective_journal | Jurnal Reflektif Harian | 5 menit | refleksi, membaca pola tekanan |

---

## 15. Contoh Skenario Lengkap

### 15.1 Senang Ke Marah

Input:

```text
Activity: Belajar biasa
Durasi: 2 jam
IF: 1.0
Mood check-in: senang
Mood check-out: marah
Jurnal: "Saya kesal karena tugas tidak selesai."
```

Estimasi:

```text
Weighted actual hours = 2
Workload = 25
Wellbeing dasar senang -> marah = 50.5
Kata "kesal" mendeteksi mood marah, tetapi bukan pressure keyword period utama
Activity risk minimal masuk area kuning karena checkout marah
Rekomendasi dari review activity berisiko = Teknik STOP
Final kemungkinan = sekitar kuning
```

### 15.2 Tenang Ke Cemas Dengan Jurnal Stres

Input:

```text
Mood check-in: tenang
Mood check-out: cemas
Jurnal: "Saya stres dan kewalahan setelah kegiatan ini."
```

Estimasi:

```text
Wellbeing sekitar 70.5
Dominant factor bisa high_wellbeing_pressure dan journal_pressure_terms
Review activity kemungkinan menyarankan Napas 4-7-8
Jika pressure terms dominan di periode, rekomendasi periode bisa Sitting Meditation
Tampilan analisis utama tetap berdasarkan category dan dominant factors periode
```

### 15.3 Cemas Ke Tenang Tetapi Jurnal Masih Berat

Input:

```text
Mood check-in: cemas, intensity 5
Mood check-out: tenang
Jurnal: "Saya masih capek dan pusing, tetapi kelas selesai."
```

Estimasi:

```text
Mood akhir membaik, tetapi jurnal punya pressure terms
Wellbeing sekitar 77.5 untuk satu activity karena check-in negatif + jurnal tekanan
Dimensi bisa kelelahan_emosional
Review activity kemungkinan menyarankan Body Scan Singkat
```

### 15.4 Senang Ke Senang

Input:

```text
Mood check-in: senang
Mood check-out: senang
Jurnal: "Kegiatan berjalan seru dan saya merasa lebih semangat."
```

Estimasi:

```text
Wellbeing = 0
Activity Risk Score mengikuti workload activity
Activity tetap masuk activity_count, completed_activity_count, journal_count, dan activity_breakdown
Activity tetap masuk journal_reviews
Final score berasal dari workload, kategori hijau jika skor di bawah 40
Rekomendasi utama berupa maintenance, misalnya Awareness of Breathing atau Jeda Napas 3 Menit
```

### 15.5 Ada Sinyal Krisis

Input:

```text
Jurnal memuat frasa krisis seperti ingin mati atau menyakiti diri.
```

Estimasi:

```text
Activity risk minimal 85
Final score minimal 75
Kategori merah
Rekomendasi utama = Grounding 3-2-1
Risk reduction steps mengarahkan user menghubungi orang tepercaya/pendamping sekolah
```

---

## 16. Catatan Penting Tentang AI

Sistem memiliki dua lapisan:

| Lapisan | Fungsi |
|---|---|
| Rule Laravel | Fallback utama jika ML/Gemini gagal dan penjaga konsistensi data |
| FastAPI/Gemini | Membantu membaca jurnal dan membuat bahasa rekomendasi lebih natural |

AI/Gemini boleh membuat variasi kalimat, tetapi tidak boleh mengarang teknik baru. Teknik harus berasal dari katalog MindfulEdu.

Jika hasil AI berbeda dengan rule periode, backend tetap menormalisasi hasil agar teknik yang keluar berasal dari katalog MindfulEdu dan sesuai kesimpulan periode.

---

## 17. Checklist Debug Rekomendasi

Jika rekomendasi terasa tidak sesuai, cek:

```text
[ ] Activity dalam periode sudah check-out
[ ] Mood check-out activity benar
[ ] Jurnal activity berisiko berisi kata yang sesuai
[ ] checkout_mood_detected terbaca sesuai isi jurnal
[ ] checkout_crisis_flag tidak aktif kecuali memang ada kata krisis
[ ] checkout_auto_burnout_tags tidak salah mendeteksi dimensi
[ ] payload.journal_reviews[0].recommended_tactic benar
[ ] recommendation_summary.practice_code sesuai dominant_factors/kesimpulan periode
[ ] APK terbaru sudah diinstall ulang dari /download/android
```

Endpoint/field penting:

```text
payload.journal_reviews
payload.journal_reviews[0].recommended_tactic
recommendation_summary.practice_code
recommendation_summary.practice_title
recommendation_summary.latest_activity_review
payload.activity_breakdown
```

---

## 18. Ringkasan Paling Cepat

```text
Mood negatif awal = cemas/sedih/marah menambah tekanan.
Mood negatif akhir = cemas/sedih/marah lebih kuat dampaknya.
Jurnal berisi stres/lelah/kewalahan bisa membuat check-out dianggap negatif.
Crisis keyword langsung menaikkan risiko ke merah.
Workload dihitung dari durasi x intensity factor dibanding kapasitas periode: harian 8 jam, mingguan 56 jam, bulanan 240 jam.
Final score = 50% workload + 50% wellbeing.
Rekomendasi utama sekarang mengikuti category dan dominant factors periode analisis.
```
