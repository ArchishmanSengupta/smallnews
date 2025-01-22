import 'package:flutter/material.dart';
import 'package:smallnews/models/models.dart';
import 'package:smallnews/repository/respository.dart';
import 'package:smallnews/theme/app_theme.dart';
import 'package:smallnews/ui/ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController;
  Future<NewsResponse>? _futureNewsResponse;
  List<Article> _articles = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  final List<String> categories = [
    'general',
    'Technology',
    'Business',
    'sports',
    'health'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController?.addListener(_onTabChanged);
    _futureNewsResponse =
        NewsRepository.fetchNewsByCategory(categories[0], _currentPage);
    _scrollController.addListener(_onScroll);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        _currentPage = 1;
        _articles = [];
        _futureNewsResponse = NewsRepository.fetchNews(query, _currentPage);
      });
    } else {
      setState(() {
        _currentPage = 1;
        _articles = [];
        _futureNewsResponse =
            NewsRepository.fetchNewsByCategory(categories[0], _currentPage);
      });
    }
  }

  void _onTabChanged() {
    final category = categories[_tabController?.index ?? 0];
    setState(() {
      _currentPage = 1;
      _articles = [];
      _futureNewsResponse =
          NewsRepository.fetchNewsByCategory(category, _currentPage);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final query = _searchController.text;
    final category = categories[_tabController?.index ?? 0];

    try {
      final NewsResponse response;
      if (query.isNotEmpty) {
        response = await NewsRepository.fetchNews(query, _currentPage + 1);
      } else {
        response = await NewsRepository.fetchNewsByCategory(
            category, _currentPage + 1);
      }

      setState(() {
        _currentPage++;
        _articles.addAll(response.articles);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/smallnews_logo.png',
            height: 30,
            width: 30,
          ),
        ),
        title: const Text(
          'smallnews',
          style:
              TextStyle(fontSize: 16, fontFamily: 'Graphik', letterSpacing: 1),
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TabBar(
            isScrollable: true,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Graphik',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Graphik',
              fontWeight: FontWeight.w500,
            ),
            controller: _tabController,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: AppTheme.secondaryColor,
              ),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            unselectedLabelColor: Colors.grey[600],
            labelColor: AppTheme.secondaryColor,
            tabs: categories
                .map((category) => Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          category == 'Technology'
                              ? 'Tech'
                              : category.capitalize(),
                          style: const TextStyle(
                            height: 1.2,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories
                  .map((category) => _buildNewsList(category))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(String category) {
    return FutureBuilder<NewsResponse>(
      future: _futureNewsResponse,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            cacheExtent: 500,
            itemCount: 10,
            itemBuilder: (context, index) {
              return const ShimmerLoading();
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData ||
            snapshot.data?.articles.isEmpty == true) {
          return const Center(child: Text('No articles found.'));
        } else {
          _articles = snapshot.data?.articles ?? [];
          return ListView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
              decelerationRate: ScrollDecelerationRate.fast,
            ),
            cacheExtent: 1000.0,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            controller: _scrollController,
            itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              if (index >= _articles.length) {
                return const ShimmerLoading();
              }
              return RepaintBoundary(
                child: NewsCard(article: _articles[index]),
              );
            },
          );
        }
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
