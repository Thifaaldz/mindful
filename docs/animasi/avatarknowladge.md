# README Step-by-Step Animasi Tambahan MindfulEdu

Dokumen ini khusus untuk teknik mindfulness tambahan yang saat ini belum punya asset animasi. Teknik utama 11 kategori sudah punya 74 gambar, sedangkan daftar di bawah ini masih perlu dibuatkan gambar/avatar animasinya.

Tujuan dokumen:

- menjadi brief pembuatan gambar animasi baru;
- memastikan setiap step punya visual yang jelas;
- menjaga nama file asset konsisten dengan aplikasi Flutter;
- membantu developer memasang asset ke guided practice tanpa menebak-nebak.

Lokasi asset yang disarankan di aplikasi:

```text
mindfuledu/assets/images/mindfulness/
```

Format nama file:

```text
{category}_{nomor_step}_{nama_singkat}.png
```

Contoh:

```text
stop_technique_01_stop.png
grounding_321_02_hear.png
breathing_478_04_exhale_8.png
```

---

## Ringkasan Teknik Yang Belum Ada Animasi

| No | Teknik | Category | Durasi | Jumlah Step | Status Asset |
|---:|---|---|---:|---:|---|
| 1 | Teknik STOP | `stop_technique` | 2 menit | 4 | Sudah dipasang |
| 2 | Grounding 3-2-1 | `grounding_321` | 3 menit | 4 | Sudah dipasang |
| 3 | Napas 4-7-8 | `breathing_478` | 5 menit | 5 | Sudah dipasang |
| 4 | Jeda Napas 3 Menit | `breathing_space_3min` | 3 menit | 4 | Sudah dipasang |
| 5 | Awareness of Breathing | `maintain_breath_awareness` | 3 menit | 5 | Sudah dipasang |
| 6 | RAIN | `rain_self_compassion` | 7 menit | 5 | Sudah dipasang |
| 7 | Jurnal Reflektif Harian | `reflective_journal` | 5 menit | 5 | Belum ada |
|  | Total |  |  | 32 step | 32 gambar dibutuhkan |

Total gambar baru yang dibutuhkan: **32 PNG**.
Total gambar yang sudah dipasang ke aplikasi: **27 PNG**.
Sisa gambar yang belum ada: **5 PNG** untuk Jurnal Reflektif Harian.

---

## Prinsip Visual Avatar

Gunakan style yang konsisten dengan 74 animasi utama:

- karakter/avatar lembut, ramah, dan aman untuk siswa/guru;
- latar sederhana, tidak ramai, dan tidak mengganggu teks instruksi;
- tiap gambar fokus pada satu aksi utama sesuai step;
- ekspresi avatar tenang, suportif, dan tidak berlebihan;
- warna tetap hangat dan edukatif;
- gambar tidak perlu memuat teks panjang karena instruksi sudah dibaca aplikasi/TTS;
- hindari visual yang terlihat seperti terapi klinis berat atau diagnosis medis.

Ukuran asset yang disarankan:

```text
1024 x 1024 px atau rasio kotak
PNG
Background bersih
File size tetap wajar untuk APK
```

---

## 1. Teknik STOP

Category:

```text
stop_technique
```

Fungsi:

Teknik STOP adalah jeda cepat ketika pengguna mulai impulsif, marah, cemas, atau ingin bereaksi terlalu cepat. Latihan ini membantu pengguna berhenti sebentar, bernapas, mengamati kondisi diri, lalu memilih respons yang lebih sadar.

Cocok untuk:

- marah;
- cemas;
- konflik;
- reaksi impulsif;
- sebelum mengambil keputusan.

Jumlah gambar dibutuhkan: **4 gambar**.

| Step | Nama Step | Instruksi di Aplikasi | Visual yang Dibutuhkan | Nama File Standar |
|---:|---|---|---|---|
| 1 | Stop | Stop: hentikan aktivitas sejenak. | Avatar berdiri atau duduk diam dengan gesture tangan berhenti, suasana tenang, tanda jeda sederhana. | `stop_technique_01_stop.png` |
| 2 | Take a Breath | Take a breath: tarik dan hembuskan napas perlahan. | Avatar menarik napas perlahan, dada/napas divisualkan dengan garis lembut. | `stop_technique_02_take_breath.png` |
| 3 | Observe | Observe: amati tubuh, pikiran, dan emosi. | Avatar memperhatikan tubuh dan pikiran, ada elemen kecil seperti ikon hati, kepala, dan tubuh. | `stop_technique_03_observe.png` |
| 4 | Proceed | Proceed: lanjutkan dengan tindakan yang lebih sadar. | Avatar melangkah pelan atau kembali beraktivitas dengan ekspresi lebih stabil. | `stop_technique_04_proceed.png` |

