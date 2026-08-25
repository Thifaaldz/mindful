<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentObservation extends Model
{
    use HasFactory;

    protected $fillable = [
        'teacher_id',
        'student_id',
        'class_id',
        'observed_on',
        'perasaan',
        'perilaku',
        'tubuh',
        'teman',
        'belajar',
        'status',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'observed_on' => 'date:Y-m-d',
        ];
    }

    /**
     * Overall status is the worst (highest risk) value among the 5 areas.
     */
    public static function computeStatus(array $areas): string
    {
        if (in_array('merah', $areas, true)) {
            return 'merah';
        }

        if (in_array('kuning', $areas, true)) {
            return 'kuning';
        }

        return 'hijau';
    }

    public static function recommendationFor(string $status): string
    {
        return match ($status) {
            'merah' => 'Risiko keselamatan terdeteksi. Rujuk ke layanan bantuan/konseling segera.',
            'kuning' => 'Ada perubahan ringan atau menetap. Dekati siswa dengan tenang dan pantau lebih lanjut.',
            default => 'Kondisi baik. Lanjutkan dukungan rutin.',
        };
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function schoolClass(): BelongsTo
    {
        return $this->belongsTo(SchoolClass::class, 'class_id');
    }
}
