<?php

namespace App\Filament\Admin\Resources\UserResource\RelationManagers;

use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class LoginHistoriesRelationManager extends RelationManager
{
    protected static string $relationship = 'loginHistories';

    protected static ?string $title = 'History Login';

    public function form(Form $form): Form
    {
        return $form;
    }

    public function table(Table $table): Table
    {
        return $table
            ->defaultSort('logged_in_at', 'desc')
            ->columns([
                Tables\Columns\TextColumn::make('logged_in_at')
                    ->label('Tanggal Login')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('location')
                    ->label('Lokasi')
                    ->badge(),
                Tables\Columns\TextColumn::make('device_name')
                    ->label('Handphone')
                    ->placeholder('-')
                    ->searchable(),
                Tables\Columns\TextColumn::make('device_brand')
                    ->label('Merek')
                    ->placeholder('-'),
                Tables\Columns\TextColumn::make('device_model')
                    ->label('Model')
                    ->placeholder('-')
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('device_platform')
                    ->label('Platform')
                    ->badge(),
                Tables\Columns\TextColumn::make('ip_address')
                    ->label('IP')
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\IconColumn::make('revoked_previous_sessions')
                    ->label('Logout Device Lama')
                    ->boolean(),
            ])
            ->filters([])
            ->headerActions([])
            ->actions([])
            ->bulkActions([]);
    }
}
