import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';

class AdminAgencyDetailsScreen extends StatefulWidget {
  final AdminAgency agency;

  const AdminAgencyDetailsScreen({super.key, required this.agency});

  @override
  State<AdminAgencyDetailsScreen> createState() =>
      _AdminAgencyDetailsScreenState();
}

class _AdminAgencyDetailsScreenState extends State<AdminAgencyDetailsScreen> {
  final AdminService _admin = AdminService.instance;

  late AdminAgency _agency = widget.agency;

  bool _isSaving = false;

  Future<void> _setActive(bool isActive) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final AdminAgency updated = await _admin.updateAgencyStatus(
        agencyId: _agency.id,
        isActive: isActive,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _agency = updated;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isActive
                ? '${updated.name} is active again.'
                : '${updated.name} is now suspended and hidden from the '
                      'customer directory.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await _showError(error.message);
    }
  }

  Future<void> _showError(String message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 38,
          ),
          title: const Text('Update Failed'),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final AdminAgency agency = _agency;

    return Scaffold(
      appBar: AppBar(title: Text(l.agencyDetails)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassContainer(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  child: Icon(
                    agency.isActive ? Icons.business : Icons.block_outlined,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  agency.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(agency.cityLabel),
                const SizedBox(height: 8),
                Chip(
                  avatar: Icon(
                    agency.isActive
                        ? Icons.check_circle_outline
                        : Icons.block_outlined,
                    size: 18,
                  ),
                  label: Text(agency.statusLabel),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Column(
              children: [
                _row('Branches', '${agency.branchCount}'),
                _row('Trips', '${agency.tripCount}'),
                _row('Vehicles', '${agency.vehicleCount}'),
                _row('Staff', '${agency.staffCount}'),
                _row('Agency status', agency.statusLabel),
                _row('Email', agency.email ?? '—'),
                _row('Phone', agency.phone ?? '—'),
                _row(
                  l.registeredOn,
                  agency.createdAt == null
                      ? '—'
                      : formatAdminDate(agency.createdAt!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isSaving)
            const Center(child: CircularProgressIndicator())
          else if (agency.isActive)
            OutlinedButton.icon(
              onPressed: () => _setActive(false),
              icon: const Icon(Icons.block_outlined),
              label: Text(l.suspendAgency),
            )
          else
            FilledButton.icon(
              onPressed: () => _setActive(true),
              icon: const Icon(Icons.refresh),
              label: Text(l.reactivateAgency),
            ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Text(
              'An agency carries a single active flag, so it is either active '
              'or suspended. There is no separate verification state the '
              'backend can record, and no approval step to complete.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
