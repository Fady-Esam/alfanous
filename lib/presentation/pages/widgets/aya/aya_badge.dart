import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';


class AyaBadge extends StatelessWidget {
  final int number;
  final bool highlighted;
  const AyaBadge({super.key, required this.number, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: highlighted
              ? [const Color(0xFFD4AF37), const Color(0xFF8B6914)]
              : [const Color(0xFF2A3D55), const Color(0xFF1A2840)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: highlighted
            ? [BoxShadow(color: AppColors.accent.withAlpha(77), blurRadius: 8)]
            : [],
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: highlighted ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
