import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  
  static final SettingsService instance = SettingsService._();
  SettingsService._();

  
  static const String _kThemeMode = 'settings.themeMode';
  static const String _kFontSizeMultiplier = 'settings.fontSizeMultiplier';
  static const String _kFontType = 'settings.fontType';
  static const String _kSelectedReciter = 'settings.selectedReciter';

  
  static const ThemeMode defaultThemeMode = ThemeMode.system;
  static const double defaultFontSizeMultiplier = 1.0;
  static const String defaultFontType = 'Amiri';
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

  

  Future<ThemeMode> getThemeMode() async {
    final prefs = await _instance;
    final stored = prefs.getString(_kThemeMode);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => defaultThemeMode,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _instance;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_kThemeMode, value);
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

  

  
  Future<String> getFontType() async {
    final prefs = await _instance;
    return prefs.getString(_kFontType) ?? defaultFontType;
  }

  Future<void> setFontType(String fontType) async {
    final prefs = await _instance;
    await prefs.setString(_kFontType, fontType);
  }

  

  Future<String> getSelectedReciter() async {
    final prefs = await _instance;
    return prefs.getString(_kSelectedReciter) ?? defaultSelectedReciter;
  }

  Future<void> setSelectedReciter(String reciter) async {
    final prefs = await _instance;
    await prefs.setString(_kSelectedReciter, reciter);
  }

  

  
  
  Future<
    ({
      ThemeMode themeMode,
      double fontSizeMultiplier,
      String fontType,
      String selectedReciter,
    })
  >
  loadAll() async {
    final prefs = await _instance;

    final themeModeStr = prefs.getString(_kThemeMode);
    final fontSizeMultiplier =
        prefs.getDouble(_kFontSizeMultiplier) ?? defaultFontSizeMultiplier;
    final fontType = prefs.getString(_kFontType) ?? defaultFontType;
    final selectedReciter =
        prefs.getString(_kSelectedReciter) ?? defaultSelectedReciter;

    final themeMode = switch (themeModeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => defaultThemeMode,
    };

    return (
      themeMode: themeMode,
      fontSizeMultiplier: fontSizeMultiplier.clamp(0.7, 2.0),
      fontType: fontType,
      selectedReciter: selectedReciter,
    );
  }
}
