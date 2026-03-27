import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../models/wishlist_item.dart';

/// Collaborative list sharing service
class CollaborativeListService {
  /// Generate shareable link with encoded wishlist data
  static Future<void> shareWishlist(List<WishlistItem> items, String listName) async {
    try {
      // Create sharing message with basic export
      final message = '''Check out my wishlist "$listName"!\n\nItems: ${items.length}\n\n${items.map((i) => '• ${i.title} ${i.price != null ? '(\$${i.price!.toStringAsFixed(2)})' : ''}').join('\n')}\n\nShared via Wishlist App 🎁''';

      await Share.share(message, subject: listName);
    } catch (e) {
      print('Error sharing wishlist: $e');
    }
  }

  /// Export wishlist as JSON
  static String exportAsJson(List<WishlistItem> items) {
    final itemsJson = items.map((item) => item.toJson()).toList();
    return jsonEncode(itemsJson);
  }

  /// Import wishlist from JSON
  static List<WishlistItem> importFromJson(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => WishlistItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Unable to import - return empty list
      return [];
    }
  }

  /// Generate CSV export for spreadsheet compatibility
  static String exportAsCsv(List<WishlistItem> items) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      'Title,Description,URL,Price,Category,Priority,Purchased,Image URL,Created At',
    );

    // Data rows
    for (final item in items) {
      buffer.writeln(
        '"${item.title}","${item.description ?? ''}","${item.url ?? ''}",${item.price ?? ''},"${item.category ?? ''}","${item.priority.displayName}",${item.isPurchased},"${item.imageUrl ?? ''}","${item.createdAt}"',
      );
    }

    return buffer.toString();
  }

  /// Create invitation link (mock implementation)
  static String generateInviteLink(String listId) {
    return 'wishlist://invite/$listId?auth=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get summary statistics for sharing
  static Map<String, dynamic> getListStatistics(List<WishlistItem> items) {
    final totalPrice =
        items.fold<double>(0, (sum, item) => sum + (item.price ?? 0));
    final purchasedCount = items.where((item) => item.isPurchased).length;
    final categories = <String>{};

    for (final item in items) {
      if (item.category != null) {
        categories.add(item.category!);
      }
    }

    return {
      'totalItems': items.length,
      'totalValue': totalPrice,
      'purchasedCount': purchasedCount,
      'remainingValue': items
          .where((item) => !item.isPurchased)
          .fold<double>(0, (sum, item) => sum + (item.price ?? 0)),
      'categoryCount': categories.length,
      'averageItemPrice': items.isEmpty ? 0 : totalPrice / items.length,
    };
  }
}
