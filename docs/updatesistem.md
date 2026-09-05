# UPDATE MINDFULEDU — MULTI SCHOOL FILAMENT

Saya memiliki project MindfulEdu yang SUDAH BERJALAN.

Project ini sudah memiliki:

* Laravel backend
* Laravel Filament Super Admin
* Super Admin existing
* Flutter mobile application
* Role Teacher/Guru
* Role Student/Siswa
* Role Parent/Orang Tua
* Activity
* Classroom Activity
* Check-in
* Check-out
* Journal
* Burnout Analysis
* Mindfulness Toolkit
* Parent Monitoring
* FastAPI/Python analysis service
* Database existing

## ATURAN PALING PENTING

JANGAN melakukan rewrite project.

JANGAN membuat Super Admin baru.

JANGAN mengubah authentication Super Admin existing.

JANGAN menghapus atau merombak fitur existing yang tidak berhubungan dengan fitur sekolah.

JANGAN mengubah FastAPI jika tidak diperlukan.

JANGAN mengubah flow burnout, mindfulness, journal, check-in, check-out, atau activity kecuali bagian relasi sekolah dan target kelas yang memang diperlukan.

Implementasi harus bersifat:

```text
ADD FEATURE
+
EXTEND EXISTING FEATURE
+
MINIMAL REFACTOR
```

bukan:

```text
REBUILD SYSTEM
```

---

# 1. TARGET PERUBAHAN

Saya hanya ingin menambahkan konsep:

```text
School Registration
        ↓
Super Admin Verification
        ↓
School Admin Account
        ↓
Filament School Admin Panel
        ↓
School manages Classes
        ↓
Teacher/Student related to School
```

Super Admin existing tetap memiliki akses global.

Tambahkan School Admin yang hanya memiliki akses ke sekolahnya sendiri.

---

# 2. FILAMENT EXISTING

Saat ini Super Admin Filament SUDAH ADA.

JANGAN membuat ulang:

```text
/admin
```

JANGAN mengganti authentication `/admin`.

JANGAN mengganti Super Admin account existing.

Yang perlu dilakukan hanya:

```text
rapikan navigation
+
tambahkan School Management
+
tambahkan data sekolah
```

---

# 3. NAVIGATION SUPER ADMIN

Rapikan resource yang sudah ada ke dalam kategori/navigation group.

Contoh:

```text
Dashboard

Sekolah
├── Pendaftaran Sekolah
├── Daftar Sekolah
└── Admin Sekolah

Pengguna
├── Guru
├── Siswa / Murid
└── Orang Tua

Akademik
├── Kelas
└── Activity

Monitoring
├── Burnout Analysis
├── Student Observation
├── Mindfulness Session
└── Login History

Mindfulness
└── Mindfulness Techniques
```

CATATAN:

Resource existing jangan dibuat ulang jika sudah tersedia.

Contoh:

Jika sudah terdapat:

```text
UserResource
ActivityResource
BurnoutAnalysisResource
MindfulTacticResource
```

maka gunakan/refactor resource existing.

Tujuan perubahan navigation hanya agar Super Admin lebih mudah melihat kategori:

```text
Sekolah
Guru
Murid
Orang Tua
Kelas
Activity
Monitoring
```

Super Admin tetap dapat melihat seluruh data dari seluruh sekolah.

---

# 4. SCHOOL REGISTRATION

Tambahkan halaman public pada website MindfulEdu:

```text
/register-school
```

atau route yang sesuai struktur project existing.

Form:

```text
Nama Sekolah *
NPSN *
Jenjang *
Status Sekolah
Alamat *
Provinsi *
Kota/Kabupaten *
Kecamatan

Nama Penanggung Jawab *
Jabatan *
Email Kontak *
Nomor WhatsApp *
```

Email Kontak adalah email nyata yang dapat menerima email.

Contoh:

```text
mindfuledu.sman1@gmail.com
```

Setelah submit:

```text
status = pending
```

JANGAN langsung membuat School Admin.

---

# 5. SCHOOL TABLE

