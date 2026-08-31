<?php

namespace App\Services;

use App\Models\Activity;
use App\Models\BurnoutAnalysisSnapshot;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Http;

class BurnoutAnalysisService
{
    private const MAX_DAILY_CAPACITY_HOURS = 8;
    private const SCORING_VERSION = 'scoring-v2.3-mbsr';
    private const MODEL_VERSION = 'php-fallback-mbsr-v2.3';
    private const THRESHOLD_VERSION = 'threshold-v2.3';
    private const CHECKIN_NEGATIVE_MOODS = ['cemas', 'sedih', 'marah'];
    private const CHECKOUT_NEGATIVE_MOODS = ['cemas', 'sedih', 'marah'];
    private const JOURNAL_PRESSURE_KEYWORDS = [
        'lelah',
        'capek',
        'stres',
        'stress',
        'tertekan',
        'pusing',
        'cemas',
        'takut',
        'marah',
        'sedih',
        'kewalahan',
        'burnout',
        'jenuh',
    ];
    private const PRACTICE_CATALOG = [
        'stop_technique' => [
            'title' => 'Teknik STOP',
            'practice' => 'Teknik STOP selama 2 menit.',
        ],
        'grounding_321' => [
            'title' => 'Grounding 3-2-1',
            'practice' => 'Grounding 3-2-1 selama 3 menit.',
        ],
        'breathing_478' => [
            'title' => 'Napas 4-7-8',
            'practice' => 'Napas 4-7-8 selama 5 menit.',
        ],
        'breathing_space_3min' => [
            'title' => 'Jeda Napas 3 Menit',
            'practice' => 'Jeda Napas 3 Menit untuk menata perhatian sebelum aktivitas berikutnya.',
        ],
        'maintain_breath_awareness' => [
            'title' => 'Awareness of Breathing',
            'practice' => 'Awareness of Breathing 2-3 menit sebelum aktivitas berikutnya.',
        ],
        'sitting_meditation' => [
            'title' => 'Sitting Meditation',
            'practice' => 'Sitting meditation fokus napas 10 menit.',
        ],
        'body_scan_micro' => [
            'title' => 'Body Scan Singkat',
            'practice' => 'Body Scan singkat 5-10 menit.',
        ],
        'body_scan_full' => [
            'title' => 'Body Scan Penuh',
            'practice' => 'Body scan 15-20 menit untuk pemulihan lebih dalam.',
        ],
        'mindful_movement' => [
            'title' => 'Mindful Movement',
            'practice' => 'Mindful movement ringan setelah aktivitas berat.',
        ],
        'walking_meditation' => [
            'title' => 'Walking Meditation',
            'practice' => 'Walking meditation 5 menit untuk jeda aktif.',
        ],
        'rain_self_compassion' => [
            'title' => 'RAIN',
            'practice' => 'RAIN untuk mengenali dan merawat emosi berat.',
        ],
        'loving_kindness' => [
            'title' => 'Loving-Kindness Meditation',
            'practice' => 'Loving-kindness meditation 7 menit.',
        ],
        'reflective_journal' => [
            'title' => 'Jurnal Reflektif Harian',
            'practice' => 'Jurnal reflektif harian untuk membaca pola tekanan.',
        ],
    ];

    public function analyze(User $user, string $periodType, Carbon|string|null $date = null, string $source = 'manual'): BurnoutAnalysisSnapshot
    {
        [$periodStart, $periodEnd] = $this->periodRange($periodType, $date);
        $analysis = $this->analysisData($user, $periodType, $periodStart, $periodEnd, true);

        return $user->burnoutAnalysisSnapshots()->create([
            'source' => $source,
            'period_type' => $periodType,
            'period_start' => $periodStart,
            'period_end' => $periodEnd,
            ...$analysis,
        ]);
    }

    public function preview(User $user, string $periodType = 'daily', Carbon|string|null $date = null): array
    {
        [$periodStart, $periodEnd] = $this->periodRange($periodType, $date);
        $analysis = $this->analysisData($user, $periodType, $periodStart, $periodEnd, false);

        return $this->presentPreview($analysis, $periodType, $periodStart, $periodEnd);
    }

