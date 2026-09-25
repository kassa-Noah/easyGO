import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../bookings/models/verified_ticket.dart';
import '../../bookings/services/ticket_service.dart';

/// Checks a ticket number at boarding.
///
/// The traveller's ticket carries a code; this is the other end of it. Staff
/// type or paste the ticket number, which is printed openly on the ticket so it
/// can be read when a code will not scan.
///
/// Verification is scoped by the backend, not here: a staff member of one
/// agency cannot check another agency's tickets, and the screen reports that
/// refusal rather than hiding the field.
class TicketVerificationScreen extends StatefulWidget {
  const TicketVerificationScreen({super.key});

  @override
  State<TicketVerificationScreen> createState() =>
      _TicketVerificationScreenState();
}

class _TicketVerificationScreenState extends State<TicketVerificationScreen> {
  final TextEditingController _ticketController = TextEditingController();

  final TicketService _tickets = TicketService.instance;

  VerifiedTicket? _result;

  bool _isChecking = false;

  /// Set when the number was rejected, so the screen can say why.
  String? _errorMessage;

  /// The number the current result belongs to, shown above it.
  String _checkedNumber = '';

  @override
  void initState() {
    super.initState();

    // The keyboard should open on the field, since checking a ticket is the
    // only thing this screen does.
    _ticketController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _ticketController.removeListener(_onChanged);
    _ticketController.dispose();
    super.dispose();
  }

  void _onChanged() {
    // The previous result no longer describes what is in the field.
    if (_result != null || _errorMessage != null) {
      setState(() {
        _result = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _verify() async {
    final String number = _ticketController.text.trim();

    if (number.isEmpty || _isChecking) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isChecking = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      final VerifiedTicket ticket = await _tickets.verifyTicket(number);

      if (!mounted) {
        return;
      }

      setState(() {
        _result = ticket;
        _checkedNumber = number;
        _isChecking = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.statusCode == 404
            ? 'No ticket was found with that number.'
            : error.message;
        _checkedNumber = number;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyTicket)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  _buildEntryCard(context),
                  if (_isChecking) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ] else if (_result != null) ...[
                    const SizedBox(height: 20),
                    _buildResultCard(context, _result!),
                  ] else if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    _buildErrorCard(context),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).verifyTicketDescription,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _ticketController,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _verify(),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).ticketReference,
              hintText: 'TKT-XXXXXXXX-XXXXXX',
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isChecking ? null : _verify,
              icon: const Icon(Icons.search_outlined),
              label: Text(AppLocalizations.of(context).verifyTicket),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, VerifiedTicket ticket) {
    final Color statusColor = ticket.isUsable
        ? AppColors.secondary
        : AppColors.warning;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ticket.isUsable
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: statusColor,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.statusLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _checkedNumber,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Passenger',
            value: ticket.passengerName.isEmpty ? '—' : ticket.passengerName,
          ),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: ticket.passengerPhone?.isNotEmpty == true
                ? ticket.passengerPhone!
                : '—',
          ),
          _DetailRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Booking',
            value: ticket.bookingReference.isEmpty
                ? '—'
                : ticket.bookingReference,
          ),
          _DetailRow(
            icon: Icons.route_outlined,
            label: 'Route',
            value: [ticket.originCity, ticket.destinationCity]
                .where((city) => city.isNotEmpty)
                .join(' → '),
          ),
          _DetailRow(
            icon: Icons.schedule_outlined,
            label: 'Departure',
            value: _formatDateTime(ticket.departureTime),
          ),
          _DetailRow(
            icon: Icons.directions_bus_outlined,
            label: 'Vehicle',
            value: ticket.vehicleDescription.isEmpty
                ? '—'
                : ticket.vehicleDescription,
          ),
          _DetailRow(
            icon: Icons.business_outlined,
            label: 'Agency',
            value: ticket.agencyName.isEmpty ? '—' : ticket.agencyName,
          ),
          if (ticket.isUsed) ...[
            const SizedBox(height: 8),
            Text(
              'This ticket was already taken on '
              '${_formatDateTime(ticket.usedAt)}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        children: [
          const Icon(
            Icons.report_gmailerrorred_outlined,
            color: AppColors.error,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '—';
    }

    final DateTime local = value.toLocal();

    final String day = local.day.toString().padLeft(2, '0');
    final String month = local.month.toString().padLeft(2, '0');
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/${local.year} $hour:$minute';
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textLight),
          const SizedBox(width: 11),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
