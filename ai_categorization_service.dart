/// AI-powered categorization service using pattern matching
class AICategorization {
  static const Map<String, List<String>> _categoryKeywords = {
    'Electronics': [
      'phone',
      'laptop',
      'computer',
      'tablet',
      'watch',
      'headphones',
      'camera',
      'console',
      'monitor',
      'keyboard',
      'mouse',
      'router',
      'speaker'
    ],
    'Fashion': [
      'shirt',
      'dress',
      'pants',
      'jacket',
      'shoes',
      'boots',
      'blouse',
      'sweater',
      'coat',
      'sneakers',
      'heels',
      'jeans',
      'suit'
    ],
    'Home & Garden': [
      'furniture',
      'sofa',
      'chair',
      'table',
      'lamp',
      'rug',
      'curtains',
      'plant',
      'decoration',
      'mirror',
      'cushion',
      'bedding'
    ],
    'Books & Media': [
      'book',
      'novel',
      'comic',
      'magazine',
      'vinyl',
      'dvd',
      'movie',
      'game',
      'audiobook'
    ],
    'Sports & Outdoors': [
      'bike',
      'skateboard',
      'hiking',
      'tent',
      'backpack',
      'camera',
      'balls',
      'equipment',
      'yoga',
      'fitness'
    ],
    'Beauty & Personal Care': [
      'skincare',
      'makeup',
      'perfume',
      'fragrance',
      'shampoo',
      'lotion',
      'beauty',
      'cosmetics',
      'razor'
    ],
    'Food & Beverages': [
      'coffee',
      'tea',
      'wine',
      'chocolate',
      'snacks',
      'spices',
      'kitchen',
      'cookbook'
    ],
    'Toys & Games': [
      'toy',
      'puzzle',
      'board game',
      'lego',
      'action figure',
      'doll'
    ],
  };

  /// Predict category based on title and description
  static String predictCategory(String title, {String? description}) {
    final text = '$title ${description ?? ''}'.toLowerCase();

    // Score each category based on keyword matches
    final scores = <String, int>{};

    _categoryKeywords.forEach((category, keywords) {
      int score = 0;
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          score += 2; // Title keywords weighted higher
          if (description != null && description.toLowerCase().contains(keyword)) {
            score += 1;
          }
        }
      }
      if (score > 0) {
        scores[category] = score;
      }
    });

    // Return category with highest score, or 'Other'
    if (scores.isEmpty) {
      return 'Other';
    }

    return scores.entries.fold(scores.entries.first, (prev, curr) {
      return curr.value > prev.value ? curr : prev;
    }).key;
  }

  /// Get suggested categories based on text
  static List<String> getSuggestions(String query) {
    if (query.isEmpty) {
      return _categoryKeywords.keys.toList();
    }

    final suggestions = <String>[];
    for (final category in _categoryKeywords.keys) {
      if (category.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(category);
      }
    }
    return suggestions;
  }
}
