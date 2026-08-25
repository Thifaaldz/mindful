import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/app_theme.dart';
import '../../widgets/app_chrome.dart';
import '../../widgets/mindful_avatar.dart';
import 'logbook_form_screen.dart';

class _Step {
  const _Step(
    this.title,
    this.instruction,
    this.seconds, {
    required this.avatarAsset,
    this.hasCounter = false,
  });
  final String title;
  final String instruction;
  final int seconds;
  final String avatarAsset;
  final bool hasCounter;
}

const _steps = [
  _Step(
    'Langkah 1: Posisi Nyaman',
    'Duduk dengan tenang, punggung tegak, dan tangan rileks di pangkuan.',
    30,
    avatarAsset: 'avatar_step_1.png',
  ),
  _Step(
    'Langkah 2: Tarik Napas Dalam',
    'Tarik napas dalam-dalam melalui hidung, embuskan perlahan melalui mulut.',
    60,
    avatarAsset: 'avatar_step_2.png',
  ),
  _Step(
    'Langkah 3: Perhatikan Napas',
    'Fokuskan perhatian sepenuhnya pada keluar-masuknya napas Anda.',
    300,
    avatarAsset: 'avatar_step_3.png',
  ),
  _Step(
    'Langkah 4: Amati Pikiran',
    'Jika pikiran melayang, sadari dengan lembut lalu kembali ke napas. Tekan tombol setiap kali Anda tersadar terdistraksi.',
    120,
    avatarAsset: 'avatar_step_4.png',
    hasCounter: true,
  ),
  _Step(
    'Langkah 5: Amati Sensasi Tubuh',
    'Rasakan sensasi tubuh dari ujung kepala hingga kaki tanpa menghakimi. Catat setiap kali perhatian Anda teralihkan.',
    120,
    avatarAsset: 'avatar_step_5.png',
    hasCounter: true,
  ),
  _Step(
    'Langkah 6: Perluas Kesadaran',
    'Perluas kesadaran ke seluruh ruangan di sekitar Anda.',
    60,
    avatarAsset: 'avatar_step_6.png',
  ),
  _Step(
    'Langkah 7: Tutup Sesi',
    'Ucapkan niat baik untuk diri sendiri dan siswa Anda hari ini.',
    30,
    avatarAsset: 'avatar_step_7.png',
  ),
];

class SessionGuideScreen extends StatefulWidget {
  const SessionGuideScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<SessionGuideScreen> createState() => _SessionGuideScreenState();
}

class _SessionGuideScreenState extends State<SessionGuideScreen> {
  int _stepIndex = 0;
  int _remaining = _steps[0].seconds;
  int _totalElapsed = 0;
  int _distractionScore = 0;
  bool _audioEnabled = false;
  bool _paused = false;
  Timer? _timer;
  late final FlutterTts _tts;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _setupVoice();
    _startTimer();
  }

  Future<void> _setupVoice() async {
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1);
  }

  Future<void> _speakCurrentStep() async {
    if (!_audioEnabled) return;
    final step = _steps[_stepIndex];
    await _tts.stop();
    await _tts.speak('${step.title}. ${step.instruction}', focus: true);
  }

  Future<void> _toggleAudio() async {
    setState(() => _audioEnabled = !_audioEnabled);
    if (_audioEnabled) {
      await _speakCurrentStep();
    } else {
      await _tts.stop();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      setState(() {
        _totalElapsed++;
        if (_remaining > 0) {
          _remaining--;
        } else {
          _nextStep();
        }
      });
    });
  }

  void _nextStep() {
    if (_stepIndex >= _steps.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _stepIndex++;
      _remaining = _steps[_stepIndex].seconds;
    });
    _speakCurrentStep();
  }

  void _finish() {
    _timer?.cancel();
    _tts.stop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LogbookFormScreen(
          sessionId: widget.sessionId,
          durationSeconds: _totalElapsed,
          distractionScore: _distractionScore,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];
    final progress = (_stepIndex + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Sesi Latihan Aktif')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'LANGKAH ${_stepIndex + 1} DARI ${_steps.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE4E5E3),
                            color: AppTheme.olive,
                          ),
                        ),
                        const SizedBox(height: 26),
                        SoftCard(
                          child: Row(
                            children: [
                              MindfulAvatar(
                                assetName: step.avatarAsset,
                                size: 74,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.title.replaceFirst(
                                        'Langkah ${_stepIndex + 1}: ',
                                        '',
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(step.instruction),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _TimerRing(label: _format(_remaining)),
                        const SizedBox(height: 28),
                        _ControlBar(
                          paused: _paused,
                          audioEnabled: _audioEnabled,
                          onPause: () => setState(() => _paused = !_paused),
                          onAudio: _toggleAudio,
                          onNext: _nextStep,
                        ),
                        const SizedBox(height: 22),
                        if (step.hasCounter)
                          SoftCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Skor Distraksi',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '$_distractionScore',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      setState(() => _distractionScore++),
                                  child: const Text('+1 Distraksi'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: FilledButton(
                        onPressed: _finish,
                        child: const Text('Selesai Sesi'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.olive, width: 10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, color: AppTheme.muted),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'MENIT • DETIK',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.paused,
    required this.audioEnabled,
    required this.onPause,
    required this.onAudio,
    required this.onNext,
  });

  final bool paused;
  final bool audioEnabled;
  final VoidCallback onPause;
  final VoidCallback onAudio;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          _ControlButton(
            icon: paused ? Icons.play_arrow : Icons.pause,
            label: paused ? 'Lanjut' : 'Jeda',
            onTap: onPause,
          ),
          _ControlButton(
            icon: audioEnabled ? Icons.volume_up : Icons.volume_off_outlined,
            label: 'Suara',
            onTap: onAudio,
          ),
          _ControlButton(
            icon: Icons.play_circle_fill,
            label: 'Berikutnya',
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.ink),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