    public function dailyHistory(User $user, int $days = 14): array
    {
        $end = now()->startOfDay();
        $start = $end->copy()->subDays(max(1, min(31, $days)) - 1);
        $activities = $this->activitiesForPeriod($user, $start, $end->copy()->endOfDay())
            ->groupBy(fn (Activity $activity) => $activity->activity_date->format('Y-m-d'));
        $history = [];

        for ($date = $start->copy(); $date->lessThanOrEqualTo($end); $date->addDay()) {
            $key = $date->format('Y-m-d');
            $analysis = $this->analysisDataFromActivities(
                $user,
                'daily',
                $date->copy()->startOfDay(),
                $date->copy()->endOfDay(),
                $activities->get($key, collect()),
                false,
            );

            $history[] = [
                'date' => $key,
                'score' => $analysis['final_burnout_risk_score'],
                'category' => $analysis['category'],
                'data_sufficiency' => $analysis['data_sufficiency'],
                'activity_count' => $analysis['activity_count'],
                'completed_activity_count' => $analysis['completed_activity_count'],
                'weighted_actual_hours' => $analysis['weighted_actual_hours'],
                'journal_score' => $analysis['journal_score'],
            ];
        }

        return $history;
    }

    public function overview(User $user): array
    {
        return [
            'today' => $this->preview($user, 'daily', now()),
            'daily_history' => $this->dailyHistory($user, 14),
            'thresholds' => [
                'green' => ['label' => 'Hijau', 'min' => 0, 'max' => 39.99],
                'yellow' => ['label' => 'Kuning', 'min' => 40, 'max' => 69.99],
                'red' => ['label' => 'Merah', 'min' => 70, 'max' => 100],
            ],
            'formula' => [
                'final' => 'Final = 50% Workload Score + 50% Wellbeing Score',
                'workload' => 'Workload Score = weighted current hours / kapasitas periode x 100',
                'journal' => 'Wellbeing Score = rasio mood negatif check-in/check-out, intensitas mood check-in, kata tekanan pada jurnal fact/feeling/plan, dan kecenderungan memburuk saat checkout',
                'capacity' => 'Kapasitas harian default = 8 jam. Aktivitas selesai memakai nilai terbesar dari actual/planned hours, aktivitas belum selesai memakai planned hours.',
            ],
            'analogies' => $this->riskAnalogies(),
        ];
    }

    private function analysisData(User $user, string $periodType, Carbon $periodStart, Carbon $periodEnd, bool $useMl): array
    {
        return $this->analysisDataFromActivities(
            $user,
            $periodType,
            $periodStart,
            $periodEnd,
            $this->activitiesForPeriod($user, $periodStart, $periodEnd),
            $useMl,
        );
    }

    private function activitiesForPeriod(User $user, Carbon $periodStart, Carbon $periodEnd): Collection
    {
        return $user->activities()
            ->whereBetween('activity_date', [$periodStart->toDateString(), $periodEnd->toDateString()])
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->orderBy('start_at')
            ->get();
    }

