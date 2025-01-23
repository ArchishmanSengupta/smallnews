import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/services/services.dart';
import 'package:smallnews/theme/app_theme.dart';
import 'package:smallnews/ui/widgets/widgets.dart';

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
  Timer? _debounceTimer;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _currentQuery = '';
  int _currentPage = 1;
  List<Article> _articles = [];
  String? _error;
  bool _hasMore = true;

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _setupAnimations();
    _setupSearchListener();
    _setupScrollListener();
    _loadRecentSearches();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        final query = _searchController.text.trim();
        if (query.isNotEmpty && query != _currentQuery) {
          _performSearch();
        }
      });
    });
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
      if (!_isLoading &&
          !_isLoadingMore &&
          _hasMore &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
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
        if (results.articles.isEmpty) {
          _error = 'No articles found for this search term.';
          _hasMore = false;
        } else {
          _articles = results.articles;
          _hasMore = results.articles.length >= 20;
        }
        _isLoading = false;
      });

      _saveRecentSearch(query);
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
    if (_isLoadingMore || _isLoading || !_hasMore || _currentQuery.isEmpty)
      return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final results = await NewsRepository.fetchNews(_currentQuery, nextPage);

      if (!mounted) return;

      setState(() {
        if (results.articles.isNotEmpty) {
          _articles.addAll(results.articles);
          _currentPage = nextPage;
          _hasMore = results.articles.length >= 20;
        } else {
          _hasMore = false;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _hasMore = false;
      });

      final errorMsg = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.sublist(0, 5);
    }
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.newsFromAllAroundTheWorld,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.search,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
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
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onSubmitted: (_) => _performSearch(),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: ShimmerLoading()),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_articles.isEmpty && _currentQuery.isNotEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('No articles found. Try a different search term.'),
        ),
      );
    }

    if (_articles.isEmpty && _currentQuery.isEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final query = _recentSearches[index];
            return ListTile(
              title: Text(query),
              onTap: () {
                _searchController.text = query;
                _performSearch();
              },
            );
          },
          childCount: _recentSearches.length,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _articles.length) {
            return _isLoadingMore
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.grey[800]!),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }

          final article = _articles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0,
              child: NewsCard(article: article),
            ),
          );
        },
        childCount: _articles.length + (_isLoadingMore ? 1 : 0),
      ),
    );
  }
}
