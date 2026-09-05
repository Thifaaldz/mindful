<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Daftar Sekolah - MindfulEdu</title>
    <style>
        :root {
            color-scheme: light;
            --primary: #315f4c;
            --surface: #f2f8f5;
            --line: #d9e6df;
            --text: #1f2d27;
            --muted: #66766e;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: var(--surface);
            color: var(--text);
        }
        main {
            width: min(960px, calc(100% - 32px));
            margin: 0 auto;
            padding: 42px 0;
        }
        a { color: var(--primary); text-decoration: none; font-weight: 700; }
        .header { margin-bottom: 24px; }
        .eyebrow { color: var(--primary); font-weight: 800; letter-spacing: .08em; text-transform: uppercase; font-size: 12px; }
        h1 { margin: 10px 0 10px; font-size: clamp(32px, 6vw, 54px); line-height: 1.02; }
        p { color: var(--muted); line-height: 1.7; }
        .notice {
            margin: 18px 0;
            padding: 14px 16px;
            border: 1px solid #9dd3b5;
            background: #e9f8ef;
            border-radius: 8px;
            color: #22533d;
            font-weight: 700;
        }
        form {
            background: white;
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 22px;
            box-shadow: 0 18px 48px rgba(49, 95, 76, .08);
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }
        .full { grid-column: 1 / -1; }
        label { display: block; font-weight: 800; margin-bottom: 7px; }
        input, select, textarea {
            width: 100%;
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 12px 13px;
            font: inherit;
            color: var(--text);
            background: #fff;
        }
        textarea { min-height: 110px; resize: vertical; }
        .error { margin-top: 6px; color: #b42318; font-size: 13px; }
        button {
            margin-top: 20px;
            border: 0;
            border-radius: 8px;
            background: var(--primary);
            color: white;
            padding: 13px 18px;
            font-weight: 900;
            font-size: 16px;
            cursor: pointer;
        }
        @media (max-width: 720px) {
            .grid { grid-template-columns: 1fr; }
            main { padding-top: 28px; }
        }
    </style>
</head>
<body>
<main>
    <div class="header">
        <a href="/">MindfulEdu</a>
        <div class="eyebrow" style="margin-top: 24px;">Pendaftaran Sekolah</div>
        <h1>Daftarkan sekolah ke MindfulEdu</h1>
        <p>
            Setelah form dikirim, Super Admin akan memverifikasi data sekolah.
            Akun Admin Sekolah dibuat setelah pendaftaran disetujui.
        </p>
    </div>

    @if (session('status'))
        <div class="notice">{{ session('status') }}</div>
    @endif

    <form method="POST" action="{{ route('schools.register.store') }}">
        @csrf
        <div class="grid">
            <div>
                <label for="name">Nama Sekolah *</label>
                <input id="name" name="name" value="{{ old('name') }}" required>
                @error('name') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="npsn">NPSN *</label>
                <input id="npsn" name="npsn" value="{{ old('npsn') }}" required>
                @error('npsn') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="education_level">Jenjang *</label>
                <select id="education_level" name="education_level" required>
                    @foreach (['SD/MI', 'SMP/MTs', 'SMA/MA', 'SMK', 'Perguruan Tinggi', 'Lainnya'] as $level)
                        <option value="{{ $level }}" @selected(old('education_level') === $level)>{{ $level }}</option>
                    @endforeach
                </select>
                @error('education_level') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="school_status">Status Sekolah</label>
                <select id="school_status" name="school_status">
                    <option value="">Pilih status</option>
                    @foreach (['Negeri', 'Swasta'] as $status)
                        <option value="{{ $status }}" @selected(old('school_status') === $status)>{{ $status }}</option>
                    @endforeach
                </select>
                @error('school_status') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div class="full">
                <label for="address">Alamat *</label>
                <textarea id="address" name="address" required>{{ old('address') }}</textarea>
                @error('address') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="province">Provinsi *</label>
                <input id="province" name="province" value="{{ old('province') }}" required>
                @error('province') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="city">Kota/Kabupaten *</label>
                <input id="city" name="city" value="{{ old('city') }}" required>
                @error('city') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="district">Kecamatan</label>
                <input id="district" name="district" value="{{ old('district') }}">
                @error('district') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="contact_name">Nama Penanggung Jawab *</label>
                <input id="contact_name" name="contact_name" value="{{ old('contact_name') }}" required>
                @error('contact_name') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="contact_position">Jabatan *</label>
                <input id="contact_position" name="contact_position" value="{{ old('contact_position') }}" required>
                @error('contact_position') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="contact_email">Email Kontak *</label>
                <input id="contact_email" name="contact_email" type="email" value="{{ old('contact_email') }}" required>
                @error('contact_email') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="contact_phone">Nomor WhatsApp *</label>
                <input id="contact_phone" name="contact_phone" value="{{ old('contact_phone') }}" required>
                @error('contact_phone') <div class="error">{{ $message }}</div> @enderror
            </div>
        </div>
        <button type="submit">Kirim Pendaftaran</button>
    </form>
</main>
</body>
</html>
