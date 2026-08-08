<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdminWeb
{
    public function handle(
        Request $request,
        Closure $next
    ): Response {
        $user = $request->user();

        if (
            $user->role !== 'ADMIN' ||
            $user->status !== 'ACTIVE'
        ) {
            Auth::logout();

            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect()
                ->route('admin.login')
                ->withErrors([
                    'email' =>
                        'Tài khoản không có quyền quản trị.',
                ]);
        }

        return $next($request);
    }
}