import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';

/// Creates a route, or amends one that already exists.
///
/// Passing no [route] switches it to creation. The branches come from the
/// caller because they are the platform's branches, not this route's, and
/// reading them again for every open would be wasteful.
class EditRouteScreen extends StatefulWidget {
  const EditRouteScreen({
    super.key,
    required this.route,
    required this.branches,
  });

  /// The route being edited, or null to create a new one.
  final AdminRoute? route;

  final List<AdminBranch> branches;

  @override
  State<EditRouteScreen> createState() => _EditRouteScreenState();
}

class _EditRouteScreenState extends State<EditRouteScreen> {
  final _formKey = GlobalKey<FormState>();

  final AdminService _admin = AdminService.instance;

  late final TextEditingController _fareController;
  late final TextEditingController _distanceController;
  late final TextEditingController _durationController;

  String? _originBranchId;
  String? _destinationBranchId;

  late bool _isActive;

  bool _isSaving = false;

  bool get _isCreating => widget.route == null;

  @override
  void initState() {
    super.initState();

    final AdminRoute? route = widget.route;

    _originBranchId = _branchExists(route?.originBranchId)
        ? route!.originBranchId
        : null;

    _destinationBranchId = _branchExists(route?.destinationBranchId)
        ? route!.destinationBranchId
        : null;

    _fareController = TextEditingController(
      text: route == null ? '' : route.baseFare.round().toString(),
    );

    _distanceController = TextEditingController(
      text: route?.distanceKm == null ? '' : _trimNumber(route!.distanceKm!),
    );

    _durationController = TextEditingController(
      text: route?.estimatedDurationMinutes?.toString() ?? '',
    );

    _isActive = route?.isActive ?? true;
  }

  @override
  void dispose() {
    _fareController.dispose();
    _distanceController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  /// A stored branch id is only offered when the branch list actually contains
  /// it, so a dropdown is never asked to show a value it does not hold.
  bool _branchExists(String? branchId) {
    if (branchId == null || branchId.isEmpty) {
      return false;
    }

    return widget.branches.any((AdminBranch b) => b.id == branchId);
  }

  static String _trimNumber(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }

  String? _requiredBranch(String? value, String message) {
    if (value == null || value.isEmpty) {
      return message;
    }

    return null;
  }

  /// A required positive number, within [min] and [max] when given.
  String? _positiveNumber(
    String? value, {
    required String label,
    required bool required,
    double max = double.infinity,
  }) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      return required ? '$label is required.' : null;
    }

    final double? parsed = double.tryParse(text.replaceAll(',', '.'));

    if (parsed == null) {
      return 'Enter $label as a number.';
    }

    if (parsed <= 0) {
      return '$label must be greater than zero.';
    }

    if (parsed > max) {
      return '$label looks too large.';
    }

