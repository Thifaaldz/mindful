<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ActivityController;
use App\Http\Controllers\Api\BurnoutAnalysisController;
use App\Http\Controllers\Api\BurnoutSelfReportController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ReminderPreferenceController;
use App\Http\Controllers\Api\ToolkitController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/auth/google', [AuthController::class, 'google']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/me/profile', [AuthController::class, 'updateProfile']);
    Route::get('/reminder-preference', [ReminderPreferenceController::class, 'show']);
    Route::put('/reminder-preference', [ReminderPreferenceController::class, 'update']);
    Route::apiResource('activities', ActivityController::class)
        ->only(['index', 'store', 'show', 'update']);
    Route::post('/activities/{activity}/check-in', [ActivityController::class, 'checkIn']);
    Route::post('/activities/{activity}/check-out', [ActivityController::class, 'checkOut']);
    Route::post('/activities/{activity}/cancel', [ActivityController::class, 'cancel']);
    Route::post('/activities/{activity}/duplicate', [ActivityController::class, 'duplicate']);
    Route::get('/activities/{activity}/ledger', [ActivityController::class, 'ledger']);
    Route::get('/burnout-analyses', [BurnoutAnalysisController::class, 'index']);
    Route::get('/burnout-analyses/overview', [BurnoutAnalysisController::class, 'overview']);
    Route::post('/burnout-analyses', [BurnoutAnalysisController::class, 'store']);
    Route::get('/toolkit/tactics', [ToolkitController::class, 'tactics']);
    Route::get('/toolkit/tactics/bookmarked', [ToolkitController::class, 'bookmarked']);
    Route::post('/toolkit/tactics/{tactic}/bookmark', [ToolkitController::class, 'toggleBookmark']);

    Route::middleware('role:teacher')->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'index']);
        Route::post('/burnout-self-reports', [BurnoutSelfReportController::class, 'store']);

    });
});
