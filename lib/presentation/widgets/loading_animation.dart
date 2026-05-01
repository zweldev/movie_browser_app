import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;
  final Color? backgroundColor;

  const LoadingAnimation({
    super.key,
    this.size = 150.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Lottie.asset(
          'assets/jsons/loading.json',
          width: size,
          height: size,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }
}
