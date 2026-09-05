<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\SchoolResource\Pages;
use App\Models\School;
use App\Services\SchoolApprovalService;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

class SchoolResource extends Resource
{
    protected static ?string $model = School::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-office-2';

    protected static ?string $navigationGroup = 'Sekolah';

    protected static ?string $navigationLabel = 'Daftar Sekolah';

    protected static ?string $recordTitleAttribute = 'name';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form->schema(static::schoolFormSchema());
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns(static::schoolTableColumns())
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        School::STATUS_PENDING => 'Pending',
                        School::STATUS_APPROVED => 'Approved',
                        School::STATUS_REJECTED => 'Rejected',
                        School::STATUS_SUSPENDED => 'Suspended',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                static::approveAction(),
                static::rejectAction(),
            ])
            ->bulkActions([])
            ->defaultSort('created_at', 'desc');
    }

    public static function getGloballySearchableAttributes(): array
    {
        return ['name', 'npsn', 'contact_email'];
    }

    public static function getGlobalSearchResultDetails(Model $record): array
    {
        return [
            'NPSN' => $record->npsn,
            'Status' => $record->status,
            'Email Kontak' => $record->contact_email,
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $count = School::where('status', School::STATUS_PENDING)->count();

        return $count > 0 ? (string) $count : null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSchools::route('/'),
            'create' => Pages\CreateSchool::route('/create'),
            'edit' => Pages\EditSchool::route('/{record}/edit'),
            'view' => Pages\ViewSchool::route('/{record}'),
        ];
    }

    public static function schoolFormSchema(): array
    {
        return [
            Forms\Components\Section::make('Data Sekolah')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('name')
                        ->label('Nama Sekolah')
                        ->required()
                        ->maxLength(255)
                        ->live(onBlur: true)
                        ->afterStateUpdated(fn ($state, Forms\Set $set, ?School $record) => $set('slug', School::makeUniqueSlug((string) $state, $record?->id))),
                    Forms\Components\TextInput::make('slug')
                        ->required()
                        ->maxLength(255)
                        ->unique(ignoreRecord: true),
                    Forms\Components\TextInput::make('npsn')
                        ->label('NPSN')
                        ->required()
                        ->maxLength(50)
                        ->unique(ignoreRecord: true),
                    Forms\Components\TextInput::make('education_level')
                        ->label('Jenjang')
                        ->required()
                        ->maxLength(80),
                    Forms\Components\TextInput::make('school_status')
                        ->label('Status Sekolah')
                        ->maxLength(80),
                    Forms\Components\Select::make('status')
                        ->options([
                            School::STATUS_PENDING => 'Pending',
                            School::STATUS_APPROVED => 'Approved',
                            School::STATUS_REJECTED => 'Rejected',
                            School::STATUS_SUSPENDED => 'Suspended',
                        ])
                        ->required()
                        ->default(School::STATUS_PENDING),
                    Forms\Components\Textarea::make('address')
                        ->label('Alamat')
                        ->required()
                        ->columnSpanFull(),
                    Forms\Components\TextInput::make('province')
                        ->label('Provinsi')
                        ->required()
                        ->maxLength(120),
                    Forms\Components\TextInput::make('city')
                        ->label('Kota/Kabupaten')
                        ->required()
                        ->maxLength(120),
                    Forms\Components\TextInput::make('district')
                        ->label('Kecamatan')
                        ->maxLength(120),
                ]),
            Forms\Components\Section::make('Kontak Penanggung Jawab')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('contact_name')
                        ->label('Nama Penanggung Jawab')
                        ->required()
                        ->maxLength(255),
                    Forms\Components\TextInput::make('contact_position')
                        ->label('Jabatan')
                        ->required()
                        ->maxLength(120),
                    Forms\Components\TextInput::make('contact_email')
                        ->label('Email Kontak')
                        ->email()
                        ->required()
                        ->maxLength(255),
                    Forms\Components\TextInput::make('contact_phone')
                        ->label('Nomor WhatsApp')
                        ->required()
                        ->maxLength(40),
                    Forms\Components\Textarea::make('rejection_reason')
                        ->label('Alasan Penolakan')
                        ->columnSpanFull(),
                ]),
        ];
    }

    public static function schoolTableColumns(): array
    {
        return [
            Tables\Columns\TextColumn::make('name')
                ->label('Nama Sekolah')
                ->searchable()
                ->sortable(),
            Tables\Columns\TextColumn::make('npsn')
                ->label('NPSN')
                ->searchable(),
            Tables\Columns\TextColumn::make('education_level')
                ->label('Jenjang')
                ->badge(),
            Tables\Columns\TextColumn::make('contact_name')
                ->label('Penanggung Jawab')
                ->searchable(),
            Tables\Columns\TextColumn::make('contact_email')
                ->label('Email Kontak')
                ->searchable()
                ->toggleable(),
            Tables\Columns\TextColumn::make('contact_phone')
                ->label('WhatsApp')
                ->toggleable(),
            Tables\Columns\TextColumn::make('status')
                ->badge()
                ->color(fn (string $state): string => match ($state) {
                    School::STATUS_APPROVED => 'success',
                    School::STATUS_REJECTED, School::STATUS_SUSPENDED => 'danger',
                    default => 'warning',
                }),
            Tables\Columns\TextColumn::make('created_at')
                ->label('Tanggal Pendaftaran')
                ->dateTime('d M Y H:i')
                ->sortable(),
        ];
    }

    public static function approveAction(): Tables\Actions\Action
    {
        return Tables\Actions\Action::make('approve')
            ->label('Approve')
            ->icon('heroicon-o-check-circle')
            ->color('success')
            ->requiresConfirmation()
            ->visible(fn (School $record): bool => $record->status !== School::STATUS_APPROVED)
            ->action(function (School $record): void {
                app(SchoolApprovalService::class)->approve($record, auth()->user());
                Notification::make()
                    ->title('Sekolah disetujui dan akun School Admin dibuat')
                    ->success()
                    ->send();
            });
    }

    public static function rejectAction(): Tables\Actions\Action
    {
        return Tables\Actions\Action::make('reject')
            ->label('Reject')
            ->icon('heroicon-o-x-circle')
            ->color('danger')
            ->form([
                Forms\Components\Textarea::make('reason')
                    ->label('Alasan Penolakan')
                    ->required(),
            ])
            ->visible(fn (School $record): bool => $record->status !== School::STATUS_REJECTED)
            ->action(function (School $record, array $data): void {
                app(SchoolApprovalService::class)->reject($record, auth()->user(), $data['reason']);
                Notification::make()
                    ->title('Pendaftaran sekolah ditolak')
                    ->warning()
                    ->send();
            });
    }
}
