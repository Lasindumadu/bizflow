import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../widgets/settings_section_title.dart';
import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/services/backup_service.dart';
import '../../../../data/services/csv_export_service.dart';
import '../../../../data/demo/demo_data_service.dart';
import '../../../../core/services/thermal_printer_service.dart';

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

  /// Thermal printer / cash drawer service.
  final ThermalPrinterService _printerService = ThermalPrinterService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  /// Printer device address (e.g. Bluetooth MAC) and optional display name.
  final TextEditingController _printerAddressController =
      TextEditingController();
  final TextEditingController _printerNameController = TextEditingController();

  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isExporting = false;
  bool _isLoadingSettings = true;
  bool _isSavingSettings = false;
  bool _isLoadingDemoData = false;
  bool _isClearingDemoData = false;
  bool _isResettingData = false;

  /// Whether a printer connection operation is in flight.
  bool _isConnectingPrinter = false;
  /// Whether a print / cash-drawer operation is in flight.
  bool _isPrinterBusy = false;

  /// Selected connection type.
  PrinterConnectionType _printerConnectionType =
      PrinterConnectionType.bluetooth;

  bool _loyaltyEnabled = true;
  final TextEditingController _loyaltyEarnRateController =
      TextEditingController(text: '1.0');
  final TextEditingController _loyaltyRedeemValueController =
      TextEditingController(text: '0.01');

  final TextEditingController _receiptHeaderController =
      TextEditingController();
  final TextEditingController _receiptFooterController =
      TextEditingController();
  final TextEditingController _receiptNoteController = TextEditingController();
  bool _receiptShowPhone = true;
  bool _receiptShowAddress = true;

  String _currency = 'USD';
  bool _loginRequired = false;
  int _inactivityTimeoutMinutes = 0;

  /// Phase G: tax / VAT settings.
  final TextEditingController _taxRateController = TextEditingController();
  bool _taxInclusive = false;

  /// Whether the acting session is the owner (security/backup/reset).
  bool get _isOwner => canPerform(
        sessionController.current,
        {StaffRole.owner},
      );

  /// Whether the acting session can manage owner+manager features.
  bool get _canManage => canPerform(
        sessionController.current,
        {StaffRole.owner, StaffRole.manager},
      );

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _appearanceKey = GlobalKey();
  final GlobalKey _businessKey = GlobalKey();
  final GlobalKey _taxKey = GlobalKey();
  final GlobalKey _loyaltyKey = GlobalKey();
  final GlobalKey _receiptKey = GlobalKey();
  final GlobalKey _printerKey = GlobalKey();
  final GlobalKey _dataKey = GlobalKey();

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
    _taxRateController.dispose();
    _printerAddressController.dispose();
    _printerNameController.dispose();
    _scrollController.dispose();
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
        _loginRequired = settings.loginRequired;
        _inactivityTimeoutMinutes = settings.inactivityTimeoutMinutes;
        _taxRateController.text = settings.taxRate.toStringAsFixed(2);
        _taxInclusive = settings.taxInclusive;
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
        loginRequired: _loginRequired,
        inactivityTimeoutMinutes: _inactivityTimeoutMinutes,
        taxRate: double.tryParse(_taxRateController.text.trim()) ?? 0.0,
        taxInclusive: _taxInclusive,
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

  /// Prompts the owner to confirm enabling startup PIN login.
  ///
  /// Enabling login is an owner-only action. The repository enforces this
  /// (rejects non-owner actors) and validates that an active owner with a
  /// usable PIN and recovery code exists before allowing the setting to flip.
  Future<bool?> _confirmLoginEnable() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enable Startup PIN Login?'),
          content: const Text(
            'When enabled, staff must sign in with their PIN before the app '
            'shell is shown on every startup. This applies to all staff '
            'accounts.\n\n'
            'Only an owner account can enable this. Before enabling, make sure '
            'the owner account is active, has a PIN set, and has a recovery '
            'code recorded. If you lose access to the owner account, use the '
            'owner recovery path to regain access.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  /// Prompts the owner to confirm disabling startup PIN login.
  Future<bool?> _confirmLoginDisable() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Disable Startup PIN Login?'),
          content: const Text(
            'When disabled, anyone can open BizFlow without signing in. '
            'Staff accounts and PINs will no longer be required at startup.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Disable'),
            ),
          ],
        );
      },
    );
  }

  /// Persists the startup PIN login requirement to the database.
  ///
  /// Only updates the `loginRequired` column, leaving all other business
  /// settings untouched. Shows a snack bar on success or failure.
  Future<void> _saveLoginRequired(bool value) async {
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
        loginRequired: value,
        inactivityTimeoutMinutes: _inactivityTimeoutMinutes,
      );
      if (!mounted) return;
      setState(() {
        _loginRequired = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Startup PIN login enabled.'
                : 'Startup PIN login disabled.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loginRequired = !value; // revert on failure
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${value ? 'enable' : 'disable'} startup PIN login: '
            '$error',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingSettings = false;
        });
      }
    }
  }

  /// Persists the inactivity auto-lock timeout setting.
  ///
  /// Only updates the `inactivityTimeoutMinutes` column, leaving all other
  /// business settings untouched. Shows a snack bar on success or failure.
  ///
  /// The timeout is a security control, so the repository rejects the change
  /// for a non-owner session. On rejection the previous value is restored so
  /// the dropdown never shows a value that was not persisted.
  Future<void> _saveInactivityTimeout(int value) async {
    final previous = _inactivityTimeoutMinutes;
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
        loginRequired: _loginRequired,
        inactivityTimeoutMinutes: value,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value == 0
                ? 'Inactivity auto-lock disabled.'
                : 'Inactivity auto-lock set to $value minutes.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        // Revert to the value that is actually persisted.
        _inactivityTimeoutMinutes = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set inactivity auto-lock: $error'),
          backgroundColor: AppColors.error,
        ),
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

    return BrandFormSection(
      title: 'Appearance',
      subtitle: 'Theme, type scale and motion for this device.',
      icon: Icons.palette_outlined,
      accent: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

            // Theme Mode Selector
            AnimatedBuilder(
              animation: themeController,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Mode',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Wrap(
                      spacing: AppDimensions.spacingSm,
                      runSpacing: AppDimensions.spacingSm,
                      children: AppThemeMode.values.map((mode) {
                        final isSelected = themeController.themeMode == mode;
                        return ChoiceChip(
                              label: Text(
                                mode.name
                                    .replaceAllMapped(
                                      RegExp(r'([A-Z])'),
                                      (m) => ' ${m.group(0)}',
                                    )
                                    .trim(),
                              ),
                              avatar: Icon(
                                _getThemeModeIcon(mode),
                                size: 18,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  themeController.setThemeMode(mode),
                              selectedColor: colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  width: isSelected ? 0 : 1.5,
                                ),
                              ),
                            )
                            .animate(
                              target: themeController.animationsEnabled ? 1 : 0,
                            )
                            .scale(duration: 200.ms, curve: Curves.easeOutBack);
                      }).toList(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            // Font Size Selector
            AnimatedBuilder(
              animation: themeController,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Font Size',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Wrap(
                      spacing: AppDimensions.spacingSm,
                      runSpacing: AppDimensions.spacingSm,
                      children: AppFontSize.values.map((size) {
                        final isSelected = themeController.fontSize == size;
                        return ChoiceChip(
                              label: Text(_getFontSizeLabel(size)),
                              selected: isSelected,
                              onSelected: (_) =>
                                  themeController.setFontSize(size),
                              selectedColor: colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  width: isSelected ? 0 : 1.5,
                                ),
                              ),
                            )
                            .animate(
                              target: themeController.animationsEnabled ? 1 : 0,
                            )
                            .scale(duration: 200.ms, curve: Curves.easeOutBack);
                      }).toList(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            // Animations Toggle
            AnimatedBuilder(
              animation: themeController,
              builder: (context, child) {
                return SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Animations',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Enable smooth transitions and micro-interactions',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                   value: themeController.animationsEnabled,
                   onChanged: (v) => themeController.setAnimationsEnabled(v),
                   activeThumbColor: colorScheme.primary,
                   activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
                 );
               },
             ),
        ],
      ),
    );
  }

  String _getFontSizeLabel(AppFontSize size) {
    switch (size) {
      case AppFontSize.small:
        return 'Small (85%)';
      case AppFontSize.medium:
        return 'Medium (100%)';
      case AppFontSize.large:
        return 'Large (115%)';
      case AppFontSize.extraLarge:
        return 'Extra Large (130%)';
    }
  }

  IconData _getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_outlined;
      case AppThemeMode.system:
        return Icons.brightness_auto_outlined;
      case AppThemeMode.highContrastLight:
        return Icons.contrast_outlined;
      case AppThemeMode.highContrastDark:
        return Icons.brightness_high_outlined;
      case AppThemeMode.sepia:
        return Icons.wb_sunny_outlined;
    }
  }

  Widget _buildReceiptSection(BuildContext context) {
    return BrandFormSection(
      title: 'Receipt branding',
      subtitle: 'Control what appears on printed and PDF receipts.',
      icon: Icons.receipt_long_outlined,
      accent: AppColors.brandMint,
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
                     onPressed: _isSavingSettings ? null : _saveBusinessSettings,
                     icon: _isSavingSettings
                         ? const SizedBox(
                             width: 16,
                             height: 16,
                             child: AuroraLoader(
                               size: 16,
                               strokeWidth: 2,
                               onDarkSurface: true,
                             ),
                           )
                         : const Icon(Icons.save_rounded, size: 18),
                     label: const Text('Save Receipt Settings'),
                   ),
                 ),
              ],
          ),
        );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Thermal printer & cash drawer section
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _connectPrinter() async {
    if (_printerService.isConnected || _isConnectingPrinter) return;

    final address = _printerAddressController.text.trim();
    if (address.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a device address.')),
      );
      return;
    }

    _printerService.setConnectionType(_printerConnectionType);

    setState(() => _isConnectingPrinter = true);
    try {
      await _printerService.connect(
        address: address,
        name: _printerNameController.text.trim().isEmpty
            ? null
            : _printerNameController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Connected to ${_printerService.deviceName ?? address}.'),
          backgroundColor: AppColors.brandMint,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isConnectingPrinter = false);
      }
    }
  }

  Future<void> _disconnectPrinter() async {
    if (!_printerService.isConnected) return;
    setState(() => _isConnectingPrinter = true);
    try {
      await _printerService.disconnect();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printer disconnected.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disconnect failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isConnectingPrinter = false);
      }
    }
  }

  Future<void> _testPrint() async {
    if (!_printerService.isConnected || _isPrinterBusy) return;

    final data = _buildTestReceiptData();
    final bytes = _printerService.formatReceipt(data: data);

    setState(() => _isPrinterBusy = true);
    try {
      final result = await _printerService.printReceipt(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success
              ? 'Test print sent to printer.'
              : 'Test print failed: ${result.message}'),
          backgroundColor: result.success
              ? AppColors.brandMint
              : AppColors.error,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test print failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPrinterBusy = false);
      }
    }
  }

  Future<void> _openCashDrawer() async {
    if (!_printerService.isConnected || _isPrinterBusy) return;

    setState(() => _isPrinterBusy = true);
    try {
      final result = await _printerService.openCashDrawer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success
              ? 'Cash drawer opened.'
              : 'Cash drawer failed: ${result.message}'),
          backgroundColor: result.success
              ? AppColors.brandMint
              : AppColors.error,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cash drawer failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPrinterBusy = false);
      }
    }
  }

  ReceiptData _buildTestReceiptData() {
    return ReceiptData(
      businessName: _businessNameController.text.trim().isNotEmpty
          ? _businessNameController.text.trim()
          : 'BizFlow Store',
      receiptHeader: _receiptHeaderController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      receiptId: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now().toString(),
      paymentMethod: 'Cash',
      customerName: 'Walk-in Customer',
      currency: _currency,
      items: const [
        ReceiptItem(name: 'Espresso', quantity: 2, unitPrice: 3.50, lineTotal: 7.00),
        ReceiptItem(name: 'Croissant', quantity: 1, unitPrice: 4.25, lineTotal: 4.25),
      ],
      subtotal: 11.25,
      discount: 0.0,
      total: 11.25,
      paidAmount: 11.25,
      changeAmount: 0.0,
      receiptFooter: _receiptFooterController.text.trim(),
      receiptNote: _receiptNoteController.text.trim(),
    );
  }

  Widget _buildPrinterSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BrandFormSection(
      title: 'Thermal printer',
      subtitle: 'Connect a Bluetooth / USB / Network receipt printer and cash drawer.',
      icon: Icons.print_outlined,
      accent: AppColors.brandMint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connection type selector
          Text(
            'Connection type',
            style: AppTextStyles.labelMedium.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: PrinterConnectionType.values.map((type) {
              final isSelected = _printerConnectionType == type;
              return ChoiceChip(
                label: Text(_printerTypeLabel(type)),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _printerConnectionType = type);
                },
                selectedColor: AppColors.brandMint,
                labelStyle: TextStyle(
                  color: isSelected
                      ? scheme.onPrimary
                      : scheme.onSurface,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.brandMint
                        : scheme.outline,
                    width: isSelected ? 0 : 1.5,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // Device address + name
          TextFormField(
            controller: _printerAddressController,
            decoration: InputDecoration(
              labelText: 'Device address',
              hintText: 'e.g. 00:11:22:33:44:55 or 192.168.1.50',
              prefixIcon: const Icon(Icons.bluetooth_outlined, size: 20),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          TextFormField(
            controller: _printerNameController,
            decoration: const InputDecoration(
              labelText: 'Printer name (display)',
              hintText: 'e.g. Main receipt printer',
              prefixIcon: Icon(Icons.print),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // Connect / disconnect
          Row(
            children: [
              Expanded(
                child: _isConnectingPrinter
                    ? const SizedBox(
                        height: 40,
                        child: Center(
                          child: AuroraLoader(size: 24, strokeWidth: 2),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: _printerService.isConnected
                            ? null
                            : _connectPrinter,
                        icon: const Icon(
                          Icons.bluetooth_rounded,
                          size: 18,
                        ),
                        label: const Text('Connect Printer'),
                      ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: _isConnectingPrinter
                    ? const SizedBox.shrink()
                    : OutlinedButton.icon(
                        onPressed:
                            _printerService.isConnected
                                ? _disconnectPrinter
                                : null,
                        icon: const Icon(
                          Icons.bluetooth_outlined,
                          size: 18,
                        ),
                        label: const Text('Disconnect'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.error,
                          side: BorderSide(color: scheme.error),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),

          // Connection status indicator
          _PrinterStatusRow(
            connected: _printerService.isConnected,
            deviceName: _printerService.deviceName ??
                _printerService.deviceAddress,
            error: _printerService.lastError,
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // Test print + cash drawer
          Row(
            children: [
              Expanded(
                child: _isPrinterBusy
                    ? const SizedBox(
                        height: 40,
                        child: Center(
                          child: AuroraLoader(size: 24, strokeWidth: 2),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: _printerService.isConnected
                            ? _testPrint
                            : null,
                        icon: const Icon(
                          Icons.receipt_long_rounded,
                          size: 18,
                        ),
                        label: const Text('Test Print'),
                      ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: _isPrinterBusy
                    ? const SizedBox.shrink()
                    : OutlinedButton.icon(
                        onPressed:
                            _printerService.isConnected
                                ? _openCashDrawer
                                : null,
                        icon: const Icon(
                          Icons.attach_money_rounded,
                          size: 18,
                        ),
                        label: const Text('Open Cash Drawer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandMint,
                          side: BorderSide(color: AppColors.brandMint),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _printerTypeLabel(PrinterConnectionType type) {
    switch (type) {
      case PrinterConnectionType.bluetooth:
        return 'Bluetooth';
      case PrinterConnectionType.usb:
        return 'USB';
      case PrinterConnectionType.network:
        return 'Network';
    }
  }

  Widget _buildLoyaltySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BrandFormSection(
      title: 'Loyalty programme',
      subtitle: 'Reward repeat customers with points on every sale.',
      icon: Icons.workspace_premium_outlined,
      accent: AppColors.tertiary,
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
                            child: AuroraLoader(
                              size: 16,
                              strokeWidth: 2,
                              onDarkSurface: true,
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save Loyalty'),
                  ),
                ),
              ],
          ),
        );
  }

  Widget _buildBusinessConfigurationSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BrandFormSection(
      title: 'Business configuration',
      subtitle: 'Identity, contact details and currency.',
      icon: Icons.storefront_outlined,
      accent: AppColors.primary,
      child: _isLoadingSettings
                ? const SizedBox(
                    height: 200,
                    child: Center(child: AuroraLoader(size: 46)),
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

                        // Phase D: startup PIN login toggle.
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.screenPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Startup PIN Login',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacingSm),
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    'Require staff PIN at startup',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _loginRequired
                                        ? 'Staff must sign in with a PIN before '
                                              'the app shell is shown.'
                                        : 'Anyone can open BizFlow without '
                                              'signing in.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  value: _loginRequired,
                                  onChanged: _isOwner && !_isSavingSettings
                                      ? (value) async {
                                          if (!value) {
                                            // Disabling login requires owner
                                            // authorization.
                                            final confirmed =
                                                await _confirmLoginDisable();
                                            if (confirmed != true || !mounted) {
                                              return;
                                            }
                                          } else {
                                            // Enabling login requires owner
                                            // authorization and a recovery
                                            // check.
                                            final confirmed =
                                                await _confirmLoginEnable();
                                            if (confirmed != true || !mounted) {
                                              return;
                                            }
                                          }
                                          await _saveLoginRequired(value);
                                        }
                                      : null,
                                  activeThumbColor: colorScheme.primary,
                                  activeTrackColor: colorScheme.primary
                                      .withValues(alpha: 0.5),
                                ),
                                if (_loginRequired) ...[
                                  const SizedBox(
                                    height: AppDimensions.spacingSm,
                                  ),
                                  Text(
                                    'Staff PIN login is required at startup. '
                                    'Only the owner can disable this setting.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Phase F: inactivity auto-lock timeout (owner-only).
                        if (_isOwner && _loginRequired) ...[
                          const SizedBox(height: AppDimensions.spacingLg),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppDimensions.screenPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Inactivity Auto-Lock',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingSm,
                                  ),
                                  Text(
                                    'Lock the session after minutes of inactivity.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingMd,
                                  ),
                                  DropdownButtonFormField<int>(
                                    initialValue: _inactivityTimeoutMinutes,
                                    decoration: const InputDecoration(
                                      labelText: 'Auto-lock after',
                                      prefixIcon: Icon(Icons.timer_outlined),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 0,
                                        child: Text('Disabled'),
                                      ),
                                      DropdownMenuItem(
                                        value: 5,
                                        child: Text('5 minutes'),
                                      ),
                                      DropdownMenuItem(
                                        value: 15,
                                        child: Text('15 minutes'),
                                      ),
                                      DropdownMenuItem(
                                        value: 30,
                                        child: Text('30 minutes'),
                                      ),
                                      DropdownMenuItem(
                                        value: 60,
                                        child: Text('1 hour'),
                                      ),
                                    ],
                                    onChanged: _isSavingSettings
                                        ? null
                                        : (value) async {
                                            if (value == null) return;
                                            setState(() {
                                              _inactivityTimeoutMinutes = value;
                                            });
                                            await _saveInactivityTimeout(value);
                                          },
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingSm,
                                  ),
                                  Text(
                                    'When the session locks, PIN re-entry is '
                                    'required to resume. Active POS carts are '
                                    'preserved across lock and sign-out.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingXs,
                                  ),
                                  Text(
                                    'Only the owner can change the auto-lock '
                                    'timeout.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

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
                                  child: AuroraLoader(
                                    size: 18,
                                    strokeWidth: 2,
                                    onDarkSurface: true,
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
      );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Phase G: tax / VAT section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTaxSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final moneyDeep = AppColors.moneyTint.last;

    return BrandFormSection(
      title: 'Tax / VAT',
      subtitle:
          'Set the tax rate and whether prices already include tax (tax-inclusive).',
      icon: Icons.payment_outlined,
      accent: moneyDeep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tax rate %
          Text(
            'Tax rate (%)',
            style: AppTextStyles.labelMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          TextFormField(
            controller: _taxRateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Tax rate',
              hintText: 'e.g. 15.0',
              prefixIcon: const Icon(Icons.percent_outlined),
              suffixText: '%',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                borderSide: const BorderSide(
                  color: AppColors.royalMid,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                borderSide: BorderSide(
                  color: colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // Tax inclusive toggle
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Tax inclusive',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              _taxInclusive
                  ? 'Prices already include tax — tax is shown as a breakdown.'
                  : 'Tax is added on top of the subtotal at checkout.',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            value: _taxInclusive,
            onChanged: _isSavingSettings
                ? null
                : (value) => setState(() => _taxInclusive = value),
            activeThumbColor: moneyDeep,
            activeTrackColor: moneyDeep.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _isSavingSettings ? null : _saveBusinessSettings,
              icon: _isSavingSettings
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: AuroraLoader(
                        size: 16,
                        strokeWidth: 2,
                        onDarkSurface: true,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Tax Settings'),
            ),
          ),
        ],
      ),
    );
  }

  void _jumpToSection(GlobalKey key) {
    final sectionContext = key.currentContext;

    if (sectionContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  /// Compact identity card that anchors the settings page.
  Widget _buildBusinessSummary(BuildContext context) {
    final name = _businessNameController.text.trim();

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF151133), Color(0xFF322569), Color(0xFF1D3C63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              const BrandMark(size: 46, showShadow: false),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Your business' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_currency  •  ${themeController.themeMode.name} theme',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Text(
                  'WORKSPACE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickNav(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <(String, IconData, GlobalKey)>[
      ('Appearance', Icons.palette_outlined, _appearanceKey),
      ('Business', Icons.storefront_outlined, _businessKey),
      ('Tax / VAT', Icons.payment_outlined, _taxKey),
      ('Loyalty', Icons.workspace_premium_outlined, _loyaltyKey),
      ('Receipts', Icons.receipt_long_outlined, _receiptKey),
      ('Data', Icons.storage_rounded, _dataKey),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: scheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(color: scheme.outline),
              ),
              child: InkWell(
                onTap: () => _jumpToSection(item.$3),
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(item.$2, size: 14, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        item.$1,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
    final palette = <IconData, List<Color>>{
      Icons.backup_outlined: [Color(0xFF34D399), Color(0xFF059669)],
      Icons.restore_outlined: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      Icons.inventory_2_outlined: [Color(0xFF818CF8), Color(0xFF4F46E5)],
      Icons.point_of_sale_outlined: [Color(0xFFC084FC), Color(0xFF7C3AED)],
      Icons.people_outline: [Color(0xFFF472B6), Color(0xFFDB2777)],
      Icons.receipt_long_outlined: [Color(0xFFFBBF24), Color(0xFFD97706)],
      Icons.science_outlined: [Color(0xFF22D3EE), Color(0xFF0891B2)],
      Icons.delete_sweep_outlined: [Color(0xFFFB7185), Color(0xFFE11D48)],
    };

    // Section tint pairing: data & backup = stock blue.
    const dataBlue = [AppColors.infoLight, AppColors.info];
    palette[Icons.backup_outlined] = dataBlue;
    palette[Icons.restore_outlined] = dataBlue;
    palette[Icons.inventory_2_outlined] = dataBlue;
    palette[Icons.point_of_sale_outlined] = dataBlue;
    palette[Icons.people_outline] = dataBlue;

    final destructive =
        icon == Icons.delete_sweep_outlined ||
        icon == Icons.warning_amber_outlined;

    // Danger-zone actions render as outlined-error tiles.
    if (destructive) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _DangerActionTile(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onTap: onTap,
          isLoading: isLoading,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BrandActionTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        isLoading: isLoading,
        destructive: destructive,
        gradient:
            palette[icon] ?? const [AppColors.primaryLight, AppColors.primary],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BrandPageHeader(
                eyebrow: 'Workspace',
                title: 'Settings',
                subtitle: 'Tune BizFlow to the way your shop actually runs.',
                icon: Icons.tune_rounded,
                showBack: Navigator.of(context).canPop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBusinessSummary(context),
                          const SizedBox(height: 14),
                          _buildQuickNav(context),
                          const SizedBox(height: 18),
                          KeyedSubtree(
                            key: _appearanceKey,
                            child: _buildThemeSection(context),
                          ),

          const SizedBox(height: AppDimensions.spacingXl),

                          KeyedSubtree(
                            key: _businessKey,
                            child: _buildBusinessConfigurationSection(context),
                          ),

                          const SizedBox(height: AppDimensions.spacingXl),

                          KeyedSubtree(
                            key: _taxKey,
                            child: _buildTaxSection(context),
                          ),

                          KeyedSubtree(
                            key: _loyaltyKey,
                            child: _buildLoyaltySection(context),
                          ),

                          const SizedBox(height: AppDimensions.spacingXl),

                          KeyedSubtree(
                            key: _receiptKey,
                            child: _buildReceiptSection(context),
                          ),

                          const SizedBox(height: AppDimensions.spacingXl),

                          KeyedSubtree(
                            key: _printerKey,
                            child: _buildPrinterSection(context),
                          ),

          const SizedBox(height: AppDimensions.spacingXl),

                          KeyedSubtree(
                            key: _dataKey,
                            child: const SettingsSectionTitle(
                              title: 'Backup & Restore',
                            ),
                          ),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.backup_outlined,
            title: 'Backup Data',
            subtitle: 'Save your BizFlow data as a backup file',
            isLoading: _isBackingUp,
            onTap:
                !_isOwner ||
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
                !_isOwner ||
                        _isBackingUp ||
                        _isRestoring ||
                        _isExporting ||
                        _isSavingSettings
                    ? null
                    : _restoreData,
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          const SettingsSectionTitle(title: 'Data Export'),

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

          const SettingsSectionTitle(title: 'Development'),

          const SizedBox(height: AppDimensions.spacingMd),

          _buildActionCard(
            context: context,
            icon: Icons.science_outlined,
            title: 'Load Demo Data',
            subtitle: 'Load sample data for development and testing',
            isLoading: _isLoadingDemoData,
            onTap:
                !_canManage ||
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
                !_canManage ||
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
                !_isOwner ||
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Danger-zone action row — outlined error styling only.
class _DangerActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  const _DangerActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = onTap == null && !isLoading;

    return Opacity(
      opacity: muted ? 0.55 : 1,
      child: MouseRegion(
        cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        child: Material(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: AppColors.error.withValues(
                alpha: isDark ? 0.45 : 0.35,
              ),
            ),
          ),
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(
                        alpha: (isDark ? 0.16 : 0.10),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(
                          alpha: (isDark ? 0.30 : 0.22),
                        ),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.error,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: scheme.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: AuroraLoader(size: 18, strokeWidth: 2.2),
                    )
                  else
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(
                          alpha: (isDark ? 0.16 : 0.09),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Connection status indicator — mint when connected, error when disconnected.
class _PrinterStatusRow extends StatelessWidget {
  final bool connected;
  final String? deviceName;
  final String? error;

  const _PrinterStatusRow({
    required this.connected,
    this.deviceName,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusColor = connected ? AppColors.brandMint : AppColors.error;
    final statusText = connected ? 'Connected' : 'Disconnected';
    final detail = connected
        ? (deviceName ?? 'Printer')
        : (error ?? 'No printer connected');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.45),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$statusText${connected ? ' • $detail' : ''}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                if (!connected && error != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    error!,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: scheme.onSurface.withValues(alpha: 0.55),
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
}
