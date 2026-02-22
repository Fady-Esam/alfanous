import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../data/repositories/quran_repository.dart';
import '../cubit/search_cubit.dart';
import '../widgets/ayah_card_widget.dart';

const _kAnimationDuration = Duration(milliseconds: 350);
const _kDebounceDelay = Duration(milliseconds: 320);

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  late final AnimationController _barAnimController;
  late final Animation<double> _barElevation;

  @override
  void initState() {
    super.initState();

    _barAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _barElevation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _barAnimController, curve: Curves.easeOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _barAnimController.forward();
      } else {
        _barAnimController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    _barAnimController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(_kDebounceDelay, () {
      if (mounted) {
        context.read<SearchCubit>().search(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    context.read<SearchCubit>().clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(context),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withAlpha(102),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'ق',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'الفانوس',
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'البحث في القرآن الكريم',
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),

          BlocBuilder<SearchCubit, SearchState>(
            buildWhen: (prev, curr) =>
                curr is SearchSuccess || prev is SearchSuccess,
            builder: (_, state) {
              if (state is! SearchSuccess || state.isEmpty) {
                return const SizedBox.shrink();
              }
              return AnimatedOpacity(
                opacity: 1.0,
                duration: _kAnimationDuration,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent, width: 0.8),
                  ),
                  child: Text(
                    '${state.count} آية',
                    style: GoogleFonts.amiri(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _barElevation,
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha(
                  (_barElevation.value * 8).toInt(),
                ),
                blurRadius: _barElevation.value * 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: GoogleFonts.amiri(color: AppColors.textPrimary, fontSize: 18),
          cursorColor: AppColors.accent,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'ابحث في القرآن الكريم…',
            hintStyle: GoogleFonts.amiri(
              color: AppColors.textSecondary,
              fontSize: 17,
            ),
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor: AppColors.searchBarBg,

            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),

            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (_, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                  tooltip: 'مسح',
                );
              },
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: _kAnimationDuration,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: switch (state) {
            SearchInitial() => const _SearchPromptView(key: ValueKey('prompt')),
            SearchLoading() => const _SearchLoadingView(
              key: ValueKey('loading'),
            ),
            SearchSuccess(:final results) when results.isEmpty =>
              _NoResultsView(
                key: const ValueKey('empty'),
                query: results.isEmpty ? '' : '',
              ),
            SearchSuccess(:final results) => _SearchResultsList(
              key: const ValueKey('results'),
              results: results,
            ),
            SearchError(:final message) => _SearchErrorView(
              key: const ValueKey('error'),
              message: message,
            ),
          },
        );
      },
    );
  }
}

class _SearchPromptView extends StatelessWidget {
  const _SearchPromptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFF5DEB3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ٱبۡدَأۡ بِٱلۡبَحۡثِ',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'اكتب كلمة أو جزءاً من آية للبحث عنها\nفي القرآن الكريم',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 40),

          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _HintChip('رحمة'),
              _HintChip('صبر'),
              _HintChip('الجنة'),
              _HintChip('النور'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final String text;
  const _HintChip(this.text);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<SearchCubit>().search(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          text,
          style: GoogleFonts.amiri(color: AppColors.textSecondary, fontSize: 15),
        ),
      ),
    );
  }
}

class _SearchLoadingView extends StatelessWidget {
  const _SearchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جارٍ البحث…',
            style: GoogleFonts.amiri(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  final String query;
  const _NoResultsView({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: GoogleFonts.amiri(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'لم يتم العثور على آيات تحتوي على "$query".\n'
              'جرّب كلمة مختلفة أو تحقق من الإملاء.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchErrorView extends StatelessWidget {
  final String message;
  const _SearchErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: GoogleFonts.amiri(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => context.read<SearchCubit>().clear(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'حاول مرة أخرى',
                style: GoogleFonts.amiri(fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final List<SearchResultItem> results;

  const _SearchResultsList({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _AyaCard(item: results[index], index: index);
      },
    );
  }
}

class _AyaCard extends StatelessWidget {
  final SearchResultItem item;
  final int index;

  const _AyaCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final aya = item.aya;
    return AyahCardWidget(
      aya: aya,
      highlightTerms: item.highlightTerms,
      isHighlight: false,
    );
  }
}
