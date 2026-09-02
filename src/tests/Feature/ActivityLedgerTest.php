<?php

use App\Models\Activity;
use App\Models\BurnoutAnalysisSnapshot;
use App\Models\MindfulTactic;
use App\Models\SchoolClass;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Spatie\Permission\Models\Role;

uses(RefreshDatabase::class);

test('activity ledger flow stores journals and only scores during manual analysis', function () {
    config(['services.mindful_ml.url' => null]);

    Role::create(['name' => 'teacher']);
    $user = User::factory()->create();
    $user->assignRole('teacher');
    Sanctum::actingAs($user);

    $activityId = $this->postJson('/api/activities', [
        'title' => 'Mengajar Matematika 5A',
        'activity_date' => '2026-08-27',
        'start_time' => '07:00',
        'end_time' => '08:00',
        'category' => 'mengajar',
    ])
        ->assertCreated()
        ->assertJsonPath('activity.status', Activity::STATUS_PLANNED)
        ->json('activity.id');

    $this->postJson("/api/activities/{$activityId}/check-in", [
        'mood' => 'cemas',
        'intensity' => 6,
        'trigger' => 'Sedikit tegang karena materi baru.',
    ])
        ->assertOk()
        ->assertJsonPath('checkin_mood', 'cemas')
        ->assertJsonPath('checkin_intensity', 6)
        ->assertJsonPath('checkin_trigger', 'Sedikit tegang karena materi baru.');

    expect(BurnoutAnalysisSnapshot::count())->toBe(0);

    $this->postJson("/api/activities/{$activityId}/check-out", [
        'mood' => 'cemas',
        'fact' => 'Kelas padat dan suara banyak dipakai saat mengajar.',
        'feeling' => 'Saya merasa lelah dan perlu jeda.',
        'plan' => 'Besok memberi jeda singkat setelah kelas.',
    ])
        ->assertOk()
        ->assertJsonPath('status', Activity::STATUS_COMPLETED)
        ->assertJsonPath('checkout_mood', 'cemas')
        ->assertJsonPath('checkout_fact', 'Kelas padat dan suara banyak dipakai saat mengajar.')
        ->assertJsonPath('checkout_feeling', 'Saya merasa lelah dan perlu jeda.')
        ->assertJsonPath('checkout_plan', 'Besok memberi jeda singkat setelah kelas.')
        ->assertJsonPath('checkout_mood_detected', 'lelah')
        ->assertJsonPath('checkout_analysis_source', 'php-fallback')
        ->assertJsonPath('checkout_crisis_flag', false);

    expect(BurnoutAnalysisSnapshot::count())->toBe(0);

    $this->postJson('/api/burnout-analyses', [
        'period_type' => 'daily',
        'date' => '2026-08-27',
    ])
        ->assertCreated()
        ->assertJsonPath('data_sufficiency', true)
        ->assertJsonPath('category', 'kuning');

    expect(BurnoutAnalysisSnapshot::count())->toBe(1);
});

test('activity form accepts website schedule fields and optional times', function () {
    config(['services.mindful_ml.url' => null]);

    Role::create(['name' => 'teacher']);
    $user = User::factory()->create();
    $user->assignRole('teacher');
    Sanctum::actingAs($user);

    $this->postJson('/api/activities', [
        'title' => 'Rapat refleksi mingguan',
        'activity_date' => '2026-08-27',
        'start_time' => null,
        'end_time' => null,
        'category' => 'rapat',
    ])
        ->assertCreated()
        ->assertJsonCount(1, 'activities')
        ->assertJsonPath('activity.activity_date', '2026-08-27')
        ->assertJsonPath('activity.category', 'rapat')
        ->assertJsonPath('activity.start_at', null)
        ->assertJsonPath('activity.end_at', null);

    expect(Activity::count())->toBe(1);
});

test('activity form can map repeated weekly and monthly activities without retyping', function () {
    config(['services.mindful_ml.url' => null]);

    Role::create(['name' => 'teacher']);
    $user = User::factory()->create();
    $user->assignRole('teacher');
    Sanctum::actingAs($user);

    $this->postJson('/api/activities', [
        'title' => 'Rapat refleksi mingguan',
        'activity_date' => '2026-08-03',
        'start_time' => '09:00',
        'end_time' => '10:00',
        'category' => 'rapat',
        'repeat_type' => 'weekly',
        'repeat_until' => '2026-08-31',
    ])
        ->assertCreated()
        ->assertJsonPath('created_count', 5)
        ->assertJsonPath('skipped_count', 0)
        ->assertJsonPath('repeat_type', 'weekly')
        ->assertJsonPath('activities.4.activity_date', '2026-08-31');

    $this->postJson('/api/activities', [
        'title' => 'Rapat refleksi mingguan',
        'activity_date' => '2026-08-03',
        'start_time' => '09:00',
        'end_time' => '10:00',
        'category' => 'rapat',
        'repeat_type' => 'weekly',
        'repeat_until' => '2026-08-31',
    ])
        ->assertCreated()
        ->assertJsonPath('created_count', 0)
        ->assertJsonPath('skipped_count', 5);

    $this->postJson('/api/activities', [
        'title' => 'Review bulanan',
        'activity_date' => '2026-08-31',
        'category' => 'administrasi',
        'repeat_type' => 'monthly',
        'repeat_until' => '2026-10-31',
    ])
        ->assertCreated()
        ->assertJsonPath('created_count', 3)
        ->assertJsonPath('activities.1.activity_date', '2026-09-30')
        ->assertJsonPath('activities.2.activity_date', '2026-10-30');

    expect(Activity::count())->toBe(8);
});

