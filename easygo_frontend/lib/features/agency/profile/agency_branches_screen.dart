import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../models/agency_console.dart';
import '../services/agency_console_service.dart';
import 'edit_branch_screen.dart';

/// The branches the agency operates from, and the only place they can be
/// created or amended.
///
/// A branch carries the address, the city and the coordinates that routes and
/// trips are built on, so an agency that cannot add one cannot open a new
/// route. The backend has always supported both operations; this screen is
/// what reaches them.
class AgencyBranchesScreen extends StatefulWidget {
  const AgencyBranchesScreen({super.key});

  @override
  State<AgencyBranchesScreen> createState() => _AgencyBranchesScreenState();
}

class _AgencyBranchesScreenState extends State<AgencyBranchesScreen> {
  final AgencyConsoleService _console = AgencyConsoleService.instance;

  String _agencyId = '';
  String _agencyName = '';

  List<ConsoleBranch> _branches = <ConsoleBranch>[];

  bool _isLoading = true;
  String? _errorMessage;

  /// Whether anything was created or changed, so the profile can re-read.
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Read through the API rather than trusting the list the profile passed
      // in, so a save that landed is always reflected here.
      final StaffAgencyProfile profile = await _console.getMyAgency(
        refresh: true,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _agencyId = profile.agencyId;
        _agencyName = profile.name;
        _branches = profile.branches;
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

  void _openAddBranch() {
    _openBranchEditor(null);
  }

  void _openEditBranch(ConsoleBranch branch) {
    _openBranchEditor(branch);
  }

  Future<void> _openBranchEditor(ConsoleBranch? branch) async {
    if (_agencyId.isEmpty) {
      return;
    }

    final ConsoleBranch? saved = await Navigator.push<ConsoleBranch>(
      context,
      MaterialPageRoute(
        builder: (context) => EditBranchScreen(
          agencyId: _agencyId,
          agencyName: _agencyName,
          branch: branch,
        ),
      ),
    );

    if (saved == null || !mounted) {
      return;
    }

    _changed = true;

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          Navigator.pop(context, _changed);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Branches'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        floatingActionButton: _isLoading || _errorMessage != null
            ? null
            : FloatingActionButton.extended(
                onPressed: _openAddBranch,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Add branch'),
              ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _buildError(context)
                    else ...[
                      Text(
                        _branchCountLabel(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (_branches.isEmpty)
                        _buildEmpty(context)
                      else
                        for (final ConsoleBranch branch in _branches) ...[
                          _buildBranchCard(context, branch),
                          const SizedBox(height: 12),
                        ],
                      const SizedBox(height: 6),
                      _buildExplanation(context),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _branchCountLabel() {
    return _branches.length == 1
        ? '1 branch'
        : '${_branches.length} branches';
  }

  Widget _buildBranchCard(BuildContext context, ConsoleBranch branch) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_city_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${branch.city} • ${branch.address}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (branch.phone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        branch.phone!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (!branch.isActive)
                Chip(
                  label: const Text('Inactive'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _coordinatesLabel(branch),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _openEditBranch(branch),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }

  /// The coordinates are shown as stored, and called out as absent when they
  /// are, rather than displayed as a plausible-looking 0, 0.
  String _coordinatesLabel(ConsoleBranch branch) {
    final double? latitude = branch.latitude;
    final double? longitude = branch.longitude;

    if (latitude == null || longitude == null) {
      return 'No coordinates recorded for this branch.';
    }

    return 'Coordinates ${latitude.toStringAsFixed(4)}, '
        '${longitude.toStringAsFixed(4)}';
  }

  Widget _buildEmpty(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Text(
        'This agency has no branch yet. A route runs between two branches, so '
        'nothing can be scheduled until at least one exists.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
      ),
    );
  }

  /// Says where the coordinates come from and what a branch cannot be, because
  /// the app has no map and the platform has no way to remove a branch, so
  /// neither can be discovered from the form itself.
  Widget _buildExplanation(BuildContext context) {
    return Text(
      'Routes and trips are built between branches, so a branch needs the '
      'address and coordinates of the place it operates from. The platform '
      'has no map here, so the coordinates are typed in.\n\n'
      'A branch can be renamed, moved and given a new phone number, but it '
      'cannot be removed or switched off once it exists.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        height: 1.5,
        color: AppColors.textLight,
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Unable to load the branches.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
