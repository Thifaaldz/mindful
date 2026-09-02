<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Activity;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Carbon;

class ActivityJournalTrendChart extends ChartWidget
{
    protected static ?string $heading = 'Perkembangan Activity Journal (14 hari)';

    protected static ?int $sort = 2;

    protected int|string|array $columnSpan = 'full';

    protected function getData(): array
    {
        $start = today()->subDays(13);
        $end = today();
        $activities = Activity::whereBetween('activity_date', [$start, $end])
            ->get()
            ->groupBy(fn (Activity $activity) => $activity->activity_date->format('Y-m-d'));
        $checkouts = Activity::whereBetween('checkout_at', [$start->copy()->startOfDay(), $end->copy()->endOfDay()])
            ->get()
            ->groupBy(fn (Activity $activity) => $activity->checkout_at->format('Y-m-d'));
        $aiReviews = Activity::whereBetween('checkout_at', [$start->copy()->startOfDay(), $end->copy()->endOfDay()])
            ->whereNotNull('checkout_suggestion')
            ->get()
            ->groupBy(fn (Activity $activity) => $activity->checkout_at->format('Y-m-d'));

        $labels = collect(range(0, 13))
            ->map(fn (int $offset) => $start->copy()->addDays($offset))
            ->values();

        return [
            'datasets' => [
                [
                    'label' => 'Activity dibuat',
                    'data' => $labels->map(fn (Carbon $date) => $activities->get($date->format('Y-m-d'), collect())->count())->values(),
                    'borderColor' => '#24718e',
                    'backgroundColor' => 'rgba(36, 113, 142, 0.12)',
                    'tension' => 0.35,
                ],
                [
                    'label' => 'Check-out selesai',
                    'data' => $labels->map(fn (Carbon $date) => $checkouts->get($date->format('Y-m-d'), collect())->count())->values(),
                    'borderColor' => '#3e735b',
                    'backgroundColor' => 'rgba(62, 115, 91, 0.12)',
                    'tension' => 0.35,
                ],
                [
                    'label' => 'Review AI/Jurnal',
                    'data' => $labels->map(fn (Carbon $date) => $aiReviews->get($date->format('Y-m-d'), collect())->count())->values(),
                    'borderColor' => '#e9be51',
                    'backgroundColor' => 'rgba(233, 190, 81, 0.14)',
                    'tension' => 0.35,
                ],
            ],
            'labels' => $labels->map(fn (Carbon $date) => $date->format('d M'))->values(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
