import 'package:flutter/material.dart';

class AccountRole {
  const AccountRole({
    required this.id,
    required this.title,
    required this.loginTitle,
    required this.registerTitle,
    required this.subtitle,
    required this.icon,
    required this.primary,
    required this.accent,
    required this.surface,
  });

  final String id;
  final String title;
  final String loginTitle;
  final String registerTitle;
  final String subtitle;
  final IconData icon;
  final Color primary;
  final Color accent;
  final Color surface;

  static const teacher = AccountRole(
    id: 'teacher',
    title: 'Guru',
    loginTitle: 'Masuk Guru',
    registerTitle: 'Daftar Guru',
    subtitle: 'Kelola aktivitas kelas dan pantau kondisi belajar.',
    icon: Icons.school,
    primary: Color(0xFF315F4C),
    accent: Color(0xFFA8D8C0),
    surface: Color(0xFFF2F8F5),
  );

  static const student = AccountRole(
    id: 'student',
    title: 'Siswa',
    loginTitle: 'Masuk Siswa',
    registerTitle: 'Daftar Siswa',
    subtitle: 'Catat mood, ikuti kelas, dan temukan latihan yang sesuai.',
    icon: Icons.backpack,
    primary: Color(0xFF315D8A),
    accent: Color(0xFFAED1F2),
    surface: Color(0xFFF1F7FD),
  );

  static const parent = AccountRole(
    id: 'parent',
    title: 'Orang Tua',
    loginTitle: 'Masuk Orang Tua',
    registerTitle: 'Daftar Orang Tua',
    subtitle: 'Lihat perkembangan anak dan rekomendasi pendampingan.',
    icon: Icons.family_restroom,
    primary: Color(0xFF7A4B35),
    accent: Color(0xFFE8BE95),
    surface: Color(0xFFFFF7EF),
  );

  static const values = [teacher, student, parent];

  static AccountRole byId(String? id) {
    return values.firstWhere((role) => role.id == id, orElse: () => teacher);
  }
}
