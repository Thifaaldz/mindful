<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="MindfulEdu adalah sistem pendamping mindfulness, logbook, observasi siswa, dan toolkit intervensi untuk lingkungan pendidikan.">
    <title>MindfulEdu - Aplikasi Mindfulness Pendidikan</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600,700,800" rel="stylesheet">
    <style>
        :root {
            --ink: #151713;
            --muted: #5f625d;
            --paper: #fcfcfa;
            --surface: #ffffff;
            --line: #e7e9e4;
            --olive: #3e735b;
            --mint: #eaf4ef;
            --amber: #e9be51;
            --coral: #e86c58;
            --blue: #24718e;
        }

        * {
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            margin: 0;
            background: var(--paper);
            color: var(--ink);
            font-family: "Instrument Sans", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            line-height: 1.55;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        img {
            display: block;
            max-width: 100%;
        }

        .site-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 20;
            background: rgba(252, 252, 250, 0.88);
            border-bottom: 1px solid rgba(231, 233, 228, 0.82);
            backdrop-filter: blur(18px);
        }

        .nav {
            width: min(1120px, calc(100% - 40px));
            min-height: 72px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            gap: 24px;
        }

        .brand {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-weight: 800;
            color: var(--olive);
            font-size: 21px;
        }

        .brand-mark {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            display: grid;
            place-items: center;
            background: var(--surface);
            border: 1px solid var(--line);
            box-shadow: 0 10px 24px rgba(20, 23, 19, 0.08);
        }

        .leaf-mark {
            width: 20px;
            height: 26px;
            border-radius: 100% 0 100% 0;
            background: linear-gradient(145deg, var(--olive), #78b58f);
            transform: rotate(-20deg);
            position: relative;
        }

        .leaf-mark::after {
            content: "";
            position: absolute;
            width: 2px;
            height: 20px;
            top: 4px;
            left: 10px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.72);
            transform: rotate(18deg);
        }

        .nav-links {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 18px;
            color: var(--muted);
            font-size: 14px;
            font-weight: 700;
        }

        .button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            min-height: 48px;
            padding: 0 20px;
            border-radius: 999px;
            border: 1px solid var(--line);
            background: var(--surface);
            font-weight: 800;
            box-shadow: 0 12px 26px rgba(20, 23, 19, 0.08);
        }

        .button.primary {
            background: var(--olive);
            color: #fff;
            border-color: var(--olive);
        }

        .hero {
            min-height: 760px;
            display: grid;
            align-items: end;
            padding: 128px 0 54px;
            background:
                linear-gradient(180deg, rgba(252, 252, 250, 0.15), rgba(252, 252, 250, 0.96)),
                url("/landing/dashboard.jpg") center 36px / min(920px, 92vw) auto no-repeat;
            border-bottom: 1px solid var(--line);
        }

        .hero-inner {
            width: min(1120px, calc(100% - 40px));
            margin: 0 auto;
        }

        .hero-copy {
            max-width: 720px;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 18px;
            color: var(--olive);
            font-size: 13px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }

        .eyebrow::before {
            content: "";
            width: 10px;
            height: 10px;
            border-radius: 999px;
            background: var(--amber);
        }

        h1 {
            margin: 0;
            max-width: 780px;
            font-size: clamp(46px, 8vw, 86px);
            line-height: 0.96;
            letter-spacing: 0;
        }

        .hero p {
            max-width: 680px;
            margin: 22px 0 0;
            color: var(--muted);
            font-size: clamp(17px, 2vw, 21px);
        }

        .hero-actions {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 14px;
            margin-top: 30px;
        }

        .download-meta {
            color: var(--muted);
            font-size: 14px;
            font-weight: 700;
        }

        .section {
            padding: 82px 0;
        }

        .section.compact {
            padding-top: 54px;
        }

        .container {
            width: min(1120px, calc(100% - 40px));
            margin: 0 auto;
        }

        .section-heading {
            max-width: 680px;
            margin-bottom: 32px;
        }

        .section-heading h2 {
            margin: 0;
            font-size: clamp(30px, 4vw, 46px);
            line-height: 1.05;
            letter-spacing: 0;
        }

        .section-heading p {
            margin: 14px 0 0;
            color: var(--muted);
            font-size: 17px;
        }

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
        }

        .feature {
            min-height: 206px;
            padding: 22px;
            border-radius: 14px;
            background: var(--surface);
            border: 1px solid var(--line);
            box-shadow: 0 18px 40px rgba(20, 23, 19, 0.06);
        }

        .feature-icon {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            display: grid;
            place-items: center;
            margin-bottom: 18px;
            color: var(--ink);
            font-weight: 800;
        }

        .feature:nth-child(1) .feature-icon { background: var(--mint); color: var(--olive); }
        .feature:nth-child(2) .feature-icon { background: #e6f2f6; color: var(--blue); }
        .feature:nth-child(3) .feature-icon { background: #fff5d9; color: #9c7220; }
        .feature:nth-child(4) .feature-icon { background: #ffece7; color: var(--coral); }

        .feature h3 {
            margin: 0 0 8px;
            font-size: 18px;
        }

        .feature p {
            margin: 0;
            color: var(--muted);
            font-size: 14px;
        }

        .updates {
            display: grid;
            grid-template-columns: 0.8fr 1.2fr;
            gap: 22px;
            align-items: stretch;
        }

        .release-note {
            padding: 28px;
            border-radius: 16px;
            background: var(--ink);
            color: #fff;
            min-height: 100%;
        }

        .release-note span {
            display: inline-flex;
            align-items: center;
            min-height: 30px;
            padding: 0 12px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.12);
            color: rgba(255, 255, 255, 0.86);
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }

        .release-note h2 {
            margin: 18px 0 12px;
            font-size: clamp(28px, 4vw, 44px);
            line-height: 1.04;
        }

        .release-note p {
            margin: 0;
            color: rgba(255, 255, 255, 0.74);
        }

        .update-list {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 14px;
        }

        .update-item {
            padding: 22px;
            border-radius: 14px;
            background: var(--surface);
            border: 1px solid var(--line);
            box-shadow: 0 18px 40px rgba(20, 23, 19, 0.06);
        }

        .update-item strong {
            display: block;
            margin-bottom: 8px;
            font-size: 17px;
        }

        .update-item p {
            margin: 0;
            color: var(--muted);
            font-size: 14px;
        }

        .showcase {
            display: grid;
            grid-template-columns: 0.85fr 1.15fr;
            gap: 34px;
            align-items: center;
        }

        .showcase-copy ul {
            display: grid;
            gap: 16px;
            margin: 28px 0 0;
            padding: 0;
            list-style: none;
        }

        .showcase-copy li {
            display: grid;
            grid-template-columns: 30px 1fr;
            gap: 12px;
            align-items: start;
            color: var(--muted);
        }

        .check {
            width: 30px;
            height: 30px;
            border-radius: 999px;
            display: grid;
            place-items: center;
            background: var(--mint);
            color: var(--olive);
            font-weight: 900;
        }

        .screen-wall {
            display: grid;
            grid-template-columns: 1fr 0.82fr;
            gap: 16px;
            align-items: start;
        }

        .screen {
            overflow: hidden;
            border-radius: 22px;
            background: var(--surface);
            border: 1px solid var(--line);
            box-shadow: 0 22px 48px rgba(20, 23, 19, 0.12);
        }

        .screen img {
            width: 100%;
            height: auto;
        }

        .screen.small {
            margin-top: 64px;
        }

        .purpose-band {
            background: #f2f7f4;
            border-top: 1px solid var(--line);
            border-bottom: 1px solid var(--line);
        }

        .purpose-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 18px;
        }

        .purpose {
            padding: 26px;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.78);
            border: 1px solid rgba(231, 233, 228, 0.9);
        }

        .purpose strong {
            display: block;
            margin-bottom: 8px;
            font-size: 18px;
        }

        .purpose span {
            color: var(--muted);
            font-size: 14px;
        }

        .role-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
        }

        .role {
            padding: 24px;
            border-radius: 14px;
            background: var(--surface);
            border: 1px solid var(--line);
        }

        .role.teacher { border-top: 5px solid var(--olive); }
        .role.student { border-top: 5px solid var(--blue); }
        .role.parent { border-top: 5px solid var(--amber); }

        .role small {
            display: block;
            margin-bottom: 10px;
            color: var(--muted);
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }

        .role h3 {
            margin: 0 0 8px;
            font-size: 20px;
        }

        .role p {
            margin: 0;
            color: var(--muted);
            font-size: 14px;
        }

        .download {
            display: grid;
            grid-template-columns: 1fr 280px;
            gap: 28px;
            align-items: center;
            padding: 38px;
            border-radius: 18px;
            background: var(--ink);
            color: #fff;
            overflow: hidden;
        }

        .download h2 {
            margin: 0;
            font-size: clamp(30px, 4vw, 48px);
            line-height: 1.05;
        }

        .download p {
            margin: 14px 0 24px;
            color: rgba(255, 255, 255, 0.76);
        }

        .download .button {
            width: fit-content;
            background: #fff;
            color: var(--ink);
            border-color: #fff;
        }

        .avatar-art {
            align-self: end;
        }

        .footer {
            padding: 32px 0 44px;
            color: var(--muted);
            font-size: 14px;
            border-top: 1px solid var(--line);
        }

        .footer-row {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
        }

        @media (max-width: 900px) {
            .nav-links a:not(.button) {
                display: none;
            }

            .hero {
                min-height: 720px;
                background-size: min(720px, 112vw) auto;
                background-position: center 74px;
            }

            .feature-grid,
            .updates,
            .update-list,
            .purpose-grid,
            .role-grid,
            .showcase,
            .download {
                grid-template-columns: 1fr;
            }

            .feature-grid {
                gap: 12px;
            }

            .screen-wall {
                grid-template-columns: 1fr;
            }

            .screen.small {
                margin-top: 0;
            }

            .avatar-art {
                width: 220px;
                margin: 0 auto;
            }
        }

        @media (max-width: 560px) {
            .nav {
                width: min(100% - 28px, 1120px);
            }

            .brand {
                font-size: 18px;
            }

            .nav .button {
                min-height: 40px;
                padding: 0 14px;
                font-size: 13px;
            }

            .hero {
                min-height: 690px;
                padding-top: 112px;
            }

            .hero-inner,
            .container {
                width: min(100% - 32px, 1120px);
            }

            .hero-actions {
                align-items: stretch;
                flex-direction: column;
            }

            .hero-actions .button,
            .download .button {
                width: 100%;
            }

            .section {
                padding: 60px 0;
            }

            .feature {
                min-height: 0;
            }

            .download {
                padding: 28px 22px;
            }
        }
    </style>
