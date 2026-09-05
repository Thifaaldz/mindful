<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\SchoolStudentObservationResource\Pages;
use App\Models\StudentObservation;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SchoolStudentObservationResource extends Resource
{
    use BelongsToSchoolPanel;

    protected static ?string $model = StudentObservation::class;
    protected static ?string $navigationGroup = 'Monitoring';
    protected static ?string $navigationLabel = 'Student Observation';
    protected static ?string $modelLabel = 'Student Observation';
    protected static ?string $pluralModelLabel = 'Student Observation';
    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-check';
    protected static ?int $navigationSort = 3;

    public static function getEloquentQuery(): Builder
    {
        $schoolId = static::schoolId();

        return parent::getEloquentQuery()
            ->with(['teacher', 'student', 'schoolClass'])
            ->where(function (Builder $query) use ($schoolId) {
                $query->whereHas('teacher', fn (Builder $teacherQuery) => $teacherQuery->where('school_id', $schoolId))
                    ->orWhereHas('student', fn (Builder $studentQuery) => $studentQuery->where('school_id', $schoolId))
                    ->orWhereHas('schoolClass', fn (Builder $classQuery) => $classQuery->where('school_id', $schoolId));
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
            Forms\Components\TextInput::make('teacher.name')->label('Guru'),
            Forms\Components\TextInput::make('student.name')->label('Murid'),
            Forms\Components\TextInput::make('status')->label('Status'),
            Forms\Components\Textarea::make('notes')->label('Catatan')->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('observed_on')->label('Tanggal')->date()->sortable(),
                Tables\Columns\TextColumn::make('teacher.name')->label('Guru')->searchable(),
                Tables\Columns\TextColumn::make('student.name')->label('Murid')->searchable(),
                Tables\Columns\TextColumn::make('schoolClass.name')->label('Kelas'),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('Status')
                    ->colors([
                        'success' => 'hijau',
                        'warning' => 'kuning',
                        'danger' => 'merah',
                    ]),
                Tables\Columns\TextColumn::make('updated_at')->label('Update')->dateTime()->sortable(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSchoolStudentObservations::route('/'),
            'view' => Pages\ViewSchoolStudentObservation::route('/{record}'),
        ];
    }
}
