library;

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._();
  SettingsService._();

  static const String _kFontSizeMultiplier = 'settings.fontSizeMultiplier';
  static const String _kSelectedReciter = 'settings.selectedReciter';

  static const double defaultFontSizeMultiplier = 1.0;
  static const String defaultSelectedReciter = 'Alafasy_128kbps';

  static const List<String> availableReciters = [
    'Alafasy_128kbps',
    'Abdul_Basit_Murattal_192kbps',
    'Husary_128kbps',
    'Minshawi_Murattal_128kbps',
    'Mohammed_Siddiq_Al-Minshawi_128kbps',
    'Minshawy_Murattal_128kbps',
    'Ahmad_ibn_Ali_al-Ajamy_128kbps',
    'Ghamadi_40kbps',
  ];

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<double> getFontSizeMultiplier() async {
    final prefs = await _instance;
    return prefs.getDouble(_kFontSizeMultiplier) ?? defaultFontSizeMultiplier;
  }

  Future<void> setFontSizeMultiplier(double multiplier) async {
    final prefs = await _instance;

    final clamped = multiplier.clamp(0.7, 2.0);
    await prefs.setDouble(_kFontSizeMultiplier, clamped);
  }

  Future<String> getSelectedReciter() async {
    final prefs = await _instance;
    return prefs.getString(_kSelectedReciter) ?? defaultSelectedReciter;
  }

  Future<void> setSelectedReciter(String reciter) async {
    final prefs = await _instance;
    await prefs.setString(_kSelectedReciter, reciter);
  }

  Future<({double fontSizeMultiplier, String selectedReciter})>
  loadAll() async {
    final prefs = await _instance;

    final fontSizeMultiplier =
        prefs.getDouble(_kFontSizeMultiplier) ?? defaultFontSizeMultiplier;
    final selectedReciter =
        prefs.getString(_kSelectedReciter) ?? defaultSelectedReciter;

    return (
      fontSizeMultiplier: fontSizeMultiplier.clamp(0.7, 2.0),
      selectedReciter: selectedReciter,
    );
  }
}
