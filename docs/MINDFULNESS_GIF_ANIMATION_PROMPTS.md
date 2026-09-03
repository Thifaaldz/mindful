# README Animasi GIF Teknik Mindfulness

Dokumen ini menjelaskan kebutuhan animasi `.gif` untuk fitur guided mindfulness di MindfulEdu. Hitungan dibuat berdasarkan dokumen:

```text
docs/mindfull tools and teknis.md
```

Tujuan dokumen ini:

- menghitung jumlah langkah latihan yang membutuhkan animasi;
- menentukan jumlah GIF per teknik;
- memberi nama file yang konsisten;
- menyediakan prompt untuk meminta atau membuat animasi;
- menjaga style visual agar semua teknik terasa satu keluarga desain.

## Ringkasan Jumlah Animasi

Prinsip hitungan:

- 1 langkah unik = 1 animasi GIF.
- Durasi berbeda memakai ulang animasi yang sama.
- Contoh: Mindful Breathing 3 menit, 5 menit, dan 10 menit tetap memakai aset yang sama untuk persiapan, napas, distraksi, dan penutup.
- Informal Mindfulness dihitung sebagai 3 sub-teknik karena alurnya berbeda: drinking, eating, dan walking to class.

| No | Teknik | Jumlah langkah unik | Jumlah GIF |
|---:|---|---:|---:|
| 1 | Mindful Breathing | 4 | 4 |
| 2 | Focused Attention Meditation | 4 | 4 |
| 3 | Body Scan Meditation | 10 | 10 |
| 4 | Sitting Meditation | 7 | 7 |
| 5 | Mindful Movement / Hatha Yoga | 8 | 8 |
| 6 | Walking Meditation | 7 | 7 |
| 7 | Open Monitoring / Choiceless Awareness | 6 | 6 |
| 8 | Mindfulness of Sounds | 5 | 5 |
| 9 | Loving-Kindness Meditation | 5 | 5 |
| 10 | Mountain Meditation | 6 | 6 |
| 11 | Informal Mindfulness | 12 | 12 |
|  | Total lengkap | 74 | 74 |

Total ideal agar setiap langkah punya animasi sendiri adalah:

```text
74 file GIF
```

Untuk versi MVP yang lebih ringan, beberapa animasi umum bisa dipakai ulang, seperti:

- persiapan tubuh;
- fokus napas;
- penutup;
- sadari lingkungan;
- duduk tenang.

Jika memakai reuse agresif, kebutuhan bisa turun menjadi sekitar:

```text
45 sampai 55 file GIF
```

Namun untuk pengalaman aplikasi yang paling menarik dan jelas, rekomendasi tetap:

```text
74 file GIF
```

## Spesifikasi Visual

Gunakan style yang sama untuk semua animasi:

```text
Format          : GIF looping
Rasio           : 1:1
Ukuran ideal    : 768x768 atau 1024x1024
Durasi loop     : 3 sampai 5 detik
Style           : clean 2D illustration, soft modern wellness app
Gerakan         : pelan, halus, tidak berlebihan
Background      : terang, minimal, tidak ramai
Teks di gambar  : tidak ada
Watermark       : tidak ada
Karakter        : netral, ramah, cocok untuk guru dan siswa
Ekspresi        : tenang, fokus, aman
```

Hindari:

- tulisan di dalam GIF;
- logo produk lain;
- simbol medis berlebihan;
- visual yang terlalu religius;
- ekspresi panik atau dramatis;
- gerakan terlalu cepat;
- background yang ramai;
- animasi yang terlihat seperti olahraga berat.

## Folder Aset yang Disarankan

Untuk Flutter:

```text
mindfuledu/assets/animations/mindfulness/
```

Struktur:

```text
mindfuledu/assets/animations/mindfulness/
├── mindful_breathing/
├── focused_attention/
├── body_scan/
├── sitting_meditation/
├── mindful_movement/
├── walking_meditation/
├── open_monitoring/
├── sounds/
├── loving_kindness/
├── mountain_meditation/
└── informal/
```

Naming convention:

```text
nama_teknik_urutan_nama_step.gif
```

Contoh:

```text
mindful_breathing_01_preparation.gif
mindful_breathing_02_notice_breath.gif
body_scan_05_abdomen.gif
```

## Prompt Utama

Gunakan prompt utama ini untuk semua animasi, lalu tambahkan bagian `Scene prompt` dari tabel masing-masing langkah.