test('burnout overview exposes today scale and daily recap graph data', function () {
    config(['services.mindful_ml.url' => null]);

    Role::create(['name' => 'teacher']);
    $user = User::factory()->create();
    $user->assignRole('teacher');
    Sanctum::actingAs($user);

    $activityId = $this->postJson('/api/activities', [
        'title' => 'Input laporan',
        'activity_date' => now()->toDateString(),
        'start_time' => '08:00',
        'end_time' => '09:00',
        'category' => 'rapat',
    ])->json('activity.id');

    $this->postJson("/api/activities/{$activityId}/check-in", [
        'mood' => 'tenang',
        'intensity' => 5,
    ])->assertOk();

    $this->postJson("/api/activities/{$activityId}/check-out", [
        'mood' => 'cemas',
        'fact' => 'Laporan terasa padat dan perlu dirapikan cepat.',
        'feeling' => 'Saya merasa cukup stres.',
        'plan' => 'Besok pecah laporan menjadi bagian kecil.',
    ])->assertOk();

    $this->getJson('/api/burnout-analyses/overview')
        ->assertOk()
        ->assertJsonPath('today.data_sufficiency', true)
        ->assertJsonPath('today.activity_count', 1)
        ->assertJsonPath('today.completed_activity_count', 1)
        ->assertJsonPath('today.journal_count', 1)
        ->assertJsonPath('today.journal_reviews.0.title', 'Input laporan')
        ->assertJsonPath('today.journal_reviews.0.mood_detected', 'lelah')
        ->assertJsonPath('today.calculation.formula', 'Final = 0.50 x min(100, Workload Score) + 0.50 x Wellbeing Score')
        ->assertJsonCount(14, 'daily_history')
        ->assertJsonCount(3, 'analogies');
});

test('daily analysis counts every checkout journal and returns all ai reviews', function () {
    config(['services.mindful_ml.url' => null]);

    Role::create(['name' => 'teacher']);
    $user = User::factory()->create();
    $user->assignRole('teacher');
    Sanctum::actingAs($user);

    $firstId = $this->postJson('/api/activities', [
        'title' => 'Kelas pagi',
        'activity_date' => now()->toDateString(),
        'start_time' => '07:00',
        'end_time' => '08:00',
        'category' => 'mengajar',
    ])->json('activity.id');

    $secondId = $this->postJson('/api/activities', [
        'title' => 'Rapat sore',
        'activity_date' => now()->toDateString(),
        'start_time' => '15:00',
        'end_time' => '16:00',
        'category' => 'rapat',
    ])->json('activity.id');

    foreach ([$firstId, $secondId] as $activityId) {
        $this->postJson("/api/activities/{$activityId}/check-in", [
            'mood' => 'cemas',
            'intensity' => 7,
        ])->assertOk();
    }

    $this->postJson("/api/activities/{$firstId}/check-out", [
        'mood' => 'cemas',
        'fact' => 'Kelas berjalan padat.',
        'feeling' => 'Saya merasa lelah setelah mengajar.',
        'plan' => 'Ambil jeda napas.',
    ])->assertOk();

    $this->postJson("/api/activities/{$secondId}/check-out", [
        'mood' => 'sedih',
        'fact' => 'Rapat selesai lebih intens dari rencana.',
        'feeling' => 'Saya capek dan kewalahan.',
        'plan' => 'Kurangi agenda tambahan.',
    ])->assertOk();

    $this->getJson('/api/burnout-analyses/overview')
        ->assertOk()
        ->assertJsonPath('today.activity_count', 2)
        ->assertJsonPath('today.completed_activity_count', 2)
        ->assertJsonPath('today.journal_count', 2)
        ->assertJsonCount(2, 'today.journal_reviews');

    $this->getJson('/api/activities?date='.now()->toDateString())
        ->assertOk()
        ->assertJsonPath('latest_analysis.activity_count', 2)
        ->assertJsonPath('latest_analysis.completed_activity_count', 2)
        ->assertJsonPath('latest_analysis.journal_count', 2)
        ->assertJsonPath('latest_analysis.category', 'kuning')
        ->assertJsonCount(2, 'latest_analysis.journal_reviews');

    $this->postJson('/api/burnout-analyses', [
        'period_type' => 'daily',
        'date' => now()->toDateString(),
    ])
        ->assertCreated()
        ->assertJsonPath('activity_count', 2)
        ->assertJsonPath('completed_activity_count', 2)
        ->assertJsonPath('payload.journal_count', 2)
        ->assertJsonCount(2, 'payload.journal_reviews');

    $this->postJson('/api/burnout-analyses', [
        'period_type' => 'weekly',
        'date' => now()->toDateString(),
    ])
        ->assertCreated()
        ->assertJsonPath('activity_count', 2)
        ->assertJsonPath('completed_activity_count', 2)
        ->assertJsonPath('payload.journal_count', 2)
        ->assertJsonCount(2, 'payload.journal_reviews');
});