Alur tampilan:

```text
Pengguna merasa butuh jeda
  -> membuka Teknik STOP
  -> melihat avatar Step 1
  -> mengikuti instruksi napas
  -> mengamati kondisi diri
  -> memilih respons berikutnya
```

Catatan implementasi:

- gunakan animasi ringan seperti scale pulse atau fade antar step;
- step ini cocok untuk mode cepat, jangan terlalu banyak elemen visual;
- gambar harus mudah dipahami dalam 2 menit latihan.

---

## 2. Grounding 3-2-1

Category:

```text
grounding_321
```

Fungsi:

Grounding 3-2-1 mengembalikan perhatian pengguna ke lingkungan nyata melalui hal yang dilihat, didengar, dan dirasakan. Teknik ini membantu ketika pikiran terlalu ramai, cemas, atau tubuh terasa panik.

Cocok untuk:

- cemas;
- panik;
- kewalahan;
- pikiran terlalu penuh;
- butuh kembali ke saat ini.

Jumlah gambar dibutuhkan: **4 gambar**.

| Step | Nama Step | Instruksi di Aplikasi | Visual yang Dibutuhkan | Nama File Standar |
|---:|---|---|---|---|
| 1 | Lihat 3 Hal | Sebutkan tiga hal yang terlihat di sekitar. | Avatar melihat sekitar kelas/ruang belajar, ada 3 objek sederhana yang terlihat jelas. | `grounding_321_01_see_three.png` |
| 2 | Dengar 2 Suara | Sebutkan dua suara yang terdengar saat ini. | Avatar mendengarkan dengan lembut, ada 2 gelombang suara/objek sumber suara. | `grounding_321_02_hear_two.png` |
| 3 | Rasakan 1 Sensasi | Sebutkan satu sensasi fisik yang terasa jelas. | Avatar menyentuh dada/tangan atau merasakan kaki di lantai, fokus pada sensasi tubuh. | `grounding_321_03_feel_one.png` |
| 4 | Tenangkan Tubuh | Tarik napas pelan dan rasakan tubuh lebih menetap. | Avatar bernapas pelan dengan postur stabil, lingkungan terasa lebih tenang. | `grounding_321_04_settle.png` |

Alur tampilan:

```text
Pengguna membuka Grounding 3-2-1
  -> mencari 3 hal yang terlihat
  -> mendengar 2 suara
  -> merasakan 1 sensasi tubuh
  -> menutup dengan napas pelan
```

Catatan implementasi:

- boleh memakai visual angka 3, 2, 1 kecil sebagai penanda, tetapi jangan dominan;
- objek lingkungan sebaiknya umum untuk sekolah: buku, meja, jendela, papan tulis;
- step harus terasa interaktif karena pengguna mengamati lingkungan sendiri.

---

## 3. Napas 4-7-8

Category:

```text
breathing_478
```

Fungsi:

Napas 4-7-8 membantu menurunkan ketegangan tubuh dengan pola napas: tarik 4 hitungan, tahan 7 hitungan, lalu buang 8 hitungan. Teknik ini cocok untuk menenangkan tubuh secara bertahap.

Cocok untuk:

- cemas;
- sulit tidur;
- tegang;
- stres;
- tubuh terasa aktif berlebihan.

Jumlah gambar dibutuhkan: **5 gambar**.

| Step | Nama Step | Instruksi di Aplikasi | Visual yang Dibutuhkan | Nama File Standar |
|---:|---|---|---|---|
| 1 | Posisi Nyaman | Duduk nyaman dan rilekskan bahu. | Avatar duduk nyaman, bahu rileks, tangan di pangkuan. | `breathing_478_01_prepare.png` |
| 2 | Tarik 4 | Tarik napas selama 4 hitungan. | Avatar menarik napas, garis napas masuk, angka 4 kecil sebagai penanda hitungan. | `breathing_478_02_inhale_4.png` |
| 3 | Tahan 7 | Tahan napas lembut selama 7 hitungan. | Avatar diam tenang, lingkaran napas tertahan, angka 7 kecil. | `breathing_478_03_hold_7.png` |
| 4 | Buang 8 | Hembuskan perlahan selama 8 hitungan. | Avatar menghembuskan napas panjang, garis napas keluar lebih panjang, angka 8 kecil. | `breathing_478_04_exhale_8.png` |
| 5 | Ulangi | Ulangi sampai waktu latihan selesai. | Avatar dalam ritme napas berulang, visual loop lembut/lingkaran napas. | `breathing_478_05_repeat.png` |

