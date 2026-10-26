import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../data/database/app_database.dart' hide SaleItem;
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/customer_repository.dart';
import '../../../../data/repositories/loyalty_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/sale_repository.dart';
import '../../../../models/product.dart';
import '../../../../models/sale_item.dart';
import '../../../sales/presentation/screens/receipt_screen.dart';
import '../utils/checkout_helpers.dart';
import '../utils/parked_sales.dart';
import '../widgets/cart_item.dart';
import '../widgets/pos_search_field.dart';
import '../widgets/barcode_scanner_sheet.dart';
import '../widgets/quantity_button.dart';
import '../widgets/redeem_config.dart';
import '../widgets/tile_step.dart';

class PosScreen extends StatefulWidget {
  final bool showAppBar;
  const PosScreen({super.key, this.showAppBar = true});

  @override
  PosScreenState createState() => PosScreenState();
}

class PosScreenState extends State<PosScreen> {
  final ProductRepository _productRepository = ProductRepository(appDatabase);
  final SaleRepository _saleRepository = SaleRepository(appDatabase,
      onLowStock: (productName, remainingStock) {
    notificationStore.push(
      type: AppNotificationType.stock,
      title: remainingStock <= 0 ? 'Out of stock' : 'Low stock',
      message:
          '$productName is running low — $remainingStock '
          'unit${remainingStock == 1 ? '' : 's'} left.',
    );
  });
  final CustomerRepository _customerRepository = CustomerRepository(
    appDatabase,
  );
  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  final LoyaltyRepository _loyaltyRepository = LoyaltyRepository(appDatabase);

  final TextEditingController _searchController = TextEditingController();

  StreamSubscription<List<Product>>? _productsSubscription;
  StreamSubscription<List<Customer>>? _customersSubscription;

  List<Product> _products = [];
  List<Customer> _customers = [];

  final List<CartItem> _cart = [];

  String _searchQuery = '';

  /// Presentation-level category chip filter. Tapping a chip narrows the
  /// grid on top of the existing search text (pure UI, no side effects).
  String? _categoryFilter;

  bool _isLoading = true;
  bool _isLoadingSettings = true;
  bool _hasError = false;

  String _currency = 'USD';

  /// Whether haptic feedback is enabled (stored in SharedPreferences).
  /// Defaults to enabled until the stored preference is loaded.
  bool _hapticFeedbackEnabled = true;

  /// Phase G: tax / VAT settings read from business settings.
  double? _taxRate;
  bool _taxInclusive = false;

  String? _stockMessage;

