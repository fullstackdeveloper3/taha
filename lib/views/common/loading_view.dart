import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final bool isLoading;
  const LoadingView({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
