<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Notification;

class NotificationController extends Controller
{
    public function index()
    {
        $notifications = Auth::user()->notifications()->latest()->paginate(10);
        return response()->json(['data' => $notifications]);
    }

    public function markAsRead($id)
    {
        $notification = Auth::user()->notifications()->findOrFail($id);
        $notification->update(['read_at' => now()]);

        return response()->json(['message' => 'Notification marked as read', 'data' => $notification]);
    }

    public function unreadCount()
    {
        $count = Auth::user()->notifications()->whereNull('read_at')->count();
        return response()->json(['data' => ['unread_count' => $count]]);
    }
}
