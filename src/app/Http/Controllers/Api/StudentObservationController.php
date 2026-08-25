<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\StudentObservation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class StudentObservationController extends Controller
{
    /**
     * Store or update today's checklist for a student (US-05, FR-04).
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'student_id' => ['required', 'integer', 'exists:users,id'],
            'class_id' => ['required', 'integer', 'exists:classes,id'],
            'observed_on' => ['nullable', 'date'],
            'perasaan' => ['required', Rule::in(['hijau', 'kuning', 'merah'])],
            'perilaku' => ['required', Rule::in(['hijau', 'kuning', 'merah'])],
            'tubuh' => ['required', Rule::in(['hijau', 'kuning', 'merah'])],
            'teman' => ['required', Rule::in(['hijau', 'kuning', 'merah'])],
            'belajar' => ['required', Rule::in(['hijau', 'kuning', 'merah'])],
            'notes' => ['nullable', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        $teacher = $request->user();
        abort_unless($teacher->teachingClasses()->where('classes.id', $data['class_id'])->exists(), 403, 'Anda tidak mengampu kelas ini.');

        $areas = [$data['perasaan'], $data['perilaku'], $data['tubuh'], $data['teman'], $data['belajar']];
        $status = StudentObservation::computeStatus($areas);
        $observedOn = $data['observed_on'] ?? now()->toDateString();

        $observation = StudentObservation::updateOrCreate(
            ['student_id' => $data['student_id'], 'observed_on' => $observedOn],
            [
                'teacher_id' => $teacher->id,
                'class_id' => $data['class_id'],
                'perasaan' => $data['perasaan'],
                'perilaku' => $data['perilaku'],
                'tubuh' => $data['tubuh'],
                'teman' => $data['teman'],
                'belajar' => $data['belajar'],
                'status' => $status,
                'notes' => $data['notes'] ?? null,
            ]
        );

        return response()->json([
            'observation' => $observation,
            'recommendation' => StudentObservation::recommendationFor($status),
        ], 201);
    }

    /**
     * Observation history for a given student.
     */
    public function history(Request $request, int $studentId)
    {
        $user = $request->user();

        if ($user->isStudent()) {
            abort_unless($user->id === $studentId, 403);
        } else {
            abort_unless(
                $user->observationsMade()->where('student_id', $studentId)->exists()
                    || $user->hasRole(['admin', 'super_admin']),
                403
            );
        }

        $history = StudentObservation::where('student_id', $studentId)
            ->orderByDesc('observed_on')
            ->paginate(30);

        return response()->json($history);
    }

    /**
     * Flagged (kuning/merah) observations across the teacher's classes, for alerting.
     */
    public function flagged(Request $request)
    {
        $classIds = $request->user()->teachingClasses()->pluck('classes.id');

        $flagged = StudentObservation::whereIn('class_id', $classIds)
            ->whereIn('status', ['kuning', 'merah'])
            ->with('student:id,name')
            ->orderByDesc('observed_on')
            ->limit(50)
            ->get();

        return response()->json($flagged);
    }
}
