<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProjectController;
use App\Http\Controllers\AssessmentLogController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);

    // Pemohon APIs
    Route::get('/projects', [ProjectController::class, 'index']);
    Route::post('/projects', [ProjectController::class, 'store']);
    Route::get('/projects/{project}', [ProjectController::class, 'show']);
    Route::post('/projects/{project}', [ProjectController::class, 'update']); // Using POST with _method=PUT to support forms with file uploads
    Route::post('/projects/{project}/submit', [ProjectController::class, 'submit']);
    Route::get('/projects/{project}/history', [ProjectController::class, 'history']);

    // Penilai APIs
    Route::get('/assessments', [AssessmentLogController::class, 'index']);
    Route::post('/assessments/{project}/evaluate', [AssessmentLogController::class, 'evaluate']);
});
