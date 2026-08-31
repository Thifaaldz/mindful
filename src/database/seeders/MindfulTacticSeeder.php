<?php

namespace Database\Seeders;

use App\Models\MindfulTactic;
use Illuminate\Database\Seeder;

class MindfulTacticSeeder extends Seeder
{
    public function run(): void
    {
        $tactics = [
            [
                'title' => 'Teknik STOP',
                'category' => 'stop_technique',
                'description' => 'Jeda cepat untuk berhenti, bernapas, mengamati diri, lalu memilih respons dengan sadar.',
                'knowledge' => 'STOP membantu memberi jarak antara stimulus dan respons. Teknik ini cocok saat emosi naik, pikiran penuh, atau sebelum mengambil keputusan di kelas maupun saat belajar.',
                'duration_minutes' => 2,
                'steps' => [
                    'Stop: hentikan aktivitas sejenak dan diamkan tubuh.',
                    'Take a breath: tarik dan hembuskan napas perlahan.',
                    'Observe: amati tubuh, pikiran, emosi, dan dorongan yang muncul.',
                    'Proceed: lanjutkan dengan satu tindakan yang lebih sadar.',
                ],
                'cues' => ['Berhenti', 'Bernapas', 'Mengamati', 'Melanjutkan'],
                'best_for' => ['marah', 'cemas', 'konflik', 'reaksi impulsif'],
                'sort_order' => 1,
            ],
            [
                'title' => 'Grounding 3-2-1',
                'category' => 'grounding_321',
                'description' => 'Mengembalikan perhatian ke saat ini melalui hal yang dilihat, didengar, dan dirasakan.',
                'knowledge' => 'Grounding membantu saat pikiran terasa terlalu ramai atau tubuh mulai panik. Fokus sensorik membuat perhatian kembali ke lingkungan nyata, bukan hanya kekhawatiran di kepala.',
                'duration_minutes' => 3,
                'steps' => [
                    'Sebutkan tiga hal yang terlihat di sekitar.',
                    'Sebutkan dua suara yang terdengar saat ini.',
                    'Sebutkan satu sensasi fisik yang terasa paling jelas.',
                    'Tarik napas pelan dan lihat apakah tubuh mulai lebih menetap.',
                ],
                'cues' => ['Lihat', 'Dengar', 'Rasakan', 'Tenangkan'],
                'best_for' => ['cemas', 'panik', 'kewalahan', 'krisis'],
                'sort_order' => 2,
            ],
            [
                'title' => 'Napas 4-7-8',
                'category' => 'breathing_478',
                'description' => 'Tarik napas 4 detik, tahan 7 detik, lalu buang napas 8 detik.',
                'knowledge' => 'Latihan napas 4-7-8 dari website lama dipakai untuk menurunkan ketegangan tubuh secara bertahap. Ritme hembusan yang lebih panjang membantu tubuh masuk ke mode lebih tenang.',
                'duration_minutes' => 5,
                'steps' => [
                    'Duduk nyaman dan rilekskan bahu.',
                    'Tarik napas lewat hidung selama 4 hitungan.',
                    'Tahan napas dengan lembut selama 7 hitungan.',
                    'Hembuskan perlahan selama 8 hitungan.',
                    'Ulangi sampai waktu latihan selesai.',
                ],
                'cues' => ['Tarik 4', 'Tahan 7', 'Buang 8', 'Ulangi'],
                'best_for' => ['cemas', 'sulit tidur', 'tegang', 'stres'],
                'sort_order' => 3,
            ],
            [
                'title' => 'Jeda Napas 3 Menit',
                'category' => 'breathing_space_3min',
                'description' => 'Tiga menit untuk menyadari kondisi, fokus ke napas, lalu memperluas perhatian ke tubuh.',
                'knowledge' => '3-Minute Breathing Space adalah latihan ringkas dari pendekatan MBSR/MBCT. Latihan ini cocok sebagai transisi sebelum kelas, setelah aktivitas berat, atau ketika jurnal menunjukkan tekanan mulai muncul.',
                'duration_minutes' => 3,
                'steps' => [
                    'Menit pertama: sadari apa yang sedang dirasakan tanpa menghakimi.',
                    'Menit kedua: fokuskan perhatian ke napas masuk dan keluar.',
                    'Menit ketiga: perluas kesadaran ke seluruh tubuh.',
                    'Tutup dengan niat sederhana untuk aktivitas berikutnya.',
                ],
                'cues' => ['Sadari', 'Napas', 'Perluas', 'Niat'],
                'best_for' => ['transisi aktivitas', 'fokus', 'tekanan ringan'],
                'sort_order' => 4,
            ],
            [
                'title' => 'Awareness of Breathing',
                'category' => 'maintain_breath_awareness',
                'description' => 'Menjaga perhatian pada napas natural tanpa perlu mengubahnya.',
                'knowledge' => 'Latihan ini melatih hadir penuh dengan sikap non-striving: tidak memaksa hasil tertentu, cukup mengenali napas dan kembali saat perhatian berpindah.',
                'duration_minutes' => 3,
                'steps' => [
                    'Duduk stabil dengan punggung nyaman.',
                    'Rasakan napas masuk sebagaimana adanya.',
                    'Rasakan napas keluar sebagaimana adanya.',
                    'Saat terdistraksi, sadari lalu kembali ke napas.',
                    'Akhiri dengan satu napas panjang.',
                ],
                'cues' => ['Duduk', 'Napas masuk', 'Napas keluar', 'Kembali'],
                'best_for' => ['fokus', 'tenang', 'ritme stabil'],
                'sort_order' => 5,
            ],
            [
                'title' => 'Sitting Meditation',
                'category' => 'sitting_meditation',
                'description' => 'Meditasi duduk untuk menyadari napas, suara, tubuh, pikiran, dan emosi.',
                'knowledge' => 'Sitting meditation membantu membaca pikiran dan emosi tanpa langsung ikut terseret. Dalam MBSR, latihan ini menguatkan non-judging, patience, dan acceptance.',
                'duration_minutes' => 10,
                'steps' => [
                    'Duduk dengan posisi yang stabil dan nyaman.',
                    'Letakkan perhatian pada napas.',
                    'Sadari suara, tubuh, pikiran, dan emosi yang muncul.',
                    'Bila perhatian berpindah, kembali ke napas dengan lembut.',
                    'Tutup dengan menyadari seluruh tubuh.',
                ],
                'cues' => ['Stabil', 'Napas', 'Sadari', 'Kembali'],
                'best_for' => ['banyak pikiran', 'stres', 'kewalahan'],
                'sort_order' => 6,
            ],
            [
                'title' => 'Body Scan Singkat',
                'category' => 'body_scan_micro',
                'description' => 'Memindai tubuh dari kepala sampai kaki untuk mengenali ketegangan dan kebutuhan istirahat.',
                'knowledge' => 'Body scan membantu tubuh memberi informasi yang sering terlewat saat aktivitas padat. Latihan ini cocok ketika mood checkout negatif, lelah, atau jurnal menunjukkan beban emosional.',
                'duration_minutes' => 10,
                'steps' => [
                    'Cari posisi duduk atau berbaring yang nyaman.',
                    'Mulai dari napas dan biarkan tubuh menetap.',
                    'Sadari kepala, wajah, leher, dan bahu.',
                    'Sadari tangan, dada, perut, dan pinggang.',
                    'Sadari kaki lalu tubuh secara keseluruhan.',
                    'Biarkan sensasi hadir tanpa perlu langsung diubah.',
                ],
                'cues' => ['Kepala', 'Bahu', 'Dada', 'Perut', 'Kaki'],
                'best_for' => ['lelah', 'tegang', 'mood negatif', 'pemulihan'],
                'sort_order' => 7,
            ],
            [
                'title' => 'Body Scan Penuh',
                'category' => 'body_scan_full',
                'description' => 'Versi lebih panjang untuk tekanan tinggi dan pemulihan lebih dalam.',
                'knowledge' => 'Body scan penuh dipakai saat sinyal burnout tinggi. Latihan ini memberi ruang pemulihan lebih panjang dan sebaiknya dilakukan di tempat aman, tenang, dan tidak terburu-buru.',
                'duration_minutes' => 20,
                'steps' => [
                    'Pastikan posisi aman dan nyaman.',
                    'Mulai dari telapak kaki dan naik perlahan.',
                    'Berhenti sejenak di area yang terasa tegang.',
                    'Izinkan sensasi hadir tanpa menghakimi.',
                    'Rasakan tubuh sebagai satu kesatuan.',
                    'Bangun perlahan sebelum kembali beraktivitas.',
                ],
                'cues' => ['Kaki', 'Tubuh bawah', 'Tubuh tengah', 'Tubuh atas', 'Utuh'],
                'best_for' => ['burnout tinggi', 'kelelahan emosional', 'pemulihan panjang'],
                'sort_order' => 8,
            ],
            [
                'title' => 'Mindful Movement',
                'category' => 'mindful_movement',
                'description' => 'Peregangan ringan dengan perhatian penuh pada gerak, napas, dan batas nyaman tubuh.',
                'knowledge' => 'Mindful movement cocok ketika tekanan terasa menumpuk di tubuh. Latihan ini bukan olahraga berat, melainkan cara bergerak perlahan sambil mendengar batas tubuh.',
                'duration_minutes' => 10,
                'steps' => [
                    'Berdiri atau duduk dengan ruang gerak aman.',
                    'Gerakkan bahu, leher, tangan, dan punggung perlahan.',
                    'Sinkronkan gerakan dengan napas.',
                    'Berhenti bila ada rasa tidak nyaman.',
                    'Rasakan kondisi tubuh sebelum lanjut.',
                ],
                'cues' => ['Bahu', 'Leher', 'Tangan', 'Punggung', 'Tenang'],
                'best_for' => ['pegal', 'duduk lama', 'usaha tinggi', 'lelah fisik'],
                'sort_order' => 9,
            ],
            [
                'title' => 'Walking Meditation',
                'category' => 'walking_meditation',
                'description' => 'Berjalan perlahan sambil menyadari kontak kaki, napas, dan lingkungan.',
                'knowledge' => 'Walking meditation membantu saat tubuh butuh jeda aktif. Latihan ini cocok setelah belajar atau mengajar lama, terutama ketika duduk diam terasa sulit.',
                'duration_minutes' => 5,
                'steps' => [
                    'Pilih jalur pendek yang aman.',
                    'Berjalan perlahan sambil merasakan telapak kaki.',
                    'Sadari gerak tubuh dan napas.',
                    'Perhatikan lingkungan tanpa buru-buru menilai.',
                    'Berhenti sejenak sebelum kembali bekerja.',
                ],
                'cues' => ['Langkah', 'Kaki', 'Napas', 'Sekitar'],
                'best_for' => ['jenuh', 'duduk lama', 'transisi', 'gelisah'],
                'sort_order' => 10,
            ],
            [
                'title' => 'RAIN',
                'category' => 'rain_self_compassion',
                'description' => 'Recognize, Allow, Investigate, Nurture untuk emosi yang berat.',
                'knowledge' => 'RAIN membantu ketika emosi terasa kuat. Teknik ini melatih mengenali emosi, mengizinkan ia hadir, menyelidiki sensasi tubuh, lalu memberi respons yang penuh welas asih.',
                'duration_minutes' => 7,
                'steps' => [
                    'Recognize: kenali emosi yang sedang muncul.',
                    'Allow: izinkan emosi hadir tanpa dilawan.',
                    'Investigate: rasakan di bagian tubuh mana emosi itu muncul.',
                    'Nurture: beri kalimat baik untuk diri sendiri.',
                    'Pilih satu langkah kecil yang aman setelah latihan.',
                ],
                'cues' => ['Kenali', 'Izinkan', 'Selidiki', 'Rawat'],
                'best_for' => ['sedih', 'marah', 'frustrasi', 'tekanan emosional'],
                'sort_order' => 11,
            ],
            [
                'title' => 'Loving-Kindness Meditation',
                'category' => 'loving_kindness',
                'description' => 'Latihan niat baik kepada diri sendiri dan orang lain secara perlahan.',
                'knowledge' => 'Loving-kindness cocok saat merasa keras pada diri sendiri, konflik, atau rendah pencapaian diri. Latihan ini membantu membangun self-compassion tanpa memaksa emosi positif muncul.',
                'duration_minutes' => 7,
                'steps' => [
                    'Duduk nyaman dan sadari napas.',
                    'Arahkan kalimat baik kepada diri sendiri.',
                    'Akui beban yang sedang terasa tanpa menghakimi.',
                    'Luaskan niat baik pada orang lain bila siap.',
                    'Tutup dengan satu tindakan kecil yang menenangkan.',
                ],
                'cues' => ['Diri', 'Lembut', 'Orang lain', 'Tenang'],
                'best_for' => ['rendah pencapaian diri', 'konflik', 'sedih', 'self-compassion'],
                'sort_order' => 12,
            ],
            [
                'title' => 'Jurnal Reflektif Harian',
                'category' => 'reflective_journal',
                'description' => 'Menulis satu hal yang menguras energi dan satu hal kecil yang bisa dilepaskan.',
                'knowledge' => 'Jurnal reflektif membantu mengubah pengalaman harian menjadi informasi. Teknik ini cocok setelah check-out agar rekomendasi berikutnya makin sesuai dengan pola yang muncul.',
                'duration_minutes' => 5,
                'steps' => [
                    'Tulis satu hal yang paling menguras energi hari ini.',
                    'Tulis satu perasaan yang paling dominan.',
                    'Tulis pola yang mulai terlihat.',
                    'Tulis satu hal kecil yang bisa dilepaskan atau ditunda.',
                    'Tutup dengan rencana lembut untuk besok.',
                ],
                'cues' => ['Fakta', 'Perasaan', 'Pola', 'Rencana'],
                'best_for' => ['refleksi', 'pola jurnal', 'rendah pencapaian diri'],
                'sort_order' => 13,
            ],
        ];

        MindfulTactic::whereNotIn('category', array_column($tactics, 'category'))->delete();

        foreach ($tactics as $tactic) {
            MindfulTactic::updateOrCreate(
                ['category' => $tactic['category']],
                $tactic,
            );
        }
    }
}
