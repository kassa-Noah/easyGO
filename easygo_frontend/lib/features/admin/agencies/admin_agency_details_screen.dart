import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';

class AdminAgencyDetailsScreen extends StatefulWidget {
  final String name;
  final String city;
  final String initialStatus;
  final String trips;
  final String bookings;

  const AdminAgencyDetailsScreen({
    super.key,
    required this.name,
    required this.city,
    required this.initialStatus,
    required this.trips,
    required this.bookings,
  });

  @override
  State<AdminAgencyDetailsScreen> createState() =>
      _AdminAgencyDetailsScreenState();
}

class _AdminAgencyDetailsScreenState
    extends State<AdminAgencyDetailsScreen> {
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
      appBar: AppBar(title: Text(l.agencyDetails)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassContainer(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 34,
                  child: Icon(Icons.business, size: 34),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(widget.city),
                const SizedBox(height: 8),
                Chip(label: Text(l.adminAgencyStatusLabel(_status))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Column(
              children: [
                _row(l.totalTrips, widget.trips),
                _row(l.totalBookings, widget.bookings),
                _row(l.verificationStatus, l.adminAgencyStatusLabel(_status)),
                _row(l.registeredOn, '12/06/2026'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_status == 'Pending')
            FilledButton.icon(
              onPressed: () => setState(() => _status = 'Verified'),
              icon: const Icon(Icons.verified_outlined),
              label: Text(l.verifyAgency),
            ),
          if (_status == 'Verified')
            OutlinedButton.icon(
              onPressed: () => setState(() => _status = 'Suspended'),
              icon: const Icon(Icons.block_outlined),
              label: Text(l.suspendAgency),
            ),
          if (_status == 'Suspended')
            FilledButton.icon(
              onPressed: () => setState(() => _status = 'Verified'),
              icon: const Icon(Icons.refresh),
              label: Text(l.reactivateAgency),
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
