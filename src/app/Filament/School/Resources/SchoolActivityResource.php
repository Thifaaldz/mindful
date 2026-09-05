<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\SchoolActivityResource\Pages;
use App\Models\Activity;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SchoolActivityResource extends Resource
{
    use BelongsToSchoolPanel;

    protected static ?string $model = Activity::class;
    protected static ?string $navigationGroup = 'Monitoring';
    protected static ?string $navigationLabel = 'Activity';
    protected static ?string $modelLabel = 'Activity';
    protected static ?string $pluralModelLabel = 'Activity';
    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        $schoolId = static::schoolId();

        return parent::getEloquentQuery()
            ->with(['owner', 'schoolClass'])
            ->where(function (Builder $query) use ($schoolId) {
                $query->where('school_id', $schoolId)
                    ->orWhereHas('owner', fn (Builder $ownerQuery) => $ownerQuery->where('school_id', $schoolId));
            });
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('title')->label('Activity'),
            Forms\Components\TextInput::make('owner.name')->label('Pengguna'),
            Forms\Components\TextInput::make('status')->label('Status'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')->label('Activity')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('owner.name')->label('Pengguna')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('owner.roles.name')->label('Role')->badge(),
                Tables\Columns\TextColumn::make('schoolClass.name')->label('Kelas'),
                Tables\Columns\BadgeColumn::make('activity_type')->label('Tipe'),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('Status')
                    ->colors([
                        'gray' => Activity::STATUS_PLANNED,
                        'warning' => Activity::STATUS_CHECKED_IN,
                        'success' => Activity::STATUS_COMPLETED,
                        'danger' => Activity::STATUS_CANCELLED,
                    ]),
                Tables\Columns\TextColumn::make('activity_date')->label('Tanggal')->date()->sortable(),
                Tables\Columns\TextColumn::make('start_at')->label('Mulai')->time(),
                Tables\Columns\TextColumn::make('end_at')->label('Selesai')->time(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        Activity::STATUS_PLANNED => 'Planned',
                        Activity::STATUS_CHECKED_IN => 'Checked In',
                        Activity::STATUS_COMPLETED => 'Completed',
                        Activity::STATUS_CANCELLED => 'Cancelled',
                    ]),
                Tables\Filters\SelectFilter::make('activity_type')
                    ->label('Tipe')
                    ->options([
                        Activity::TYPE_PERSONAL => 'Personal',
                        Activity::TYPE_CLASSROOM => 'Classroom',
                        Activity::TYPE_CLASSROOM_STUDENT => 'Classroom Student',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSchoolActivities::route('/'),
            'view' => Pages\ViewSchoolActivity::route('/{record}'),
        ];
    }
}
