<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Activity;
use App\Models\User;
use App\Services\BurnoutAnalysisService;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Validator;

class ParentDashboardController extends Controller
{
    public function __construct(private readonly BurnoutAnalysisService $burnoutAnalysisService)
    {
    }

    public function index(Request $request)
    {
        $parent = $request->user();
        abort_unless($parent->isParent(), 403);

        $date = Carbon::parse($request->query('date', now()->toDateString()));
        $children = $parent->parentChildren()
            ->with('schoolClass')
            ->orderBy('name')
            ->get();

        return response()->json([
            'date' => $date->toDateString(),
            'children' => $children->map(fn (User $student) => $this->childPayload($student, $date))->values(),
        ]);
    }

    public function linkChild(Request $request)
    {
        $parent = $request->user();
        abort_unless($parent->isParent(), 403);

        $data = Validator::make($request->all(), [
            'student_verification_code' => ['required', 'string', 'max:24'],
            'school' => ['required', 'string', 'max:255'],
        ])->validate();

        $student = User::role('student')
            ->where('student_verification_code', strtoupper(trim($data['student_verification_code'])))
            ->first();

        abort_if(! $student, 422, 'Kode verifikasi siswa tidak ditemukan.');
        abort_if(
            strtolower(trim((string) $student->school)) !== strtolower(trim($data['school'])),
            422,
            'Sekolah anak harus sesuai dengan akun siswa.'
        );

        $parent->parentChildren()->syncWithoutDetaching([
            $student->id => ['verified_at' => now()],
        ]);

        return response()->json([
            'message' => 'Anak berhasil ditautkan.',
            'child' => $this->childPayload($student->loadMissing('schoolClass'), now()),
        ], 201);
    }

    private function childPayload(User $student, Carbon $date): array
    {
        $activities = $student->activities()
            ->with(['teacherActivity.owner:id,name,school', 'schoolClass:id,name,school'])
            ->whereDate('activity_date', $date)
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->orderBy('start_at')
            ->get();

        $analysis = $this->burnoutAnalysisService->analyze($student, 'daily', $date, 'parent_dashboard');

        return [
            'student' => [
                'id' => $student->id,
                'name' => $student->name,
                'school' => $student->school,
                'class' => $student->schoolClass ? [
                    'id' => $student->schoolClass->id,
                    'name' => $student->schoolClass->name,
                ] : null,
            ],
            'analysis' => $analysis,
            'activities' => $activities->map(fn (Activity $activity) => [
                'id' => $activity->id,
                'title' => $activity->title,
                'category' => $activity->category,
                'activity_type' => $activity->activity_type,
                'activity_date' => $activity->activity_date?->toDateString(),
                'start_at' => $activity->start_at?->toIso8601String(),
                'end_at' => $activity->end_at?->toIso8601String(),
                'status' => $activity->status,
                'checkin_mood' => $activity->checkin_mood,
                'checkin_intensity' => $activity->checkin_intensity,
                'checkin_trigger' => $activity->checkin_trigger,
                'checkout_mood' => $activity->checkout_mood,
                'checkout_mood_detected' => $activity->checkout_mood_detected,
                'checkout_fact' => $activity->checkout_fact,
                'checkout_feeling' => $activity->checkout_feeling,
                'checkout_pattern' => $activity->checkout_pattern,
                'checkout_plan' => $activity->checkout_plan,
                'checkout_suggestion' => $activity->checkout_suggestion,
                'checkout_analysis_source' => $activity->checkout_analysis_source,
                'teacher' => $activity->teacherActivity?->owner ? [
                    'id' => $activity->teacherActivity->owner->id,
                    'name' => $activity->teacherActivity->owner->name,
                ] : null,
                'class' => $activity->schoolClass ? [
                    'id' => $activity->schoolClass->id,
                    'name' => $activity->schoolClass->name,
                ] : null,
            ])->values(),
        ];
    }
}
