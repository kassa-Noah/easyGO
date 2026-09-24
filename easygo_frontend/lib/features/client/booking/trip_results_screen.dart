import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../trips/models/trip.dart';
import '../../trips/services/trip_service.dart';
import 'booking_review_screen.dart';

class TripResultsScreen extends StatefulWidget {
  final Map<String, dynamic> agency;
  final String bookingMode;

  final String departureCity;
  final String destinationCity;

  final String? pickupLocation;
  final String? finalDestination;

  final DateTime travelDate;

  final int passengers;
  final int luggage;

  const TripResultsScreen({
    super.key,
    required this.agency,
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
  State<TripResultsScreen> createState() => _TripResultsScreenState();
}

class _TripResultsScreenState extends State<TripResultsScreen> {
  final TripService _tripService = TripService.instance;

  List<Trip> _trips = <Trip>[];

  bool _isLoading = true;
  String? _errorMessage;

  bool get isDoorToDoor => widget.bookingMode == 'door_to_door';

  @override
  void initState() {
    super.initState();

    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Trip> results = await _tripService.searchTrips(
        originCity: _normalizeCityForApi(widget.departureCity),
        destinationCity: _normalizeCityForApi(widget.destinationCity),
        travelDate: widget.travelDate,
      );

      final String selectedAgencyId = widget.agency['id']?.toString() ?? '';

      final List<Trip> agencyTrips = selectedAgencyId.isEmpty
          ? results
          : results.where((trip) => trip.agencyId == selectedAgencyId).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _trips = agencyTrips;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _trips = <Trip>[];
        _isLoading = false;
        _errorMessage = _cleanErrorMessage(error);
      });
    }
  }

  String _normalizeCityForApi(String city) {
    return city
        .trim()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('É', 'E')
        .replaceAll('È', 'E')
        .replaceAll('Ê', 'E')
        .replaceAll('Ë', 'E');
  }

  String _cleanErrorMessage(Object error) {
    final String message = error.toString();

    if (message.startsWith('ApiException(')) {
      final int separatorIndex = message.indexOf(': ');

      if (separatorIndex != -1 && message.endsWith(')')) {
        return message.substring(separatorIndex + 2, message.length - 1);
      }
    }

    return message;
  }

  String _formattedDate() {
    final String day = widget.travelDate.day.toString().padLeft(2, '0');

    final String month = widget.travelDate.month.toString().padLeft(2, '0');

    return '$day/$month/'
        '${widget.travelDate.year}';
  }

  String _formatPrice(double price) {
    final int wholePrice = price.round();

    return wholePrice.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String _formatTime(DateTime value) {
    final DateTime local = value.toLocal();

    final String hour = local.hour.toString().padLeft(2, '0');

    final String minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatDuration(Trip trip) {
    final int minutes =
        trip.estimatedDurationMinutes ?? trip.duration.inMinutes;

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

  void _selectTrip(BuildContext context, Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingReviewScreen(
          agency: widget.agency,
          trip: trip,
          bookingMode: widget.bookingMode,
          departureCity: widget.departureCity,
          destinationCity: widget.destinationCity,
          pickupLocation: widget.pickupLocation,
          finalDestination: widget.finalDestination,
          travelDate: widget.travelDate,
          passengers: widget.passengers,
          luggage: widget.luggage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.availableTrips)),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _buildSearchSummary(context, l10n),
                  ),
                  Expanded(child: _buildContent(context, l10n)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return RefreshIndicator(
        onRefresh: _loadTrips,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 70),
            _StatusCard(
              icon: Icons.error_outline,
              title: 'Unable to load trips',
              message: _errorMessage!,
              buttonLabel: 'Try again',
              onPressed: _loadTrips,
            ),
          ],
        ),
      );
    }

    if (_trips.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTrips,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 70),
            _StatusCard(
              icon: Icons.directions_bus_outlined,
              title: 'No available trips',
              message:
                  'No trip is currently available for '
                  '${widget.departureCity} → '
                  '${widget.destinationCity} on '
                  '${_formattedDate()} for the selected agency.',
              buttonLabel: 'Refresh',
              onPressed: _loadTrips,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _trips.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final Trip trip = _trips[index];

          return _TripCard(
            trip: trip,
            passengers: widget.passengers,
            formattedPrice: _formatPrice(trip.price),
            departureTime: _formatTime(trip.departureTime),
            arrivalTime: _formatTime(trip.arrivalTime),
            duration: _formatDuration(trip),
            onSelect: () {
              _selectTrip(context, trip);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchSummary(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_bus_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.agency['name']?.toString() ?? l10n.transportAgency,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CityDisplay(
                  label: l10n.from,
                  city: widget.departureCity,
                  alignment: CrossAxisAlignment.start,
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _CityDisplay(
                  label: l10n.to,
                  city: widget.destinationCity,
                  alignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              _SummaryItem(
                icon: Icons.calendar_today_outlined,
                text: _formattedDate(),
              ),
              _SummaryItem(
                icon: Icons.people_outline,
                text: l10n.passengerCount(widget.passengers),
              ),
              _SummaryItem(
                icon: Icons.luggage_outlined,
                text: l10n.luggageCount(widget.luggage),
              ),
            ],
          ),
          if (isDoorToDoor) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_taxi_outlined,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.doorToDoorJourney,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
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
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final int passengers;
  final String formattedPrice;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final VoidCallback onSelect;

  const _TripCard({
    required this.trip,
    required this.passengers,
    required this.formattedPrice,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool enoughSeats = trip.availableSeats >= passengers;

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trip.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                enoughSeats
                    ? Icons.event_seat_outlined
                    : Icons.warning_amber_outlined,
                size: 17,
                color: enoughSeats ? AppColors.secondary : AppColors.error,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  enoughSeats
                      ? l10n.seatsLeft(trip.availableSeats)
                      : l10n.insufficientSeats,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    color: enoughSeats ? AppColors.secondary : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      departureTime,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.departure,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      duration,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 5),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            Icons.directions_bus,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      arrivalTime,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.arrival,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.directions_bus_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  trip.vehicleDescription,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
          if (trip.originBranchName.isNotEmpty ||
              trip.destinationBranchName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '${trip.originBranchName} → '
                    '${trip.destinationBranchName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 390;

              final Widget fare = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.interurbanFare,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$formattedPrice FCFA',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (passengers > 1)
                    Text(
                      l10n.perPassenger,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                ],
              );

              final Widget button = SizedBox(
                width: compact ? double.infinity : 135,
                child: ElevatedButton(
                  onPressed: enoughSeats ? onSelect : null,
                  child: Text(
                    enoughSeats ? l10n.select : l10n.insufficientSeats,
                    textAlign: TextAlign.center,
                  ),
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [fare, const SizedBox(height: 14), button],
                );
              }

              return Row(
                children: [
                  Expanded(child: fare),
                  const SizedBox(width: 16),
                  button,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 20,
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.refresh),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _CityDisplay extends StatelessWidget {
  final String label;
  final String city;
  final CrossAxisAlignment alignment;

  const _CityDisplay({
    required this.label,
    required this.city,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          city,
          textAlign: alignment == CrossAxisAlignment.end
              ? TextAlign.end
              : TextAlign.start,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
