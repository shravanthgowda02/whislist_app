import 'package:flutter/material.dart';
import '../models/wishlist_item.dart';
import '../services/storage_service.dart';
import '../services/collaborative_list_service.dart';
import 'add_edit_screen.dart';
import '../widgets/empty_state.dart';
import '../widgets/wishlist_card.dart';
import '../widgets/wishlist_logo.dart';
import 'analytics_screen.dart';


enum SortOption {
  dateAdded,
  priceLowToHigh,
  priceHighToLow,
  priority,
  alphabetical,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.dateAdded:
        return 'Date Added';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.priority:
        return 'Priority';
      case SortOption.alphabetical:
        return 'Alphabetical';
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StorageService _storageService;
  List<WishlistItem> _items = [];
  List<WishlistItem> _filteredItems = [];
  bool _showCompleted = true;
  String _filterCategory = 'All';
  SortOption _sortOption = SortOption.dateAdded;
  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _initApp();
  }

  Future<void> _initApp() async {
    await _storageService.init();
    await _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    final items = await _storageService.getAllItems();
    setState(() {
      _items = items;
      _isLoading = false;
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    // First filter
    _filteredItems = _items.where((item) {
      bool categoryMatch =
          _filterCategory == 'All' || item.category == _filterCategory;
      bool completionMatch =
          _showCompleted || (!_showCompleted && !item.isPurchased);
      return categoryMatch && completionMatch;
    }).toList();

    // Then sort
    _filteredItems.sort((a, b) {
      switch (_sortOption) {
        case SortOption.dateAdded:
          return b.createdAt.compareTo(a.createdAt);
        case SortOption.priceLowToHigh:
          final aPrice = a.price ?? 0;
          final bPrice = b.price ?? 0;
          return aPrice.compareTo(bPrice);
        case SortOption.priceHighToLow:
          final aPrice = a.price ?? 0;
          final bPrice = b.price ?? 0;
          return bPrice.compareTo(aPrice);
        case SortOption.priority:
          // Must have items first, then nice to have
          if (a.priority == b.priority) {
            return b.createdAt.compareTo(a.createdAt);
          }
          return a.priority == Priority.mustHave ? -1 : 1;
        case SortOption.alphabetical:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });
  }

  Future<void> _deleteItem(String id) async {
    await _storageService.deleteItem(id);
    await _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _togglePurchased(WishlistItem item) async {
    final updatedItem = item.copyWith(isPurchased: !item.isPurchased);
    await _storageService.updateItem(updatedItem);
    await _loadItems();
  }

  Future<void> _navigateToAddEdit([WishlistItem? item]) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddEditScreen(item: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (result == true) {
      await _loadItems();
    }
  }

  List<String> _getCategories() {
    final categories = _items
        .map((item) => item.category)
        .whereType<String>()
        .toSet();
    return ['All', ...categories];
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories();
    final purchasedCount = _items.where((item) => item.isPurchased).length;
    final totalCount = _items.length;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              WishlistLogo(
                size: 32,
                color: Theme.of(context).colorScheme.onPrimary,
                animated: true,
              ),
              const SizedBox(width: 12),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor ??
                      Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                child: const Text('Wishlist'),
              ),
            ],
          ),
          actions: [
            // Share list
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                CollaborativeListService.shareWishlist(
                  _items,
                  'My Wishlist',
                );
              },
              tooltip: 'Share wishlist',
            ),
            // Theme toggle
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: 'Toggle theme',
            ),
            // Sort menu
            PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort items',
              onSelected: (SortOption option) {
                setState(() {
                  _sortOption = option;
                  _applyFiltersAndSort();
                });
              },
              itemBuilder: (BuildContext context) {
                return SortOption.values.map((SortOption option) {
                  return PopupMenuItem<SortOption>(
                    value: option,
                    child: Row(
                      children: [
                        Icon(
                          _sortOption == option ? Icons.check : Icons.sort,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(option.displayName),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Tooltip(
                  message: 'Purchased / Total Items',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$purchasedCount/$totalCount',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (_items.isNotEmpty)
                          Text(
                            '\$${_items.fold<double>(0, (sum, item) => sum + (item.price ?? 0)).toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: _isLoading
              ? Center(
                  key: const ValueKey('loading'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Loading your wishlist...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )
              : _items.isEmpty
              ? EmptyState(onAddPressed: () => _navigateToAddEdit())
              : Column(
                  children: [
                    // Filter Section
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            ...categories.map(
                              (category) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: _filterCategory == category
                                      ? Matrix4.identity()
                                      : Matrix4.identity().scaled(0.95),
                                  child: FilterChip(
                                    label: Text(category),
                                    selected: _filterCategory == category,
                                    onSelected: (selected) {
                                      setState(() {
                                        _filterCategory = category;
                                        _applyFiltersAndSort();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Toggle Completed Items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _showCompleted,
                            onChanged: (value) {
                              setState(() {
                                _showCompleted = value ?? true;
                                _applyFiltersAndSort();
                              });
                            },
                          ),
                          const Text('Show completed items'),
                        ],
                      ),
                    ),
                    // Items List
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? Center(
                              child: Text(
                                'No items found',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: Duration(
                                      milliseconds: 300 + (index * 50),
                                    ),
                                    curve: Curves.easeOut,
                                    child: AnimatedPadding(
                                      padding: EdgeInsets.zero,
                                      duration: Duration(
                                        milliseconds: 300 + (index * 50),
                                      ),
                                      curve: Curves.easeOut,
                                      child: WishlistCard(
                                        item: item,
                                        onEdit: () => _navigateToAddEdit(item),
                                        onDelete: () => _deleteItem(item.id),
                                        onTogglePurchased: () =>
                                            _togglePurchased(item),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
        floatingActionButton: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.elasticOut,
          child: FloatingActionButton(
            onPressed: () => _navigateToAddEdit(),
            tooltip: 'Add new item',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
