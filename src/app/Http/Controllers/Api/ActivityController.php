<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Activity;
use App\Models\SchoolClass;
use App\Services\BurnoutAnalysisService;
use App\Services\JournalAnalysisService;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class ActivityController extends Controller
{
    private const CHECKIN_MOODS = ['senang', 'tenang', 'cemas', 'sedih', 'marah'];
    private const BURNOUT_DIMENSIONS = ['kelelahan_emosional', 'depersonalisasi', 'rendah_pencapaian_diri'];

    private const INTENSITY_FACTOR_RULES = [
        [['ulangan', 'ujian'], 1.6],
        [['matematika', 'mtk'], 1.5],
        [['mengajar', 'rapat', 'koreksi'], 1.4],
        [['olahraga'], 1.2],
        [['istirahat', 'santai'], 0.5],
        [['tidur'], 0.4],
    ];

    public function __construct(
        private readonly JournalAnalysisService $journalAnalysisService,
        private readonly BurnoutAnalysisService $burnoutAnalysisService,
    ) {
    }

    public function index(Request $request)
    {
        $date = Carbon::parse($request->query('date', now()->toDateString()));

        $activities = $request->user()->activities()
            ->with([
                'teacherActivity:id,user_id,title,activity_type,checkin_at,checkout_at',
                'teacherActivity.owner:id,name,school',
                'schoolClass:id,name,grade,school',
            ])
            ->whereDate('activity_date', $date)
            ->orderBy('start_at')
            ->get();

        return response()->json([
            'date' => $date->toDateString(),
            'summary' => $this->summary($activities),
            'activities' => $activities->map(fn (Activity $activity) => $this->activityPayload($activity))->values(),
            'latest_analysis' => $this->burnoutAnalysisService->preview($request->user(), 'daily', $date),
        ]);
    }

    public function store(Request $request)
    {
        $validator = $this->validator($request);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $schoolClass = $this->resolveSchoolClassForActivity($request, $data);
        $data['school_class_id'] = $schoolClass?->id;
        $activityDate = $data['activity_date'] ?? now()->toDateString();
        $repeatType = $data['repeat_type'] ?? 'none';
        $dates = $this->activityDates($activityDate, $repeatType, $data['repeat_until'] ?? null);
        $activities = collect();
        $overlap = false;
        $skippedCount = 0;

        foreach ($dates as $date) {
            $dateText = $date->toDateString();
            [$startAt, $endAt] = $this->timestamps($dateText, $data['start_time'] ?? null, $data['end_time'] ?? null);

            if ($startAt !== null && $endAt !== null && $endAt->lessThanOrEqualTo($startAt)) {
                return response()->json(['message' => 'Jam selesai harus setelah jam mulai.'], 422);
            }

            $dateOverlap = $this->hasOverlap($request, $startAt, $endAt);
            $overlap = $overlap || $dateOverlap;

            if ($this->sameActivityExists($request, $dateText, $data, $startAt, $endAt)) {
                $skippedCount++;
                continue;
            }

            $activity = $request->user()->activities()->create([
                'school_id' => $request->user()->school_id,
                'title' => $data['title'],
                'category' => $data['category'] ?? null,
                'activity_type' => $this->activityTypeFor($request, $data),
                'activity_kind' => $data['activity_kind'] ?? null,
                'school_class_id' => $schoolClass?->id,
                'activity_date' => $dateText,
                'start_at' => $startAt,
                'end_at' => $endAt,
                'planned_hours' => $this->plannedHours($startAt, $endAt),
                'intensity_factor' => $this->intensityFactor($data['title'], $data['category'] ?? null),
                'intensity_factor_version' => 'website-keyword-v1',
                'status' => Activity::STATUS_PLANNED,
            ]);

            $activity->appendEvent('activity_created', [
                'overlap_warning' => $dateOverlap,
                'source' => 'todo_list',
                'repeat_type' => $repeatType,
                'school_class_id' => $schoolClass?->id,
            ]);
            $activities->push($activity);
        }

        $firstActivity = $activities->first();

        return response()->json([
            'activity' => $firstActivity,
            'activities' => $activities->values(),
            'created_count' => $activities->count(),
            'skipped_count' => $skippedCount,
            'repeat_type' => $repeatType,
            'repeat_until' => $dates ? end($dates)->toDateString() : $activityDate,
            'overlap_warning' => $overlap,
        ], 201);
    }

    public function show(Request $request, Activity $activity)
    {
        $this->authorizeOwner($request, $activity);

        return response()->json($activity->load('events'));
    }

    public function update(Request $request, Activity $activity)
    {
        $this->authorizeOwner($request, $activity);
        abort_if($activity->status === Activity::STATUS_CANCELLED, 422, 'Activity yang dibatalkan tidak dapat diubah.');

        $validator = $this->validator($request);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $schoolClass = $this->resolveSchoolClassForActivity($request, $data);
        $data['school_class_id'] = $schoolClass?->id;
        $activityDate = $data['activity_date'] ?? $activity->activity_date->toDateString();
        [$startAt, $endAt] = $this->timestamps($activityDate, $data['start_time'] ?? null, $data['end_time'] ?? null);

        if ($startAt !== null && $endAt !== null && $endAt->lessThanOrEqualTo($startAt)) {
            return response()->json(['message' => 'Jam selesai harus setelah jam mulai.'], 422);
        }

        $overlap = $this->hasOverlap($request, $startAt, $endAt, $activity->id);

        $activity->update([
            'school_id' => $request->user()->school_id,
            'title' => $data['title'],
            'category' => $data['category'] ?? null,
            'activity_type' => $this->activityTypeFor($request, $data),
            'activity_kind' => $data['activity_kind'] ?? null,
            'school_class_id' => $schoolClass?->id,
            'activity_date' => $activityDate,
            'start_at' => $startAt,
            'end_at' => $endAt,
            'planned_hours' => $this->plannedHours($startAt, $endAt),
            'intensity_factor' => $this->intensityFactor($data['title'], $data['category'] ?? null),
            'intensity_factor_version' => 'website-keyword-v1',
        ]);

        $activity->appendEvent('activity_rescheduled', [
            'overlap_warning' => $overlap,
            'reminder_reschedule_required' => true,
        ]);

        return response()->json([
            'activity' => $activity->fresh(),
            'overlap_warning' => $overlap,
        ]);
    }

    public function checkIn(Request $request, Activity $activity)
    {
        $this->authorizeOwner($request, $activity);
        abort_if($activity->status === Activity::STATUS_CANCELLED, 422, 'Activity sudah dibatalkan.');
        abort_if($activity->checkin_at !== null, 422, 'Check-in sudah tercatat.');
        $this->authorizeClassroomStudentCheckIn($activity);

        $validator = Validator::make($request->all(), [
            'mood' => ['nullable', 'string', Rule::in(self::CHECKIN_MOODS)],
            'intensity' => ['nullable', 'integer', 'min:1', 'max:10', 'required_with:mood'],
            'trigger' => ['nullable', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $activity->update([
            'checkin_at' => now(),
            'checkin_mood' => $data['mood'] ?? null,
            'checkin_intensity' => $data['intensity'] ?? null,
            'checkin_trigger' => $data['trigger'] ?? null,
            'status' => Activity::STATUS_CHECKED_IN,
        ]);
        $activity->appendEvent('check_in_submitted', [
            'mood' => $data['mood'] ?? null,
            'intensity' => $data['intensity'] ?? null,
            'trigger' => $data['trigger'] ?? null,
        ]);

        return response()->json($this->activityPayload($activity->fresh()));
    }

    public function checkOut(Request $request, Activity $activity)
    {
        $this->authorizeOwner($request, $activity);
        abort_if($activity->status === Activity::STATUS_CANCELLED, 422, 'Activity sudah dibatalkan.');
        abort_if($activity->checkin_at === null, 422, 'Check-in harus dilakukan sebelum check-out.');
        abort_if($activity->checkout_at !== null, 422, 'Check-out sudah tercatat.');
        $this->authorizeClassroomStudentCheckOut($activity);

        $validator = Validator::make($request->all(), [
            'mood' => ['nullable', 'string', Rule::in(self::CHECKIN_MOODS)],
            'fact' => ['nullable', 'string'],
            'feeling' => ['nullable', 'string'],
            'pattern' => ['nullable', 'string'],
            'plan' => ['nullable', 'string'],
            'burnout_tags' => ['nullable', 'array'],
            'burnout_tags.*' => ['string', Rule::in(self::BURNOUT_DIMENSIONS)],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        if (blank($data['fact'] ?? null) && blank($data['feeling'] ?? null)) {
            return response()->json(['message' => 'Isi minimal fakta atau perasaan sebelum check-out.'], 422);
        }

        $checkoutAt = now();
        $actualHours = max(0, $activity->checkin_at->diffInMinutes($checkoutAt) / 60);
        $journalAnalysis = $this->journalAnalysisService->analyze([
            'fact' => $data['fact'] ?? null,
            'feeling' => $data['feeling'] ?? null,
            'pattern' => $data['pattern'] ?? null,
            'plan' => $data['plan'] ?? null,
            'burnout_tags' => $data['burnout_tags'] ?? [],
        ]);

        $activity->update([
            'checkout_at' => $checkoutAt,
            'actual_hours' => round($actualHours, 2),
            'checkout_mood' => $data['mood'] ?? null,
            'checkout_fact' => $data['fact'] ?? null,
            'checkout_feeling' => $data['feeling'] ?? null,
            'checkout_pattern' => $data['pattern'] ?? null,
            'checkout_plan' => $data['plan'] ?? null,
            'checkout_burnout_tags' => $data['burnout_tags'] ?? null,
            'checkout_auto_burnout_tags' => $journalAnalysis['burnout_dimensions'] ?? [],
            'checkout_analysis_source' => $journalAnalysis['source'] ?? null,
            'checkout_analysis_raw_response' => $this->journalAnalysisSnapshot($journalAnalysis),
            'checkout_mood_detected' => $journalAnalysis['mood_detected'] ?? null,
            'checkout_suggestion' => $journalAnalysis['suggestion'] ?? null,
            'checkout_crisis_flag' => (bool) ($journalAnalysis['crisis_flag'] ?? false),
            'status' => Activity::STATUS_COMPLETED,
        ]);
        $activity->appendEvent('check_out_submitted', [
            'actual_hours' => round($actualHours, 2),
            'mood' => $data['mood'] ?? null,
            'fact' => $data['fact'] ?? null,
            'feeling' => $data['feeling'] ?? null,
            'pattern' => $data['pattern'] ?? null,
            'plan' => $data['plan'] ?? null,
            'burnout_tags' => $data['burnout_tags'] ?? [],
            'journal_analysis' => [
                'mood_detected' => $journalAnalysis['mood_detected'] ?? null,
                'suggestion' => $journalAnalysis['suggestion'] ?? null,
                'crisis_flag' => (bool) ($journalAnalysis['crisis_flag'] ?? false),
                'burnout_dimensions' => $journalAnalysis['burnout_dimensions'] ?? [],
                'source' => $journalAnalysis['source'] ?? null,
                'practice_code' => $journalAnalysis['practice_code'] ?? null,
                'practice_title' => $journalAnalysis['practice_title'] ?? null,
            ],
        ]);
        $activity->appendEvent('activity_completed');

        return response()->json($this->activityPayload($activity->fresh()));
    }

    public function cancel(Request $request, Activity $activity)
    {
        $this->authorizeOwner($request, $activity);

        $activity->update(['status' => Activity::STATUS_CANCELLED]);
        $activity->appendEvent('activity_cancelled', ['reminder_cancel_required' => true]);

        return response()->json($activity->fresh());
    }

    public function duplicate(Request $request, Activity $activity)
    {
        $this->authorizeOwner($request, $activity);

        $data = Validator::make($request->all(), [
            'activity_date' => ['nullable', 'date'],
        ])->validate();

        $date = Carbon::parse($data['activity_date'] ?? $activity->activity_date->copy()->addDay()->toDateString());
        $startAt = $activity->start_at ? Carbon::parse($date->toDateString().' '.$activity->start_at->format('H:i:s')) : null;
        $endAt = $activity->end_at ? Carbon::parse($date->toDateString().' '.$activity->end_at->format('H:i:s')) : null;

        $copy = $request->user()->activities()->create([
            'title' => $activity->title,
            'category' => $activity->category,
            'school_id' => $activity->school_id,
            'activity_type' => $activity->activity_type,
            'activity_kind' => $activity->activity_kind,
            'school_class_id' => $activity->school_class_id,
            'teacher_activity_id' => $activity->teacher_activity_id,
            'activity_date' => $date,
            'start_at' => $startAt,
            'end_at' => $endAt,
            'planned_hours' => $activity->planned_hours,
            'intensity_factor' => $activity->intensity_factor,
            'intensity_factor_version' => $activity->intensity_factor_version,
            'status' => Activity::STATUS_PLANNED,
        ]);
        $copy->appendEvent('activity_duplicated', ['from_activity_id' => $activity->id]);

        return response()->json($copy->fresh(), 201);
    }

    public function ledger(Request $request, Activity $activity)
    {
        $this->authorizeOwner($request, $activity);

        return response()->json($activity->events()->orderBy('occurred_at')->get());
    }

    private function validator(Request $request)
    {
        return Validator::make($request->all(), [
            'title' => ['required', 'string', 'max:160'],
            'activity_date' => ['nullable', 'date'],
            'start_time' => ['nullable', 'date_format:H:i'],
            'end_time' => ['nullable', 'date_format:H:i'],
            'category' => ['nullable', 'string', 'max:160'],
            'activity_kind' => ['nullable', 'string', 'max:80'],
            'activity_type' => ['nullable', Rule::in([Activity::TYPE_PERSONAL, Activity::TYPE_CLASSROOM])],
            'school_class_id' => ['nullable', 'integer', 'exists:classes,id'],
            'school_class_name' => ['nullable', 'string', 'max:80'],
            'repeat_type' => ['nullable', Rule::in(['none', 'weekly', 'monthly'])],
            'repeat_until' => ['nullable', 'date', 'after_or_equal:activity_date'],
        ]);
    }

    private function activityDates(string $startDate, string $repeatType, ?string $repeatUntil): array
    {
        $current = Carbon::parse($startDate)->startOfDay();
        $until = match ($repeatType) {
            'weekly' => Carbon::parse($repeatUntil ?? $current->copy()->endOfMonth()->toDateString())->startOfDay(),
            'monthly' => Carbon::parse($repeatUntil ?? $current->copy()->addMonthsNoOverflow(5)->toDateString())->startOfDay(),
            default => $current->copy(),
        };

        if ($repeatType === 'none') {
            return [$current];
        }

        $dates = [];
        while ($current->lessThanOrEqualTo($until) && count($dates) < 31) {
            $dates[] = $current->copy();
            $repeatType === 'weekly'
                ? $current->addWeek()
                : $current->addMonthNoOverflow();
        }

        return $dates ?: [Carbon::parse($startDate)->startOfDay()];
    }

    private function timestamps(string $date, ?string $startTime, ?string $endTime): array
    {
        return [
            $startTime ? Carbon::parse($date.' '.$startTime) : null,
            $endTime ? Carbon::parse($date.' '.$endTime) : null,
        ];
    }

    private function plannedHours(?Carbon $startAt, ?Carbon $endAt): float
    {
        if ($startAt === null || $endAt === null) {
            return 0;
        }

        return round($startAt->diffInMinutes($endAt) / 60, 2);
    }

    private function intensityFactor(string $title, ?string $category): float
    {
        $text = strtolower($title.' '.($category ?? ''));

        foreach (self::INTENSITY_FACTOR_RULES as [$keywords, $factor]) {
            foreach ($keywords as $keyword) {
                if (str_contains($text, $keyword)) {
                    return $factor;
                }
            }
        }

        return 1.0;
    }

    private function hasOverlap(Request $request, ?Carbon $startAt, ?Carbon $endAt, ?int $ignoreId = null): bool
    {
        if ($startAt === null || $endAt === null) {
            return false;
        }

        return $request->user()->activities()
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->when($ignoreId, fn ($query) => $query->whereKeyNot($ignoreId))
            ->where('start_at', '<', $endAt)
            ->where('end_at', '>', $startAt)
            ->exists();
    }

    private function sameActivityExists(Request $request, string $date, array $data, ?Carbon $startAt, ?Carbon $endAt): bool
    {
        return $request->user()->activities()
            ->whereDate('activity_date', $date)
            ->where('title', $data['title'])
            ->where('category', $data['category'] ?? null)
            ->where('activity_kind', $data['activity_kind'] ?? null)
            ->where('school_class_id', $data['school_class_id'] ?? null)
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->when(
                $startAt,
                fn ($query) => $query->where('start_at', $startAt),
                fn ($query) => $query->whereNull('start_at')
            )
            ->when(
                $endAt,
                fn ($query) => $query->where('end_at', $endAt),
                fn ($query) => $query->whereNull('end_at')
            )
            ->exists();
    }

    private function authorizeOwner(Request $request, Activity $activity): void
    {
        abort_if($activity->user_id !== $request->user()->id, 403);
    }

    private function resolveSchoolClassForActivity(Request $request, array $data): ?SchoolClass
    {
        $user = $request->user();
        $kind = strtolower((string) ($data['activity_kind'] ?? ''));
        $activityType = $data['activity_type'] ?? null;
        $className = trim((string) ($data['school_class_name'] ?? ''));
        $classId = $data['school_class_id'] ?? null;
        $isTeaching = $activityType === Activity::TYPE_CLASSROOM
            || str_contains($kind, 'mengajar')
            || str_contains($kind, 'teaching')
            || $className !== ''
            || $classId !== null;

        if (! $isTeaching) {
            return null;
        }

        abort_unless($user->isTeacher(), 403, 'Hanya guru yang dapat membuat activity kelas.');
        abort_if(blank($user->school_id) && blank($user->school), 422, 'Sekolah guru wajib diisi sebelum membuat activity kelas.');

        if ($classId) {
            $schoolClass = SchoolClass::findOrFail($classId);
            abort_if(
                $user->school_id && $schoolClass->school_id && (int) $schoolClass->school_id !== (int) $user->school_id,
                422,
                'Kelas harus berada di sekolah yang sama dengan guru.'
            );
            abort_if(
                ! $user->school_id && filled($schoolClass->school) && strcasecmp($schoolClass->school, $user->school) !== 0,
                422,
                'Kelas harus berada di sekolah yang sama dengan guru.'
            );
        } elseif ($className !== '') {
            $schoolClass = $user->school_id
                ? SchoolClass::firstOrCreate(
                    ['name' => strtoupper($className), 'school_id' => $user->school_id],
                    [
                        'school' => $user->school,
                        'grade' => $this->gradeFromClassName($className),
                    ]
                )
                : SchoolClass::firstOrCreate(
                    ['name' => strtoupper($className), 'school' => $user->school],
                    ['grade' => $this->gradeFromClassName($className)]
                );
        } else {
            return null;
        }

        $schoolClass->forceFill([
            'school_id' => $schoolClass->school_id ?: $user->school_id,
            'school' => $schoolClass->school ?: $user->school,
        ])->save();
        $user->teachingClasses()->syncWithoutDetaching([$schoolClass->id]);

        return $schoolClass;
    }

    private function activityTypeFor(Request $request, array $data): string
    {
        if (($data['activity_type'] ?? null) === Activity::TYPE_CLASSROOM) {
            abort_unless($request->user()->isTeacher(), 403, 'Hanya guru yang dapat membuat activity kelas.');

            return Activity::TYPE_CLASSROOM;
        }

        if (
            $request->user()->isTeacher()
            && (
                str_contains(strtolower((string) ($data['activity_kind'] ?? '')), 'mengajar')
                || str_contains(strtolower((string) ($data['activity_kind'] ?? '')), 'teaching')
                || filled($data['school_class_name'] ?? null)
                || filled($data['school_class_id'] ?? null)
            )
        ) {
            return Activity::TYPE_CLASSROOM;
        }

        return Activity::TYPE_PERSONAL;
    }

    private function authorizeClassroomStudentCheckIn(Activity $activity): void
    {
        if (! $activity->teacher_activity_id) {
            return;
        }

        $teacherActivity = $activity->teacherActivity()->first();
        abort_if(! $teacherActivity || $teacherActivity->checkin_at === null, 422, 'Siswa belum bisa check-in sebelum guru melakukan check-in.');
    }

    private function authorizeClassroomStudentCheckOut(Activity $activity): void
    {
        if (! $activity->teacher_activity_id) {
            return;
        }

        $teacherActivity = $activity->teacherActivity()->first();
        abort_if(! $teacherActivity || $teacherActivity->checkout_at === null, 422, 'Siswa belum bisa check-out sebelum guru melakukan check-out.');
    }

    private function activityPayload(Activity $activity): array
    {
        return [
            ...$activity->toArray(),
            'classroom_gate' => $this->classroomGatePayload($activity),
            'recommended_tactic' => filled($activity->checkout_fact) || filled($activity->checkout_feeling)
                ? $this->burnoutAnalysisService->recommendedTacticForJournalActivity($activity)
                : null,
        ];
    }

    private function journalAnalysisSnapshot(array $journalAnalysis): ?string
    {
        $snapshot = array_filter([
            'mood_detected' => $journalAnalysis['mood_detected'] ?? null,
            'suggestion' => $journalAnalysis['suggestion'] ?? null,
            'crisis_flag' => $journalAnalysis['crisis_flag'] ?? false,
            'burnout_dimensions' => $journalAnalysis['burnout_dimensions'] ?? [],
            'practice_code' => $journalAnalysis['practice_code'] ?? null,
            'practice_title' => $journalAnalysis['practice_title'] ?? null,
            'recommended_movement' => $journalAnalysis['recommended_movement'] ?? null,
            'why_this_tactic' => $journalAnalysis['why_this_tactic'] ?? null,
            'source' => $journalAnalysis['source'] ?? null,
        ], fn ($value) => $value !== null);

        $raw = $journalAnalysis['raw_response'] ?? null;
        if (is_string($raw) && trim($raw) !== '') {
            $decoded = json_decode($raw, true);
            if (is_array($decoded)) {
                $snapshot = array_replace($decoded, $snapshot);
            } else {
                $snapshot['raw_response'] = $raw;
            }
        }

        $json = json_encode($snapshot, JSON_UNESCAPED_UNICODE);

        return is_string($json) ? $json : null;
    }

    private function classroomGatePayload(Activity $activity): ?array
    {
        if (! $activity->teacher_activity_id) {
            return null;
        }

        $teacherActivity = $activity->relationLoaded('teacherActivity')
            ? $activity->teacherActivity
            : $activity->teacherActivity()->with('owner:id,name,school')->first();

        return [
            'teacher_activity_id' => $activity->teacher_activity_id,
            'teacher_checkin_available' => $teacherActivity?->checkin_at !== null,
            'teacher_checkout_available' => $teacherActivity?->checkout_at !== null,
            'can_student_check_in' => $teacherActivity?->checkin_at !== null,
            'can_student_check_out' => $teacherActivity?->checkout_at !== null,
            'message' => match (true) {
                $teacherActivity === null => 'Activity guru tidak ditemukan.',
                $teacherActivity->checkin_at === null => 'Menunggu guru melakukan check-in.',
                $teacherActivity->checkout_at === null => 'Menunggu guru melakukan check-out.',
                default => 'Activity guru sudah lengkap.',
            },
        ];
    }

    private function gradeFromClassName(string $className): ?string
    {
        preg_match('/\d+/', $className, $matches);

        return $matches[0] ?? null;
    }

    private function summary($activities): array
    {
        $active = $activities->where('status', '!=', Activity::STATUS_CANCELLED);
        $completed = $active->where('status', Activity::STATUS_COMPLETED);

        return [
            'planned' => $active->count(),
            'completed' => $completed->count(),
            'checkin_pending' => $active->where('checkin_at', null)->count(),
            'weighted_planned_hours' => round($active->sum(fn (Activity $activity) => (float) $activity->planned_hours * (float) $activity->intensity_factor), 2),
            'weighted_actual_hours' => round($completed->sum(fn (Activity $activity) => max((float) $activity->actual_hours, (float) $activity->planned_hours) * (float) $activity->intensity_factor), 2),
        ];
    }
}
