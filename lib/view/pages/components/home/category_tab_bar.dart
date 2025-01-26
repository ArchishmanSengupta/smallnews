import 'package:flutter/material.dart';
import 'package:smallnews/view/theme/app_theme.dart';
import 'package:smallnews/view/util/util.dart';

/// Custom styled tab bar for news categories
///
/// Features:
/// - Scrollable tab layout
/// - Consistent theming
/// - Category name formatting
class CategoryTabBar extends StatelessWidget {
  final TabController controller;

  const CategoryTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      physics: const AlwaysScrollableScrollPhysics(),
      indicatorColor: AppTheme.primaryColor.withOpacity(0.5),
      isScrollable: true,
      controller: controller,
      labelColor: AppTheme.secondaryColor,
      // Disable splash
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabs: categories
          .map((category) => Tab(
                child: Text(
                  // Special case for 'Technology' abbreviation
                  category == 'Technology' ? 'Tech' : category.capitalize(),
                  style: const TextStyle(height: 1.2),
                ),
              ))
          .toList(),
    );
  }
}
