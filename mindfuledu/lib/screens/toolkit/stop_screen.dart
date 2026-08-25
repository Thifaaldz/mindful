import 'package:flutter/material.dart';

class _StopStep {
  const _StopStep(this.letter, this.title, this.description);
  final String letter;
  final String title;
  final String description;
}

const _stopSteps = [
  _StopStep('S', 'Stop', 'Hentikan sejenak apa pun yang sedang Anda lakukan.'),
  _StopStep(
    'T',
    'Take a breath',
    'Tarik napas dalam-dalam beberapa kali dengan perlahan.',
  ),
  _StopStep(
    'O',
    'Observe',
    'Amati apa yang Anda rasakan di tubuh, pikiran, dan emosi Anda saat ini.',
  ),
  _StopStep(
    'P',
    'Proceed',
    'Lanjutkan dengan pilihan yang lebih sadar dan tenang.',
  ),
];

class StopScreen extends StatefulWidget {
  const StopScreen({super.key});

  @override
  State<StopScreen> createState() => _StopScreenState();
}

class _StopScreenState extends State<StopScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final step = _stopSteps[_index];

    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Spacer(),
              Text(
                step.letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                step.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                step.description,
                style: const TextStyle(color: Colors.white70, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _stopSteps.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index ? Colors.white : Colors.white24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_index < _stopSteps.length - 1) {
                      setState(() => _index++);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _index < _stopSteps.length - 1 ? 'Lanjut' : 'Selesai',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
