<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProjectController;
use App\Http\Controllers\AssessmentLogController;

use App\Http\Controllers\DashboardController;

use App\Http\Controllers\ExportController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\DocumentTypeController;

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

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::get('/notifications/unread', [NotificationController::class, 'unreadCount']);

    // Pemohon APIs
    Route::get('/projects', [ProjectController::class, 'index']);
    Route::get('/projects/trash/view', [ProjectController::class, 'trash']);
    Route::post('/projects/{project}/restore', [ProjectController::class, 'restore']);
    Route::post('/projects/{project}/assign', [ProjectController::class, 'assignReviewer']);
    Route::post('/projects', [ProjectController::class, 'store']);
    Route::get('/projects/{project}', [ProjectController::class, 'show']);
    Route::post('/projects/{project}', [ProjectController::class, 'update']);
    Route::delete('/projects/{project}', [ProjectController::class, 'destroy']);
    Route::post('/projects/{project}/submit', [ProjectController::class, 'submit']);
    Route::get('/projects/{project}/history', [ProjectController::class, 'history']);

    // Penilai APIs
    Route::get('/assessments', [AssessmentLogController::class, 'index']);
    Route::post('/assessments/{project}/evaluate', [AssessmentLogController::class, 'evaluate']);

    // Admin APIs
    Route::prefix('admin')->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::get('/users/{id}', [UserController::class, 'show']);
        Route::put('/users/{id}', [UserController::class, 'update']);
        Route::delete('/users/{id}', [UserController::class, 'destroy']);
        Route::post('/users/{id}/toggle', [UserController::class, 'toggleStatus']);

        // Document Types API
        Route::get('/document-types', [DocumentTypeController::class, 'index']);
        Route::post('/document-types', [DocumentTypeController::class, 'store']);
        Route::put('/document-types/{id}', [DocumentTypeController::class, 'update']);
        Route::post('/document-types/{id}/toggle', [DocumentTypeController::class, 'toggle']);
        Route::delete('/document-types/{id}', [DocumentTypeController::class, 'destroy']);
    });
});
