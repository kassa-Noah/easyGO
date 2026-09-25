import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  final AdminAccount account;

  const AdminUserDetailsScreen({super.key, required this.account});

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  final AdminService _admin = AdminService.instance;

  late AdminAccount _account = widget.account;

  bool _isSaving = false;

  Future<void> _setActive(bool isActive) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final AdminAccount updated = await _admin.updateUserStatus(
        userId: _account.id,
        isActive: isActive,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _account = updated;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isActive
                ? '${updated.fullName} can sign in again.'
                : '${updated.fullName} can no longer sign in.',
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

    final AdminAccount account = _account;

    return Scaffold(
      appBar: AppBar(title: Text(l.userDetails)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassContainer(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  child: Icon(
                    account.isActive
                        ? Icons.person
                        : Icons.block_outlined,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  account.fullName,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(account.email),
                const SizedBox(height: 8),
                Chip(
                  avatar: Icon(
                    account.isActive
                        ? Icons.check_circle_outline
                        : Icons.block_outlined,
                    size: 18,
                  ),
                  label: Text(account.statusLabel),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Column(
              children: [
                _row(l.accountStatus, account.statusLabel),
                _row('Role', account.role),
                _row('Phone', account.phone ?? '—'),
                _row(
                  l.registeredDate,
                  account.createdAt == null
                      ? '—'
                      : formatAdminDate(account.createdAt!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isSaving)
            const Center(child: CircularProgressIndicator())
          else if (account.isActive)
            OutlinedButton.icon(
              onPressed: () => _setActive(false),
              icon: const Icon(Icons.block_outlined),
              label: Text(l.suspendUser),
            )
          else
            FilledButton.icon(
              onPressed: () => _setActive(true),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l.activateUser),
            ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Text(
              'Suspending an account stops it from signing in. It is stored as '
              'a single active flag, which is the only account state the '
              'backend records.',
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
