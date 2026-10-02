import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/database/app_database.dart' hide SaleItem;
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/customer_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/sale_repository.dart';
import '../../../../models/product.dart';
import '../../../../models/sale_item.dart';
import '../../../sales/presentation/screens/receipt_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  PosScreenState createState() => PosScreenState();
}

class PosScreenState extends State<PosScreen> {
  final ProductRepository _productRepository = ProductRepository(appDatabase);
  final SaleRepository _saleRepository = SaleRepository(appDatabase);
  final CustomerRepository _customerRepository = CustomerRepository(
    appDatabase,
  );
  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  final TextEditingController _searchController = TextEditingController();

  StreamSubscription<List<Product>>? _productsSubscription;
  StreamSubscription<List<Customer>>? _customersSubscription;

  List<Product> _products = [];
  List<Customer> _customers = [];

  final List<_CartItem> _cart = [];

  String _searchQuery = '';

  bool _isLoading = true;
  bool _isLoadingSettings = true;
  bool _hasError = false;

  String _currency = 'USD';

  String? _stockMessage;

  @override
  void initState() {
    super.initState();

    _watchProducts();
    _watchCustomers();
    _loadBusinessSettings();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadBusinessSettings();
  }

  @override
  void dispose() {
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

    if (query.isEmpty) {
      return _products;
    }

    final matches = _products.where((product) {
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

  void _addToCart(Product product) {
    final existingIndex = _cart.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final existingItem = _cart[existingIndex];

      if (existingItem.quantity >= product.stockQuantity) {
        setState(() {
          _stockMessage =
              'Not enough stock for ${product.name} '
              '(SKU: ${product.sku}). '
              'Available stock: ${product.stockQuantity}.';
        });

        return;
      }

      setState(() {
        existingItem.quantity++;
        _stockMessage = null;
      });

      return;
    }

    if (product.stockQuantity <= 0) {
      setState(() {
        _stockMessage =
            '${product.name} (SKU: ${product.sku}) is out of stock.';
      });

      return;
    }

    setState(() {
      _cart.add(_CartItem(product: product, quantity: 1));
      _stockMessage = null;
    });
  }

  void _increaseQuantity(_CartItem item) {
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

  void _decreaseQuantity(_CartItem item) {
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

  void _removeFromCart(_CartItem item) {
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

  Future<String?> _showCheckoutDialog() async {
    if (_cart.isEmpty) {
      return null;
    }

    final discountController = TextEditingController(text: '0.00');

    final paidAmountController = TextEditingController(
      text: _subtotal.toStringAsFixed(2),
    );

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double discount = 0.0;
        double paidAmount = _subtotal;

        String paymentMethod = 'cash';
        String? selectedCustomerId;

        String? validationMessage;
        String? discountValidationMessage;
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            final total = (_subtotal - discount).clamp(0.0, double.infinity);

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

                if (parsed > _subtotal) {
                  discount = parsed;
                  discountValidationMessage =
                      'Discount cannot be greater than the subtotal.';
                  return;
                }

                discount = parsed;
                discountValidationMessage = null;
                validationMessage = null;
              });
            }

            void updatePaidAmount(String value) {
              final parsed = double.tryParse(value) ?? 0.0;

              setDialogState(() {
                paidAmount = parsed < 0 ? 0.0 : parsed;
                validationMessage = null;
              });
            }

            Future<void> completeCheckout() async {
              final parsedDiscount =
                  double.tryParse(discountController.text.trim()) ?? 0.0;

              final parsedPaidAmount =
                  double.tryParse(paidAmountController.text.trim()) ?? 0.0;

              if (parsedDiscount < 0) {
                setDialogState(() {
                  discountValidationMessage = 'Discount cannot be negative.';
                });

                return;
              }

              if (parsedDiscount > _subtotal) {
                setDialogState(() {
                  discountValidationMessage =
                      'Discount cannot be greater than the subtotal.';
                });

                return;
              }

              final finalTotal = _subtotal - parsedDiscount;

              if (parsedPaidAmount < finalTotal) {
                setDialogState(() {
                  validationMessage = 'Amount received is less than the total.';
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
                      quantity: item.quantity,
                      unitPrice: item.product.sellingPrice,
                      purchasePrice: item.product.purchasePrice,
                    ),
                  );
                }

                await _saleRepository.completeSale(
                  saleId: saleId,
                  customerId: selectedCustomerId,
                  subtotal: _subtotal,
                  discount: parsedDiscount,
                  total: finalTotal,
                  paidAmount: parsedPaidAmount,
                  paymentMethod: paymentMethod,
                  createdAt: DateTime.now(),
                  items: items,
                );

                if (!mounted) {
                  return;
                }

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

                            Divider(
                              height: 1,
                              color: colorScheme.outlineVariant,
                            ),

                            const SizedBox(height: AppDimensions.spacingMd),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                    '$_currency ${total.toStringAsFixed(2)}',
                                    key: ValueKey(total),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
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

                            return DropdownMenuItem<String?>(
                              value: customer.id,
                              child: Text(
                                phone.isEmpty
                                    ? customer.name
                                    : '${customer.name} • $phone',
                                overflow: TextOverflow.ellipsis,
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
                                });
                              },
                      ),

                      const SizedBox(height: AppDimensions.spacingLg),

                      // ─────────────────────────────────────────────
                      // DISCOUNT
                      // ─────────────────────────────────────────────
                      Text(
                        'Discount',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
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
                          prefixText: '$_currency ',
                          prefixIcon: const Icon(Icons.discount_outlined),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),

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
                      // PAYMENT METHOD
                      // ─────────────────────────────────────────────
                      Text(
                        'Payment Method',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingSm),

                      DropdownButtonFormField<String>(
                        initialValue: paymentMethod,
                        decoration: InputDecoration(
                          hintText: 'Select payment method',
                          prefixIcon: const Icon(Icons.payments_outlined),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                          DropdownMenuItem(
                            value: 'bank_transfer',
                            child: Text('Bank Transfer'),
                          ),
                        ],
                        onChanged: isProcessing
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setDialogState(() {
                                  paymentMethod = value;
                                  validationMessage = null;
                                });
                              },
                      ),

                      const SizedBox(height: AppDimensions.spacingLg),

                      // ─────────────────────────────────────────────
                      // AMOUNT RECEIVED
                      // ─────────────────────────────────────────────
                      Text(
                        'Amount Received',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingSm),

                      TextField(
                        controller: paidAmountController,
                        enabled: !isProcessing,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: updatePaidAmount,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '$_currency ',
                          prefixIcon: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingLg),

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

                FilledButton.icon(
                  onPressed: isProcessing ? null : completeCheckout,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded, size: 19),
                  label: Text(
                    isProcessing ? 'Processing...' : 'Complete Sale',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    discountController.dispose();
    paidAmountController.dispose();

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

              // Success icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.75, end: 1.0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
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

            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReceiptScreen(saleId: saleId),
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long_outlined, size: 19),
              label: const Text(
                'View Receipt',
                style: TextStyle(fontWeight: FontWeight.w700),
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
            void increaseItem(_CartItem item) {
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

            void decreaseItem(_CartItem item) {
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

            void removeItem(_CartItem item) {
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

                              return _CartItemTile(
                                item: item,
                                currency: _currency,
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 48),
            SizedBox(height: AppDimensions.spacingMd),
            Text('Cart is empty'),
            SizedBox(height: AppDimensions.spacingXs),
            Text('Add products to start a sale.', style: AppTextStyles.caption),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      itemCount: _cart.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: AppDimensions.spacingXs);
      },
      itemBuilder: (context, index) {
        final item = _cart[index];

        return _CartItemTile(
          item: item,
          currency: _currency,
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

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.spacingMd,
        AppDimensions.screenPadding,
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                'Cart Summary',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Row(
            children: [
              Text(
                'Items',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  '$_totalItems',
                  key: ValueKey(_totalItems),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  '$_currency ${_subtotal.toStringAsFixed(2)}',
                  key: ValueKey(_subtotal),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (showCheckout) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: AppDimensions.spacingMd),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: FilledButton.icon(
                onPressed: _cart.isEmpty
                    ? null
                    : () {
                        _handleCheckout(closeAfterCheckout: closeAfterCheckout);
                      },
                icon: const Icon(Icons.point_of_sale_rounded, size: 20),
                label: const Text(
                  'Checkout',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
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
      appBar: AppBar(
        title: const Text('New Sale'),
        actions: [
          if (_cart.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSm,
                vertical: AppDimensions.spacingXs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Text(
                '$_totalItems '
                '${_totalItems == 1 ? 'item' : 'items'}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            TextButton.icon(
              onPressed: _clearCart,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Clear'),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
          ],
        ],
      ),
      body: _isLoading || _isLoadingSettings
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _hasError
          ? _buildErrorState()
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(flex: 3, child: _buildProductSection()),
                      VerticalDivider(
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Products',
                      style: AppTextStyles.heading1.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      _searchQuery.trim().isEmpty
                          ? 'Select a product to add it to the cart.'
                          : '${products.length} matching '
                                '${products.length == 1 ? 'product' : 'products'}',
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          _PosSearchField(
            controller: _searchController,
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
          const SizedBox(height: AppDimensions.spacingLg),
          Row(
            children: [
              Text(
                'Available Products',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: AppDimensions.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  '${products.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
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
                        int columns = 1;

                        if (constraints.maxWidth >= 1250) {
                          columns = 3;
                        } else if (constraints.maxWidth >= 650) {
                          columns = 2;
                        }

                        final childAspectRatio = columns == 1
                            ? 4.2
                            : columns == 2
                            ? 2.15
                            : 1.95;

                        return GridView.builder(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacingMd,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: AppDimensions.spacingMd,
                                mainAxisSpacing: AppDimensions.spacingMd,
                                childAspectRatio: childAspectRatio,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return _ProductTile(
                              product: product,
                              currency: _currency,
                              quantity: _getCartQuantity(product.id),
                              onAdd: () {
                                _addToCart(product);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Cart',
                style: AppTextStyles.heading2.copyWith(
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
// POS SEARCH FIELD
// =============================================================================

class _PosSearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _PosSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_PosSearchField> createState() => _PosSearchFieldState();
}

class _PosSearchFieldState extends State<_PosSearchField> {
  late final FocusNode _focusNode;

  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name, SKU, barcode, or category',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _hasFocus
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Clear search',
                onPressed: widget.onClear,
                icon: const Icon(Icons.close_rounded),
              );
            },
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CART ITEM MODEL
// =============================================================================

class _CartItem {
  final Product product;

  int quantity;

  _CartItem({required this.product, required this.quantity});

  double get total {
    return product.sellingPrice * quantity;
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
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isLowStock = widget.product.isLowStock;

    final stockColor = isLowStock ? colorScheme.error : AppColors.success;

    final stockBackground = isLowStock
        ? colorScheme.errorContainer
        : AppColors.successLight;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTapDown: (_) {
            setState(() {
              _isPressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _isPressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              _isPressed = false;
            });
          },
          onTap: widget.onAdd,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;

                final isCompact = cardWidth < 420;

                final isTabletCard = cardWidth >= 420 && cardWidth < 700;

                if (isCompact) {
                  return _buildCompactLayout(context, stockColor);
                }

                return Row(
                  children: [
                    _buildProductIcon(
                      context,
                      size: isTabletCard ? 56 : 52,
                      iconSize: isTabletCard ? 27 : 25,
                    ),
                    const SizedBox(width: AppDimensions.spacingLg),
                    Expanded(
                      child: _buildProductInfo(
                        context,
                        isTabletCard: isTabletCard,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    _buildPriceAndStock(
                      context,
                      stockColor,
                      stockBackground,
                      isTabletCard: isTabletCard,
                    ),
                    const SizedBox(width: AppDimensions.spacingLg),
                    _buildAddButton(
                      context,
                      size: isTabletCard ? 44 : 40,
                      iconSize: isTabletCard ? 23 : 21,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context, Color stockColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        _buildCompactProductIcon(context),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.product.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${widget.currency} '
                      '${widget.product.sellingPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Flexible(
                    child: Text(
                      '• Stock ${widget.product.stockQuantity}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: stockColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        _buildAddButton(context, size: 40, iconSize: 21),
      ],
    );
  }

  Widget _buildCompactProductIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: 20,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildProductIcon(
    BuildContext context, {
    required double size,
    required double iconSize,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: iconSize,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, {required bool isTabletCard}) {
    final colorScheme = Theme.of(context).colorScheme;

    final nameFontSize = isTabletCard ? 19.0 : 17.0;
    final detailFontSize = isTabletCard ? 14.0 : 13.0;
    final categoryIconSize = isTabletCard ? 16.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: AppTextStyles.heading2.copyWith(
            color: colorScheme.onSurface,
            fontSize: nameFontSize,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          'SKU: ${widget.product.sku}',
          style: AppTextStyles.caption.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: detailFontSize,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Row(
          children: [
            Icon(
              Icons.category_outlined,
              size: categoryIconSize,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            Flexible(
              child: Text(
                widget.product.category,
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: detailFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceAndStock(
    BuildContext context,
    Color stockColor,
    Color stockBackground, {
    required bool isTabletCard,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final priceFontSize = isTabletCard ? 20.0 : 18.0;
    final stockFontSize = isTabletCard ? 13.0 : 12.0;
    final stockIconSize = isTabletCard ? 16.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${widget.currency} '
          '${widget.product.sellingPrice.toStringAsFixed(2)}',
          style: AppTextStyles.statValue.copyWith(
            color: colorScheme.onSurface,
            fontSize: priceFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTabletCard
                ? AppDimensions.spacingMd
                : AppDimensions.spacingSm,
            vertical: isTabletCard
                ? AppDimensions.spacingSm
                : AppDimensions.spacingXs,
          ),
          decoration: BoxDecoration(
            color: stockBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.product.isLowStock
                    ? Icons.warning_amber_rounded
                    : Icons.inventory_2_outlined,
                size: stockIconSize,
                color: stockColor,
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Text(
                'Stock: ${widget.product.stockQuantity}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: stockColor,
                  fontSize: stockFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(
    BuildContext context, {
    required double size,
    required double iconSize,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.quantity == 0) {
      return FilledButton(
        onPressed: widget.onAdd,
        style: FilledButton.styleFrom(
          minimumSize: Size(size, size),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
        child: Icon(Icons.add_rounded, size: iconSize),
      );
    }

    return Container(
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: IconButton(
              onPressed: widget.onDecrease,
              tooltip: 'Decrease quantity',
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.remove_rounded,
                size: iconSize - 2,
                color: colorScheme.primary,
              ),
            ),
          ),
          SizedBox(
            width: size * 0.75,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  '${widget.quantity}',
                  key: ValueKey(widget.quantity),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: IconButton(
              onPressed: widget.onIncrease,
              tooltip: 'Increase quantity',
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.add_rounded,
                size: iconSize - 2,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CART ITEM TILE
// =============================================================================

class _CartItemTile extends StatelessWidget {
  final _CartItem item;
  final String currency;

  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.currency,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        'SKU: ${item.product.sku}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Remove item',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    backgroundColor: colorScheme.errorContainer,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              '$currency '
              '${item.product.sellingPrice.toStringAsFixed(2)} each',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Row(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove_rounded,
                        tooltip: 'Decrease quantity',
                        onPressed: onDecrease,
                      ),
                      SizedBox(
                        width: 38,
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add_rounded,
                        tooltip: 'Increase quantity',
                        onPressed: onIncrease,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      '$currency '
                      '${item.total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CART QUANTITY BUTTON
// =============================================================================

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 19, color: colorScheme.primary),
      ),
    );
  }
}
