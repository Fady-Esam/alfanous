import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/aya_model.dart';
import '../../../cubit/audio_cubit/audio_cubit.dart';
import 'card_body.dart';

class AyahCardWidget extends StatelessWidget {
  final AyaModel aya;

  final List<String> highlightTerms;

  final bool isHighlight;

  const AyahCardWidget({
    super.key,
    required this.aya,
    this.highlightTerms = const [],
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AudioCubit>(
      create: (_) =>
          AudioCubit(sura: aya.suraId, aya: aya.ayaId)..checkDownloaded(),
      child: CardBody(
        aya: aya,
        highlightTerms: highlightTerms,
        isHighlight: isHighlight,
      ),
    );
  }
}
