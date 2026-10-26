import 'package:flutter/material.dart';

import '../../../../core/widgets/brand_ui.dart';

/// Photo-backed empty state for the sales list, mapped to the store
/// photography per the Aurora 2.0 photo system.
class EmptySalesCard extends StatelessWidget {
  const EmptySalesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const BrandEmptyState(
        icon: Icons.receipt_long_rounded,
        image: AppImages.storeHero,
        title: 'No sales yet',
        message: 'Your recent sales will appear here once you open the till.',
      ),
    );
  }
}
