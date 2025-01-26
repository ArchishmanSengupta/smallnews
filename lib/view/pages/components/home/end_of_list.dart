import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';

/// A reusable widget indicating the end of a scrollable list
/// Displays a visual indicator with configurable messages and styling
///
/// ## Usage
/// Typically used as the last item in a [ListView] or [CustomScrollView]
///
/// ## Features
/// - Customizable messages and styling
/// - Responsive layout
/// - Themed icon and text hierarchy
/// - Built-in padding for list integration
class EndOfListIndicator extends StatelessWidget {
  /// Primary message displayed below the icon
  /// Defaults to [AppStrings.youveReachedTheEnd]
  final String message;

  /// Base color used for both icon and text
  /// Applies opacity automatically for visual hierarchy
  /// Defaults to Colors.grey
  final Color color;

  /// Size of the leading icon in logical pixels
  /// Defaults to 40px
  final double iconSize;

  /// Vertical spacing between elements in logical pixels
  /// Used consistently between all elements
  /// Defaults to 16px
  final double spacing;

  /// Creates an end-of-list indicator with customizable properties
  const EndOfListIndicator({
    super.key,
    this.message = AppStrings.youveReachedTheEnd,
    this.color = Colors.grey,
    this.iconSize = 40,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Primary icon with subtle opacity
          Icon(
            Icons.check_circle_outline,
            size: iconSize,
            color: color.withOpacity(0.6),
          ),

          SizedBox(height: spacing),

          // Main message with medium emphasis
          Text(
            message,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: spacing / 2), // Half spacing for visual grouping

          // Secondary message with lower emphasis
          Text(
            AppStrings.noMoreArticlesTo,
            style: TextStyle(
              color: color.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
