import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../trips/models/trip.dart';
import '../home/main_screen.dart';

class DigitalTicketScreen extends StatelessWidget {
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

  // Issued by the backend: the booking reference comes from the stored booking
  // and the ticket reference from the ticket created for it.
  final String bookingReference;
  final String ticketReference;

  const DigitalTicketScreen({
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
    required this.ticketReference,
    this.pickupLocation,
    this.finalDestination,
  });

  bool get isDoorToDoor => bookingMode == 'door_to_door';

  String _formattedDate() {
    return '${travelDate.day.toString().padLeft(2, '0')}/'
        '${travelDate.month.toString().padLeft(2, '0')}/'
        '${travelDate.year}';
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.digitalTicket)),
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
                      _buildTicket(context, l10n),
                      const SizedBox(height: 20),
                      if (isDoorToDoor)
                        _buildDoorToDoorInformation(context, l10n),
                      if (isDoorToDoor) const SizedBox(height: 20),
                      _buildImportantInformation(context, l10n),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.ticketDownloadPending),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_outlined),
                          label: Text(
                            l10n.downloadTicket,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ClientMainScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.home_outlined),
                          label: Text(l10n.returnToHome),
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

  Widget _buildTicket(BuildContext context, AppLocalizations l10n) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: isDark ? 0.90 : 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            _buildTicketHeader(context, l10n),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildRoute(context, l10n),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _TicketField(
                          label: l10n.date,
                          value: _formattedDate(),
                        ),
                      ),
                      Expanded(
                        child: _TicketField(
                          label: l10n.departure.toUpperCase(),
                          value: _formatTime(trip.departureTime),
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _TicketField(
                          label: l10n.arrival.toUpperCase(),
                          value: _formatTime(trip.arrivalTime),
                        ),
                      ),
                      Expanded(
                        child: _TicketField(
                          label: 'STATUS',
                          value: trip.status,
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _TicketField(
                          label: l10n.passengersLabel,
                          value: '$passengers',
                        ),
                      ),
                      Expanded(
                        child: _TicketField(
                          label: l10n.luggageLabel,
                          value: '$luggage',
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _TicketField(
                    label: 'VEHICLE',
                    value: trip.vehicleDescription,
                  ),
                  const SizedBox(height: 22),
                  const Divider(),
                  const SizedBox(height: 18),
                  _buildReferences(context, l10n),
                  const SizedBox(height: 22),
                  _buildQrPlaceholder(context, l10n),
                  const SizedBox(height: 18),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_formatPrice(totalAmount)} FCFA',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.paidVia(paymentMethod),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_num_outlined,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'easyGO',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isDoorToDoor ? l10n.doorToDoorTicket : l10n.interurbanTicket,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.paid,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoute(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          agency['name']?.toString() ?? l10n.transportAgency,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.from,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    departureCity,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.to, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 5),
                  Text(
                    destinationCity,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReferences(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _ReferenceRow(label: l10n.bookingReference, value: bookingReference),
          const SizedBox(height: 10),
          _ReferenceRow(label: l10n.ticketReference, value: ticketReference),
        ],
      ),
    );
  }

  Widget _buildQrPlaceholder(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
          ),
          child: const Icon(
            Icons.qr_code_2_rounded,
            size: 105,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.presentTicketForVerification,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDoorToDoorInformation(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 17,
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
          _JourneyLine(
            icon: Icons.home_outlined,
            title: l10n.pickup,
            value: pickupLocation ?? l10n.pickupLocationFallback,
          ),
          const SizedBox(height: 16),
          _JourneyLine(
            icon: Icons.directions_bus_outlined,
            title: l10n.interurban,
            value:
                '$departureCity → '
                '$destinationCity',
          ),
          const SizedBox(height: 16),
          _JourneyLine(
            icon: Icons.location_on_outlined,
            title: l10n.finalDestination,
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

  Widget _buildImportantInformation(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.importantTicketInformation,
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

class _TicketField extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _TicketField({
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
          label,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReferenceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: SelectableText(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _JourneyLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _JourneyLine({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
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
