<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Activity;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class DashboardController extends Controller
{
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

        $latestAnalysis = $user->burnoutAnalysisSnapshots()
            ->select([
                'id',
                'user_id',
                'source',
                'period_type',
                'period_start',
                'period_end',
                'data_sufficiency',
                'journal_score',
                'final_burnout_risk_score',
                'category',
                'recommendation_summary',
                'created_at',
            ])
            ->latest()
            ->first();
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
}
