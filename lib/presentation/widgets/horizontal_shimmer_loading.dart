import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HorizontalShimmerLoading extends StatelessWidget {
  final double height;
  final double itemWidth;
  final int itemCount;
  final double spacing;

  const HorizontalShimmerLoading({
    super.key,
    required this.height,
    required this.itemWidth,
    this.itemCount = 6,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: spacing),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: itemWidth,
            margin: EdgeInsets.only(right: spacing),
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              highlightColor: Theme.of(context).colorScheme.surface,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Container(color: Colors.white)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(height: 12, width: 60, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