test('one angry checkout raises the daily status to yellow while counting all journals', function () {
    config(['services.mindful_ml.url' => null]);

    Role::create(['name' => 'teacher']);
    $user = User::factory()->create();
    $user->assignRole('teacher');
    Sanctum::actingAs($user);

    $positiveId = $this->postJson('/api/activities', [
        'title' => 'Ngajar bahasa indonesia',
        'activity_date' => now()->toDateString(),
        'start_time' => '08:00',
        'end_time' => '09:00',
        'category' => 'mengajar',
    ])->json('activity.id');

    $angryId = $this->postJson('/api/activities', [
        'title' => 'Ngajar bahasa inggris',
        'activity_date' => now()->toDateString(),
        'start_time' => '10:00',
        'end_time' => '11:00',
        'category' => 'mengajar',
    ])->json('activity.id');

    $this->postJson("/api/activities/{$positiveId}/check-in", [
        'mood' => 'senang',
        'intensity' => 5,
    ])->assertOk();

    $this->postJson("/api/activities/{$positiveId}/check-out", [
        'mood' => 'tenang',
        'fact' => 'Murid mudah memahami materi.',
        'feeling' => 'Saya merasa lega dan nyaman.',
        'plan' => 'Besok mengulang metode yang sama.',
    ])->assertOk();

    $this->postJson("/api/activities/{$angryId}/check-in", [
        'mood' => 'marah',
        'intensity' => 5,
    ])->assertOk();

    $this->postJson("/api/activities/{$angryId}/check-out", [
        'mood' => 'marah',
        'fact' => 'Tidak ada yang memahami penjelasan.',
        'feeling' => 'Saya kesal, marah, dan ingin menyelesaikan kelas secepat mungkin.',
        'pattern' => 'Mulai kesal dan malas mengajar.',
        'plan' => 'Besok akan lebih ketat dalam pengajaran.',
        'burnout_tags' => ['kelelahan_emosional'],
    ])->assertOk();

    $this->getJson('/api/burnout-analyses/overview')
        ->assertOk()
        ->assertJsonPath('today.activity_count', 2)
        ->assertJsonPath('today.completed_activity_count', 2)
        ->assertJsonPath('today.journal_count', 2)
        ->assertJsonPath('today.category', 'kuning')
        ->assertJsonPath('today.score', 40)
        ->assertJsonPath('today.activity_breakdown.1.title', 'Ngajar bahasa inggris')
        ->assertJsonPath('today.activity_breakdown.1.condition', 'merah')
        ->assertJsonCount(2, 'today.journal_reviews');

    $this->getJson('/api/activities?date='.now()->toDateString())
        ->assertOk()
        ->assertJsonPath('latest_analysis.category', 'kuning')
        ->assertJsonPath('latest_analysis.journal_count', 2)
        ->assertJsonCount(2, 'latest_analysis.activity_breakdown');
});

test('students can open guided mindfulness toolkit with knowledge and steps', function () {
    Role::create(['name' => 'student']);
    $user = User::factory()->create();
    $user->assignRole('student');
    Sanctum::actingAs($user);

    MindfulTactic::create([
        'title' => 'Napas 4-7-8',
        'category' => 'breathing_478',
        'description' => 'Tarik napas 4, tahan 7, buang 8.',
        'knowledge' => 'Ritme napas membantu tubuh lebih tenang.',
        'duration_minutes' => 5,
        'steps' => ['Tarik napas', 'Tahan', 'Buang napas'],
        'cues' => ['Tarik', 'Tahan', 'Buang'],
        'best_for' => ['cemas'],
        'sort_order' => 1,
    ]);

    $this->getJson('/api/toolkit/tactics')
        ->assertOk()
        ->assertJsonPath('0.category', 'breathing_478')
        ->assertJsonPath('0.knowledge', 'Ritme napas membantu tubuh lebih tenang.')
        ->assertJsonPath('0.duration_minutes', 5)
        ->assertJsonPath('0.steps.0', 'Tarik napas');
});