    return null;
  }

  String? _wholeNumber(String? value, {required String label}) {
    final String text = (value ?? '').trim();

    if (text.isEmpty) {
      return null;
    }

    final int? parsed = int.tryParse(text);

    if (parsed == null) {
      return 'Enter $label as a whole number of minutes.';
    }

    if (parsed <= 0) {
      return '$label must be greater than zero.';
    }

    return null;
  }

  double? _parseDouble(String value) {
    final String text = value.trim();

    return text.isEmpty ? null : double.tryParse(text.replaceAll(',', '.'));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? origin = _originBranchId;
    final String? destination = _destinationBranchId;

    if (origin == null || destination == null) {
      return;
    }

    if (origin == destination) {
      // The backend refuses this too, but saying it here avoids the round trip.
      await _showResult(
        title: 'Not Saved',
        message:
            'A route cannot start and end at the same branch. Choose a '
            'different destination.',
        isError: true,
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    final double? distance = _parseDouble(_distanceController.text);

    final int? duration = _durationController.text.trim().isEmpty
        ? null
        : int.tryParse(_durationController.text.trim());

    final double fare = _parseDouble(_fareController.text) ?? 0;

    try {
      final AdminRoute saved = _isCreating
          ? await _admin.createRoute(
              originBranchId: origin,
              destinationBranchId: destination,
              baseFare: fare,
              distanceKm: distance,
              estimatedDurationMinutes: duration,
            )
          : await _admin.updateRoute(
              routeId: widget.route!.id,
              originBranchId: origin,
              destinationBranchId: destination,
              baseFare: fare,
              distanceKm: distance,
              estimatedDurationMinutes: duration,
              isActive: _isActive,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await _showResult(
        title: _isCreating ? 'Route Added' : 'Route Updated',
        message: _isCreating
            ? '${saved.label} is now available. Agencies whose branches these '
                  'are can schedule trips on it.'
            : '${saved.label} was saved.'
                  '${saved.isActive ? '' : ' It is retired, so it is no '
                      'longer offered to agencies or to travellers.'}',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreating ? 'Add Route' : 'Edit Route'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
            children: [
              Text(
                _isCreating
                    ? 'A route is a pair of branches with a fare. Trips are '
                          'scheduled against it, so it is the step between '
                          'having branches and being able to sell a journey.'
                    : 'Change what is out of date. Distance and duration may '
                          'be left blank.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              if (widget.branches.length < 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _buildPanel(
                    context,
                    child: Text(
                      widget.branches.isEmpty
                          ? 'The platform has no branches yet, so no route can '
                                'be built. Add branches to an agency first.'
                          : 'A route needs two branches and the platform only '
                                'has one, so no route can be built yet.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              _buildSection(
                context,
                title: 'Branches',
                description:
                    'The two ends of the journey. Both branches belong to an '
                    'agency, and that agency is the one able to schedule trips '
                    'on this route.',
                children: [
                  _buildBranchField(
                    value: _originBranchId,
                    label: 'Origin branch',
                    onChanged: (String? value) {
                      setState(() => _originBranchId = value);
                    },
                    validator: (String? value) =>
                        _requiredBranch(value, 'Choose an origin branch.'),
                  ),
                  _buildBranchField(
                    value: _destinationBranchId,
                    label: 'Destination branch',
                    onChanged: (String? value) {
                      setState(() => _destinationBranchId = value);
                    },
                    validator: (String? value) => _requiredBranch(
                      value,
                      'Choose a destination branch.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSection(
                context,
                title: 'Journey',
                description:
                    'The fare is what a booking costs before any door-to-door '
                    'extras. Distance and duration are optional — the platform '
                    'has no map, so they are whatever the operator records.',
                children: [
                  _buildField(
                    controller: _fareController,
                    label: 'Base fare (FCFA)',
                    hint: 'For example: 5000',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (String? value) => _positiveNumber(
                      value,
                      label: 'The base fare',
                      required: true,
                      max: 10000000,
                    ),
                  ),
                  _buildField(
                    controller: _distanceController,
                    label: 'Distance in km (optional)',
                    hint: 'For example: 250',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (String? value) => _positiveNumber(
                      value,
                      label: 'The distance',
                      required: false,
                      max: 100000,
                    ),
                  ),
                  _buildField(
                    controller: _durationController,
                    label: 'Estimated duration in minutes (optional)',
                    hint: 'For example: 240',
                    keyboardType: TextInputType.number,
                    validator: (String? value) =>
                        _wholeNumber(value, label: 'The duration'),
                  ),
                ],
              ),
              if (!_isCreating) ...[
                const SizedBox(height: 18),
                _buildSection(
                  context,
                  title: 'Availability',
                  description:
                      'A retired route stays in the platform but is no longer '
                      'offered to agencies or travellers.',
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Route is offered'),
                      subtitle: Text(
                        _isActive
                            ? 'Agencies can schedule trips on it.'
                            : 'Retired. No new trips can use it.',
                      ),
                      value: _isActive,
                      onChanged: _isSaving
                          ? null
                          : (bool value) {
                              setState(() => _isActive = value);
                            },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving || widget.branches.length < 2
                      ? null
                      : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : _isCreating
                        ? 'Add route'
                        : 'Save changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchField({
    required String? value,
    required String label,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    // The stored value is dropped when the branch list does not contain it, so
    // DropdownButtonFormField is never handed a value outside its items.
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: widget.branches
          .map(
            (AdminBranch branch) => DropdownMenuItem<String>(
              value: branch.id,
              child: Text(branch.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: _isSaving ? null : onChanged,
      validator: validator,
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    String? description,
  }) {
    return _buildPanel(
      context,
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

  Widget _buildPanel(BuildContext context, {required Widget child}) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: child,
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
