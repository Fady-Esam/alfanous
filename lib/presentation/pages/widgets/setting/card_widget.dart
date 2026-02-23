import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const CardWidget({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      padding: padding,
      child: child,
    );
  }
}
