<?php

use App\Models\Activity;
use App\Models\BurnoutAnalysisSnapshot;
use App\Models\MindfulTactic;
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

    Http::fake([
        'http://ml:8000/analyze/journal' => Http::response([
            'mood_detected' => 'netral',
            'suggestion' => 'Pertahankan ritme dan beri jeda transisi.',
            'crisis_flag' => false,
            'burnout_dimensions' => [],
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
        ->assertJsonPath('recommendation_summary.practice_code', 'body_scan_micro')
        ->assertJsonPath('payload.ml_service_used', true);

    Http::assertSent(fn ($request) => $request->url() === 'http://ml:8000/score/burnout'
        && $request['role_context'] === 'teacher'
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