Periksa dahulu apakah model/table School sudah tersedia.

Jika sudah ada:

```text
EXTEND EXISTING TABLE
```

JANGAN membuat tabel School kedua.

Data minimal:

```text
id
name
slug
npsn
education_level
school_status
address
province
city
district

contact_name
contact_position
contact_email
contact_phone

status

verified_at
verified_by

rejected_at
rejected_by
rejection_reason

created_at
updated_at
```

School status:

```text
pending
approved
rejected
suspended
```

---

# 6. SUPER ADMIN — PENDAFTARAN SEKOLAH

Tambahkan ke Super Admin existing:

```text
Sekolah
    └── Pendaftaran Sekolah
```

Tampilkan:

```text
Nama Sekolah
NPSN
Jenjang
Penanggung Jawab
Email Kontak
WhatsApp
Tanggal Pendaftaran
Status
```

Actions:

```text
Detail
Approve
Reject
```

---

# 7. APPROVE SCHOOL

Ketika Super Admin existing menekan:

```text
Approve
```

jalankan:

```text
School Pending
        ↓
Super Admin Approve
        ↓
status = approved
        ↓
verified_at = now()
        ↓
verified_by = Super Admin Existing
        ↓
Generate School Admin Account
```

Gunakan database transaction jika sesuai.

---

# 8. SCHOOL ADMIN LOGIN EMAIL

UNTUK SAAT INI saya ingin username/email login School Admin dibuat otomatis menggunakan format:

```text
admin@namasekolah.test
```

Contoh:

```text
Nama Sekolah:
SMAN 1 Tangerang

slug:
sman1tangerang

School Admin Login:
admin@sman1tangerang.test
```

Contoh lain:

```text
SMP Negeri 5 Jakarta

admin@smpnegeri5jakarta.test
```

Buat slug yang aman:

```text
lowercase
tanpa spasi
tanpa simbol yang tidak diperlukan
```

Pastikan email login tersebut unique.

Jika terjadi duplicate slug gunakan suffix.

Contoh:

```text
admin@sman1tangerang.test

jika sudah ada:

admin@sman1tangerang2.test
```

---

# 9. PENTING — LOGIN EMAIL DAN EMAIL PENGIRIMAN BERBEDA

Email:

```text
admin@namasekolah.test
```

HANYA digunakan sebagai:

```text
username / email login School Admin
```

JANGAN mencoba mengirim email Resend ke domain `.test`.

Karena `.test` digunakan untuk development dan bukan email public yang dapat menerima email internet.

Gunakan:

```text
schools.contact_email
```

sebagai tujuan email Resend.

Contoh:

```text
LOGIN ADMIN

admin@sman1tangerang.test
```

tetapi email credential dikirim ke:

```text
mindfuledu.sman1@gmail.com
```

yang berasal dari:

```text
schools.contact_email
```

---

# 10. SCHOOL ADMIN ACCOUNT

Setelah sekolah approved:

Buat account School Admin.

Contoh:

```text
name:
Admin SMAN 1 Tangerang

email:
admin@sman1tangerang.test

school_id:
5

role:
school_admin
```

Generate temporary password.

Contoh Laravel:

```php
$tempPassword = Str::password(12);
```

Database hanya menyimpan:

```php
Hash::make($tempPassword)
```

JANGAN menyimpan temporary password plain text.

Tambahkan:

```text
must_change_password = true
```

jika field belum tersedia.

---

# 11. RESEND

Gunakan Resend untuk email transactional.

Resend digunakan untuk mengirim informasi akun School Admin ke:

```text
schools.contact_email
```

BUKAN:

```text
admin@namasekolah.test
```

Flow:

```text
Super Admin Approve
        ↓
School Admin Created
        ↓
Temporary Password Generated
        ↓
Laravel Notification
        ↓
Resend
        ↓
schools.contact_email
```

---

# 12. EMAIL SCHOOL APPROVED

Buat Laravel Notification:

```text
SchoolApprovedNotification
```

Isi email:

