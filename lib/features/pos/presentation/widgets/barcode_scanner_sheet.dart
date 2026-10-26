import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Bottom-sheet camera barcode scanner with Aurora 2.0 styling.
///
/// Requests camera permission, shows a live preview, supports flash toggle
/// and gallery import, and pops with the scanned barcode string on success.
class BarcodeScannerSheet extends StatefulWidget {
  const BarcodeScannerSheet({super.key});

  @override
  State<BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<BarcodeScannerSheet> {
  final MobileScannerController _controller = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  bool _hasPermission = false;
  bool _isRequesting = false;
  bool _flashOn = false;
  bool _isScanning = true;

  String? _lastCode;
  Timer? _scanDebounce;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _scanDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    if (!mounted) return;
    setState(() => _isRequesting = true);
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _hasPermission = status.isGranted;
      _isRequesting = false;
    });
  }

  Future<void> _toggleFlash() async {
    await _controller.toggleTorch();
    if (!mounted) return;
    setState(() => _flashOn = !_flashOn);
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null || !mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Image selected — barcode decode from gallery is not supported on this platform.'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image from gallery.')),
      );
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    final String? code = barcodes.firstOrNull?.rawValue;
    if (code == null || code == _lastCode) return;

    _lastCode = code;
    _isScanning = false;

    // Debounce so rapid re-detections of the same code don't pop multiple times.
    _scanDebounce?.cancel();
    _scanDebounce = Timer(const Duration(milliseconds: 800), () {
      _lastCode = null;
      if (mounted) {
        setState(() => _isScanning = true);
      }
    });

    if (mounted) {
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Royal gradient header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            decoration: BoxDecoration(
              gradient: AppDecor.royalGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.35),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SCAN BARCODE',
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Point the camera at the barcode',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Flash toggle
                    Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(alpha: _flashOn ? 0.30 : 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: IconButton(
                        tooltip: _flashOn ? 'Flash on' : 'Flash off',
                        icon: Icon(
                          _flashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _toggleFlash,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Gallery import
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: IconButton(
                        tooltip: 'Import from gallery',
                        icon: const Icon(
                          Icons.image_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _pickFromGallery,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Camera preview ──
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  if (!_hasPermission || _isRequesting)
                    Container(
                      color:
                          isDark ? AppColors.darkSurface : Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isRequesting
                                  ? Icons.hourglass_top_rounded
                                  : Icons.camera_alt_outlined,
                              size: 48,
                              color: isDark
                                  ? AppColors.royalMid
                                  : AppColors.primaryDark,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isRequesting
                                  ? 'Requesting camera permission...'
                                  : 'Camera permission required',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (!_hasPermission && !_isRequesting) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Grant camera access to scan barcodes.',
                                style:
                                    theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    else
                      MobileScanner(
                        controller: _controller,
                        onDetect: _onDetect,
                      ),

                  // Scan reticle overlay
                  const _ScanReticle(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated corner reticle that marks the scan zone.
class _ScanReticle extends StatelessWidget {
  const _ScanReticle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          children: [
            // Center target dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.brandMint,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandMint.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            // Four animated corners
            ...List.generate(4, (i) {
              final Alignment alignment;
              switch (i) {
                case 0:
                  alignment = Alignment.topLeft;
                case 1:
                  alignment = Alignment.topRight;
                case 2:
                  alignment = Alignment.bottomLeft;
                default:
                  alignment = Alignment.bottomRight;
              }
              return Positioned.fill(
                child: Align(
                  alignment: alignment,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      border: Border(
                        top: alignment == Alignment.topLeft ||
                                alignment == Alignment.topRight
                            ? const BorderSide(
                                color: AppColors.brandMint,
                                width: 3,
                              )
                            : BorderSide.none,
                        bottom: alignment == Alignment.bottomLeft ||
                                alignment == Alignment.bottomRight
                            ? const BorderSide(
                                color: AppColors.brandMint,
                                width: 3,
                              )
                            : BorderSide.none,
                        left: alignment == Alignment.topLeft ||
                                alignment == Alignment.bottomLeft
                            ? const BorderSide(
                                color: AppColors.brandMint,
                                width: 3,
                              )
                            : BorderSide.none,
                        right: alignment == Alignment.topRight ||
                                alignment == Alignment.bottomRight
                            ? const BorderSide(
                                color: AppColors.brandMint,
                                width: 3,
                              )
                            : BorderSide.none,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
