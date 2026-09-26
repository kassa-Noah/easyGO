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

  List<AdminStaffMember> _staff = <AdminStaffMember>[];

  bool _isSaving = false;
  bool _isLoadingStaff = true;
  String? _staffError;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  /// Reads the agency's staff, which is who can actually operate its console.
  ///
  /// Kept separate from the agency record so a failure here leaves the rest of
  /// the page readable.
  Future<void> _loadStaff() async {
    if (mounted) {
      setState(() {
        _isLoadingStaff = true;
        _staffError = null;
      });
    }

    try {
      final List<AdminStaffMember> staff = await _admin.getAgencyStaff(
        _agency.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _staff = staff;
        _isLoadingStaff = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _staffError = error.message;
        _isLoadingStaff = false;
      });
    }
  }

  /// Accounts that can be attached: a customer who is not staff anywhere.
  ///
  /// Attaching sets the platform role to AGENCY_STAFF, so anyone who is
  /// already agency staff is already attached somewhere and is left out, as
  /// are administrators, whom the backend refuses to demote.
  Future<void> _addStaff() async {
    List<AdminAccount> accounts;

    try {
      accounts = await _admin.getUsers();
    } on ApiException catch (error) {
      if (mounted) {
        await _showError(error.message);
      }
      return;
    }

    final List<AdminAccount> candidates = accounts
        .where(
          (AdminAccount account) =>
              account.role == 'CUSTOMER' && account.isActive,
        )
        .toList();

    if (!mounted) {
      return;
    }

    if (candidates.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.info_outline),
          title: const Text('No account to attach'),
          content: const Text(
            'Every active customer account is already staff of an agency, or '
            'there is no active customer account. A person registers their own '
            'account, and an administrator attaches it afterwards.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return;
    }

    final AdminAccount? chosen = await showDialog<AdminAccount>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Attach an account'),
        children: [
          for (final AdminAccount account in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, account),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(account.fullName.isEmpty
                    ? account.email
                    : account.fullName),
                subtitle: Text(account.email),
              ),
            ),
        ],
      ),
    );

    if (chosen == null || !mounted) {
      return;
    }

    await _attach(chosen);
  }

  Future<void> _attach(AdminAccount account) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _admin.attachStaff(
        agencyId: _agency.id,
        userId: account.id,
        role: 'AGENT',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await _loadStaff();

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          title: const Text('Account attached'),
          content: Text(
            '${account.fullName.isEmpty ? account.email : account.fullName} '
            'can now operate the ${_agency.name} console as an agent.\n\n'
            'They must sign in again first: the role changes in the platform, '
            'and the session they already hold keeps the old one.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
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

  Future<void> _detach(AdminStaffMember member) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.person_remove_outlined),
        title: const Text('Remove from this agency?'),
        content: Text(
          '${member.name.isEmpty ? member.email : member.name} will lose '
          'access to the ${_agency.name} console and their account returns to '
          'being a customer. Their account is not deleted, and they can be '
          'attached to an agency again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _admin.detachStaff(
        agencyId: _agency.id,
        userId: member.userId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await _loadStaff();
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
          _buildStaffSection(context),
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

  /// Who can operate this agency's console.
  ///
  /// Worth its own section because the platform has no other way to say it:
  /// an account is attached to an agency one at a time, and until it is, the
  /// agency has nobody who can sign in to manage it.
  Widget _buildStaffSection(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staff',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'These accounts can sign in to this agency\'s console. The '
            'platform has no way to invite someone: a person registers their '
            'own account, and it is attached here afterwards.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 14),
          if (_isLoadingStaff)
            const Center(child: CircularProgressIndicator())
          else if (_staffError != null) ...[
            Text(
              _staffError!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadStaff,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ] else if (_staff.isEmpty) ...[
            Text(
              'No account is attached, so nobody can manage this agency yet.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
          ] else
            for (final AdminStaffMember member in _staff)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.badge_outlined),
                title: Text(
                  member.name.isEmpty ? member.email : member.name,
                ),
                subtitle: Text(
                  '${member.role} • ${member.email}'
                  '${member.isActive ? '' : ' • account suspended'}',
                ),
                trailing: TextButton(
                  onPressed: _isSaving ? null : () => _detach(member),
                  child: const Text('Remove'),
                ),
              ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _addStaff,
            icon: const Icon(Icons.person_add_alt_outlined),
            label: const Text('Attach an account'),
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
