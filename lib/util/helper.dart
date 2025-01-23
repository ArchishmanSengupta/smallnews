/// An extension on the [String] class that provides additional utility methods.
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  ///
  /// Returns a new string with the first letter converted to uppercase
  /// and the remaining letters unchanged.
  ///
  /// Example:
  /// ```dart
  /// print('hello'.capitalize()); // Output: 'Hello'
  /// ```
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

/// Formats the given date string into a relative "time ago" string.
///
/// Returns a string like "2d ago", "5h ago", or "15m ago" based on the difference
/// between the current time and the parsed [dateStr].
String formatTimeAgo(String dateStr) {
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

/// A list of news categories used in the application.
///
/// This list contains the following categories:
/// - 'general', 'technology', 'Business', 'sports', 'health', 'entertainment'
///
/// These categories can be used to filter news articles based on the user's interests.
final List<String> categories = [
  'general',
  'Technology',
  'Business',
  'sports',
  'health',
  'entertainment',
];