```text
Pendaftaran sekolah Anda di MindfulEdu telah disetujui.

Sekolah:
SMAN 1 Tangerang

Akun Administrator Sekolah:

Email / Username:
admin@sman1tangerang.test

Password Sementara:
************

Panel Admin Sekolah:
APP_URL/school

Silakan login menggunakan akun tersebut.

Untuk keamanan akun, Anda akan diminta mengganti password setelah login pertama.

MindfulEdu
```

---

# 13. SCHOOL ADMIN FILAMENT PANEL

Tambahkan panel Filament BARU:

```text
/school
```

Jangan mengganggu:

```text
/admin
```

Struktur:

```text
app/
Providers/
Filament/

ExistingAdminPanelProvider.php
SchoolPanelProvider.php
```

Sesuaikan dengan struktur project existing.

Jangan rename provider Super Admin jika tidak diperlukan.

---

# 14. SCHOOL ADMIN ACCESS

Hanya role:

```text
school_admin
```

yang dapat masuk:

```text
/school
```

School Admin harus memiliki:

```text
school_id
```

School Admin hanya boleh melihat data:

```text
school_id == auth()->user()->school_id
```

---

# 15. SCHOOL ADMIN NAVIGATION

Panel School Admin cukup memiliki:

```text
Dashboard

Sekolah
├── Profil Sekolah
└── Kelas

Pengguna
├── Guru
├── Murid
└── Orang Tua

Pendaftaran
├── Guru Pending
└── Murid Pending

Monitoring
├── Activity
├── Burnout Analysis
└── Student Observation
```

JANGAN tampilkan data global.

---

# 16. SCHOOL ADMIN DASHBOARD

Contoh:

```text
SMAN 1 Tangerang

Total Guru
48

Guru Pending
3

Total Murid
820

Murid Pending
8

Total Kelas
24

Activity Hari Ini
72
```

Semua query harus otomatis:

```text
WHERE school_id = authenticated_school_admin.school_id
```

---

# 17. SCHOOL DATA ISOLATION

School Admin SMAN 1:

```text
school_id = 5
```

hanya dapat melihat:

```text
School 5
Teachers School 5
Students School 5
Classes School 5
Activities School 5
Analyses School 5
```

Tidak boleh melihat:

```text
School 6
Teacher School 6
Student School 6
Class School 6
```

Walaupun mencoba membuka ID secara langsung melalui URL.

Implementasikan backend authorization.

Jangan hanya filter tabel Filament.

Gunakan:

```text
Policy
Query Scope
Resource Query
Authorization
```

sesuai struktur existing.

---

# 18. CLASS MANAGEMENT

School Admin dapat membuat kelas untuk sekolahnya.

Menu:

```text
Sekolah
    └── Kelas
```

Form:

```text
Nama Kelas *
Tingkat
Tahun Ajaran
Status Aktif
```

Contoh:

```text
X IPA 1
X IPA 2
XI IPA 1
XI IPA 2
XII IPA 1
```

School Admin JANGAN memilih school manually.

Server otomatis menentukan:

```text
school_id = auth()->user()->school_id
```

---

# 19. RELATION CLASS

Gunakan class model/table EXISTING jika sudah tersedia.

Jangan membuat duplicate.

Pastikan:

```text
School
    hasMany Classes
```

dan:

```text
Class
    belongsTo School
```

Class harus memiliki:

```text
school_id
```

---

# 20. REGISTER GURU — SCHOOL DROPDOWN

Pada Flutter Register Guru:

JANGAN lagi menggunakan text bebas untuk sekolah.

Ubah menjadi:

```text
Dropdown / Searchable Dropdown
```

Contoh:

```text
Nama
Email
Password
Konfirmasi Password

Sekolah
[ Cari / Pilih Sekolah ▼ ]
```

Daftar hanya berasal dari:

```text
schools.status = approved
```

Value yang dikirim:

```text
school_id
```

bukan nama sekolah.

---

# 21. PUBLIC SCHOOL API

Tambahkan endpoint:

```text
GET /api/public/schools
```

Hanya mengembalikan approved school.

