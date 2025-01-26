import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/controller/provider/provider.dart';
import 'package:smallnews/view/pages/pages.dart';
import 'package:smallnews/view/widgets/widgets.dart';

/// Scrollable search results area with state management
///
/// Handles:
/// - Loading states with shimmer
/// - Error states with retry
/// - Empty states
/// - Pagination support
/// - Recent search display
class SearchContent extends StatelessWidget {
  final NewsSearchProvider controller;

  const SearchContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller.scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: _buildContent(),
        ),
      ],
    );
  }

  /// Dynamic content builder based on state
  Widget _buildContent() {
    return Consumer<NewsSearchProvider>(
      builder: (context, controller, _) {
        // Loading state (initial load)
        if (controller.isLoading && controller.articles.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: ShimmerLoading()),
          );
        }

        // Error state
        if (controller.error != null && controller.articles.isEmpty) {
          return _buildErrorState(controller);
        }

        // Results display
        return _buildResultsList(controller);
      },
    );
  }

  /// Error state presentation
  Widget _buildErrorState(NewsSearchProvider controller) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: controller.performSearch,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Results list construction
  Widget _buildResultsList(NewsSearchProvider controller) {
    // Empty search results
    if (controller.articles.isEmpty && controller.currentQuery.isNotEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No articles found')),
      );
    }

    // Recent searches display
    if (controller.articles.isEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => RecentSearchItem(
            query: controller.recentSearches[index],
            articles: controller
                    .recentSearchResults[controller.recentSearches[index]] ??
                [],
          ),
          childCount: controller.recentSearches.length,
        ),
      );
    }

    // Search results list with pagination
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Pagination loading indicator
          if (index >= controller.articles.length) {
            return controller.hasMore
                ? _buildLoadingIndicator()
                : const SizedBox.shrink();
          }
          // Article card with spacing
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: NewsCard(article: controller.articles[index]),
          );
        },
        childCount: controller.articles.length + (controller.hasMore ? 1 : 0),
      ),
    );
  }

  /// Pagination loading indicator
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Center(child: LoadingIndicator()),
    );
  }
}
