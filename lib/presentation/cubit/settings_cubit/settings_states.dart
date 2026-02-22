import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/services/settings_service.dart';

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
