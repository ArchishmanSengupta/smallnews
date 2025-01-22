import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smallnews/models/models.dart';

class NewsCard extends StatelessWidget {
  final Article article;
  final bool isLoading;

  const NewsCard({super.key, required this.article, this.isLoading = false});

  String _formatTimeAgo(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 130,
                height: 155,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerLine(),
                    const SizedBox(height: 8),
                    _buildShimmerLine(),
                    const SizedBox(height: 8),
                    _buildShimmerLine(),
                    const SizedBox(height: 8),
                    _buildShimmerLine(width: 100),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildShimmerLine({double width = double.infinity}) {
    return Container(
      width: width,
      height: 8,
      color: Colors.white,
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            //TODO: go inside
          },
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
                    fit: BoxFit.fitHeight,
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
                        fontSize: 10,
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
          _formatTimeAgo(article.publishedAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8),
        ),
      ],
    );
  }

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
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: isLoading ? _buildShimmer() : _buildArticleContent(context),
    );
  }
}
