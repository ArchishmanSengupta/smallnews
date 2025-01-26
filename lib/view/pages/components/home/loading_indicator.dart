import 'package:flutter/cupertino.dart';

/// Standardized loading indicator component
///
/// Features:
/// - Consistent padding
/// - Platform-appropriate styling
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: CupertinoActivityIndicator(
          radius: 14,
        ),
      ),
    );
  }
}
