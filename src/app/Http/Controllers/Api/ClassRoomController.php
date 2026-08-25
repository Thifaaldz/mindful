<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ClassRoomController extends Controller
{
    /**
     * Classes assigned to the authenticated teacher.
     */
    public function index(Request $request)
    {
        $classes = $request->user()->teachingClasses()->withCount('students')->get();

        return response()->json($classes);
    }

    /**
     * Students belonging to a class the authenticated teacher teaches.
     */
    public function students(Request $request, int $classId)
    {
        $class = $request->user()->teachingClasses()->findOrFail($classId);

        $students = $class->students()->with(['observationsReceived' => function ($query) {
            $query->latest('observed_on')->latest('id');
        }])->get()->map(function ($student) {
            $latest = $student->observationsReceived->first();

            return [
                'id' => $student->id,
                'name' => $student->name,
                'school' => $student->school,
                'latest_status' => $latest?->status,
                'latest_notes' => $latest?->notes,
                'latest_observed_on' => $latest?->observed_on?->format('Y-m-d'),
            ];
        });

        return response()->json($students);
    }
}