```text
Create a seamless looping animated GIF for a mindfulness mobile app.
Style: calm clean 2D illustration, modern wellness app, soft natural colors, minimal background, friendly Indonesian school context, suitable for teachers and students.
Character: one neutral adult or student character, modest casual clothing, calm facial expression, simple rounded shapes.
Animation: slow breathing pace, gentle movement, subtle motion only, 3 to 5 seconds loop, no sudden movement.
Composition: centered character, enough empty space around the body, readable at small mobile size, 1:1 square format, 768x768.
Do not include text, UI elements, logos, watermark, religious symbols, medical equipment, dramatic crying, panic expression, or crowded background.

Scene:
{SCENE_PROMPT}
```

Prompt negatif:

```text
No text, no watermark, no logo, no medical diagnosis visual, no hospital scene, no religious symbol, no dramatic sadness, no exaggerated stress, no fast motion, no busy background, no photorealistic style.
```

## 1. Mindful Breathing

Jumlah langkah unik:

```text
4 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `mindful_breathing_01_preparation.gif` | A calm person sits upright comfortably on a simple chair, shoulders slowly relaxing, hands resting on thighs, soft indoor classroom corner background. |
| 2 | `mindful_breathing_02_notice_breath.gif` | A calm person gently breathing naturally, subtle chest and abdomen movement, small soft airflow lines near the nose, attention centered on breath. |
| 3 | `mindful_breathing_03_return_from_distraction.gif` | A calm person notices a small floating thought bubble fading away, then attention gently returns to breathing, expression accepting and relaxed. |
| 4 | `mindful_breathing_04_closing.gif` | A calm person slowly opens eyes and notices the room, posture relaxed, gentle final inhale and exhale, peaceful closing moment. |

## 2. Focused Attention Meditation

Jumlah langkah unik:

```text
4 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `focused_attention_01_choose_anchor.gif` | A person sits calmly and chooses one focus anchor, shown by a soft glow around the nose breath area, hands still, minimal background. |
| 2 | `focused_attention_02_hold_focus.gif` | A person maintains steady focus on one small glowing point near the breath, posture stable, only subtle breathing movement. |
| 3 | `focused_attention_03_label_and_return.gif` | A small thought bubble appears with abstract shapes only, gently fades, and the person returns attention to the glowing focus point. |
| 4 | `focused_attention_04_closing.gif` | A person relaxes focus, becomes aware of the whole body and room, soft calm closing animation. |

## 3. Body Scan Meditation

Jumlah langkah unik:

```text
10 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `body_scan_01_preparation.gif` | A person lies down or sits comfortably, taking a few natural breaths, body relaxed, soft mat or chair, calm background. |
| 2 | `body_scan_02_feet.gif` | A relaxed person focuses attention on both feet, soft glow around toes and soles, tiny warmth waves around feet. |
| 3 | `body_scan_03_legs.gif` | Attention slowly moves from calves to knees to thighs, soft glow travels upward through the legs, body remains still. |
| 4 | `body_scan_04_pelvis_lower_back.gif` | A relaxed person notices pelvis and lower back contact with the chair or floor, gentle glow around hips and lower back. |
| 5 | `body_scan_05_abdomen.gif` | A person notices the abdomen moving softly with natural breathing, subtle glow around belly, peaceful expression. |
| 6 | `body_scan_06_chest.gif` | A person notices the chest rising and falling gently, soft glow around chest area, calm breathing loop. |
| 7 | `body_scan_07_hands_arms.gif` | Attention moves from fingers to palms, wrists, and arms, soft glow travels along both hands and forearms. |
| 8 | `body_scan_08_shoulders_neck.gif` | A person notices shoulders and neck tension softening, gentle downward shoulder release, soft glow around neck and shoulders. |
| 9 | `body_scan_09_face_head.gif` | A person relaxes jaw, cheeks, eyes, forehead, and head, soft glow around face, calm closed eyes. |
| 10 | `body_scan_10_whole_body.gif` | A relaxed person senses the whole body as one, soft glow around the entire body, slow peaceful breathing. |

## 4. Sitting Meditation

Jumlah langkah unik:

```text
7 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `sitting_meditation_01_posture.gif` | A person sits upright but not stiff, feet grounded, hands resting, posture balanced, calm classroom or quiet room. |
| 2 | `sitting_meditation_02_breath.gif` | A seated person follows natural breathing, subtle chest movement and soft airflow cue, eyes gently lowered. |
| 3 | `sitting_meditation_03_body_sensation.gif` | A seated person notices body contact points, soft glow on hands, feet, shoulders, and back in sequence. |
| 4 | `sitting_meditation_04_sounds.gif` | A seated person calmly listens to surrounding sounds, gentle abstract sound waves appear and fade without labels. |
| 5 | `sitting_meditation_05_thoughts.gif` | Abstract thought clouds pass slowly near the seated person, the person observes without reacting, calm face. |
| 6 | `sitting_meditation_06_emotions.gif` | Soft colored shapes near the chest appear and fade, representing emotions being noticed without judgment. |
| 7 | `sitting_meditation_07_closing.gif` | A seated person returns attention to breath and the room, opens eyes softly, relaxed final moment. |

