import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/view.dart';

class NewsCard extends StatefulWidget {
  final ArticleModel article;
  final bool isLoading;

  const NewsCard({super.key, required this.article, this.isLoading = false});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _imageFailed = false;

  void _handleImageError() {
    if (!_imageFailed) {
      setState(() {
        _imageFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: widget.isLoading
          ? const ShimmerLoading()
          : _buildArticleContent(context),
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailsPage(article: widget.article),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.article.urlToImage != null &&
                  widget.article.urlToImage!.isNotEmpty &&
                  !_imageFailed)
                _buildImage(widget.article.urlToImage!),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAuthorAndTime(context),
                    const SizedBox(height: 8),
                    Text(
                      widget.article.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.article.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.article.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
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

  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Hero(
        tag: 'news_image_$imageUrl',
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 155,
          width: 130,
          memCacheWidth: 3 * 130,
          cacheKey: imageUrl,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 500),
          fadeInCurve: Curves.easeIn,
          progressIndicatorBuilder: (context, url, progress) =>
              Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 155,
              width: 130,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            SchedulerBinding.instance
                .addPostFrameCallback((_) => _handleImageError());
            return const SizedBox.shrink();
          },
        ),
      ),
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
            widget.article.author ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatTimeAgo(widget.article.publishedAt),
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
        widget.article.source.name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 8,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}
