library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/database/database_helper.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/quran_repository.dart';
import 'presentation/cubit/favorite_cubit/favorites_cubit.dart';
import 'presentation/cubit/search_cubit/search_cubit.dart';
import 'presentation/cubit/settings_cubit/settings_cubit.dart';
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
    final favRepo = FavoritesRepository(dbHelper: DatabaseHelper.instance);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<QuranRepository>.value(value: repo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>.value(value: settingsCubit),

          BlocProvider<SearchCubit>(
            create: (_) => SearchCubit(repository: repo),
          ),
          BlocProvider<FavoritesCubit>(
            create: (_) => FavoritesCubit(repository: favRepo)..loadFavorites(),
          ),
        ],
        child: MaterialApp(
          title: 'الفانوس — البحث القرآني',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          theme: _buildTheme(),

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', ''), Locale('en', '')],
          locale: const Locale('ar', ''),

          home: const SearchPage(),
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    const darkBg = Color(0xFF0F1923);
    const darkSurface = Color(0xFF1A2840);
    const accent = Color(0xFFD4AF37);
    const darkText = Color(0xFFF0E6CC);
    const darkTextSec = Color(0xFF8EA8C3);

    final amiriBase = GoogleFonts.amiriTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      canvasColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: darkText,
        error: Color(0xFFEF5350),
        onError: Colors.white,
      ),
      textTheme: amiriBase.copyWith(
        bodyLarge: amiriBase.bodyLarge?.copyWith(color: darkText),
        bodyMedium: amiriBase.bodyMedium?.copyWith(color: darkText),
        bodySmall: amiriBase.bodySmall?.copyWith(color: darkTextSec),
        titleLarge: amiriBase.titleLarge?.copyWith(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: GoogleFonts.amiri(color: darkTextSec),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: accent),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
