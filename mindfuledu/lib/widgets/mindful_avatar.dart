import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class MindfulAvatar extends StatelessWidget {
  const MindfulAvatar({
    super.key,
    required this.assetName,
    this.size = 180,
    this.icon = Icons.self_improvement,
  });

  final String assetName;
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        'assets/images/mindfulness/$assetName',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFEDE8DC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.line),
          ),
          child: Icon(icon, size: size * 0.42, color: AppTheme.moss),
        ),
      ),
    );
  }
}