test('manual burnout analysis recalculates after adding activity on the same day', function () {
    config(['services.mindful_ml.url' => null]);

    Role::create(['name' => 'teacher']);
    $user = User::factory()->create();
    $user->assignRole('teacher');
    Sanctum::actingAs($user);

    $completedId = $this->postJson('/api/activities', [
        'title' => 'Matematika kelas pagi',
        'activity_date' => '2026-08-27',
        'start_time' => '07:00',
        'end_time' => '08:00',
        'category' => 'mengajar',
    ])->json('activity.id');

    $this->postJson("/api/activities/{$completedId}/check-in", [
        'mood' => 'tenang',
        'intensity' => 5,
    ])->assertOk();

    $this->postJson("/api/activities/{$completedId}/check-out", [
        'mood' => 'cemas',
        'fact' => 'Materi berjalan padat dan kelas perlu perhatian ekstra.',
        'feeling' => 'Saya merasa lelah setelah kelas.',
        'plan' => 'Besok siapkan jeda sebelum kelas tambahan.',
    ])->assertOk();

    $this->postJson('/api/burnout-self-reports', [
        'level' => 8,
    ])->assertCreated();

    $firstScore = $this->postJson('/api/burnout-analyses', [
        'period_type' => 'daily',
        'date' => '2026-08-27',
    ])
        ->assertCreated()
        ->assertJsonPath('activity_count', 1)
        ->json('final_burnout_risk_score');

    $this->postJson('/api/activities', [
        'title' => 'Matematika tambahan',
        'activity_date' => '2026-08-27',
        'start_time' => '13:00',
        'end_time' => '17:00',
        'category' => 'mengajar',
    ])->assertCreated();

    $second = $this->postJson('/api/burnout-analyses', [
        'period_type' => 'daily',
        'date' => '2026-08-27',
    ])
        ->assertCreated()
        ->assertJsonPath('activity_count', 2)
        ->assertJsonPath('category', 'merah')
        ->json();

    expect((float) $second['weighted_actual_hours'])->toBe(7.5);
    expect($second['final_burnout_risk_score'])->toBeGreaterThan($firstScore);
});

