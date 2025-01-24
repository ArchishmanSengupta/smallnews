import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays a shimmer loading effect.
///
/// This widget is useful for showing a loading indicator with a shimmer effect
/// while data is being fetched or processed.
class ShimmerLoading extends StatelessWidget {
  /// Creates a [ShimmerLoading] widget.
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      /// The base color of the shimmer effect.
      baseColor: Colors.grey[300]!,

      /// The highlight color of the shimmer effect.
      highlightColor: Colors.grey[100]!,

      /// The child widget to which the shimmer effect is applied.
      child: Padding(
        padding: const EdgeInsets.all(16.0),

        /// A column containing the shimmer effect layout.
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// A container representing a placeholder image with a shimmer effect.
                Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),

                /// A column containing multiple shimmer lines.
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLine(),
                      SizedBox(height: 8),
                      ShimmerLine(),
                      SizedBox(height: 8),
                      ShimmerLine(),
                      SizedBox(height: 8),
                      ShimmerLine(width: 80),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// A widget that represents a single line with a shimmer effect.
///
/// This widget is used to create a placeholder line that mimics text loading.
class ShimmerLine extends StatelessWidget {
  /// The width of the shimmer line.
  final double width;

  /// Creates a [ShimmerLine] widget.
  ///
  /// The [width] parameter specifies the width of the shimmer line.
  const ShimmerLine({super.key, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
