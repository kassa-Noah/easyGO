import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../models/agency_console.dart';
import '../services/agency_console_service.dart';

/// Creates a branch, or amends one that already exists.
///
/// Passing no [branch] switches it to creation. The backend insists on
/// coordinates for a new branch, and the platform has no map to pick them
/// from, so here they are plain fields with the range they must fall in.
class EditBranchScreen extends StatefulWidget {
  const EditBranchScreen({
    super.key,
    required this.agencyId,
    required this.agencyName,
    this.branch,
  });

  final String agencyId;
  final String agencyName;

  /// The branch being edited, or null to create a new one.
  final ConsoleBranch? branch;

  @override
  State<EditBranchScreen> createState() => _EditBranchScreenState();
}

class _EditBranchScreenState extends State<EditBranchScreen> {
  final _formKey = GlobalKey<FormState>();

  final AgencyConsoleService _console = AgencyConsoleService.instance;

  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;

  bool get _isCreating => widget.branch == null;

  @override
  void initState() {
    super.initState();

    final ConsoleBranch? branch = widget.branch;

    _nameController = TextEditingController(text: branch?.name ?? '');

    _cityController = TextEditingController(text: branch?.city ?? '');

    _addressController = TextEditingController(text: branch?.address ?? '');

    // An existing branch usually has coordinates on the server. They are shown
    // so an edit does not silently drop them, and blank means "leave as is".
    _latitudeController = TextEditingController(
      text: _formatCoordinate(branch?.latitude),
    );

    _longitudeController = TextEditingController(
      text: _formatCoordinate(branch?.longitude),
    );

    _phoneController = TextEditingController(text: branch?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  static String _formatCoordinate(double? value) {
    if (value == null) {
      return '';
    }

    // Trailing zeros would suggest more precision than the record holds.
    return value.toString();
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  /// A required number inside [min] and [max].
  String? _coordinateValidator(
    String? value, {
    required String label,
    required double min,
    required double max,
  }) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      // Only a new branch must carry coordinates; the schema leaves them
      // optional on an update.
      return _isCreating ? '$label is required.' : null;
    }

    final double? parsed = double.tryParse(text.replaceAll(',', '.'));

    if (parsed == null) {
      return 'Enter $label as a number, for example ${min.toStringAsFixed(2)}.';
    }

    if (parsed < min || parsed > max) {
      return '$label must be between ${min.toStringAsFixed(0)} and '
          '${max.toStringAsFixed(0)}.';
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

    final String phone = _phoneController.text.trim();

    try {
      final ConsoleBranch saved = _isCreating
          ? await _console.createBranch(
              agencyId: widget.agencyId,
              name: _nameController.text.trim(),
              city: _cityController.text.trim(),
              address: _addressController.text.trim(),
              latitude: _parse(_latitudeController.text)!,
              longitude: _parse(_longitudeController.text)!,
              phone: phone.isEmpty ? null : phone,
            )
          : await _console.updateBranch(
              agencyId: widget.agencyId,
              branchId: widget.branch!.id,
              name: _nameController.text.trim(),
              city: _cityController.text.trim(),
              address: _addressController.text.trim(),
              latitude: _parse(_latitudeController.text),
              longitude: _parse(_longitudeController.text),
              phone: phone.isEmpty ? null : phone,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await _showResult(
        title: _isCreating ? 'Branch Added' : 'Branch Updated',
        message: _isCreating
            ? '${saved.name} is now a branch of ${widget.agencyName}. Routes '
                  'for ${saved.city} can be scheduled against it.'
            : 'The details for ${saved.name} were saved.',
        isError: false,
      );

      if (mounted) {
        Navigator.pop(context, saved);
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await _showResult(
        title: 'Not Saved',
        message: error.message,
        isError: true,
      );
    }
  }

  double? _parse(String value) {
    final String text = value.trim();

    return text.isEmpty ? null : double.tryParse(text.replaceAll(',', '.'));
  }

  Future<void> _showResult({
    required String title,
    required String message,
    required bool isError,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: isError ? AppColors.error : AppColors.success,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreating ? 'Add Branch' : 'Edit Branch'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.agencyName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isCreating
                          ? 'A branch is a place the agency operates from. '
                                'Routes run between two of them.'
                          : 'Change what is out of date. Leave a coordinate '
                                'blank to keep the value already stored.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSection(
                      context,
                      title: 'Branch',
                      children: [
                        _buildField(
                          controller: _nameController,
                          label: 'Branch name',
                          hint: 'For example: Douala Main Branch',
                          validator: (value) => _requiredValidator(
                            value,
                            'A branch name is required.',
                          ),
                        ),
                        _buildField(
                          controller: _cityController,
                          label: 'City',
                          hint: 'For example: Douala',
                          validator: (value) => _requiredValidator(
                            value,
                            'A city is required.',
                          ),
                        ),
                        _buildField(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'For example: Akwa, Douala',
                          validator: (value) => _requiredValidator(
                            value,
                            'An address is required.',
                          ),
                        ),
                        _buildField(
                          controller: _phoneController,
                          label: 'Phone (optional)',
                          hint: 'For example: 690111224',
                          keyboardType: TextInputType.phone,
                          validator: _phoneValidator,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSection(
                      context,
                      title: 'Coordinates',
                      description:
                          'The platform places the branch on the map from '
                          'these. There is no map to choose from, so they are '
                          'typed in. Latitude runs from -90 to 90 and '
                          'longitude from -180 to 180.',
                      children: [
                        _buildField(
                          controller: _latitudeController,
                          label: _isCreating
                              ? 'Latitude'
                              : 'Latitude (blank keeps the stored value)',
                          hint: 'For example: 4.0511',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: (value) => _coordinateValidator(
                            value,
                            label: 'Latitude',
                            min: -90,
                            max: 90,
                          ),
                        ),
                        _buildField(
                          controller: _longitudeController,
                          label: _isCreating
                              ? 'Longitude'
                              : 'Longitude (blank keeps the stored value)',
                          hint: 'For example: 9.7679',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: (value) => _coordinateValidator(
                            value,
                            label: 'Longitude',
                            min: -180,
                            max: 180,
                          ),
                        ),
                      ],
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving
                              ? 'Saving...'
                              : _isCreating
                              ? 'Add branch'
                              : l10n.saveChanges,
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
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    String? description,
  }) {
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
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: AppColors.textLight,
              ),
            ),
          ],
          const SizedBox(height: 14),
          for (int index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: 14),
            children[index],
          ],
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !_isSaving,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
