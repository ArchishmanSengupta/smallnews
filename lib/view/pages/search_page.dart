import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/controller/provider/provider.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/theme/app_theme.dart';
import 'package:smallnews/view/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late final NewsSearchProvider _controller;
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;

  @override
  void initState() {
    super.initState();
    _controller = context.read<NewsSearchProvider>();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchBarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          elevation: 0,
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: CustomScrollView(
                  controller: _controller.scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      sliver: _buildContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(
                  CupertinoIcons.back,
                  color: AppTheme.secondaryColor,
                ),
              ),
              const Text(
                AppStrings.discover,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: Text(
              AppStrings.newsFromAllAroundTheWorld,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _searchBarAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_searchBarAnimation),
              child: _buildSearchBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              Expanded(
                child: TextField(
                  controller: _controller.newsSearchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.search,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (input) => onSearch(),
                  textInputAction: TextInputAction.done,
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.grey[400]),
                onPressed: onSearch,
              ),
              if (_controller.newsSearchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    _controller.clearSearch();
                  },
                ),
            ],
          ),
        ),
        Consumer<NewsSearchProvider>(
          builder: (context, controller, _) {
            if (_controller.newsSearchController.text.isEmpty &&
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
                        onPressed: _controller.clearRecentSearches,
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
        ),
      ],
    );
  }

  void onSearch() {
    final query = _controller.newsSearchController.text.trim();
    if (query.isNotEmpty) {
      FocusScope.of(context).unfocus();
      _controller.performSearch();
    }
  }

  Widget _buildContent() {
    return Consumer<NewsSearchProvider>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.articles.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: ShimmerLoading()),
          );
        }

        if (controller.error != null && controller.articles.isEmpty) {
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _controller.performSearch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildArticleList();
      },
    );
  }

  Widget _buildArticleList() {
    return Consumer<NewsSearchProvider>(
      builder: (context, controller, _) {
        if (controller.articles.isEmpty && controller.currentQuery.isNotEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No articles found')),
          );
        }

        if (controller.articles.isEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildRecentSearchItem(index),
              childCount: controller.recentSearches.length,
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= controller.articles.length) {
                return controller.hasMore
                    ? _buildLoadingIndicator()
                    : const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NewsCard(article: controller.articles[index]),
              );
            },
            childCount:
                controller.articles.length + (controller.hasMore ? 1 : 0),
          ),
        );
      },
    );
  }

  Widget _buildRecentSearchItem(int index) {
    return Consumer<NewsSearchProvider>(
      builder: (context, controller, _) {
        final query = controller.recentSearches[index];
        final articles = controller.recentSearchResults[query] ?? [];
        final isExpanded = controller.isExpanded[query] ?? false;

        return Column(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.history, color: AppTheme.secondaryColor),
              title: Text(query),
              trailing: IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => controller.toggleExpanded(query),
              ),
              onTap: () {
                controller.newsSearchController.text = query;
                controller.performSearch();
              },
            ),
            if (isExpanded && articles.isNotEmpty)
              ...articles.map((article) => NewsCard(article: article)),
            if (index < controller.recentSearches.length - 1)
              Divider(color: Colors.grey[300]),
          ],
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Center(child: ShimmerLoading()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
