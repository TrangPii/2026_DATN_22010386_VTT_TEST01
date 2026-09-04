<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class SystemNotification extends Notification
{
    use Queueable;

    public function __construct(
        private readonly string $type,
        private readonly string $title,
        private readonly string $message,
        private readonly string $audience,
        private readonly ?string $target = null,
        private readonly ?int $bookingId = null,
        private readonly ?string $bookingCode = null,
        private readonly ?string $status = null,
    ) {
    }

    public function via(
        object $notifiable
    ): array {
        return [
            'database',
        ];
    }

    public function toArray(
        object $notifiable
    ): array {
        return [
            'type' =>
                $this->type,

            'title' =>
                $this->title,

            'message' =>
                $this->message,

            'audience' =>
                $this->audience,

            'target' =>
                $this->target,

            'booking_id' =>
                $this->bookingId,

            'booking_code' =>
                $this->bookingCode,

            'status' =>
                $this->status,
        ];
    }
}