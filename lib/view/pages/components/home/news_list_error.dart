import 'package:flutter/material.dart';
import 'package:smallnews/data/data.dart';

/// Error state presentation component
///
/// Features:
/// - Custom retry functionality
/// - Themed error display
/// - Responsive layout
class NewsListError extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const NewsListError({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Error: $errorMessage',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onRetry,
          child: const Text(AppStrings.retry),
        ),
      ],
    );
  }
}
