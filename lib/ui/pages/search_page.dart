import 'package:flutter/material.dart';
import 'package:smallnews/models/models.dart';
import 'package:smallnews/repository/respository.dart';
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
  final NewsRepository _newsRepository = NewsRepository();

  final Map<String, List<Article>> _searchCache = {};
  final int _maxCacheSize = 5;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _currentQuery = '';
  int _currentPage = 1;
  List<Article> _articles = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _setupAnimations();
    _setupScrollListener();
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
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
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
    });

    try {
      if (_searchCache.containsKey(query)) {
        setState(() {
          _articles = _searchCache[query]!;
          _isLoading = false;
          _currentQuery = query;
        });
        return;
      }

      final results = await NewsRepository.fetchNews(query, _currentPage);
      setState(() {
        _articles = results.articles;
        _currentQuery = query;
        _updateCache(query, results.articles);
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch news articles. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateCache(String query, List<Article> results) {
    if (_searchCache.length >= _maxCacheSize) {
      _searchCache.remove(_searchCache.keys.first);
    }
    _searchCache[query] = results;
  }

  Future<void> _loadMoreResults() async {
    if (_isLoadingMore || _isLoading || _currentQuery.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final moreResults =
          await NewsRepository.fetchNews(_currentQuery, nextPage);

      if (moreResults.articles.isNotEmpty) {
        setState(() {
          _articles.addAll(moreResults.articles);
          _currentPage = nextPage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load more articles')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
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
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'News from all around the world',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: _buildContent(),
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
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: IconButton(
            icon: Icon(Icons.tune, color: Colors.grey[400]),
            onPressed: () {
              // Add filters functionality here
            },
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onSubmitted: (_) => _performSearch(),
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
              Text(_error!, style: TextStyle(color: Colors.grey[600])),
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
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1.0,
            child: NewsCard(
              article: article,
            ),
          );
        },
        childCount: _articles.length + (_isLoadingMore ? 1 : 0),
      ),
    );
  }
}
