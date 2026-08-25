<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ClassRoomController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\MindfulnessSessionController;
use App\Http\Controllers\Api\QuestionnaireController;
use App\Http\Controllers\Api\ReminderPreferenceController;
use App\Http\Controllers\Api\StudentObservationController;
use App\Http\Controllers\Api\ToolkitController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/questionnaire/latest', [QuestionnaireController::class, 'latest']);
    Route::post('/questionnaire/responses', [QuestionnaireController::class, 'store']);
    Route::get('/reminder-preference', [ReminderPreferenceController::class, 'show']);
    Route::put('/reminder-preference', [ReminderPreferenceController::class, 'update']);

    // Student's own observation history (US-05 companion view).
    Route::get('/students/{studentId}/observations', [StudentObservationController::class, 'history']);

    Route::middleware('role:teacher')->group(function () {
        Route::apiResource('mindfulness-sessions', MindfulnessSessionController::class)
            ->only(['index', 'store', 'show', 'update']);

        Route::get('/dashboard', [DashboardController::class, 'index']);

        Route::get('/toolkit/tactics', [ToolkitController::class, 'tactics']);
        Route::get('/toolkit/tactics/bookmarked', [ToolkitController::class, 'bookmarked']);
        Route::post('/toolkit/tactics/{tactic}/bookmark', [ToolkitController::class, 'toggleBookmark']);

        Route::get('/classes', [ClassRoomController::class, 'index']);
        Route::get('/classes/{classId}/students', [ClassRoomController::class, 'students']);

        Route::post('/observations', [StudentObservationController::class, 'store']);
        Route::get('/observations/flagged', [StudentObservationController::class, 'flagged']);
    });
});
