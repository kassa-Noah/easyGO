import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';

/// Registers a new agency.
///
/// The form is deliberately short, because the record is all it can create.
/// The rest of an agency is assembled elsewhere: an account has to be
/// registered by the person and attached from the agency's page before anyone
/// can sign in, and branches and routes come after that.
class AddAgencyScreen extends StatefulWidget {
  const AddAgencyScreen({super.key});

  @override
  State<AddAgencyScreen> createState() => _AddAgencyScreenState();
}

class _AddAgencyScreenState extends State<AddAgencyScreen> {
  final _formKey = GlobalKey<FormState>();

  final AdminService _admin = AdminService.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'An agency name is required.';
    }

    if (value.trim().length < 2) {
      return 'An agency name needs at least 2 characters.';
    }

    return null;
  }

  String? _emailValidator(String? value, AppLocalizations l10n) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      return null;
    }

    final RegExp pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!pattern.hasMatch(text)) {
      return l10n.invalidEmailAddress;
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      return null;
    }

    if (text.length < 8) {
      return 'A phone number needs at least 8 characters.';
    }

    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final String description = _descriptionController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();

    try {
      final AdminAgency created = await _admin.createAgency(
        name: _nameController.text.trim(),
        description: description.isEmpty ? null : description,
        email: email.isEmpty ? null : email,
        phone: phone.isEmpty ? null : phone,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          title: const Text('Agency registered'),
          content: Text(
            '${created.name} now exists on the platform. It has no branches, '
            'no routes and nobody who can sign in to manage it yet.\n\n'
            'Open the agency from the list to attach an account, then add a '
            'branch and a route before any journey can be sold.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.pop(context, created);
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
          ),
          title: const Text('Not registered'),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Agency')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
            children: [
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                borderRadius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What this creates',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The agency record and nothing else. An agency becomes '
                      'usable in steps: an account is attached to it so '
                      'somebody can sign in, that person adds a branch, and an '
                      'administrator adds a route between branches. Only then '
                      'can a trip be scheduled.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                borderRadius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agency',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isSaving,
                      validator: _nameValidator,
                      decoration: const InputDecoration(
                        labelText: 'Agency name',
                        hintText: 'For example: Finexs Voyages',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !_isSaving,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'What the agency offers',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                borderRadius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact (optional)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'These are the agency\'s own contact details, shown to '
                      'travellers on its page. They are not the account the '
                      'agency signs in with.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isSaving,
                      keyboardType: TextInputType.emailAddress,
                      validator: (String? value) =>
                          _emailValidator(value, l10n),
                      decoration: const InputDecoration(
                        labelText: 'Email (optional)',
                        hintText: 'For example: contact@finexs.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_isSaving,
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                      decoration: const InputDecoration(
                        labelText: 'Phone (optional)',
                        hintText: 'For example: 690111222',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_business_outlined),
                  label: Text(
                    _isSaving ? 'Registering...' : 'Register agency',
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