Alur tampilan:

```text
Pengguna duduk nyaman
  -> tarik napas 4 hitungan
  -> tahan 7 hitungan
  -> buang 8 hitungan
  -> ulangi beberapa siklus
```

Catatan implementasi:

- step 2, 3, dan 4 sebaiknya punya visual hitungan yang berbeda;
- visual buang napas dibuat lebih panjang agar pola 4-7-8 terasa jelas;
- hindari instruksi visual yang membuat pengguna menahan napas terlalu tegang.

---

## 4. Jeda Napas 3 Menit

Category:

```text
breathing_space_3min
```

Fungsi:

Jeda Napas 3 Menit adalah latihan transisi pendek. Pengguna menyadari kondisi saat ini, mengumpulkan perhatian pada napas, lalu memperluas kesadaran ke tubuh sebelum melanjutkan aktivitas.

Cocok untuk:

- transisi aktivitas;
- fokus;
- tekanan ringan;
- sebelum kelas;
- setelah aktivitas berat.

Jumlah gambar dibutuhkan: **4 gambar**.

| Step | Nama Step | Instruksi di Aplikasi | Visual yang Dibutuhkan | Nama File Standar |
|---:|---|---|---|---|
| 1 | Sadari Kondisi | Menit pertama: sadari apa yang sedang dirasakan. | Avatar duduk tenang sambil mengenali pikiran dan emosi, elemen awan/gelombang halus. | `breathing_space_3min_01_awareness.png` |
| 2 | Fokus Napas | Menit kedua: fokus pada napas masuk dan keluar. | Avatar fokus ke napas, visual napas masuk-keluar sederhana. | `breathing_space_3min_02_breath.png` |
| 3 | Perluas Tubuh | Menit ketiga: perluas perhatian ke seluruh tubuh. | Avatar menyadari seluruh tubuh dari kepala sampai kaki, aura tubuh lembut. | `breathing_space_3min_03_expand_body.png` |
| 4 | Niat Lembut | Tutup dengan satu niat sederhana. | Avatar membuka mata/tersenyum lembut, siap melanjutkan aktivitas. | `breathing_space_3min_04_intention.png` |

Alur tampilan:

```text
Menit 1: sadari kondisi
  -> Menit 2: fokus ke napas
  -> Menit 3: perluas ke tubuh
  -> tutup dengan niat sederhana
```

Catatan implementasi:

- tiap gambar bisa dipakai selama sekitar 45 detik;
- visual harus terasa seperti transisi cepat, bukan sesi meditasi panjang;
- cocok dibuat sederhana agar tidak terasa berat.

---

## 5. Awareness of Breathing

Category:

```text
maintain_breath_awareness
```

Fungsi:

Awareness of Breathing melatih pengguna hadir pada napas natural tanpa mengubahnya. Saat perhatian berpindah, pengguna cukup menyadari lalu kembali ke napas.

Cocok untuk:

- fokus;
- tenang;
- ritme stabil;
- latihan dasar mindfulness;
- menjaga perhatian sebelum aktivitas.

Jumlah gambar dibutuhkan: **5 gambar**.

| Step | Nama Step | Instruksi di Aplikasi | Visual yang Dibutuhkan | Nama File Standar |
|---:|---|---|---|---|
| 1 | Duduk Stabil | Duduk stabil dengan punggung nyaman. | Avatar duduk tegak namun rileks, posisi tubuh stabil. | `maintain_breath_awareness_01_sit_stable.png` |
| 2 | Napas Masuk | Rasakan napas masuk sebagaimana adanya. | Avatar menyadari napas masuk, garis lembut menuju hidung/dada. | `maintain_breath_awareness_02_in_breath.png` |
| 3 | Napas Keluar | Rasakan napas keluar sebagaimana adanya. | Avatar menyadari napas keluar, garis lembut keluar dari hidung/dada. | `maintain_breath_awareness_03_out_breath.png` |
| 4 | Kembali Dari Distraksi | Saat terdistraksi, sadari lalu kembali ke napas. | Avatar dengan pikiran kecil lewat lalu kembali ke napas, tanpa ekspresi frustrasi. | `maintain_breath_awareness_04_return.png` |
| 5 | Napas Panjang | Akhiri dengan satu napas panjang. | Avatar mengambil satu napas panjang dan tampak lebih stabil. | `maintain_breath_awareness_05_long_breath.png` |

