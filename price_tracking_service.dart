import '../models/wishlist_item.dart';

/// Price tracking and alert service
class PriceTrackingService {
  /// Track price change and return alert message if price dropped below target
  static String? checkPriceAlert(
    WishlistItem item,
    double newPrice,
    double? targetPrice,
  ) {
    if (item.price == null) return null;

    final oldPrice = item.price!;

    // Price dropped significantly
    if (newPrice < oldPrice * 0.9) {
      final savings = oldPrice - newPrice;
      return '💰 Price dropped by \$${savings.toStringAsFixed(2)}! Now \$${newPrice.toStringAsFixed(2)}';
    }

    // Price at or below target
    if (targetPrice != null && newPrice <= targetPrice) {
      return '🎯 Target price reached! \$${newPrice.toStringAsFixed(2)}';
    }

    return null;
  }

  /// Calculate average price from history
  static double getAveragePrice(WishlistItem item) {
    if (item.priceHistory.isEmpty) return item.price ?? 0;

    final total =
        item.priceHistory.fold<double>(0, (sum, ph) => sum + ph.price);
    return total / item.priceHistory.length;
  }

  /// Calculate lowest price from history
  static double? getLowestPrice(WishlistItem item) {
    if (item.priceHistory.isEmpty) return item.price;

    return item.priceHistory
        .fold<double>(item.price ?? double.infinity, (lowest, ph) {
      return ph.price < lowest ? ph.price : lowest;
    });
  }

  /// Calculate highest price from history
  static double? getHighestPrice(WishlistItem item) {
    if (item.priceHistory.isEmpty) return item.price;

    return item.priceHistory.fold<double>(0, (highest, ph) {
      return ph.price > highest ? ph.price : highest;
    });
  }

  /// Get price trend (up, down, stable)
  static String getPriceTrend(WishlistItem item) {
    if (item.priceHistory.length < 2) return 'No trend';

    final recent = item.priceHistory.last.price;
    final previous = item.priceHistory[item.priceHistory.length - 2].price;

    if (recent < previous * 0.95) return '📉 Falling';
    if (recent > previous * 1.05) return '📈 Rising';
    return '➡️ Stable';
  }

  /// Get formatted price with currency
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }
}