  @override
  void initState() {
    super.initState();

    parkedSalesStore.addListener(_onParkedSalesChanged);
    _watchProducts();
    _watchCustomers();
    _loadBusinessSettings();
    _loadHapticFeedbackSetting();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && parkedSalesStore.sales.isNotEmpty) {
        _showRestoreHeldCartPrompt();
      }
    });
  }

  Future<void> _loadHapticFeedbackSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _hapticFeedbackEnabled = prefs.getBool('haptic_feedback_enabled') ?? true;
    });
  }

  void _hapticMedium() {
    if (!_hapticFeedbackEnabled) return;
    Haptics.vibrate(HapticsType.medium);
  }

  void _hapticHeavy() {
    if (!_hapticFeedbackEnabled) return;
    Haptics.vibrate(HapticsType.heavy);
  }

  void _onParkedSalesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _watchProducts() {
    _productsSubscription?.cancel();

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _productsSubscription = _productRepository.watchProducts().listen(
      (products) {
        if (!mounted) {
          return;
        }

        setState(() {
          _products = products;
          _isLoading = false;
          _hasError = false;
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
    );
  }

  void _watchCustomers() {
    _customersSubscription?.cancel();

    _customersSubscription = _customerRepository.watchCustomers().listen((
      customers,
    ) {
      if (!mounted) {
        return;
      }

      setState(() {
        _customers = customers;
      });
    }, onError: (_) {});
  }

  Future<void> _loadBusinessSettings() async {
    try {
      final settings = await _businessSettingsRepository.getSettings();

      if (!mounted) {
        return;
      }

      setState(() {
        _currency = settings.currency;
        _taxRate = settings.taxRate;
        _taxInclusive = settings.taxInclusive;
        _isLoadingSettings = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingSettings = false;
      });
    }
  }

  Future<void> refreshBusinessSettings() async {
    await _loadBusinessSettings();
  }


  /// Awards loyalty points to a customer after a completed sale.
  /// Uses the configured earn rate and the customer's tier multiplier.
  Future<void> _awardLoyalty({
    required String? customerId,
    required double amount,
  }) async {
    if (customerId == null) return;

    try {
      final settings = await _businessSettingsRepository.getSettings();
      if (!settings.loyaltyEnabled) return;

      final customer = await _customerRepository.getCustomerById(customerId);
      if (customer == null) return;

      final earned = LoyaltyService.pointsEarned(
        amount,
        earnRate: settings.loyaltyEarnRate,
        currentPoints: customer.loyaltyPoints,
      );

      if (earned <= 0) return;

      await _loyaltyRepository.earnPoints(customerId, earned);
    } catch (_) {
      // Loyalty is best-effort — never block a sale on it.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadBusinessSettings();
  }

  @override
  void dispose() {
    parkedSalesStore.removeListener(_onParkedSalesChanged);
    _productsSubscription?.cancel();
    _customersSubscription?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // PRODUCTS
  // ===========================================================================

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    final category = _categoryFilter;

    final source = category == null || category.isEmpty
        ? _products
        : _products
            .where((product) => product.category.trim() == category)
            .toList();

    if (query.isEmpty) {
      return source;
    }

    final matches = source.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
    }).toList();

    matches.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();

      final aExact = aName == query;
      final bExact = bName == query;

      if (aExact && !bExact) {
        return -1;
      }

      if (!aExact && bExact) {
        return 1;
      }

      final aStarts = aName.startsWith(query);
      final bStarts = bName.startsWith(query);

      if (aStarts && !bStarts) {
        return -1;
      }

      if (!aStarts && bStarts) {
        return 1;
      }

      return aName.compareTo(bName);
    });

    return matches;
  }

  // ===========================================================================
  // CART
  // ===========================================================================

  double get _subtotal {
    return _cart.fold(0, (total, item) => total + item.total);
  }

  int get _totalItems {
    return _cart.fold(0, (total, item) => total + item.quantity);
  }

  int _getCartQuantity(String productId) {
    for (final item in _cart) {
      if (item.product.id == productId) {
        return item.quantity;
      }
    }

    return 0;
  }

  void _addToCart(Product product, {String? batchNumber, String? expiryDate}) {
    final existingIndex = _cart.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final existingItem = _cart[existingIndex];

      if (existingItem.quantity >= product.stockQuantity) {
        _hapticHeavy();
        setState(() {
          _stockMessage =
              'Not enough stock for ${product.name} '
              '(SKU: ${product.sku}). '
              'Available stock: ${product.stockQuantity}.';
        });

        return;
      }

      _hapticMedium();
      setState(() {
        existingItem.quantity++;
        _stockMessage = null;
      });

      return;
    }

    if (product.stockQuantity <= 0) {
      _hapticHeavy();
      setState(() {
        _stockMessage =
            '${product.name} (SKU: ${product.sku}) is out of stock.';
      });

      return;
    }

    _hapticMedium();
    setState(() {
      _cart.add(
        CartItem(
          product: product,
          quantity: 1,
          batchNumber: batchNumber,
          expiryDate: expiryDate,
        ),
      );
      _stockMessage = null;
    });
  }

  void _handleBarcodeSubmitted(String value) {
    final barcode = value.trim();

    if (barcode.isEmpty) return;

    final matches = _products
        .where((product) => product.barcode.trim() == barcode)
        .toList();

    if (matches.length != 1) {
      setState(() {
        _stockMessage = matches.isEmpty
            ? 'No product found for barcode: $barcode'
            : 'Multiple products use barcode: $barcode';
      });
      return;
    }

    final product = matches.single;
    final previousQuantity = _getCartQuantity(product.id);

    _addProductToCart(product);

    final newQuantity = _getCartQuantity(product.id);

    if (newQuantity > previousQuantity) {
      _searchController.clear();

      setState(() {
        _searchQuery = '';
      });
    }
  }

  /// Launches the barcode scanner bottom sheet. On a successful scan, looks up
  /// the product by barcode and adds it to the cart.
  Future<void> _scanBarcode() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => const BarcodeScannerSheet(),
    );

    if (result == null || result.isEmpty || !mounted) return;

    final barcode = result.trim();
    final matches = _products
        .where((product) => product.barcode.trim() == barcode)
        .toList();

    if (matches.length != 1) {
      setState(() {
        _stockMessage = matches.isEmpty
            ? 'No product found for barcode: $barcode'
            : 'Multiple products use barcode: $barcode';
      });
      return;
    }

    final product = matches.single;
    final previousQuantity = _getCartQuantity(product.id);

    _addProductToCart(product);

    final newQuantity = _getCartQuantity(product.id);
    if (newQuantity > previousQuantity) {
      _searchController.clear();
      setState(() {
        _searchQuery = '';
      });
    }
  }

  /// Prompts the operator to optionally enter a batch number and expiry date
  /// before adding an item to the cart. Returns null if skipped.
  Future<Map<String, String>?> _promptBatchExpiry(Product product) async {
    final batchController = TextEditingController();
    final expiryController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Batch & Expiry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add traceability for ${product.name}',
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              TextField(
                controller: batchController,
                decoration: const InputDecoration(
                  labelText: 'Batch number',
                  hintText: 'e.g. BATCH-2024-001',
                  prefixIcon: Icon(Icons.label_outlined),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              TextField(
                controller: expiryController,
                decoration: const InputDecoration(
                  labelText: 'Expiry date',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop({
                'batchNumber': batchController.text.trim().isEmpty
                    ? null
                    : batchController.text.trim(),
                'expiryDate': expiryController.text.trim().isEmpty
                    ? null
                    : expiryController.text.trim(),
              }),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    batchController.dispose();
    expiryController.dispose();

    if (!mounted) return null;
    return result;
  }

  /// Adds a product to the cart after an optional batch/expiry prompt.
  Future<void> _addProductToCart(Product product) async {
    final batchInfo = await _promptBatchExpiry(product);
    if (!mounted) return;

    _addToCart(
      product,
      batchNumber: batchInfo?['batchNumber'],
      expiryDate: batchInfo?['expiryDate'],
    );
  }

  void _increaseQuantity(CartItem item) {
    if (item.quantity >= item.product.stockQuantity) {
      setState(() {
        _stockMessage =
            'Not enough stock for ${item.product.name} '
            '(SKU: ${item.product.sku}). '
            'Available stock: ${item.product.stockQuantity}.';
      });

      return;
    }

    setState(() {
      item.quantity++;
      _stockMessage = null;
    });
  }

  void _decreaseQuantity(CartItem item) {
    if (item.quantity <= 1) {
      setState(() {
        _cart.remove(item);
        _stockMessage = null;
      });

      return;
    }

    setState(() {
      item.quantity--;
      _stockMessage = null;
    });
  }

  void _removeFromCart(CartItem item) {
    setState(() {
      _cart.remove(item);
      _stockMessage = null;
    });
  }

  void _clearCart() {
    if (_cart.isEmpty) {
      return;
    }

    setState(() {
      _cart.clear();
      _stockMessage = null;
    });
  }

  // ===========================================================================
  // HELD (PARKED) SALES
  // ===========================================================================

  void _parkCurrentSale() {
    if (_cart.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final label = 'Hold $time • $_totalItems items';

    parkedSalesStore.park(
      ParkedSale(
        label: label,
        parkedAt: now,
        customerId: null,
        items: _cart
            .map(
              (item) => ParkedItem(
                productId: item.product.id,
                name: item.product.name,
                price: item.product.sellingPrice,
                cost: item.product.purchasePrice,
                qty: item.quantity,
              ),
            )
            .toList(),
      ),
    );

    setState(() {
      _cart.clear();
      _stockMessage = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sale parked — $label'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Parks the current POS cart to the [parkedSalesStore] if it is not empty.
  ///
  /// Used by the app shell when the session locks or signs out so an active
  /// cart is preserved across the lock boundary. Returns true if a cart was
  /// parked, false if the cart was empty.
  bool parkActiveCart() {
    if (_cart.isEmpty) return false;
    _parkCurrentSale();
    return true;
  }

  /// Restores the most recently parked sale into the current cart.
  ///
  /// Used by the app shell when the session unlocks or a staff member signs
  /// back in, so an in-progress sale can be resumed. Returns the restored
  /// [ParkedSale], or null if there are no parked sales.
  ParkedSale? restoreLastParkedCart() {
    final sales = parkedSalesStore.sales;
    if (sales.isEmpty) return null;
    final recalled = parkedSalesStore.recall(sales.length - 1);
    if (recalled == null) return null;

    setState(() {
      for (final parked in recalled.items) {
        final product = _products.where((p) => p.id == parked.productId).firstOrNull;
        if (product == null) continue;
        final existingIndex = _cart.indexWhere((item) => item.product.id == parked.productId);
        if (existingIndex >= 0) {
          _cart[existingIndex] = CartItem(
            product: product,
            quantity: _cart[existingIndex].quantity + parked.qty,
          );
        } else {
          _cart.add(CartItem(product: product, quantity: parked.qty));
        }
      }
    });

    return recalled;
  }

  Future<void> _showHeldSales() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final sales = parkedSalesStore.sales;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  0,
                  AppDimensions.screenPadding,
                  AppDimensions.spacingLg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Held Sales',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sales.length} waiting to resume',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    if (sales.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spacingLg,
                        ),
                        child: Icon(
                          Icons.pause_circle_outlined,
                          size: 48,
                          color: colorScheme.outline,
                        ),
                      )
                    else
                      ...List.generate(sales.length, (index) {
                        final sale = sales[index];

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: AppDimensions.spacingSm,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  colorScheme.primaryContainer,
                              child: Icon(
                                Icons.pause_rounded,
                                size: 20,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              sale.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${sale.items.length} product lines • '
                              '$_currency ${sale.subtotal.toStringAsFixed(2)}',
                            ),
                            trailing: IconButton(
                              tooltip: 'Discard',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                              ),
                              onPressed: () {
                                parkedSalesStore.removeAt(index);
                                setSheetState(() {});
                              },
                            ),
                            onTap: () {
                              final recalled =
                                  parkedSalesStore.recall(index);

                              if (recalled == null) {
                                return;
                              }

                              setState(() {
                                _cart.clear();

                                for (final parked in recalled.items) {
                                  final product = _products
                                      .where(
                                        (p) => p.id == parked.productId,
                                      )
                                      .firstOrNull;

                                  if (product == null) {
                                    continue;
                                  }

                                  _cart.add(
                                    CartItem(
                                      product: product,
                                      quantity: parked.qty,
                                    ),
                                  );
                                }

                                _stockMessage = null;
                              });

                              Navigator.of(sheetContext).pop();
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Shows a one-time prompt on POS startup when there are held (parked) carts,
  /// inviting the operator to restore the most recent one. Styled with BrandCard
  /// and the royal brand gradient per the visual polish spec.
  Future<void> _showRestoreHeldCartPrompt() async {
    if (!mounted || parkedSalesStore.sales.isEmpty) return;

    final sales = parkedSalesStore.sales;
    final latest = sales.last;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final restore = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BrandCard(
            padding: const EdgeInsets.all(24),
            radius: 24,
            accent: AppColors.royalStart,
            gradientBorder: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Royal gradient header band
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppDecor.royalGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.35),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.schedule_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Restore held cart?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${sales.length} held cart${sales.length == 1 ? '' : 's'} waiting',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.pause_circle_outlined,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              latest.label,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${latest.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.brandMint,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Resume this held sale and continue checkout? Items, quantities and pricing are preserved.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'Not now',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppDecor.royalGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.30),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.playlist_add_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Restore cart',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || restore != true) return;

    // Restore the most recently held cart into the current cart.
    final recalled = parkedSalesStore.recall(sales.length - 1);
    if (recalled == null) return;

    setState(() {
      _cart.clear();
      for (final parked in recalled.items) {
        final product = _products.where((p) => p.id == parked.productId).firstOrNull;
        if (product == null) continue;
        final existingIndex = _cart.indexWhere((item) => item.product.id == parked.productId);
        if (existingIndex >= 0) {
          _cart[existingIndex] = CartItem(
            product: product,
            quantity: _cart[existingIndex].quantity + parked.qty,
          );
        } else {
          _cart.add(CartItem(product: product, quantity: parked.qty));
        }
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Held cart restored — ${recalled.label}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ===========================================================================
  // NOTIFICATION
  // ===========================================================================

  Widget _buildStockNotification({
    required String message,
    required VoidCallback onDismiss,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 19,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          IconButton(
            onPressed: onDismiss,
            tooltip: 'Dismiss',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CHECKOUT
  // ===========================================================================

  /// Small loyalty summary shown under the customer selector at checkout.
  Widget _buildLoyaltyPreview(Customer customer) {    final tier = LoyaltyService.tierFor(customer.loyaltyPoints);
    final next = LoyaltyService.nextTierFor(customer.loyaltyPoints);
    final progress = LoyaltyService.progressToNextTier(customer.loyaltyPoints);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tertiary.withValues(alpha: 0.14),
            AppColors.tertiary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.tertiary, AppColors.tertiaryDark],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${tier.name} member',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.tertiaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${customer.loyaltyPoints} pts',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.tertiaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColors.tertiary.withValues(alpha: 0.18),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.tertiaryDark,
                    ),
                  ),
                ),
                if (next != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${next.minPoints - customer.loyaltyPoints} pts to '
                    '${next.name}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tertiaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Loads the customer's redeemable balance and the configured redeem value
  /// so the checkout redemption control can be offered.
  Future<void> _loadRedeemConfig(
    String customerId,
    void Function(RedeemConfig) onLoaded,
  ) async {
    try {
      final settings = await _businessSettingsRepository.getSettings();
      if (!settings.loyaltyEnabled) {
        onLoaded(const RedeemConfig(balance: 0, redeemValue: 0));
        return;
      }

      final customer = await _customerRepository.getCustomerById(customerId);
      onLoaded(
        RedeemConfig(
          balance: customer?.pointsBalance ?? 0,
          redeemValue: settings.loyaltyRedeemValue,
        ),
      );
    } catch (_) {
      onLoaded(const RedeemConfig(balance: 0, redeemValue: 0));
    }
  }

  /// The redemption control shown in checkout: a slider + quick presets that
  /// lets the cashier spend the customer's points against this sale.
  Widget _buildRedeemControl({
    required int redeemPoints,
    required int maxRedeemable,
    required double redeemValue,
    required ValueChanged<int> onChanged,
  }) {
    final money = LoyaltyService.redeemValue(
      redeemPoints,
      redeemValue: redeemValue,
    );

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.redeem_rounded,
                size: 18,
                color: AppColors.tertiaryDark,
              ),
              const SizedBox(width: 8),
              Text(
                'Redeem points',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.tertiaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '$redeemPoints pts = $_currency ${money.toStringAsFixed(2)}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.tertiaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: redeemPoints.toDouble().clamp(0, maxRedeemable.toDouble()),
            max: maxRedeemable <= 0 ? 1 : maxRedeemable.toDouble(),
            divisions: maxRedeemable <= 0 ? null : maxRedeemable,
            label: '$redeemPoints pts',
            activeColor: AppColors.tertiaryDark,
            onChanged: maxRedeemable <= 0
                ? null
                : (value) => onChanged(value.round()),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => onChanged(0),
                child: const Text('None'),
              ),
              const Spacer(),
              TextButton(
                onPressed: maxRedeemable <= 0
                    ? null
                    : () => onChanged(maxRedeemable),
                child: Text('Max ($maxRedeemable)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _showCheckoutDialog() async {
    if (_cart.isEmpty) {
      return null;
    }

    final discountController = TextEditingController(text: '0.00');

    // ── Phase G: split payments ──
    // A single cash line is the default (backward compatible). Additional
    // lines let the customer split the amount due across multiple methods.
    final taxRate = _taxRate ?? 0.0;
    final taxInclusive = _taxInclusive;
    final initialTaxable = _subtotal.clamp(0.0, double.infinity);
    final initialTax = taxInclusive
        ? initialTaxable * taxRate / (100 + taxRate)
        : initialTaxable * taxRate / 100;
    final initialTotal = taxInclusive ? initialTaxable : initialTaxable + initialTax;

    final paymentMethodMeta = <String, ({
      IconData icon,
      Color color,
    })>{
      'cash': (icon: Icons.payments_outlined, color: AppColors.moneyTint.last),
      'card': (icon: Icons.credit_card_outlined, color: AppColors.primary),
      'bank_transfer': (icon: Icons.account_balance_outlined,
          color: AppColors.info),
      'qr_payment': (icon: Icons.qr_code_rounded, color: AppColors.brandAmber),
      'wallet': (icon: Icons.account_balance_wallet_outlined,
          color: AppColors.brandMint),
    };

    final paymentMethodLabel = <String, String>{
      'cash': 'Cash',
      'card': 'Card',
      'bank_transfer': 'Bank Transfer',
      'qr_payment': 'QR Payment',
      'wallet': 'Wallet',
    };

    List<_SplitLine> splitLines = [
      _SplitLine(method: 'cash', amount: initialTotal),
    ];

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double discount = 0.0;

        String? selectedCustomerId;
        bool isPercentMode = false;

        String? validationMessage;
        String? discountValidationMessage;
        bool isProcessing = false;

        // Loyalty redemption state (points spent at this checkout).
        int redeemPoints = 0;
        int redeemableBalance = 0;
        double redeemValue = 0.01;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final isDark = theme.brightness == Brightness.dark;

            final loyaltyDiscount =
                LoyaltyService.redeemValue(redeemPoints, redeemValue: redeemValue);
            final taxable = (_subtotal - discount - loyaltyDiscount)
                .clamp(0.0, double.infinity);

            // Phase G: tax / VAT.
            final taxAmount = taxInclusive
                ? taxable * taxRate / (100 + taxRate)
                : taxable * taxRate / 100;
            final total = taxInclusive ? taxable : taxable + taxAmount;

            final paidAmount = splitLines.fold<double>(
              0.0,
              (sum, line) => sum + line.amount,
            );
            final change = paidAmount - total;

            void updateDiscount(String value) {
              final parsed = double.tryParse(value);

              setDialogState(() {
                if (value.trim().isEmpty) {
                  discount = 0.0;
                  discountValidationMessage = null;
                  validationMessage = null;
                  return;
                }

                if (parsed == null) {
                  discount = 0.0;
                  discountValidationMessage = null;
                  return;
                }

                if (parsed < 0) {
                  discount = 0.0;
                  discountValidationMessage = 'Discount cannot be negative.';
                  return;
                }

                if (isPercentMode && parsed > 100) {
                  discount = CheckoutHelpers.discountFor(
                    _subtotal,
                    parsed,
                    true,
                  );
                  discountValidationMessage =
                      'Discount cannot exceed 100%.';
                  return;
                }

                if (!isPercentMode && parsed > _subtotal) {
                  discount = parsed;
                  discountValidationMessage =
                      'Discount cannot be greater than the subtotal.';
                  return;
                }

                discount = CheckoutHelpers.discountFor(
                  _subtotal,
                  parsed,
                  isPercentMode,
                );
                discountValidationMessage = null;
                validationMessage = null;
              });
            }

            Future<void> completeCheckout() async {
              final rawDiscount =
                  double.tryParse(discountController.text.trim()) ?? 0.0;

              final parsedDiscount = CheckoutHelpers.discountFor(
                _subtotal,
                rawDiscount,
                isPercentMode,
              );

              if (rawDiscount < 0) {
                setDialogState(() {
                  discountValidationMessage = 'Discount cannot be negative.';
                });

                return;
              }

              if (isPercentMode && rawDiscount > 100) {
                setDialogState(() {
                  discountValidationMessage = 'Discount cannot exceed 100%.';
                });

                return;
              }

              if (!isPercentMode && rawDiscount > _subtotal) {
                setDialogState(() {
                  discountValidationMessage =
                      'Discount cannot be greater than the subtotal.';
                });

                return;
              }

              final loyaltyDiscount = LoyaltyService.redeemValue(
                redeemPoints,
                redeemValue: redeemValue,
              );
              final taxable = (_subtotal - parsedDiscount - loyaltyDiscount)
                  .clamp(0.0, double.infinity);

              // Phase G: tax / VAT.
              final taxAmount = taxInclusive
                  ? taxable * taxRate / (100 + taxRate)
                  : taxable * taxRate / 100;
              final finalTotal = taxInclusive ? taxable : taxable + taxAmount;

              // Split payment validation.
              final paidAmount = splitLines.fold<double>(
                0.0,
                (sum, line) => sum + line.amount,
              );

              for (final line in splitLines) {
                if (line.amount <= 0) {
                  setDialogState(() {
                    validationMessage =
                        'Each payment amount must be greater than 0.';
                  });
                  return;
                }
              }

              if (paidAmount < finalTotal) {
                setDialogState(() {
                  validationMessage = 'Amount received is less than the total.';
                });

                return;
              }

              if (splitLines.length > 1 &&
                  (paidAmount - finalTotal).abs() > 0.005) {
                setDialogState(() {
                  validationMessage =
                      'Split payment amounts must equal the total due.';
                });

                return;
              }

              if (_cart.isEmpty) {
                setDialogState(() {
                  validationMessage = 'The cart is empty.';
                });

                return;
              }

              if (isProcessing) {
                return;
              }

              setDialogState(() {
                isProcessing = true;
                validationMessage = null;
              });

              try {
                final saleId = DateTime.now().microsecondsSinceEpoch.toString();

                final items = <SaleItem>[];

                for (var index = 0; index < _cart.length; index++) {
                  final item = _cart[index];

                  items.add(
                    SaleItem(
                      id: '${saleId}_$index',
                      saleId: saleId,
                      productId: item.product.id,
                      productName: item.product.name,
                      quantity: item.quantity.toDouble(),
                      unitPrice: item.product.sellingPrice,
                      purchasePrice: item.product.purchasePrice,
                      batchNumber: item.batchNumber,
                      expiryDate: item.expiryDate,
                    ),
                  );
                }

                final paymentMethod =
                    splitLines.length == 1
                        ? splitLines.first.method
                        : 'split';
                String? paymentMethodDetails;
                if (splitLines.length > 1) {
                  paymentMethodDetails = jsonEncode(
                    splitLines
                        .map((line) => <String, dynamic>{
                              'method': line.method,
                              'amount': line.amount,
                            })
                        .toList(),
                  );
                }

                await _saleRepository.completeSale(
                  saleId: saleId,
                  customerId: selectedCustomerId,
                  subtotal: _subtotal,
                  discount: parsedDiscount + loyaltyDiscount,
                  total: finalTotal,
                  taxAmount: taxAmount,
                  paymentMethodDetails: paymentMethodDetails,
                  paidAmount: paidAmount,
                  paymentMethod: paymentMethod,
                  createdAt: DateTime.now(),
                  items: items,
                );

                // Redeem the points the customer spent at this checkout.
                if (redeemPoints > 0 && selectedCustomerId != null) {
                  try {
                    await _loyaltyRepository.redeemPoints(
                      selectedCustomerId!,
                      redeemPoints,
                    );
                  } catch (_) {
                    // Redemption is best-effort; the sale already succeeded.
                  }
                }

                // Award new loyalty points on the amount actually paid.
                await _awardLoyalty(
                  customerId: selectedCustomerId,
                  amount: finalTotal,
                );

                // Push an in-app notification for the completed sale.
                notificationStore.push(
                  type: AppNotificationType.sale,
                  title: 'Sale completed',
                  message:
                      '$_currency ${finalTotal.toStringAsFixed(2)} • '
                      '${items.length} item${items.length == 1 ? '' : 's'} '
                      'via ${paymentMethod.toUpperCase()}',
                );

                if (!mounted) {
                  return;
                }

                _hapticMedium();
                setState(() {
                  _cart.clear();
                  _stockMessage = null;
                });

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(saleId);
                }
              } catch (error) {
                if (!dialogContext.mounted) {
                  return;
                }

                _hapticHeavy();
                setDialogState(() {
                  isProcessing = false;

                  validationMessage = error.toString().replaceFirst(
                    'StateError: ',
                    '',
                  );
                });
              }
            }

            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                AppDimensions.screenPadding,
                AppDimensions.screenPadding,
                AppDimensions.spacingSm,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                AppDimensions.spacingSm,
                AppDimensions.screenPadding,
                AppDimensions.spacingSm,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                AppDimensions.spacingSm,
                AppDimensions.screenPadding,
                AppDimensions.screenPadding,
              ),

              title: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Icon(
                      Icons.point_of_sale_rounded,
                      size: 22,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checkout',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Complete this sale',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─────────────────────────────────────────────
                      // SALE SUMMARY
                      // ─────────────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.spacingLg),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppDimensions.spacingSm),
                                Text(
                                  'Sale Summary',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppDimensions.spacingLg),

                            Row(
                              children: [
                                Text(
                                  'Items',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$_totalItems',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppDimensions.spacingSm),

                            Row(
                              children: [
                                Text(
                                  'Subtotal',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$_currency '
                                  '${_subtotal.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppDimensions.spacingMd),

                            if (loyaltyDiscount > 0) ...[
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.redeem_rounded,
                                        size: 15,
                                        color: AppColors.tertiaryDark,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Loyalty ($redeemPoints pts)',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: AppColors.tertiaryDark,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '- $_currency '
                                    '${loyaltyDiscount.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.tertiaryDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.spacingMd),
                            ],

                            if (discount > 0) ...[
                              Row(
                                children: [
                                  Text(
                                    'Discount',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '- $_currency '
                                    '${discount.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.spacingMd),
                            ],

                            // Phase G: tax / VAT breakdown.
                            if (taxRate > 0) ...[
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      taxInclusive
                                          ? 'Tax (included, '
                                              '${taxRate.toStringAsFixed(0)}%)'
                                          : 'Tax (+${taxRate.toStringAsFixed(0)}%)',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$_currency '
                                        '${taxAmount.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppColors.moneyTint.last,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.spacingMd),
                            ],

                            Divider(
                              height: 1,
                              color: colorScheme.outlineVariant,
                            ),

                            const SizedBox(height: AppDimensions.spacingMd),

                            // Phase G: royal-tinted totals panel.
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingMd,
                                vertical: AppDimensions.spacingSm,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.posTint.last.withValues(
                                        alpha: 0.14,
                                      )
                                    : AppColors.posTint.first,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.buttonRadius,
                                ),
                                border: Border.all(
                                  color: AppColors.posTint.last.withValues(
                                    alpha: isDark ? 0.55 : 0.35,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  AnimatedSwitcher(
                                    duration: const Duration(
                                      milliseconds: 180,
                                    ),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: Text(
                                      '$_currency ${total.toStringAsFixed(2)}',
                                      key: ValueKey(total),
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingLg),

                      // ─────────────────────────────────────────────
                      // CUSTOMER
                      // ─────────────────────────────────────────────
                      Text(
                        'Customer',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingSm),

                      DropdownButtonFormField<String?>(
                        initialValue: selectedCustomerId,
                        decoration: InputDecoration(
                          hintText: 'Select customer',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Walk-in Customer'),
                          ),
                          ..._customers.map((customer) {
                            final phone = customer.phone.trim();
                            final label = phone.isEmpty
                                ? customer.name
                                : '${customer.name} • $phone';

                            return DropdownMenuItem<String?>(
                              value: customer.id,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (customer.loyaltyPoints > 0)
                                    Text(
                                      '• ${customer.loyaltyPoints} pts',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.tertiaryDark,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: isProcessing
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedCustomerId = value;
                                  validationMessage = null;
                                  // Reset any redemption when the
                                  // customer changes.
                                  redeemPoints = 0;
                                });

                                if (value != null) {
                                  _loadRedeemConfig(value, (config) {
                                    if (!dialogContext.mounted) return;
                                    setDialogState(() {
                                      redeemableBalance = config.balance;
                                      redeemValue = config.redeemValue;
                                    });
                                  });
                                }
                              },
                      ),

                      // Loyalty preview for the selected customer.
                      if (selectedCustomerId != null &&
                          _customers.any(
                            (c) => c.id == selectedCustomerId,
                          )) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        _buildLoyaltyPreview(
                          _customers.firstWhere(
                            (c) => c.id == selectedCustomerId,
                          ),
                        ),
                        if (redeemableBalance > 0 && redeemValue > 0) ...[
                          const SizedBox(height: AppDimensions.spacingSm),
                          _buildRedeemControl(
                            redeemPoints: redeemPoints,
                            maxRedeemable: () {
                              // Never let the loyalty discount exceed the
                              // amount still owed after the manual discount.
                              final owed = (_subtotal - discount).clamp(
                                0.0,
                                double.infinity,
                              );
                              final byValue = redeemValue <= 0
                                  ? 0
                                  : (owed / redeemValue).floor();
                              return byValue < redeemableBalance
                                  ? byValue
                                  : redeemableBalance;
                            }(),
                            redeemValue: redeemValue,
                            onChanged: (points) => setDialogState(() {
                              redeemPoints = points;
                              validationMessage = null;
                            }),
                          ),
                        ],
                      ],

                      const SizedBox(height: AppDimensions.spacingLg),

                      // ─────────────────────────────────────────────
                      // DISCOUNT
                      // ─────────────────────────────────────────────
                      Row(
                        children: [
                          Text(
                            'Discount',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          // Discount mode toggle styled as BrandPill.
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: isProcessing
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          isPercentMode = false;
                                          discountValidationMessage = null;
                                        });
                                        updateDiscount(discountController.text);
                                      },
                                child: BrandPill(
                                  label: 'Amount',
                                  color: AppColors.royalMid,
                                  filled: !isPercentMode,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: isProcessing
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          isPercentMode = true;
                                          discountValidationMessage = null;
                                        });
                                        updateDiscount(discountController.text);
                                      },
                                child: BrandPill(
                                  label: 'Percent',
                                  color: AppColors.royalMid,
                                  filled: isPercentMode,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.spacingSm),

                      Wrap(
                        spacing: AppDimensions.spacingSm,
                        runSpacing: AppDimensions.spacingSm,
                        children: [
                          for (final preset in (isPercentMode
                              ? const [5, 10, 15, 20]
                              : const [5, 10, 20, 50]))
                            ActionChip(
                              avatar: Icon(
                                Icons.local_offer_outlined,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              label: Text(
                                isPercentMode
                                    ? '$preset%'
                                    : '$_currency $preset',
                              ),
                              onPressed: isProcessing
                                  ? null
                                  : () {
                                      discountController.text =
                                          preset.toString();
                                      updateDiscount(preset.toString());
                                    },
                            ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.spacingSm),

                      TextField(
                        controller: discountController,
                        enabled: !isProcessing,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: updateDiscount,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: isPercentMode
                              ? '% '
                              : '$_currency ',
                          prefixIcon: const Icon(Icons.discount_outlined),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),

                      // Percentage discount calculation preview.
                      if (isPercentMode && discount > 0 && _subtotal > 0) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        Text(
                          '${(discount * 100 / _subtotal).toStringAsFixed(0)}% of '
                          '$_currency ${_subtotal.toStringAsFixed(2)} = '
                          '$_currency ${discount.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      if (discountValidationMessage != null) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            key: ValueKey(discountValidationMessage),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingMd,
                              vertical: AppDimensions.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                              border: Border.all(
                                color: colorScheme.error.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 19,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(width: AppDimensions.spacingSm),
                                Expanded(
                                  child: Text(
                                    discountValidationMessage!,
                                    style: TextStyle(
                                      color: colorScheme.onErrorContainer,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.spacingLg),

                      // ─────────────────────────────────────────────
                      // PAYMENT METHODS (split payments)
                      // ─────────────────────────────────────────────
                      Text(
                        'Payment Methods',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingSm),

                      // Each split method is a premium row: icon tile + amount
                      // input + remove button. Single cash line is the default.
                      ...splitLines.asMap().entries.map((entry) {
                        final index = entry.key;
                        final line = entry.value;
                        final meta = paymentMethodMeta[line.method]!;
                        final canRemove = splitLines.length > 1;

                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: AppDimensions.spacingSm,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingMd,
                            vertical: AppDimensions.spacingSm,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.buttonRadius,
                            ),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              BrandIconBadge(
                                icon: meta.icon,
                                color: meta.color,
                                size: 40,
                              ),
                              const SizedBox(width: AppDimensions.spacingMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      paymentMethodLabel[line.method] ??
                                          line.method,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: AppDimensions
                                        .spacingXs),
                                    SizedBox(
                                      width: 160,
                                      child: TextField(
                                        controller: line.controller,
                                        enabled: !isProcessing,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        onChanged: (value) {
                                          final parsed =
                                              double.tryParse(value) ?? 0.0;
                                          setDialogState(() {
                                            line.amount =
                                                parsed < 0 ? 0 : parsed;
                                            validationMessage = null;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: '0.00',
                                          prefixText: '$_currency ',
                                          filled: true,
                                          fillColor: colorScheme.surface,
                                          contentPadding: const EdgeInsets
                                              .symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (canRemove) ...[
                                const SizedBox(width: AppDimensions
                                    .spacingSm),
                                GestureDetector(
                                  onTap: isProcessing
                                      ? null
                                      : () {
                                          setDialogState(() {
                                            splitLines.removeAt(index);
                                            line.controller.dispose();
                                            validationMessage = null;
                                          });
                                        },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: colorScheme.error
                                          .withValues(alpha: 0.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: AppDimensions.spacingSm),

                      // "Add payment method" — royal gradient.
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppDecor.royalGradient,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.buttonRadius,
                          ),
                          boxShadow: AppDecor.glow(
                            AppColors.royalMid,
                            alpha: 0.30,
                          ),
                        ),
                        child: SizedBox(
                          height: 40,
                          child: FilledButton.icon(
                            onPressed: isProcessing
                                ? null
                                : () {
                                    setDialogState(() {
                                      final used = splitLines
                                          .map((l) => l.method)
                                          .toSet();
                                      final next = paymentMethodMeta.keys
                                          .firstWhere(
                                            (m) => !used.contains(m),
                                            orElse: () => 'cash',
                                          );
                                      splitLines.add(
                                        _SplitLine(method: next, amount: 0.0),
                                      );
                                      validationMessage = null;
                                    });
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingMd,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.buttonRadius,
                                ),
                              ),
                            ),
                            icon: const Icon(
                              Icons.add_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Add payment method',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingLg),

                      // Quick cash (only meaningful for a single cash tender).
                      if (splitLines.length == 1 &&
                          splitLines.first.method == 'cash' &&
                          CheckoutHelpers.quickCash(total).isNotEmpty) ...[
                        Text(
                          'Quick Cash',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Wrap(
                          spacing: AppDimensions.spacingSm,
                          runSpacing: AppDimensions.spacingSm,
                          children: [
                            for (final amount
                                in CheckoutHelpers.quickCash(total))
                              ActionChip(
                                avatar: Icon(
                                  Icons.payments_outlined,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                label: Text(
                                  (amount - total).abs() < 0.005
                                      ? 'Exact'
                                      : '$_currency '
                                          '${amount.toStringAsFixed(2)}',
                                ),
                                onPressed: isProcessing
                                    ? null
                                    : () {
                                        final text =
                                            amount.toStringAsFixed(2);
                                        splitLines.first.controller.text =
                                            text;
                                        setDialogState(() {
                                          splitLines.first.amount = amount;
                                          validationMessage = null;
                                        });
                                      },
                              ),
                          ],
                        ),
                      ],

                      // ─────────────────────────────────────────────
                      // CHANGE
                      // ─────────────────────────────────────────────
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.spacingLg),
                        decoration: BoxDecoration(
                          color: change >= 0
                              ? colorScheme.primary.withValues(alpha: 0.08)
                              : colorScheme.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                          border: Border.all(
                            color: change >= 0
                                ? colorScheme.primary.withValues(alpha: 0.18)
                                : colorScheme.error.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: change >= 0
                                    ? colorScheme.primary.withValues(
                                        alpha: 0.12,
                                      )
                                    : colorScheme.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                              ),
                              child: Icon(
                                change >= 0
                                    ? Icons.change_circle_outlined
                                    : Icons.warning_amber_rounded,
                                size: 20,
                                color: change >= 0
                                    ? colorScheme.primary
                                    : colorScheme.error,
                              ),
                            ),

                            const SizedBox(width: AppDimensions.spacingMd),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Change',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingXs,
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: Text(
                                      '$_currency '
                                      '${change < 0 ? '0.00' : change.toStringAsFixed(2)}',
                                      key: ValueKey(change),
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: change >= 0
                                                ? colorScheme.primary
                                                : colorScheme.error,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ─────────────────────────────────────────────
                      // VALIDATION MESSAGE
                      // ─────────────────────────────────────────────
                      if (validationMessage != null) ...[
                        const SizedBox(height: AppDimensions.spacingMd),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            key: ValueKey(validationMessage),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingMd,
                              vertical: AppDimensions.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                              border: Border.all(
                                color: colorScheme.error.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppDimensions.spacingXs,
                                  ),
                                  child: Icon(
                                    Icons.error_outline_rounded,
                                    color: colorScheme.error,
                                  ),
                                ),

                                const SizedBox(width: AppDimensions.spacingSm),

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppDimensions.spacingXs,
                                    ),
                                    child: Text(
                                      validationMessage!,
                                      style: TextStyle(
                                        color: colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      validationMessage = null;
                                    });
                                  },
                                  tooltip: 'Dismiss',
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),

                Container(
                  decoration: BoxDecoration(
                    gradient: isProcessing
                        ? null
                        : AppDecor.royalGradient,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                    boxShadow: isProcessing
                        ? null
                        : AppDecor.glow(AppColors.royalMid, alpha: 0.30),
                  ),
                  child: FilledButton.icon(
                    onPressed: isProcessing ? null : completeCheckout,
                    style: FilledButton.styleFrom(
                      backgroundColor: isProcessing
                          ? colorScheme.onSurfaceVariant
                          : Colors.transparent,
                      foregroundColor: isProcessing
                          ? colorScheme.onSurface
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingLg,
                        vertical: AppDimensions.spacingSm,
                      ),
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
                    ),
                    icon: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: AuroraLoader(size: 18, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded, size: 19),
                    label: Text(
                      isProcessing ? 'Processing...' : 'Complete Sale',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    discountController.dispose();
    for (final line in splitLines) {
      line.controller.dispose();
    }

    return result;
  }

  Future<void> _handleCheckout({required bool closeAfterCheckout}) async {
    if (_cart.isEmpty) {
      return;
    }

    final completedSaleId = await _showCheckoutDialog();

    if (!mounted || completedSaleId == null) {
      return;
    }

    if (closeAfterCheckout && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    await _showSaleSuccessDialog(completedSaleId);
  }

  // ===========================================================================
  // SUCCESS DIALOG
  // ===========================================================================

  Future<void> _showSaleSuccessDialog(String saleId) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.screenPadding,
            AppDimensions.screenPadding,
            AppDimensions.spacingSm,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.spacingSm,
            AppDimensions.screenPadding,
            AppDimensions.spacingSm,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.spacingSm,
            AppDimensions.screenPadding,
            AppDimensions.screenPadding,
          ),

          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 24,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sale Successful',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Transaction completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.spacingSm),

              // Success badge — sunset-aurora circle with a one-shot
              // elastic scale-bounce and a warm glow. Plays once; never
              // blocks input (dialog buttons appear immediately).
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandCoral.withValues(alpha: 0.35),
                      blurRadius: 36,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppDecor.sunsetGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                ).fadeIn(duration: 240.ms),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              Text(
                'Payment completed successfully',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingSm),

              Text(
                'Your sale has been recorded and inventory has been updated.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: Text(
                        'Receipt available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Done'),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: AppDecor.royalGradient,
                borderRadius: BorderRadius.circular(
                  AppDimensions.buttonRadius,
                ),
                boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.28),
              ),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReceiptScreen(saleId: saleId),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                  ),
                ),
                icon: const Icon(Icons.receipt_long_outlined, size: 19),
                label: const Text(
                  'View Receipt',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // MOBILE CART
  // ===========================================================================

  Future<void> _showMobileCart() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (bottomSheetContext) {
        String? stockMessage;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            void increaseItem(CartItem item) {
              if (item.quantity >= item.product.stockQuantity) {
                setSheetState(() {
                  stockMessage =
                      'Not enough stock for ${item.product.name} '
                      '(SKU: ${item.product.sku}). '
                      'Available stock: ${item.product.stockQuantity}.';
                });

                return;
              }

              setState(() {
                item.quantity++;
                _stockMessage = null;
              });

              setSheetState(() {
                stockMessage = null;
              });
            }

            void decreaseItem(CartItem item) {
              if (item.quantity <= 1) {
                setState(() {
                  _cart.remove(item);
                  _stockMessage = null;
                });

                setSheetState(() {
                  stockMessage = null;
                });

                return;
              }

              setState(() {
                item.quantity--;
                _stockMessage = null;
              });

              setSheetState(() {
                stockMessage = null;
              });
            }

            void removeItem(CartItem item) {
              setState(() {
                _cart.remove(item);
                _stockMessage = null;
              });

              setSheetState(() {
                stockMessage = null;
              });
            }

            return FractionallySizedBox(
              heightFactor: 0.85,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.screenPadding,
                      AppDimensions.spacingMd,
                      AppDimensions.screenPadding,
                      AppDimensions.spacingSm,
                    ),
                    child: Row(
                      children: [
                        const Text('Cart', style: AppTextStyles.heading2),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.of(bottomSheetContext).pop();
                          },
                          icon: const Icon(Icons.close),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (stockMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding,
                        AppDimensions.spacingMd,
                        AppDimensions.screenPadding,
                        0,
                      ),
                      child: _buildSheetStockNotification(
                        context,
                        stockMessage!,
                        () {
                          setSheetState(() {
                            stockMessage = null;
                          });
                        },
                      ),
                    ),
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 48),
                                SizedBox(height: AppDimensions.spacingMd),
                                Text('Cart is empty'),
                                SizedBox(height: AppDimensions.spacingXs),
                                Text(
                                  'Add products to start a sale.',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(
                              AppDimensions.screenPadding,
                            ),
                            itemCount: _cart.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: AppDimensions.spacingXs,
                              );
                            },
                            itemBuilder: (context, index) {
                              final item = _cart[index];

                              return CartItemTile(
                                item: item,
                                currency: _currency,
                                enterIndex: index,
                                onIncrease: () {
                                  increaseItem(item);
                                },
                                onDecrease: () {
                                  decreaseItem(item);
                                },
                                onRemove: () {
                                  removeItem(item);
                                },
                              );
                            },
                          ),
                  ),
                  _buildCartSummary(
                    showCheckout: true,
                    closeAfterCheckout: true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetStockNotification(
    BuildContext context,
    String message,
    VoidCallback onDismiss,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.error),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onErrorContainer,
            ),
            tooltip: 'Dismiss',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CART WIDGETS
  // ===========================================================================

  Widget _buildCartItems() {
    if (_cart.isEmpty) {
      return const BrandEmptyState(
        compact: true,
        icon: Icons.shopping_bag_outlined,
        title: 'Nothing in the cart yet',
        message: 'Tap a product on the left — it will appear here instantly.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      itemCount: _cart.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: AppDimensions.spacingXs);
      },
      itemBuilder: (context, index) {
        final item = _cart[index];

        return CartItemTile(
          item: item,
          currency: _currency,
          enterIndex: index,
          onIncrease: () {
            _increaseQuantity(item);
          },
          onDecrease: () {
            _decreaseQuantity(item);
          },
          onRemove: () {
            _removeFromCart(item);
          },
        );
      },
    );
  }

  Widget _buildCartSummary({
    required bool showCheckout,
    required bool closeAfterCheckout,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '$_totalItems ${_totalItems == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.50),
                ),
              ),
              const Spacer(),
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.50),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  '$_currency ${_subtotal.toStringAsFixed(2)}',
                  key: ValueKey(_subtotal),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.primary.withValues(alpha: 0.24),
                        AppColors.auroraTeal.withValues(alpha: 0.10),
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.09),
                        AppColors.auroraTeal.withValues(alpha: 0.12),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.30 : 0.22,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.14 : 0.08,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL DUE',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Hero total in Sora priceHero — counts up over a
                      // lightweight 300ms tween whenever the totals change.
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: _subtotal),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Text(
                          '$_currency ${value.toStringAsFixed(2)}',
                          style: AppTextStyles.priceHero.copyWith(
                            fontSize: 24,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showCheckout)
                  Container(
                    decoration: BoxDecoration(
                      gradient: _cart.isEmpty ? null : AppDecor.royalGradient,
                      color: _cart.isEmpty
                          ? colorScheme.onSurfaceVariant
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _cart.isEmpty
                          ? null
                          : AppDecor.glow(AppColors.royalMid, alpha: 0.30),
                    ),
                    child: SizedBox(
                      height: 42,
                      child: FilledButton.icon(
                        onPressed: _cart.isEmpty
                            ? null
                            : () => _handleCheckout(
                                  closeAfterCheckout: closeAfterCheckout,
                                ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.transparent,
                          disabledForegroundColor: colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.point_of_sale_rounded,
                          size: 17,
                        ),
                        label: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showCheckout) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: _cart.isEmpty ? null : _parkCurrentSale,
                      icon: const Icon(Icons.pause_rounded, size: 15),
                      label: const Text(
                        'Hold',
                        style: TextStyle(fontSize: 11.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextButton.icon(
                      onPressed: _showHeldSales,
                      icon: Icon(
                        Icons.history_rounded,
                        size: 15,
                        color: parkedSalesStore.sales.isEmpty
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.primary,
                      ),
                      label: Text(
                        parkedSalesStore.sales.isEmpty
                            ? 'Held sales'
                            : 'Held (${parkedSalesStore.sales.length})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: parkedSalesStore.sales.isEmpty
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileCartBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_stockMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  AppDimensions.spacingSm,
                  AppDimensions.screenPadding,
                  0,
                ),
                child: _buildStockNotification(
                  message: _stockMessage!,
                  onDismiss: () {
                    setState(() {
                      _stockMessage = null;
                    });
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                AppDimensions.spacingSm,
                AppDimensions.screenPadding,
                AppDimensions.spacingSm,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _cart.isEmpty
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.buttonRadius,
                      ),
                    ),
                    child: Icon(
                      _cart.isEmpty
                          ? Icons.shopping_cart_outlined
                          : Icons.shopping_cart_rounded,
                      size: 21,
                      color: _cart.isEmpty
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            _totalItems == 0
                                ? 'Cart is empty'
                                : '$_totalItems '
                                      '${_totalItems == 1 ? 'item' : 'items'}',
                            key: ValueKey(_totalItems),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            '$_currency ${_subtotal.toStringAsFixed(2)}',
                            key: ValueKey(_subtotal),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: _cart.isEmpty
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  FilledButton.icon(
                    onPressed: _cart.isEmpty ? null : _showMobileCart,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: const Text(
                      'View Cart',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ERROR STATE
  // ===========================================================================

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Unable to load products.',
              style: AppTextStyles.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Something went wrong while loading your products. '
              'Please try again.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            FilledButton.icon(
              onPressed: _watchProducts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('New Sale'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (_cart.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSm,
                vertical: AppDimensions.spacingXs,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.15),
                    colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_totalItems ${_totalItems == 1 ? 'item' : 'items'}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            TextButton.icon(
              onPressed: _clearCart,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
          ],
        ],
      ) : null,
      body: _isLoading || _isLoadingSettings
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AuroraLoader(size: 48),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Loading products...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : _hasError
          ? _buildErrorState()
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(flex: 3, child: _buildProductSection()),
                      Container(
                        width: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      SizedBox(width: 380, child: _buildDesktopCart()),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(child: _buildProductSection()),
                    _buildMobileCartBar(),
                  ],
                );
              },
            ),
    );
  }

  // ===========================================================================
  // PRODUCT SECTION
  // ===========================================================================

  Widget _buildProductSection() {
    final products = _filteredProducts;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPosHeader(products),
          const SizedBox(height: AppDimensions.spacingMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: PosSearchField(
                  controller: _searchController,
                  onSubmitted: _handleBarcodeSubmitted,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onClear: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              // Scan button — royal gradient icon tile that opens the camera
              // barcode scanner bottom sheet.
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppDecor.royalGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.30),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _scanBarcode,
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildCategoryChips(),
          const SizedBox(height: AppDimensions.spacingMd),
          SectionHeading(
            title: 'Available products',
            subtitle: 'Tap to add · stock updates live',
            icon: Icons.grid_view_rounded,
            trailing: BrandPill(
              label: '${products.length}',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: products.isEmpty
                  ? _buildEmptyProductState()
                  : LayoutBuilder(
                      key: ValueKey(products.length),
                      builder: (context, constraints) {
                        return GridView.builder(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacingMd,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 460,
                                mainAxisExtent: 118,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];

                            final tile = _ProductTile(
                              product: product,
                              currency: _currency,
                              quantity: _getCartQuantity(product.id),
                              onAdd: () {
                                _addProductToCart(product);
                              },
                              onIncrease: () {
                                final item = _cart.firstWhere(
                                  (item) => item.product.id == product.id,
                                );

                                _increaseQuantity(item);
                              },
                              onDecrease: () {
                                final item = _cart.firstWhere(
                                  (item) => item.product.id == product.id,
                                );

                                _decreaseQuantity(item);
                              },
                            );

                            // Soft entrance for the first screenful only —
                            // fades never delay a tap and don't replay on
                            // cart-related rebuilds of existing tiles.
                            if (index >= 12) {
                              return tile;
                            }

                            return tile
                                .animate(
                                  delay: Duration(milliseconds: 60 * index),
                                )
                                .fadeIn(
                                  duration: 350.ms,
                                  curve: Curves.easeOutCubic,
                                );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Compact photo-accent header for the POS: the payment photo sits under
  /// the brand wash, with the in-cart glanceable total on the right. Kept
  /// short (~110px) so the search field and product grid stay above the fold.
  Widget _buildPosHeader(List<Product> products) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 96),
        child: Stack(
          children: [
            Positioned.fill(
              child: AppDecor.photoHero(
                image: AppImages.posPayment,
                imageAlignmentY: 0.45,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.point_of_sale_rounded,
                              size: 13,
                              color: Color(0xFF7DF3DF),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'CHECKOUT',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont,
                                  color: AppColors.onPhotoMuted,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Point of sale',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            color: AppColors.onPhoto,
                            fontSize: theme.brightness == Brightness.dark
                                ? 21
                                : 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _searchQuery.trim().isEmpty
                              ? 'Tap a product to add it, or scan a barcode.'
                              : '${products.length} matching '
                                  '${products.length == 1 ? 'product' : 'products'} for your search.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.onPhotoSoft,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _totalItems == 0
                              ? 'CART'
                              : '$_totalItems ITEM'
                                  '${_totalItems == 1 ? '' : 'S'}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            color: AppColors.onPhotoSoft,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Text(
                            '$_currency ${_subtotal.toStringAsFixed(2)}',
                            key: ValueKey(_subtotal),
                            style: TextStyle(
                              fontFamily: AppTextStyles.displayFont,
                              color: AppColors.onPhoto,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        if (parkedSalesStore.sales.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppDecor.royalGradient,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.35),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.pause_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'HELD ${parkedSalesStore.sales.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Category shortcut chips under the search field. Selected chip carries
  /// the royal (pos) tint; tapping is instant — it only narrows the visible
  /// list, never blocks. Derived purely from the loaded products.
  Widget _buildCategoryChips() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = <String>{
      for (final product in _products) product.category.trim(),
    }.where((category) => category.isNotEmpty).toList()..sort();

    if (categories.length < 2) {
      return const SizedBox.shrink();
    }

    final deep = AppColors.posTint.last;

    Widget chip(String? value, String label) {
      final selected = _categoryFilter == value;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _categoryFilter = selected ? null : value;
            });
          },
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark ? deep.withValues(alpha: 0.22) : AppColors.posTint.first)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.045)
                      : Colors.white),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? deep.withValues(alpha: isDark ? 0.55 : 0.65)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : AppColors.lightBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected
                      ? Icons.check_rounded
                      : Icons.category_outlined,
                  size: 13,
                  color: selected
                      ? deep
                      : theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? (isDark ? AppColors.primaryLight : deep)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chipList = <Widget>[
      chip(null, 'All'),
      for (final category in categories) chip(category, category),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chipList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemBuilder: (context, index) => chipList[index],
      ),
    );
  }

  Widget _buildEmptyProductState() {
    final colorScheme = Theme.of(context).colorScheme;

    final hasSearch = _searchQuery.trim().isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasSearch
                      ? Icons.search_off_rounded
                      : Icons.inventory_2_outlined,
                  size: 30,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                hasSearch ? 'No products found' : 'No products available',
                style: AppTextStyles.heading2.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                hasSearch
                    ? 'Try another product name, SKU, barcode, or category.'
                    : 'Add products before starting a sale.',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (hasSearch) ...[
                const SizedBox(height: AppDimensions.spacingLg),
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Clear Search'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP CART
  // ===========================================================================

  Widget _buildDesktopCart() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 12, 12, 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.lightBorder,
        ),
        boxShadow: AppDecor.layeredShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: AppDecor.royalGradient,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.24),
                ),
                child: const Icon(
                  Icons.receipt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Current sale',
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              if (_totalItems > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                  ),
                  child: Text(
                    '$_totalItems '
                    '${_totalItems == 1 ? 'item' : 'items'}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          if (_stockMessage != null) ...[
            _buildStockNotification(
              message: _stockMessage!,
              onDismiss: () {
                setState(() {
                  _stockMessage = null;
                });
              },
            ),
            const SizedBox(height: AppDimensions.spacingMd),
          ],
          Expanded(child: _buildCartItems()),
          _buildCartSummary(showCheckout: true, closeAfterCheckout: false),
        ],
      ),
    );
  }
}
// =============================================================================
// PRODUCT TILE
// =============================================================================

class _ProductTile extends StatefulWidget {
  final Product product;
  final String currency;
  final int quantity;

  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _ProductTile({
    required this.product,
    required this.currency,
    required this.quantity,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile> {
  bool _hovered = false;
  bool _pressed = false;

  List<Color> get _colors {
    final k = widget.product.category.toLowerCase();
    if (k.contains('elect')) {
      return const [Color(0xFF6366F1), Color(0xFF8B5CF6)];
    }
    if (k.contains('groc') || k.contains('food')) {
      return const [Color(0xFF10B981), Color(0xFF2DD4BF)];
    }
    if (k.contains('bev')) {
      return const [Color(0xFF0EA5E9), Color(0xFF22D3EE)];
    }
    if (k.contains('house')) {
      return const [Color(0xFFF59E0B), Color(0xFFFB923C)];
    }
    if (k.contains('care') || k.contains('beaut')) {
      return const [Color(0xFFEC4899), Color(0xFFFB7185)];
    }
    if (k.contains('stat')) {
      return const [Color(0xFF8B5CF6), Color(0xFF6D5DFB)];
    }
    return const [Color(0xFF5B5BF7), Color(0xFF8B5CF6)];
  }

  IconData get _icon {
    final k = widget.product.category.toLowerCase();
    if (k.contains('elect')) return Icons.devices_rounded;
    if (k.contains('groc') || k.contains('food')) {
      return Icons.shopping_basket_rounded;
    }
    if (k.contains('bev')) return Icons.local_cafe_rounded;
    if (k.contains('house')) return Icons.chair_rounded;
    if (k.contains('care') || k.contains('beaut')) return Icons.spa_rounded;
    if (k.contains('stat')) return Icons.note_alt_rounded;
    return Icons.inventory_2_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final out = widget.product.stockQuantity <= 0;
    final low = widget.product.isLowStock;

    // Stock indicator rhythm: mint (healthy) → amber (low) → red (out).
    final stockColor = out
        ? AppColors.error
        : low
            ? AppColors.brandAmber
            : (isDark ? AppColors.brandMint : AppColors.brandMintDeep);

    final royal = AppColors.posTint.last;
    final hovered = _hovered && !out;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: out ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hovered
                ? royal.withValues(alpha: isDark ? 0.55 : 0.45)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : AppColors.lightBorder),
          ),
          boxShadow: hovered
              ? [
                  BoxShadow(
                    color: royal.withValues(
                      alpha: isDark ? 0.16 : 0.10,
                    ),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                    spreadRadius: -6,
                  ),
                ]
              : null,
        ),
        child: AnimatedScale(
          scale: _pressed && !out ? 0.95 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: out ? null : widget.onAdd,
            onTapDown: out ? null : (_) => setState(() => _pressed = true),
            onTapUp: out ? null : (_) => setState(() => _pressed = false),
            onTapCancel: out ? null : () => setState(() => _pressed = false),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (widget.product.productImageUrl != null &&
                      widget.product.productImageUrl!.isNotEmpty &&
                      !out)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(widget.product.productImageUrl!),
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _ProductTileIconSquircle(
                          colors: out
                              ? [
                                  Colors.grey.withValues(alpha: 0.35),
                                  Colors.grey.withValues(alpha: 0.18),
                                ]
                              : _colors,
                          icon: _icon,
                          out: out,
                        ),
                      ),
                    )
                  else
                    _ProductTileIconSquircle(
                      colors: out
                          ? [
                              Colors.grey.withValues(alpha: 0.35),
                              Colors.grey.withValues(alpha: 0.18),
                            ]
                          : _colors,
                      icon: _icon,
                      out: out,
                    ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: out
                                ? scheme.onSurface.withValues(alpha: 0.45)
                                : scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.product.sku} · ${widget.product.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface.withValues(alpha: 0.42),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Tinted squircle price chip.
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: out
                                    ? scheme.onSurface
                                        .withValues(alpha: 0.06)
                                    : (isDark
                                        ? royal.withValues(alpha: 0.20)
                                        : AppColors.posTint.first),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: out
                                      ? scheme.onSurface
                                          .withValues(alpha: 0.10)
                                      : royal.withValues(
                                          alpha: isDark ? 0.42 : 0.30,
                                        ),
                                ),
                              ),
                              child: Text(
                                '${widget.currency} '
                                '${widget.product.sellingPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.displayFont,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: out
                                      ? scheme.onSurface
                                          .withValues(alpha: 0.45)
                                      : (isDark
                                          ? AppColors.primaryLight
                                          : royal),
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            BrandPill(
                              label: out
                                  ? 'OUT'
                                  : low
                                      ? 'LOW ${widget.product.stockQuantity}'
                                      : '${widget.product.stockQuantity}',
                              color: stockColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.quantity == 0)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: out ? null : AppDecor.royalGradient,
                        color: out
                            ? scheme.onSurface.withValues(alpha: 0.06)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: out
                            ? null
                            : AppDecor.glow(royal, alpha: 0.26),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 19,
                        color: out
                            ? scheme.onSurface.withValues(alpha: 0.3)
                            : Colors.white,
                      ),
                    )
                  else
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TileStep(
                            icon: Icons.remove_rounded,
                            onTap: widget.onDecrease,
                          ),
                          SizedBox(
                            width: 20,
                            child: Center(
                              child: Text(
                                '${widget.quantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ),
                          TileStep(
                            icon: Icons.add_rounded,
                            onTap: widget.onIncrease,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

// =============================================================================
// CART ITEM TILE
// =============================================================================

class CartItemTile extends StatefulWidget {
  final CartItem item;
  final String currency;

  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  /// 0-based index used for the staggered fade-slide entrance. Tiles beyond
  /// the first screenful (or null) appear instantly and never re-animate.
  final int? enterIndex;

  const CartItemTile({
    super.key,
    required this.item,
    required this.currency,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    this.enterIndex,
  });

  @override
  State<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<CartItemTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;
    final currency = widget.currency;
    final initial = item.product.name.trim().isEmpty
        ? '•'
        : item.product.name.trim().substring(0, 1).toUpperCase();

    final row = Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _hovered
            ? (isDark
                ? Colors.white.withValues(alpha: 0.065)
                : AppColors.posTint.first)
            : (isDark
                ? Colors.white.withValues(alpha: 0.035)
                : const Color(0xFFF8F9FD)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hovered
              ? AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.28)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.065)
                  : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppDecor.royalGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppDecor.glow(
                AppColors.royalMid,
                alpha: 0.22,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$currency ${item.product.sellingPrice.toStringAsFixed(2)} each',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                if (item.batchNumber != null || item.expiryDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.batchNumber != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.royalMid.withValues(
                              alpha: isDark ? 0.12 : 0.08,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.royalMid.withValues(
                                alpha: isDark ? 0.30 : 0.20,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.label_outlined,
                                size: 11,
                                color: AppColors.royalMid,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Batch ${item.batchNumber}',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.royalMid,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (item.expiryDate != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(
                              alpha: isDark ? 0.12 : 0.08,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.error.withValues(
                                alpha: isDark ? 0.30 : 0.20,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event_outlined,
                                size: 11,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Exp ${item.expiryDate}',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      height: 27,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(
                          alpha: isDark ? 0.12 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: scheme.primary.withValues(
                            alpha: isDark ? 0.26 : 0.18,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          QuantityButton(
                            icon: Icons.remove_rounded,
                            tooltip: 'Decrease quantity',
                            onPressed: widget.onDecrease,
                          ),
                          SizedBox(
                            width: 22,
                            child: Center(
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ),
                          QuantityButton(
                            icon: Icons.add_rounded,
                            tooltip: 'Increase quantity',
                            onPressed: widget.onIncrease,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$currency ${item.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: widget.onRemove,
            tooltip: 'Remove item',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              Icons.close_rounded,
              size: 15,
              color: _hovered
                  ? AppColors.error.withValues(alpha: 0.85)
                  : scheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );

    final index = widget.enterIndex;
    if (index == null || index >= 12) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: row,
      );
    }

    // Fade-slide entrance for the first screenful only; taps stay instant.
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: row
          .animate(delay: Duration(milliseconds: 60 * index))
          .fadeIn(
            duration: 350.ms,
            curve: Curves.easeOutCubic,
          )
          .moveY(
            begin: 14,
            end: 0,
            duration: 350.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

/// Gradient category squircle used by _ProductTile when no product image
/// is available (or the image fails to load).
class _ProductTileIconSquircle extends StatelessWidget {
  final List<Color> colors;
  final IconData icon;
  final bool out;

  const _ProductTileIconSquircle({
    required this.colors,
    required this.icon,
    required this.out,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: out
              ? [
                  Colors.grey.withValues(alpha: 0.35),
                  Colors.grey.withValues(alpha: 0.18),
                ]
              : colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: out
            ? null
            : [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
      ),
      child: Icon(
        icon,
        size: 22,
        color: out
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.white,
      ),
    );
  }
}

/// A single split-payment tender line used at POS checkout.
///
/// Holds the payment method, its amount input controller and the parsed
/// amount. The controller is owned by the line and disposed when the line is
/// removed or the checkout dialog closes.
class _SplitLine {
  final String method;
  final TextEditingController controller;
  double amount;

  _SplitLine({required this.method, required this.amount})
      : controller = TextEditingController(text: amount.toStringAsFixed(2));
}
