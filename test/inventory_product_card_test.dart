import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/features/inventory/presentation/widgets/inventory_product_card.dart';
import 'package:bizflow/models/product.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  final product = Product(
    id: 'prod-widget-1',
    name: 'Widget Product',
    sku: 'WIDGET-001',
    category: 'Test',
    purchasePrice: 100,
    sellingPrice: 150,
    stockQuantity: 10,
    lowStockThreshold: 2,
    barcode: '001234567890',
  );

  group('InventoryProductCard - role gating', () {
    testWidgets('stock buttons are disabled when the actor cannot manage stock',
        (tester) async {
      var stockInPressed = false;
      var stockOutPressed = false;
      var adjustmentPressed = false;
      var historyPressed = false;

      await tester.pumpWidget(
        wrap(
          InventoryProductCard(
            product: product,
            canManageStock: false,
            onStockIn: () => stockInPressed = true,
            onStockOut: () => stockOutPressed = true,
            onAdjustment: () => adjustmentPressed = true,
            onHistory: () => historyPressed = true,
          ),
        ),
      );

      final stockIn = find.widgetWithText(OutlinedButton, 'Stock In');
      final stockOut = find.widgetWithText(OutlinedButton, 'Stock Out');
      final adjust = find.widgetWithText(OutlinedButton, 'Adjust');

      expect(stockIn, findsOneWidget);
      expect(stockOut, findsOneWidget);
      expect(adjust, findsOneWidget);

      expect(
        tester.widget<OutlinedButton>(stockIn.first).onPressed,
        isNull,
      );
      expect(
        tester.widget<OutlinedButton>(stockOut.first).onPressed,
        isNull,
      );
      expect(
        tester.widget<OutlinedButton>(adjust.first).onPressed,
        isNull,
      );

      // History remains enabled regardless of role.
      expect(
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'History'))
            .onPressed,
        isNotNull,
      );

      await tester.tap(stockIn.first);
      await tester.tap(stockOut.first);
      await tester.tap(adjust.first);
      await tester.tap(find.widgetWithText(TextButton, 'History').first);

      expect(stockInPressed, isFalse);
      expect(stockOutPressed, isFalse);
      expect(adjustmentPressed, isFalse);
      expect(historyPressed, isTrue);
    });

    testWidgets('stock buttons are enabled when the actor can manage stock',
        (tester) async {
      var stockInPressed = false;
      var stockOutPressed = false;
      var adjustmentPressed = false;

      await tester.pumpWidget(
        wrap(
          InventoryProductCard(
            product: product,
            canManageStock: true,
            onStockIn: () => stockInPressed = true,
            onStockOut: () => stockOutPressed = true,
            onAdjustment: () => adjustmentPressed = true,
            onHistory: () {},
          ),
        ),
      );

      expect(
        tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Stock In').first,
        ).onPressed,
        isNotNull,
      );
      expect(
        tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Stock Out').first,
        ).onPressed,
        isNotNull,
      );
      expect(
        tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Adjust').first,
        ).onPressed,
        isNotNull,
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Stock In').first);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Stock Out').first);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Adjust').first);

      expect(stockInPressed, isTrue);
      expect(stockOutPressed, isTrue);
      expect(adjustmentPressed, isTrue);
    });
  });
}
