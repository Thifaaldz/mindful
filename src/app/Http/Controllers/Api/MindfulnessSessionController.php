<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MindfulnessSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MindfulnessSessionController extends Controller
{
    /**
     * History of the authenticated teacher's sessions.
     */
    public function index(Request $request)
    {
        $sessions = $request->user()->mindfulnessSessions()
            ->orderByDesc('started_at')
            ->paginate(20);

        return response()->json($sessions);
    }

    public function show(Request $request, MindfulnessSession $mindfulness_session)
    {
        abort_if($mindfulness_session->user_id !== $request->user()->id, 403);

        return response()->json($mindfulness_session);
    }

    /**
     * Start a new mindfulness session (US-01).
     */
    public function store(Request $request)
    {
        $session = $request->user()->mindfulnessSessions()->create([
            'started_at' => now(),
            'status' => 'in_progress',
        ]);

        return response()->json($session, 201);
    }

    /**
     * Finish a session and save the logbook entry (US-02, US-03).
     */
    public function update(Request $request, MindfulnessSession $mindfulness_session)
    {
        abort_if($mindfulness_session->user_id !== $request->user()->id, 403);

        $validator = Validator::make($request->all(), [
            'duration_seconds' => ['required', 'integer', 'min:0'],
            'distraction_score' => ['required', 'integer', 'min:0'],
            'calmness_before' => ['required', 'integer', 'min:1', 'max:10'],
            'calmness_after' => ['required', 'integer', 'min:1', 'max:10'],
            'reflection' => ['nullable', 'string'],
            'body_note' => ['nullable', 'string'],
            'helpful_note' => ['nullable', 'string'],
            'logbook_answers' => ['nullable', 'array'],
            'logbook_answers.*' => ['nullable', 'integer', 'min:1', 'max:5'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $mindfulness_session->update([
            ...$validator->validated(),
            'completed_at' => now(),
            'status' => 'completed',
        ]);

        return response()->json($mindfulness_session->fresh());
    }
}
