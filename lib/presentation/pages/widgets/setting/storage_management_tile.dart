import 'package:alfanous/presentation/pages/widgets/setting/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/reciter_names.dart';
import '../../../../core/services/offline_audio_service.dart';
import '../../../cubit/settings_cubit/settings_cubit.dart';
import '../../../cubit/settings_cubit/settings_states.dart';

class StorageManagementTile extends StatelessWidget {
  final String reciter;
  const StorageManagementTile({super.key, required this.reciter});

  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final reciterNameAr = reciterNames[reciter] ?? reciter;

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.currentReciterSizeBytes != curr.currentReciterSizeBytes ||
          prev.selectedReciter != curr.selectedReciter,
      builder: (context, state) {
        final formattedSize = _formatBytes(state.currentReciterSizeBytes);

        return CardWidget(
          child: Column(
            children: [
              // Storage used row
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.storage_outlined, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'المساحة المستخدمة للشيخ $reciterNameAr',
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: state.currentReciterSizeBytes > 0
                          ? AppColors.accentSoft
                          : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: state.currentReciterSizeBytes > 0
                            ? AppColors.accent
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      formattedSize,
                      style: GoogleFonts.amiri(
                        color: state.currentReciterSizeBytes > 0
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Clear current reciter button
              OutlinedButton.icon(
                onPressed: state.currentReciterSizeBytes == 0
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.divider),
                            ),
                            title: Text(
                              'تأكيد الحذف',
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.amiri(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: RichText(
                              textDirection: TextDirection.rtl,
                              text: TextSpan(
                                style: GoogleFonts.amiri(
                                  color: AppColors.textSecondary,
                                  fontSize: 18,
                                  height: 1.8,
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'هل أنت متأكد من مسح جميع التنزيلات الصوتية للقارئ ',
                                  ),
                                  TextSpan(
                                    text: reciterNameAr,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: '؟\n'),
                                  const TextSpan(text: 'سيتم تفريغ مساحة '),
                                  TextSpan(
                                    text: formattedSize,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  //const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(
                                  'إلغاء',
                                  style: GoogleFonts.amiri(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  'مسح',
                                  style: GoogleFonts.amiri(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          final messenger = ScaffoldMessenger.of(context);
                          final cubit = context.read<SettingsCubit>();

                          await OfflineAudioService.instance.clearReciter(
                            reciter,
                          );
                          await cubit.refreshStorageSize();

                          messenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'تم مسح مساحة القارئ $reciterNameAr بنجاح',
                                      textDirection: TextDirection.rtl,
                                      style: GoogleFonts.amiri(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(
                                0xFFD32F2F,
                              ), // Deep Red
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size.fromHeight(40),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(
                  'مسح مساحة القارئ الحالي',
                  style: GoogleFonts.amiri(fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              // Clear ALL storage button
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: Text(
                        'مسح كل التنزيلات',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'سيتم حذف جميع ملفات الصوت المحمّلة لجميع القراء. هل تريد المتابعة؟',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          color: AppColors.textSecondary,
                          height: 1.8,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'إلغاء',
                            style: GoogleFonts.amiri(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'مسح الكل',
                            style: GoogleFonts.amiri(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    final messenger = ScaffoldMessenger.of(context);
                    final cubit = context.read<SettingsCubit>();

                    await OfflineAudioService.instance.clearAll();
                    await cubit.refreshStorageSize();

                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            const Icon(
                              Icons.delete_sweep_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تم تفريغ جميع ملفات الصوت المؤقتة',
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.amiri(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFFD32F2F), // Deep Red
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.divider, width: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size.fromHeight(40),
                ),
                icon: const Icon(Icons.delete_forever_rounded, size: 18),
                label: Text(
                  'تفريغ الذاكرة المؤقتة',
                  style: GoogleFonts.amiri(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
