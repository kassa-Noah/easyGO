import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../bookings/models/booking.dart';
import '../../bookings/services/booking_service.dart';
import 'trip_details_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  static const String _upcoming = 'Upcoming';
  static const String _completed = 'Completed';
  static const String _cancelled = 'Cancelled';

  static const List<String> _filters = [_upcoming, _completed, _cancelled];

  final BookingService _bookingService = BookingService.instance;

  String _selectedFilter = _upcoming;

  bool _isLoading = true;
  String? _errorMessage;

  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<Booking> bookings = await _bookingService.getMyBookings();

      if (!mounted) {
        return;
      }

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  String _displayStatus(Booking booking) {
    if (booking.isCancelled) {
      return _cancelled;
    }

    // The backend's own status wins over the date guess. Without this a trip it
    // has already marked COMPLETED would sit under Upcoming whenever the trip's
    // scheduled date has not arrived yet, and the actions that belong to a
    // finished trip would look unavailable.
    if (booking.isCompleted) {
      return _completed;
    }

    final DateTime? arrivalTime = booking.arrivalTime;

    if (arrivalTime != null && arrivalTime.isBefore(DateTime.now().toUtc())) {
      return _completed;
    }

    return _upcoming;
  }

  List<Booking> get _filteredBookings {
    return _bookings.where((booking) {
      return _displayStatus(booking) == _selectedFilter;
    }).toList();
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

  Color _statusColor(String status) {
    switch (status) {
      case _upcoming:
        return AppColors.primary;

      case _completed:
        return AppColors.success;

      case _cancelled:
        return AppColors.error;

      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case _upcoming:
        return Icons.schedule_outlined;

      case _completed:
        return Icons.check_circle_outline;

      case _cancelled:
        return Icons.cancel_outlined;

      default:
        return Icons.confirmation_num_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.myTrips),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadBookings,
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
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
          child: Column(
            children: [
              _buildFilters(context, l10n),
              Expanded(child: _buildBody(context, l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState(context);
    }

    final List<Booking> bookings = _filteredBookings;

    if (bookings.isEmpty) {
      return _buildEmptyState(
        context,
        l10n,
        key: ValueKey('empty-$_selectedFilter'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: _buildBookingList(bookings, l10n, key: ValueKey(_selectedFilter)),
    );
  }

  Widget _buildFilters(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            borderRadius: 18,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final bool selected = filter == _selectedFilter;

                  final Color color = _statusColor(filter);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ChoiceChip(
                        avatar: Icon(
                          _statusIcon(filter),
                          size: 17,
                          color: selected
                              ? color
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        label: Text(l10n.tripStatusLabel(filter)),
                        selected: selected,
                        showCheckmark: false,
                        side: BorderSide.none,
                        backgroundColor: Colors.transparent,
                        selectedColor: Colors.transparent,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(
    List<Booking> bookings,
    AppLocalizations l10n, {
    required Key key,
  }) {
    return ListView.builder(
      key: key,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildBookingCard(context, bookings[index], l10n),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Booking booking,
    AppLocalizations l10n,
  ) {
    final String status = _displayStatus(booking);

    return GlassContainer(
      width: double.infinity,
      padding: EdgeInsets.zero,
      borderRadius: 20,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsScreen(booking: booking),
          ),
        );

        if (mounted) {
          await _loadBookings();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.directions_bus_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.agencyName.isEmpty
                            ? 'Transport agency'
                            : booking.agencyName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      // A SelectableText here would claim the card's semantics
                      // node for itself, and the card would stop announcing
                      // itself as something that can be opened.
                      Text(
                        booking.bookingReference,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _StatusBadge(
                  status: status,
                  label: l10n.tripStatusLabel(status),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _TripLocation(
                    time: _formatTime(booking.departureTime),
                    city: booking.originCity,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_bus_outlined,
                        size: 22,
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
                  child: _TripLocation(
                    time: _formatTime(booking.arrivalTime),
                    city: booking.destinationCity,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: [
                _MetadataItem(
                  icon: Icons.calendar_today_outlined,
                  value: _formatDate(booking.departureTime),
                ),
                _MetadataItem(icon: Icons.info_outline, value: booking.status),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InformationChip(
                  icon: booking.isDoorToDoor
                      ? Icons.home_outlined
                      : Icons.directions_bus_outlined,
                  label: booking.isDoorToDoor
                      ? 'Door-to-Door'
                      : 'Interurban Only',
                ),
                _InformationChip(
                  icon: Icons.person_outline,
                  label: l10n.passengerCount(booking.numberOfSeats),
                ),
                _InformationChip(
                  icon: Icons.luggage_outlined,
                  label: l10n.luggageItemCount(booking.luggageCount),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  l10n.amountLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '${_formatPrice(booking.totalAmount)} FCFA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 46,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load bookings',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'Unknown error.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _loadBookings,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n, {
    required Key key,
  }) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _statusIcon(_selectedFilter),
                  size: 42,
                  color: _statusColor(_selectedFilter),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.emptyTripsTitle(_selectedFilter),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.emptyTripsDescription(_selectedFilter),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TripLocation extends StatelessWidget {
  final String time;
  final String city;
  final bool alignEnd;

  const _TripLocation({
    required this.time,
    required this.city,
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
          time,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          city,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MetadataItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MetadataItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
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
        return AppColors.primary;

      case 'Completed':
        return AppColors.success;

      case 'Cancelled':
        return AppColors.error;

      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.10),
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

class _InformationChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InformationChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
