import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../cubit/settings_cubit/settings_cubit.dart';
import '../cubit/settings_cubit/settings_states.dart';
import 'widgets/setting/about_tile.dart';
import 'widgets/setting/fontsize_slider.dart';
import 'widgets/setting/section_header.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'الإعدادات',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              SectionHeader(label: 'المظهر', icon: Icons.palette_outlined),
              FontSizeSlider(value: settings.fontSizeMultiplier),

              const SizedBox(height: 24),

              SectionHeader(
                label: 'عن التطبيق',
                icon: Icons.info_outline_rounded,
              ),
              AboutTile(),
            ],
          );
        },
      ),
    );
  }
}