test('manual burnout analysis stores fastapi recommendation when ml service is available', function () {
    config(['services.mindful_ml.url' => 'http://ml:8000']);

    MindfulTactic::create([
        'title' => 'Body Scan Singkat',
        'category' => 'body_scan_micro',
        'description' => 'Body scan singkat untuk memulihkan tubuh setelah aktivitas berat.',
        'knowledge' => 'Membaca sensasi tubuh membantu mengenali tekanan lebih awal.',
        'duration_minutes' => 5,
        'steps' => ['Duduk nyaman', 'Pindai kepala sampai kaki', 'Lepaskan tegang perlahan'],
        'cues' => ['Rasakan tubuh', 'Lepaskan tegang'],
        'best_for' => ['lelah', 'marah'],
        'sort_order' => 1,
    ]);

    Http::fake([
        'http://ml:8000/analyze/journal' => Http::response([
            'mood_detected' => 'netral',
            'suggestion' => 'Pertahankan ritme dan beri jeda transisi.',
            'crisis_flag' => false,
            'burnout_dimensions' => [],
            'practice_code' => 'mindful_breathing',
            'practice_title' => 'Mindful Breathing',
            'recommended_movement' => 'Duduk nyaman dan ikuti napas masuk-keluar selama beberapa menit.',
            'why_this_tactic' => 'Jurnal stabil cocok dijaga dengan napas mindful ringan.',
            'source' => 'mock',
            'raw_response' => null,
        ]),
        'http://ml:8000/score/burnout' => Http::response([
            'data_sufficiency' => true,
            'weighted_planned_hours' => 2.0,
            'weighted_actual_hours' => 2.5,
            'workload_score_raw' => 31.25,
            'workload_variance_pct' => 25.0,
            'journal_score' => 72.0,
            'final_burnout_risk_score' => 51.63,
            'category' => 'kuning',
            'dominant_factors' => ['high_wellbeing_pressure'],
            'recommendation_codes' => ['body_scan_micro', 'recovery_break'],
            'recommendation_summary' => [
                'codes' => ['body_scan_micro', 'recovery_break'],
                'headline' => 'Perlu jeda pemulihan dari FastAPI',
                'action' => 'Kurangi aktivitas paling menekan dan sisipkan recovery break.',
                'practice' => 'Body Scan 5 menit.',
                'practice_code' => 'body_scan_micro',
                'practice_title' => 'Body Scan Singkat',
                'source' => 'gemini',
                'tactic' => [
                    'code' => 'body_scan_micro',
                    'category' => 'body_scan_micro',
                    'title' => 'Body Scan Singkat',
                    'description' => 'Body scan singkat untuk memulihkan tubuh setelah aktivitas berat.',
                    'knowledge' => 'Membaca sensasi tubuh membantu mengenali tekanan lebih awal.',
                    'duration_minutes' => 5,
                    'steps' => ['Duduk nyaman', 'Pindai kepala sampai kaki', 'Lepaskan tegang perlahan'],
                    'cues' => ['Rasakan tubuh', 'Lepaskan tegang'],
                    'best_for' => ['lelah', 'marah'],
                ],
                'dominant_factors' => ['high_wellbeing_pressure'],
                'theory_reference' => 'Jon Kabat-Zinn - Mindfulness-Based Stress Reduction (MBSR)',
            ],
            'model_version' => 'fastapi-rule-mbsr-v2.3',
            'scoring_version' => 'scoring-v2.3-mbsr',
        ]),
    ]);

    Role::create(['name' => 'teacher']);
    $user = User::factory()->create();
    $user->assignRole('teacher');
    Sanctum::actingAs($user);

    $activityId = $this->postJson('/api/activities', [
        'title' => 'Kelas pagi',
        'activity_date' => '2026-08-27',
        'start_time' => '07:00',
        'end_time' => '08:00',
        'category' => 'mengajar',
    ])->json('activity.id');

    $this->postJson("/api/activities/{$activityId}/check-in", [
        'mood' => 'senang',
        'intensity' => 5,
    ])->assertOk();

    $this->postJson("/api/activities/{$activityId}/check-out", [
        'mood' => 'tenang',
        'fact' => 'Kelas pagi selesai sesuai rencana.',
        'feeling' => 'Saya merasa cukup stabil.',
        'plan' => 'Tetap beri jeda sebelum aktivitas berikutnya.',
    ])->assertOk();

    $this->postJson('/api/burnout-analyses', [
        'period_type' => 'daily',
        'date' => '2026-08-27',
    ])
        ->assertCreated()
        ->assertJsonPath('model_version', 'fastapi-rule-mbsr-v2.3')
        ->assertJsonPath('recommendation_summary.headline', 'Perlu jeda pemulihan dari FastAPI')
        ->assertJsonPath('recommendation_summary.practice_code', 'mindful_breathing')
        ->assertJsonPath('recommendation_summary.source', 'gemini')
        ->assertJsonPath('recommendation_summary.tactic.category', 'mindful_breathing')
        ->assertJsonPath('recommendation_summary.tactic.title', 'Mindful Breathing')
        ->assertJsonPath('payload.journal_reviews.0.recommended_tactic.code', 'mindful_breathing')
        ->assertJsonPath('payload.ml_service_used', true)
        ->assertJsonPath('payload.recommendation_source', 'gemini');

    $this->getJson('/api/burnout-analyses')
        ->assertOk()
        ->assertJsonPath('data.0.recommendation_summary.source', 'gemini')
        ->assertJsonPath('data.0.recommendation_summary.tactic.title', 'Mindful Breathing');

    Http::assertSent(fn ($request) => $request->url() === 'http://ml:8000/score/burnout'
        && $request['role_context'] === 'teacher'
        && $request['mindfulness_tactics'][0]['code'] === 'body_scan_micro'
        && $request['mindfulness_tactics'][0]['steps'][1] === 'Pindai kepala sampai kaki'
        && $request['activities'][0]['checkin_mood'] === 'senang'
        && $request['activities'][0]['checkin_intensity'] === 5
        && $request['self_report_levels'] === []
        && $request['activities'][0]['checkout_mood'] === 'tenang'
        && $request['activities'][0]['checkout_fact'] === 'Kelas pagi selesai sesuai rencana.'
        && $request['activities'][0]['checkout_mood_detected'] === 'netral');
    Http::assertSent(fn ($request) => $request->url() === 'http://ml:8000/analyze/journal'
        && $request['fact'] === 'Kelas pagi selesai sesuai rencana.'
        && $request['feeling'] === 'Saya merasa cukup stabil.');
});

