import 'package:flutter/material.dart';

class PGDetailScreen extends StatelessWidget {
  final String pgId;

  const PGDetailScreen({super.key, required this.pgId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PG Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text('PG Details for ID: $pgId'),
            const SizedBox(height: 8),
            const Text('Detailed view coming soon!'),
          ],
        ),
      ),
    );
  }
}
