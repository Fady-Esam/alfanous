
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/quran_repository.dart';
import '../cubit/surah_cubit/surah_cubit.dart';
import 'widgets/surah/surah_view.dart';


class SurahPage extends StatelessWidget {
  final int suraId;
  final String suraName;
  final int? highlightAyaId;
  final String searchQuery;

  const SurahPage({
    super.key,
    required this.suraId,
    required this.suraName,
    this.highlightAyaId,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<QuranRepository>();
    return BlocProvider<SurahCubit>(
      create: (_) => SurahCubit(repository: repo)..loadSurah(suraId),
      child: SurahView(
        suraId: suraId,
        suraName: suraName,
        highlightAyaId: highlightAyaId,
        searchQuery: searchQuery,
      ),
    );
  }
}



