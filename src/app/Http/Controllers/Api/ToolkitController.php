<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MindfulTactic;
use Illuminate\Http\Request;

class ToolkitController extends Controller
{
    /**
     * List of "Taktik Mindful Lecturing" tips with bookmark state for the user.
     */
    public function tactics(Request $request)
    {
        $bookmarkedIds = $request->user()->bookmarkedTactics()->pluck('mindful_tactics.id');

        $tactics = MindfulTactic::orderBy('sort_order')->get()->map(function ($tactic) use ($bookmarkedIds) {
            return [
                'id' => $tactic->id,
                'title' => $tactic->title,
                'category' => $tactic->category,
                'description' => $tactic->description,
                'knowledge' => $tactic->knowledge,
                'duration_minutes' => $tactic->duration_minutes,
                'steps' => $tactic->steps ?? [],
                'cues' => $tactic->cues ?? [],
                'best_for' => $tactic->best_for ?? [],
                'is_bookmarked' => $bookmarkedIds->contains($tactic->id),
            ];
        });

        return response()->json($tactics);
    }

    public function toggleBookmark(Request $request, MindfulTactic $tactic)
    {
        $user = $request->user();
        $existing = $user->bookmarkedTactics()->where('mindful_tactic_id', $tactic->id)->exists();

        if ($existing) {
            $user->bookmarkedTactics()->detach($tactic->id);
        } else {
            $user->bookmarkedTactics()->attach($tactic->id);
        }

        return response()->json(['is_bookmarked' => ! $existing]);
    }

    public function bookmarked(Request $request)
    {
        return response()->json($request->user()->bookmarkedTactics()->get());
    }
}
