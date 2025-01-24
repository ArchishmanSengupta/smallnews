import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smallnews/controller/services/services.dart';
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
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  String _currentQuery = '';
  int _currentPage = 1;
  int _totalResults = 0;
  List<Article> _articles = [];
  String? _error;
  bool _hasMore = true;

  List<String> _recentSearches = [];
  final Map<String, List<Article>> _recentSearchResults = {};
  final Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _setupAnimations();
    _setupScrollListener();
    _loadRecentSearches();
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

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_isLoading || !_hasMore) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      const scrollThreshold = 100;

      if (maxScroll - currentScroll <= scrollThreshold) {
        _loadMoreResults();
      }
    });
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _articles = [];
      _currentQuery = query;
      _hasMore = true;
    });

    try {
      final results = await NewsRepository.fetchNews(query, _currentPage);
      if (!mounted) return;

      setState(() {
        _totalResults = results.totalResults;
        _articles = results.articles;
        _hasMore = _articles.length < _totalResults;
        _isLoading = false;
      });

      _saveRecentSearch(query, results.articles);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoading || !_hasMore || _currentQuery.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final nextPage = _currentPage + 1;
      final results = await NewsRepository.fetchNews(_currentQuery, nextPage);
      if (!mounted) return;

      setState(() {
        _articles.addAll(results.articles);
        _currentPage = nextPage;
        _totalResults = results.totalResults;
        _hasMore = _articles.length < _totalResults;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRecentSearch(String query, List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.sublist(0, 5);
    }
    await prefs.setStringList('recent_searches', _recentSearches);

    setState(() {
      _recentSearchResults[query] = articles;
      _isExpanded[query] = false;
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });

    // Load recent search results
    for (var query in _recentSearches) {
      final results = await NewsRepository.fetchNews(query, 1);
      setState(() {
        _recentSearchResults[query] = results.articles;
        _isExpanded[query] = false;
      });
    }
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() {
      _recentSearches = [];
      _recentSearchResults.clear();
      _isExpanded.clear();
    });
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
              Padding(
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
              ),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.search,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.grey[400]),
                onPressed: () {
                  final query = _searchController.text.trim();
                  if (query.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                    _performSearch();
                  }
                },
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _articles = [];
                      _error = null;
                      _currentQuery = '';
                      _hasMore = true;
                    });
                  },
                ),
            ],
          ),
        ),

        // Recent Searches Section
        if (_searchController.text.isEmpty && _recentSearches.isNotEmpty) ...[
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
                onPressed: _clearRecentSearches,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.secondaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading && _articles.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: ShimmerLoading()),
      );
    }

    if (_error != null && _articles.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _performSearch,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_articles.isEmpty && _currentQuery.isNotEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No articles found')),
      );
    }

    if (_articles.isEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildRecentSearchItem(index),
          childCount: _recentSearches.length,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= _articles.length) {
            if (_error != null) {
              return _buildErrorIndicator();
            }
            return _hasMore
                ? _buildLoadingIndicator()
                : const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: NewsCard(article: _articles[index]),
          );
        },
        childCount: _articles.length + (_hasMore ? 1 : 0),
      ),
    );
  }

  Widget _buildRecentSearchItem(int index) {
    final query = _recentSearches[index];
    final articles = _recentSearchResults[query] ?? [];
    final isExpanded = _isExpanded[query] ?? false;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.history, color: AppTheme.secondaryColor),
          title: Text(query),
          trailing: IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => _isExpanded[query] = !isExpanded),
          ),
          onTap: () {
            _searchController.text = query;
            _performSearch();
          },
        ),
        if (isExpanded && articles.isNotEmpty)
          ...articles.map((article) => NewsCard(article: article)),
        if (index < _recentSearches.length - 1)
          Divider(color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(_error!),
          ElevatedButton(
            onPressed: _loadMoreResults,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
