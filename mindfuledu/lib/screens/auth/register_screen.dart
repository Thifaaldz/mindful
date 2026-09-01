import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/account_role.dart';
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
  bool _loading = false;
  bool _googleLoading = false;
  bool _rememberDevice = true;
  String? _error;

  AccountRole get _role => AccountRole.byId(widget.selectedRole);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<Session>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        role: _role.id,
        school: _role.id == 'parent' ? _schoolController.text.trim() : null,
        studentVerificationCode: _role.id == 'parent'
            ? _studentCodeController.text.trim()
            : null,
        rememberDevice: _rememberDevice,
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      setState(() => _error = _formatApiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      final idToken = await GoogleAuthService.signInAndGetIdToken();
      if (idToken == null) return;
      if (!mounted) return;

      await context.read<Session>().loginWithGoogleIdToken(
        idToken,
        role: _role.id,
        rememberDevice: _rememberDevice,
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
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
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
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
                if (_role.id == 'parent') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _schoolController,
                    decoration: const InputDecoration(
                      labelText: 'Sekolah anak',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Sekolah anak wajib diisi'
                        : null,
                  ),
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
                      : Text(_role.registerTitle),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _role.primary,
                    side: BorderSide(
                      color: _role.primary.withValues(alpha: 0.24),
                    ),
                  ),
                  onPressed: _googleLoading ? null : _registerWithGoogle,
                  icon: _googleLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.g_mobiledata, size: 28),
                  label: Text('${_role.registerTitle} dengan Google'),
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
