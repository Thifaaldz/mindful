<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Activity;
use App\Models\User;
use App\Services\BurnoutAnalysisService;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class DashboardController extends Controller
{
    public function __construct(private readonly BurnoutAnalysisService $analysisService)
    {
    }

    /**
     * Educator's Dashboard summary data (US-04, section 3.3).
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $today = Carbon::today();

        $todayStats = $user->activities()
            ->whereDate('activity_date', $today)
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->selectRaw(
                'COUNT(*) as planned_count,
                SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as completed_count,
                SUM(planned_hours * intensity_factor) as weighted_planned_hours,
                SUM(CASE WHEN status = ? THEN COALESCE(actual_hours, 0) * intensity_factor ELSE 0 END) as weighted_actual_hours,
                SUM(CASE WHEN checkin_at IS NULL THEN 1 ELSE 0 END) as checkin_pending_count',
                [Activity::STATUS_COMPLETED, Activity::STATUS_COMPLETED]
            )
            ->first();
        $monthStart = $today->copy()->startOfMonth();
        $monthEnd = $today->copy()->endOfMonth();
        $activityCalendar = $user->activities()
            ->whereBetween('activity_date', [$monthStart->toDateString(), $monthEnd->toDateString()])
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->selectRaw(
                'activity_date,
                COUNT(*) as planned_count,
                SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as completed_count,
                SUM(CASE WHEN status = ? THEN COALESCE(actual_hours, 0) * intensity_factor ELSE 0 END) as weighted_actual_hours',
                [Activity::STATUS_COMPLETED, Activity::STATUS_COMPLETED]
            )
            ->groupBy('activity_date')
            ->get()
            ->mapWithKeys(function (Activity $activity) {
                $planned = (int) $activity->planned_count;
                $completed = (int) $activity->completed_count;

                return [
                    $activity->activity_date->format('Y-m-d') => [
                        'planned' => $planned,
                        'completed' => $completed,
                        'has_pending' => $completed < $planned,
                        'weighted_actual_hours' => round((float) $activity->weighted_actual_hours, 2),
                    ],
                ];
            });

        $latestAnalysis = $this->latestTodayAnalysis($user);
        $plannedCount = (int) ($todayStats->planned_count ?? 0);
        $completedCount = (int) ($todayStats->completed_count ?? 0);
        $weightedPlannedHours = round((float) ($todayStats->weighted_planned_hours ?? 0), 2);
        $weightedActualHours = round((float) ($todayStats->weighted_actual_hours ?? 0), 2);
        $checkinPendingCount = (int) ($todayStats->checkin_pending_count ?? 0);

        return response()->json([
            'summary' => [
                'planned_activities_today' => $plannedCount,
                'completed_activities_today' => $completedCount,
                'weighted_planned_hours_today' => $weightedPlannedHours,
                'weighted_actual_hours_today' => $weightedActualHours,
            ],
            'activity_summary' => [
                'date' => $today->toDateString(),
                'planned' => $plannedCount,
                'completed' => $completedCount,
                'checkin_pending' => $checkinPendingCount,
                'weighted_planned_hours' => $weightedPlannedHours,
                'weighted_actual_hours' => $weightedActualHours,
            ],
            'activity_calendar' => [
                'month' => $today->format('Y-m'),
                'days' => (object) $activityCalendar->all(),
            ],
            'latest_analysis' => $latestAnalysis,
        ]);
    }

    private function latestTodayAnalysis(User $user): ?array
    {
        $preview = $this->analysisService->preview($user, 'daily', now());
        if ($preview === [] || ($preview['score'] ?? null) === null) {
            return null;
        }

        $recommendation = is_array($preview['recommendation'] ?? null)
            ? $preview['recommendation']
            : [];

        return [
            'id' => null,
            'user_id' => $user->id,
            'source' => 'today_preview',
            'period_type' => $preview['period_type'] ?? 'daily',
            'period_start' => $preview['period_start'] ?? now()->toDateString(),
            'period_end' => $preview['period_end'] ?? now()->toDateString(),
            'data_sufficiency' => $preview['data_sufficiency'] ?? false,
            'activity_count' => $preview['activity_count'] ?? 0,
            'completed_activity_count' => $preview['completed_activity_count'] ?? 0,
            'weighted_actual_hours' => $preview['weighted_actual_hours'] ?? 0,
            'workload_score_raw' => $preview['workload_score_raw'] ?? 0,
            'journal_score' => $preview['journal_score'] ?? 0,
            'final_burnout_risk_score' => $preview['score'],
            'category' => $preview['category'],
            'dominant_factors' => $preview['dominant_factors'] ?? [],
            'recommendation_codes' => $recommendation['codes'] ?? [],
            'recommendation_summary' => $recommendation,
            'payload' => [
                'journal_count' => $preview['journal_count'] ?? 0,
                'journal_reviews' => $preview['journal_reviews'] ?? [],
                'activity_breakdown' => $preview['activity_breakdown'] ?? [],
                'calculation' => $preview['calculation'] ?? null,
                'source' => 'daily_preview',
            ],
            'created_at' => now(),
        ];
    }
}
