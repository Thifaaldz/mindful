<?php

namespace App\Filament\School\Resources\Concerns;

use App\Models\User;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Tables;

trait HandlesSchoolUserApproval
{
    protected static function approveUserAction(): Tables\Actions\Action
    {
        return Tables\Actions\Action::make('approve')
            ->label('Approve')
            ->icon('heroicon-m-check-circle')
            ->color('success')
            ->visible(fn (User $record): bool => $record->approval_status === 'pending')
            ->requiresConfirmation()
            ->action(function (User $record): void {
                if (auth()->user()?->isSchoolAdmin() && (int) $record->school_id !== (int) auth()->user()?->school_id) {
                    abort(403, 'Akun ini bukan bagian dari sekolah Anda.');
                }

                $record->forceFill([
                    'approval_status' => 'approved',
                    'approved_at' => now(),
                    'approved_by' => auth()->id(),
                    'rejected_at' => null,
                    'rejected_by' => null,
                    'rejection_reason' => null,
                ])->save();

                Notification::make()
                    ->title('Akun berhasil di-approve')
                    ->body('Tidak ada email otomatis yang dikirim. Silakan kabarkan approval secara pribadi.')
                    ->success()
                    ->send();
            });
    }

    protected static function rejectUserAction(): Tables\Actions\Action
    {
        return Tables\Actions\Action::make('reject')
            ->label('Reject')
            ->icon('heroicon-m-x-circle')
            ->color('danger')
            ->visible(fn (User $record): bool => $record->approval_status === 'pending')
            ->form([
                Forms\Components\Textarea::make('rejection_reason')
                    ->label('Alasan penolakan')
                    ->required()
                    ->maxLength(1000),
            ])
            ->action(function (User $record, array $data): void {
                if (auth()->user()?->isSchoolAdmin() && (int) $record->school_id !== (int) auth()->user()?->school_id) {
                    abort(403, 'Akun ini bukan bagian dari sekolah Anda.');
                }

                $record->forceFill([
                    'approval_status' => 'rejected',
                    'rejected_at' => now(),
                    'rejected_by' => auth()->id(),
                    'rejection_reason' => $data['rejection_reason'],
                ])->save();

                Notification::make()
                    ->title('Akun berhasil ditolak')
                    ->success()
                    ->send();
            });
    }
}
