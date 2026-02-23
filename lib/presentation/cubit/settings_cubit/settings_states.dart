import 'package:equatable/equatable.dart';

import '../../../core/services/settings_service.dart';

final class SettingsState extends Equatable {
  final double fontSizeMultiplier;

  final String selectedReciter;

  final int currentReciterSizeBytes;

  const SettingsState({
    required this.fontSizeMultiplier,
    required this.selectedReciter,
    required this.currentReciterSizeBytes,
  });

  factory SettingsState.defaults() => const SettingsState(
    fontSizeMultiplier: SettingsService.defaultFontSizeMultiplier,
    selectedReciter: SettingsService.defaultSelectedReciter,
    currentReciterSizeBytes: 0,
  );

  SettingsState copyWith({
    double? fontSizeMultiplier,
    String? selectedReciter,
    int? currentReciterSizeBytes,
  }) => SettingsState(
    fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
    selectedReciter: selectedReciter ?? this.selectedReciter,
    currentReciterSizeBytes:
        currentReciterSizeBytes ?? this.currentReciterSizeBytes,
  );

  @override
  List<Object?> get props => [
    fontSizeMultiplier,
    selectedReciter,
    currentReciterSizeBytes,
  ];

  @override
  String toString() =>
      'SettingsState('
      'fontSize=$fontSizeMultiplier, '
      'reciter=$selectedReciter, '
      'size=$currentReciterSizeBytes)';
}
