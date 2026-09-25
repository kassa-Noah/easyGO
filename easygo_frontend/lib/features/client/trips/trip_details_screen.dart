import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../bookings/models/booking.dart';
import '../../bookings/services/booking_service.dart';
import '../../journeys/models/journey.dart';
import '../../journeys/services/journey_service.dart';
import '../booking/digital_ticket_screen.dart';
import 'booking_luggage_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final Booking booking;

  const TripDetailsScreen({super.key, required this.booking});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final BookingService _bookingService = BookingService.instance;

  final JourneyService _journeyService = JourneyService.instance;

  late Booking _booking;

  Journey? _journey;

  bool _isCancelling = false;
  bool _isLoadingJourney = false;

  String? _journeyError;

  @override
  void initState() {
    super.initState();

    _booking = widget.booking;

    if (_booking.isDoorToDoor) {
      _loadJourney();
    }
  }

  Future<void> _loadJourney() async {
    final String? journeyId = _booking.journey?.id;

    if (journeyId == null || journeyId.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoadingJourney = true;
      _journeyError = null;
    });

    try {
      final Journey journey = await _journeyService.getJourneyById(journeyId);

      if (!mounted) {
        return;
      }

      setState(() {
        _journey = journey;
        _isLoadingJourney = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _journeyError = error.toString();
        _isLoadingJourney = false;
      });
    }
  }

  String _formatPrice(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '—';
    }

    final DateTime date = value.toLocal();

    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '—';
    }

    final DateTime time = value.toLocal();

    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '—';
    }

    return '${_formatDate(value)} '
        '${_formatTime(value)}';
  }

  String _readableStatus(String value) {
    if (value.trim().isEmpty) {
      return '—';
    }

    return value
        .toLowerCase()
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}'
              '${part.substring(1)}',
        )
        .join(' ');
  }

  String get _displayStatus {
    if (_booking.isCancelled) {
      return 'Cancelled';
    }

    final DateTime? arrival = _booking.arrivalTime;

    if (arrival != null && arrival.isBefore(DateTime.now().toUtc())) {
      return 'Completed';
    }

    return 'Upcoming';
  }

  Map<String, dynamic> _buildLuggageCompatibilityMap() {
    return {
      'bookingReference': _booking.bookingReference,
      'agency': _booking.agencyName,
      'departureCity': _booking.originCity,
      'destinationCity': _booking.destinationCity,
      'luggage': _booking.luggageCount,
      'luggageItems': _booking.luggage
          .map(
            (item) => {
              'id': item.id,
              'trackingReference': item.trackingNumber,
              'trackingNumber': item.trackingNumber,
              'description': item.description,
              'weight': item.weightKg == null ? '' : '${item.weightKg} kg',
              'weightKg': item.weightKg,
              'status': item.status,
              'progressPercentage': item.progressPercentage,
            },
          )
          .toList(),
    };
  }

  void _openLuggage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookingLuggageScreen(trip: _buildLuggageCompatibilityMap()),
      ),
    );
  }

  void _openDigitalTicket() {
    final ticket = _booking.ticket;
    final trip = _booking.trip;

    if (ticket == null || trip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A digital ticket is not '
            'available for this booking yet.',
          ),
        ),
      );

      return;
    }

    final BookingPayment? payment = _booking.successfulPayment;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DigitalTicketScreen(
          agency: {'id': trip.agencyId, 'name': trip.agencyName},
          trip: trip,
          bookingMode: _booking.isDoorToDoor
              ? 'door_to_door'
              : 'interurban_only',
          departureCity: trip.originCity,
          destinationCity: trip.destinationCity,
          travelDate: trip.departureTime,
          passengers: _booking.numberOfSeats,
          luggage: _booking.luggageCount,
          totalAmount: _booking.totalAmount.round(),
          paymentMethod: payment?.method ?? 'Not available',
          bookingReference: _booking.bookingReference,
          ticketReference: ticket.ticketNumber,
          pickupLocation: _booking.journey?.pickupAddress,
          finalDestination: _booking.journey?.destinationAddress,
        ),
      ),
    );
  }

  Future<void> _cancelBooking() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel booking'),
          content: const Text(
            'Are you sure you want to '
            'cancel this booking?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Keep booking'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Cancel booking'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      final Booking updated = await _bookingService.cancelBooking(_booking.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _booking = updated;
        _isCancelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCancelling = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
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
          child: RefreshIndicator(
            onRefresh: () async {
              if (_booking.isDoorToDoor) {
                await _loadJourney();
              }
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      children: [
                        _buildHeader(context, l10n),
                        const SizedBox(height: 18),
                        _buildJourneyCard(context, l10n),
                        if (_booking.isDoorToDoor) ...[
                          const SizedBox(height: 18),
                          _buildDoorToDoor(context, l10n),
                        ],
                        const SizedBox(height: 18),
                        _buildTravelInfo(context, l10n),
                        const SizedBox(height: 18),
                        _buildPaymentInfo(context, l10n),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _booking.agencyName.isEmpty
                      ? 'Transport agency'
                      : _booking.agencyName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _HeaderStatusBadge(label: l10n.tripStatusLabel(_displayStatus)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.bookingReferenceLabel,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          SelectableText(
            _booking.bookingReference,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Backend status: '
            '${_readableStatus(_booking.status)}',
            style: const TextStyle(fontSize: 11, color: Colors.white70),
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
                  city: _booking.originCity,
                  time: _formatTime(_booking.departureTime),
                ),
              ),
              const Expanded(
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _JourneyLocation(
                  label: l10n.arrivalLabel,
                  city: _booking.destinationCity,
                  time: _formatTime(_booking.arrivalTime),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InformationRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.travelDate,
            value: _formatDate(_booking.departureTime),
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.business_outlined,
            label: l10n.transportAgency,
            value: _booking.agencyName,
          ),
          if (_booking.trip != null) ...[
            const SizedBox(height: 13),
            _InformationRow(
              icon: Icons.directions_bus_outlined,
              label: 'Vehicle',
              value: _booking.trip!.vehicleDescription,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoorToDoor(BuildContext context, AppLocalizations l10n) {
    final BookingJourney bookingJourney = _booking.journey!;

    return _SectionCard(
      title: l10n.doorToDoorJourney,
      icon: Icons.route_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InformationRow(
            icon: Icons.home_outlined,
            label: l10n.pickupLocation,
            value: bookingJourney.pickupAddress,
          ),
          const SizedBox(height: 14),
          _InformationRow(
            icon: Icons.route_outlined,
            label: 'Journey status',
            value: _readableStatus(_journey?.status ?? bookingJourney.status),
          ),
          const SizedBox(height: 14),
          _InformationRow(
            icon: Icons.location_on_outlined,
            label: l10n.finalDestination,
            value: bookingJourney.destinationAddress,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          if (_isLoadingJourney)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_journeyError != null)
            _JourneyError(message: _journeyError!, onRetry: _loadJourney)
          else if (_journey == null)
            const Text(
              'Detailed taxi information '
              'is not available yet.',
            )
          else ...[
            _TaxiAssignmentCard(
              title: l10n.pickupTaxi,
              assignment: _journey!.pickupTaxi,
              readableStatus: _readableStatus,
              formatPrice: _formatPrice,
              formatDateTime: _formatDateTime,
              pendingMessage:
                  'Pickup taxi assignment '
                  'is pending.',
            ),
            const SizedBox(height: 16),
            _InterurbanSegment(
              booking: _booking,
              readableStatus: _readableStatus,
            ),
            const SizedBox(height: 16),
            _TaxiAssignmentCard(
              title: l10n.destinationTaxi,
              assignment: _journey!.arrivalTaxi,
              readableStatus: _readableStatus,
              formatPrice: _formatPrice,
              formatDateTime: _formatDateTime,
              pendingMessage:
                  'Destination taxi '
                  'assignment is pending.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTravelInfo(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.travelInformation,
      icon: Icons.info_outline,
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.person_outline,
            label: l10n.passengers,
            value: _booking.numberOfSeats.toString(),
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.luggage_outlined,
            label: l10n.luggage,
            value: _booking.luggageCount.toString(),
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: _booking.isDoorToDoor
                ? Icons.home_outlined
                : Icons.directions_bus_outlined,
            label: l10n.bookingMode,
            value: _booking.isDoorToDoor ? 'Door-to-Door' : 'Interurban Only',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context, AppLocalizations l10n) {
    final BookingPayment? payment = _booking.successfulPayment;

    return _SectionCard(
      title: l10n.paymentInformation,
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          _InformationRow(
            icon: _booking.hasSuccessfulPayment
                ? Icons.check_circle_outline
                : Icons.schedule_outlined,
            label: l10n.paymentStatus,
            value: payment == null
                ? 'Not paid'
                : _readableStatus(payment.status),
            valueColor: payment == null
                ? AppColors.textSecondary
                : AppColors.success,
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.account_balance_wallet_outlined,
            label: l10n.paymentMethod,
            value: payment == null ? '—' : _readableStatus(payment.method),
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.payments_outlined,
            label: l10n.amountPaid,
            value: payment == null
                ? '0 FCFA'
                : '${_formatPrice(payment.amount)} '
                      'FCFA',
          ),
          const SizedBox(height: 13),
          _InformationRow(
            icon: Icons.receipt_long_outlined,
            label: l10n.amountLabel,
            value:
                '${_formatPrice(_booking.totalAmount)} '
                'FCFA',
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 17,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _booking.ticket == null || _booking.isCancelled
                  ? null
                  : _openDigitalTicket,
              icon: const Icon(Icons.qr_code_2_outlined),
              label: Text(l10n.viewDigitalTicket),
            ),
          ),
          if (_booking.luggageCount > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openLuggage,
                icon: const Icon(Icons.luggage_outlined),
                label: Text(l10n.trackLuggage),
              ),
            ),
          ],
          if (!_booking.isCancelled) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isCancelling ? null : _cancelBooking,
                icon: _isCancelling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_outlined),
                label: Text(_isCancelling ? 'Cancelling...' : 'Cancel booking'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaxiAssignmentCard extends StatelessWidget {
  final String title;

  final TaxiAssignment? assignment;

  final String Function(String) readableStatus;

  final String Function(double) formatPrice;

  final String Function(DateTime?) formatDateTime;

  final String pendingMessage;

  const _TaxiAssignmentCard({
    required this.title,
    required this.assignment,
    required this.readableStatus,
    required this.formatPrice,
    required this.formatDateTime,
    required this.pendingMessage,
  });

  @override
  Widget build(BuildContext context) {
    final TaxiAssignment? taxi = assignment;

    if (taxi == null) {
      return _JourneyStageContainer(
        title: title,
        icon: Icons.local_taxi_outlined,
        child: Text(
          pendingMessage,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final bool hasFinalFare = taxi.finalFare != null;

    return _JourneyStageContainer(
      title: title,
      icon: Icons.local_taxi_outlined,
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: readableStatus(taxi.status),
          ),
          const SizedBox(height: 11),
          _InformationRow(
            icon: Icons.business_outlined,
            label: 'Provider',
            value: taxi.provider?.name ?? '—',
          ),
          const SizedBox(height: 11),
          _InformationRow(
            icon: Icons.my_location_outlined,
            label: 'Pickup',
            value: taxi.pickupAddress,
          ),
          const SizedBox(height: 11),
          _InformationRow(
            icon: Icons.location_on_outlined,
            label: 'Drop-off',
            value: taxi.dropoffAddress,
          ),
          const SizedBox(height: 11),
          _InformationRow(
            icon: Icons.payments_outlined,
            label: hasFinalFare ? 'Final fare' : 'Estimated fare',
            value:
                '${formatPrice(hasFinalFare ? taxi.finalFare! : taxi.estimatedFare)} FCFA',
          ),
          if (taxi.hasDriver) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            _InformationRow(
              icon: Icons.person_outline,
              label: 'Driver',
              value: taxi.driverName ?? '—',
            ),
            const SizedBox(height: 11),
            _InformationRow(
              icon: Icons.phone_outlined,
              label: 'Driver phone',
              value: taxi.driverPhone ?? '—',
            ),
            const SizedBox(height: 11),
            _InformationRow(
              icon: Icons.directions_car_outlined,
              label: 'Vehicle',
              value: taxi.vehicleDescription ?? '—',
            ),
            const SizedBox(height: 11),
            _InformationRow(
              icon: Icons.confirmation_number_outlined,
              label: 'Registration',
              value: taxi.vehicleRegistration ?? '—',
            ),
          ] else ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule_outlined, size: 18),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      pendingMessage,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (taxi.assignedAt != null) ...[
            const SizedBox(height: 11),
            _InformationRow(
              icon: Icons.schedule_outlined,
              label: 'Assigned at',
              value: formatDateTime(taxi.assignedAt),
            ),
          ],
          if (taxi.completedAt != null) ...[
            const SizedBox(height: 11),
            _InformationRow(
              icon: Icons.check_circle_outline,
              label: 'Completed at',
              value: formatDateTime(taxi.completedAt),
            ),
          ],
        ],
      ),
    );
  }
}

class _InterurbanSegment extends StatelessWidget {
  final Booking booking;

  final String Function(String) readableStatus;

  const _InterurbanSegment({
    required this.booking,
    required this.readableStatus,
  });

  @override
  Widget build(BuildContext context) {
    return _JourneyStageContainer(
      title: 'Interurban bus journey',
      icon: Icons.directions_bus_outlined,
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.business_outlined,
            label: 'Agency',
            value: booking.agencyName,
          ),
          const SizedBox(height: 11),
          _InformationRow(
            icon: Icons.route_outlined,
            label: 'Route',
            value:
                '${booking.originCity} → '
                '${booking.destinationCity}',
          ),
          if (booking.trip != null) ...[
            const SizedBox(height: 11),
            _InformationRow(
              icon: Icons.info_outline,
              label: 'Trip status',
              value: readableStatus(booking.trip!.status),
            ),
            const SizedBox(height: 11),
            _InformationRow(
              icon: Icons.directions_bus_outlined,
              label: 'Vehicle',
              value: booking.trip!.vehicleDescription,
            ),
          ],
        ],
      ),
    );
  }
}

class _JourneyStageContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _JourneyStageContainer({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _JourneyError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _JourneyError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.35),
      ),
      child: Column(
        children: [
          Text(
            'Unable to load detailed '
            'door-to-door information.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
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
              Icon(icon, color: AppColors.primary),
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
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 5),
        Text(
          time,
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

class _HeaderStatusBadge extends StatelessWidget {
  final String label;

  const _HeaderStatusBadge({required this.label});

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
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
