import 'package:flutter/material.dart';

Widget buildEmptyFavorites(context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.brown.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_outline_rounded,
            size: 50,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'No Favorites Yet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Start saving your favorite wood products to easily find them later',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            context.go('/home');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.explore_outlined),
          label: const Text(
            'Explore Products',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

Widget buildEmptyView(context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        const Text(
          'No Favorites Yet',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Tap the heart icon on any product to add it to your favorites',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Browse Products'),
        ),
      ],
    ),
  );
}
