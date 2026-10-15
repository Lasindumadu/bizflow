import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/supplier_repository.dart';

/// Add/edit supplier screen.
class SupplierDetailScreen extends StatefulWidget {
  final SupplierRecord? supplier;

  const SupplierDetailScreen({super.key, this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  final SupplierRepository _repository = SupplierRepository(appDatabase);
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _paymentTermsController = TextEditingController(text: '30');
  final _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      final s = widget.supplier!;
      _nameController.text = s.name;
      _contactPersonController.text = s.contactPerson;
      _phoneController.text = s.phone;
      _emailController.text = s.email;
      _addressController.text = s.address;
      _taxNumberController.text = s.taxNumber;
      _paymentTermsController.text = s.paymentTermsDays.toString();
      _notesController.text = s.notes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _taxNumberController.dispose();
    _paymentTermsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.supplier != null) {
        await _repository.updateSupplier(
          id: widget.supplier!.id,
          name: _nameController.text.trim(),
          contactPerson: _contactPersonController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          taxNumber: _taxNumberController.text.trim(),
          paymentTermsDays: int.tryParse(_paymentTermsController.text.trim()) ?? 30,
          notes: _notesController.text.trim(),
        );
      } else {
        await _repository.createSupplier(
          name: _nameController.text.trim(),
          contactPerson: _contactPersonController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          taxNumber: _taxNumberController.text.trim(),
          paymentTermsDays: int.tryParse(_paymentTermsController.text.trim()) ?? 30,
          notes: _notesController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save supplier: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Supplier' : 'Add Supplier')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            Text('Basic Information', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: (v) => _validateRequired(v, 'Supplier name'),
              decoration: const InputDecoration(
                labelText: 'Supplier Name *',
                hintText: 'e.g. Acme Wholesale',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _contactPersonController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Contact Person',
                hintText: 'e.g. John Smith',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            Text('Contact Details', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'e.g. +1 555-0123',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'e.g. orders@acme.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _addressController,
              textInputAction: TextInputAction.next,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Supplier address',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            Text('Business Details', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _taxNumberController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Tax / VAT Number',
                hintText: 'Optional tax identification',
                prefixIcon: Icon(Icons.receipt_outlined),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _paymentTermsController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final n = int.tryParse(v.trim());
                if (n == null || n < 0) return 'Enter a valid number of days';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Payment Terms (days) *',
                hintText: 'e.g. 30 for Net-30',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            Text('Notes', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Internal Notes',
                hintText: 'Any additional information about this supplier',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),

            GradientButton(
              label: _isSaving ? 'Saving…' : (widget.supplier != null ? 'Save Changes' : 'Create Supplier'),
              icon: Icons.save_rounded,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}