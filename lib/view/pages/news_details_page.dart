import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/view.dart';

/// News article detail screen displaying full content and metadata
///
/// Features:
/// - Hero animation for image transitions
/// - Stacked layout with gradient overlay
/// - Web view integration for full article content
/// - Responsive image handling with error states
class NewsDetailsPage extends StatefulWidget {
  final ArticleModel article;

  const NewsDetailsPage({
    super.key,
    required this.article,
  });

  @override
  State<NewsDetailsPage> createState() => _NewsDetailsPageState();
}

class _NewsDetailsPageState extends State<NewsDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Image section with overlay content
          Stack(
            children: [
              NewsImageWidget(
                imageUrl: widget.article.urlToImage ?? '',
                articleUrl: widget.article.url,
              ),
              NewsImageOverlay(
                article: widget.article,
                onBackPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          // Full article content web view
          Expanded(
            child: WebViewArticle(
              url: widget.article.url,
            ),
          ),
        ],
      ),
    );
  }
}
