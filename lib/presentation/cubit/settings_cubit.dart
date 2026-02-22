import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/settings_service.dart';

final class SettingsState extends Equatable {
  final ThemeMode themeMode;

  final double fontSizeMultiplier;

  final String fontType;

  final String selectedReciter;

  const SettingsState({
    required this.themeMode,
    required this.fontSizeMultiplier,
    required this.fontType,
    required this.selectedReciter,
  });

  factory SettingsState.defaults() => const SettingsState(
    themeMode: SettingsService.defaultThemeMode,
    fontSizeMultiplier: SettingsService.defaultFontSizeMultiplier,
    fontType: SettingsService.defaultFontType,
    selectedReciter: SettingsService.defaultSelectedReciter,
  );

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? fontSizeMultiplier,
    String? fontType,
    String? selectedReciter,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
    fontType: fontType ?? this.fontType,
    selectedReciter: selectedReciter ?? this.selectedReciter,
  );

  @override
  List<Object?> get props => [
    themeMode,
    fontSizeMultiplier,
    fontType,
    selectedReciter,
  ];

  @override
  String toString() =>
      'SettingsState('
      'theme=$themeMode, '
      'fontSize=$fontSizeMultiplier, '
      'font=$fontType, '
      'reciter=$selectedReciter)';
}

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
          themeMode: saved.themeMode,
          fontSizeMultiplier: saved.fontSizeMultiplier,
          fontType: saved.fontType,
          selectedReciter: saved.selectedReciter,
        ),
      );
    } catch (e) {
      debugPrint('[SettingsCubit] init failed, using defaults: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) return;
    emit(state.copyWith(themeMode: mode));
    await _service.setThemeMode(mode);
  }

  Future<void> setFontSizeMultiplier(double multiplier) async {
    if (state.fontSizeMultiplier == multiplier) return;
    emit(state.copyWith(fontSizeMultiplier: multiplier));
    await _service.setFontSizeMultiplier(multiplier);
  }

  Future<void> setFontType(String fontType) async {
    if (state.fontType == fontType) return;
    emit(state.copyWith(fontType: fontType));
    await _service.setFontType(fontType);
  }

  Future<void> setSelectedReciter(String reciter) async {
    if (state.selectedReciter == reciter) return;
    emit(state.copyWith(selectedReciter: reciter));
    await _service.setSelectedReciter(reciter);
  }

  Future<void> cycleThemeMode() async {
    final next = switch (state.themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  Future<void> adjustFontSize(double step) async {
    final next = (state.fontSizeMultiplier + step).clamp(0.7, 2.0);
    await setFontSizeMultiplier(next);
  }

  Future<void> resetToDefaults() async {
    final defaults = SettingsState.defaults();
    emit(defaults);
    await Future.wait([
      _service.setThemeMode(defaults.themeMode),
      _service.setFontSizeMultiplier(defaults.fontSizeMultiplier),
      _service.setFontType(defaults.fontType),
      _service.setSelectedReciter(defaults.selectedReciter),
    ]);
  }
}
