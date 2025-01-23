import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/ui/ui.dart';
import 'package:smallnews/util/util.dart';

/// A widget that displays a news article in a card format.
///
/// The [NewsCard] shows the article's image, title, author, publication time, and source.
/// It also provides a tappable interface to navigate to the article's details page.
class NewsCard extends StatelessWidget {
  /// The [Article] instance representing the article to display.
  final Article article;

  /// A flag indicating whether the card is in a loading state.
  ///
  /// If `true`, a shimmer loading animation will be displayed instead of the article content.
  final bool isLoading;

  /// Creates a [NewsCard] widget.
  ///
  /// The [article] parameter must not be null. The [isLoading] parameter defaults to `false`.
  const NewsCard({super.key, required this.article, this.isLoading = false});

  /// Builds the main content of the article, including the image, title, and metadata.
  Widget _buildArticleContent(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          // Navigates to the [NewsDetailsPage] when the article card is tapped.
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailsPage(article: article),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    article.urlToImage!,
                    height: 155,
                    width: 130,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 155,
                        width: 130,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 155,
                        width: 130,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error_outline),
                      );
                    },
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAuthorAndTime(context),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (article.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        article.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 10),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildSource(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Builds a row displaying the author's name and the publication time.
  Widget _buildAuthorAndTime(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 8,
          backgroundImage: NetworkImage(
            'https://xsgames.co/randomusers/avatar.php?g=male',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            article.author ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatTimeAgo(article.publishedAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8),
        ),
      ],
    );
  }

  /// Builds a chip-like widget displaying the article's source name.
  Widget _buildSource(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        article.source.name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 8,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  /// Builds the overall widget tree for the [NewsCard].
  ///
  /// Displays a shimmer loading animation if [isLoading] is `true`, or the article
  /// content otherwise.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: isLoading ? const ShimmerLoading() : _buildArticleContent(context),
    );
  }
}
