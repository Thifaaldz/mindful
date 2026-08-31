import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/app_theme.dart';
import '../../widgets/app_chrome.dart';

class KabatZinnPracticeScreen extends StatefulWidget {
  const KabatZinnPracticeScreen({super.key, required this.snapshot});

  final Map<String, dynamic> snapshot;

  @override
  State<KabatZinnPracticeScreen> createState() =>
      _KabatZinnPracticeScreenState();
}

class _KabatZinnPracticeScreenState extends State<KabatZinnPracticeScreen>
    with SingleTickerProviderStateMixin {
  late _PracticeMethod _method;
  late int _remainingSeconds;
  late List<int> _stepDurations;
  late int _stepRemainingSeconds;
  late final AnimationController _animation;
  late final FlutterTts _tts;
  Timer? _timer;
  bool _running = false;
  bool _started = false;
  bool _ttsEnabled = true;
  int _activeStep = 0;

  @override
  void initState() {
    super.initState();
    _method = _methodForSnapshot(widget.snapshot);
    _remainingSeconds = _method.duration.inSeconds;
    _stepDurations = _buildStepDurations(_method);
    _stepRemainingSeconds = _stepDurations.first;
    _tts = FlutterTts();
    unawaited(_configureTts());
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_tts.stop());
    _animation.dispose();
    super.dispose();
  }

  Future<void> _configureTts() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1);
      await _tts.awaitSpeakCompletion(false);
    } catch (_) {
      if (mounted) setState(() => _ttsEnabled = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running || !mounted) return;
      if (_remainingSeconds <= 1) {
        setState(() {
          _remainingSeconds = 0;
          _stepRemainingSeconds = 0;
        });
        _showEvaluation();
        return;
      }
      if (_stepRemainingSeconds <= 1) {
        _goToStep(_activeStep + 1, fromTimer: true);
        return;
      }
      setState(() {
        _remainingSeconds--;
        _stepRemainingSeconds--;
      });
    });
  }

  void _setMethod(_PracticeMethod method) {
    _timer?.cancel();
    unawaited(_tts.stop());
    setState(() {
      _method = method;
      _stepDurations = _buildStepDurations(method);
      _remainingSeconds = method.duration.inSeconds;
      _stepRemainingSeconds = _stepDurations.first;
      _activeStep = 0;
      _running = false;
      _started = false;
    });
  }

  void _reset() {
    _timer?.cancel();
    unawaited(_tts.stop());
    setState(() {
      _remainingSeconds = _method.duration.inSeconds;
      _stepRemainingSeconds = _stepDurations.first;
      _activeStep = 0;
      _running = false;
      _started = false;
    });
  }

  void _startPractice() {
    setState(() {
      _started = true;
      _running = true;
      _activeStep = 0;
      _remainingSeconds = _method.duration.inSeconds;
      _stepRemainingSeconds = _stepDurations.first;
    });
    _speakCurrentStep();
    _startTimer();
  }

  Future<void> _showEvaluation() async {
    _timer?.cancel();
    await _tts.stop();
    if (!mounted) return;
    setState(() => _running = false);

    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _EvaluationSheet(
        onSelected: (value) => Navigator.of(sheetContext).pop(value),
      ),
    );
    if (!mounted || result == null) return;

    Navigator.of(context).pop(result);
  }

  String _formatTime() {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatStepTime() {
    final minutes = (_stepRemainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_stepRemainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  int _remainingFromStep(int step) {
    if (_stepDurations.isEmpty) return 0;
    return _stepDurations.skip(step).fold(0, (total, value) => total + value);
  }

  void _goToStep(int step, {bool fromTimer = false}) {
    if (step < 0) return;
    if (step >= _method.steps.length) {
      setState(() {
        _remainingSeconds = 0;
        _stepRemainingSeconds = 0;
      });
      _showEvaluation();
      return;
    }

    setState(() {
      _activeStep = step;
      _stepRemainingSeconds = _stepDurations[step];
      _remainingSeconds = _remainingFromStep(step);
    });
    _speakCurrentStep(fromTimer: fromTimer);
  }

  Future<void> _speakCurrentStep({bool fromTimer = false}) async {
    if (!_ttsEnabled || _method.steps.isEmpty) return;

    final cue = fromTimer
        ? 'Waktunya lanjut ke langkah ${_activeStep + 1}.'
        : 'Langkah ${_activeStep + 1} dari ${_method.steps.length}.';
    await _tts.stop();
    await _tts.speak('$cue ${_method.steps[_activeStep]}');
  }

  void _toggleTts() {
    setState(() => _ttsEnabled = !_ttsEnabled);
    if (_ttsEnabled && _started) {
      _speakCurrentStep();
    } else {
      unawaited(_tts.stop());
    }
  }

  void _toggleRunning() {
    setState(() => _running = !_running);
    if (_running) {
      _speakCurrentStep();
    } else {
      unawaited(_tts.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = '${widget.snapshot['category'] ?? 'belum cukup'}';
    final color = _categoryColor(category);
    final fromToolkit = widget.snapshot['source'] == 'toolkit';
    final elapsed =
        _method.duration.inSeconds - _remainingSeconds.clamp(0, 999999);
    final progress = (_method.duration.inSeconds == 0)
        ? 0.0
        : (elapsed / _method.duration.inSeconds).clamp(0.0, 1.0);
    final activeStep = _method.steps.isEmpty
        ? 0
        : _activeStep.clamp(0, _method.steps.length - 1).toInt();
    final stepProgress = _stepDurations.isEmpty
        ? 0.0
        : (1 -
                  (_stepRemainingSeconds /
                      math.max(1, _stepDurations[activeStep])))
              .clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan Mindfulness'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Row(
              children: [
                StatusPill(
                  label: fromToolkit ? 'TOOLKIT' : 'REKOMENDASI',
                  color: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fromToolkit
                        ? 'Kenali dulu tekniknya, lalu mulai saat siap.'
                        : 'Dipilih dari jurnal dan kondisi aktivitas terakhir.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              _method.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(_method.reason, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            if (!_started) ...[
              _KnowledgeCard(method: _method, onStart: _startPractice),
              const SizedBox(height: 20),
            ] else ...[
              _AnimatedPractice(
                animation: _animation,
                method: _method,
                activeStep: activeStep,
              ),
              const SizedBox(height: 20),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatTime(),
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        StatusPill(
                          label: _running ? 'BERJALAN' : 'JEDA',
                          color: _running ? AppTheme.olive : AppTheme.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE4E5E3),
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _toggleRunning,
                            icon: Icon(
                              _running ? Icons.pause : Icons.play_arrow,
                            ),
                            label: Text(_running ? 'Jeda' : 'Lanjut'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _showEvaluation,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Selesai'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _StepGuideCard(
                steps: _method.steps,
                activeStep: activeStep,
                stepTime: _formatStepTime(),
                stepProgress: stepProgress,
                ttsEnabled: _ttsEnabled,
                onPrevious: activeStep == 0
                    ? null
                    : () => _goToStep(activeStep - 1),
                onNext: activeStep == _method.steps.length - 1
                    ? null
                    : () => _goToStep(activeStep + 1),
                onReplay: _speakCurrentStep,
                onToggleTts: _toggleTts,
              ),
              const SizedBox(height: 18),
            ],
            _AlternativesCard(
              methods: _alternativesForSnapshot(widget.snapshot),
              selected: _method,
              onSelected: _setMethod,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPractice extends StatelessWidget {
  const _AnimatedPractice({
    required this.animation,
    required this.method,
    required this.activeStep,
  });

  final Animation<double> animation;
  final _PracticeMethod method;
  final int activeStep;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final pulse = Curves.easeInOut.transform(animation.value);
          final isBodyScan = method.kind == _PracticeKind.bodyScan;

          return Column(
            children: [
              SizedBox(
                height: 210,
                child: Center(
                  child: isBodyScan
                      ? _BodyScanFigure(activeStep: activeStep)
                      : _PersonPracticeFigure(
                          value: pulse,
                          icon: method.icon,
                          kind: method.kind,
                          activeStep: activeStep,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                method.animationCue(pulse),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PersonPracticeFigure extends StatelessWidget {
  const _PersonPracticeFigure({
    required this.value,
    required this.icon,
    required this.kind,
    required this.activeStep,
  });

  final double value;
  final IconData icon;
  final _PracticeKind kind;
  final int activeStep;

  @override
  Widget build(BuildContext context) {
    final sway = math.sin(value * math.pi * 2);
    final stepTone = _stepTone(activeStep);
    final stepPhase = activeStep % 4;
    final breathScale = 1 + value * 0.08;
    final walkOffset = kind == _PracticeKind.walking ? sway * 22 : 0.0;
    final armLift = kind == _PracticeKind.movement
        ? 18 + value * 24
        : 8.0 + stepPhase * 5;
    final bodyColor = kind == _PracticeKind.lovingKindness
        ? const Color(0xFFB76E79)
        : kind == _PracticeKind.grounding
        ? const Color(0xFF24718E)
        : stepTone;

    return Transform.translate(
      offset: Offset(walkOffset, 0),
      child: Transform.scale(
        scale:
            kind == _PracticeKind.breathing ||
                kind == _PracticeKind.breathing478
            ? breathScale
            : 1,
        child: SizedBox(
          width: 180,
          height: 190,
          child: CustomPaint(
            painter: _PersonPainter(
              pulse: value,
              armLift: armLift,
              bodyColor: bodyColor,
              kind: kind,
              activeStep: activeStep,
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: Icon(icon, color: bodyColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonPainter extends CustomPainter {
  const _PersonPainter({
    required this.pulse,
    required this.armLift,
    required this.bodyColor,
    required this.kind,
    required this.activeStep,
  });

  final double pulse;
  final double armLift;
  final Color bodyColor;
  final _PracticeKind kind;
  final int activeStep;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stepPhase = activeStep % 4;
    final paint = Paint()
      ..color = bodyColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = AppTheme.mint
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center.translate(0, 52), 56, fill);
    final headOffset = Offset(
      stepPhase == 1
          ? -3
          : stepPhase == 2
          ? 3
          : 0,
      0,
    );
    canvas.drawCircle(
      center.translate(headOffset.dx, -50),
      24,
      Paint()..color = bodyColor,
    );
    canvas.drawLine(
      center.translate(0, -20),
      center.translate(stepPhase == 3 ? 4 : 0, 52),
      paint,
    );
    canvas.drawLine(
      center.translate(0, 4),
      center.translate(-42, -armLift - stepPhase * 2),
      paint,
    );
    canvas.drawLine(
      center.translate(0, 4),
      center.translate(42, -armLift + stepPhase * 2),
      paint,
    );

    final step = kind == _PracticeKind.walking
        ? math.sin(pulse * math.pi) * 18
        : 0.0;
    canvas.drawLine(
      center.translate(0, 52),
      center.translate(-30, 104 + step),
      paint,
    );
    canvas.drawLine(
      center.translate(0, 52),
      center.translate(30, 104 - step),
      paint,
    );

    final haloPaint = Paint()
      ..color = bodyColor.withValues(alpha: 0.08 + pulse * 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center.translate((stepPhase - 1.5) * 18, -78 + stepPhase * 10),
      18 + pulse * 8,
      haloPaint,
    );

    if (kind == _PracticeKind.breathing ||
        kind == _PracticeKind.breathing478 ||
        kind == _PracticeKind.grounding) {
      final ring = Paint()
        ..color = bodyColor.withValues(alpha: 0.22)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center.translate(0, 18), 36 + pulse * 18, ring);
    }

    if (kind == _PracticeKind.journaling) {
      final notePaint = Paint()..color = Colors.white;
      final lineCount = (activeStep + 1).clamp(1, 5);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(54, 36),
          width: 46,
          height: 56,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, notePaint);
      final noteStroke = Paint()
        ..color = bodyColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3;
      for (var i = 0; i < lineCount; i++) {
        final y = 18 + i * 8.0;
        canvas.drawLine(
          center.translate(40, y),
          center.translate(68 - (i.isOdd ? 8 : 0), y),
          noteStroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PersonPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.armLift != armLift ||
        oldDelegate.bodyColor != bodyColor ||
        oldDelegate.kind != kind ||
        oldDelegate.activeStep != activeStep;
  }
}

class _BodyScanFigure extends StatelessWidget {
  const _BodyScanFigure({required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    final labels = ['Kepala', 'Bahu', 'Dada', 'Perut', 'Kaki'];
    final active = activeStep.clamp(0, labels.length - 1);

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(170, 180),
            painter: _BodyScanPainter(activeIndex: active),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.olive,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                labels[active],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyScanPainter extends CustomPainter {
  const _BodyScanPainter({required this.activeIndex});

  final int activeIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..color = AppTheme.olive
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    final highlight = Paint()
      ..color = const Color(0xFFD99B3D).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final highlightCenters = [
      center.translate(0, -58),
      center.translate(0, -22),
      center.translate(0, 10),
      center.translate(0, 42),
      center.translate(0, 82),
    ];
    final highlightSizes = [26.0, 36.0, 42.0, 42.0, 46.0];
    canvas.drawCircle(
      highlightCenters[activeIndex],
      highlightSizes[activeIndex],
      highlight,
    );

    canvas.drawCircle(
      center.translate(0, -58),
      22,
      Paint()..color = AppTheme.olive,
    );
    canvas.drawLine(center.translate(0, -32), center.translate(0, 54), stroke);
    canvas.drawLine(center.translate(0, -4), center.translate(-38, 28), stroke);
    canvas.drawLine(center.translate(0, -4), center.translate(38, 28), stroke);
    canvas.drawLine(
      center.translate(0, 54),
      center.translate(-30, 112),
      stroke,
    );
    canvas.drawLine(center.translate(0, 54), center.translate(30, 112), stroke);
  }

  @override
  bool shouldRepaint(covariant _BodyScanPainter oldDelegate) {
    return oldDelegate.activeIndex != activeIndex;
  }
}

class _StepGuideCard extends StatelessWidget {
  const _StepGuideCard({
    required this.steps,
    required this.activeStep,
    required this.stepTime,
    required this.stepProgress,
    required this.ttsEnabled,
    required this.onPrevious,
    required this.onNext,
    required this.onReplay,
    required this.onToggleTts,
  });

  final List<String> steps;
  final int activeStep;
  final String stepTime;
  final double stepProgress;
  final bool ttsEnabled;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onReplay;
  final VoidCallback onToggleTts;

  @override
  Widget build(BuildContext context) {
    final step = steps.isEmpty ? '' : steps[activeStep];

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Langkah ${activeStep + 1} dari ${steps.length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton.filledTonal(
                tooltip: ttsEnabled ? 'Matikan suara' : 'Aktifkan suara',
                onPressed: onToggleTts,
                icon: Icon(
                  ttsEnabled ? Icons.volume_up : Icons.volume_off_outlined,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Ulangi suara',
                onPressed: ttsEnabled ? onReplay : null,
                icon: const Icon(Icons.record_voice_over_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.line),
            ),
            child: Text(
              step,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: stepProgress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE4E5E3),
                    color: AppTheme.olive,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                stepTime,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.olive,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Lanjut'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlternativesCard extends StatelessWidget {
  const _AlternativesCard({
    required this.methods,
    required this.selected,
    required this.onSelected,
  });

  final List<_PracticeMethod> methods;
  final _PracticeMethod selected;
  final ValueChanged<_PracticeMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilihan latihan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final method in methods)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(method.icon, color: AppTheme.olive),
                title: Text(method.title),
                subtitle: Text('${method.duration.inMinutes} menit'),
                trailing: selected.title == method.title
                    ? const Icon(Icons.check_circle, color: AppTheme.olive)
                    : const Icon(Icons.chevron_right),
                onTap: () => onSelected(method),
              ),
            ),
        ],
      ),
    );
  }
}

class _EvaluationSheet extends StatelessWidget {
  const _EvaluationSheet({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const options = [
      'Jauh lebih baik',
      'Lebih baik',
      'Tidak berubah',
      'Masih lelah',
      'Lebih buruk',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bagaimana kondisi Anda setelah latihan?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final option in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => onSelected(option),
                  child: Text(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  const _KnowledgeCard({required this.method, required this.onStart});

  final _PracticeMethod method;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.mint,
                child: Icon(method.icon, color: AppTheme.olive),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kenali teknik',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(method.knowledge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Mulai'),
          ),
        ],
      ),
    );
  }
}

enum _PracticeKind {
  breathing,
  breathing478,
  bodyScan,
  walking,
  movement,
  lovingKindness,
  stop,
  grounding,
  journaling,
}

class _PracticeMethod {
  const _PracticeMethod({
    required this.title,
    required this.duration,
    required this.kind,
    required this.icon,
    required this.reason,
    required this.knowledge,
    required this.steps,
  });

  final String title;
  final Duration duration;
  final _PracticeKind kind;
  final IconData icon;
  final String reason;
  final String knowledge;
  final List<String> steps;

  _PracticeMethod copyWith({
    String? title,
    Duration? duration,
    _PracticeKind? kind,
    IconData? icon,
    String? reason,
    String? knowledge,
    List<String>? steps,
  }) {
    return _PracticeMethod(
      title: title ?? this.title,
      duration: duration ?? this.duration,
      kind: kind ?? this.kind,
      icon: icon ?? this.icon,
      reason: reason ?? this.reason,
      knowledge: knowledge ?? this.knowledge,
      steps: steps ?? this.steps,
    );
  }

  String animationCue(double value) {
    if (kind == _PracticeKind.stop) {
      return value < 0.5
          ? 'Berhenti sejenak sebelum merespons.'
          : 'Amati tubuh, pikiran, dan emosi.';
    }
    if (kind == _PracticeKind.grounding) {
      return value < 0.5
          ? 'Lihat, dengar, dan rasakan sekitar.'
          : 'Biarkan tubuh kembali ke saat ini.';
    }
    if (kind == _PracticeKind.breathing478) {
      return value < 0.33
          ? 'Tarik napas 4 hitungan.'
          : value < 0.66
          ? 'Tahan lembut 7 hitungan.'
          : 'Buang napas 8 hitungan.';
    }
    if (kind == _PracticeKind.bodyScan) {
      return 'Arahkan perhatian perlahan pada bagian tubuh yang aktif.';
    }
    if (kind == _PracticeKind.walking) {
      return value < 0.5
          ? 'Rasakan langkah dan kontak kaki dengan lantai.'
          : 'Sadari napas dan lingkungan sekitar.';
    }
    if (kind == _PracticeKind.movement) {
      return value < 0.5
          ? 'Gerakkan tubuh dengan lembut mengikuti napas.'
          : 'Rasakan area yang tegang tanpa memaksa.';
    }
    if (kind == _PracticeKind.lovingKindness) {
      return value < 0.5
          ? 'Tarik napas, beri ruang untuk diri sendiri.'
          : 'Ucapkan niat baik dengan lembut.';
    }
    if (kind == _PracticeKind.journaling) {
      return value < 0.5
          ? 'Tulis pengalaman apa adanya.'
          : 'Cari pola kecil yang bisa dirawat.';
    }

    return value < 0.5 ? 'Tarik napas perlahan.' : 'Hembuskan napas perlahan.';
  }
}

_PracticeMethod _methodForSnapshot(Map<String, dynamic> snapshot) {
  final tactic = _mapOrNull(snapshot['tactic']);
  if (tactic != null) {
    return _methodFromTactic(tactic);
  }

  final code = _practiceCode(snapshot);
  if (code != null) {
    return _methodForCode(code);
  }

  final category = '${snapshot['category'] ?? ''}';
  final factors = (snapshot['dominant_factors'] as List? ?? [])
      .map((item) => '$item')
      .toSet();

  if (category == 'merah') {
    if (factors.contains('crisis_flag')) return _breathing(3);
    if (factors.contains('journal_pressure_terms')) return _sitting(10);
    if (factors.contains('checkout_negative_mood')) {
      return _bodyScan(15, high: true);
    }
    return _bodyScan(15, high: true);
  }

  if (category == 'kuning') {
    if (factors.contains('journal_pressure_terms')) return _sitting(7);
    if (factors.contains('checkout_negative_mood')) return _bodyScan(10);
    return _bodyScan(10);
  }

  return _breathing(3);
}

List<_PracticeMethod> _alternativesForSnapshot(Map<String, dynamic> snapshot) {
  final category = '${snapshot['category'] ?? ''}';
  if (category == 'merah') {
    return [
      _bodyScan(15, high: true),
      _sitting(10),
      _movement(10),
      _kindness(7),
    ];
  }
  if (category == 'kuning') {
    return [_bodyScan(10), _sitting(7), _walking(5), _movement(5)];
  }
  return [_breathing(3), _informal(3), _walking(5)];
}

Map<String, dynamic>? _mapOrNull(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return null;
}

String? _practiceCode(Map<String, dynamic> snapshot) {
  final direct = snapshot['practice_code'];
  if (direct != null && '$direct'.isNotEmpty) return '$direct';

  final recommendation = _mapOrNull(snapshot['recommendation_summary']);
  final fromRecommendation = recommendation?['practice_code'];
  if (fromRecommendation != null && '$fromRecommendation'.isNotEmpty) {
    return '$fromRecommendation';
  }

  return null;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => '$item')
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const [];
}

int _intValue(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? fallback;
}

String _textValue(dynamic value, String fallback) {
  final text = '${value ?? ''}'.trim();
  return text.isEmpty ? fallback : text;
}

List<int> _buildStepDurations(_PracticeMethod method) {
  final count = math.max(1, method.steps.length);
  final totalSeconds = math.max(count, method.duration.inSeconds);
  final baseSeconds = totalSeconds ~/ count;
  final extraSeconds = totalSeconds % count;

  return List.generate(
    count,
    (index) => baseSeconds + (index < extraSeconds ? 1 : 0),
  );
}

_PracticeMethod _methodFromTactic(Map<String, dynamic> tactic) {
  final fallback = _methodForCode('${tactic['category'] ?? ''}');
  final steps = _stringList(tactic['steps']);

  return fallback.copyWith(
    title: _textValue(tactic['title'], fallback.title),
    duration: Duration(
      minutes: _intValue(
        tactic['duration_minutes'],
        fallback.duration.inMinutes,
      ),
    ),
    reason: _textValue(tactic['description'], fallback.reason),
    knowledge: _textValue(tactic['knowledge'], fallback.knowledge),
    steps: steps.isEmpty ? fallback.steps : steps,
  );
}

_PracticeMethod _methodForCode(String code) {
  return switch (code) {
    'stop_technique' => _stop(),
    'grounding_321' => _grounding(),
    'breathing_478' => _breathing478(),
    'breathing_space_3min' => _breathingSpace(),
    'maintain_breath_awareness' => _awareness(),
    'sitting_meditation' => _sitting(10),
    'body_scan_micro' => _bodyScan(10),
    'body_scan_full' => _bodyScan(20, high: true),
    'mindful_movement' => _movement(10),
    'walking_meditation' => _walking(5),
    'rain_self_compassion' => _rain(),
    'loving_kindness' => _kindness(7),
    'reflective_journal' => _journal(),
    _ => _breathing(3),
  };
}

_PracticeMethod _breathing(int minutes) {
  return _PracticeMethod(
    title: 'Mindful Breathing',
    duration: Duration(minutes: minutes),
    kind: _PracticeKind.breathing,
    icon: Icons.air,
    reason:
        'Cocok untuk burnout rendah atau saat butuh menjaga fokus sebelum aktivitas berikutnya.',
    knowledge:
        'Latihan napas sadar membantu perhatian kembali ke tubuh. Tujuannya bukan mengosongkan pikiran, tetapi menyadari napas lalu kembali dengan lembut saat terdistraksi.',
    steps: const [
      'Duduk nyaman dan biarkan bahu lebih rileks.',
      'Perhatikan napas masuk secara alami.',
      'Perhatikan napas keluar secara alami.',
      'Saat pikiran berpindah, sadari lalu kembali ke napas.',
      'Akhiri dengan satu niat baik untuk aktivitas berikutnya.',
    ],
  );
}

_PracticeMethod _breathingSpace() {
  return _PracticeMethod(
    title: 'Jeda Napas 3 Menit',
    duration: const Duration(minutes: 3),
    kind: _PracticeKind.breathing,
    icon: Icons.hourglass_bottom,
    reason:
        'Cocok sebagai transisi pendek sebelum atau setelah aktivitas yang menguras perhatian.',
    knowledge:
        '3-Minute Breathing Space membantu pengguna berhenti sebentar, mengenali kondisi, lalu memperluas kesadaran tubuh sebelum melanjutkan aktivitas.',
    steps: const [
      'Menit pertama: sadari apa yang sedang dirasakan.',
      'Menit kedua: fokus pada napas masuk dan keluar.',
      'Menit ketiga: perluas perhatian ke seluruh tubuh.',
      'Tutup dengan satu niat sederhana.',
    ],
  );
}

_PracticeMethod _awareness() {
  return _PracticeMethod(
    title: 'Awareness of Breathing',
    duration: const Duration(minutes: 3),
    kind: _PracticeKind.breathing,
    icon: Icons.spa_outlined,
    reason:
        'Cocok untuk menjaga fokus dan menstabilkan ritme sebelum masuk aktivitas berikutnya.',
    knowledge:
        'Awareness of Breathing melatih hadir pada napas natural tanpa mengubahnya. Saat perhatian berpindah, pengguna cukup sadar lalu kembali.',
    steps: const [
      'Duduk stabil dengan punggung nyaman.',
      'Rasakan napas masuk sebagaimana adanya.',
      'Rasakan napas keluar sebagaimana adanya.',
      'Saat terdistraksi, sadari lalu kembali ke napas.',
      'Akhiri dengan satu napas panjang.',
    ],
  );
}

_PracticeMethod _informal(int minutes) {
  return _PracticeMethod(
    title: 'Informal Mindfulness',
    duration: Duration(minutes: minutes),
    kind: _PracticeKind.walking,
    icon: Icons.local_cafe_outlined,
    reason:
        'Cocok saat kondisi masih terkendali dan latihan ingin dibuat ringan dalam aktivitas sehari-hari.',
    knowledge:
        'Informal mindfulness membawa perhatian penuh ke aktivitas sederhana. Ini berguna ketika pengguna tidak punya banyak waktu tetapi tetap butuh kembali hadir.',
    steps: const [
      'Pilih aktivitas sederhana seperti minum, duduk, atau berjalan.',
      'Turunkan tempo dan lepaskan dorongan membuka ponsel.',
      'Sadari napas, gerak tubuh, dan lingkungan sekitar.',
      'Kembali ke aktivitas dengan perhatian yang lebih utuh.',
    ],
  );
}

_PracticeMethod _walking(int minutes) {
  return _PracticeMethod(
    title: 'Walking Meditation',
    duration: Duration(minutes: minutes),
    kind: _PracticeKind.walking,
    icon: Icons.directions_walk,
    reason:
        'Cocok setelah aktivitas berat, terlalu lama duduk, atau saat butuh jeda aktif.',
    knowledge:
        'Walking meditation memakai langkah sebagai jangkar perhatian. Latihan ini membantu tubuh bergerak pelan tanpa kehilangan kesadaran pada napas dan lingkungan.',
    steps: const [
      'Berdiri dan pilih jalur pendek yang aman.',
      'Berjalan perlahan sambil merasakan telapak kaki.',
      'Sadari gerakan tubuh dan napas.',
      'Perhatikan lingkungan tanpa buru-buru menilai.',
      'Berhenti sejenak sebelum kembali bekerja.',
    ],
  );
}

_PracticeMethod _bodyScan(int minutes, {bool high = false}) {
  return _PracticeMethod(
    title: 'Body Scan Meditation',
    duration: Duration(minutes: minutes),
    kind: _PracticeKind.bodyScan,
    icon: Icons.accessibility_new,
    reason: high
        ? 'Sangat direkomendasikan saat burnout tinggi karena tubuh perlu ruang pemulihan lebih panjang.'
        : 'Direkomendasikan saat burnout sedang untuk membaca ketegangan tubuh dan memberi jeda pemulihan.',
    knowledge:
        'Body scan membantu membaca sinyal tubuh yang sering terlewat saat aktivitas padat. Pengguna diajak mengenali sensasi tanpa menghakimi atau memaksa tubuh cepat rileks.',
    steps: const [
      'Cari posisi duduk atau berbaring yang nyaman.',
      'Mulai dari napas dan biarkan tubuh menetap.',
      'Sadari kepala, wajah, leher, dan bahu.',
      'Sadari tangan, dada, perut, dan pinggang.',
      'Sadari kaki lalu tubuh secara keseluruhan.',
      'Biarkan sensasi hadir tanpa harus langsung bereaksi.',
    ],
  );
}

_PracticeMethod _sitting(int minutes) {
  return _PracticeMethod(
    title: 'Sitting Meditation',
    duration: Duration(minutes: minutes),
    kind: _PracticeKind.breathing,
    icon: Icons.self_improvement,
    reason:
        'Cocok ketika stres, banyak pikiran, atau rasa kewalahan mulai meningkat.',
    knowledge:
        'Sitting meditation melatih pengguna menyadari napas, suara, tubuh, pikiran, dan emosi. Latihan ini menguatkan sikap menerima pengalaman tanpa langsung bereaksi.',
    steps: const [
      'Duduk stabil dengan punggung nyaman.',
      'Letakkan perhatian pada napas.',
      'Sadari tubuh, suara, pikiran, dan emosi yang muncul.',
      'Jika perhatian berpindah, kembali pada napas.',
      'Akhiri dengan sikap lembut pada diri sendiri.',
    ],
  );
}

_PracticeMethod _movement(int minutes) {
  return _PracticeMethod(
    title: 'Mindful Movement',
    duration: Duration(minutes: minutes),
    kind: _PracticeKind.movement,
    icon: Icons.accessibility,
    reason:
        'Cocok saat jurnal menunjukkan usaha tinggi, badan pegal, atau duduk terlalu lama.',
    knowledge:
        'Mindful movement adalah peregangan ringan yang dilakukan pelan. Fokusnya bukan performa, tetapi merasakan gerak, napas, dan batas nyaman tubuh.',
    steps: const [
      'Berdiri atau duduk dengan ruang gerak yang aman.',
      'Gerakkan bahu, leher, tangan, dan punggung perlahan.',
      'Sinkronkan gerakan dengan napas.',
      'Berhenti bila ada rasa tidak nyaman.',
      'Rasakan tubuh sebelum melanjutkan aktivitas.',
    ],
  );
}

_PracticeMethod _kindness(int minutes) {
  return _PracticeMethod(
    title: 'Loving-Kindness Meditation',
    duration: Duration(minutes: minutes),
    kind: _PracticeKind.lovingKindness,
    icon: Icons.favorite_border,
    reason:
        'Cocok saat tekanan emosional tinggi, frustrasi, konflik, atau merasa terbebani.',
    knowledge:
        'Loving-kindness membantu melatih kalimat baik untuk diri sendiri dan orang lain. Latihan ini berguna saat pengguna keras pada diri sendiri atau merasa gagal.',
    steps: const [
      'Duduk nyaman dan sadari napas.',
      'Arahkan kalimat baik kepada diri sendiri.',
      'Akui beban yang sedang terasa tanpa menghakimi.',
      'Luaskan niat baik pada orang lain bila siap.',
      'Tutup dengan satu tindakan kecil yang menenangkan.',
    ],
  );
}

_PracticeMethod _stop() {
  return _PracticeMethod(
    title: 'Teknik STOP',
    duration: const Duration(minutes: 2),
    kind: _PracticeKind.stop,
    icon: Icons.pan_tool_alt_outlined,
    reason:
        'Cocok saat emosi naik, ingin bereaksi cepat, atau perlu mengambil keputusan dengan lebih tenang.',
    knowledge:
        'STOP memberi jeda pendek antara pemicu dan respons. Pengguna berhenti, bernapas, mengamati pengalaman saat ini, lalu melanjutkan dengan pilihan yang lebih sadar.',
    steps: const [
      'Stop: hentikan aktivitas sejenak.',
      'Take a breath: tarik dan hembuskan napas perlahan.',
      'Observe: amati tubuh, pikiran, dan emosi.',
      'Proceed: lanjutkan dengan tindakan yang lebih sadar.',
    ],
  );
}

_PracticeMethod _grounding() {
  return _PracticeMethod(
    title: 'Grounding 3-2-1',
    duration: const Duration(minutes: 3),
    kind: _PracticeKind.grounding,
    icon: Icons.touch_app_outlined,
    reason: 'Cocok saat cemas, panik, atau pikiran terasa terlalu penuh.',
    knowledge:
        'Grounding mengajak perhatian kembali ke lingkungan nyata melalui pancaindra. Ini membantu tubuh menetap saat pikiran bergerak terlalu cepat.',
    steps: const [
      'Sebutkan tiga hal yang terlihat di sekitar.',
      'Sebutkan dua suara yang terdengar saat ini.',
      'Sebutkan satu sensasi fisik yang terasa jelas.',
      'Tarik napas pelan dan rasakan tubuh lebih menetap.',
    ],
  );
}

_PracticeMethod _breathing478() {
  return _PracticeMethod(
    title: 'Napas 4-7-8',
    duration: const Duration(minutes: 5),
    kind: _PracticeKind.breathing478,
    icon: Icons.air,
    reason:
        'Cocok untuk cemas, tegang, sulit tidur, atau butuh menurunkan aktivasi tubuh.',
    knowledge:
        'Napas 4-7-8 memakai hembusan lebih panjang untuk memberi sinyal aman pada tubuh. Tarik napas 4 hitungan, tahan 7 hitungan, lalu buang 8 hitungan.',
    steps: const [
      'Duduk nyaman dan rilekskan bahu.',
      'Tarik napas selama 4 hitungan.',
      'Tahan napas lembut selama 7 hitungan.',
      'Hembuskan perlahan selama 8 hitungan.',
      'Ulangi sampai waktu latihan selesai.',
    ],
  );
}

_PracticeMethod _rain() {
  return _PracticeMethod(
    title: 'RAIN',
    duration: const Duration(minutes: 7),
    kind: _PracticeKind.lovingKindness,
    icon: Icons.umbrella_outlined,
    reason:
        'Cocok ketika emosi berat, frustrasi, atau tekanan dari jurnal terasa kuat.',
    knowledge:
        'RAIN berarti Recognize, Allow, Investigate, dan Nurture. Pengguna mengenali emosi, mengizinkannya hadir, merasakan jejaknya di tubuh, lalu merawat diri dengan lembut.',
    steps: const [
      'Recognize: kenali emosi yang sedang muncul.',
      'Allow: izinkan emosi hadir tanpa dilawan.',
      'Investigate: rasakan di bagian tubuh mana emosi itu muncul.',
      'Nurture: beri kalimat baik untuk diri sendiri.',
      'Pilih satu langkah kecil yang aman setelah latihan.',
    ],
  );
}

_PracticeMethod _journal() {
  return _PracticeMethod(
    title: 'Jurnal Reflektif Harian',
    duration: const Duration(minutes: 5),
    kind: _PracticeKind.journaling,
    icon: Icons.edit_note,
    reason:
        'Cocok saat pengguna perlu membaca pola emosi dan beban dari aktivitas harian.',
    knowledge:
        'Jurnal reflektif mengubah pengalaman menjadi informasi yang lebih jelas. Teknik ini membantu rekomendasi berikutnya makin sesuai dengan pola pengguna.',
    steps: const [
      'Tulis satu hal yang paling menguras energi hari ini.',
      'Tulis perasaan yang paling dominan.',
      'Tulis pola yang mulai terlihat.',
      'Tulis satu hal kecil yang bisa dilepaskan atau ditunda.',
      'Tutup dengan rencana lembut untuk besok.',
    ],
  );
}

Color _categoryColor(String category) {
  return switch (category) {
    'merah' => const Color(0xFFC65A4A),
    'kuning' => const Color(0xFFD99B3D),
    'hijau' => AppTheme.olive,
    _ => AppTheme.muted,
  };
}

Color _stepTone(int step) {
  const tones = [
    AppTheme.olive,
    Color(0xFF24718E),
    Color(0xFF8D6B32),
    Color(0xFFB76E79),
  ];

  return tones[step % tones.length];
}
