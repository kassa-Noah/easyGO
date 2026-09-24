import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';

class EditAgencyProfileScreen extends StatefulWidget {
  const EditAgencyProfileScreen({super.key, required this.agency});

  final Map<String, dynamic> agency;

  @override
  State<EditAgencyProfileScreen> createState() =>
      _EditAgencyProfileScreenState();
}

class _EditAgencyProfileScreenState extends State<EditAgencyProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _headOfficeController;
  late final TextEditingController _addressController;
  late final TextEditingController _openingHoursController;

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

    _headOfficeController = TextEditingController(
      text: widget.agency['headOffice'] as String,
    );

    _addressController = TextEditingController(
      text: widget.agency['address'] as String,
    );

    _openingHoursController = TextEditingController(
      text: widget.agency['openingHours'] as String,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _headOfficeController.dispose();
    _addressController.dispose();
    _openingHoursController.dispose();

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
    final localizations = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    final updatedAgency = Map<String, dynamic>.from(widget.agency);

    updatedAgency.addAll({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'description': _descriptionController.text.trim(),
      'headOffice': _headOfficeController.text.trim(),
      'address': _addressController.text.trim(),
      'openingHours': _openingHoursController.text.trim(),
    });

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 38,
          ),
          title: Text(localizations.profileValidated),
          content: Text(localizations.profilePrototypeNotice),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(localizations.continueLabel),
            ),
          ],
        );
      },
    );

    if (!mounted || confirm != true) {
      return;
    }

    Navigator.pop(context, updatedAgency);
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
        const SizedBox(height: 15),
        TextFormField(
          controller: _openingHoursController,
          validator: (value) =>
              _requiredValidator(value, localizations.requiredField),
          decoration: InputDecoration(
            labelText: localizations.openingHours,
            prefixIcon: const Icon(Icons.schedule_outlined),
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

  Widget _buildLocationInformation(AppLocalizations localizations) {
    return _FormSection(
      title: localizations.locationInformation,
      children: [
        TextFormField(
          controller: _headOfficeController,
          textCapitalization: TextCapitalization.words,
          validator: (value) =>
              _requiredValidator(value, localizations.requiredField),
          decoration: InputDecoration(
            labelText: localizations.headOffice,
            prefixIcon: const Icon(Icons.location_city_outlined),
          ),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _addressController,
          textCapitalization: TextCapitalization.words,
          validator: (value) =>
              _requiredValidator(value, localizations.requiredField),
          decoration: InputDecoration(
            labelText: localizations.agencyAddress,
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
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
