import 'package:flutter/material.dart';

class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> {
  final _seen = List.generate(3, (_) => TextEditingController());
  final _heard = List.generate(2, (_) => TextEditingController());
  final _felt = List.generate(1, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in [..._seen, ..._heard, ..._felt]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _section(
    String title,
    String prompt,
    List<TextEditingController> controllers,
    Color color,
  ) {
    return Card(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(prompt, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            for (var i = 0; i < controllers.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(
                    hintText: '${i + 1}. ...',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grounding 3-2-1')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            '3 Hal yang Dilihat',
            'Sebutkan 3 benda yang bisa Anda lihat di sekitar Anda sekarang.',
            _seen,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _section(
            '2 Hal yang Didengar',
            'Sebutkan 2 suara yang bisa Anda dengar sekarang.',
            _heard,
            Colors.teal,
          ),
          const SizedBox(height: 12),
          _section(
            '1 Hal yang Dirasakan',
            'Sebutkan 1 sensasi fisik yang Anda rasakan sekarang.',
            _felt,
            Colors.purple,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Selesai, Saya Merasa Lebih Tenang'),
          ),
        ],
      ),
    );
  }
}
