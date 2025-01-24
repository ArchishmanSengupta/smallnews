import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/controller/controller.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Navigator.push(context, AppRoutes.createRoute(const SearchPage()));
        },
        child: const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Icon(Icons.search, color: Colors.black),
        ),
      ),
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
    );
  }

  Widget _buildBody() {
    final newsProvider = Provider.of<NewsProvider>(context);
    return Column(
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
                      category == 'Technology' ? 'Tech' : category.capitalize(),
                      style: const TextStyle(height: 1.2),
                    ),
                  ))
              .toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: categories.map((category) {
              final categoryState = newsProvider.getState(category);
              if (categoryState == null) {
                return const Center(child: CupertinoActivityIndicator());
              }
              return _buildCategoryNewsList(
                category,
                categoryState,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryNewsList(
    String category,
    NewsListState categoryState,
  ) {
    if (categoryState.error != null && categoryState.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${categoryState.error}'),
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
              onPressed: () =>
                  context.read<NewsProvider>().initCategory(category),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<NewsProvider>().refresh(category),
      child: ListView.builder(
        controller: categoryState.scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: categoryState.hasReachedEnd
            ? categoryState.articles.length
            : categoryState.articles.length + 1,
        itemBuilder: (context, index) {
          if (index >= categoryState.articles.length) {
            if (categoryState.error != null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Error: ${categoryState.error}'),
                    const SizedBox(height: 8),
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
                      onPressed: () => context
                          .read<NewsProvider>()
                          .loadMoreArticles(category),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: CupertinoActivityIndicator()),
            );
          }

          return NewsCard(article: categoryState.articles[index]);
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