    private function analysisDataFromActivities(User $user, string $periodType, Carbon $periodStart, Carbon $periodEnd, Collection $activities, bool $useMl): array
    {
        $completed = $activities
            ->where('status', Activity::STATUS_COMPLETED)
            ->filter(fn (Activity $activity) => $activity->actual_hours !== null);

        $weightedPlannedHours = $this->weightedHours($activities, 'planned_hours');
        $weightedActualHours = $this->weightedCurrentHours($activities);
        $activeDays = max(1, $activities->pluck('activity_date')->map->toDateString()->unique()->count());
        $periodCapacity = self::MAX_DAILY_CAPACITY_HOURS * $activeDays;
        $journalRows = $completed->filter(fn (Activity $activity) => $this->hasStructuredPostJournal($activity));
        $crisisCount = $journalRows->filter(fn (Activity $activity) => (bool) $activity->checkout_crisis_flag)->count();
        $selfReportLevels = $this->selfReportLevels($user, $periodStart, $periodEnd);

        $mlPayload = $this->mlPayload($user, $periodType, $periodCapacity, $activities, $selfReportLevels);
        $mlScore = $useMl ? $this->scoreViaMl($mlPayload) : null;

        if ($mlScore) {
            $weightedPlannedHours = (float) $mlScore['weighted_planned_hours'];
            $weightedActualHours = (float) $mlScore['weighted_actual_hours'];
            $workloadScoreRaw = (float) $mlScore['workload_score_raw'];
            $variance = ($mlScore['workload_variance_pct'] ?? null) === null ? null : (float) $mlScore['workload_variance_pct'];
            $journalScore = (float) $mlScore['journal_score'];
            $dataSufficiency = (bool) $mlScore['data_sufficiency'];
            $finalScore = ($mlScore['final_burnout_risk_score'] ?? null) === null ? null : (float) $mlScore['final_burnout_risk_score'];
            $category = $mlScore['category'] ?? null;
            $dominantFactors = array_values(array_unique(array_merge(
                ($mlScore['dominant_factors'] ?? []) ?: [],
                $this->dominantFactors($workloadScoreRaw, $journalScore, $completed, $selfReportLevels),
            )));
            $modelVersion = $mlScore['model_version'] ?? self::MODEL_VERSION;
        } else {
            $workloadScoreRaw = $periodCapacity > 0 ? ($weightedActualHours / $periodCapacity) * 100 : 0;
            $variance = $weightedPlannedHours > 0
                ? (($weightedActualHours - $weightedPlannedHours) / $weightedPlannedHours) * 100
                : null;
            $journalScore = $this->wellbeingScore($activities, $selfReportLevels);
            $dataSufficiency = $journalRows->count() > 0;
            $finalScore = $dataSufficiency
                ? min(100, $workloadScoreRaw) * 0.50 + $journalScore * 0.50
                : null;
            $category = $finalScore === null ? null : $this->category($finalScore);
            $dominantFactors = $this->dominantFactors($workloadScoreRaw, $journalScore, $completed, $selfReportLevels);
            $modelVersion = self::MODEL_VERSION;
        }

        if ($crisisCount > 0 && $finalScore !== null) {
            $finalScore = max($finalScore, 75);
            $category = 'merah';
            $dominantFactors = array_values(array_unique(['crisis_flag', ...$dominantFactors]));
        }

        [$finalScore, $category] = $this->applyRiskFloor($finalScore, $category, $dominantFactors);

        $recommendation = is_array($mlScore['recommendation_summary'] ?? null)
            ? $mlScore['recommendation_summary']
            : $this->recommendation($category, $dominantFactors, $user);
        $recommendationCodes = is_array($mlScore['recommendation_codes'] ?? null)
            ? $mlScore['recommendation_codes']
            : ($recommendation['codes'] ?? []);

        return [
            'data_sufficiency' => $dataSufficiency,
            'activity_count' => $activities->count(),
            'completed_activity_count' => $completed->count(),
            'weighted_planned_hours' => round($weightedPlannedHours, 2),
            'weighted_actual_hours' => round($weightedActualHours, 2),
            'workload_score_raw' => round($workloadScoreRaw, 2),
            'workload_variance_pct' => $variance === null ? null : round($variance, 2),
            'journal_score' => round($journalScore, 2),
            'final_burnout_risk_score' => $finalScore === null ? null : round($finalScore, 2),
            'category' => $category,
            'dominant_factors' => $dominantFactors,
            'recommendation_codes' => $recommendationCodes,
            'recommendation_summary' => $recommendation,
            'model_version' => $modelVersion,
            'scoring_version' => self::SCORING_VERSION,
            'threshold_version' => self::THRESHOLD_VERSION,
            'payload' => [
                'max_daily_capacity_hours' => self::MAX_DAILY_CAPACITY_HOURS,
                'active_days' => $activeDays,
                'period_capacity_hours' => $periodCapacity,
                'journal_count' => $journalRows->count(),
                'formula' => 'final = 0.50 * min(100, workload_score_raw) + 0.50 * wellbeing_score; current hours memakai nilai terbesar dari actual/planned untuk completed dan planned hours untuk aktivitas belum selesai',
                'ml_service_used' => $mlScore !== null,
                'ml_calculation' => $mlScore['calculation'] ?? null,
                'journal_reviews' => $this->journalReviews($journalRows),
                'activity_breakdown' => $this->activityBreakdown($activities),
            ],
        ];
    }

    public function periodRange(string $periodType, Carbon|string|null $date = null): array
    {
        $anchor = $date ? Carbon::parse($date) : now();

        return match ($periodType) {
            'daily' => [$anchor->copy()->startOfDay(), $anchor->copy()->endOfDay()],
            'weekly' => [$anchor->copy()->startOfWeek(), $anchor->copy()->endOfWeek()],
            'monthly' => [$anchor->copy()->startOfMonth(), $anchor->copy()->endOfMonth()],
            default => throw new \InvalidArgumentException('Periode analisis tidak dikenal.'),
        };
    }

