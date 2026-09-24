import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  bool _readAll = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminNotifications),
        actions: [
          TextButton(
            onPressed: () => setState(() => _readAll = true),
            child: Text(l.markAllAsRead),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _notification(
            l.newAgencyRegistered,
            'Central Voyage',
            Icons.business_outlined,
          ),
          _notification(
            l.agencyVerificationCompleted,
            'General Express',
            Icons.verified_outlined,
          ),
          _notification(
            l.newUserRegistered,
            'USR-DEMO-1248',
            Icons.person_add_alt_1_outlined,
          ),
        ],
      ),
    );
  }

  Widget _notification(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: _readAll ? FontWeight.w500 : FontWeight.w800,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: _readAll ? null : const Badge(),
        ),
      ),
    );
  }
}
