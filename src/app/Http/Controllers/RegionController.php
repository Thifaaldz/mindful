<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

class RegionController extends Controller
{
    private const BASE_URL = 'https://wilayah.id/api';

    public function provinces(): JsonResponse
    {
        return response()->json([
            'regions' => $this->fetchRegions('provinces.json', 'regions.provinces'),
        ]);
    }

    public function regencies(string $provinceCode): JsonResponse
    {
        abort_unless($this->isValidCode($provinceCode), 404);

        return response()->json([
            'regions' => $this->fetchRegions("regencies/{$provinceCode}.json", "regions.regencies.{$provinceCode}"),
        ]);
    }

    public function districts(string $regencyCode): JsonResponse
    {
        abort_unless($this->isValidCode($regencyCode), 404);

        return response()->json([
            'regions' => $this->fetchRegions("districts/{$regencyCode}.json", "regions.districts.{$regencyCode}"),
        ]);
    }

    private function fetchRegions(string $path, string $cacheKey): array
    {
        $cached = Cache::get($cacheKey);

        if (is_array($cached)) {
            return $cached;
        }

        $response = Http::timeout(10)
            ->retry(2, 200)
            ->acceptJson()
            ->get(self::BASE_URL.'/'.$path);

        if (! $response->successful()) {
            return [];
        }

        $regions = collect($response->json('data', []))
            ->map(fn (array $region) => [
                'code' => trim((string) ($region['code'] ?? '')),
                'name' => trim((string) ($region['name'] ?? '')),
            ])
            ->filter(fn (array $region) => $region['code'] !== '' && $region['name'] !== '')
            ->values()
            ->all();

        if ($regions !== []) {
            Cache::put($cacheKey, $regions, now()->addDays(7));
        }

        return $regions;
    }

    private function isValidCode(string $code): bool
    {
        return preg_match('/^\d{2}(?:\.\d{2})?$/', $code) === 1;
    }
}
