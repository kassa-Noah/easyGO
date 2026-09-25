import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';
import 'admin_user_details_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _admin = AdminService.instance;

  static const List<String> _filters = <String>['All', 'Active', 'Suspended'];

  String _query = '';
  String _filter = 'All';

  List<AdminAccount> _users = <AdminAccount>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<AdminAccount> users = await _admin.getUsers();

      if (!mounted) {
        return;
      }

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _openDetails(AdminAccount account) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminUserDetailsScreen(account: account),
      ),
    );

    // The details screen can suspend or reactivate the account.
    if (mounted) {
      await _loadUsers();
    }
  }

  List<AdminAccount> get _visibleUsers {
    final String query = _query.toLowerCase();

    return _users.where((AdminAccount account) {
      final bool matchesQuery =
          account.fullName.toLowerCase().contains(query) ||
          account.email.toLowerCase().contains(query);

      final bool matchesFilter =
          _filter == 'All' || account.statusLabel == _filter;

      return matchesQuery && matchesFilter;
    }).toList();
  }

  Widget _buildMessage(BuildContext context, Widget child) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final List<AdminAccount> visible = _visibleUsers;

    return Scaffold(
      appBar: AppBar(title: Text(l.userManagement)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: l.searchUsers,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: _filters.map((String status) {
              return ChoiceChip(
                label: Text(status == 'All' ? l.allAdmin : status),
                selected: _filter == status,
                onSelected: (_) => setState(() => _filter = status),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            _buildMessage(
              context,
              Column(
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    color: AppColors.error,
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    onPressed: _loadUsers,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            )
          else if (visible.isEmpty)
            _buildMessage(
              context,
              Text(
                _users.isEmpty
                    ? 'No account is registered yet.'
                    : 'No account matches this view.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...visible.map(
              (AdminAccount account) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        account.isActive
                            ? Icons.person_outline
                            : Icons.block_outlined,
                      ),
                    ),
                    title: Text(account.fullName),
                    subtitle: Text(
                      '${account.email} • ${account.role} • '
                      '${account.statusLabel}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openDetails(account),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
