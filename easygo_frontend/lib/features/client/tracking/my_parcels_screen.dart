import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'tracking_details_screen.dart';

class MyParcelsScreen extends StatelessWidget {
  const MyParcelsScreen({super.key});

  /*
   * FRONTEND DEMONSTRATION DATA ONLY.
   *
   * In production, these records must come
   * from the authenticated client's backend
   * parcel shipments.
   *
   * Creating a parcel in the current prototype
   * does not persist a new record into this
   * demonstration list.
   */
  List<Map<String, dynamic>> get _parcels => [
    {
      'trackingReference': 'PAR-DEMO-001',
      'recipientName': 'John Doe',
      'recipientPhone': '677123456',
      'agency': 'General Express',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Douala',
      'description': 'Clothes in a medium box',
      'weight': '8.5 kg',
      'status': 'In Transit',
    },
    {
      'trackingReference': 'PAR-DEMO-002',
      'recipientName': 'Mary Example',
      'recipientPhone': '699123456',
      'agency': 'Finexs Voyage',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Bafoussam',
      'description': 'Personal items',
      'weight': '5.0 kg',
      'status': 'Received by Agency',
    },
  ];

  bool _isFrench(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'fr';
  }

  String _myParcels(BuildContext context) {
    return _isFrench(context) ? 'Mes colis' : 'My Parcels';
  }

  String _myParcelShipments(BuildContext context) {
    return _isFrench(context)
        ? 'Mes expéditions de colis'
        : 'My Parcel Shipments';
  }

  String _headerDescription(BuildContext context) {
    return _isFrench(context)
        ? 'Consultez vos expéditions interurbaines de colis et leur état de suivi actuel.'
        : 'View your interurban parcel shipments and their current tracking status.';
  }

  String _parcelShipments(BuildContext context) {
    return _isFrench(context) ? 'Expéditions de colis' : 'Parcel Shipments';
  }

  String _parcelCount(BuildContext context, int count) {
    if (_isFrench(context)) {
      return count > 1 ? '$count colis' : '$count colis';
    }

    return count == 1 ? '1 parcel' : '$count parcels';
  }

  String _agency(BuildContext context) {
    return _isFrench(context) ? 'Agence' : 'Agency';
  }

  String _route(BuildContext context) {
    return _isFrench(context) ? 'Itinéraire' : 'Route';
  }

  String _recipient(BuildContext context) {
    return _isFrench(context) ? 'Destinataire' : 'Recipient';
  }

  String _weight(BuildContext context) {
    return _isFrench(context) ? 'Poids' : 'Weight';
  }

  String _trackParcel(BuildContext context) {
    return _isFrench(context) ? 'Suivre le colis' : 'Track Parcel';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(_myParcels(context))),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context),

                      const SizedBox(height: 24),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _parcelShipments(context),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              _parcelCount(context, _parcels.length),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      ..._parcels.map(
                        (parcel) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ParcelCard(
                            parcel: parcel,
                            agencyLabel: _agency(context),
                            routeLabel: _route(context),
                            recipientLabel: _recipient(context),
                            weightLabel: _weight(context),
                            trackLabel: _trackParcel(context),
                            localizedStatus: l10n.trackingStatusLabel(
                              parcel['status'],
                            ),
                            onTrack: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrackingDetailsScreen(
                                    trackingReference:
                                        parcel['trackingReference'],
                                    itemType: 'parcel',
                                    departureCity: parcel['departureCity'],
                                    destinationCity: parcel['destinationCity'],
                                    currentStatus: parcel['status'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
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

  Widget _buildHeader(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 31,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _myParcelShipments(context),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _headerDescription(context),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
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
}

class _ParcelCard extends StatelessWidget {
  final Map<String, dynamic> parcel;

  final String agencyLabel;
  final String routeLabel;
  final String recipientLabel;
  final String weightLabel;
  final String trackLabel;
  final String localizedStatus;
  final VoidCallback onTrack;

  const _ParcelCard({
    required this.parcel,
    required this.agencyLabel,
    required this.routeLabel,
    required this.recipientLabel,
    required this.weightLabel,
    required this.trackLabel,
    required this.localizedStatus,
    required this.onTrack,
  });

  Color _statusColor() {
    switch (parcel['status']) {
      case 'Delivered':
        return AppColors.success;

      case 'In Transit':
        return AppColors.primary;

      case 'Arrived':
      case 'Ready for Collection':
        return AppColors.secondary;

      case 'Loaded':
        return AppColors.primary;

      case 'Registered':
      case 'Received by Agency':
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      parcel['trackingReference'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      parcel['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                constraints: const BoxConstraints(maxWidth: 130),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  localizedStatus,
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

          const SizedBox(height: 16),

          const Divider(),

          const SizedBox(height: 12),

          _InformationRow(label: agencyLabel, value: parcel['agency']),

          const SizedBox(height: 10),

          _InformationRow(
            label: routeLabel,
            value:
                '${parcel['departureCity']} → '
                '${parcel['destinationCity']}',
          ),

          const SizedBox(height: 10),

          _InformationRow(
            label: recipientLabel,
            value: parcel['recipientName'],
          ),

          const SizedBox(height: 10),

          _InformationRow(label: weightLabel, value: parcel['weight']),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTrack,
              icon: const Icon(Icons.location_searching),
              label: Text(trackLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final String label;
  final String value;

  const _InformationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