## 5. Mindful Movement / Hatha Yoga

Jumlah langkah unik:

```text
8 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `mindful_movement_01_grounding.gif` | A standing person grounds both feet, slow natural breathing, arms relaxed beside body, calm indoor space. |
| 2 | `mindful_movement_02_shoulders_up_down.gif` | A person slowly raises and lowers shoulders with breath, gentle and safe movement, no strain. |
| 3 | `mindful_movement_03_shoulder_roll.gif` | A person performs slow shoulder rolls, small circular motion, relaxed neck and face, mindful pace. |
| 4 | `mindful_movement_04_arms_lift.gif` | A person slowly lifts both arms to a comfortable height and lowers them, movement gentle and not athletic. |
| 5 | `mindful_movement_05_neck_side.gif` | A person gently tilts head right and left within a safe range, shoulders relaxed, slow controlled motion. |
| 6 | `mindful_movement_06_upper_back.gif` | A person gently rounds and opens upper back while seated or standing, slow safe stretch, calm expression. |
| 7 | `mindful_movement_07_waist_legs.gif` | A person makes a small gentle side bend or weight shift through waist and legs, stable feet, mindful movement. |
| 8 | `mindful_movement_08_closing.gif` | A standing person returns to neutral posture, notices body and breath, hands relaxed, calm closing. |

## 6. Walking Meditation

Jumlah langkah unik:

```text
7 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `walking_meditation_01_stand_feet_contact.gif` | A person stands still and notices both feet touching the floor, soft glow under the soles, calm hallway or classroom. |
| 2 | `walking_meditation_02_begin_walking.gif` | A person begins walking very slowly, one step at a time, relaxed arms, safe indoor path. |
| 3 | `walking_meditation_03_lift_move_touch.gif` | Close but full-body readable animation of one foot lifting, moving forward, and touching the floor slowly. |
| 4 | `walking_meditation_04_whole_body_movement.gif` | A person walks slowly while noticing the whole body moving together, gentle motion lines around legs and torso. |
| 5 | `walking_meditation_05_breath_and_steps.gif` | A person synchronizes awareness of breath and slow steps, subtle breath cue and foot contact glow. |
| 6 | `walking_meditation_06_environment.gif` | A person walking slowly notices the quiet surrounding environment, soft light and simple school hallway background. |
| 7 | `walking_meditation_07_slow_stop_close.gif` | A person gradually slows down, stops, stands still, and takes one calm breath to close the session. |

## 7. Open Monitoring / Choiceless Awareness

Jumlah langkah unik:

```text
6 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `open_monitoring_01_stabilize_breath.gif` | A seated person stabilizes attention through natural breathing, soft calm breath cue, minimal background. |
| 2 | `open_monitoring_02_body_awareness.gif` | Awareness opens to the body, soft glow appears around different body areas without focusing on one point. |
| 3 | `open_monitoring_03_notice_sounds.gif` | A seated person notices sounds around them, abstract sound waves appear and fade in different directions. |
| 4 | `open_monitoring_04_notice_thoughts_emotions.gif` | Thoughts and emotion shapes appear and pass gently around the person, who observes calmly without reaction. |
| 5 | `open_monitoring_05_open_awareness.gif` | A seated person rests in broad awareness, soft circles expand around body, calm spacious feeling. |
| 6 | `open_monitoring_06_return_and_close.gif` | A seated person returns to breath, notices the room, and closes the session peacefully. |

## 8. Mindfulness of Sounds

Jumlah langkah unik:

```text
5 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `sounds_01_preparation.gif` | A person sits comfortably, eyes gently lowered, preparing to listen, calm quiet room. |
| 2 | `sounds_02_near_sounds.gif` | A person listens to nearby sounds, small soft sound waves close to the body, no judgment, calm face. |
| 3 | `sounds_03_far_sounds.gif` | A person listens to distant sounds, subtle sound waves farther in the background, simple peaceful environment. |
| 4 | `sounds_04_sound_appears_changes_fades.gif` | Abstract sound waves appear, change shape, and fade away, while the person observes calmly. |
| 5 | `sounds_05_return_to_breath.gif` | A person returns from listening to natural breathing, sound waves fade, breath cue becomes soft focus. |

