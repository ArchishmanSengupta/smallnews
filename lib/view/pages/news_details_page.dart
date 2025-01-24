library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
  Widget _buildImage(String imageUrl) {
    final isEmpty = imageUrl.isEmpty;

    return Hero(
      tag: 'news_image_${widget.article.url}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isEmpty
            ? _buildErrorContainer()
            : CachedNetworkImage(
                imageUrl: imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) =>
                    _buildShimmerEffect(),
                errorWidget: (context, url, error) => _buildErrorContainer(),
              ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey[900],
      ),
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              _buildImage(widget.article.urlToImage ?? ''),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.3, 0.6],
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
                top: MediaQuery.of(context).padding.top + 10,
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
