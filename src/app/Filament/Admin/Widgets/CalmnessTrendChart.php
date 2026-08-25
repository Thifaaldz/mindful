<?php

namespace App\Filament\Admin\Widgets;

use App\Models\MindfulnessSession;
use Filament\Widgets\ChartWidget;

class CalmnessTrendChart extends ChartWidget
{
    protected static ?string $heading = 'Tren Rata-rata Skala Ketenangan (30 hari)';

    protected int|string|array $columnSpan = 'full';

    protected function getData(): array
    {
        $sessions = MindfulnessSession::where('status', 'completed')
            ->where('started_at', '>=', now()->subDays(30))
            ->get()
            ->groupBy(fn ($session) => $session->started_at->format('Y-m-d'))
            ->sortKeys();

        return [
            'datasets' => [
                [
                    'label' => 'Sebelum',
                    'data' => $sessions->map(fn ($day) => round($day->avg('calmness_before'), 1))->values(),
                    'borderColor' => '#f59e0b',
                ],
                [
                    'label' => 'Sesudah',
                    'data' => $sessions->map(fn ($day) => round($day->avg('calmness_after'), 1))->values(),
                    'borderColor' => '#22c55e',
                ],
            ],
            'labels' => $sessions->keys(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
