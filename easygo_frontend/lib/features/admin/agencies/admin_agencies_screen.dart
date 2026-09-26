import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';
import 'add_agency_screen.dart';
import 'admin_agency_details_screen.dart';

class AdminAgenciesScreen extends StatefulWidget {
  const AdminAgenciesScreen({super.key});

  @override
  State<AdminAgenciesScreen> createState() => _AdminAgenciesScreenState();
}

class _AdminAgenciesScreenState extends State<AdminAgenciesScreen> {
  final AdminService _admin = AdminService.instance;

  /// The states the platform actually stores. The console used to filter on
  /// Verified / Pending / Suspended, but an agency carries a single active
  /// flag, so there is no approval state to filter on.
  static const List<String> _filters = <String>['All', 'Active', 'Suspended'];

  String _query = '';
  String _filter = 'All';

  List<AdminAgency> _agencies = <AdminAgency>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAgencies();
  }

  Future<void> _loadAgencies() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<AdminAgency> agencies = await _admin.getAgencies();

      if (!mounted) {
        return;
      }

      setState(() {
        _agencies = agencies;
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

  Future<void> _openDetails(AdminAgency agency) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminAgencyDetailsScreen(agency: agency),
      ),
    );

    // The details screen can suspend or reactivate the agency.
    if (mounted) {
      await _loadAgencies();
    }
  }

  Future<void> _addAgency() async {
    final AdminAgency? created = await Navigator.push<AdminAgency>(
      context,
      MaterialPageRoute(builder: (context) => const AddAgencyScreen()),
    );

    if (created != null && mounted) {
      await _loadAgencies();
    }
  }

  List<AdminAgency> get _visibleAgencies {
    final String query = _query.toLowerCase();

    return _agencies.where((AdminAgency agency) {
      final bool matchesQuery =
          agency.name.toLowerCase().contains(query) ||
          agency.cityLabel.toLowerCase().contains(query);

      final bool matchesFilter =
          _filter == 'All' || agency.statusLabel == _filter;

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

    final List<AdminAgency> visible = _visibleAgencies;

    return Scaffold(
      appBar: AppBar(title: Text(l.agencyManagement)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAgency,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Add agency'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
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
                    onPressed: _loadAgencies,
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
                _agencies.isEmpty
                    ? 'No agency is registered yet.'
                    : 'No agency matches this view.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...visible.map(
              (AdminAgency agency) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        agency.isActive
                            ? Icons.business_outlined
                            : Icons.block_outlined,
                      ),
                    ),
                    title: Text(agency.name),
                    subtitle: Text(
                      '${agency.cityLabel} • ${agency.statusLabel}\n'
                      '${agency.branchCount} branches • '
                      '${agency.tripCount} trips • '
                      '${agency.vehicleCount} vehicles • '
                      '${agency.staffCount} staff',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openDetails(agency),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
