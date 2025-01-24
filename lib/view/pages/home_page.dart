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
        onTap: () => {
          Navigator.push(context, AppRoutes.createRoute(const SearchPage()))
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
                return const Center(child: CircularProgressIndicator());
              }
              return _buildCategoryNewsList(
                category,
                categoryState,
                onLoadMore: () async {
                  await newsProvider.loadMoreArticles(category);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryNewsList(String category, NewsListState categoryState,
      {required VoidCallback onLoadMore}) {
    if (categoryState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${categoryState.error}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final newsProvider =
                    Provider.of<NewsProvider>(context, listen: false);
                await newsProvider.initCategory(category);
              },
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
    }
    final articles = categoryState.articles;
    return RefreshIndicator(
      onRefresh: () async {
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        await newsProvider.initCategory(category);
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        controller: categoryState.scrollController,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return const ShimmerLoading();
          }

          return NewsCard(article: articles[index]);
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
