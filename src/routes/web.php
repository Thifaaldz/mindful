<?php

use Illuminate\Support\Facades\Route;
use Livewire\Livewire;
use Illuminate\Support\Facades\Response;

/* NOTE: Do Not Remove
/ Livewire asset handling if using sub folder in domain
*/

Livewire::setUpdateRoute(function ($handle) {
    return Route::post(config('app.asset_prefix') . '/livewire/update', $handle);
});

Livewire::setScriptRoute(function ($handle) {
    return Route::get(config('app.asset_prefix') . '/livewire/livewire.js', $handle);
});
/*
/ END
*/
Route::get('/', function () {
    $apkPath = public_path('downloads/mindfuledu.apk');
    $apkSize = file_exists($apkPath)
        ? number_format(filesize($apkPath) / 1024 / 1024, 1) . ' MB'
        : 'APK Android';

    return view('welcome', ['apkSize' => $apkSize]);
});

Route::get('/download/android', function () {
    $apkPath = public_path('downloads/mindfuledu.apk');

    abort_unless(file_exists($apkPath), 404);

    return Response::download($apkPath, 'MindfulEdu.apk', [
        'Content-Type' => 'application/vnd.android.package-archive',
    ]);
})->name('download.android');
