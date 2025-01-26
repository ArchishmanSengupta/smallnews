import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smallnews/controller/controller.dart';
import 'package:smallnews/data/data.dart';
import 'package:smallnews/view/pages/pages.dart';
import 'package:smallnews/view/theme/app_theme.dart';

/// Animated search header with interactive controls
///
/// Implements:
/// - Custom back navigation
/// - Branded title display
/// - Contextual subtitle
/// - Animated search bar integration
class SearchAppBar extends StatelessWidget {
  final AnimationController animationController;
  final NewsSearchProvider controller;

  const SearchAppBar({
    super.key,
    required this.animationController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 24),
          AnimatedSearchBar(
            animationController: animationController,
            controller: controller,
          ),
        ],
      ),
    );
  }

  /// Constructs navigation bar with branded elements
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(
            CupertinoIcons.back,
            color: AppTheme.secondaryColor,
            semanticLabel: 'Close search',
          ),
        ),
        // Branded title display
        const Text(
          AppStrings.discover,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  /// Contextual guidance text
  Widget _buildSubtitle() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        AppStrings.newsFromAllAroundTheWorld,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
