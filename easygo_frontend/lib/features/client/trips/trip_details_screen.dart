import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../trips/models/trip.dart' as trip_model;
import '../booking/digital_ticket_screen.dart';
import 'booking_luggage_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailsScreen({super.key, required this.trip});

  bool get _isDoorToDoor => trip['bookingMode'] == 'Door-to-Door';

  bool get _isCancelled => trip['status'] == 'Cancelled';

  String _stringValue(String key, {String fallback = ''}) {
    return trip[key]?.toString() ?? fallback;
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  DateTime _getTravelDate() {
    final String date = _stringValue('date');

    final List<String> parts = date.split(' ');

    if (parts.length != 3) {
      return DateTime.now();
    }

    final int? day = int.tryParse(parts[0]);

    const Map<String, int> months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    final int? month = months[parts[1]];

    final int? year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return DateTime.now();
    }

    return DateTime(year, month, day);
  }

  DateTime _buildTripDateTime(String timeValue) {
    final DateTime date = _getTravelDate();

    final List<String> parts = timeValue.trim().split(':');

    if (parts.length < 2) {
      return date;
    }

    final int? hour = int.tryParse(parts[0]);

    final String minutePart = parts[1].replaceAll(RegExp(r'[^0-9]'), '').trim();

    final int? minute = int.tryParse(minutePart);

    if (hour == null || minute == null) {
      return date;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  trip_model.Trip _buildTypedTrip() {
    final DateTime departureTime = _buildTripDateTime(
      _stringValue('departureTime'),
    );

    DateTime arrivalTime = _buildTripDateTime(_stringValue('arrivalTime'));

    if (arrivalTime.isBefore(departureTime)) {
      arrivalTime = arrivalTime.add(const Duration(days: 1));
    }

    return trip_model.Trip(
      id: _stringValue('tripId', fallback: _stringValue('id')),
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      price: _toDouble(trip['amount']),
      totalSeats: 0,
      availableSeats: 0,
      status: _stringValue('status'),
      agencyId: _stringValue('agencyId'),
      routeId: _stringValue('routeId'),
      vehicleId: _stringValue('vehicleId'),
      agencyName: _stringValue('agency'),
      originCity: _stringValue('departureCity'),
      destinationCity: _stringValue('destinationCity'),
      originBranchName: _stringValue('originBranchName'),
      destinationBranchName: _stringValue('destinationBranchName'),
      originBranchAddress: _stringValue('originBranchAddress'),
      destinationBranchAddress: _stringValue('destinationBranchAddress'),
      distanceKm: trip['distanceKm'] == null
          ? null
          : _toDouble(trip['distanceKm']),
      estimatedDurationMinutes: trip['estimatedDurationMinutes'] == null
          ? null
          : _toInt(trip['estimatedDurationMinutes']),
      vehicleRegistrationNumber: _stringValue('vehicleRegistrationNumber'),
      vehicleModel: _stringValue('vehicleModel'),
      vehicleBrand: _stringValue('vehicleBrand'),
      vehicleCapacity: trip['vehicleCapacity'] == null
          ? null
          : _toInt(trip['vehicleCapacity']),
    );
  }

  void _openDigitalTicket(BuildContext context) {
    final Map<String, dynamic> agency = {'name': _stringValue('agency')};

    final trip_model.Trip ticketTrip = _buildTypedTrip();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DigitalTicketScreen(
          agency: agency,
          trip: ticketTrip,
          bookingMode: _isDoorToDoor ? 'door_to_door' : 'interurban_only',
          departureCity: _stringValue('departureCity'),
          destinationCity: _stringValue('destinationCity'),
          travelDate: _getTravelDate(),
          passengers: (trip['passengers'] as int?) ?? 1,
          luggage: (trip['luggage'] as int?) ?? 0,
          totalAmount: (trip['amount'] as int?) ?? 0,
          paymentMethod: _stringValue(
            'paymentMethod',
            fallback: 'Mobile Money',
          ),
          bookingReference: _stringValue('bookingReference'),
          ticketReference: _stringValue(
            'ticketReference',
            fallback: 'DEMO-TICKET',
          ),
          pickupLocation: _isDoorToDoor ? _stringValue('pickupLocation') : null,
          finalDestination: _isDoorToDoor
              ? _stringValue('finalDestination')
              : null,
        ),
      ),
    );
  }

  void _openLuggage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingLuggageScreen(trip: trip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetails)),
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
                    children: [
                      _buildBookingHeader(context, l10n),
                      const SizedBox(height: 18),
                      _buildJourneyCard(context, l10n),
                      if (_isDoorToDoor) ...[
                        const SizedBox(height: 18),
                        _buildDoorToDoorJourney(context, l10n),
                      ],
                      const SizedBox(height: 18),
                      _buildTravelInformation(context, l10n),
                      const SizedBox(height: 18),
                      _buildPaymentInformation(context, l10n),
                      const SizedBox(height: 18),
                      _buildActions(context, l10n),
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

  Widget _buildBookingHeader(BuildContext context, AppLocalizations l10n) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _stringValue('agency'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(
                status: _stringValue('status'),
                label: l10n.tripStatusLabel(_stringValue('status')),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.bookingReferenceLabel,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            _stringValue('bookingReference'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Text(
              l10n.bookingModeLabel(_stringValue('bookingMode')),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.interurbanJourney,
      icon: Icons.directions_bus_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _JourneyLocation(
                  label: l10n.departureLabel,
                  city: _stringValue('departureCity'),
                  time: _stringValue('departureTime'),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_bus_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _JourneyLocation(
                  label: l10n.arrivalLabel,
                  city: _stringValue('destinationCity'),
                  time: _stringValue('arrivalTime'),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 14),
          _InformationRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.travelDate,
            value: _stringValue('date'),
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.event_seat_outlined,
            label: l10n.travelClass,
            value: _stringValue(
              'travelClass',
              fallback: _stringValue('status'),
            ),
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.business_outlined,
            label: l10n.transportAgency,
            value: _stringValue('agency'),
          ),
        ],
      ),
    );
  }

  Widget _buildDoorToDoorJourney(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.doorToDoorJourney,
      icon: Icons.route_outlined,
      child: Column(
        children: [
          _JourneyStage(
            icon: Icons.home_outlined,
            title: l10n.pickupLocation,
            subtitle: _stringValue(
              'pickupLocation',
              fallback: l10n.pickupLocationFallback,
            ),
            status: l10n.scheduled,
            first: true,
          ),
          _JourneyStage(
            icon: Icons.local_taxi_outlined,
            title: l10n.pickupTaxi,
            subtitle: l10n.pickupTaxiAssignmentPending,
            status: l10n.pendingAssignment,
          ),
          _JourneyStage(
            icon: Icons.business_outlined,
            title: l10n.departureAgency,
            subtitle:
                '${_stringValue('agency')} • '
                '${_stringValue('departureCity')}',
            status: l10n.scheduled,
          ),
          _JourneyStage(
            icon: Icons.directions_bus_outlined,
            title: l10n.interurbanTrip,
            subtitle:
                '${_stringValue('departureCity')} → '
                '${_stringValue('destinationCity')}',
            status: l10n.journeyStageStatusLabel(_stringValue('status')),
          ),
          _JourneyStage(
            icon: Icons.business_outlined,
            title: l10n.arrivalAgency,
            subtitle:
                '${_stringValue('agency')} • '
                '${_stringValue('destinationCity')}',
            status: l10n.scheduled,
          ),
          _JourneyStage(
            icon: Icons.local_taxi_outlined,
            title: l10n.destinationTaxi,
            subtitle: l10n.destinationTaxiAssignmentPending,
            status: l10n.pendingAssignment,
          ),
          _JourneyStage(
            icon: Icons.location_on_outlined,
            title: l10n.finalDestination,
            subtitle: _stringValue(
              'finalDestination',
              fallback: l10n.finalDestinationFallback,
            ),
            status: l10n.scheduled,
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelInformation(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.travelInformation,
      icon: Icons.info_outline,
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.person_outline,
            label: l10n.passengers,
            value: '${(trip['passengers'] as int?) ?? 0}',
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.luggage_outlined,
            label: l10n.luggage,
            value: '${(trip['luggage'] as int?) ?? 0}',
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: _isDoorToDoor
                ? Icons.home_outlined
                : Icons.directions_bus_outlined,
            label: l10n.bookingMode,
            value: l10n.bookingModeLabel(_stringValue('bookingMode')),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInformation(BuildContext context, AppLocalizations l10n) {
    final int amount = (trip['amount'] as int?) ?? 0;

    return _SectionCard(
      title: l10n.paymentInformation,
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.check_circle_outline,
            label: l10n.paymentStatus,
            value: l10n.paid,
            valueColor: AppColors.success,
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.account_balance_wallet_outlined,
            label: l10n.paymentMethod,
            value: _stringValue('paymentMethod', fallback: 'Mobile Money'),
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.payments_outlined,
            label: l10n.amountPaid,
            value: '${_formatPrice(amount)} FCFA',
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    final int luggageCount = (trip['luggage'] as int?) ?? 0;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 17,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCancelled
                  ? null
                  : () {
                      _openDigitalTicket(context);
                    },
              icon: const Icon(Icons.qr_code_2_outlined),
              label: Text(l10n.viewDigitalTicket),
            ),
          ),
          if (luggageCount > 0 && !_isCancelled) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _openLuggage(context);
                },
                icon: const Icon(Icons.luggage_outlined),
                label: Text(l10n.trackLuggage),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 17,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 21, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _JourneyLocation extends StatelessWidget {
  final String label;
  final String city;
  final String time;
  final bool alignEnd;

  const _JourneyLocation({
    required this.label,
    required this.city,
    required this.time,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 5),
        Text(
          time,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
          city,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _JourneyStage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final bool first;
  final bool last;

  const _JourneyStage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    this.first = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                if (!first)
                  Container(
                    width: 2,
                    height: 12,
                    color: Theme.of(context).dividerColor,
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 17, color: Colors.white),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints: const BoxConstraints(minHeight: 28),
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: first ? 3 : 14,
                bottom: last ? 3 : 17,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const _StatusBadge({required this.status, required this.label});

  Color get _color {
    switch (status) {
      case 'Upcoming':
        return Colors.white;
      case 'Completed':
        return AppColors.secondaryLight;
      case 'Cancelled':
        return const Color(0xFFFFCDD2);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