test('manual burnout analysis reuses cached ai result when period data is unchanged', function () {
    config(['services.mindful_ml.url' => 'http://ml:8000']);

    MindfulTactic::create([
        'title' => 'Grounding 3-2-1',
        'category' => 'grounding_321',
        'description' => 'Grounding sensorik untuk menurunkan intensitas emosi.',
        'knowledge' => 'Mengamati indra membantu perhatian kembali ke saat ini.',
        'duration_minutes' => 3,
        'steps' => ['Lihat tiga hal', 'Dengar dua suara', 'Rasakan satu napas'],
        'cues' => ['Lihat', 'Dengar', 'Rasakan'],
        'best_for' => ['marah', 'cemas'],
        'sort_order' => 1,
    ]);

    Http::fake([
        'http://ml:8000/analyze/journal' => Http::response([
            'mood_detected' => 'marah',
            'suggestion' => 'Ambil jeda grounding sebelum lanjut.',
            'crisis_flag' => false,
            'burnout_dimensions' => ['kelelahan_emosional'],
            'practice_code' => 'grounding_321',
            'practice_title' => 'Grounding 3-2-1',
            'recommended_movement' => 'Lihat tiga hal, dengar dua suara, lalu rasakan satu napas.',
            'why_this_tactic' => 'Gemini memilih grounding untuk menurunkan intensitas marah setelah rapat.',
            'source' => 'gemini',
            'raw_response' => '{}',
        ]),
        'http://ml:8000/score/burnout' => Http::response([
            'data_sufficiency' => true,
            'weighted_planned_hours' => 2.0,
            'weighted_actual_hours' => 2.0,
            'workload_score_raw' => 25.0,
            'workload_variance_pct' => 0.0,
            'journal_score' => 80.0,
            'final_burnout_risk_score' => 52.5,
            'category' => 'kuning',
            'dominant_factors' => ['checkout_negative_mood'],
            'recommendation_codes' => ['grounding_321'],
            'recommendation_summary' => [
                'codes' => ['grounding_321'],
                'headline' => 'Emosi mulai meninggi',
                'action' => 'Gemini menyarankan grounding karena jurnal menunjukkan marah setelah aktivitas.',
                'practice' => 'Grounding sensorik untuk menurunkan intensitas emosi.',
                'practice_code' => 'grounding_321',
                'practice_title' => 'Grounding 3-2-1',
                'source' => 'gemini',
                'tactic' => [
                    'code' => 'grounding_321',
                    'category' => 'grounding_321',
                    'title' => 'Grounding 3-2-1',
                    'description' => 'Grounding sensorik untuk menurunkan intensitas emosi.',
                    'knowledge' => 'Mengamati indra membantu perhatian kembali ke saat ini.',
                    'duration_minutes' => 3,
                    'steps' => ['Lihat tiga hal', 'Dengar dua suara', 'Rasakan satu napas'],
                    'cues' => ['Lihat', 'Dengar', 'Rasakan'],
                    'best_for' => ['marah', 'cemas'],
                ],
                'dominant_factors' => ['checkout_negative_mood'],
                'theory_reference' => 'Jon Kabat-Zinn - Mindfulness-Based Stress Reduction (MBSR)',
            ],
            'model_version' => 'fastapi-rule-mbsr-v2.3',
            'scoring_version' => 'scoring-v2.3-mbsr',
        ]),
    ]);

    Role::create(['name' => 'teacher']);
    $user = User::factory()->create();
    $user->assignRole('teacher');
    Sanctum::actingAs($user);

    $activityId = $this->postJson('/api/activities', [
        'title' => 'Rapat evaluasi',
        'activity_date' => '2026-08-27',
        'start_time' => '09:00',
        'end_time' => '11:00',
        'category' => 'rapat',
    ])->json('activity.id');

    $this->postJson("/api/activities/{$activityId}/check-in", [
        'mood' => 'senang',
        'intensity' => 4,
    ])->assertOk();

    $this->postJson("/api/activities/{$activityId}/check-out", [
        'mood' => 'marah',
        'fact' => 'Rapat berjalan alot.',
        'feeling' => 'Saya marah dan lelah setelah rapat.',
        'plan' => 'Saya butuh jeda sebelum lanjut.',
    ])->assertOk();

    $this->postJson('/api/burnout-analyses', [
        'period_type' => 'daily',
        'date' => '2026-08-27',
    ])
        ->assertCreated()
        ->assertJsonPath('payload.cache_hit', false)
        ->assertJsonPath('recommendation_summary.source', 'gemini')
        ->assertJsonPath('recommendation_summary.practice_code', 'grounding_321');

    $this->postJson('/api/burnout-analyses', [
        'period_type' => 'daily',
        'date' => '2026-08-27',
    ])
        ->assertCreated()
        ->assertJsonPath('payload.cache_hit', true)
        ->assertJsonPath('recommendation_summary.source', 'gemini')
        ->assertJsonPath('recommendation_summary.practice_code', 'grounding_321');

    expect(BurnoutAnalysisSnapshot::count())->toBe(1);
    Http::assertSentCount(2);
});

