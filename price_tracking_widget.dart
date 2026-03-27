import 'package:flutter/material.dart';
import '../models/wishlist_item.dart';
import '../services/price_tracking_service.dart';

/// Widget to display price tracking information
class PriceTrackingWidget extends StatelessWidget {
  final WishlistItem item;

  const PriceTrackingWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.price == null) {
      return const SizedBox.shrink();
    }

    final lowestPrice = PriceTrackingService.getLowestPrice(item);
    final highestPrice = PriceTrackingService.getHighestPrice(item);
    final trend = PriceTrackingService.getPriceTrend(item);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Tracking',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current: ${PriceTrackingService.formatPrice(item.price!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (lowestPrice != null && highestPrice != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Range: ${PriceTrackingService.formatPrice(lowestPrice)} - ${PriceTrackingService.formatPrice(highestPrice)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withAlpha((255 * 0.7).toInt()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
