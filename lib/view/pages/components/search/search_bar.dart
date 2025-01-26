import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/controller/provider/provider.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/theme/app_theme.dart';

/// Animated search input component with history management
///
/// Features:
/// - Composite entrance animations
/// - Input validation and sanitization
/// - Search history persistence
/// - Clear/reuse functionality
class AnimatedSearchBar extends StatelessWidget {
  final AnimationController animationController;
  final NewsSearchProvider controller;

  const AnimatedSearchBar({
    super.key,
    required this.animationController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animationController),
        child: _SearchBarContent(controller: controller),
      ),
    );
  }
}

/// Search input core implementation
class _SearchBarContent extends StatelessWidget {
  final NewsSearchProvider controller;

  const _SearchBarContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchInput(context),
        _buildRecentSearchesHeader(),
      ],
    );
  }

  /// Constructs search input field with actions
  Widget _buildSearchInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Flexible input field
          Expanded(
            child: TextField(
              controller: controller.newsSearchController,
              decoration: InputDecoration(
                hintText: AppStrings.search,
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onSubmitted: (input) => _performSearch(context),
              textInputAction: TextInputAction.done,
            ),
          ),
          // Search action button
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[400]),
            onPressed: () => _performSearch(context),
            tooltip: 'Execute search',
          ),
          // Dynamic clear button
          if (controller.newsSearchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[400]),
              onPressed: controller.clearSearch,
              tooltip: 'Clear search',
            ),
        ],
      ),
    );
  }

  /// Recent searches header with clear option
  Widget _buildRecentSearchesHeader() {
    return Consumer<NewsSearchProvider>(
      builder: (context, controller, _) {
        // Conditional display logic
        if (controller.newsSearchController.text.isEmpty &&
            controller.recentSearches.isNotEmpty) {
          return Column(
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your recent searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  TextButton(
                    onPressed: controller.clearRecentSearches,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Executes search with validation
  void _performSearch(BuildContext context) {
    final query = controller.newsSearchController.text.trim();
    if (query.isNotEmpty) {
      // Dismiss keyboard
      FocusScope.of(context).unfocus();
      // Initiate search
      controller.performSearch();
    }
  }
}
