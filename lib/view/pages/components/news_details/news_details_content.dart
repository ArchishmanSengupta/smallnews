import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smallnews/data/data.dart';

/// Content section for article metadata display
///
/// Displays:
/// - Source branding
/// - Article title
/// - Publication date
class NewsDetailsContent extends StatelessWidget {
  final ArticleModel article;

  const NewsDetailsContent({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSourceTag(),
          const SizedBox(height: 10),
          _buildTitle(),
          const SizedBox(height: 10),
          _buildPublishDate(),
        ],
      ),
    );
  }

  /// Source identification badge with styled container
  Widget _buildSourceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        article.source.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Primary article title display
  Widget _buildTitle() {
    return Text(
      article.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Formatted publication date display
  Widget _buildPublishDate() {
    return Text(
      'Published • ${DateFormat('d MMM yyyy').format(DateTime.parse(article.publishedAt))}',
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
    );
  }
}
