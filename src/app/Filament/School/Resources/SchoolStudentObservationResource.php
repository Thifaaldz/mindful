<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\SchoolStudentObservationResource\Pages;
use App\Models\Activity;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SchoolStudentObservationResource extends Resource
{
    use BelongsToSchoolPanel;

    protected static ?string $model = Activity::class;
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
            ->with([
                'owner.schoolClass',
                'schoolClass',
                'teacherActivity.owner',
            ])
            ->where('activity_type', Activity::TYPE_CLASSROOM_STUDENT)
            ->where(function (Builder $query) use ($schoolId) {
                $query->where('school_id', $schoolId)
                    ->orWhereHas('owner', fn (Builder $studentQuery) => $studentQuery->where('school_id', $schoolId))
                    ->orWhereHas('teacherActivity.owner', fn (Builder $teacherQuery) => $teacherQuery->where('school_id', $schoolId))
                    ->orWhereHas('schoolClass', fn (Builder $classQuery) => $classQuery->where('school_id', $schoolId));
            })
            ->latest('activity_date')
            ->latest('checkout_at')
            ->latest('checkin_at');
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }

    public static function canView($record): bool
    {
        return (bool) auth()->user()?->isSchoolAdmin();
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Identitas Kelas')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('teacherActivity.title')
                        ->label('Activity Guru')
                        ->disabled(),
                    Forms\Components\TextInput::make('teacherActivity.owner.name')
                        ->label('Guru')
                        ->disabled(),
                    Forms\Components\TextInput::make('owner.name')
                        ->label('Siswa')
                        ->disabled(),
                    Forms\Components\TextInput::make('owner.email')
                        ->label('Email Siswa')
                        ->disabled(),
                    Forms\Components\TextInput::make('schoolClass.name')
                        ->label('Kelas Activity')
                        ->disabled(),
                    Forms\Components\TextInput::make('activity_date')
                        ->label('Tanggal')
                        ->disabled(),
                ]),
            Forms\Components\Section::make('Check-in Siswa')
                ->columns(3)
                ->schema([
                    Forms\Components\TextInput::make('checkin_at')
                        ->label('Waktu Check-in')
                        ->disabled(),
                    Forms\Components\TextInput::make('checkin_mood')
                        ->label('Mood Check-in')
                        ->disabled(),
                    Forms\Components\TextInput::make('checkin_intensity')
                        ->label('Intensitas')
                        ->disabled(),
                    Forms\Components\Textarea::make('checkin_trigger')
                        ->label('Kenapa mood check-in seperti itu')
                        ->disabled()
                        ->columnSpanFull(),
                ]),
            Forms\Components\Section::make('Check-out dan Journal Siswa')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('checkout_at')
                        ->label('Waktu Check-out')
                        ->disabled(),
                    Forms\Components\TextInput::make('checkout_mood')
                        ->label('Mood Check-out')
                        ->disabled(),
                    Forms\Components\Textarea::make('checkout_fact')
                        ->label('Apa yang terjadi tadi')
                        ->disabled()
                        ->columnSpanFull(),
                    Forms\Components\Textarea::make('checkout_feeling')
                        ->label('Bagaimana perasaan siswa')
                        ->disabled()
                        ->columnSpanFull(),
                    Forms\Components\Textarea::make('checkout_pattern')
                        ->label('Pola yang disadari')
                        ->disabled()
                        ->columnSpanFull(),
                    Forms\Components\Textarea::make('checkout_plan')
                        ->label('Rencana ke depan')
                        ->disabled()
                        ->columnSpanFull(),
                ]),
            Forms\Components\Section::make('Analisa dan Rekomendasi')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('checkout_analysis_source')
                        ->label('Sumber Analisa')
                        ->formatStateUsing(fn (?string $state): string => static::reviewSourceLabel($state))
                        ->disabled(),
                    Forms\Components\TextInput::make('condition_summary')
                        ->label('Kondisi')
                        ->formatStateUsing(fn ($state, Activity $record): string => static::conditionLabel(static::conditionFor($record)))
                        ->disabled(),
                    Forms\Components\TextInput::make('checkout_crisis_flag')
                        ->label('Flag Dukungan Segera')
                        ->formatStateUsing(fn ($state): string => $state ? 'Ya' : 'Tidak')
                        ->disabled(),
                    Forms\Components\Textarea::make('checkout_suggestion')
                        ->label('Analisa dan Saran')
                        ->disabled()
                        ->columnSpanFull(),
                    Forms\Components\Textarea::make('checkout_auto_burnout_tags')
                        ->label('Dimensi Burnout')
                        ->formatStateUsing(fn ($state): string => is_array($state) ? implode(', ', $state) : (string) $state)
                        ->disabled()
                        ->columnSpanFull(),
                    Forms\Components\Textarea::make('checkout_analysis_raw_response')
                        ->label('Detail Analisa')
                        ->formatStateUsing(fn ($state): string => static::prettyJson($state))
                        ->disabled()
                        ->columnSpanFull(),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('activity_date')->label('Tanggal')->date()->sortable(),
                Tables\Columns\TextColumn::make('teacherActivity.title')->label('Activity')->searchable(),
                Tables\Columns\TextColumn::make('teacherActivity.owner.name')->label('Guru')->searchable(),
                Tables\Columns\TextColumn::make('owner.name')->label('Murid')->searchable(),
                Tables\Columns\TextColumn::make('schoolClass.name')->label('Kelas'),
                Tables\Columns\TextColumn::make('checkin_mood')->label('Mood In')->badge(),
                Tables\Columns\TextColumn::make('checkout_mood')->label('Mood Out')->badge(),
                Tables\Columns\TextColumn::make('condition_summary')
                    ->label('Status')
                    ->state(fn (Activity $record): string => static::conditionFor($record))
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => static::conditionLabel($state))
                    ->color(fn (string $state): string => match ($state) {
                        'merah' => 'danger',
                        'kuning' => 'warning',
                        'hijau' => 'success',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('checkout_analysis_source')
                    ->label('Analisa')
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => static::reviewSourceLabel($state))
                    ->color(fn (?string $state): string => static::reviewSourceColor($state)),
                Tables\Columns\TextColumn::make('updated_at')->label('Update')->dateTime()->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('condition_summary')
                    ->label('Status')
                    ->options([
                        'hijau' => 'Hijau',
                        'kuning' => 'Kuning',
                        'merah' => 'Merah',
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        $value = $data['value'] ?? null;

                        return match ($value) {
                            'merah' => $query->where('checkout_crisis_flag', true),
                            'kuning' => $query
                                ->where('checkout_crisis_flag', false)
                                ->where(fn (Builder $query) => $query
                                    ->whereIn('checkout_mood', ['cemas', 'sedih', 'marah', 'lelah'])
                                    ->orWhereIn('checkout_mood_detected', ['cemas', 'sedih', 'marah', 'lelah'])
                                    ->orWhereNotNull('checkout_auto_burnout_tags')),
                            'hijau' => $query
                                ->where('checkout_crisis_flag', false)
                                ->whereNotIn('checkout_mood', ['cemas', 'sedih', 'marah', 'lelah'])
                                ->whereNotIn('checkout_mood_detected', ['cemas', 'sedih', 'marah', 'lelah']),
                            default => $query,
                        };
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    protected static function conditionFor(Activity $activity): string
    {
        if ($activity->checkout_crisis_flag) {
            return 'merah';
        }

        $mood = $activity->checkout_mood_detected ?: $activity->checkout_mood;
        if (in_array($mood, ['cemas', 'sedih', 'marah', 'lelah'], true)) {
            return 'kuning';
        }

        if (filled($activity->checkout_auto_burnout_tags) || filled($activity->checkout_suggestion)) {
            return 'kuning';
        }

        return 'hijau';
    }

    protected static function conditionLabel(string $condition): string
    {
        return match ($condition) {
            'merah' => 'Butuh dukungan',
            'kuning' => 'Perlu perhatian',
            'hijau' => 'Stabil',
            default => 'Belum ada',
        };
    }

    protected static function prettyJson($state): string
    {
        if (! is_string($state) || trim($state) === '') {
            return '';
        }

        $decoded = json_decode($state, true);

        if (! is_array($decoded)) {
            return $state;
        }

        if (isset($decoded['source']) && static::isAiSource($decoded['source'])) {
            $decoded['source'] = 'analisa';
        }

        return json_encode($decoded, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) ?: $state;
    }

    protected static function reviewSourceLabel(?string $source): string
    {
        return static::isAiSource($source) ? 'Analisa' : 'Analisa lokal';
    }

    protected static function reviewSourceColor(?string $source): string
    {
        return static::isAiSource($source) ? 'success' : 'gray';
    }

    protected static function isAiSource(?string $source): bool
    {
        return in_array($source, ['gemini', 'fastapi', 'mock', 'ai'], true);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSchoolStudentObservations::route('/'),
            'view' => Pages\ViewSchoolStudentObservation::route('/{record}'),
        ];
    }
}
