<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\TeacherActivityResource\Pages;
use App\Models\Activity;
use App\Models\School;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class TeacherActivityResource extends Resource
{
    protected static ?string $model = Activity::class;
    protected static ?string $navigationGroup = 'Guru';
    protected static ?string $navigationLabel = 'Activity Guru';
    protected static ?string $modelLabel = 'Activity Guru';
    protected static ?string $pluralModelLabel = 'Activity Guru';
    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?int $navigationSort = 2;

    public static function getEloquentQuery(): Builder
    {
        return Activity::query()
            ->with(['owner', 'schoolModel', 'schoolClass'])
            ->whereHas('owner', fn (Builder $query) => $query->role('teacher'));
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
            Forms\Components\TextInput::make('owner.name')->label(static::ownerLabel()),
            Forms\Components\TextInput::make('schoolModel.name')->label('Sekolah'),
            Forms\Components\TextInput::make('status')->label('Status'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns(static::activityColumns())
            ->filters(static::activityFilters())
            ->defaultSort('activity_date', 'desc')
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    protected static function activityColumns(): array
    {
        return [
            Tables\Columns\TextColumn::make('title')->label('Activity')->searchable()->sortable(),
            Tables\Columns\TextColumn::make('owner.name')->label(static::ownerLabel())->searchable()->sortable(),
            Tables\Columns\TextColumn::make('schoolModel.name')->label('Sekolah')->searchable()->sortable(),
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
        ];
    }

    protected static function ownerLabel(): string
    {
        return 'Guru';
    }

    protected static function activityFilters(): array
    {
        return [
            Tables\Filters\SelectFilter::make('school_id')
                ->label('Sekolah')
                ->options(fn () => School::orderBy('name')->pluck('name', 'id')),
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
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeacherActivities::route('/'),
            'view' => Pages\ViewTeacherActivity::route('/{record}'),
        ];
    }
}