Alur tampilan:

```text
Duduk stabil
  -> sadari napas masuk
  -> sadari napas keluar
  -> kembali saat terdistraksi
  -> tutup dengan napas panjang
```

Catatan implementasi:

- teknik ini mirip Mindful Breathing, tetapi visualnya dibuat lebih sederhana dan natural;
- jangan tampilkan napas sebagai sesuatu yang harus diatur kuat;
- fokus visual pada "menjaga awareness", bukan mengubah pola napas.

---

## 6. RAIN

Category:

```text
rain_self_compassion
```

Fungsi:

RAIN adalah latihan untuk emosi berat. Pengguna mengenali emosi, mengizinkan emosi hadir, menyelidiki sensasi tubuh, lalu merawat diri dengan respons yang lebih lembut.

Kepanjangan RAIN:

```text
R = Recognize
A = Allow
I = Investigate
N = Nurture
```

Cocok untuk:

- sedih;
- marah;
- frustrasi;
- tekanan emosional;
- merasa keras pada diri sendiri.

Jumlah gambar dibutuhkan: **5 gambar**.

| Step | Nama Step | Instruksi di Aplikasi | Visual yang Dibutuhkan | Nama File Standar |
|---:|---|---|---|---|
| 1 | Recognize | Recognize: kenali emosi yang sedang muncul. | Avatar menyadari emosi, ada ikon hati/awan emosi di sekitar tanpa kesan menakutkan. | `rain_self_compassion_01_recognize.png` |
| 2 | Allow | Allow: izinkan emosi hadir tanpa dilawan. | Avatar duduk menerima emosi, tangan terbuka, suasana aman. | `rain_self_compassion_02_allow.png` |
| 3 | Investigate | Investigate: rasakan di bagian tubuh mana emosi itu muncul. | Avatar memperhatikan tubuh, area dada/perut diberi highlight lembut. | `rain_self_compassion_03_investigate.png` |
| 4 | Nurture | Nurture: beri kalimat baik untuk diri sendiri. | Avatar memeluk diri sendiri atau tangan di dada dengan ekspresi lembut. | `rain_self_compassion_04_nurture.png` |
| 5 | Langkah Aman | Pilih satu langkah kecil yang aman setelah latihan. | Avatar mengambil langkah kecil atau menulis pilihan sederhana, ekspresi lebih tenang. | `rain_self_compassion_05_safe_step.png` |

Alur tampilan:

```text
Kenali emosi
  -> izinkan emosi hadir
  -> rasakan jejaknya di tubuh
  -> rawat diri dengan kalimat baik
  -> pilih langkah kecil yang aman
```

Catatan implementasi:

- jangan buat visual emosi terlalu gelap atau dramatis;
- teknik ini harus terasa suportif dan aman;
- cocok diberi visual self-compassion seperti tangan di dada atau memeluk diri.

---

## 7. Jurnal Reflektif Harian

Category:

```text
reflective_journal
```

Fungsi:

Jurnal Reflektif Harian membantu pengguna membaca pengalaman hariannya. Teknik ini mengubah kejadian, perasaan, pola, dan rencana kecil menjadi informasi yang lebih jelas.

Cocok untuk:

- refleksi;
- membaca pola jurnal;
- rendah pencapaian diri;
- setelah check-out;
- menutup hari.

Jumlah gambar dibutuhkan: **5 gambar**.

| Step | Nama Step | Instruksi di Aplikasi | Visual yang Dibutuhkan | Nama File Standar |
|---:|---|---|---|---|
| 1 | Fakta Hari Ini | Tulis satu hal yang paling menguras energi hari ini. | Avatar menulis di jurnal, ada ikon aktivitas/kejadian hari ini. | `reflective_journal_01_energy_drain.png` |
| 2 | Perasaan Dominan | Tulis perasaan yang paling dominan. | Avatar memilih/mengenali emosi, ada beberapa simbol mood kecil. | `reflective_journal_02_dominant_feeling.png` |
| 3 | Pola Terlihat | Tulis pola yang mulai terlihat. | Avatar melihat catatan dengan garis/pola sederhana yang terhubung. | `reflective_journal_03_notice_pattern.png` |
| 4 | Lepaskan Hal Kecil | Tulis satu hal kecil yang bisa dilepaskan atau ditunda. | Avatar menutup/menaruh beban kecil, visual ringan tentang melepaskan. | `reflective_journal_04_let_go.png` |
| 5 | Rencana Besok | Tutup dengan rencana lembut untuk besok. | Avatar menulis rencana kecil untuk besok, kalender/buku sederhana. | `reflective_journal_05_tomorrow_plan.png` |

