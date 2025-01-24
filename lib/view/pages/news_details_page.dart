/// A page that displays the details of a news article.
///
/// The [NewsDetailsPage] widget is a stateful widget that takes an [Article]
/// object as a required parameter. It displays the article's image, source,
/// title, and publication date, and provides a back button to navigate back
/// to the previous screen.
///
/// The page consists of a [Scaffold] with a [Column] containing a [Stack]
/// that displays the article's image with a gradient overlay, and a [WebViewArticle]
/// that loads the article's URL.
///
/// The [NewsDetailsPage] widget uses the following packages:
/// - `flutter/material.dart` for UI components.
/// - `intl/intl.dart` for date formatting.
/// - `smallnews/data/data.dart` for the [Article] model.
/// - `smallnews/ui/ui.dart` for the [WebViewArticle] widget.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/view.dart';

class NewsDetailsPage extends StatefulWidget {
  final Article article;

  const NewsDetailsPage({
    super.key,
    required this.article,
  });

  @override
  State<NewsDetailsPage> createState() => _NewsDetailsPageState();
}

class _NewsDetailsPageState extends State<NewsDetailsPage> {

   ClipRRect _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Hero(
        tag: 'news_image_$imageUrl',
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 300,
          cacheKey: imageUrl,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, child, loadingProgress) {
            return Container(
              height: 155,
              width: 130,
              color: Colors.grey[300],
              child: Center(
                child: LinearProgressIndicator(
                  value: loadingProgress.progress,
                ),
              ),
            );
          },
          errorWidget: (context, error, stackTrace) {
            return Container(
              height: 155,
              width: 130,
              color: Colors.grey[300],
              child: const Icon(Icons.error_outline),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              _buildImage(widget.article.urlToImage??''), 
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.article.source.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Published • ${DateFormat('d MMM yyyy').format(DateTime.parse(widget.article.publishedAt))}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
