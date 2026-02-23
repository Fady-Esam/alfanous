import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/quran_repository.dart';
import 'surah_states.dart';

class SurahCubit extends Cubit<SurahState> {
  final QuranRepository _repository;

  SurahCubit({required QuranRepository repository})
    : _repository = repository,
      super(const SurahInitial());

  Future<void> loadSurah(int suraId) async {
    final current = state;
    if (current is SurahLoaded && current.suraId == suraId) return;

    emit(SurahLoading(suraId: suraId));

    try {
      final ayat = await _repository.getSurah(suraId);
      if (!isClosed) emit(SurahLoaded(ayat: ayat, suraId: suraId));
    } catch (e, st) {
      debugPrint('[SurahCubit] loadSurah($suraId) failed: $e\n$st');
      if (!isClosed) {
        emit(
          SurahError(
            message: 'فشل تحميل السورة. يرجى المحاولة مرة أخرى.',
            exception: e,
          ),
        );
      }
    }
  }
}
