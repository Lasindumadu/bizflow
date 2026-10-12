import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/services/backup_service.dart';
import '../../../../data/services/csv_export_service.dart';
import '../../../../data/demo/demo_data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  final CsvExportService _csvExportService = CsvExportService();
  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository();
  final DemoDataService _demoDataService = DemoDataService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isExporting = false;
  bool _isLoadingSettings = true;
  bool _isSavingSettings = false;
  bool _isLoadingDemoData = false;
  bool _isClearingDemoData = false;
  bool _isResettingData = false;

  bool _loyaltyEnabled = true;
  final TextEditingController _loyaltyEarnRateController =
      TextEditingController(text: '1.0');
  final TextEditingController _loyaltyRedeemValueController =
      TextEditingController(text: '0.01');

  final TextEditingController _receiptHeaderController =
      TextEditingController();
  final TextEditingController _receiptFooterController =
      TextEditingController();
  final TextEditingController _receiptNoteController =
      TextEditingController();
  bool _receiptShowPhone = true;
  bool _receiptShowAddress = true;

  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadBusinessSettings();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _loyaltyEarnRateController.dispose();
    _loyaltyRedeemValueController.dispose();
    _receiptHeaderController.dispose();
    _receiptFooterController.dispose();
    _receiptNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessSettings() async {
    try {
      final settings = await _businessSettingsRepository.getSettings();

      if (!mounted) {
        return;
      }

      _businessNameController.text = settings.businessName;
      _addressController.text = settings.address;
      _phoneController.text = settings.phone;
      _emailController.text = settings.email;
      _loyaltyEarnRateController.text = settings.loyaltyEarnRate
          .toStringAsFixed(2);
      _loyaltyRedeemValueController.text = settings.loyaltyRedeemValue
          .toStringAsFixed(2);
      _receiptHeaderController.text = settings.receiptHeader;
      _receiptFooterController.text = settings.receiptFooter;
      _receiptNoteController.text = settings.receiptNote;

      setState(() {
        _currency = settings.currency;
        _loyaltyEnabled = settings.loyaltyEnabled;
        _receiptShowPhone = settings.receiptShowPhone;
        _receiptShowAddress = settings.receiptShowAddress;
        _isLoadingSettings = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingSettings = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load business settings: $error')),
      );
    }
  }

  Future<void> _clearDemoData() async {
    if (_isClearingDemoData ||
        _isLoadingDemoData ||
        _isBackingUp ||
        _isRestoring ||
        _isExporting ||
        _isSavingSettings) {
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Demo Data?'),
          content: const Text(
            'This will remove all BizFlow demo products, sales, customers, '
            'categories, expenses, and stock movements.\n\n'
            'Your real business data will not be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Clear Demo Data'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) {
      return;
    }

    setState(() {
      _isClearingDemoData = true;
    });

    try {
      await _demoDataService.clearDemoData();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo data cleared successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear demo data: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isClearingDemoData = false;
        });
      }
    }
  }

  Future<void> _saveBusinessSettings() async {
    if (_isSavingSettings) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isSavingSettings = true;
    });

    try {
      await _businessSettingsRepository.saveSettings(
        businessName: _businessNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        currency: _currency,
        loyaltyEnabled: _loyaltyEnabled,
        loyaltyEarnRate:
            double.tryParse(_loyaltyEarnRateController.text.trim()) ?? 1.0,
        loyaltyRedeemValue:
            double.tryParse(_loyaltyRedeemValueController.text.trim()) ?? 0.01,
        receiptHeader: _receiptHeaderController.text.trim(),
        receiptFooter: _receiptFooterController.text.trim(),
        receiptNote: _receiptNoteController.text.trim(),
        receiptShowPhone: _receiptShowPhone,
        receiptShowAddress: _receiptShowAddress,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business settings saved successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save business settings: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingSettings = false;
        });
      }
    }
  }

  String? _validateBusinessName(String? value) {
    final businessName = value?.trim() ?? '';

    if (businessName.isEmpty) {
      return 'Business name is required.';
    }

    if (businessName.length < 2) {
      return 'Business name must be at least 2 characters.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return null;
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return null;
    }

    final phonePattern = RegExp(r'^[0-9+()\- ]+$');

    if (!phonePattern.hasMatch(phone)) {
      return 'Please enter a valid phone number.';
    }

    final digitCount = phone.replaceAll(RegExp(r'[^0-9]'), '').length;

    if (digitCount < 7) {
      return 'Phone number must contain at least 7 digits.';
    }

    return null;
  }

  Future<void> _backupData() async {
    if (_isBackingUp || _isRestoring || _isExporting || _isSavingSettings) {
      return;
    }

    setState(() {
      _isBackingUp = true;
    });

    try {
      await _backupService.saveBackup();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup saved successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Backup failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  Future<void> _restoreData() async {
    if (_isBackingUp || _isRestoring || _isExporting || _isSavingSettings) {
      return;
    }

    setState(() {
      _isRestoring = true;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();

      final backup = await _backupService.validateBackupJson(bytes);

      if (!mounted) {
        return;
      }

      final data = backup['data'] as Map<String, dynamic>;

      final products = data['products'] as List;
      final categories = data['categories'] as List;
      final sales = data['sales'] as List;
      final saleItems = data['saleItems'] as List;
      final customers = data['customers'] as List;
      final expenses = data['expenses'] as List;
      final stockMovements = data['stockMovements'] as List;
      final businessSettings = data['businessSettings'] as List;

      final businessSetting = businessSettings.isNotEmpty
          ? Map<String, dynamic>.from(businessSettings.first as Map)
          : null;

      final shouldRestore = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Restore Backup?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Text(
                    'This will replace all current BizFlow data with '
                    'the selected backup.',
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Backup contents:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  if (businessSetting != null) ...[
                    Text(
                      'Business: '
                      '${businessSetting['businessName']}',
                    ),
                    Text(
                      'Currency: '
                      '${businessSetting['currency']}',
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                  ],
                  Text('Products: ${products.length}'),
                  Text('Categories: ${categories.length}'),
                  Text('Sales: ${sales.length}'),
                  Text('Sale Items: ${saleItems.length}'),
                  Text('Customers: ${customers.length}'),
                  Text('Expenses: ${expenses.length}'),
                  Text(
                    'Stock Movements: '
                    '${stockMovements.length}',
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  const Text(
                    'Current data will be replaced. '
                    'Make sure you have a recent backup before continuing.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Restore'),
              ),
            ],
          );
        },
      );

      if (shouldRestore != true) {
        return;
      }

      await _backupService.restoreBackup(bytes);

      await _loadBusinessSettings();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backup restored successfully. '
            'BizFlow data has been restored.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Restore failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  Future<void> _exportProductsCsv() async {
    if (_isBackingUp || _isRestoring || _isExporting || _isSavingSettings) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await _csvExportService.exportProducts();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Products CSV exported successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Products CSV export failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportSalesCsv() async {
    if (_isBackingUp || _isRestoring || _isExporting || _isSavingSettings) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await _csvExportService.exportSales();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sales CSV exported successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sales CSV export failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportCustomersCsv() async {
    if (_isBackingUp || _isRestoring || _isExporting || _isSavingSettings) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await _csvExportService.exportCustomers();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customers CSV exported successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customers CSV export failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportExpensesCsv() async {
    if (_isBackingUp || _isRestoring || _isExporting || _isSavingSettings) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await _csvExportService.exportExpenses();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expenses CSV exported successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expenses CSV export failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _loadDemoData() async {
    if (_isLoadingDemoData ||
        _isBackingUp ||
        _isRestoring ||
        _isExporting ||
        _isSavingSettings) {
      return;
    }

    final shouldLoad = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Load Demo Data?'),
          content: const Text(
            'This will add sample BizFlow data for development and testing.\n\n'
            'Existing non-demo data will not be removed.\n\n'
            'Use this only for development/testing.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Load Demo Data'),
            ),
          ],
        );
      },
    );

    if (shouldLoad != true) {
      return;
    }

    setState(() {
      _isLoadingDemoData = true;
    });

    try {
      await _demoDataService.loadDemoData();

      await _loadBusinessSettings();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo data loaded successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load demo data: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDemoData = false;
        });
      }
    }
  }

  Future<void> _resetAllData() async {
    if (_isResettingData ||
        _isLoadingDemoData ||
        _isClearingDemoData ||
        _isBackingUp ||
        _isRestoring ||
        _isExporting ||
        _isSavingSettings) {
      return;
    }

    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset All Data?'),
          content: const Text(
            'This will permanently delete all BizFlow data from this device.\n\n'
            'This includes products, categories, sales, customers, expenses, '
            'stock movements, and business settings.\n\n'
            'This action cannot be undone. Create a backup before continuing.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Reset All Data'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true || !mounted) {
      return;
    }

    setState(() {
      _isResettingData = true;
    });

    try {
      await _backupService.resetAllData();

      _businessNameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _emailController.clear();

      if (!mounted) {
        return;
      }

      setState(() {
        _currency = 'USD';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All BizFlow data has been reset successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to reset data: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isResettingData = false;
        });
      }
    }
  }

  Widget _buildThemeSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: AppTextStyles.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Choose how BizFlow looks on your device.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            AnimatedBuilder(
              animation: themeController,
              builder: (context, child) {
                return SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('System'),
                    ),
                  ],
                  selected: {themeController.themeMode},
                  onSelectionChanged: (selection) {
                    if (selection.isEmpty) {
                      return;
                    }

                    themeController.setThemeMode(selection.first);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt Branding',
          style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          'Control what appears on printed and PDF receipts.',
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _receiptHeaderController,
                  decoration: const InputDecoration(
                    labelText: 'Receipt header',
                    hintText: 'e.g. Thank you for your purchase!',
                    prefixIcon: Icon(Icons.receipt_long_outlined),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                TextFormField(
                  controller: _receiptFooterController,
                  decoration: const InputDecoration(
                    labelText: 'Receipt footer',
                    hintText: 'e.g. Returns accepted within 7 days',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                TextFormField(
                  controller: _receiptNoteController,
                  decoration: const InputDecoration(
                    labelText: 'Note under the total',
                    hintText: 'e.g. Tax invoice',
                    prefixIcon: Icon(Icons.info_outline_rounded),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _receiptShowPhone,
                  onChanged: (v) => setState(() => _receiptShowPhone = v),
                  title: const Text('Show phone number'),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _receiptShowAddress,
                  onChanged: (v) => setState(() => _receiptShowAddress = v),
                  title: const Text('Show address'),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _isSavingSettings
                        ? null
                        : _saveBusinessSettings,
                    icon: _isSavingSettings
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save Receipt Settings'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoyaltySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loyalty Programme',
          style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          'Reward repeat customers with points on every sale.',
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable loyalty points',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Customers earn points automatically at checkout',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _loyaltyEnabled,
                      onChanged: (value) =>
                          setState(() => _loyaltyEnabled = value),
                    ),
                  ],
                ),
                if (_loyaltyEnabled) ...[
                  const SizedBox(height: AppDimensions.spacingLg),
                  TextFormField(
                    controller: _loyaltyEarnRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Points earned per 1.0 spent',
                      hintText: 'e.g. 1.0',
                      prefixIcon: Icon(Icons.add_circle_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  TextFormField(
                    controller: _loyaltyRedeemValueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Value of 1 point when redeemed',
                      hintText: 'e.g. 0.01',
                      prefixIcon: Icon(Icons.redeem_rounded),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingLg),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _isSavingSettings ? null : _saveBusinessSettings,
                    icon: _isSavingSettings
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save Loyalty'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessConfigurationSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Configuration',
          style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: _isLoadingSettings
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _businessNameController,
                          textInputAction: TextInputAction.next,
                          validator: _validateBusinessName,
                          decoration: const InputDecoration(
                            labelText: 'Business Name',
                            hintText: 'Enter your business name',
                            prefixIcon: Icon(Icons.store_outlined),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        TextFormField(
                          controller: _addressController,
                          textInputAction: TextInputAction.next,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            hintText: 'Enter your business address',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: _validatePhone,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            hintText: 'Enter your business phone',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your business email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        DropdownButtonFormField<String>(
                          initialValue: _currency,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'USD',
                              child: Text('USD - US Dollar'),
                            ),
                            DropdownMenuItem(
                              value: 'LKR',
                              child: Text('LKR - Sri Lankan Rupee'),
                            ),
                            DropdownMenuItem(
                              value: 'EUR',
                              child: Text('EUR - Euro'),
                            ),
                            DropdownMenuItem(
                              value: 'GBP',
                              child: Text('GBP - British Pound'),
                            ),
                            DropdownMenuItem(
                              value: 'INR',
                              child: Text('INR - Indian Rupee'),
                            ),
                            DropdownMenuItem(
                              value: 'AUD',
                              child: Text('AUD - Australian Dollar'),
                            ),
                            DropdownMenuItem(
                              value: 'CAD',
                              child: Text('CAD - Canadian Dollar'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _currency = value;
                            });
                          },
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),
                        FilledButton.icon(
                          onPressed:
                              _isSavingSettings ||
                                  _isBackingUp ||
                                  _isRestoring ||
                                  _isExporting
                              ? null
                              : _saveBusinessSettings,
                          icon: _isSavingSettings
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _isSavingSettings
                                ? 'Saving...'
                                : 'Save Business Settings',
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      title,
      style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isLoading,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        trailing: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          _buildThemeSection(context),

          const SizedBox(height: AppDimensions.spacingXl),

          _buildBusinessConfigurationSection(context),

          const SizedBox(height: AppDimensions.spacingXl),

          _buildLoyaltySection(context),

          const SizedBox(height: AppDimensions.spacingXl),

          _buildReceiptSection(context),

          const SizedBox(height: AppDimensions.spacingXl),

          _buildSectionTitle(context, 'Backup & Restore'),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.backup_outlined,
            title: 'Backup Data',
            subtitle: 'Save your BizFlow data as a backup file',
            isLoading: _isBackingUp,
            onTap:
                _isBackingUp ||
                    _isRestoring ||
                    _isExporting ||
                    _isSavingSettings
                ? null
                : _backupData,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.restore_outlined,
            title: 'Restore Data',
            subtitle: 'Restore BizFlow data from a backup file',
            isLoading: _isRestoring,
            onTap:
                _isBackingUp ||
                    _isRestoring ||
                    _isExporting ||
                    _isSavingSettings
                ? null
                : _restoreData,
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          _buildSectionTitle(context, 'Data Export'),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.inventory_2_outlined,
            title: 'Export Products',
            subtitle: 'Export your products as a CSV file',
            isLoading: _isExporting,
            onTap:
                _isBackingUp ||
                    _isRestoring ||
                    _isExporting ||
                    _isSavingSettings
                ? null
                : _exportProductsCsv,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.point_of_sale_outlined,
            title: 'Export Sales',
            subtitle: 'Export your sales as a CSV file',
            isLoading: _isExporting,
            onTap:
                _isBackingUp ||
                    _isRestoring ||
                    _isExporting ||
                    _isSavingSettings
                ? null
                : _exportSalesCsv,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.people_outline,
            title: 'Export Customers',
            subtitle: 'Export your customers as a CSV file',
            isLoading: _isExporting,
            onTap:
                _isBackingUp ||
                    _isRestoring ||
                    _isExporting ||
                    _isSavingSettings
                ? null
                : _exportCustomersCsv,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.receipt_long_outlined,
            title: 'Export Expenses',
            subtitle: 'Export your expenses as a CSV file',
            isLoading: _isExporting,
            onTap:
                _isBackingUp ||
                    _isRestoring ||
                    _isExporting ||
                    _isSavingSettings
                ? null
                : _exportExpensesCsv,
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          _buildSectionTitle(context, 'Development'),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.science_outlined,
            title: 'Load Demo Data',
            subtitle: 'Load sample data for development and testing',
            isLoading: _isLoadingDemoData,
            onTap:
                _isLoadingDemoData ||
                    _isBackingUp ||
                    _isRestoring ||
                    _isExporting ||
                    _isSavingSettings
                ? null
                : _loadDemoData,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.delete_sweep_outlined,
            title: 'Clear Demo Data',
            subtitle: 'Remove sample data without removing your real data',
            isLoading: _isClearingDemoData,
            onTap:
                _isClearingDemoData ||
                    _isLoadingDemoData ||
                    _isBackingUp ||
                    _isRestoring ||
                    _isExporting ||
                    _isSavingSettings
                ? null
                : _clearDemoData,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.warning_amber_outlined,
            title: 'Reset All Data',
            subtitle: 'Permanently delete all data and start fresh',
            isLoading: _isResettingData,
            onTap:
                _isResettingData ||
                    _isLoadingDemoData ||
                    _isClearingDemoData ||
                    _isBackingUp ||
                    _isRestoring ||
                    _isExporting ||
                    _isSavingSettings
                ? null
                : _resetAllData,
          ),
        ],
      ),
    );
  }
}
