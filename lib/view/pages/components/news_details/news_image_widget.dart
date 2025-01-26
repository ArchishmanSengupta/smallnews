import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Hero-animated image component with loading and error states
///
/// Features:
/// - Cached network image loading
/// - Shimmer loading effect
/// - Error state handling
/// - Hero animation coordination
class NewsImageWidget extends StatelessWidget {
  final String imageUrl;
  final String articleUrl;

  const NewsImageWidget({
    super.key,
    required this.imageUrl,
    required this.articleUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = imageUrl.isEmpty;

    return Hero(
      tag: 'news_image_$articleUrl',
      child: isEmpty
          ? _buildErrorContainer()
          : CachedNetworkImage(
              imageUrl: imageUrl,
              height: 300,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, progress) =>
                  _buildShimmerEffect(),
              errorWidget: (context, url, error) => _buildErrorContainer(),
            ),
    );
  }

  /// Loading state shimmer animation
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

  /// Unified error state presentation
  Widget _buildErrorContainer() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.black,
    );
  }
}
