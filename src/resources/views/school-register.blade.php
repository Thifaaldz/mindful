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
        select:disabled {
            background: #f3f6f4;
            color: #8a9891;
            cursor: not-allowed;
        }
        textarea { min-height: 110px; resize: vertical; }
        .error { margin-top: 6px; color: #b42318; font-size: 13px; }
        .hint { margin-top: 6px; color: var(--muted); font-size: 13px; line-height: 1.5; }
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
                <select id="province" name="province" required data-selected="{{ old('province') }}">
                    <option value="">Memuat provinsi...</option>
                </select>
                <div class="hint" id="province_hint">Pilih provinsi terlebih dahulu.</div>
                @error('province') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="city">Kota/Kabupaten *</label>
                <select id="city" name="city" required data-selected="{{ old('city') }}" disabled>
                    <option value="">Pilih provinsi terlebih dahulu</option>
                </select>
                <div class="hint" id="city_hint">Kota/kabupaten akan muncul setelah provinsi dipilih.</div>
                @error('city') <div class="error">{{ $message }}</div> @enderror
            </div>
            <div>
                <label for="district">Kecamatan *</label>
                <select id="district" name="district" required data-selected="{{ old('district') }}" disabled>
                    <option value="">Pilih kota/kabupaten terlebih dahulu</option>
                </select>
                <div class="hint" id="district_hint">Kecamatan akan muncul setelah kota/kabupaten dipilih.</div>
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
<script>
    (() => {
        const endpoints = {
            provinces: @json(route('regions.provinces')),
            regencies: @json(url('/regions/regencies')),
            districts: @json(url('/regions/districts')),
        };

        const selects = {
            province: document.getElementById('province'),
            city: document.getElementById('city'),
            district: document.getElementById('district'),
        };

        const hints = {
            province: document.getElementById('province_hint'),
            city: document.getElementById('city_hint'),
            district: document.getElementById('district_hint'),
        };

        const oldValues = {
            province: selects.province.dataset.selected || '',
            city: selects.city.dataset.selected || '',
            district: selects.district.dataset.selected || '',
        };

        const resetSelect = (select, placeholder, disabled = true) => {
            select.innerHTML = '';
            select.append(new Option(placeholder, ''));
            select.disabled = disabled;
        };

        const setLoading = (select, message) => {
            select.innerHTML = '';
            select.append(new Option(message, ''));
            select.disabled = true;
        };

        const populateSelect = (select, regions, placeholder, selectedValue = '') => {
            select.innerHTML = '';
            select.append(new Option(placeholder, ''));

            regions.forEach((region) => {
                const option = new Option(region.name, region.name);
                option.dataset.code = region.code;

                if (selectedValue && region.name.toLowerCase() === selectedValue.toLowerCase()) {
                    option.selected = true;
                }

                select.append(option);
            });

            select.disabled = regions.length === 0;
        };

        const selectedCode = (select) => select.options[select.selectedIndex]?.dataset.code || '';

        const fetchRegions = async (url) => {
            const response = await fetch(url, {
                headers: {
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                },
            });

            if (!response.ok) {
                throw new Error('Request gagal');
            }

            const payload = await response.json();

            return Array.isArray(payload.regions) ? payload.regions : [];
        };

        const loadProvinces = async () => {
            setLoading(selects.province, 'Memuat provinsi...');
            resetSelect(selects.city, 'Pilih provinsi terlebih dahulu');
            resetSelect(selects.district, 'Pilih kota/kabupaten terlebih dahulu');

            try {
                const provinces = await fetchRegions(endpoints.provinces);
                populateSelect(selects.province, provinces, 'Pilih provinsi', oldValues.province);
                hints.province.textContent = provinces.length
                    ? 'Pilih provinsi sesuai lokasi sekolah.'
                    : 'Data provinsi belum berhasil dimuat.';

                if (selects.province.value) {
                    await loadRegencies(oldValues.city, oldValues.district);
                }
            } catch (error) {
                resetSelect(selects.province, 'Gagal memuat provinsi');
                hints.province.textContent = 'Periksa koneksi server lalu muat ulang halaman.';
            }
        };

        const loadRegencies = async (selectedCity = '', selectedDistrict = '') => {
            const provinceCode = selectedCode(selects.province);
            resetSelect(selects.district, 'Pilih kota/kabupaten terlebih dahulu');

            if (!provinceCode) {
                resetSelect(selects.city, 'Pilih provinsi terlebih dahulu');
                hints.city.textContent = 'Kota/kabupaten akan muncul setelah provinsi dipilih.';
                return;
            }

            setLoading(selects.city, 'Memuat kota/kabupaten...');

            try {
                const regencies = await fetchRegions(`${endpoints.regencies}/${provinceCode}`);
                populateSelect(selects.city, regencies, 'Pilih kota/kabupaten', selectedCity);
                hints.city.textContent = regencies.length
                    ? 'Pilih kota/kabupaten sesuai lokasi sekolah.'
                    : 'Data kota/kabupaten belum berhasil dimuat.';

                if (selects.city.value) {
                    await loadDistricts(selectedDistrict);
                }
            } catch (error) {
                resetSelect(selects.city, 'Gagal memuat kota/kabupaten');
                hints.city.textContent = 'Periksa koneksi server lalu pilih provinsi ulang.';
            }
        };

        const loadDistricts = async (selectedDistrict = '') => {
            const regencyCode = selectedCode(selects.city);

            if (!regencyCode) {
                resetSelect(selects.district, 'Pilih kota/kabupaten terlebih dahulu');
                hints.district.textContent = 'Kecamatan akan muncul setelah kota/kabupaten dipilih.';
                return;
            }

            setLoading(selects.district, 'Memuat kecamatan...');

            try {
                const districts = await fetchRegions(`${endpoints.districts}/${regencyCode}`);
                populateSelect(selects.district, districts, 'Pilih kecamatan', selectedDistrict);
                hints.district.textContent = districts.length
                    ? 'Pilih kecamatan sesuai lokasi sekolah.'
                    : 'Data kecamatan belum berhasil dimuat.';
            } catch (error) {
                resetSelect(selects.district, 'Gagal memuat kecamatan');
                hints.district.textContent = 'Periksa koneksi server lalu pilih kota/kabupaten ulang.';
            }
        };

        selects.province.addEventListener('change', () => loadRegencies());
        selects.city.addEventListener('change', () => loadDistricts());

        loadProvinces();
    })();
</script>
</body>
</html>