## 9. Loving-Kindness Meditation

Jumlah langkah unik:

```text
5 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `loving_kindness_01_stabilize.gif` | A person sits quietly and stabilizes with breath, hands on chest or lap, warm gentle light. |
| 2 | `loving_kindness_02_self_kindness.gif` | A person offers kindness to self, soft warm glow around chest, calm accepting expression. |
| 3 | `loving_kindness_03_trusted_person.gif` | A gentle abstract silhouette of a trusted person appears nearby with warm light, the seated person remains calm. |
| 4 | `loving_kindness_04_expand_kindness.gif` | Warm light expands softly from the person outward to simple abstract silhouettes, peaceful and non-dramatic. |
| 5 | `loving_kindness_05_closing.gif` | The warm light settles, the person returns to breath and body, relaxed closing posture. |

## 10. Mountain Meditation

Jumlah langkah unik:

```text
6 GIF
```

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `mountain_meditation_01_prepare_breath.gif` | A seated person prepares with natural breathing, a soft simple mountain shape appears faintly in the background. |
| 2 | `mountain_meditation_02_visualize_mountain.gif` | A calm mountain visualization becomes clearer behind the seated person, stable and peaceful. |
| 3 | `mountain_meditation_03_weather_changes.gif` | Simple clouds, rain, wind, and sunlight move slowly around the mountain, mountain remains steady. |
| 4 | `mountain_meditation_04_thoughts_emotions_change.gif` | Abstract thought and emotion shapes move like changing weather around the person and mountain, calm observation. |
| 5 | `mountain_meditation_05_stable_body.gif` | The seated person feels stable like a mountain, soft grounding glow through body and floor. |
| 6 | `mountain_meditation_06_close.gif` | The mountain fades softly, the person returns to breath and closes the session peacefully. |

## 11. Informal Mindfulness

Jumlah langkah unik:

```text
12 GIF
```

### A. Mindful Drinking

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `informal_drinking_01_hold_cup.gif` | A person holds a cup with both hands and notices the temperature, soft glow around hands and cup. |
| 2 | `informal_drinking_02_notice_color_aroma.gif` | A person observes the drink color and aroma, gentle steam or aroma lines rise slowly, calm attention. |
| 3 | `informal_drinking_03_drink_slowly.gif` | A person takes a small slow sip mindfully, relaxed shoulders, no hurry. |
| 4 | `informal_drinking_04_notice_after_swallow.gif` | A person pauses after swallowing and notices body sensation, soft glow around throat and chest. |

### B. Mindful Eating

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `informal_eating_01_notice_food.gif` | A person observes food color, shape, and aroma before eating, simple plate on table, calm focus. |
| 2 | `informal_eating_02_take_one_bite.gif` | A person slowly takes one mindful bite, gentle movement, no rush. |
| 3 | `informal_eating_03_chew_slowly.gif` | A person chews slowly and attentively, relaxed face, subtle timing cue through gentle motion. |
| 4 | `informal_eating_04_notice_taste_texture.gif` | A person notices taste and texture, soft abstract sensory shapes near mouth, calm expression. |
| 5 | `informal_eating_05_notice_body.gif` | A person pauses and notices the body after eating, hands relaxed, soft glow around abdomen. |

### C. Mindful Walking to Class

| Step | File | Scene prompt |
|---:|---|---|
| 1 | `informal_walking_class_01_notice_steps.gif` | A teacher or student walks slowly toward class and notices each step, soft glow under feet. |
| 2 | `informal_walking_class_02_notice_breath.gif` | A teacher or student walking calmly notices natural breathing while moving through a simple school hallway. |
| 3 | `informal_walking_class_03_notice_environment.gif` | A teacher or student notices the surrounding hallway calmly before entering class, simple school setting, peaceful mood. |

## Prompt Batch per Teknik

Jika ingin meminta semua animasi satu teknik sekaligus, gunakan format ini:

```text
Create a consistent set of seamless looping animated GIFs for the mindfulness technique "{TECHNIQUE_NAME}".
Use the same character, same illustration style, same color palette, same camera angle, and same soft school wellness app atmosphere.
Each GIF must be 1:1 square, 768x768, 3 to 5 seconds, slow and calming, no text, no logo, no watermark.

