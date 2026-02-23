import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../cubit/audio_cubit/audio_states.dart';

class AudioStatus extends StatelessWidget {
  final AudioState audioState;
  const AudioStatus({super.key, required this.audioState});

  @override
  Widget build(BuildContext context) {
    return switch (audioState) {
      AudioIdle(isDownloaded: false) => Text(
        'اضغط لتحميل الصوت',
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(color: AppColors.textSecondary, fontSize: 12),
      ),
      AudioIdle(isDownloaded: true) => Text(
        'محمّل — جاهز للتشغيل',
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(color: AppColors.accent, fontSize: 12),
      ),
      AudioDownloading(:final progress) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'جارٍ التحميل… ${(progress * 100).toInt()}٪',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
      AudioPlaying() => Text(
        '▶ جارٍ التشغيل',
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(color: AppColors.accent, fontSize: 12),
      ),
      AudioPaused() => Text(
        '⏸ متوقف مؤقتاً',
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(color: AppColors.textSecondary, fontSize: 12),
      ),
      AudioError(:final message) => Text(
        message,
        textDirection: TextDirection.rtl,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.amiri(color: AppColors.error, fontSize: 11),
      ),
    };
  }
}
