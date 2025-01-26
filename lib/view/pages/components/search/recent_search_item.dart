import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smallnews/controller/provider/provider.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/theme/app_theme.dart';
import 'package:smallnews/view/widgets/widgets.dart';

/// Historical search entry component with expandable results
///
/// Features:
/// - Interactive expansion/collapse
/// - Contextual article previews
/// - Search query rehydration
/// - Visual separation between entries
class RecentSearchItem extends StatelessWidget {
  final String query;
  final List<ArticleModel> articles;

  const RecentSearchItem({
    super.key,
    required this.query,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsSearchProvider>(
      // Efficient rebuilds for expansion state
      builder: (context, controller, _) {
        final isExpanded = controller.isExpanded[query] ?? false;

        return Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.history,
                color: AppTheme.secondaryColor,
                semanticLabel: 'Search history',
              ),
              title: Text(
                query,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => controller.toggleExpanded(query),
                tooltip: isExpanded ? 'Collapse' : 'Expand',
              ),
            ),
            if (isExpanded && articles.isNotEmpty)
              ...articles.map((article) => NewsCard(article: article)),
            if (query != controller.recentSearches.last)
              Divider(color: Colors.grey[300]),
          ],
        );
      },
    );
  }
}
