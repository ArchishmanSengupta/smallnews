import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/controller/controller.dart';
import 'package:smallnews/view/view.dart';

/// Main application screen displaying categorized news feeds
///
/// Features:
/// - Tabbed interface for news categories
/// - State-preserved scroll positions per category
/// - Integrated pull-to-refresh
/// - Paginated content loading
/// - Error state handling
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
    // Initialize tab controller with category count
    _tabController = TabController(
      length: categories.length,
      // VSync for animation optimization & synchronization
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.build(context),
      body: Column(
        children: [
          const SizedBox(height: 16),
          CategoryTabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              // Maintain separate states per category
              children: categories.map((category) {
                final categoryState =
                    context.watch<NewsProvider>().getState(category);
                return CategoryNewsList(
                  category: category,
                  categoryState: categoryState,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Prevent memory leaks
    _tabController.dispose();
    super.dispose();
  }
}
