import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../tracking/models/tracking.dart';
import '../../tracking/services/parcel_service.dart';
import 'tracking_details_screen.dart';

class MyParcelsScreen extends StatefulWidget {
  const MyParcelsScreen({super.key});

  @override
  State<MyParcelsScreen> createState() => _MyParcelsScreenState();
}

class _MyParcelsScreenState extends State<MyParcelsScreen> {
  final ParcelService _parcelService = ParcelService.instance;

  List<Parcel> _parcels = const <Parcel>[];

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadParcels();
  }

  Future<void> _loadParcels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Parcel> parcels = await _parcelService.getMyParcels();

      if (!mounted) {
        return;
      }

      setState(() {
        _parcels = parcels;
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

  /// `_ParcelCard` keeps its simple map contract, so each backend
  /// parcel is projected into the values the card renders.
  Map<String, dynamic> _toCardData(Parcel parcel) {
    return <String, dynamic>{
      'trackingReference': parcel.trackingNumber,
      'recipientName': parcel.recipientName,
      'recipientPhone': parcel.recipientPhone,
      'agency': parcel.originAgencyName ?? '—',
      'departureCity': parcel.originCity ?? '—',
      'destinationCity': parcel.destinationCity ?? '—',
      'description': parcel.description,
      'weight': parcel.weightKg == null
          ? '—'
          : '${parcel.weightKg!.toStringAsFixed(1)} kg',
      'status': parcel.status,
    };
  }

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

                      if (_isLoading) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ] else if (_errorMessage != null) ...[
                        _buildError(context),
                      ] else if (_parcels.isEmpty) ...[
                        _buildEmpty(context),
                      ] else ...[
                        ..._parcels.map(_buildParcelCard),
                      ],

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

  Widget _buildParcelCard(Parcel parcel) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _ParcelCard(
        parcel: _toCardData(parcel),
        agencyLabel: _agency(context),
        routeLabel: _route(context),
        recipientLabel: _recipient(context),
        weightLabel: _weight(context),
        trackLabel: _trackParcel(context),
        localizedStatus: l10n.trackingStatusLabel(parcel.status),
        onTrack: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackingDetailsScreen(
                trackingReference: parcel.trackingNumber,
                itemType: 'parcel',
                departureCity: parcel.originCity ?? '',
                destinationCity: parcel.destinationCity ?? '',
                status: parcel.status,
                progressPercentage: parcel.progressPercentage,
                events: parcel.trackingEvents,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.textSecondary,
            size: 34,
          ),

          const SizedBox(height: 12),

          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: _loadParcels,
            icon: const Icon(Icons.refresh),
            label: Text(_isFrench(context) ? 'Réessayer' : 'Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 16,
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.textSecondary,
            size: 34,
          ),

          const SizedBox(height: 12),

          Text(
            _isFrench(context)
                ? 'Aucun colis pour le moment. Les colis que vous envoyez apparaîtront ici.'
                : 'No parcels yet. Parcels you send will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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
      case 'DELIVERED':
      case 'Collected':
      case 'COLLECTED':
        return AppColors.success;

      case 'In Transit':
      case 'IN_TRANSIT':
      case 'Loaded':
      case 'LOADED':
        return AppColors.primary;

      case 'Arrived':
      case 'ARRIVED_AT_DESTINATION_AGENCY':
      case 'Ready for Collection':
      case 'READY_FOR_COLLECTION':
        return AppColors.secondary;

      case 'Registered':
      case 'REGISTERED':
      case 'Received by Agency':
      case 'RECEIVED_AT_AGENCY':
      case 'Received at Origin Agency':
      case 'RECEIVED_AT_ORIGIN_AGENCY':
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
