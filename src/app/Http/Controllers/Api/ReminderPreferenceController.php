<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class ReminderPreferenceController extends Controller
{
    public function show(Request $request)
    {
        return response()->json(['reminder' => $this->format($request->user())]);
    }

    public function update(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'enabled' => ['required', 'boolean'],
            'time' => ['nullable', 'date_format:H:i'],
            'channel' => ['required', Rule::in(['push', 'email'])],
            'timezone' => ['nullable', 'string', 'max:80'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $request->user()->update([
            'reminder_enabled' => $data['enabled'],
            'reminder_time' => $data['enabled'] ? ($data['time'] ?? '07:00') : null,
            'reminder_channel' => $data['channel'],
            'reminder_timezone' => $data['timezone'] ?? config('app.timezone'),
        ]);

        return response()->json(['reminder' => $this->format($request->user()->fresh())]);
    }

    private function format($user): array
    {
        return [
            'enabled' => (bool) $user->reminder_enabled,
            'time' => $user->reminder_time ? substr((string) $user->reminder_time, 0, 5) : '07:00',
            'channel' => $user->reminder_channel ?? 'push',
            'timezone' => $user->reminder_timezone ?? config('app.timezone'),
        ];
    }
}
