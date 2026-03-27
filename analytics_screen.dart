import 'package:flutter/material.dart';
import '../models/wishlist_item.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<WishlistItem> items;

  const AnalyticsScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final totalItems = items.length;
    final purchasedItems = items.where((e) => e.isPurchased).length;
    final pendingItems = totalItems - purchasedItems;

    final totalValue =
        items.fold<double>(0, (sum, item) => sum + (item.price ?? 0));

    final mostExpensive = items.isEmpty
        ? null
        : items.reduce((a, b) =>
            (a.price ?? 0) > (b.price ?? 0) ? a : b);

    final mustHaveCount =
        items.where((e) => e.priority == Priority.mustHave).length;

    final niceToHaveCount =
        items.where((e) => e.priority == Priority.niceToHave).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            // 🔥 Summary Cards
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildCard("Total Items", totalItems.toString()),
                _buildCard("Purchased", purchasedItems.toString()),
                _buildCard("Pending", pendingItems.toString()),
                _buildCard("Total Value", "₹${totalValue.toStringAsFixed(2)}"),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 Most Expensive Item
            if (mostExpensive != null)
              _buildHighlightCard(
                "Most Expensive Item",
                mostExpensive.title,
                "₹${mostExpensive.price ?? 0}",
              ),

            const SizedBox(height: 20),

            // 🔥 Priority Breakdown
            _buildProgress(
              context,
              "Must Have",
              mustHaveCount,
              totalItems,
              Colors.red,
            ),

            const SizedBox(height: 10),

            _buildProgress(
              context,
              "Nice To Have",
              niceToHaveCount,
              totalItems,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Simple Stat Card
  Widget _buildCard(String title, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 🔹 Highlight Card
  Widget _buildHighlightCard(String title, String item, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 10),
          Text(item,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  // 🔹 Progress Bar
  Widget _buildProgress(
      BuildContext context,
      String label,
      int value,
      int total,
      Color color) {
    final percent = total == 0 ? 0.0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label ($value)"),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: percent,
          color: color,
          backgroundColor: color.withOpacity(0.2),
        ),
      ],
    );
  }
}
