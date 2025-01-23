import 'package:flutter/material.dart';
import 'package:smallnews/models/models.dart';
import 'package:smallnews/repository/respository.dart';
import 'package:smallnews/theme/app_theme.dart';
import 'package:smallnews/ui/ui.dart';
import 'package:smallnews/util/util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final List<String> _categories = [
    'general',
    'Technology',
    'Business',
    'sports',
    'health',
    'entertainment',
  ];

  final Map<String, NewsListState> _categoryStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);

    _initializeCategoryState(_categories[0]);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_categories[_tabController.index]);
      }
    });
  }

  void _initializeCategoryState(String category) {
    if (!_categoryStates.containsKey(category)) {
      _categoryStates[category] = NewsListState(
        futureNewsResponse: NewsRepository.fetchNewsByCategory(category, 1),
        articles: [],
        currentPage: 1,
      );
    }
  }

  void _onTabChanged(String category) {
    _initializeCategoryState(category);
    setState(() {});
  }

  Future<void> _loadMoreArticles(String category) async {
    final state = _categoryStates[category]!;
    if (state.isLoadingMore) return;

    state.isLoadingMore = true;
    try {
      final response = await NewsRepository.fetchNewsByCategory(
          category, state.currentPage + 1);

      state.articles.addAll(response.articles);
      state.currentPage++;
      state.isLoadingMore = false;
      setState(() {});
    } catch (e) {
      state.isLoadingMore = false;
    }
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
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SearchPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    final tween = Tween(begin: begin, end: end);
                    final offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
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
            physics: const AlwaysScrollableScrollPhysics(),
            indicatorColor: AppTheme.primaryColor.withOpacity(0.5),
            isScrollable: true,
            controller: _tabController,
            labelColor: AppTheme.secondaryColor,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: _categories
                .map((category) => Tab(
                      child: Text(
                        category == 'Technology'
                            ? 'Tech'
                            : category.capitalize(),
                        style: const TextStyle(height: 1.2),
                      ),
                    ))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final categoryState = _categoryStates[category] ??
                    NewsListState(
                      futureNewsResponse:
                          NewsRepository.fetchNewsByCategory(category, 1),
                      articles: [],
                      currentPage: 1,
                    );

                return _buildCategoryNewsList(category, categoryState,
                    onLoadMore: () => _loadMoreArticles(category));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryNewsList(String category, NewsListState categoryState,
      {required VoidCallback onLoadMore}) {
    return FutureBuilder<NewsResponse>(
      future: categoryState.futureNewsResponse,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => const ShimmerLoading(),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.articles.isEmpty) {
          return const Center(child: Text('No articles found'));
        }

        final articles = categoryState.articles.isEmpty
            ? snapshot.data!.articles
            : categoryState.articles;

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: articles.length + (categoryState.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == articles.length) {
              return const ShimmerLoading();
            }

            if (index == articles.length - 1) {
              onLoadMore();
            }

            return NewsCard(article: articles[index]);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
