import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  final String name;
  final String email;
  final String initialStatus;
  final String trips;
  final String parcels;

  const AdminUserDetailsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.initialStatus,
    required this.trips,
    required this.parcels,
  });

  @override
  State<AdminUserDetailsScreen> createState() =>
      _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.userDetails)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassContainer(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 34,
                  child: Icon(Icons.person, size: 34),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(widget.email),
                const SizedBox(height: 8),
                Chip(label: Text(l.adminUserStatusLabel(_status))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Column(
              children: [
                _row(l.accountStatus, l.adminUserStatusLabel(_status)),
                _row(l.registeredDate, '18/05/2026'),
                _row(l.completedTrips, widget.trips),
                _row(l.parcels, widget.parcels),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_status == 'Active')
            OutlinedButton.icon(
              onPressed: () => setState(() => _status = 'Suspended'),
              icon: const Icon(Icons.block_outlined),
              label: Text(l.suspendUser),
            )
          else
            FilledButton.icon(
              onPressed: () => setState(() => _status = 'Active'),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l.activateUser),
            ),
          const SizedBox(height: 16),
          GlassContainer(child: Text(l.prototypeAdminNotice)),
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
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
