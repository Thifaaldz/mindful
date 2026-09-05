<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\School;
use App\Models\SchoolClass;
use Illuminate\Http\Request;

class PublicSchoolController extends Controller
{
    public function schools(Request $request)
    {
        $search = trim((string) $request->query('search', ''));

        $schools = School::approved()
            ->when($search !== '', function ($query) use ($search) {
                $query->where(function ($inner) use ($search) {
                    $inner->where('name', 'like', '%'.$search.'%')
                        ->orWhere('npsn', 'like', '%'.$search.'%')
                        ->orWhere('city', 'like', '%'.$search.'%')
                        ->orWhere('province', 'like', '%'.$search.'%');
                });
            })
            ->orderBy('name')
            ->limit(30)
            ->get(['id', 'name', 'npsn', 'city', 'province']);

        return response()->json(['schools' => $schools]);
    }

    public function classes(School $school)
    {
        abort_unless($school->status === School::STATUS_APPROVED, 404);

        $classes = SchoolClass::query()
            ->where('school_id', $school->id)
            ->where('is_active', true)
            ->orderBy('grade')
            ->orderBy('name')
            ->get(['id', 'name', 'grade', 'academic_year']);

        return response()->json([
            'school' => [
                'id' => $school->id,
                'name' => $school->name,
            ],
            'classes' => $classes,
        ]);
    }
}