test('students join teacher classroom activities with school guard and teacher checkin checkout gates', function () {
    config(['services.mindful_ml.url' => null]);

    Http::fake([
        '*' => Http::response([
            'mood_detected' => 'netral',
            'suggestion' => 'Ambil jeda mindful sebelum lanjut.',
            'crisis_flag' => false,
            'burnout_dimensions' => [],
            'source' => 'mock',
            'raw_response' => null,
        ]),
    ]);

    Role::create(['name' => 'teacher']);
    Role::create(['name' => 'student']);

    $class = SchoolClass::create(['name' => '5A', 'grade' => '5', 'school' => 'SDN Harmoni']);
    $teacher = User::factory()->create(['school' => 'SDN Harmoni']);
    $teacher->assignRole('teacher');
    $student = User::factory()->create([
        'school' => 'SDN Harmoni',
        'class_id' => $class->id,
        'student_verification_code' => 'STU-ABCDE123',
    ]);
    $student->assignRole('student');
    $otherSchoolStudent = User::factory()->create(['school' => 'SDN Lain']);
    $otherSchoolStudent->assignRole('student');
    $otherClass = SchoolClass::create(['name' => '5B', 'grade' => '5', 'school' => 'SDN Harmoni']);
    $otherClassStudent = User::factory()->create([
        'school' => 'SDN Harmoni',
        'class_id' => $otherClass->id,
    ]);
    $otherClassStudent->assignRole('student');

    Sanctum::actingAs($teacher);
    $teacherActivityId = $this->postJson('/api/activities', [
        'title' => 'Mengajar IPA',
        'activity_date' => '2026-09-01',
        'start_time' => '08:00',
        'end_time' => '09:00',
        'activity_kind' => 'Mengajar',
        'activity_type' => Activity::TYPE_CLASSROOM,
        'school_class_name' => '5A',
    ])
        ->assertCreated()
        ->assertJsonPath('activity.activity_type', Activity::TYPE_CLASSROOM)
        ->assertJsonPath('activity.school_class_id', $class->id)
        ->json('activity.id');

    Sanctum::actingAs($otherSchoolStudent);
    $this->postJson("/api/classroom/activities/{$teacherActivityId}/join")
        ->assertForbidden();

    Sanctum::actingAs($otherClassStudent);
    $this->getJson('/api/classroom/activities/available?date=2026-09-01')
        ->assertOk()
        ->assertJsonCount(0, 'activities');
    $this->postJson("/api/classroom/activities/{$teacherActivityId}/join")
        ->assertForbidden();

    Sanctum::actingAs($student);
    $this->getJson('/api/classroom/activities/available?date=2026-09-01')
        ->assertOk()
        ->assertJsonPath('activities.0.id', $teacherActivityId)
        ->assertJsonPath('activities.0.class.name', '5A');

    $studentActivityId = $this->postJson("/api/classroom/activities/{$teacherActivityId}/join")
        ->assertCreated()
        ->assertJsonPath('activity.activity_type', Activity::TYPE_CLASSROOM_STUDENT)
        ->assertJsonPath('activity.teacher_activity_id', $teacherActivityId)
        ->assertJsonPath('activity.classroom_gate.teacher_checkin_available', false)
        ->assertJsonPath('activity.classroom_gate.can_student_check_in', false)
        ->json('activity.id');

    $this->postJson("/api/activities/{$studentActivityId}/check-in", [
        'mood' => 'senang',
        'intensity' => 4,
    ])->assertStatus(422);

    Sanctum::actingAs($teacher);
    $this->postJson("/api/activities/{$teacherActivityId}/check-in", [
        'mood' => 'tenang',
        'intensity' => 4,
    ])->assertOk();

    Sanctum::actingAs($student);
    $this->getJson('/api/activities?date=2026-09-01')
        ->assertOk()
        ->assertJsonPath('activities.0.classroom_gate.teacher_checkin_available', true)
        ->assertJsonPath('activities.0.classroom_gate.teacher_checkout_available', false)
        ->assertJsonPath('activities.0.classroom_gate.can_student_check_in', true)
        ->assertJsonPath('activities.0.classroom_gate.can_student_check_out', false);

    $this->postJson("/api/activities/{$studentActivityId}/check-in", [
        'mood' => 'senang',
        'intensity' => 4,
    ])->assertOk();

    $this->postJson("/api/activities/{$studentActivityId}/check-out", [
        'mood' => 'cemas',
        'fact' => 'Pelajaran cukup padat.',
        'feeling' => 'Saya sedikit cemas.',
    ])->assertStatus(422);

    Sanctum::actingAs($teacher);
    $this->postJson("/api/activities/{$teacherActivityId}/check-out", [
        'mood' => 'tenang',
        'fact' => 'Kelas selesai sesuai rencana.',
        'feeling' => 'Saya merasa stabil.',
    ])->assertOk();

    Sanctum::actingAs($student);
    $this->getJson('/api/activities?date=2026-09-01')
        ->assertOk()
        ->assertJsonPath('activities.0.classroom_gate.teacher_checkout_available', true)
        ->assertJsonPath('activities.0.classroom_gate.can_student_check_out', true);

    $this->postJson("/api/activities/{$studentActivityId}/check-out", [
        'mood' => 'cemas',
        'fact' => 'Pelajaran cukup padat.',
        'feeling' => 'Saya sedikit cemas.',
        'plan' => 'Saya akan mengulang materi pelan-pelan.',
    ])->assertOk();

    Sanctum::actingAs($teacher);
    $this->getJson("/api/teacher/classroom-activities/{$teacherActivityId}/observations")
        ->assertOk()
        ->assertJsonPath('students.0.student.id', $student->id)
        ->assertJsonPath('students.0.activity.teacher_activity_id', $teacherActivityId)
        ->assertJsonPath('students.0.burnout_analysis.activity_count', 1);

    Sanctum::actingAs($teacher);
    $openSchoolActivityId = $this->postJson('/api/activities', [
        'title' => 'Mengajar literasi sekolah',
        'activity_date' => '2026-09-02',
        'start_time' => '10:00',
        'end_time' => '11:00',
        'activity_kind' => 'Mengajar',
        'activity_type' => Activity::TYPE_CLASSROOM,
    ])
        ->assertCreated()
        ->assertJsonPath('activity.activity_type', Activity::TYPE_CLASSROOM)
        ->assertJsonPath('activity.school_class_id', null)
        ->json('activity.id');

    Sanctum::actingAs($student);
    $this->getJson('/api/classroom/activities/available?date=2026-09-02')
        ->assertOk()
        ->assertJsonPath('activities.0.id', $openSchoolActivityId)
        ->assertJsonPath('activities.0.class', null);

    Sanctum::actingAs($otherClassStudent);
    $this->getJson('/api/classroom/activities/available?date=2026-09-02')
        ->assertOk()
        ->assertJsonPath('activities.0.id', $openSchoolActivityId)
        ->assertJsonPath('activities.0.class', null);
});