Response minimal:

```text
id
name
npsn
city
province
```

Jangan mengekspos:

```text
contact_email
contact_phone
verified_by
internal admin data
```

Support search:

```text
GET /api/public/schools?search=sman
```

---

# 22. REGISTER GURU → SCHOOL ADMIN

Ketika Guru register:

```text
Teacher Register
        ↓
Pilih School
        ↓
school_id
        ↓
Teacher created
        ↓
status pending
        ↓
School Admin sekolah tersebut mengetahui
```

School Admin SMAN 1 hanya mendapatkan pendaftaran guru:

```text
school_id = SMAN 1
```

Tidak mendapatkan guru sekolah lain.

---

# 23. REGISTER MURID

Pada register siswa/murid:

```text
Nama
Email
Password
Konfirmasi Password

Sekolah
[ Pilih Sekolah ▼ ]

Kelas
[ Pilih Kelas ▼ ]
```

Flow:

```text
Pilih Sekolah
        ↓
Laravel mengambil kelas sekolah
        ↓
Flutter menampilkan Class Dropdown
```

Contoh:

```text
Sekolah:
SMAN 1 Tangerang

Kelas:
X IPA 1
X IPA 2
XI IPA 1
XI IPA 2
```

---

# 24. CLASS API

Tambahkan endpoint:

```text
GET /api/public/schools/{school}/classes
```

Hanya active class milik sekolah tersebut.

Backend wajib memastikan:

```text
class.school_id == selected_school_id
```

Jangan percaya `class_id` yang dikirim Flutter tanpa validasi.

---

# 25. REGISTER MURID → SCHOOL ADMIN

Flow:

```text
Student Register
        ↓
school_id
        ↓
class_id
        ↓
status pending
        ↓
School Admin sekolah tersebut mengetahui
```

School Admin dapat:

```text
Approve
Reject
```

---

# 26. TARGET KELAS GURU

Ini perubahan penting pada activity Guru.

Jika Guru memilih:

```text
Jenis Activity = Mengajar
```

maka:

```text
Target Kelas
```

harus berupa:

```text
Dropdown
```

BUKAN text field.

Daftar kelas berasal dari:

```text
teacher.school_id
```

Contoh:

```text
Guru:
Budi

School:
SMAN 1 Tangerang
```

Target kelas:

```text
[ Semua Kelas ]
[ X IPA 1 ]
[ X IPA 2 ]
[ XI IPA 1 ]
[ XI IPA 2 ]
```

JANGAN tampilkan kelas sekolah lain.

---

# 27. TARGET CLASS RELATION

Jika memungkinkan berdasarkan struktur database existing, gunakan:

```text
target_class_id
```

sebagai foreign key.

JANGAN lagi bergantung pada:

```text
target_class = "XI IPA 1"
```

Jika migration diperlukan, buat migration additive.

Jangan menghapus data existing.

---

# 28. CLASSROOM EXISTING

JANGAN ubah flow classroom activity lebih dari yang diperlukan.

Tetap gunakan konsep existing:

```text
personal
classroom
classroom_student
```

Yang berubah hanya filter berdasarkan:

```text
school_id
```

dan:

```text
class_id
```

---

# 29. CLASSROOM RULE

Jika Guru membuat classroom activity:

```text
target_class_id = null
```

maka siswa sekolah yang sama dapat melihat activity sesuai aturan existing.

Jika:

```text
target_class_id = 10
```

maka hanya siswa:

```text
student.school_id == teacher.school_id

AND

student.class_id == target_class_id
```

yang dapat melihat/join.

---

# 30. JANGAN SENTUH FITUR LAIN

Jangan melakukan refactor besar terhadap:

```text
Burnout
FastAPI
AI Analysis
Mindfulness Toolkit
Journal
Check-in
Check-out
Reminder
Google Login
Parent Monitoring
Login History
```

kecuali ada dependency langsung akibat perubahan `school_id`.

Jika tidak perlu berubah:

```text
LEAVE IT AS IS.
```

---

