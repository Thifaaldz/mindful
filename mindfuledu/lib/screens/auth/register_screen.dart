import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/account_role.dart';
import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/google_auth_service.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.selectedRole});

  final String selectedRole;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _schoolController = TextEditingController();
  final _studentCodeController = TextEditingController();
  late Future<List<dynamic>> _schoolsFuture;
  Future<List<dynamic>>? _classesFuture;
  int? _selectedSchoolId;
  int? _selectedClassId;
  bool _loading = false;
  bool _googleLoading = false;
  bool _rememberDevice = true;
  String? _error;
  String? _googleIdToken;

  AccountRole get _role => AccountRole.byId(widget.selectedRole);
  bool get _isGoogleRegistration => _googleIdToken != null;

  @override
  void initState() {
    super.initState();
    _schoolsFuture = Api.publicSchools();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<Session>();

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final registrationMessage = _isGoogleRegistration
          ? await session.registerWithGoogleIdToken(
              idToken: _googleIdToken!,
              email: _emailController.text.trim(),
              password: _passwordController.text,
              passwordConfirmation: _passwordConfirmController.text,
              role: _role.id,
              schoolId: _role.id == 'teacher' || _role.id == 'student'
                  ? _selectedSchoolId
                  : null,
              school: _role.id == 'parent'
                  ? _schoolController.text.trim()
                  : null,
              classId: _role.id == 'student' ? _selectedClassId : null,
              studentVerificationCode: _role.id == 'parent'
                  ? _studentCodeController.text.trim()
                  : null,
              rememberDevice: _rememberDevice,
            )
          : await session.register(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              passwordConfirmation: _passwordConfirmController.text,
              role: _role.id,
              schoolId: _role.id == 'teacher' || _role.id == 'student'
                  ? _selectedSchoolId
                  : null,
              school: _role.id == 'parent'
                  ? _schoolController.text.trim()
                  : null,
              classId: _role.id == 'student' ? _selectedClassId : null,
              studentVerificationCode: _role.id == 'parent'
                  ? _studentCodeController.text.trim()
                  : null,
              rememberDevice: _rememberDevice,
            );
      if (registrationMessage != null && mounted) {
        await _showRegistrationDialog(registrationMessage);
      }
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      setState(() => _error = _formatApiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showRegistrationDialog(String message) {
    final waitingApproval = message.toLowerCase().contains('menunggu');

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pendaftaran Berhasil'),
        content: Text(
          waitingApproval
              ? 'Terima kasih sudah daftar. Tunggu approval Admin Sekolah.\n\nSetelah disetujui, Anda bisa login memakai email dan password yang dibuat saat registrasi.'
              : 'Terima kasih sudah daftar.\n\n$message',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      await GoogleAuthService.signOut();
      final result = await GoogleAuthService.signInAndGetProfile();
      if (result == null) return;
      if (!mounted) return;

      setState(() {
        _googleIdToken = result.idToken;
        _emailController.text = result.email;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akun Google ${result.email} dipilih. Lengkapi password dan data sekolah, lalu tekan daftar.',
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _error = _formatApiError(e));
    } catch (e) {
      setState(() => _error = 'Register Google gagal: $e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _schoolController.dispose();
    _studentCodeController.dispose();
    super.dispose();
  }

  void _selectSchool(int? schoolId, {String? schoolName}) {
    setState(() {
      _selectedSchoolId = schoolId;
      _schoolController.text = schoolName ?? '';
      _selectedClassId = null;
      _classesFuture = schoolId == null || _role.id != 'student'
          ? null
          : Api.publicSchoolClasses(schoolId);
    });
  }

  void _clearGoogleRegistration() {
    setState(() {
      _googleIdToken = null;
      _emailController.clear();
      _error = null;
    });
  }

  Widget _googleRegisterButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: _role.primary,
        side: BorderSide(color: _role.primary.withValues(alpha: 0.24)),
      ),
      onPressed: _googleLoading ? null : _registerWithGoogle,
      icon: _googleLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.g_mobiledata, size: 28),
      label: Text(
        _isGoogleRegistration ? 'Ganti akun Google' : 'Pilih akun Google',
      ),
    );
  }

  Widget _emailDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau daftar dengan email',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _schoolDropdown() {
    return FutureBuilder<List<dynamic>>(
      future: _schoolsFuture,
      builder: (context, snapshot) {
        final schools = snapshot.data ?? const [];
        final hasSelected = schools.any(
          (item) => (item as Map<String, dynamic>)['id'] == _selectedSchoolId,
        );

        return DropdownButtonFormField<int>(
          initialValue: hasSelected ? _selectedSchoolId : null,
          decoration: InputDecoration(
            labelText: switch (_role.id) {
              'parent' => 'Sekolah anak',
              'student' => 'Sekolah siswa',
              _ => 'Sekolah',
            },
            border: const OutlineInputBorder(),
          ),
          items: schools.map((item) {
            final school = item as Map<String, dynamic>;
            final city = '${school['city'] ?? ''}'.trim();
            final subtitle = city.isEmpty ? '' : ' - $city';

            return DropdownMenuItem<int>(
              value: school['id'] as int,
              child: Text('${school['name']}$subtitle'),
            );
          }).toList(),
          onChanged: snapshot.connectionState == ConnectionState.waiting
              ? null
              : (value) {
                  final selectedSchools = schools
                      .cast<Map<String, dynamic>>()
                      .where((school) => school['id'] == value)
                      .toList();
                  final schoolName = selectedSchools.isEmpty
                      ? null
                      : '${selectedSchools.first['name'] ?? ''}'.trim();
                  _selectSchool(value, schoolName: schoolName);
                },
          validator: (value) =>
              value == null ? 'Pilih sekolah terdaftar' : null,
        );
      },
    );
  }

  Widget _studentClassDropdown() {
    if (_selectedSchoolId == null || _classesFuture == null) {
      return DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Kelas',
          border: OutlineInputBorder(),
        ),
        items: const [],
        onChanged: null,
        validator: (_) => 'Pilih sekolah terlebih dahulu',
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: _classesFuture,
      builder: (context, snapshot) {
        final classes = snapshot.data ?? const [];

        return DropdownButtonFormField<int>(
          initialValue: _selectedClassId,
          decoration: const InputDecoration(
            labelText: 'Kelas',
            border: OutlineInputBorder(),
          ),
          items: classes.map((item) {
            final schoolClass = item as Map<String, dynamic>;
            final grade = '${schoolClass['grade'] ?? ''}'.trim();
            final subtitle = grade.isEmpty ? '' : ' - tingkat $grade';

            return DropdownMenuItem<int>(
              value: schoolClass['id'] as int,
              child: Text('${schoolClass['name']}$subtitle'),
            );
          }).toList(),
          onChanged: snapshot.connectionState == ConnectionState.waiting
              ? null
              : (value) => setState(() => _selectedClassId = value),
          validator: (value) => value == null ? 'Pilih kelas' : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _role.surface,
      appBar: AppBar(
        backgroundColor: _role.surface,
        foregroundColor: _role.primary,
        title: Text(_role.registerTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: BrandMark(
                    size: 86,
                    radius: 22,
                    iconSize: 46,
                    backgroundColor: _role.primary,
                    iconColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _role.registerTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _role.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _role.subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _googleRegisterButton(),
                const SizedBox(height: 12),
                if (!_isGoogleRegistration) ...[
                  _emailDivider(),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _emailController,
                  readOnly: _isGoogleRegistration,
                  decoration: InputDecoration(
                    labelText: _isGoogleRegistration ? 'Email Google' : 'Email',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isGoogleRegistration
                        ? Icon(Icons.verified, color: _role.primary)
                        : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Email wajib diisi';
                    if (!value.contains('@')) return 'Format email belum benar';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 8)
                      ? 'Password minimal 8 karakter'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmController,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => (v != _passwordController.text)
                      ? 'Konfirmasi tidak sesuai'
                      : null,
                ),
                if (_isGoogleRegistration) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: _role.primary),
                    onPressed: _googleLoading ? null : _clearGoogleRegistration,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Ganti ke daftar email biasa'),
                  ),
                ],
                if (_role.id == 'teacher' ||
                    _role.id == 'student' ||
                    _role.id == 'parent') ...[
                  const SizedBox(height: 16),
                  _schoolDropdown(),
                ],
                if (_role.id == 'student') ...[
                  const SizedBox(height: 16),
                  _studentClassDropdown(),
                ],
                if (_role.id == 'parent') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _studentCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Kode verifikasi siswa',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Kode verifikasi siswa wajib diisi'
                        : null,
                  ),
                ],
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _rememberDevice,
                  onChanged: (value) => setState(() => _rememberDevice = value),
                  title: const Text('Simpan akun di perangkat ini'),
                  subtitle: const Text(
                    'Login berikutnya cukup PIN atau biometrik',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _role.primary),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isGoogleRegistration
                              ? '${_role.registerTitle} dengan Google'
                              : _role.registerTitle,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatApiError(ApiException error) {
    final errors = error.errors;
    if (errors == null || errors.isEmpty) return error.message;

    final messages = <String>[];
    for (final value in errors.values) {
      if (value is List) {
        messages.addAll(value.map((item) => '$item'));
      } else if (value != null) {
        messages.add('$value');
      }
    }

    return messages.isEmpty ? error.message : messages.join('\n');
  }
}