</head>
<body>
    <header class="site-header">
        <nav class="nav" aria-label="Navigasi utama">
            <a class="brand" href="#top" aria-label="MindfulEdu">
                <span class="brand-mark" aria-hidden="true"><span class="leaf-mark"></span></span>
                <span>MindfulEdu</span>
            </a>
            <div class="nav-links">
                <a href="#fitur">Fitur</a>
                <a href="#pembaruan">Pembaruan</a>
                <a href="#tujuan">Tujuan</a>
                <a href="#aplikasi">Aplikasi</a>
                <a class="button primary" href="/download/android">Download</a>
            </div>
        </nav>
    </header>

    <main id="top">
        <section class="hero" aria-label="MindfulEdu">
            <div class="hero-inner">
                <div class="hero-copy">
                    <span class="eyebrow">Sistem mindfulness pendidikan</span>
                    <h1>MindfulEdu</h1>
                    <p>
                        Aplikasi pendamping guru, siswa, dan orang tua untuk activity journal,
                        analisis burnout, rekomendasi Gemini AI, serta latihan mindfulness yang praktis
                        digunakan di lingkungan sekolah.
                    </p>
                    <div class="hero-actions">
                        <a class="button primary" href="/download/android">Download APK Android</a>
                        <a class="button" href="#fitur">Lihat Informasi</a>
                        <span class="download-meta">Ukuran file: {{ $apkSize }}</span>
                    </div>
                </div>
            </div>
        </section>

        <section id="fitur" class="section">
            <div class="container">
                <div class="section-heading">
                    <h2>Satu aplikasi untuk kebiasaan mindful di lingkungan belajar.</h2>
                    <p>
                        MindfulEdu dirancang untuk membantu proses latihan, pencatatan, dan pendampingan
                        agar guru punya data yang lebih rapi saat memantau kesejahteraan siswa.
                    </p>
                </div>
                <div class="feature-grid">
                    <article class="feature">
                        <div class="feature-icon">01</div>
                        <h3>Dashboard Ringkas</h3>
                        <p>Guru, siswa, dan orang tua masuk ke tampilan sesuai perannya dengan warna dan alur yang berbeda.</p>
                    </article>
                    <article class="feature">
                        <div class="feature-icon">02</div>
                        <h3>Activity Journal</h3>
                        <p>Catat activity, check-in, check-out, mood, dan refleksi harian sebagai dasar analisis burnout.</p>
                    </article>
                    <article class="feature">
                        <div class="feature-icon">03</div>
                        <h3>Review AI Gemini</h3>
                        <p>Review jurnal menyimpan hasil AI dan memilih teknik mindfulness dari daftar teknik yang tersedia.</p>
                    </article>
                    <article class="feature">
                        <div class="feature-icon">04</div>
                        <h3>Observasi Kelas</h3>
                        <p>Siswa join activity kelas guru, lalu guru melihat hasil check-in, check-out, status, dan rekomendasi.</p>
                    </article>
                </div>
            </div>
        </section>

        <section id="pembaruan" class="section compact">
            <div class="container updates">
                <div class="release-note">
                    <span>Pembaruan terbaru</span>
                    <h2>Analisis, rekomendasi, dan role sudah diselaraskan.</h2>
                    <p>
                        Versi ini fokus pada alur activity journal, review AI, rekomendasi teknik mindfulness,
                        serta pembatas akses guru, siswa, dan orang tua agar pemakaian lebih jelas.
                    </p>
                </div>
                <div class="update-list">
                    <article class="update-item">
                        <strong>Rekomendasi mengikuti review AI</strong>
                        <p>Teknik yang tampil di analisis depan sekarang mengikuti teknik yang dipilih dari review jurnal.</p>
                    </article>
                    <article class="update-item">
                        <strong>Check-in kelas lebih terkontrol</strong>
                        <p>Siswa dapat check-in dan check-out activity kelas sesuai status check-in/check-out guru.</p>
                    </article>
                    <article class="update-item">
                        <strong>History analisis tersimpan</strong>
                        <p>Hasil analisis periode disimpan agar tidak perlu memanggil AI berulang saat data belum berubah.</p>
                    </article>
                    <article class="update-item">
                        <strong>Toolkit mindfulness terhubung</strong>
                        <p>Latihan yang direkomendasikan dapat dibuka dari popup review dan berjalan per langkah dengan TTS.</p>
                    </article>
                </div>
            </div>
        </section>

        <section id="tujuan" class="section purpose-band">
            <div class="container">
                <div class="section-heading">
                    <h2>Tujuan sistem</h2>
                    <p>
                        Sistem ini dibuat sebagai media pendukung praktik mindfulness dan observasi awal,
                        bukan pengganti tenaga profesional kesehatan mental.
                    </p>
                </div>
                <div class="purpose-grid">
                    <div class="purpose">
                        <strong>Mendukung guru</strong>
                        <span>Membantu guru membuat activity, membuka kelas, dan melihat observasi kondisi siswa.</span>
                    </div>
                    <div class="purpose">
                        <strong>Memantau siswa</strong>
                        <span>Memberi alur check-in, check-out, analisis burnout, dan latihan mindfulness yang sesuai.</span>
                    </div>
                    <div class="purpose">
                        <strong>Menghubungkan orang tua</strong>
                        <span>Orang tua memantau perkembangan anak melalui kode verifikasi siswa dan rekomendasi pendampingan.</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="section compact">
            <div class="container">
                <div class="section-heading">
                    <h2>Akses aplikasi dibuat sesuai pengguna.</h2>
                    <p>
                        Setiap akun memiliki dashboard, warna, dan batasan fitur yang berbeda agar alurnya tidak bercampur.
                    </p>
                </div>
                <div class="role-grid">
                    <article class="role teacher">
                        <small>Guru</small>
                        <h3>Kelola kelas dan observasi</h3>
                        <p>Membuat activity mengajar, menentukan kelas, check-in/check-out, dan memantau journal siswa.</p>
                    </article>
                    <article class="role student">
                        <small>Siswa</small>
                        <h3>Ikut kelas dan refleksi diri</h3>
                        <p>Join activity dari guru, mengisi check-in/check-out, serta melihat analisis burnout pribadi.</p>
                    </article>
                    <article class="role parent">
                        <small>Orang tua</small>
                        <h3>Monitoring perkembangan anak</h3>
                        <p>Melihat aktivitas, mood, hasil analisis, dan rekomendasi mindfulness untuk mendampingi anak.</p>
                    </article>
                </div>
            </div>
        </section>

        <section id="aplikasi" class="section compact">
            <div class="container showcase">
                <div class="showcase-copy">
                    <div class="section-heading">
                        <h2>Informasi aplikasi</h2>
                        <p>
                            MindfulEdu tersedia sebagai aplikasi Android untuk guru, siswa, dan orang tua, dengan backend web
                            sebagai pusat API, autentikasi, data kelas, Gemini AI, observasi, dan konfigurasi sistem.
                        </p>
                    </div>
                    <ul>
                        <li><span class="check">✓</span><span>Login guru, siswa, dan orang tua dengan akses yang dipisahkan.</span></li>
                        <li><span class="check">✓</span><span>Activity kelas mendukung filter kelas atau seluruh siswa satu sekolah.</span></li>
                        <li><span class="check">✓</span><span>Review AI menampilkan status hijau, kuning, merah, dan saran teknik.</span></li>
                        <li><span class="check">✓</span><span>Toolkit STOP, grounding, body scan, breathing, dan teknik mindful lainnya.</span></li>
                    </ul>
                </div>
                <div class="screen-wall" aria-label="Tampilan aplikasi MindfulEdu">
                    <figure class="screen">
                        <img src="/landing/observasi.jpg" alt="Tampilan observasi siswa MindfulEdu">
                    </figure>
                    <figure class="screen small">
                        <img src="/landing/logbook.jpg" alt="Tampilan logbook harian MindfulEdu">
                    </figure>
                </div>
            </div>
        </section>

        <section class="section">
            <div class="container">
                <div class="download">
                    <div>
                        <h2>Download aplikasi MindfulEdu untuk Android.</h2>
                        <p>
                            Unduh APK terbaru yang sudah dibuild dari project ini. Setelah terpasang,
                            pastikan perangkat berada di jaringan yang bisa mengakses backend MindfulEdu.
                        </p>
                        <a class="button" href="/download/android">Download APK Android</a>
                    </div>
                    <img class="avatar-art" src="/landing/avatar_home.png" alt="Avatar mindfulness MindfulEdu">
                </div>
            </div>
        </section>
    </main>

    <footer class="footer">
        <div class="container footer-row">
            <span>MindfulEdu 2026</span>
            <span>Mindfulness, logbook, observasi siswa, dan toolkit intervensi.</span>
        </div>
    </footer>
</body>
</html>
