import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../bookings/agency_bookings_screen.dart';
import '../luggage/agency_luggage_screen.dart';
import '../models/agency_console.dart';
import '../parcels/agency_parcels_screen.dart';
import '../services/agency_console_service.dart';
import '../trips/agency_trips_screen.dart';

class AgencyOperationsScreen extends StatefulWidget {
  const AgencyOperationsScreen({super.key});

  @override
  State<AgencyOperationsScreen> createState() =>
      _AgencyOperationsScreenState();
}

class _AgencyOperationsScreenState extends State<AgencyOperationsScreen> {
  final AgencyConsoleService _console = AgencyConsoleService.instance;

  String? _agencyName;
  String? _staffRole;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAgency();
  }

  Future<void> _loadAgency() async {
    try {
      final StaffAgencyProfile profile = await _console.getMyAgency();

      if (!mounted) {
        return;
      }

      setState(() {
        _agencyName = profile.name;
        _staffRole = profile.staffRole;
        _errorMessage = null;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    }
  }

  void _openTrips(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgencyTripsScreen()),
    );
  }

  void _openBookings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgencyBookingsScreen()),
    );
  }

  void _openLuggage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgencyLuggageScreen()),
    );
  }

  void _openParcels(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgencyParcelsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.operations)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF09111F),
                    Color(0xFF0D1B2A),
                    Color(0xFF10253B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF2F8FF),
                    Color(0xFFF7FBFF),
                    Color(0xFFF1FFF6),
                  ],
                ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, localizations),
                    const SizedBox(height: 22),
                    _buildOperationsGrid(context, localizations),
                    const SizedBox(height: 22),
                    _buildAuthorizationNotice(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      borderRadius: 19,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.operations,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _agencyName ?? 'Your agency',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_staffRole != null && _staffRole!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _staffRole!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsGrid(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 650;

        if (!wide) {
          return Column(
            children: [
              _OperationCard(
                icon: Icons.directions_bus_outlined,
                title: localizations.trips,
                description: localizations.tripManagement,
                color: AppColors.primary,
                onTap: () {
                  _openTrips(context);
                },
              ),
              const SizedBox(height: 14),
              _OperationCard(
                icon: Icons.confirmation_number_outlined,
                title: localizations.bookings,
                description: localizations.bookingManagement,
                color: AppColors.secondary,
                onTap: () {
                  _openBookings(context);
                },
              ),
              const SizedBox(height: 14),
              _OperationCard(
                icon: Icons.luggage_outlined,
                title: localizations.travelerLuggage,
                description: localizations.luggageManagement,
                color: AppColors.warning,
                onTap: () {
                  _openLuggage(context);
                },
              ),
              const SizedBox(height: 14),
              _OperationCard(
                icon: Icons.inventory_2_outlined,
                title: localizations.parcels,
                description: localizations.parcelManagement,
                color: AppColors.primaryDark,
                onTap: () {
                  _openParcels(context);
                },
              ),
            ],
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 2.1,
          children: [
            _OperationCard(
              icon: Icons.directions_bus_outlined,
              title: localizations.trips,
              description: localizations.tripManagement,
              color: AppColors.primary,
              onTap: () {
                _openTrips(context);
              },
            ),
            _OperationCard(
              icon: Icons.confirmation_number_outlined,
              title: localizations.bookings,
              description: localizations.bookingManagement,
              color: AppColors.secondary,
              onTap: () {
                _openBookings(context);
              },
            ),
            _OperationCard(
              icon: Icons.luggage_outlined,
              title: localizations.travelerLuggage,
              description: localizations.luggageManagement,
              color: AppColors.warning,
              onTap: () {
                _openLuggage(context);
              },
            ),
            _OperationCard(
              icon: Icons.inventory_2_outlined,
              title: localizations.parcels,
              description: localizations.parcelManagement,
              color: AppColors.primaryDark,
              onTap: () {
                _openParcels(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthorizationNotice(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These screens are scoped by the backend to the agency your '
              'staff account belongs to, so the trips, bookings, luggage and '
              'parcels you see are only your own.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 18,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 15),
        ],
      ),
    );
  }
}
