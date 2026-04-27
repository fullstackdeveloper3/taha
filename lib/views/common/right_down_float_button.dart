import 'package:flutter/material.dart';

class RightDownFloatButton extends StatelessWidget {
  final VoidCallback onTap;
  const RightDownFloatButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: FloatingActionButton(
        onPressed: onTap,
        child: const Icon(Icons.add),
      ),
    );
  }
}
