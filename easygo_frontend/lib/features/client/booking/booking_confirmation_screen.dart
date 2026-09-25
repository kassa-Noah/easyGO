import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../trips/models/trip.dart';
import 'digital_ticket_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> agency;
  final Trip trip;

  final String bookingMode;
  final String departureCity;
  final String destinationCity;

  final String? pickupLocation;
  final String? finalDestination;

  final DateTime travelDate;

  final int passengers;
  final int luggage;
  final int totalAmount;
  final String paymentMethod;

  // The real backend booking reference
  // returned once the booking is created.
  final String bookingReference;

  // The digital ticket number issued for the
  // confirmed booking.
  final String ticketNumber;

  const BookingConfirmationScreen({
    super.key,
    required this.agency,
    required this.trip,
    required this.bookingMode,
    required this.departureCity,
    required this.destinationCity,
    required this.travelDate,
    required this.passengers,
    required this.luggage,
    required this.totalAmount,
    required this.paymentMethod,
    required this.bookingReference,
    required this.ticketNumber,
    this.pickupLocation,
    this.finalDestination,
  });

  bool get isDoorToDoor => bookingMode == 'door_to_door';

  String _formattedDate() {
    final String day = travelDate.day.toString().padLeft(2, '0');

    final String month = travelDate.month.toString().padLeft(2, '0');

    return '$day/$month/${travelDate.year}';
  }

  String _formatTime(DateTime value) {
    final DateTime local = value.toLocal();

    final String hour = local.hour.toString().padLeft(2, '0');

    final String minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  void _viewTicket(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DigitalTicketScreen(
          agency: agency,
          trip: trip,
          bookingMode: bookingMode,
          departureCity: departureCity,
          destinationCity: destinationCity,
          pickupLocation: pickupLocation,
          finalDestination: finalDestination,
          travelDate: travelDate,
          passengers: passengers,
          luggage: luggage,
          totalAmount: totalAmount,
          paymentMethod: paymentMethod,

          // Both references now come from the backend.
          bookingReference: bookingReference,
          ticketReference: ticketNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking confirmation'),
        automaticallyImplyLeading: false,
      ),
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
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    children: [
                      _buildSuccessHeader(context),
                      const SizedBox(height: 20),
                      _buildBookingSummary(context, l10n),
                      const SizedBox(height: 20),
                      _buildPaymentSummary(context),
                      if (isDoorToDoor) ...[
                        const SizedBox(height: 20),
                        _buildDoorToDoorInfo(context, l10n),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _viewTicket(context);
                          },
                          icon: const Icon(Icons.confirmation_num_outlined),
                          label: const Text(
                            'View digital ticket',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildSuccessHeader(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 22,
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 44,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Payment successful',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment has been '
            'processed successfully.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'The booking and ticket '
            'references are issued by '
            'the easyGO backend and '
            'identify this journey.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          _ConfirmationRow(
            icon: Icons.business_outlined,
            label: 'Agency',
            value: agency['name']?.toString() ?? l10n.transportAgency,
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.route_outlined,
            label: 'Route',
            value:
                '$departureCity → '
                '$destinationCity',
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.calendar_today_outlined,
            label: 'Travel date',
            value: _formattedDate(),
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.schedule_outlined,
            label: 'Departure',
            value: _formatTime(trip.departureTime),
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.access_time_outlined,
            label: 'Arrival',
            value: _formatTime(trip.arrivalTime),
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.directions_bus_outlined,
            label: 'Vehicle',
            value: trip.vehicleDescription,
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.people_outline,
            label: 'Passengers',
            value: passengers.toString(),
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.luggage_outlined,
            label: 'Luggage',
            value: luggage.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          _ConfirmationRow(
            icon: Icons.payment_outlined,
            label: 'Payment method',
            value: paymentMethod,
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.payments_outlined,
            label: 'Amount paid',
            value: '${_formatPrice(totalAmount)} FCFA',
            emphasize: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDoorToDoorInfo(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.doorToDoorJourney,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          _ConfirmationRow(
            icon: Icons.home_outlined,
            label: 'Pickup',
            value: pickupLocation ?? l10n.pickupLocationFallback,
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.directions_bus_outlined,
            label: 'Interurban',
            value:
                '$departureCity → '
                '$destinationCity',
          ),
          const Divider(height: 28),
          _ConfirmationRow(
            icon: Icons.location_on_outlined,
            label: 'Final destination',
            value: finalDestination ?? l10n.finalDestinationFallback,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_taxi_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    l10n.taxiAssignmentInformation,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.5),
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

class _ConfirmationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  const _ConfirmationRow({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
                  color: emphasize ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
