<?php

namespace App\Http\Controllers;

use App\Models\School;
use Illuminate\Http\Request;

class SchoolRegistrationController extends Controller
{
    public function create()
    {
        return view('school-register');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'npsn' => ['required', 'string', 'max:50', 'unique:schools,npsn'],
            'education_level' => ['required', 'string', 'max:80'],
            'school_status' => ['nullable', 'string', 'max:80'],
            'address' => ['required', 'string'],
            'province' => ['required', 'string', 'max:120'],
            'city' => ['required', 'string', 'max:120'],
            'district' => ['nullable', 'string', 'max:120'],
            'contact_name' => ['required', 'string', 'max:255'],
            'contact_position' => ['required', 'string', 'max:120'],
            'contact_email' => ['required', 'email', 'max:255'],
            'contact_phone' => ['required', 'string', 'max:40'],
        ]);

        $data['slug'] = School::makeUniqueSlug($data['name']);
        $data['status'] = School::STATUS_PENDING;

        School::create($data);

        return redirect()
            ->route('schools.register.create')
            ->with('status', 'Pendaftaran sekolah berhasil dikirim. Super Admin akan melakukan verifikasi terlebih dahulu.');
    }
}
