import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/services/services.dart';
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
  late TabController _tabController;

  final Map<String, NewsListState> _categoryStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);

    _initializeCategoryState(categories[0]);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(categories[_tabController.index]);
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
    if (_categoryStates[category]!.articles.isEmpty) {
      _initializeCategoryState(category);
    }
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

  Widget _buildAppbar() {
    return GestureDetector(
      onTap: () => {
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
        )
      },
      child: const Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Icon(Icons.search, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: _buildAppbar(),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  AppImages.logo,
                  height: 30,
                  width: 30,
                ),
              ),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                    fontSize: 16, fontFamily: 'Graphik', letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          TabBar(
            physics: const AlwaysScrollableScrollPhysics(),
            indicatorColor: AppTheme.primaryColor.withOpacity(0.5),
            isScrollable: true,
            controller: _tabController,
            labelColor: AppTheme.secondaryColor,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: categories
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
              children: categories.map((category) {
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
        if (snapshot.connectionState == ConnectionState.waiting &&
            categoryState.articles.isEmpty) {
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

        return RefreshIndicator(
          onRefresh: () async {
            final response =
                await NewsRepository.fetchNewsByCategory(category, 1);
            setState(() {
              categoryState.articles = response.articles;
              categoryState.currentPage = 1;
            });
          },
          child: ListView.builder(
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
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
