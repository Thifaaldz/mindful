# Manual Video Admin Sekolah MindfulEdu

Dokumen ini adalah panduan video khusus role Admin Sekolah.

---

## 1. Tujuan Role

Admin Sekolah bertugas mengelola data dalam satu sekolah. Role ini tidak mengelola semua sekolah, tetapi hanya sekolah yang terhubung dengan akunnya.

Admin Sekolah digunakan untuk:

- melihat profil sekolah;
- membuat dan mengelola kelas;
- approve/reject akun guru dan siswa;
- melihat data guru, siswa, parent;
- memantau activity dan analisis sekolah;
- membantu reset password user sekolah jika diperlukan.

---

## 2. Akses

```text
URL Admin Panel : https://mindfulapps.pkmueu.online/admin
Role            : school_admin
Scope data      : sekolah milik admin tersebut
```

Catatan:

- admin sekolah dibuat oleh super admin;
- admin sekolah tidak melihat data sekolah lain.

---

## 3. Alur Video Singkat

```text
Login admin sekolah
  -> buka dashboard sekolah
  -> cek School Profile
  -> buat kelas
  -> approve guru pending
  -> approve siswa pending
  -> cek Teacher Data
  -> cek Student Data
  -> cek Parent Management
  -> cek activity dan analisis sekolah
```

---

## 4. Langkah Detail Rekaman

### 4.1 Login Admin Sekolah

Yang ditampilkan:

- halaman login admin;
- dashboard sekolah setelah login.

Naskah:

```text
Admin sekolah masuk melalui admin panel. Berbeda dari super admin, data yang tampil hanya data dari sekolah yang terhubung dengan akun admin ini.
```

### 4.2 Melihat Profil Sekolah

Yang ditampilkan:

- menu School Profile;
- nama sekolah;
- data wilayah;
- status sekolah.

Naskah:

```text
Pada menu School Profile, admin dapat melihat data sekolahnya. Data ini menjadi dasar relasi guru, siswa, kelas, dan parent dalam satu sekolah.
```

### 4.3 Membuat Kelas

Yang ditampilkan:

- menu Classes;
- tombol create;
- isi nama kelas;
- simpan.

Naskah:

```text
Admin sekolah membuat kelas agar siswa dapat ditempatkan sesuai kelasnya. Kelas ini juga dipakai guru saat membuat activity mengajar dengan target kelas tertentu.
```

Checklist:

```text
[ ] Menu Classes tampil
[ ] Kelas baru bisa dibuat
[ ] Kelas tersimpan di sekolah yang benar
```

### 4.4 Approve Guru

Yang ditampilkan:

- menu Teacher Registrations;
- daftar guru pending;
- detail guru;
- action approve/reject.

Naskah:

```text
Guru yang register dari aplikasi akan masuk ke daftar pending sesuai sekolah yang dipilih. Admin sekolah mengecek data guru lalu menyetujui akun agar guru bisa login.
```

Aturan:

- guru pending sekolah lain tidak muncul di admin ini;
- guru belum bisa login sebelum approved;
- approval tidak mengirim email otomatis.

### 4.5 Approve Siswa

Yang ditampilkan:

- menu Student Registrations;
- daftar siswa pending;
- sekolah dan kelas siswa;
- action approve/reject.

Naskah:

```text
Siswa yang register juga perlu disetujui. Setelah approved, siswa dapat login, membuat activity pribadi, dan join activity kelas dari guru.
```

Aturan:

- siswa pending sekolah lain tidak muncul;
- kelas siswa harus sesuai data sekolah;
- siswa approved dapat dipantau pada Student Data.

### 4.6 Mengelola Data Guru dan Siswa

Menu:

| Menu | Fungsi |
|---|---|
| Teacher Data | Melihat data guru approved |
| Student Data | Melihat data siswa approved |
| Parent Management | Melihat parent yang terhubung dengan siswa sekolah |

Naskah:

```text
Setelah akun disetujui, data guru dan siswa pindah ke menu data utama. Admin sekolah dapat memantau data user, sekolah, kelas, dan membantu reset password jika dibutuhkan.
```

### 4.7 Monitoring Activity dan Analisis

Menu:

| Menu | Fungsi |
|---|---|
| Teacher Activities | Melihat aktivitas guru sekolah |
| Student Activities | Melihat aktivitas siswa sekolah |
| Teacher Burnout Analysis | Melihat analisis guru sekolah |
| Student Burnout Analysis | Melihat analisis siswa sekolah |
| Student Observations | Melihat observasi siswa dari activity kelas |

Naskah:

```text
Admin sekolah dapat memantau activity, jurnal, dan analisis di sekolahnya. Data ini membantu sekolah melihat pola penggunaan sistem tanpa membuka data sekolah lain.
```

---

## 5. Fungsi Penting Yang Harus Disebut

- Admin sekolah hanya mengelola satu sekolah.
- Admin sekolah membuat kelas.
- Admin sekolah approve guru dan siswa.
- Admin sekolah bisa melihat parent yang terhubung dengan siswa sekolah.
- Admin sekolah memantau activity dan analisis sekolah.
- Approval tidak mengirim email otomatis.

---

## 6. Checklist Akhir Video

```text
[ ] Admin sekolah login berhasil
[ ] School Profile tampil
[ ] Kelas bisa dibuat
[ ] Guru pending terlihat sesuai sekolah
[ ] Siswa pending terlihat sesuai sekolah
[ ] Guru/siswa bisa di-approve
[ ] Data approved tampil di menu data
[ ] Activity sekolah terlihat
[ ] Analisis sekolah terlihat
[ ] Logout berhasil
```