    private function presentPreview(array $analysis, string $periodType, Carbon $periodStart, Carbon $periodEnd): array
    {
        $score = $analysis['final_burnout_risk_score'];
        $category = $analysis['category'];
        $workloadScore = (float) $analysis['workload_score_raw'];
        $journalScore = (float) $analysis['journal_score'];
        $weightedActualHours = (float) $analysis['weighted_actual_hours'];
        $capacity = (float) ($analysis['payload']['period_capacity_hours'] ?? self::MAX_DAILY_CAPACITY_HOURS);
        $recommendation = $analysis['recommendation_summary'];

        return [
            'period_type' => $periodType,
            'period_start' => $periodStart->toDateString(),
            'period_end' => $periodEnd->toDateString(),
            'score' => $score,
            'category' => $category,
            'data_sufficiency' => $analysis['data_sufficiency'],
            'activity_count' => $analysis['activity_count'],
            'completed_activity_count' => $analysis['completed_activity_count'],
            'journal_count' => $analysis['payload']['journal_count'] ?? count($analysis['payload']['journal_reviews'] ?? []),
            'weighted_actual_hours' => $analysis['weighted_actual_hours'],
            'workload_score_raw' => $analysis['workload_score_raw'],
            'journal_score' => $analysis['journal_score'],
            'dominant_factors' => $analysis['dominant_factors'],
            'recommendation' => $recommendation,
            'journal_reviews' => $analysis['payload']['journal_reviews'] ?? [],
            'activity_breakdown' => $analysis['payload']['activity_breakdown'] ?? [],
            'calculation' => [
                'formula' => 'Final = 0.50 x min(100, Workload Score) + 0.50 x Wellbeing Score',
                'workload_detail' => "Workload saat ini: {$weightedActualHours} weighted hours / {$capacity} jam kapasitas x 100 = ".round($workloadScore, 2).'. Completed memakai nilai terbesar dari actual/planned hours, planned/checked-in memakai planned hours.',
                'journal_detail' => "Wellbeing: check-in, check-out, dan jurnal menghasilkan skor ".round($journalScore, 2).' dari skala 0-100.',
                'final_detail' => $score === null
                    ? 'Skor final belum dihitung karena jurnal check-out belum lengkap.'
                    : 'Final: 50% x '.round(min(100, $workloadScore), 2).' + 50% x '.round($journalScore, 2).' = '.$score,
                'category_detail' => $this->categoryExplanation($category, $score),
            ],
        ];
    }

    private function categoryExplanation(?string $category, mixed $score): string
    {
        if ($category === null || $score === null) {
            return 'Belum masuk hijau, kuning, atau merah karena minimal satu check-out lengkap dibutuhkan untuk membaca jurnal.';
        }

        return match ($category) {
            'hijau' => "Hijau karena skor {$score} berada di bawah 40. Beban dan jurnal masih relatif terkendali.",
            'kuning' => "Kuning karena skor {$score} berada di rentang 40-69. Ada tanda beban atau jurnal mulai meningkat.",
            'merah' => "Merah karena skor {$score} berada di 70 ke atas. Beban dan/atau jurnal menunjukkan tekanan tinggi.",
            default => 'Kategori belum dikenal.',
        };
    }

    private function riskAnalogies(): array
    {
        return [
            [
                'category' => 'hijau',
                'title' => 'Contoh hijau',
                'description' => 'Sekitar 2 aktivitas ringan-sedang, total 2-3 weighted hours, dengan mood dan jurnal checkout yang relatif stabil.',
            ],
            [
                'category' => 'kuning',
                'title' => 'Contoh kuning',
                'description' => 'Sekitar 3-4 aktivitas sedang, total 4-6 weighted hours, dengan beberapa mood negatif atau kata tekanan pada jurnal checkout.',
            ],
            [
                'category' => 'merah',
                'title' => 'Contoh merah',
                'description' => 'Bisa terjadi pada 4 aktivitas intensif berdurasi 2 jam dengan IF 1.5, atau lebih sedikit aktivitas bila mood negatif dan jurnal tekanan muncul berulang.',
            ],
        ];
    }

    private function weightedHours(Collection $activities, string $field): float
    {
        return (float) $activities->sum(function (Activity $activity) use ($field) {
            return ((float) $activity->{$field}) * ((float) $activity->intensity_factor);
        });
    }

    private function weightedCurrentHours(Collection $activities): float
    {
        return (float) $activities->sum(function (Activity $activity) {
            return $this->effectiveHours($activity) * ((float) $activity->intensity_factor);
        });
    }

    private function effectiveHours(Activity $activity): float
    {
        if ($activity->status === Activity::STATUS_COMPLETED && $activity->actual_hours !== null) {
            return max((float) $activity->actual_hours, (float) $activity->planned_hours);
        }

        return (float) $activity->planned_hours;
    }

