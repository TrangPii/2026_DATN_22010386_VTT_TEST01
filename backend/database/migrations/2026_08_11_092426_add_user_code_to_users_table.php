<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('user_code', 6)
                ->nullable()
                ->unique()
                ->after('id');
        });

        $users = DB::table('users')
            ->orderBy('id')
            ->get(['id', 'role']);

        $nextNumber = 1;

        foreach ($users as $user) {
            if ($user->role === 'ADMIN') {
                $userCode = 'SS0000';
            } else {
                if ($nextNumber > 9999) {
                    throw new RuntimeException(
                        'Đã đạt giới hạn mã người dùng SS9999.'
                    );
                }

                $userCode = sprintf(
                    'SS%04d',
                    $nextNumber
                );

                $nextNumber++;
            }

            DB::table('users')
                ->where('id', $user->id)
                ->update([
                    'user_code' => $userCode,
                ]);
        }

        Schema::table('users', function (Blueprint $table) {
            $table->string('user_code', 6)
                ->nullable(false)
                ->change();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['user_code']);
            $table->dropColumn('user_code');
        });
    }
};