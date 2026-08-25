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
            .purpose-grid,
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
                <span class="brand-mark">M</span>
                <span>MindfulEdu</span>
            </a>
            <div class="nav-links">
                <a href="#fitur">Fitur</a>
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
                        Aplikasi pendamping guru dan siswa untuk latihan mindfulness, logbook harian,
                        observasi kondisi siswa, serta toolkit intervensi yang praktis digunakan di sekolah.
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
                        <p>Melihat total sesi, rata-rata ketenangan, distraksi, tren, dan akses cepat ke fitur utama.</p>
                    </article>
                    <article class="feature">
                        <div class="feature-icon">02</div>
                        <h3>Latihan Mindfulness</h3>
                        <p>Sesi panduan 7 langkah dengan audio/guided mode untuk latihan harian yang lebih terarah.</p>
                    </article>
                    <article class="feature">
                        <div class="feature-icon">03</div>
                        <h3>Logbook Harian</h3>
                        <p>Catatan refleksi, tingkat ketenangan, distraksi, dan kuesioner singkat setelah latihan.</p>
                    </article>
                    <article class="feature">
                        <div class="feature-icon">04</div>
                        <h3>Observasi Siswa</h3>
                        <p>Checklist PFA untuk status hijau, kuning, merah lengkap dengan catatan dan rekomendasi.</p>
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
                        <span>Membantu guru membuat rutinitas latihan mindful dan mencatat refleksi dengan terstruktur.</span>
                    </div>
                    <div class="purpose">
                        <strong>Memantau siswa</strong>
                        <span>Memberi alur observasi sederhana agar perubahan kondisi siswa lebih cepat terlihat.</span>
                    </div>
                    <div class="purpose">
                        <strong>Menyiapkan tindak lanjut</strong>
                        <span>Menyediakan rekomendasi tindakan awal dan toolkit intervensi kelas yang mudah dipakai.</span>
                    </div>
                </div>
            </div>
        </section>

        <section id="aplikasi" class="section compact">
            <div class="container showcase">
                <div class="showcase-copy">
                    <div class="section-heading">
                        <h2>Informasi aplikasi</h2>
                        <p>
                            MindfulEdu tersedia sebagai aplikasi Android untuk guru dan siswa, dengan backend web
                            sebagai pusat API, autentikasi, data kelas, observasi, dan konfigurasi sistem.
                        </p>
                    </div>
                    <ul>
                        <li><span class="check">✓</span><span>Role guru dan siswa dengan tampilan yang disesuaikan.</span></li>
                        <li><span class="check">✓</span><span>Data latihan tersimpan dan terhubung ke dashboard.</span></li>
                        <li><span class="check">✓</span><span>Reminder latihan harian melalui preferensi pengingat.</span></li>
                        <li><span class="check">✓</span><span>Toolkit STOP, grounding, dan taktik mindful lecturing.</span></li>
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
