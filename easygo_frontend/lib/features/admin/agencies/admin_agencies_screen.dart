import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';
import 'admin_agency_details_screen.dart';

class AdminAgenciesScreen extends StatefulWidget {
  const AdminAgenciesScreen({super.key});

  @override
  State<AdminAgenciesScreen> createState() => _AdminAgenciesScreenState();
}

class _AdminAgenciesScreenState extends State<AdminAgenciesScreen> {
  String _query = '';
  String _filter = 'All';

  final List<Map<String, String>> _agencies = const [
    {
      'name': 'General Express',
      'city': 'Yaoundé',
      'status': 'Verified',
      'trips': '68',
      'bookings': '426',
    },
    {
      'name': 'Central Voyage',
      'city': 'Douala',
      'status': 'Pending',
      'trips': '0',
      'bookings': '0',
    },
    {
      'name': 'Global Travel',
      'city': 'Bafoussam',
      'status': 'Verified',
      'trips': '41',
      'bookings': '271',
    },
    {
      'name': 'City Transport',
      'city': 'Buea',
      'status': 'Suspended',
      'trips': '22',
      'bookings': '119',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final visible = _agencies.where((agency) {
      final q = _query.toLowerCase();
      final matchesQuery =
          agency['name']!.toLowerCase().contains(q) ||
          agency['city']!.toLowerCase().contains(q);
      final matchesFilter = _filter == 'All' || agency['status'] == _filter;
      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.agencyManagement)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: l.searchAgencies,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: ['All', 'Verified', 'Pending', 'Suspended'].map((status) {
              return ChoiceChip(
                label: Text(
                  status == 'All'
                      ? l.allAdmin
                      : l.adminAgencyStatusLabel(status),
                ),
                selected: _filter == status,
                onSelected: (_) => setState(() => _filter = status),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          ...visible.map(
            (agency) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.business_outlined),
                  ),
                  title: Text(agency['name']!),
                  subtitle: Text(
                    '${agency['city']} • '
                    '${l.adminAgencyStatusLabel(agency['status']!)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminAgencyDetailsScreen(
                          name: agency['name']!,
                          city: agency['city']!,
                          initialStatus: agency['status']!,
                          trips: agency['trips']!,
                          bookings: agency['bookings']!,
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
