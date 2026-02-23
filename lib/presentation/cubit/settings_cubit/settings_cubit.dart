import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/offline_audio_service.dart';
import '../../../core/services/settings_service.dart';
import 'settings_states.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _service;

  SettingsCubit({SettingsService? service})
    : _service = service ?? SettingsService.instance,
      super(SettingsState.defaults());

  Future<void> init() async {
    try {
      final saved = await _service.loadAll();
      emit(
        SettingsState(
          fontSizeMultiplier: saved.fontSizeMultiplier,
          selectedReciter: saved.selectedReciter,
          currentReciterSizeBytes: 0,
        ),
      );
      await refreshStorageSize();
    } catch (e) {
      debugPrint('[SettingsCubit] init failed, using defaults: $e');
    }
  }

  Future<void> setFontSizeMultiplier(double multiplier) async {
    if (state.fontSizeMultiplier == multiplier) return;
    emit(state.copyWith(fontSizeMultiplier: multiplier));
    await _service.setFontSizeMultiplier(multiplier);
  }

  Future<void> setSelectedReciter(String reciter) async {
    if (state.selectedReciter == reciter) return;
    emit(state.copyWith(selectedReciter: reciter));
    await _service.setSelectedReciter(reciter);
    await refreshStorageSize();
  }

  Future<void> refreshStorageSize() async {
    final size = await OfflineAudioService.instance.calculateReciterSize(
      state.selectedReciter,
    );
    emit(state.copyWith(currentReciterSizeBytes: size));
  }

  Future<void> recalculateCurrentStorage() => refreshStorageSize();

  Future<void> adjustFontSize(double step) async {
    final next = (state.fontSizeMultiplier + step).clamp(0.7, 2.0);
    await setFontSizeMultiplier(next);
  }

  Future<void> resetToDefaults() async {
    final defaults = SettingsState.defaults();
    emit(defaults);
    await Future.wait([
      _service.setFontSizeMultiplier(defaults.fontSizeMultiplier),
      _service.setSelectedReciter(defaults.selectedReciter),
    ]);
    await refreshStorageSize();
  }
}