# 31. DATABASE EXISTING

Sebelum migration:

Inspect:

```text
users
schools
classes
activities
roles
permissions
Filament resources
```

Gunakan struktur existing.

Jika sudah ada:

```text
school
class
role
```

maka EXTEND.

JANGAN buat duplicate seperti:

```text
schools_new
school_master
new_classes
```

tanpa alasan.

---

# 32. SUPER ADMIN EXISTING

SANGAT PENTING:

Super Admin saat ini SUDAH ADA.

JANGAN:

```text
recreate Super Admin
delete Super Admin
change Super Admin password
change Super Admin email
change Super Admin login mechanism
change Super Admin role unexpectedly
```

Hanya tambahkan resource/menu yang diperlukan.

---

# 33. SUPER ADMIN DATA

Super Admin tetap dapat melihat:

```text
SEMUA sekolah
SEMUA School Admin
SEMUA guru
SEMUA murid
SEMUA parent
SEMUA kelas
SEMUA activity
SEMUA monitoring
```

Contoh filter boleh ditambahkan:

```text
School
Status
Role
Class
```

supaya data lebih mudah dibaca.

---

# 34. SCHOOL ADMIN DATA

School Admin hanya:

```text
SEKOLAH SENDIRI

GURU SEKOLAH SENDIRI

MURID SEKOLAH SENDIRI

KELAS SEKOLAH SENDIRI

PARENT TERKAIT SISWA SEKOLAH SENDIRI

ACTIVITY SEKOLAH SENDIRI

ANALYSIS SEKOLAH SENDIRI
```

Tidak ada dropdown:

```text
Pilih Sekolah
```

pada School Admin Panel.

Karena sekolah otomatis berasal dari:

```text
auth()->user()->school_id
```

---

# 35. EMAIL DEVELOPMENT

Untuk saat ini pola account School Admin adalah:

```text
admin@schoolslug.test
```

Contoh:

```text
admin@sman1tangerang.test
admin@smpn5jakarta.test
admin@smkn2tangerang.test
```

Gunakan ini sebagai LOGIN.

Untuk EMAIL DELIVERY gunakan:

```text
schools.contact_email
```

melalui Resend.

---

# 36. RESEND ENVIRONMENT

Jangan hardcode API key.

Gunakan `.env`.

Contoh:

```env
MAIL_MAILER=resend

RESEND_KEY=

MAIL_FROM_ADDRESS=
MAIL_FROM_NAME="MindfulEdu"
```

Gunakan configuration Laravel yang kompatibel dengan versi Laravel existing.

Jangan upgrade framework hanya untuk memasang email.

---

# 37. SECURITY

Pastikan:

```text
school_id tidak bisa dimanipulasi School Admin

class_id harus berasal dari school yang sesuai

teacher school harus approved

student school harus approved

School Admin hanya school sendiri

temporary password hashed

Resend API key hanya di .env

Super Admin tetap global
```

---

# 38. MIGRATION

Migration harus additive dan aman.

Contoh kemungkinan tambahan:

```text
schools.status
schools.slug
schools.contact_email
schools.verified_at
schools.verified_by

users.school_id
users.approval_status
users.must_change_password

classes.school_id

activities.target_class_id
```

TETAPI:

Jangan langsung membuat semuanya.

PERIKSA dahulu field mana yang sebenarnya sudah tersedia.

Jika sudah ada:

```text
REUSE.
```

---

# 39. IMPLEMENTATION ORDER

Kerjakan dengan urutan:

```text
1. Audit project existing.

2. Identifikasi:
   - existing Super Admin
   - Filament version
   - School model/table
   - Class model/table
   - User school field
   - existing roles
   - Activity target class

3. Tambahkan/extend School model.

4. Tambahkan Public School Registration.

5. Tambahkan School Registration ke Super Admin existing.

6. Implement Approve/Reject.

7. Generate:
   admin@schoolslug.test

8. Integrasikan Resend ke contact_email.

9. Tambahkan Filament /school panel.

10. Implement tenant isolation.

11. Tambahkan Class Management School Admin.

12. Update Teacher registration School Dropdown.

13. Update Student School + Class Dropdown.

14. Update Target Class Guru menjadi dropdown.

15. Test classroom isolation.

16. Rapikan navigation Super Admin existing.

17. Jalankan semua test.
```

