<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BurnoutSelfReportController extends Controller
{
    public function store(Request $request)
    {
        abort_unless($request->user()->isTeacher(), 403);

        $validator = Validator::make($request->all(), [
            'level' => ['required', 'integer', 'min:0', 'max:10'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $report = $request->user()->burnoutSelfReports()->create($validator->validated());

        return response()->json($report, 201);
    }
}
