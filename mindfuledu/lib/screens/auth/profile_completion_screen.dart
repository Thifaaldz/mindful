import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/account_role.dart';
import '../../core/api.dart';
import '../../core/api_client.dart';
import '../../core/session.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();
  final _studentCodeController = TextEditingController();
  late Future<List<dynamic>> _schoolsFuture;
  Future<List<dynamic>>? _classesFuture;
  int? _selectedSchoolId;
  int? _selectedClassId;
  String _role = 'teacher';
  bool _initialized = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _schoolsFuture = Api.publicSchools();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<Session>().user;
    if (!_initialized) {
      _role = (user?['role'] as String?) ?? _role;
      _selectedSchoolId = user?['school_id'] as int?;
      _selectedClassId = (user?['class'] as Map?)?['id'] as int?;
      if (_selectedSchoolId != null) {
        _classesFuture = Api.publicSchoolClasses(_selectedSchoolId!);
      }
      _initialized = true;
    }
    _nameController.text = _nameController.text.isEmpty
        ? (user?['name'] as String? ?? '')
        : _nameController.text;
    _schoolController.text = _schoolController.text.isEmpty
        ? (user?['school'] as String? ?? '')
        : _schoolController.text;
    final className = (user?['class'] as Map?)?['name'] as String?;
    _classController.text = _classController.text.isEmpty
        ? (className ?? '')
        : _classController.text;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<Session>().completeProfile(
        name: _nameController.text.trim(),
        role: _role,
        schoolId: _role == 'teacher' || _role == 'student'
            ? _selectedSchoolId
            : null,
        school: _role == 'parent' ? _schoolController.text.trim() : null,
        classId: _role == 'student' ? _selectedClassId : null,
        className: _role == 'student' && _selectedClassId == null
            ? _classController.text.trim()
            : null,
        studentVerificationCode: _role == 'parent'
            ? _studentCodeController.text.trim()
            : null,
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    _studentCodeController.dispose();
    super.dispose();
  }

  void _selectSchool(int? schoolId) {
    setState(() {
      _selectedSchoolId = schoolId;
      _selectedClassId = null;
      _classesFuture = schoolId == null ? null : Api.publicSchoolClasses(schoolId);
    });
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
          decoration: const InputDecoration(
            labelText: 'Sekolah',
            border: OutlineInputBorder(),
          ),
          items: schools
              .map((item) {
                final school = item as Map<String, dynamic>;
                final city = '${school['city'] ?? ''}'.trim();
                final subtitle = city.isEmpty ? '' : ' - $city';

                return DropdownMenuItem<int>(
                  value: school['id'] as int,
                  child: Text('${school['name']}$subtitle'),
                );
              })
              .toList(),
          onChanged: snapshot.connectionState == ConnectionState.waiting
              ? null
              : _selectSchool,
          validator: (value) => value == null ? 'Pilih sekolah terdaftar' : null,
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
        final hasSelected = classes.any(
          (item) => (item as Map<String, dynamic>)['id'] == _selectedClassId,
        );

        return DropdownButtonFormField<int>(
          initialValue: hasSelected ? _selectedClassId : null,
          decoration: const InputDecoration(
            labelText: 'Kelas',
            border: OutlineInputBorder(),
          ),
          items: classes
              .map((item) {
                final schoolClass = item as Map<String, dynamic>;
                final grade = '${schoolClass['grade'] ?? ''}'.trim();
                final subtitle = grade.isEmpty ? '' : ' - tingkat $grade';

                return DropdownMenuItem<int>(
                  value: schoolClass['id'] as int,
                  child: Text('${schoolClass['name']}$subtitle'),
                );
              })
              .toList(),
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
    final role = AccountRole.byId(_role);

    return Scaffold(
      backgroundColor: role.surface,
      appBar: AppBar(
        backgroundColor: role.surface,
        foregroundColor: role.primary,
        title: const Text('Lengkapi Akun'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: _loading
                ? null
                : () => context.read<Session>().logout(remote: false),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SelectedRoleBanner(role: role),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                if (_role == 'teacher' || _role == 'student')
                  _schoolDropdown()
                else
                  TextFormField(
                    controller: _schoolController,
                    decoration: const InputDecoration(
                      labelText: 'Sekolah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Sekolah wajib diisi'
                        : null,
                  ),
                if (_role == 'student') ...[
                  const SizedBox(height: 16),
                  _studentClassDropdown(),
                ],
                if (_role == 'parent') ...[
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
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: role.primary),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedRoleBanner extends StatelessWidget {
  const _SelectedRoleBanner({required this.role});

  final AccountRole role;

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
              child: Icon(role.icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: role.primary),
                  ),
                  Text(
                    role.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
