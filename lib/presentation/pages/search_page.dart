import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../cubit/search_cubit/search_cubit.dart';
import 'widgets/search/search_body.dart';
import 'widgets/search/search_header.dart';
import 'widgets/search/search_input_field.dart';

const _kDebounceDelay = Duration(milliseconds: 320);

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
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

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
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
    _searchFocusNode.dispose();
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
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => _searchFocusNode.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: [
              SearchHeader(searchFocusNode: _searchFocusNode),
              SearchInputField(
                barElevation: _barElevation,
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
                onSearchChanged: _onSearchChanged,
                onClearSearch: _clearSearch,
              ),
              const SizedBox(height: 8),
              Expanded(child: SearchBody(searchFocusNode: _searchFocusNode)),
            ],
          ),
        ),
      ),
    );
  }
}
