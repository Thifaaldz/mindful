import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/account_role.dart';
import '../../core/api_client.dart';
import '../../core/google_auth_service.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AccountRole _selectedRole = AccountRole.teacher;
  bool _loading = false;
  bool _googleLoading = false;
  bool _quickLoading = false;
  bool _rememberDevice = true;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<Session>().login(
        _emailController.text.trim(),
        _passwordController.text,
        role: _selectedRole.id,
        rememberDevice: _rememberDevice,
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
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
        role: _selectedRole.id,
        rememberDevice: _rememberDevice,
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Login Google gagal: $e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _quickLogin() async {
    setState(() {
      _quickLoading = true;
      _error = null;
    });
    try {
      await context.read<Session>().quickLogin(role: _selectedRole.id);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _quickLoading = false);
    }
  }

  void _selectRole(AccountRole role) {
    setState(() {
      _selectedRole = role;
      _error = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final savedAccount = session.savedAccount;
    final savedRole = savedAccount?['role'] as String?;
    final canQuickLogin =
        session.quickLoginAvailable &&
        savedAccount != null &&
        (savedRole == null || savedRole == _selectedRole.id);

    return Scaffold(
      backgroundColor: _selectedRole.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: BrandMark(
                      size: 118,
                      radius: 30,
                      iconSize: 62,
                      backgroundColor: _selectedRole.primary,
                      iconColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _selectedRole.loginTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _selectedRole.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedRole.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _RolePicker(
                    selectedRole: _selectedRole,
                    onSelected: _selectRole,
                  ),
                  const SizedBox(height: 22),
                  if (canQuickLogin) ...[
                    _SavedAccountPanel(
                      role: _selectedRole,
                      name: savedAccount['name'] as String?,
                      email: savedAccount['email'] as String?,
                      loading: _quickLoading,
                      onPressed: _quickLogin,
                    ),
                    const SizedBox(height: 18),
                  ],
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
                      if (!value.contains('@')) {
                        return 'Format email belum benar';
                      }
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
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Password wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: _selectedRole.primary,
                    value: _rememberDevice,
                    onChanged: (value) =>
                        setState(() => _rememberDevice = value),
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
                    style: FilledButton.styleFrom(
                      backgroundColor: _selectedRole.primary,
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_selectedRole.loginTitle),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _selectedRole.primary,
                      side: BorderSide(
                        color: _selectedRole.primary.withValues(alpha: 0.24),
                      ),
                    ),
                    onPressed: _googleLoading ? null : _loginWithGoogle,
                    icon: _googleLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.g_mobiledata, size: 28),
                    label: Text('${_selectedRole.loginTitle} dengan Google'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: _selectedRole.primary,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RegisterScreen(selectedRole: _selectedRole.id),
                      ),
                    ),
                    child: Text(
                      'Belum punya akun? ${_selectedRole.registerTitle}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RolePicker extends StatelessWidget {
  const _RolePicker({required this.selectedRole, required this.onSelected});

  final AccountRole selectedRole;
  final ValueChanged<AccountRole> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selectedRole.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: AccountRole.values.map((role) {
          final selected = role.id == selectedRole.id;
          return Expanded(
            child: Tooltip(
              message: role.title,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => onSelected(role),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: selected ? role.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        role.icon,
                        size: 18,
                        color: selected ? Colors.white : role.primary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            role.title,
                            maxLines: 1,
                            style: TextStyle(
                              color: selected ? Colors.white : role.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SavedAccountPanel extends StatelessWidget {
  const _SavedAccountPanel({
    required this.role,
    required this.name,
    required this.email,
    required this.loading,
    required this.onPressed,
  });

  final AccountRole role;
  final String? name;
  final String? email;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: role.primary.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: role.accent,
              foregroundColor: role.primary,
              child: Text(
                ((name?.isNotEmpty ?? false) ? name! : email ?? 'M')
                    .characters
                    .first
                    .toUpperCase(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? 'Akun tersimpan',
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (email != null)
                    Text(
                      email!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Masuk cepat',
              onPressed: loading ? null : onPressed,
              icon: loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.fingerprint),
            ),
          ],
        ),
      ),
    );
  }
}
