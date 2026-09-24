import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';
import 'admin_user_details_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _query = '';

  final List<Map<String, String>> _users = const [
    {'name': 'Marie N.', 'email': 'marie@example.com', 'status': 'Active', 'trips': '8', 'parcels': '3'},
    {'name': 'Paul T.', 'email': 'paul@example.com', 'status': 'Active', 'trips': '5', 'parcels': '1'},
    {'name': 'Kevin A.', 'email': 'kevin@example.com', 'status': 'Suspended', 'trips': '2', 'parcels': '0'},
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final q = _query.toLowerCase();

    final visible = _users.where((user) {
      return user['name']!.toLowerCase().contains(q) ||
          user['email']!.toLowerCase().contains(q);
    }).toList();

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
          const SizedBox(height: 18),
          ...visible.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(user['name']!),
                  subtitle: Text(
                    '${user['email']} • '
                    '${l.adminUserStatusLabel(user['status']!)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminUserDetailsScreen(
                          name: user['name']!,
                          email: user['email']!,
                          initialStatus: user['status']!,
                          trips: user['trips']!,
                          parcels: user['parcels']!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