Make these steps:
{LIST_OF_STEPS}

For each step, create a separate GIF file using this naming format:
{FILE_NAMING_LIST}
```

Contoh untuk Mindful Breathing:

```text
Create a consistent set of seamless looping animated GIFs for the mindfulness technique "Mindful Breathing".
Use the same character, same illustration style, same color palette, same camera angle, and same soft school wellness app atmosphere.
Each GIF must be 1:1 square, 768x768, 3 to 5 seconds, slow and calming, no text, no logo, no watermark.

Make these steps:
1. Preparation: a calm person sits comfortably and relaxes shoulders.
2. Notice breath: subtle natural breathing movement in chest and abdomen.
3. Return from distraction: a thought bubble fades and attention returns to breath.
4. Closing: the person opens eyes softly and notices the room.

File names:
mindful_breathing_01_preparation.gif
mindful_breathing_02_notice_breath.gif
mindful_breathing_03_return_from_distraction.gif
mindful_breathing_04_closing.gif
```

## Analisis Implementasi di Aplikasi

Untuk guided session, struktur data ideal per teknik:

```json
{
  "method": "Mindful Breathing",
  "duration_minutes": 5,
  "steps": [
    {
      "title": "Persiapan tubuh",
      "start_second": 0,
      "end_second": 60,
      "audio_text": "Duduk atau berdiri dengan nyaman. Lepaskan ketegangan yang tidak perlu.",
      "animation_asset": "assets/animations/mindfulness/mindful_breathing/mindful_breathing_01_preparation.gif"
    }
  ]
}
```

Kebutuhan minimal per step di aplikasi:

| Field | Fungsi |
|---|---|
| `title` | Judul tahap yang ditampilkan di sesi |
| `start_second` | Waktu mulai step |
| `end_second` | Waktu akhir step |
| `audio_text` | Teks untuk TTS |
| `animation_asset` | Path GIF untuk step |
| `safety_note` | Catatan keselamatan jika diperlukan |

Alur guided session:

```text
User pilih teknik
User pilih durasi
App membaca daftar step
Timer mulai
GIF step pertama tampil
TTS membacakan instruksi step pertama
Saat waktu step habis, app otomatis pindah ke step berikutnya
GIF step berikutnya tampil
TTS membacakan instruksi step berikutnya
Sampai step terakhir
User mengisi evaluasi setelah latihan
App menyimpan history latihan
```

## Prioritas Pembuatan GIF

Jika tidak bisa langsung membuat 74 GIF, urutan prioritas:

| Prioritas | Teknik | Alasan |
|---:|---|---|
| 1 | Mindful Breathing | Teknik paling dasar dan paling sering direkomendasikan |
| 2 | Body Scan | Penting untuk kelelahan fisik dan burnout sedang/tinggi |
| 3 | Sitting Meditation | Penting untuk overthinking dan beban mental |
| 4 | Mindful Movement | Penting untuk bahu, leher, punggung, dan pegal |
| 5 | Focused Attention | Penting untuk masalah fokus |
| 6 | Loving-Kindness | Penting untuk frustrasi dan self-criticism |
| 7 | Walking Meditation | Penting untuk jeda aktif |
| 8 | Open Monitoring | Penting untuk overwhelmed |
| 9 | Mountain Meditation | Penting untuk emosi naik-turun |
| 10 | Mindfulness of Sounds | Alternatif grounding |
| 11 | Informal Mindfulness | Pelengkap kebiasaan harian |

Paket MVP pertama:

```text
Mindful Breathing  : 4 GIF
Body Scan          : 10 GIF
Sitting Meditation : 7 GIF
Mindful Movement   : 8 GIF
Focused Attention  : 4 GIF
Total MVP awal     : 33 GIF
```

Paket lengkap:

```text
Semua teknik       : 74 GIF
```