    private function mlPayload(User $user, string $periodType, float $periodCapacity, Collection $activities, array $selfReportLevels): array
    {
        return [
            'period_type' => $periodType,
            'role_context' => $user->isStudent() ? 'student' : ($user->isTeacher() ? 'teacher' : 'other'),
            'period_capacity_hours' => $periodCapacity,
            'self_report_levels' => $selfReportLevels,
            'scoring_version' => self::SCORING_VERSION,
            'activities' => $activities->map(fn (Activity $activity) => [
                'title' => $activity->title,
                'category_name' => $activity->category,
                'planned_hours' => (float) $activity->planned_hours,
                'actual_hours' => $this->effectiveHours($activity),
                'intensity_factor' => (float) $activity->intensity_factor,
                'checkin_mood' => $activity->checkin_mood,
                'checkin_intensity' => $activity->checkin_intensity,
                'checkin_trigger' => $activity->checkin_trigger,
                'checkout_mood' => $activity->checkout_mood,
                'checkout_fact' => $activity->checkout_fact,
                'checkout_feeling' => $activity->checkout_feeling,
                'checkout_pattern' => $activity->checkout_pattern,
                'checkout_plan' => $activity->checkout_plan,
                'checkout_burnout_tags' => $activity->checkout_burnout_tags ?? [],
                'checkout_auto_burnout_tags' => $activity->checkout_auto_burnout_tags ?? [],
                'checkout_mood_detected' => $activity->checkout_mood_detected,
                'checkout_crisis_flag' => (bool) $activity->checkout_crisis_flag,
            ])->values()->all(),
        ];
    }

    private function scoreViaMl(array $payload): ?array
    {
        $url = config('services.mindful_ml.url');
        if (! $url) {
            return null;
        }

        try {
            $response = Http::timeout(5)->post(rtrim($url, '/').'/score/burnout', $payload);

            $score = $response->successful() ? $response->json() : null;

            return is_array($score) && $this->isValidMlScore($score) ? $score : null;
        } catch (\Throwable) {
            return null;
        }
    }

    private function isValidMlScore(array $score): bool
    {
        foreach ([
            'data_sufficiency',
            'weighted_planned_hours',
            'weighted_actual_hours',
            'workload_score_raw',
            'journal_score',
        ] as $field) {
            if (! array_key_exists($field, $score)) {
                return false;
            }
        }

        return true;
    }

    private function selfReportLevels(User $user, Carbon $periodStart, Carbon $periodEnd): array
    {
        if (! $user->isTeacher()) {
            return [];
        }

        return $user->burnoutSelfReports()
            ->whereBetween('created_at', [$periodStart, $periodEnd])
            ->pluck('level')
            ->map(fn ($level) => (int) $level)
            ->values()
            ->all();
    }

    private function hasStructuredPostJournal(Activity $activity): bool
    {
        return filled($activity->checkout_fact) || filled($activity->checkout_feeling);
    }

    private function wellbeingScore(Collection $activities, array $selfReportLevels = []): float
    {
        $checkinRows = $activities->filter(fn (Activity $activity) => $activity->checkin_mood !== null);
        $checkoutRows = $activities->filter(fn (Activity $activity) => $this->hasStructuredPostJournal($activity));
        $totalSessions = $checkinRows->count() + $checkoutRows->count();
        $negativeSessions = $checkinRows->filter(fn (Activity $activity) => $this->checkinNegative($activity))->count()
            + $checkoutRows->filter(fn (Activity $activity) => $this->checkoutNegative($activity))->count();
        $negativeRatio = $totalSessions > 0 ? $negativeSessions / $totalSessions : 0;

        $intensities = $this->negativeIntensityValues($activities);
        $averageNegativeIntensity = count($intensities) > 0 ? array_sum($intensities) / count($intensities) : 0;
        $worsening = max(0, $this->checkoutNegativeRatio($activities) - $this->checkinNegativeRatio($activities));
        $density = $this->dimensionDensity($activities);

        $score = 0;
        $score += $negativeRatio * 35;
        $score += $averageNegativeIntensity * 15;
        $score += $worsening * 15;
        $score += $density * 20;
        if ($selfReportLevels !== []) {
            $score += (array_sum($selfReportLevels) / count($selfReportLevels) / 10) * 15;
        } else {
            $score += $negativeRatio * 15;
        }

        return min(100, $score);
    }

    private function checkinNegative(Activity $activity): bool
    {
        return $activity->checkin_mood !== null
            && in_array($activity->checkin_mood, self::CHECKIN_NEGATIVE_MOODS, true);
    }

    private function checkoutNegative(Activity $activity): bool
    {
        return $this->hasStructuredPostJournal($activity)
            && (in_array($activity->checkout_mood, self::CHECKOUT_NEGATIVE_MOODS, true)
                || $this->hasPressureText($this->checkoutText($activity)));
    }

