// ─────────────────────────────────────────────────────────────
// BizFlow master app-icon generator
//
// Paints the 1024x1024 master icon PNG that replicates the
// in-app `BrandMark` identity (lib/core/widgets/brand_ui.dart):
// a rounded-square canvas with a diagonal royal gradient
// (AppColors.royalStart → royalMid → royalEnd), a white glossy
// top highlight, a subtle aurora-teal radial glow in the top-right
// corner, and the white flowing bolt glyph with its teal "flow" dot.
//
// Run:  dart run tool/generate_icon.dart
// Output: assets/icon/app_icon.png (1024x1024)
// ─────────────────────────────────────────────────────────────

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

// ── Brand palette (AppColors, lib/core/theme/app_colors.dart) ──
const int royalStart = 0xFF8460FF;
const int royalMid = 0xFF5B5BF7;
const int royalEnd = 0xFF4338CA;
const int auroraTeal = 0xFF5EEAD4;
const int white = 0xFFFFFFFF;

const int size = 1024;

// BrandMark corner radius ratio (BorderRadius.circular(size * 0.31)).
const double cornerRadiusRatio = 0.31;

// Bolt polygon from _FlowMarkPainter, in fractions of canvas size:
//   (0.57,0.18) (0.30,0.53) (0.47,0.53) (0.40,0.82) (0.71,0.44) (0.52,0.44)
const List<(double, double)> boltPoints = [
  (0.57, 0.18),
  (0.30, 0.53),
  (0.47, 0.53),
  (0.40, 0.82),
  (0.71, 0.44),
  (0.52, 0.44),
];

// Teal flow dot from _FlowMarkPainter: center (0.72, 0.25), r 0.055.
const double dotCx = 0.72;
const double dotCy = 0.25;
const double dotR = 0.055;

int redOf(int c) => (c >> 16) & 0xFF;
int greenOf(int c) => (c >> 8) & 0xFF;
int blueOf(int c) => c & 0xFF;

int pack(int r, int g, int b, int a) =>
    (a << 24) | (r << 16) | (g << 8) | b;

int lerpColor(int from, int to, double t) {
  t = t.clamp(0.0, 1.0);
  final ar = redOf(from), ag = greenOf(from), ab = blueOf(from);
  final br = redOf(to), bg = greenOf(to), bb = blueOf(to);
  return pack(
    (ar + (br - ar) * t).round(),
    (ag + (bg - ag) * t).round(),
    (ab + (bb - ab) * t).round(),
    255,
  );
}

/// Diagonal gradient (topLeft → bottomRight), stops [0, 0.55, 1] —
/// the BrandMark LinearGradient rhythm.
int gradientAt(double x, double y) {
  final t = ((x + y) / (2 * size)).clamp(0.0, 1.0);
  return t < 0.55
      ? lerpColor(royalStart, royalMid, t / 0.55)
      : lerpColor(royalMid, royalEnd, (t - 0.55) / 0.45);
}

/// Even-odd inside test for the bolt polygon.
bool insideBolt(double x, double y) {
  var inside = false;
  for (var i = 0, j = boltPoints.length - 1;
      i < boltPoints.length;
      j = i++) {
    final ax = boltPoints[i].$1 * size;
    final ay = boltPoints[i].$2 * size;
    final bx = boltPoints[j].$1 * size;
    final by = boltPoints[j].$2 * size;

    if ((ay > y) != (by > y)) {
      final xInt = (bx - ax) * (y - ay) / (by - ay) + ax;
      if (x < xInt) inside = !inside;
    }
  }
  return inside;
}

/// Signed distance to a rounded rect spanning [0, size] with the
/// given corner radius. Negative inside, positive outside.
double roundedRectSdf(double x, double y, double radius) {
  final half = size / 2.0;
  final qx = (x - half).abs() - (half - radius);
  final qy = (y - half).abs() - (half - radius);
  final oqx = math.max(qx, 0.0);
  final oqy = math.max(qy, 0.0);
  return math.sqrt(oqx * oqx + oqy * oqy) +
      math.min(math.max(qx, qy), 0.0) -
      radius;
}

void main(List<String> args) {
  // Foreground mode: square canvas (fully filled) for Android adaptive
  // icons so the system mask shapes the silhouette; a rounded-corner
  // squircle on transparent background would show the solid adaptive
  // background between the canvas corner and the mask.
  final foregroundMode = args.contains('--foreground');
  final outputPath = foregroundMode
      ? 'assets/icon/app_icon_foreground.png'
      : 'assets/icon/app_icon.png';
  final radius = foregroundMode ? 0.0 : size * cornerRadiusRatio;

  const outputDir = 'assets/icon';
  final dir = Directory(outputDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);

  const radiusPx = dotR * size;

  // Supersampling factor for anti-aliased edges and glyphs.
  const ss = 4;

  final image = img.Image(width: size, height: size, numChannels: 4);

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final px = x + 0.5;
      final py = y + 0.5;

      var coverage = 0.0;
      var bolt = 0.0;

      for (var sy = 0; sy < ss; sy++) {
        for (var sx = 0; sx < ss; sx++) {
          final jx = px - 0.5 + (sx + 0.5) / ss;
          final jy = py - 0.5 + (sy + 0.5) / ss;

          // Rounded canvas coverage.
          final sd = roundedRectSdf(jx, jy, radius);
          coverage += (0.5 - sd).clamp(0.0, 1.0) / (ss * ss);

          if (insideBolt(jx, jy)) bolt += 1 / (ss * ss);
        }
      }

      if (coverage <= 0.002) {
        image.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        continue;
      }

      // Diagonal royal gradient base.
      var col = gradientAt(px, py);

      // Aurora-teal radial glow in the top-right corner.
      final glowCx = size * 0.86;
      final glowCy = size * 0.13;
      final glowD = math
              .sqrt(
                  (px - glowCx) * (px - glowCx) +
                      (py - glowCy) * (py - glowCy)) /
          (size * 0.55);
      if (glowD < 1) {
        final glowAlpha = math.pow(1 - glowD, 2.0) * 0.32;
        col = lerpColor(col, auroraTeal, glowAlpha);
      }

      // White glossy top highlight (BrandMark top band):
      // faint white wash falling from the top-left.
      final hl = (1 - py / (size * 0.48)).clamp(0.0, 1.0);
      if (hl > 0) {
        final alpha = hl * 0.20 * (1 - px / (size * 2.2));
        col = lerpColor(col, white, alpha);
      }

      // Teal flow dot (anti-aliased rim).
      final dotDx = px - dotCx * size;
      final dotDy = py - dotCy * size;
      final dotDist = math.sqrt(dotDx * dotDx + dotDy * dotDy);
      final dotA = (radiusPx + 0.5 - dotDist).clamp(0.0, 1.0);
      if (dotA > 0) col = lerpColor(col, auroraTeal, dotA);

      // White bolt glyph.
      if (bolt > 0) col = lerpColor(col, white, bolt);

      image.setPixel(
        x,
        y,
        img.ColorRgba8(
          redOf(col),
          greenOf(col),
          blueOf(col),
          (255 * coverage).round().clamp(0, 255),
        ),
      );
    }
  }

  final png = img.encodePng(image);
  final file = File(outputPath);
  file.writeAsBytesSync(png);
  stdout
      .writeln('OK: wrote ${file.path} (${png.length ~/ 1024} KB, 1024x1024)');
}
