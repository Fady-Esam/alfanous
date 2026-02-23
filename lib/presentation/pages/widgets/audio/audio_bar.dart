import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../cubit/audio_cubit/audio_cubit.dart';
import '../../../cubit/audio_cubit/audio_states.dart';
import 'audio_button.dart';
import 'audio_status.dart';

class AudioBar extends StatelessWidget {
  final int sura;
  final int ayaId;
  const AudioBar({super.key, required this.sura, required this.ayaId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioCubit, AudioState>(
      // Only listen to error transitions — show a SnackBar on error.
      listenWhen: (_, curr) => curr is AudioError,
      listener: (context, state) {
        if (state is AudioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(),
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, audioState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Left: audio control button
              AudioButton(audioState: audioState),
              const SizedBox(width: 10),
              // Right: status text / progress bar
              Expanded(child: AudioStatus(audioState: audioState)),
            ],
          ),
        );
      },
    );
  }
}