Alur tampilan:

```text
Tulis fakta yang menguras energi
  -> tulis perasaan dominan
  -> temukan pola
  -> pilih hal kecil yang bisa dilepas
  -> tutup dengan rencana lembut
```

Catatan implementasi:

- visual harus mendukung aktivitas menulis, bukan meditasi diam;
- hindari terlalu banyak teks di gambar;
- gambar boleh menampilkan buku, pena, kalender, dan simbol mood.

---

## Daftar Nama File Yang Perlu Dibuat

Gunakan daftar ini sebagai checklist saat membuat atau menyalin gambar ke project.

### Teknik STOP

```text
stop_technique_01_stop.png
stop_technique_02_take_breath.png
stop_technique_03_observe.png
stop_technique_04_proceed.png
```

### Grounding 3-2-1

```text
grounding_321_01_see_three.png
grounding_321_02_hear_two.png
grounding_321_03_feel_one.png
grounding_321_04_settle.png
```

### Napas 4-7-8

```text
breathing_478_01_prepare.png
breathing_478_02_inhale_4.png
breathing_478_03_hold_7.png
breathing_478_04_exhale_8.png
breathing_478_05_repeat.png
```

### Jeda Napas 3 Menit

```text
breathing_space_3min_01_awareness.png
breathing_space_3min_02_breath.png
breathing_space_3min_03_expand_body.png
breathing_space_3min_04_intention.png
```

### Awareness of Breathing

```text
maintain_breath_awareness_01_sit_stable.png
maintain_breath_awareness_02_in_breath.png
maintain_breath_awareness_03_out_breath.png
maintain_breath_awareness_04_return.png
maintain_breath_awareness_05_long_breath.png
```

### RAIN

```text
rain_self_compassion_01_recognize.png
rain_self_compassion_02_allow.png
rain_self_compassion_03_investigate.png
rain_self_compassion_04_nurture.png
rain_self_compassion_05_safe_step.png
```

### Jurnal Reflektif Harian

```text
reflective_journal_01_energy_drain.png
reflective_journal_02_dominant_feeling.png
reflective_journal_03_notice_pattern.png
reflective_journal_04_let_go.png
reflective_journal_05_tomorrow_plan.png
```

---

## Checklist Setelah Asset Dibuat

```text
[x] 27 gambar PNG teknik 12-17 sudah dibuat
[x] Nama file teknik 12-17 sesuai daftar standar
[x] Semua gambar teknik 12-17 dipindah ke mindfuledu/assets/images/mindfulness/
[x] pubspec.yaml sudah include assets/images/mindfulness/
[x] Mapping asset teknik 12-17 ditambahkan di kabat_zinn_practice_screen.dart
[x] Setiap category tambahan punya assetKey
[ ] 5 gambar Jurnal Reflektif Harian sudah dibuat
[ ] Flutter analyze sukses
[ ] Guided practice dicek di emulator/perangkat
[ ] Tidak ada gambar yang terpotong di layar kecil
```

---

## Mapping Yang Perlu Ditambahkan Ke Flutter

Setelah gambar tersedia, category berikut perlu dihubungkan ke asset map guided practice:

| Category | Asset Key Yang Disarankan |
|---|---|
| `stop_technique` | `stop_technique` |
| `grounding_321` | `grounding_321` |
| `breathing_478` | `breathing_478` |
| `breathing_space_3min` | `breathing_space_3min` |
| `maintain_breath_awareness` | `maintain_breath_awareness` |
| `rain_self_compassion` | `rain_self_compassion` |
| `reflective_journal` | `reflective_journal` |

Contoh struktur mapping:

```text
stop_technique:
  1 -> stop_technique_01_stop.png
  2 -> stop_technique_02_take_breath.png
  3 -> stop_technique_03_observe.png
  4 -> stop_technique_04_proceed.png
```

Jika mapping belum ditambahkan, aplikasi tetap bisa memakai visual fallback bawaan. Setelah asset tersedia dan mapping dipasang, setiap step akan menampilkan avatar animasi sesuai file.
