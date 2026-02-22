import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/quran_repository.dart';
import 'presentation/cubit/search_cubit/search_cubit.dart';
import 'presentation/cubit/settings_cubit/settings_cubit.dart';
import 'presentation/cubit/settings_cubit/settings_states.dart';
import 'presentation/pages/search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F1923),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final settingsCubit = SettingsCubit();
  await settingsCubit.init();

  runApp(AlfanousApp(settingsCubit: settingsCubit));
}

class AlfanousApp extends StatelessWidget {
  final SettingsCubit settingsCubit;
  const AlfanousApp({super.key, required this.settingsCubit});

  @override
  Widget build(BuildContext context) {
    final repo = QuranRepository(dbHelper: DatabaseHelper.instance);

    return MultiRepositoryProvider(
      providers: [RepositoryProvider<QuranRepository>.value(value: repo)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>.value(value: settingsCubit),

          BlocProvider<SearchCubit>(
            create: (_) => SearchCubit(repository: repo),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
          builder: (context, settings) {
            return MaterialApp(
              title: 'الفانوس — البحث القرآني',
              debugShowCheckedModeBanner: false,
              themeMode: settings.themeMode,
              theme: _buildTheme(Brightness.light),
              darkTheme: _buildTheme(Brightness.dark),

              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ar', ''), Locale('en', '')],
              locale: const Locale('ar', ''),

              home: const SearchPage(),
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? AppColors.background : AppColors.lightBg;
    final surf = isDark ? AppColors.surface : AppColors.lightSurface;
    final text = isDark ? AppColors.textPrimary : AppColors.lightText;
    final textS = isDark ? AppColors.textSecondary : AppColors.lightTextSec;

    final amiriBase = GoogleFonts.amiriTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: surf,
        onSurface: text,
        error: const Color(0xFFEF5350),
        onError: Colors.white,
      ),
      textTheme: amiriBase.copyWith(
        bodyLarge: amiriBase.bodyLarge?.copyWith(color: text),
        bodyMedium: amiriBase.bodyMedium?.copyWith(color: text),
        bodySmall: amiriBase.bodySmall?.copyWith(color: textS),
        titleLarge: amiriBase.titleLarge?.copyWith(
          color: text,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surf,
        hintStyle: GoogleFonts.amiri(color: textS),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
