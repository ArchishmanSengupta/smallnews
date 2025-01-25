import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';

class EndOfListIndicator extends StatelessWidget {
  final String message;
  final Color color;
  final double iconSize;
  final double spacing;

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
          Icon(
            Icons.check_circle_outline,
            size: iconSize,
            color: color.withOpacity(0.6),
          ),
          SizedBox(height: spacing),
          Text(
            message,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: spacing / 2),
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
