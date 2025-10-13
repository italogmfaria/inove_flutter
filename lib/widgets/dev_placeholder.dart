import 'package:flutter/material.dart';

class DevPlaceholder extends StatelessWidget {
  const DevPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.yellow,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'EM DESENVOLVIMENTO',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

