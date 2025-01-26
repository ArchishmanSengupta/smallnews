import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/pages/components/components.dart';

/// Image overlay with navigation controls and content gradient
///
/// Features:
/// - Gradient overlay for text readability
/// - Back navigation button
/// - Safe area handling
class NewsImageOverlay extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onBackPressed;

  const NewsImageOverlay({
    super.key,
    required this.article,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context),
            const Spacer(),
            NewsDetailsContent(article: article),
          ],
        ),
      ),
    );
  }

  /// Custom app bar with back navigation
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.5),
          child: IconButton(
            onPressed: onBackPressed,
            icon: const Icon(
              CupertinoIcons.arrow_left,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