    private function checkinNegativeRatio(Collection $activities): float
    {
        $rows = $activities->filter(fn (Activity $activity) => $activity->checkin_mood !== null);

        return $rows->isEmpty() ? 0 : $rows->filter(fn (Activity $activity) => $this->checkinNegative($activity))->count() / $rows->count();
    }

    private function checkoutNegativeRatio(Collection $activities): float
    {
        $rows = $activities->filter(fn (Activity $activity) => $this->hasStructuredPostJournal($activity));

        return $rows->isEmpty() ? 0 : $rows->filter(fn (Activity $activity) => $this->checkoutNegative($activity))->count() / $rows->count();
    }

    private function negativeIntensityValues(Collection $activities): array
    {
        $values = [];

        foreach ($activities as $activity) {
            if ($this->checkinNegative($activity)) {
                $values[] = (($activity->checkin_intensity ?? 5) / 10);
            }
            if ($this->checkoutNegative($activity)) {
                $values[] = in_array($activity->checkout_mood, self::CHECKOUT_NEGATIVE_MOODS, true) ? 0.7 : 0.5;
            }
        }

        return $values;
    }

    private function dimensionDensity(Collection $activities): float
    {
        $rows = $activities->filter(fn (Activity $activity) => $this->hasStructuredPostJournal($activity));
        if ($rows->isEmpty()) {
            return 0;
        }

        $pressureCount = $rows
            ->filter(fn (Activity $activity) => $this->hasPressureText($this->checkoutText($activity))
                || count($this->burnoutDimensions($activity)) > 0)
            ->count();

        return min($pressureCount / $rows->count(), 1);
    }

    private function category(float $score): string
    {
        if ($score < 40) {
            return 'hijau';
        }

        if ($score < 70) {
            return 'kuning';
        }

        return 'merah';
    }

    private function applyRiskFloor(?float $score, ?string $category, array $dominantFactors): array
    {
        if ($score === null || $category === 'merah') {
            return [$score, $category];
        }

        $yellowSignals = [
            'checkout_negative_mood',
            'journal_pressure_terms',
            'teacher_self_report_high',
            'high_wellbeing_pressure',
        ];

        if (array_intersect($yellowSignals, $dominantFactors) !== []) {
            $score = max($score, 40);
            $category = $this->category($score);
        }

        return [$score, $category];
    }

    private function dominantFactors(float $workloadScoreRaw, float $journalScore, Collection $completed, array $selfReportLevels = []): array
    {
        $factors = [];

        if ($workloadScoreRaw > 100) {
            $factors[] = 'workload_over_capacity';
        } elseif ($workloadScoreRaw >= 80) {
            $factors[] = 'dense_workload';
        }

        if ($journalScore >= 70) {
            $factors[] = 'high_wellbeing_pressure';
        }

        if ($selfReportLevels !== [] && (array_sum($selfReportLevels) / count($selfReportLevels)) >= 7) {
            $factors[] = 'teacher_self_report_high';
        }

        if ($completed->filter(fn (Activity $activity) => (bool) $activity->checkout_crisis_flag)->isNotEmpty()) {
            $factors[] = 'crisis_flag';
        }

        if ($this->checkoutNegativeRatio($completed) >= 0.5) {
            $factors[] = 'checkout_negative_mood';
        }

        $journalRows = $completed->filter(fn (Activity $activity) => $this->hasStructuredPostJournal($activity));
        if ($journalRows->isNotEmpty() && $this->dimensionDensity($completed) >= 0.5) {
            $factors[] = 'journal_pressure_terms';
        }

        $highIntensityCount = $completed->filter(fn (Activity $activity) => (float) $activity->intensity_factor >= 1.5)->count();
        if ($highIntensityCount >= 2) {
            $factors[] = 'consecutive_high_intensity';
        }

        $lateActivities = $completed->filter(fn (Activity $activity) => $activity->end_at !== null && $activity->end_at->hour >= 18)->count();
        if ($lateActivities > 0) {
            $factors[] = 'late_activity';
        }

        return $factors ?: ['balanced_period'];
    }

    private function checkoutText(Activity $activity): string
    {
        return collect([
            $activity->checkout_fact,
            $activity->checkout_feeling,
            $activity->checkout_pattern,
            $activity->checkout_plan,
        ])->filter(fn ($value) => filled($value))->implode(' ');
    }

