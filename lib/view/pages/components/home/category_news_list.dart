import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/controller/controller.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/view.dart';

/// News list implementation for individual categories
///
/// Handles:
/// - Initial loading states
/// - Error states
/// - Paginated content
/// - Scroll position preservation
/// - Pull-to-refresh functionality
class CategoryNewsList extends StatelessWidget {
  final String category;
  final NewsListModel? categoryState;

  const CategoryNewsList({
    super.key,
    required this.category,
    required this.categoryState,
  });

  @override
  Widget build(BuildContext context) {
    // Handle initial loading state
    if (categoryState == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    // Error state handling
    if (categoryState!.hasError) {
      return _buildErrorState(context);
    }

    return CustomScrollView(
      // Preserve scroll position
      key: PageStorageKey<String>(category),
      // Pagination control
      controller: categoryState!.scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async => context.read<NewsProvider>().refresh(category),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildListItem(context, index),
            // Account for loading indicator at end
            childCount: categoryState!.hasReachedEnd
                ? categoryState!.articles.length
                : categoryState!.articles.length + 1,
          ),
        ),
      ],
    );
  }

  /// Builds individual list items with error boundaries
  Widget _buildListItem(BuildContext context, int index) {
    // Pagination loading/error state
    if (index >= categoryState!.articles.length) {
      return categoryState!.error != null
          ? _buildPaginationError(context)
          : const LoadingIndicator();
    }

    // End of list indicator
    if (index == categoryState!.totalResults - 1) {
      return const EndOfListIndicator();
    }

    return NewsCard(article: categoryState!.articles[index]);
  }

  /// Full-screen error state presentation
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: NewsListError(
        errorMessage: categoryState!.error!,
        onRetry: () => context.read<NewsProvider>().initCategory(category),
      ),
    );
  }

  /// Pagination-specific error display
  Widget _buildPaginationError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: NewsListError(
        errorMessage: categoryState!.error!,
        onRetry: () => context.read<NewsProvider>().loadMoreArticles(category),
      ),
    );
  }
}
