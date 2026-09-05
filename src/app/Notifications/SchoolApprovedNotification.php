<?php

namespace App\Notifications;

use App\Models\School;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class SchoolApprovedNotification extends Notification
{
    use Queueable;

    public function __construct(
        private readonly School $school,
        private readonly string $loginEmail,
        private readonly string $temporaryPassword,
    ) {
    }

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Pendaftaran Sekolah MindfulEdu Disetujui')
            ->greeting('Halo '.$this->school->contact_name.',')
            ->line('Pendaftaran sekolah Anda di MindfulEdu telah disetujui.')
            ->line('Sekolah: '.$this->school->name)
            ->line('Akun Administrator Sekolah:')
            ->line('Email / Username: '.$this->loginEmail)
            ->line('Password Sementara: '.$this->temporaryPassword)
            ->action('Masuk Panel Admin Sekolah', url('/school'))
            ->line('Silakan login menggunakan akun tersebut.')
            ->line('Untuk keamanan akun, Anda akan diminta mengganti password setelah login pertama.')
            ->salutation('MindfulEdu');
    }
}
