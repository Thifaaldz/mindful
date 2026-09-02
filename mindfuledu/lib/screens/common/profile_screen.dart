import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/account_role.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/session.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/login_history_widgets.dart';
import 'reminder_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  bool _avatarLoading = false;

  Future<void> _pickAvatar() async {
    setState(() => _avatarLoading = true);
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 82,
      );
      if (image == null) return;
      if (!mounted) return;

      await context.read<Session>().updateAvatar(image.path);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto profil diperbarui')));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload foto gagal: $e')));
    } finally {
      if (mounted) setState(() => _avatarLoading = false);
    }
  }

  Future<void> _openEditProfile(Map<String, dynamic> user) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EditProfileSheet(user: user),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final user = session.user ?? {};
    final role = user['role'] as String?;
    final accountRole = AccountRole.byId(role);
    final className = (user['class'] as Map?)?['name'] as String?;
    final studentCode = user['student_verification_code'] as String?;
    final avatarUrl = user['avatar_url'] as String?;
    final latestLogin = loginHistoryMap(user['latest_login']);
    final loginHistories = (user['login_histories'] as List? ?? const [])
        .cast<dynamic>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const BrandHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: accountRole.accent.withValues(
                          alpha: 0.35,
                        ),
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: avatarUrl == null
                            ? Icon(
                                Icons.person,
                                color: accountRole.primary,
                                size: 42,
                              )
                            : null,
                      ),
                      IconButton.filled(
                        tooltip: 'Ubah foto',
                        style: IconButton.styleFrom(
                          backgroundColor: accountRole.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _avatarLoading ? null : _pickAvatar,
                        icon: _avatarLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.camera_alt_outlined, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['name'] as String? ?? '-',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'] as String? ?? '-',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  LastLoginCaption(
                    login: latestLogin,
                    color: accountRole.primary,
                  ),
                  const SizedBox(height: 18),
                  if (role == 'teacher' || role == 'student')
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: accountRole.primary,
                      ),
                      onPressed: () => _openEditProfile(user),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profil'),
                    ),
                  const SizedBox(height: 24),
                  SoftCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Peran',
                          value: (role ?? '-').toUpperCase(),
                        ),
                        if (user['school'] != null) ...[
                          const Divider(height: 28),
                          _InfoRow(
                            icon: Icons.school_outlined,
                            label: 'Sekolah',
                            value: user['school'] as String,
                          ),
                        ],
                        if (className != null) ...[
                          const Divider(height: 28),
                          _InfoRow(
                            icon: Icons.class_outlined,
                            label: 'Kelas',
                            value: className,
                          ),
                        ],
                        if (studentCode != null && studentCode.isNotEmpty) ...[
                          const Divider(height: 28),
                          _InfoRow(
                            icon: Icons.verified_user_outlined,
                            label: 'Kode Parent',
                            value: studentCode,
                            trailing: IconButton.filledTonal(
                              tooltip: 'Salin kode',
                              onPressed: () => _copyStudentCode(studentCode),
                              icon: const Icon(Icons.copy_outlined),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  LoginHistoryCard(
                    histories: loginHistories,
                    color: accountRole.primary,
                  ),
                  if (loginHistories.isNotEmpty) const SizedBox(height: 22),
                  _ActionCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'Pengingat Harian',
                    subtitle: 'Push notification atau email.',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReminderSettingsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.read<Session>().logout(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyStudentCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Kode siswa disalin')));
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});

  final Map<String, dynamic> user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _schoolController;
  late final TextEditingController _classController;
  bool _loading = false;
  String? _error;

  bool get _isStudent => widget.user['role'] == 'student';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user['name'] as String? ?? '',
    );
    _schoolController = TextEditingController(
      text: widget.user['school'] as String? ?? '',
    );
    _classController = TextEditingController(
      text: (widget.user['class'] as Map?)?['name'] as String? ?? '',
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<Session>().updateProfile(
        name: _nameController.text.trim(),
        school: _schoolController.text.trim(),
        className: _isStudent ? _classController.text.trim() : null,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = _formatApiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Profil',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _schoolController,
                decoration: const InputDecoration(labelText: 'Sekolah'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Sekolah wajib diisi'
                    : null,
              ),
              if (_isStudent) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _classController,
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Kelas wajib diisi'
                      : null,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loading ? null : _save,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Simpan'),
              ),
            ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.mint,
          child: Icon(icon, color: AppTheme.olive),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: AppTheme.mint,
          child: Icon(icon, color: AppTheme.olive),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
