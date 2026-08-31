<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class JournalAnalysisService
{
    private const MOOD_KEYWORDS = [
        'cemas' => ['cemas', 'khawatir', 'gugup', 'takut', 'deg-degan', 'panik'],
        'sedih' => ['sedih', 'kecewa', 'putus asa', 'menangis', 'murung', 'sepi'],
        'marah' => ['marah', 'kesal', 'jengkel', 'benci', 'emosi'],
        'senang' => ['senang', 'bahagia', 'gembira', 'semangat', 'seru', 'asik'],
        'lelah' => ['lelah', 'capek', 'ngantuk', 'burnout', 'pusing', 'stres', 'stress'],
    ];

    private const SUGGESTIONS = [
        'cemas' => 'Coba latihan napas 4-7-8 selama 5 menit untuk menenangkan tubuh.',
        'sedih' => 'Tuliskan satu hal kecil yang membuatmu nyaman hari ini, lalu coba sesi napas singkat.',
        'marah' => 'Coba tarik napas dalam 5 kali sebelum melanjutkan aktivitas.',
        'lelah' => 'Istirahat sejenak dan coba sesi napas 10 menit sebelum lanjut belajar.',
        'senang' => 'Pertahankan momen ini, catat apa yang membuatmu senang hari ini.',
        'netral' => 'Coba check-in mood harian dan sesi napas singkat untuk menjaga fokus.',
    ];

    private const CRISIS_KEYWORDS = [
        'bunuh diri',
        'mengakhiri hidup',
        'ingin mati',
        'ingin hilang saja',
        'menyakiti diri',
        'melukai diri',
        'tidak ingin hidup',
    ];

    private const BURNOUT_DIMENSIONS = [
        'kelelahan_emosional' => [
            'lelah',
            'capek',
            'habis energi',
            'terkuras',
            'menguras',
            'kelelahan',
            'burnout',
            'ngantuk',
            'pusing',
        ],
        'depersonalisasi' => [
            'sinis',
            'malas',
            'percuma',
            'cuek',
            'acuh',
            'tidak peduli',
            'masa bodoh',
        ],
        'rendah_pencapaian_diri' => [
            'gagal',
            'tidak berarti',
            'tidak kompeten',
            'meragukan',
            'tidak becus',
            'sia-sia',
            'tidak berguna',
        ],
    ];

    private const VALID_MOODS = ['senang', 'tenang', 'cemas', 'sedih', 'marah', 'lelah', 'netral'];

    public function analyze(array $payload): array
    {
        $url = config('services.mindful_ml.url');

        if ($url) {
            try {
                $response = Http::timeout(5)->post(rtrim($url, '/').'/analyze/journal', $payload);
                $analysis = $response->successful() ? $response->json() : null;

                if (is_array($analysis) && isset($analysis['mood_detected'], $analysis['suggestion'])) {
                    return $this->normalize($analysis, $payload);
                }
            } catch (\Throwable) {
                // Checkout should stay available even when the ML service is offline.
            }
        }

        return $this->fallback($payload);
    }

    private function normalize(array $analysis, array $payload): array
    {
        $local = $this->fallback($payload);
        $mood = $analysis['mood_detected'] ?? 'netral';
        $dimensions = array_values(array_unique(array_filter([
            ...($payload['burnout_tags'] ?? []),
            ...($analysis['burnout_dimensions'] ?? []),
        ], fn ($tag) => array_key_exists($tag, self::BURNOUT_DIMENSIONS))));

        return [
            'mood_detected' => in_array($mood, self::VALID_MOODS, true) ? $mood : 'netral',
            'suggestion' => $analysis['suggestion'] ?? self::SUGGESTIONS['netral'],
            'crisis_flag' => (bool) ($analysis['crisis_flag'] ?? false) || $local['crisis_flag'],
            'burnout_dimensions' => $dimensions,
            'source' => $analysis['source'] ?? 'fastapi',
            'raw_response' => $analysis['raw_response'] ?? null,
        ];
    }

    private function fallback(array $payload): array
    {
        $text = $this->journalText($payload);
        $lower = strtolower($text);
        $scores = array_fill_keys(array_keys(self::MOOD_KEYWORDS), 0);

        foreach (self::MOOD_KEYWORDS as $mood => $keywords) {
            foreach ($keywords as $keyword) {
                if (str_contains($lower, $keyword)) {
                    $scores[$mood]++;
                }
            }
        }

        arsort($scores);
        $mood = array_key_first($scores);
        $moodDetected = ($scores[$mood] ?? 0) > 0 ? $mood : 'netral';
        $dimensions = array_values(array_unique(array_filter([
            ...($payload['burnout_tags'] ?? []),
            ...$this->detectBurnoutDimensions($lower),
        ], fn ($tag) => array_key_exists($tag, self::BURNOUT_DIMENSIONS))));

        return [
            'mood_detected' => $moodDetected,
            'suggestion' => self::SUGGESTIONS[$moodDetected] ?? self::SUGGESTIONS['netral'],
            'crisis_flag' => $this->hasCrisisText($lower),
            'burnout_dimensions' => $dimensions,
            'source' => 'php-fallback',
            'raw_response' => null,
        ];
    }

    private function journalText(array $payload): string
    {
        if (filled($payload['text'] ?? null)) {
            return trim($payload['text']);
        }

        return collect([
            'Fakta' => $payload['fact'] ?? null,
            'Perasaan' => $payload['feeling'] ?? null,
            'Pola' => $payload['pattern'] ?? null,
            'Rencana' => $payload['plan'] ?? null,
        ])
            ->filter(fn ($value) => filled($value))
            ->map(fn ($value, $label) => "{$label}: {$value}")
            ->implode("\n");
    }

    private function detectBurnoutDimensions(string $lower): array
    {
        $dimensions = [];

        foreach (self::BURNOUT_DIMENSIONS as $dimension => $keywords) {
            foreach ($keywords as $keyword) {
                if (str_contains($lower, $keyword)) {
                    $dimensions[] = $dimension;
                    break;
                }
            }
        }

        return $dimensions;
    }

    private function hasCrisisText(string $lower): bool
    {
        foreach (self::CRISIS_KEYWORDS as $keyword) {
            if (str_contains($lower, $keyword)) {
                return true;
            }
        }

        return false;
    }
}
