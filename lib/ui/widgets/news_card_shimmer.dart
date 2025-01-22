import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 100,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLine(),
                    SizedBox(height: 4),
                    ShimmerLine(),
                    SizedBox(height: 4),
                    ShimmerLine(),
                    SizedBox(height: 4),
                    ShimmerLine(width: 60),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class ShimmerLine extends StatelessWidget {
  final double width;

  const ShimmerLine({super.key, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 6,
      color: Colors.white,
    );
  }
}
