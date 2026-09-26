import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/admin_console.dart';
import '../services/admin_service.dart';
import 'edit_route_screen.dart';

/// The routes the platform sells.
///
/// A route joins two branches and carries the fare, and a trip can only be
/// scheduled against an existing route. Nothing in the app could create one
/// before this screen: `POST /routes` is admin-only and the console had no
/// caller for it, so a new agency had no way to reach a sellable service.
///
/// The list comes from `GET /admin/routes` rather than the public `/routes`,
/// which hides retired routes. Reading the public list would mean that
/// retiring a route removes it from the only place it could be reinstated.
class AdminRoutesScreen extends StatefulWidget {
  const AdminRoutesScreen({super.key});

  @override
  State<AdminRoutesScreen> createState() => _AdminRoutesScreenState();
}

class _AdminRoutesScreenState extends State<AdminRoutesScreen> {
  final AdminService _admin = AdminService.instance;

  List<AdminRoute> _routes = <AdminRoute>[];
  List<AdminBranch> _branches = <AdminBranch>[];

  bool _isLoading = true;
  String? _errorMessage;

  /// True when the branches could not be read, which only matters for editing.
  bool _branchesFailed = false;

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
        _branchesFailed = false;
      });
    }

    try {
      final List<AdminRoute> routes = await _admin.getRoutes();

      // The branches are only needed once a form is opened, so a failure here
      // must not blank out the list that did load.
      List<AdminBranch> branches = <AdminBranch>[];
      bool branchesFailed = false;

      try {
        branches = await _admin.getBranches();
      } on ApiException {
        branchesFailed = true;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _routes = routes;
        _branches = branches;
        _branchesFailed = branchesFailed;
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

  Future<void> _openEditor(AdminRoute? route) async {
    final AdminRoute? saved = await Navigator.push<AdminRoute>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditRouteScreen(route: route, branches: _branches),
      ),
    );

    if (saved != null && mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Routes')),
      floatingActionButton: _isLoading || _errorMessage != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(null),
              icon: const Icon(Icons.add_road_outlined),
              label: const Text('Add route'),
            ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
            children: [
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
                        onPressed: _load,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  _routes.length == 1
                      ? '1 route'
                      : '${_routes.length} routes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (_branchesFailed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMessage(
                      context,
                      const Text(
                        'The branch list did not load, so the route editor '
                        'may not be able to offer a branch. Pull down to try '
                        'again.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_routes.isEmpty)
                  _buildMessage(
                    context,
                    const Text(
                      'No route exists yet. A trip can only be scheduled '
                      'against a route, so an agency cannot sell a journey '
                      'until one is added.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ..._routes.map(
                    (AdminRoute route) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRouteCard(context, route),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'A route joins two branches and sets the fare for the '
                  'journey between them. Retiring a route keeps it in this '
                  'list so it can be brought back.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, AdminRoute route) {
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
              Icon(
                route.isActive
                    ? Icons.alt_route_outlined
                    : Icons.block_outlined,
                color: route.isActive ? AppColors.primary : AppColors.textLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      route.agencyName.isEmpty
                          ? 'Agency not recorded'
                          : route.agencyName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!route.isActive)
                Chip(
                  label: const Text('Retired'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${route.originBranchName} → ${route.destinationBranchName}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(
            '${route.baseFare.round()} FCFA • '
            '${route.distanceLabel} • ${route.durationLabel}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _openEditor(route),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, Widget child) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: child,
    );
  }
}