    private function journalReviews(Collection $journalRows): array
    {
        return $journalRows
            ->sortByDesc(fn (Activity $activity) => $activity->checkout_at)
            ->map(fn (Activity $activity) => [
                'activity_id' => $activity->id,
                'title' => $activity->title,
                'activity_date' => $activity->activity_date?->toDateString(),
                'checked_out_at' => $activity->checkout_at?->toIso8601String(),
                'mood' => $activity->checkout_mood,
                'mood_detected' => $activity->checkout_mood_detected,
                'fact' => $activity->checkout_fact,
                'feeling' => $activity->checkout_feeling,
                'pattern' => $activity->checkout_pattern,
                'plan' => $activity->checkout_plan,
                'suggestion' => $activity->checkout_suggestion,
                'crisis_flag' => (bool) $activity->checkout_crisis_flag,
                'burnout_dimensions' => $this->burnoutDimensions($activity),
                'analysis_source' => $activity->checkout_analysis_source,
            ])
            ->values()
            ->all();
    }

    private function activityBreakdown(Collection $activities): array
    {
        return $activities
            ->sortBy(fn (Activity $activity) => $activity->start_at ?? $activity->created_at)
            ->map(function (Activity $activity) {
                $score = $this->activityRiskScore($activity);

                return [
                    'activity_id' => $activity->id,
                    'title' => $activity->title,
                    'activity_date' => $activity->activity_date?->toDateString(),
                    'status' => $activity->status,
                    'category_name' => $activity->category,
                    'start_at' => $activity->start_at?->toIso8601String(),
                    'end_at' => $activity->end_at?->toIso8601String(),
                    'planned_hours' => (float) $activity->planned_hours,
                    'actual_hours' => $activity->actual_hours === null ? null : (float) $activity->actual_hours,
                    'weighted_current_hours' => round($this->effectiveHours($activity) * (float) $activity->intensity_factor, 2),
                    'checkin_mood' => $activity->checkin_mood,
                    'checkout_mood' => $activity->checkout_mood,
                    'mood_detected' => $activity->checkout_mood_detected,
                    'has_journal' => $this->hasStructuredPostJournal($activity),
                    'burnout_dimensions' => $this->burnoutDimensions($activity),
                    'score' => round($score, 2),
                    'condition' => $this->category($score),
                ];
            })
            ->values()
            ->all();
    }

    private function activityRiskScore(Activity $activity): float
    {
        $score = min(35, ($this->effectiveHours($activity) * (float) $activity->intensity_factor / self::MAX_DAILY_CAPACITY_HOURS) * 100);

        if ($this->checkinNegative($activity)) {
            $score += 10 + (($activity->checkin_intensity ?? 5) / 10) * 10;
        }

        if ($this->checkoutNegative($activity)) {
            $score += in_array($activity->checkout_mood, self::CHECKOUT_NEGATIVE_MOODS, true) ? 20 : 12;
        }

        if ($this->hasPressureText($this->checkoutText($activity))) {
            $score += 12;
        }

        $score += min(20, count($this->burnoutDimensions($activity)) * 10);

        if ((bool) $activity->checkout_crisis_flag) {
            $score = max($score, 85);
        }

        return min(100, $score);
    }

    private function burnoutDimensions(Activity $activity): array
    {
        return array_values(array_unique(array_filter([
            ...($activity->checkout_burnout_tags ?? []),
            ...($activity->checkout_auto_burnout_tags ?? []),
        ])));
    }

    private function hasPressureText(string $text): bool
    {
        $normalized = strtolower($text);

        foreach (self::JOURNAL_PRESSURE_KEYWORDS as $keyword) {
            if (str_contains($normalized, $keyword)) {
                return true;
            }
        }

        return false;
    }

    private function practiceCodeFor(?string $category, array $dominantFactors, string $role): string
    {
        if (in_array('crisis_flag', $dominantFactors, true)) {
            return 'grounding_321';
        }
        if (in_array('teacher_self_report_high', $dominantFactors, true)) {
            return 'body_scan_full';
        }
        if (in_array('journal_pressure_terms', $dominantFactors, true)) {
            return 'sitting_meditation';
        }
        if (in_array('checkout_negative_mood', $dominantFactors, true)) {
            return 'body_scan_micro';
        }
        if (in_array('consecutive_high_intensity', $dominantFactors, true)
            || in_array('dense_workload', $dominantFactors, true)) {
            return 'mindful_movement';
        }

        return match ($category) {
            'merah' => $role === 'student' ? 'grounding_321' : 'body_scan_full',
            'kuning' => 'body_scan_micro',
            'hijau' => $role === 'student' ? 'breathing_space_3min' : 'maintain_breath_awareness',
            default => 'breathing_space_3min',
        };
    }

