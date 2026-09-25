import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../bookings/models/booking.dart';
import '../../bookings/services/booking_service.dart';
import '../../journeys/services/journey_service.dart';
import '../../trips/models/trip.dart';
import 'payment_screen.dart';

class BookingReviewScreen extends StatefulWidget {
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

  const BookingReviewScreen({
    super.key,
    required this.agency,
    required this.trip,
    required this.bookingMode,
    required this.departureCity,
    required this.destinationCity,
    required this.travelDate,
    required this.passengers,
    required this.luggage,
    this.pickupLocation,
    this.finalDestination,
  });

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  final BookingService _bookingService = BookingService.instance;

  final JourneyService _journeyService = JourneyService.instance;

  bool _isCreatingBooking = false;

  bool get isDoorToDoor => widget.bookingMode == 'door_to_door';

  int get interurbanUnitFare => widget.trip.price.round();

  int get interurbanTotal => interurbanUnitFare * widget.passengers;

  // Temporary frontend estimates only.
  // They are not sent to the booking API.
  int get pickupTaxiFare => isDoorToDoor ? 2500 : 0;

  int get destinationTaxiFare => isDoorToDoor ? 3000 : 0;

  int get totalPrice => interurbanTotal + pickupTaxiFare + destinationTaxiFare;

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String _formattedDate() {
    final String day = widget.travelDate.day.toString().padLeft(2, '0');

    final String month = widget.travelDate.month.toString().padLeft(2, '0');

    return '$day/$month/${widget.travelDate.year}';
  }

