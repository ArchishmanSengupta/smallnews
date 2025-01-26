import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smallnews/data/images/app_images.dart';
import 'package:smallnews/data/strings/app_strings.dart';
import 'package:smallnews/view/pages/search_page.dart';
import 'package:smallnews/view/routes/app_routes.dart';
import 'package:smallnews/view/theme/app_theme.dart';

/// Reusable application bar component with consistent styling and behavior
///
/// Features:
/// - Centralized app bar configuration
/// - Theme-aware coloring
/// - Search navigation functionality
/// - Branding with logo and typography
///
/// Usage:
/// Use in scaffold's appBar property:
/// ```dart
/// Scaffold(
///   appBar: AppBarWidget.build(context),
///   ...
/// )
/// ```
class AppBarWidget {
  /// Constructs a configured [AppBar] with consistent branding and actions
  ///
  /// Parameters:
  /// - [context]: BuildContext for theme access and navigation
  ///
  /// Returns:
  /// A [PreferredSizeWidget] configured with:
  /// - Brand logo and title
  /// - Search action button
  /// - Theme-appropriate styling
  static PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      actions: [
        GestureDetector(
          onTap: () => _navigateToSearch(context),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.only(right: 20.0, top: 20.0),
            child: Icon(
              CupertinoIcons.search,
            ),
          ),
        )
      ],
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                AppImages.logo,
                height: 30,
                width: 30,
                filterQuality: FilterQuality.high,
              ),
            ),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Graphik',
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles navigation to search page with custom transition
  static void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      AppRoutes.createRoute(
        const SearchPage(),
      ),
    );
  }
}
