import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/customer_repository.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  final CustomerRepository _customerRepository = CustomerRepository(
    appDatabase,
  );

  bool _isSaving = false;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();

    final customer = widget.customer;

    if (customer != null) {
      _nameController.text = customer.name;
      _phoneController.text = customer.phone;
      _emailController.text = customer.email;
      _addressController.text = customer.address;
    }

    // Keeps the live profile preview in sync while typing.
    _nameController.addListener(_refreshPreview);
    _phoneController.addListener(_refreshPreview);
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_refreshPreview);
    _phoneController.removeListener(_refreshPreview);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await _customerRepository.updateCustomer(
          id: widget.customer!.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
        );
      } else {
        final customerId = DateTime.now().microsecondsSinceEpoch.toString();

        await _customerRepository.addCustomer(
          id: customerId,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Customer updated successfully.'
                : 'Customer added successfully.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Unable to update customer: $error'
                : 'Unable to add customer: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return null;
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String get _initials {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      return '?';
    }

    final parts = name.split(RegExp(r'\s+'));
    final first = parts.first.substring(0, 1);
    final second = parts.length > 1 ? parts.last.substring(0, 1) : '';

    return '$first$second'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim();

    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BrandPageHeader(
                eyebrow: 'Customer directory',
                title: _isEditing ? 'Edit customer' : 'New customer',
                subtitle: _isEditing
                    ? 'Keep contact details and balances up to date.'
                    : 'Add a contact to track purchases and credit.',
                icon: Icons.people_alt_rounded,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfilePreview(
                              initials: _initials,
                              name: name.isEmpty ? 'New customer' : name,
                              phone: _phoneController.text.trim(),
                              isEditing: _isEditing,
                            ),
                            const SizedBox(height: 16),
                            BrandFormSection(
                              title: 'Identity',
                              subtitle: 'How this customer appears in BizFlow.',
                              icon: Icons.badge_outlined,
                              accent: AppColors.primary,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Full name',
                                      hintText: 'e.g. Amara Okafor',
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Customer name is required.';
                                      }

                                      if (value.trim().length < 2) {
                                        return 'Name must contain at least 2 characters.';
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingMd,
                                  ),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone',
                                      hintText: '+1 555 0100',
                                      prefixIcon: Icon(Icons.phone_outlined),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            BrandFormSection(
                              title: 'Contact preferences',
                              subtitle:
                                  'Optional details for receipts and follow-ups.',
                              icon: Icons.alternate_email_rounded,
                              accent: AppColors.cyan,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: _validateEmail,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'name@example.com',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingMd,
                                  ),
                                  TextFormField(
                                    controller: _addressController,
                                    textInputAction: TextInputAction.done,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Address',
                                      hintText: 'Street, city, country',
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                      ),
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            BrandCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  const BrandIconBadge(
                                    icon: Icons.loyalty_outlined,
                                    color: AppColors.brandAmber,
                                    size: 34,
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Text(
                                      'Loyalty points and store credit are managed from the customer card after saving.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        height: 1.45,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              BrandStickyBar(
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveCustomer,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 19),
                  label: Text(
                    _isSaving
                        ? 'Saving…'
                        : _isEditing
                        ? 'Save changes'
                        : 'Add customer',
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

/// Gradient avatar + name preview that updates as the form is filled.
class _ProfilePreview extends StatelessWidget {
  final String initials;
  final String name;
  final String phone;
  final bool isEditing;

  const _ProfilePreview({
    required this.initials,
    required this.name,
    required this.phone,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppDecor.heroGradient(
          Theme.of(context).brightness == Brightness.dark,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppDecor.glow(AppColors.primary, alpha: 0.22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: AppTextStyles.displayFont,
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  phone.isEmpty ? 'No phone number yet' : phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              isEditing ? 'EDITING' : 'NEW',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