---

# 40. TEST WAJIB

Pastikan minimal:

```text
Existing Super Admin masih bisa login.

Existing /admin masih bekerja.

Existing resource tidak rusak.

School registration berhasil.

School pending masuk Super Admin.

Super Admin dapat approve.

Approve membuat School Admin.

School Admin login email:
admin@schoolslug.test

Credential email dikirim ke school.contact_email.

School Admin hanya melihat sekolahnya.

School Admin A tidak melihat School B.

School Admin dapat membuat kelas.

Kelas otomatis memiliki school_id.

Teacher register hanya melihat approved school.

Teacher pending muncul pada School Admin yang benar.

Student register hanya melihat approved school.

Class dropdown mengikuti selected school.

Student pending muncul ke School Admin yang benar.

Teacher Target Class hanya menampilkan class sekolahnya.

Siswa sekolah lain tidak bisa join activity tersebut.

Existing check-in tetap bekerja.

Existing check-out tetap bekerja.

Existing burnout tetap bekerja.

Existing toolkit tetap bekerja.

Existing parent flow tetap bekerja.
```

---

# 41. HASIL AKHIR

Arsitektur akhirnya:

```text
MINDFULEDU
│
├── Website
│   │
│   └── Daftar Sekolah
│
├── Existing Filament Super Admin
│   │
│   └── /admin
│
│       ├── Sekolah
│       ├── Guru
│       ├── Murid
│       ├── Orang Tua
│       ├── Kelas
│       ├── Activity
│       └── Monitoring
│
├── New Filament School Admin
│   │
│   └── /school
│
│       ├── Profil Sekolah
│       ├── Guru
│       ├── Murid
│       ├── Kelas
│       └── Monitoring
│
├── Flutter
│   ├── Teacher
│   ├── Student
│   └── Parent
│
└── Existing FastAPI
    └── Tetap seperti sekarang
```

School onboarding:

```text
School Register
      ↓
Super Admin Existing
      ↓
Approve
      ↓
Generate
admin@schoolslug.test
      ↓
Generate Temporary Password
      ↓
Send credentials via Resend
to schools.contact_email
      ↓
School Admin Login /school
      ↓
School Admin membuat kelas
```

User flow:

```text
TEACHER

Register
↓
School Dropdown
↓
school_id
↓
School Admin mengetahui
↓
Approve
↓
Teacher Active
```

```text
STUDENT

Register
↓
School Dropdown
↓
Class Dropdown
↓
school_id + class_id
↓
School Admin mengetahui
↓
Approve
↓
Student Active
```

Activity:

```text
Teacher
↓
Create Activity
↓
Jenis = Mengajar
↓
Target Kelas
↓
Dropdown kelas sekolah guru
↓
Classroom Activity
```

---

# 42. FINAL INSTRUCTION

Prioritas utama:

```text
JANGAN RUSAK SISTEM EXISTING.
```

Jika fitur tidak berhubungan dengan requirement ini:

```text
JANGAN UBAH.
```

Super Admin existing:

```text
PERTAHANKAN.
```

Filament Admin existing:

```text
PERTAHANKAN.
```

Yang ditambahkan hanya:

```text
School Registration

School Management

School Admin Account

School Admin Filament Panel

School Tenant Isolation

Class Management

School Dropdown

Class Dropdown

Teacher Target Class Dropdown

Resend Email

Super Admin Navigation Grouping
```

Setelah implementasi selesai, berikan laporan:

```text
1. File yang ditambah
2. File existing yang diubah
3. Migration yang ditambah
4. Resource Filament yang ditambah
5. Endpoint yang ditambah
6. Flutter screen yang berubah
7. Resend configuration
8. Hasil testing
9. Fitur existing yang diverifikasi tetap bekerja
```
