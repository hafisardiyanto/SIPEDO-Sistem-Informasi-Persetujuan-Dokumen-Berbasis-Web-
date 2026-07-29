<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProjectController;
use App\Http\Controllers\AssessmentLogController;

use App\Http\Controllers\DashboardController;

use App\Http\Controllers\ExportController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Export Routes (Public for Demo Token Access)
Route::get('/export/excel', [ExportController::class, 'excel']);
Route::get('/export/pdf', [ExportController::class, 'pdf']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);

    // Aggregation Stats
    Route::get('/dashboard/stats', [DashboardController::class, 'stats']);

    // Pemohon APIs
    Route::get('/projects', [ProjectController::class, 'index']);
    Route::post('/projects', [ProjectController::class, 'store']);
    Route::get('/projects/{project}', [ProjectController::class, 'show']);
    Route::post('/projects/{project}', [ProjectController::class, 'update']);
    Route::post('/projects/{project}/submit', [ProjectController::class, 'submit']);
    Route::get('/projects/{project}/history', [ProjectController::class, 'history']);

    // Penilai APIs
    Route::get('/assessments', [AssessmentLogController::class, 'index']);
    Route::post('/assessments/{project}/evaluate', [AssessmentLogController::class, 'evaluate']);
});
