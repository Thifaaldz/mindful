<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
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
        $since = Carbon::now()->subDays(7);

        $totalSessions = $user->mindfulnessSessions()
            ->where('status', 'completed')
            ->count();

        $weekSessions = $user->mindfulnessSessions()
            ->where('status', 'completed')
            ->where('started_at', '>=', $since)
            ->get();

        $trend = $weekSessions
            ->sortBy('started_at')
            ->groupBy(fn ($s) => $s->started_at->format('Y-m-d'))
            ->map(function ($daySessions) {
                return [
                    'calmness_before' => round($daySessions->avg('calmness_before') ?? 0, 1),
                    'calmness_after' => round($daySessions->avg('calmness_after') ?? 0, 1),
                ];
            });

        $badges = $user->badges()->get(['badges.id', 'badges.code', 'badges.name', 'badges.description', 'badges.icon']);

        return response()->json([
            'summary' => [
                'total_sessions' => $totalSessions,
                'sessions_this_week' => $weekSessions->count(),
                'avg_calmness_before' => round($weekSessions->avg('calmness_before') ?? 0, 1),
                'avg_calmness_after' => round($weekSessions->avg('calmness_after') ?? 0, 1),
                'avg_distraction_score' => round($weekSessions->avg('distraction_score') ?? 0, 1),
            ],
            'calmness_trend' => (object) $trend->all(),
            'badges' => $badges,
        ]);
    }
}
