<?php

namespace App\Notifications;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class UserApprovedNotification extends Notification
{
    use Queueable;

    public function __construct(
        private readonly User $user,
    ) {
    }

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Akun MindfulEdu Anda Disetujui')
            ->greeting('Halo '.$this->user->name.',')
            ->line('Akun MindfulEdu Anda sudah disetujui oleh Admin Sekolah.')
            ->line('Email login: '.$this->user->email)
            ->line('Gunakan password yang Anda buat saat registrasi untuk masuk ke aplikasi.')
            ->line('Setelah login, Anda bisa memperbarui password dari menu Profile jika diperlukan.')
            ->salutation('MindfulEdu');
    }
}