    private function recommendation(?string $category, array $dominantFactors, User $user): array
    {
        $role = $user->isStudent() ? 'student' : 'teacher';

        if ($category === null) {
            $practiceCode = $this->practiceCodeFor(null, $dominantFactors, $role);
            $practice = self::PRACTICE_CATALOG[$practiceCode];

            return [
                'codes' => ['complete_activity_journal'],
                'headline' => 'Data belum cukup',
                'action' => 'Lengkapi check-in, check-out, dan jurnal pasca pada minimal satu aktivitas lalu jalankan analisis ulang.',
                'practice' => $practice['practice'],
                'practice_code' => $practiceCode,
                'practice_title' => $practice['title'],
                'dominant_factors' => $dominantFactors,
            ];
        }

        $matrix = [
            'hijau' => [
                'codes' => ['maintain_breath_awareness', 'mindful_transition'],
                'headline' => 'Risiko rendah',
                'action' => 'Pertahankan ritme aktivitas dan beri jeda transisi singkat antar kegiatan.',
                'practice' => $role === 'student'
                    ? 'Latihan napas 3 putaran sebelum belajar.'
                    : 'Awareness of breathing 2-3 menit sebelum masuk kelas.',
            ],
            'kuning' => [
                'codes' => ['body_scan_micro', 'recovery_break', 'mindful_movement'],
                'headline' => 'Perlu jeda pemulihan',
                'action' => 'Identifikasi aktivitas paling menguras, kurangi multitasking, dan sisipkan recovery break.',
                'practice' => $role === 'student'
                    ? 'Body awareness singkat dan jeda layar 5 menit.'
                    : 'Body scan singkat 5-10 menit atau mindful stretch.',
            ],
            'merah' => [
                'codes' => ['guided_breathing', 'workload_adjustment', 'support_check'],
                'headline' => 'Prioritaskan pemulihan',
                'action' => 'Tinjau ulang todo-list, pindahkan aktivitas yang dapat ditunda, dan hubungi pendamping bila tekanan berlanjut.',
                'practice' => $role === 'student'
                    ? 'Guided breathing sederhana dengan pendamping atau wali kelas.'
                    : 'Sitting meditation fokus napas 10 menit dan rencana penyesuaian beban.',
            ],
        ];

        $codes = $matrix[$category]['codes'];
        $action = $matrix[$category]['action'];
        $practice = $matrix[$category]['practice'];

        if (in_array('crisis_flag', $dominantFactors, true)) {
            $codes[] = 'support_check';
            $action = 'Ada sinyal krisis pada jurnal. Hubungi pendamping, guru BK, keluarga, atau layanan profesional sebelum menambah beban aktivitas.';
            $practice = 'Grounding napas singkat sambil ditemani orang tepercaya.';
        } elseif (in_array('journal_pressure_terms', $dominantFactors, true)) {
            $codes[] = 'stress_regulation_from_journal';
            $action = 'Jurnal checkout memuat tanda tekanan. Turunkan kepadatan aktivitas paling menekan, beri batas waktu jelas, dan sisipkan jeda regulasi setelah aktivitas berat.';
            $practice = $role === 'student'
                ? 'Napas 4 hitungan masuk dan 6 hitungan keluar selama 3 menit setelah belajar intens.'
                : 'Awareness of breathing 3-5 menit setelah kelas atau tugas administratif berat.';
        } elseif (in_array('checkout_negative_mood', $dominantFactors, true)) {
            $codes[] = 'recovery_plan_from_journal';
            $action = 'Mood checkout sering berada di area negatif. Jadwalkan aktivitas pemulihan nyata sebelum menambah tugas baru.';
            $practice = $role === 'student'
                ? 'Body scan singkat 5 menit, lalu pisahkan belajar berikutnya menjadi blok lebih kecil.'
                : 'Body scan 5-10 menit dan jeda tanpa layar sebelum aktivitas berikutnya.';
        } elseif (in_array('teacher_self_report_high', $dominantFactors, true)) {
            $codes[] = 'teacher_recovery_plan';
            $action = 'Refleksi kondisi guru menunjukkan tekanan tinggi. Kurangi aktivitas rendah prioritas dan buat jeda pemulihan yang benar-benar terjadwal.';
            $practice = 'Body scan 15-20 menit atau mindful movement ringan setelah jam mengajar.';
        }

        $practiceCode = $this->practiceCodeFor($category, $dominantFactors, $role);
        $catalogPractice = self::PRACTICE_CATALOG[$practiceCode];

        return [
            ...$matrix[$category],
            'codes' => array_values(array_unique($codes)),
            'action' => $action,
            'practice' => $catalogPractice['practice'] ?: $practice,
            'practice_code' => $practiceCode,
            'practice_title' => $catalogPractice['title'],
            'dominant_factors' => $dominantFactors,
        ];
    }
}
