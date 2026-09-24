import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'tracking_details_screen.dart';

class TravelerLuggageScreen extends StatelessWidget {
  const TravelerLuggageScreen({super.key});

  /*
   * FRONTEND DEMONSTRATION DATA ONLY.
   *
   * During backend integration, these records
   * will be retrieved using the authenticated
   * client's confirmed bookings.
   *
   * Tracking status values remain canonical
   * internal values. Their visible labels are
   * localized by the frontend.
   */
  List<Map<String, dynamic>> get _luggageItems => [
    {
      'id': 'luggage_001',
      'trackingReference': 'LUG-DEMO-001',
      'bookingReference': 'DEMO-BOOKING-001',
      'agency': 'General Express',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Douala',
      'description': 'Large black suitcase',
      'weight': '18 kg',
      'status': 'In Transit',
    },
    {
      'id': 'luggage_002',
      'trackingReference': 'LUG-DEMO-002',
      'bookingReference': 'DEMO-BOOKING-002',
      'agency': 'Finexs Voyage',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Bafoussam',
      'description': 'Medium blue travel bag',
      'weight': '12 kg',
      'status': 'Received by Agency',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.travelerLuggage)),
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, l10n),

                      const SizedBox(height: 26),

                      _buildSectionHeader(context, l10n),

                      const SizedBox(height: 16),

                      ..._luggageItems.map(
                        (luggage) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _LuggageCard(
                            luggage: luggage,
                            onTrack: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrackingDetailsScreen(
                                    trackingReference:
                                        luggage['trackingReference'],
                                    itemType: 'luggage',
                                    departureCity: luggage['departureCity'],
                                    destinationCity: luggage['destinationCity'],
                                    currentStatus: luggage['status'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      _buildInformationCard(context, l10n),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.luggage_outlined,
              size: 33,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.travelLuggage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  l10n.travelLuggageDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.myLuggage,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.luggageItemCount(_luggageItems.length),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 20,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              l10n.travelerLuggageInformation,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuggageCard extends StatelessWidget {
  final Map<String, dynamic> luggage;

  final VoidCallback onTrack;

  const _LuggageCard({required this.luggage, required this.onTrack});

  Color _statusColor() {
    switch (luggage['status']) {
      case 'Delivered':
        return AppColors.success;

      case 'In Transit':
        return AppColors.primary;

      case 'Arrived':
      case 'Ready for Collection':
        return AppColors.secondary;

      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final Color statusColor = _statusColor();

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 17,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.luggage_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.luggageDescriptionLabel(luggage['description']),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    SelectableText(
                      luggage['trackingReference'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                constraints: const BoxConstraints(maxWidth: 145),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  l10n.trackingStatusLabel(luggage['status']),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 12),

          _LuggageInformationRow(
            icon: Icons.confirmation_num_outlined,
            label: l10n.booking,
            value: luggage['bookingReference'],
          ),

          const SizedBox(height: 12),

          _LuggageInformationRow(
            icon: Icons.business_outlined,
            label: l10n.agency,
            value: luggage['agency'],
          ),

          const SizedBox(height: 12),

          _LuggageInformationRow(
            icon: Icons.route_outlined,
            label: l10n.route,
            value:
                '${luggage['departureCity']} → '
                '${luggage['destinationCity']}',
          ),

          const SizedBox(height: 12),

          _LuggageInformationRow(
            icon: Icons.scale_outlined,
            label: l10n.weight,
            value: luggage['weight'],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTrack,
              icon: const Icon(Icons.location_searching_outlined),
              label: Text(l10n.trackLuggage),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuggageInformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LuggageInformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),

        const SizedBox(width: 9),

        SizedBox(
          width: 82,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
