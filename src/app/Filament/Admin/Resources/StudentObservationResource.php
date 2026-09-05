<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\StudentObservationResource\Pages;
use App\Models\StudentObservation;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class StudentObservationResource extends Resource
{
    protected static ?string $model = StudentObservation::class;

    protected static ?string $navigationIcon = 'heroicon-o-face-smile';

    protected static ?string $navigationGroup = 'Monitoring';

    protected static ?string $recordTitleAttribute = 'student.name';

    protected static array $statusColors = [
        'hijau' => 'success',
        'kuning' => 'warning',
        'merah' => 'danger',
    ];

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::whereIn('status', ['kuning', 'merah'])->count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'danger';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('teacher_id')
                    ->relationship('teacher', 'name')
                    ->required(),
                Forms\Components\Select::make('student_id')
                    ->relationship('student', 'name')
                    ->required(),
                Forms\Components\TextInput::make('class_id')
                    ->required()
                    ->numeric(),
                Forms\Components\DatePicker::make('observed_on')
                    ->required(),
                Forms\Components\Select::make('perasaan')
                    ->options(['hijau' => 'Hijau', 'kuning' => 'Kuning', 'merah' => 'Merah'])
                    ->required(),
                Forms\Components\Select::make('perilaku')
                    ->options(['hijau' => 'Hijau', 'kuning' => 'Kuning', 'merah' => 'Merah'])
                    ->required(),
                Forms\Components\Select::make('tubuh')
                    ->options(['hijau' => 'Hijau', 'kuning' => 'Kuning', 'merah' => 'Merah'])
                    ->required(),
                Forms\Components\Select::make('teman')
                    ->options(['hijau' => 'Hijau', 'kuning' => 'Kuning', 'merah' => 'Merah'])
                    ->required(),
                Forms\Components\Select::make('belajar')
                    ->options(['hijau' => 'Hijau', 'kuning' => 'Kuning', 'merah' => 'Merah'])
                    ->required(),
                Forms\Components\Select::make('status')
                    ->options(['hijau' => 'Hijau', 'kuning' => 'Kuning', 'merah' => 'Merah'])
                    ->required(),
                Forms\Components\Textarea::make('notes')
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('teacher.name')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('student.name')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('class_id')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('observed_on')
                    ->date()
                    ->sortable(),
                Tables\Columns\TextColumn::make('perasaan')
                    ->badge()->colors(static::$statusColors),
                Tables\Columns\TextColumn::make('perilaku')
                    ->badge()->colors(static::$statusColors),
                Tables\Columns\TextColumn::make('tubuh')
                    ->badge()->colors(static::$statusColors),
                Tables\Columns\TextColumn::make('teman')
                    ->badge()->colors(static::$statusColors),
                Tables\Columns\TextColumn::make('belajar')
                    ->badge()->colors(static::$statusColors),
                Tables\Columns\TextColumn::make('status')
                    ->badge()->colors(static::$statusColors),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('observed_on', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(['hijau' => 'Hijau', 'kuning' => 'Kuning', 'merah' => 'Merah']),
                Tables\Filters\SelectFilter::make('class_id')
                    ->relationship('schoolClass', 'name')
                    ->label('Kelas'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStudentObservations::route('/'),
            'view' => Pages\ViewStudentObservation::route('/{record}'),
            'edit' => Pages\EditStudentObservation::route('/{record}/edit'),
        ];
    }
}
