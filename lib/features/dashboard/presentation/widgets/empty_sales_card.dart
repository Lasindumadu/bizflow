import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class EmptySalesCard extends StatelessWidget {
  const EmptySalesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXl,
            vertical: AppDimensions.spacingXxl,
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 30,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              Text(
                'No sales yet',
                style: AppTextStyles.heading2.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingSm),

              Text(
                'Your recent sales will appear here.',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
