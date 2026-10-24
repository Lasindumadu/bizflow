import 'package:flutter/material.dart';

import 'brand_ui.dart';

/// Backwards-compatible alias for the BizFlow brand mark.
class BrandBadge extends StatelessWidget {
  final double size;
  const BrandBadge({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) => BrandMark(size: size);
}
