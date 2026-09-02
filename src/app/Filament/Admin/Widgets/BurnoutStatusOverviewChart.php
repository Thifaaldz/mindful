<?php

namespace App\Filament\Admin\Widgets;

use App\Models\BurnoutAnalysisSnapshot;
use Filament\Widgets\ChartWidget;

class BurnoutStatusOverviewChart extends ChartWidget
{
    protected static ?string $heading = 'Sebaran Status Analisis Burnout (30 hari)';

    protected static ?int $sort = 3;

    protected int|string|array $columnSpan = 1;

    protected function getData(): array
    {
        $snapshots = BurnoutAnalysisSnapshot::where('created_at', '>=', now()->subDays(30))->get();

        return [
            'datasets' => [
                [
                    'label' => 'Jumlah analisis',
                    'data' => [
                        $snapshots->where('category', 'hijau')->count(),
                        $snapshots->where('category', 'kuning')->count(),
                        $snapshots->where('category', 'merah')->count(),
                    ],
                    'backgroundColor' => ['#3e735b', '#e9be51', '#e86c58'],
                    'borderWidth' => 0,
                ],
            ],
            'labels' => ['Hijau', 'Kuning', 'Merah'],
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }
}
