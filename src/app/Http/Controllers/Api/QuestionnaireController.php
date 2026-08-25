<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QuestionnaireResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class QuestionnaireController extends Controller
{
    public function latest(Request $request)
    {
        $response = $request->user()
            ->questionnaireResponses()
            ->latest('submitted_at')
            ->first();

        return response()->json(['response' => $response]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'respondent_profile' => ['nullable', 'array'],
            'respondent_profile.age_range' => ['nullable', 'string', 'max:50'],
            'respondent_profile.profession' => ['nullable', 'string', 'max:100'],
            'respondent_profile.teaching_experience' => ['nullable', 'string', 'max:100'],
            'respondent_profile.similar_app_experience' => ['nullable', 'string', 'max:100'],
            'answers' => ['required', 'array', 'min:1'],
            'answers.*' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string', 'max:2000'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $answers = collect($data['answers']);
        $overallScore = (int) round($answers->avg());
        $percentageScore = round(($answers->sum() / ($answers->count() * 5)) * 100, 2);

        $response = QuestionnaireResponse::create([
            'user_id' => $request->user()->id,
            'respondent_profile' => $data['respondent_profile'] ?? null,
            'answers' => $answers->all(),
            'overall_score' => $overallScore,
            'percentage_score' => $percentageScore,
            'comment' => $data['comment'] ?? null,
            'submitted_at' => now(),
        ]);

        return response()->json([
            'message' => 'Kuesioner berhasil disimpan',
            'response' => $response,
        ], 201);
    }
}
