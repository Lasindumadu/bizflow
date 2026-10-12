class AppDimensions {
  // ─────────────────────────────────────────────
  // Screen spacing
  // ─────────────────────────────────────────────

  static const screenPadding = 16.0;
  static const screenPaddingLarge = 24.0;
  static const sectionSpacing = 24.0;
  static const componentSpacing = 16.0;

  // ─────────────────────────────────────────────
  // Spacing scale
  // ─────────────────────────────────────────────

  static const spacingXxxs = 2.0;
  static const spacingXxs = 4.0;
  static const spacingXs = 8.0;
  static const spacingSm = 12.0;
  static const spacingMd = 16.0;
  static const spacingLg = 20.0;
  static const spacingXl = 24.0;
  static const spacingXxl = 32.0;
  static const spacingXxxl = 48.0;

  // ─────────────────────────────────────────────
  // Corner radius
  // ─────────────────────────────────────────────

  static const radiusXs = 4.0;
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 20.0;
  static const radiusXxl = 24.0;
  static const radiusFull = 9999.0;

  // Existing names kept for compatibility.
  static const cardRadius = radiusLg;
  static const buttonRadius = radiusMd;
  static const inputRadius = radiusMd;
  static const chipRadius = radiusFull;
  static const avatarRadius = radiusFull;

  // ─────────────────────────────────────────────
  // Component heights
  // ─────────────────────────────────────────────

  static const inputHeight = 52.0;
  static const inputHeightSm = 44.0;
  static const buttonHeight = 48.0;
  static const buttonHeightSm = 40.0;
  static const buttonHeightLg = 56.0;
  static const compactButtonHeight = 36.0;
  static const listTileHeight = 56.0;
  static const appBarHeight = 64.0;
  static const bottomNavHeight = 72.0;
  static const dialogMaxWidth = 560.0;
  static const sheetMaxHeight = 0.9;

  // ─────────────────────────────────────────────
  // Elevation
  // ─────────────────────────────────────────────

  static const elevationNone = 0.0;
  static const elevationXs = 1.0;
  static const elevationSm = 2.0;
  static const elevationMd = 4.0;
  static const elevationLg = 8.0;
  static const elevationXl = 12.0;
  static const elevationXxl = 16.0;
  static const elevationXxxl = 24.0;

  static const cardElevation = elevationSm;
  static const cardElevationHover = elevationMd;
  static const dialogElevation = elevationXl;
  static const menuElevation = elevationLg;
  static const sheetElevation = elevationLg;
  static const fabElevation = elevationMd;
  static const fabElevationHover = elevationLg;

  // ─────────────────────────────────────────────
  // Animation durations
  // ─────────────────────────────────────────────

  static const durationInstant = Duration(milliseconds: 0);
  static const durationFast = Duration(milliseconds: 150);
  static const durationNormal = Duration(milliseconds: 250);
  static const durationSlow = Duration(milliseconds: 350);
  static const durationSlower = Duration(milliseconds: 500);

  // ─────────────────────────────────────────────
  // Breakpoints for responsive design
  // ─────────────────────────────────────────────

  static const breakpointSm = 600.0;
  static const breakpointMd = 900.0;
  static const breakpointLg = 1200.0;
  static const breakpointXl = 1440.0;

  // ─────────────────────────────────────────────
  // Content constraints
  // ─────────────────────────────────────────────

  static const contentMaxWidth = 1200.0;
  static const contentMaxWidthNarrow = 800.0;
  static const sidebarWidth = 280.0;
  static const sidebarWidthCollapsed = 72.0;
  static const railWidth = 80.0;
}