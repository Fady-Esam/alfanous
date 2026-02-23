import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../cubit/audio_cubit/audio_cubit.dart';
import '../../../cubit/audio_cubit/audio_states.dart';
import 'icon_btn.dart';

class AudioButton extends StatelessWidget {
  final AudioState audioState;
  const AudioButton({super.key, required this.audioState});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AudioCubit>();

    return switch (audioState) {
      // ── Not downloaded yet / cancelled ──────────────────────────────
      AudioIdle(isDownloaded: false) => IconBtn(
        icon: Icons.download_rounded,
        tooltip: 'تحميل للتشغيل دون إنترنت',
        onTap: cubit.download,
      ),

      // ── Downloaded, not playing ──────────────────────────────────────
      AudioIdle(isDownloaded: true) => IconBtn(
        icon: Icons.play_circle_filled_rounded,
        tooltip: 'تشغيل (محلي)',
        color: AppColors.accent,
        onTap: cubit.play,
      ),

      // ── Downloading in progress — show cancel ────────────────────────
      AudioDownloading() => IconBtn(
        icon: Icons.cancel_outlined,
        tooltip: 'إلغاء التحميل',
        color: AppColors.textSecondary,
        onTap: cubit.cancelDownload,
      ),

      // ── Playing ──────────────────────────────────────────────────────
      AudioPlaying() => IconBtn(
        icon: Icons.stop_circle_rounded,
        tooltip: 'إيقاف',
        color: AppColors.accent,
        onTap: cubit.stop,
      ),

      // ── Paused ───────────────────────────────────────────────────────
      AudioPaused() => IconBtn(
        icon: Icons.play_circle_filled_rounded,
        tooltip: 'استئناف',
        color: AppColors.accent,
        onTap: cubit.resume,
      ),

      // ── Error — retry ────────────────────────────────────────────────
      AudioError() => IconBtn(
        icon: Icons.refresh_rounded,
        tooltip: 'إعادة المحاولة',
        color: AppColors.error,
        onTap: cubit.checkDownloaded,
      ),
    };
  }
}
