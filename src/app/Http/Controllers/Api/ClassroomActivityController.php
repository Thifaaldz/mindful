<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Activity;
use App\Models\User;
use App\Services\BurnoutAnalysisService;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class ClassroomActivityController extends Controller
{
    public function __construct(private readonly BurnoutAnalysisService $burnoutAnalysisService)
    {
    }

    public function available(Request $request)
    {
        $user = $request->user();
        abort_unless($user->isStudent(), 403);
        abort_if(blank($user->school), 422, 'Sekolah siswa wajib diisi sebelum mencari kelas.');

        $date = Carbon::parse($request->query('date', now()->toDateString()));
        $joinedIds = $user->activities()
            ->whereNotNull('teacher_activity_id')
            ->pluck('teacher_activity_id');

        $activities = Activity::query()
            ->with(['owner:id,name,school', 'schoolClass:id,name,grade,school'])
            ->where('activity_type', Activity::TYPE_CLASSROOM)
            ->whereDate('activity_date', $date)
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->whereNotIn('id', $joinedIds)
            ->whereHas('owner', fn ($query) => $query
                ->role('teacher')
                ->whereRaw('LOWER(TRIM(school)) = ?', [strtolower(trim((string) $user->school))]))
            ->where(fn ($query) => $query
                ->whereNull('school_class_id')
                ->orWhere('school_class_id', $user->class_id))
            ->orderBy('start_at')
            ->get();

        return response()->json([
            'date' => $date->toDateString(),
            'activities' => $activities->map(fn (Activity $activity) => $this->classroomActivityPayload($activity))->values(),
        ]);
    }

    public function join(Request $request, Activity $activity)
    {
        $student = $request->user();
        abort_unless($student->isStudent(), 403);
        abort_unless($activity->activity_type === Activity::TYPE_CLASSROOM, 422, 'Activity ini bukan activity kelas.');
        abort_if($activity->status === Activity::STATUS_CANCELLED, 422, 'Activity kelas sudah dibatalkan.');
        abort_if(blank($student->school), 422, 'Sekolah siswa wajib diisi sebelum join kelas.');

        $activity->loadMissing('owner', 'schoolClass');
        abort_if(
            ! $this->sameSchool($student->school, $activity->owner?->school),
            403,
            'Siswa hanya dapat join kelas dari sekolah yang sama.'
        );

        if ($student->class_id && $activity->school_class_id && (int) $student->class_id !== (int) $activity->school_class_id) {
            abort(403, 'Kelas siswa tidak sesuai dengan activity kelas ini.');
        }

        if (! $student->class_id && $activity->school_class_id) {
            abort(403, 'Lengkapi kelas siswa sebelum join activity kelas tertentu.');
        }

        $studentActivity = $student->activities()->firstOrCreate(
            ['teacher_activity_id' => $activity->id],
            [
                'title' => $activity->title,
                'category' => $activity->category,
                'activity_type' => Activity::TYPE_CLASSROOM_STUDENT,
                'activity_kind' => $activity->activity_kind,
                'school_class_id' => $activity->school_class_id,
                'joined_at' => now(),
                'activity_date' => $activity->activity_date,
                'start_at' => $activity->start_at,
                'end_at' => $activity->end_at,
                'planned_hours' => $activity->planned_hours,
                'intensity_factor' => $activity->intensity_factor,
                'intensity_factor_version' => $activity->intensity_factor_version,
                'status' => Activity::STATUS_PLANNED,
            ]
        );

        $wasRecentlyCreated = $studentActivity->wasRecentlyCreated;

        if ($wasRecentlyCreated) {
            $studentActivity->appendEvent('classroom_activity_joined', [
                'teacher_activity_id' => $activity->id,
                'teacher_id' => $activity->user_id,
                'class_id' => $activity->school_class_id,
            ]);
        }

        $studentActivity = $studentActivity->fresh(['teacherActivity.owner:id,name,school', 'schoolClass:id,name,grade,school']);

        return response()->json([
            'activity' => $this->studentActivityPayload($studentActivity),
        ], $wasRecentlyCreated ? 201 : 200);
    }

    public function observations(Request $request, Activity $activity)
    {
        $teacher = $request->user();
        abort_unless($teacher->isTeacher(), 403);
        abort_if($activity->user_id !== $teacher->id, 403);
        abort_unless($activity->activity_type === Activity::TYPE_CLASSROOM, 422, 'Activity ini bukan activity kelas.');

        $date = Carbon::parse($activity->activity_date)->toDateString();
        $studentActivities = $activity->studentActivities()
            ->with(['owner:id,name,email,school,class_id,student_verification_code', 'owner.schoolClass:id,name,grade,school'])
            ->orderBy('checkin_at')
            ->get();

        return response()->json([
            'teacher_activity' => $this->classroomActivityPayload($activity->loadMissing('schoolClass')),
            'students' => $studentActivities->map(function (Activity $studentActivity) use ($date) {
                $student = $studentActivity->owner;
                $analysis = $student
                    ? $this->burnoutAnalysisService->preview($student, 'daily', $date)
                    : null;

                return [
                    'student' => [
                        'id' => $student?->id,
                        'name' => $student?->name,
                        'email' => $student?->email,
                        'school' => $student?->school,
                        'class' => $student?->schoolClass ? [
                            'id' => $student->schoolClass->id,
                            'name' => $student->schoolClass->name,
                        ] : null,
                    ],
                    'activity' => $studentActivity,
                    'checkin' => [
                        'at' => $studentActivity->checkin_at?->toIso8601String(),
                        'mood' => $studentActivity->checkin_mood,
                        'intensity' => $studentActivity->checkin_intensity,
                        'trigger' => $studentActivity->checkin_trigger,
                    ],
                    'checkout' => [
                        'at' => $studentActivity->checkout_at?->toIso8601String(),
                        'mood' => $studentActivity->checkout_mood,
                        'mood_detected' => $studentActivity->checkout_mood_detected,
                        'fact' => $studentActivity->checkout_fact,
                        'feeling' => $studentActivity->checkout_feeling,
                        'pattern' => $studentActivity->checkout_pattern,
                        'plan' => $studentActivity->checkout_plan,
                        'suggestion' => $studentActivity->checkout_suggestion,
                        'analysis_source' => $studentActivity->checkout_analysis_source,
                    ],
                    'burnout_analysis' => $analysis,
                ];
            })->values(),
        ]);
    }

    private function classroomActivityPayload(Activity $activity): array
    {
        return [
            'id' => $activity->id,
            'title' => $activity->title,
            'category' => $activity->category,
            'activity_type' => $activity->activity_type,
            'activity_kind' => $activity->activity_kind,
            'activity_date' => $activity->activity_date?->toDateString(),
            'start_at' => $activity->start_at?->toIso8601String(),
            'end_at' => $activity->end_at?->toIso8601String(),
            'status' => $activity->status,
            'teacher_checkin_available' => $activity->checkin_at !== null,
            'teacher_checkout_available' => $activity->checkout_at !== null,
            'teacher' => [
                'id' => $activity->owner?->id,
                'name' => $activity->owner?->name,
                'school' => $activity->owner?->school,
            ],
            'class' => $activity->schoolClass ? [
                'id' => $activity->schoolClass->id,
                'name' => $activity->schoolClass->name,
                'school' => $activity->schoolClass->school,
            ] : null,
        ];
    }

    private function studentActivityPayload(Activity $activity): array
    {
        return [
            ...$activity->toArray(),
            'classroom_gate' => [
                'teacher_activity_id' => $activity->teacher_activity_id,
                'teacher_checkin_available' => $activity->teacherActivity?->checkin_at !== null,
                'teacher_checkout_available' => $activity->teacherActivity?->checkout_at !== null,
                'can_student_check_in' => $activity->teacherActivity?->checkin_at !== null,
                'can_student_check_out' => $activity->teacherActivity?->checkout_at !== null,
                'message' => match (true) {
                    $activity->teacherActivity === null => 'Activity guru tidak ditemukan.',
                    $activity->teacherActivity->checkin_at === null => 'Menunggu guru melakukan check-in.',
                    $activity->teacherActivity->checkout_at === null => 'Menunggu guru melakukan check-out.',
                    default => 'Activity guru sudah lengkap.',
                },
            ],
        ];
    }

    private function sameSchool(?string $left, ?string $right): bool
    {
        return filled($left)
            && filled($right)
            && strtolower(trim($left)) === strtolower(trim($right));
    }
}
