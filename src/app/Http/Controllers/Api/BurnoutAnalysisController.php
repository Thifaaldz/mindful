<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\BurnoutAnalysisService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class BurnoutAnalysisController extends Controller
{
    public function __construct(private readonly BurnoutAnalysisService $analysisService)
    {
    }

    public function index(Request $request)
    {
        return response()->json(
            $request->user()->burnoutAnalysisSnapshots()
                ->select([
                    'id',
                    'user_id',
                    'source',
                    'period_type',
                    'period_start',
                    'period_end',
                    'data_sufficiency',
                    'activity_count',
                    'completed_activity_count',
                    'weighted_planned_hours',
                    'weighted_actual_hours',
                    'workload_score_raw',
                    'workload_variance_pct',
                    'journal_score',
                    'final_burnout_risk_score',
                    'category',
                    'dominant_factors',
                    'recommendation_codes',
                    'recommendation_summary',
                    'model_version',
                    'scoring_version',
                    'threshold_version',
                    'payload',
                    'created_at',
                ])
                ->latest()
                ->simplePaginate(24)
        );
    }

    public function overview(Request $request)
    {
        return response()->json($this->analysisService->overview($request->user()));
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'period_type' => ['required', Rule::in(['daily', 'weekly', 'monthly'])],
            'date' => ['nullable', 'date'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $snapshot = $this->analysisService->analyze(
            $request->user(),
            $data['period_type'],
            $data['date'] ?? null,
            'manual'
        );

        return response()->json($snapshot, 201);
    }
}
