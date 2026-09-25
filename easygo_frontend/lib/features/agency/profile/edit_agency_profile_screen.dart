import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../services/agency_console_service.dart';

class EditAgencyProfileScreen extends StatefulWidget {
  const EditAgencyProfileScreen({super.key, required this.agency});

  final Map<String, dynamic> agency;

  @override
  State<EditAgencyProfileScreen> createState() =>
      _EditAgencyProfileScreenState();
}

class _EditAgencyProfileScreenState extends State<EditAgencyProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final AgencyConsoleService _console = AgencyConsoleService.instance;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _descriptionController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.agency['name'] as String,
    );

    _emailController = TextEditingController(
      text: widget.agency['email'] as String,
    );

    _phoneController = TextEditingController(
      text: widget.agency['phone'] as String,
    );

    _descriptionController = TextEditingController(
      text: widget.agency['description'] as String,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _emailValidator(String? value, AppLocalizations localizations) {
    if (value == null || value.trim().isEmpty) {
      return localizations.requiredField;
    }

    final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(value.trim())) {
      return localizations.invalidEmailAddress;
    }

    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _console.updateAgency(
        agencyId: widget.agency['agencyId'] as String? ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await _showResult(
        title: 'Agency Information Saved',
        message:
            'The agency name, description, email address and phone number '
            'were saved.',
        isError: false,
      );

      if (mounted) {
        // The profile screen re-reads the record from the API.
        Navigator.pop(context, true);
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await _showResult(
        title: 'Save Failed',
        message: error.message,
        isError: true,
      );
    }
  }

  Future<void> _showResult({
    required String title,
    required String message,
    required bool isError,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppColors.error : AppColors.success,
            size: 38,
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(AppLocalizations.of(context).continueLabel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.editAgencyProfile)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF09111F),
                    Color(0xFF0D1B2A),
                    Color(0xFF10253B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF2F8FF),
                    Color(0xFFF7FBFF),
                    Color(0xFFF1FFF6),
                  ],
                ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, localizations),
                      const SizedBox(height: 18),
                      _buildGeneralInformation(localizations),
                      const SizedBox(height: 18),
                      _buildContactInformation(localizations),
                      const SizedBox(height: 18),
                      _buildLocationInformation(localizations),
                      const SizedBox(height: 18),
                      _buildPrototypeNotice(context, localizations),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isSaving ? null : _saveProfile,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _isSaving
                                ? localizations.savingChanges
                                : localizations.saveChanges,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.business_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.updateAgencyInformation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizations.updateAgencyInformationDescription,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInformation(AppLocalizations localizations) {
    return _FormSection(
      title: localizations.generalInformation,
      children: [
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          validator: (value) =>
              _requiredValidator(value, localizations.requiredField),
          decoration: InputDecoration(
            labelText: localizations.agencyName,
            prefixIcon: const Icon(Icons.business_outlined),
          ),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _descriptionController,
          minLines: 3,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) =>
              _requiredValidator(value, localizations.requiredField),
          decoration: InputDecoration(
            labelText: localizations.agencyDescription,
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInformation(AppLocalizations localizations) {
    return _FormSection(
      title: localizations.contactInformation,
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => _emailValidator(value, localizations),
          decoration: InputDecoration(
            labelText: localizations.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) =>
              _requiredValidator(value, localizations.requiredField),
          decoration: InputDecoration(
            labelText: localizations.phoneNumber,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
      ],
    );
  }

  /// Addresses belong to each branch, so they are not edited on the agency.
  Widget _buildLocationInformation(AppLocalizations localizations) {
    return _FormSection(
      title: localizations.locationInformation,
      children: [
        Text(
          'The agency record has no address of its own: each address is stored '
          'on a branch, and the profile screen lists them.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
        ),
      ],
    );
  }

  Widget _buildPrototypeNotice(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline, color: AppColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.agencyProfileBackendNotice,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