test('parent links child by verification code and sees child activity dashboard', function () {
    config(['services.mindful_ml.url' => null]);

    Role::create(['name' => 'parent']);
    Role::create(['name' => 'student']);

    $class = SchoolClass::create(['name' => '5B', 'grade' => '5', 'school' => 'SDN Harmoni']);
    $student = User::factory()->create([
        'school' => 'SDN Harmoni',
        'class_id' => $class->id,
        'student_verification_code' => 'STU-PARENT1',
    ]);
    $student->assignRole('student');

    $activity = $student->activities()->create([
        'title' => 'Belajar mandiri',
        'category' => 'belajar',
        'activity_date' => '2026-09-01',
        'planned_hours' => 1,
        'intensity_factor' => 1,
        'intensity_factor_version' => 'test',
        'status' => Activity::STATUS_COMPLETED,
        'checkin_at' => now(),
        'checkin_mood' => 'senang',
        'checkin_intensity' => 4,
        'checkout_at' => now(),
        'actual_hours' => 1,
        'checkout_mood' => 'tenang',
        'checkout_fact' => 'Belajar selesai.',
        'checkout_feeling' => 'Saya merasa cukup baik.',
    ]);
    $activity->appendEvent('activity_completed');

    $this->postJson('/api/register', [
        'name' => 'Orang Tua',
        'email' => 'wali@example.test',
        'password' => 'password123',
        'password_confirmation' => 'password123',
        'role' => 'parent',
        'school' => 'SDN Lain',
        'student_verification_code' => 'STU-PARENT1',
    ])->assertStatus(422);

    $token = $this->postJson('/api/register', [
        'name' => 'Orang Tua',
        'email' => 'wali@example.test',
        'password' => 'password123',
        'password_confirmation' => 'password123',
        'role' => 'parent',
        'school' => 'SDN Harmoni',
        'student_verification_code' => 'STU-PARENT1',
    ])
        ->assertCreated()
        ->assertJsonPath('user.role', 'parent')
        ->assertJsonPath('user.children.0.id', $student->id)
        ->json('token');

    $this->withHeader('Authorization', "Bearer {$token}")
        ->getJson('/api/parent/dashboard?date=2026-09-01')
        ->assertOk()
        ->assertJsonPath('children.0.student.id', $student->id)
        ->assertJsonPath('children.0.activities.0.title', 'Belajar mandiri')
        ->assertJsonPath('children.0.analysis.activity_count', 1);
});