  String _formatTime(DateTime value) {
    final DateTime local = value.toLocal();

    final String hour = local.hour.toString().padLeft(2, '0');

    final String minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatDuration() {
    final int minutes =
        widget.trip.estimatedDurationMinutes ?? widget.trip.duration.inMinutes;

    final int hours = minutes ~/ 60;

    final int remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}min';
    }

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h '
        '${remainingMinutes.toString().padLeft(2, '0')}min';
  }

  String _vehicleInformation() {
    if (widget.trip.vehicleDescription.trim().isNotEmpty) {
      return widget.trip.vehicleDescription;
    }

    return 'Vehicle information unavailable';
  }

  bool _validateDoorToDoorAddresses() {
    if (!isDoorToDoor) {
      return true;
    }

    final String pickup = widget.pickupLocation?.trim() ?? '';

    final String destination = widget.finalDestination?.trim() ?? '';

    if (pickup.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid pickup address '
            'before continuing.',
          ),
        ),
      );

      return false;
    }

    if (destination.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid final destination '
            'before continuing.',
          ),
        ),
      );

      return false;
    }

    return true;
  }

  Future<void> _continueToPayment() async {
    if (_isCreatingBooking) {
      return;
    }

    if (!_validateDoorToDoorAddresses()) {
      return;
    }

    if (widget.passengers < 1 || widget.passengers > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The number of passengers must '
            'be between 1 and 10.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isCreatingBooking = true;
    });

    Booking? createdBooking;

    try {
      createdBooking = await _bookingService.createBooking(
        tripId: widget.trip.id,
        numberOfSeats: widget.passengers,
      );

      if (isDoorToDoor) {
        await _journeyService.createJourney(
          bookingId: createdBooking.id,
          pickupAddress: widget.pickupLocation!.trim(),
          destinationAddress: widget.finalDestination!.trim(),
        );

        // Reload the booking so the object
        // passed forward contains the newly
        // created nested journey.
        createdBooking = await _bookingService.getBookingById(
          createdBooking.id,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            agency: widget.agency,
            trip: widget.trip,
            booking: createdBooking!,
            bookingMode: widget.bookingMode,
            departureCity: widget.departureCity,
            destinationCity: widget.destinationCity,
            pickupLocation: widget.pickupLocation,
            finalDestination: widget.finalDestination,
            travelDate: widget.travelDate,
            passengers: widget.passengers,
            luggage: widget.luggage,
            displayTotalAmount: totalPrice,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      String message = error.toString();

      if (createdBooking != null && isDoorToDoor) {
        message =
            'The interurban booking was created, '
            'but the door-to-door journey could '
            'not be created. Please do not press '
            'Continue again. Error: $message';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 6)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewBooking)),
      body: Container(
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          _buildModeBanner(context, l10n),
                          const SizedBox(height: 18),
                          _buildJourneyCard(context, l10n),
                          const SizedBox(height: 18),
                          _buildTripCard(context, l10n),
                          const SizedBox(height: 18),
                          _buildPassengerCard(context, l10n),
                          if (isDoorToDoor) ...[
                            const SizedBox(height: 18),
                            _buildDoorToDoorCard(context, l10n),
                          ],
                          const SizedBox(height: 18),
                          _buildPriceCard(context, l10n),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomSection(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeBanner(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isDoorToDoor ? AppColors.secondary : AppColors.primary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isDoorToDoor
                  ? Icons.home_work_outlined
                  : Icons.directions_bus_outlined,
              color: isDoorToDoor ? AppColors.secondary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDoorToDoor ? l10n.doorToDoorJourney : l10n.interurbanOnly,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDoorToDoor
                      ? l10n.taxiInterurbanTaxi
                      : l10n.agencyToAgencyTransport,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.journey,
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.business_outlined,
            label: l10n.agency,
            value: widget.agency['name']?.toString() ?? l10n.transportAgency,
          ),
          const Divider(height: 28),
          _DetailRow(
            icon: Icons.route_outlined,
            label: l10n.route,
            value:
                '${widget.departureCity} → '
                '${widget.destinationCity}',
          ),
          const Divider(height: 28),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.travelDate,
            value: _formattedDate(),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.selectedTrip,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _TimeBlock(
                  label: l10n.departure,
                  value: _formatTime(widget.trip.departureTime),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 19,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _TimeBlock(
                  label: l10n.arrival,
                  value: _formatTime(widget.trip.arrivalTime),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(
            icon: Icons.directions_bus_outlined,
            label: l10n.travelClass,
            value: widget.trip.status,
          ),
          const Divider(height: 28),
          _DetailRow(
            icon: Icons.schedule_outlined,
            label: l10n.duration,
            value: _formatDuration(),
          ),
          const Divider(height: 28),
          _DetailRow(
            icon: Icons.directions_bus_outlined,
            label: 'Vehicle',
            value: _vehicleInformation(),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.travelInformation,
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.people_outline,
            label: l10n.passengers,
            value: widget.passengers.toString(),
          ),
          const Divider(height: 28),
          _DetailRow(
            icon: Icons.luggage_outlined,
            label: l10n.luggageItems,
            value: widget.luggage.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildDoorToDoorCard(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.doorToDoorDetails,
      child: Column(
        children: [
          _JourneySegment(
            number: '1',
            icon: Icons.local_taxi_outlined,
            title: l10n.pickupTaxi,
            description: widget.pickupLocation ?? l10n.pickupLocation,
          ),
          _buildVerticalConnector(context),
          _JourneySegment(
            number: '2',
            icon: Icons.directions_bus_outlined,
            title: l10n.interurbanTrip,
            description:
                '${widget.departureCity} → '
                '${widget.destinationCity}',
          ),
          _buildVerticalConnector(context),
          _JourneySegment(
            number: '3',
            icon: Icons.local_taxi_outlined,
            title: l10n.destinationTaxi,
            description: widget.finalDestination ?? l10n.finalDestination,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalConnector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 22,
          child: VerticalDivider(
            thickness: 2,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.priceSummary,
      child: Column(
        children: [
          _PriceRow(
            label: l10n.interurbanFareForPassengers(widget.passengers),
            value:
                '${_formatPrice(interurbanTotal)} '
                'FCFA',
          ),
          if (isDoorToDoor) ...[
            const SizedBox(height: 14),
            _PriceRow(
              label: l10n.pickupTaxiFareLabel,
              value:
                  '${_formatPrice(pickupTaxiFare)} '
                  'FCFA',
            ),
            const SizedBox(height: 14),
            _PriceRow(
              label: l10n.destinationTaxiFareLabel,
              value:
                  '${_formatPrice(destinationTaxiFare)} '
                  'FCFA',
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.total,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_formatPrice(totalPrice)} '
                'FCFA',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (isDoorToDoor) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      l10n.temporaryTaxiEstimate,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, AppLocalizations l10n) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: isDark ? 0.96 : 0.94),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.total,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    Text(
                      '${_formatPrice(totalPrice)} '
                      'FCFA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isCreatingBooking ? null : _continueToPayment,
                    icon: _isCreatingBooking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.payment_outlined),
                    label: Text(
                      _isCreatingBooking
                          ? 'Creating booking...'
                          : l10n.continueToPayment,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
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
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _TimeBlock({
    required this.label,
    required this.value,
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
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _JourneySegment extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _JourneySegment({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
