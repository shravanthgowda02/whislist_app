import 'package:flutter/material.dart';

class WishlistItem {
  final String id;
  final String title;
  final String? description;
  final String? url;
  final double? price;
  final String? category;
  final DateTime createdAt;
  final String? imageUrl; // New: High quality image support
  final Priority priority; // New: Must have vs nice to have
  final List<PriceHistory> priceHistory; // New: Price tracking
  bool isPurchased;

  WishlistItem({
    required this.id,
    required this.title,
    this.description,
    this.url,
    this.price,
    this.category,
    required this.createdAt,
    this.imageUrl,
    this.priority = Priority.niceToHave,
    this.priceHistory = const [],
    this.isPurchased = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'price': price,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'priority': priority.name,
      'priceHistory': priceHistory.map((p) => p.toJson()).toList(),
      'isPurchased': isPurchased,
    };
  }

  // Create from JSON
  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      url: json['url'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      priority: Priority.values.firstWhere(
        (p) => p.name == (json['priority'] as String? ?? 'niceToHave'),
        orElse: () => Priority.niceToHave,
      ),
      priceHistory:
          (json['priceHistory'] as List<dynamic>?)
              ?.map((p) => PriceHistory.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      isPurchased: json['isPurchased'] as bool? ?? false,
    );
  }

  // Create a copy with modifications
  WishlistItem copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    double? price,
    String? category,
    DateTime? createdAt,
    String? imageUrl,
    Priority? priority,
    List<PriceHistory>? priceHistory,
    bool? isPurchased,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      price: price ?? this.price,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
      priceHistory: priceHistory ?? this.priceHistory,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}

enum Priority { mustHave, niceToHave }

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.mustHave:
        return 'Must Have';
      case Priority.niceToHave:
        return 'Nice to Have';
    }
  }

  Color get color {
    switch (this) {
      case Priority.mustHave:
        return const Color(0xFFEF4444); // Red
      case Priority.niceToHave:
        return const Color(0xFF10B981); // Green
    }
  }
}

class PriceHistory {
  final double price;
  final DateTime date;

  PriceHistory({required this.price, required this.date});

  Map<String, dynamic> toJson() {
    return {'price': price, 'date': date.toIso8601String()};
  }

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      price: (json['price'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
