import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../bookings/models/booking.dart';
import '../../bookings/services/ticket_service.dart';
import '../../payments/models/payment.dart';
import '../../payments/services/payment_service.dart';
import '../../trips/models/trip.dart';
import 'booking_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> agency;
  final Trip trip;
  final Booking booking;

  final String bookingMode;
  final String departureCity;
  final String destinationCity;

  final String? pickupLocation;
  final String? finalDestination;

  final DateTime travelDate;

  final int passengers;
  final int luggage;

  // This remains a frontend display amount
  // until the payment API is integrated.
  final int displayTotalAmount;

  const PaymentScreen({
    super.key,
    required this.agency,
    required this.trip,
    required this.booking,
    required this.bookingMode,
    required this.departureCity,
    required this.destinationCity,
    required this.travelDate,
    required this.passengers,
    required this.luggage,
    required this.displayTotalAmount,
    this.pickupLocation,
    this.finalDestination,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService.instance;

  final TicketService _ticketService = TicketService.instance;

  String? _selectedPaymentMethod;

  bool _isProcessing = false;

  final TextEditingController _phoneController = TextEditingController();

  final List<String> _paymentMethods = const [
    'MTN Mobile Money',
    'Orange Money',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  bool _isValidPhoneNumber(String value) {
    final String phone = value.replaceAll(' ', '').trim();

    return RegExp(r'^[0-9]{9}$').hasMatch(phone);
  }

  Future<void> _processPayment(AppLocalizations l10n) async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );

      return;
    }

    if (!_isValidPhoneNumber(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid 9-digit '
            'mobile money number.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // The mobile money providers are not integrated for the
      // academic prototype, so the MVP settles payments through
      // the backend's deterministic SIMULATED adapter.
      final Payment pendingPayment = await _paymentService.initiatePayment(
        bookingId: widget.booking.id,
      );

      // The backend only confirms the booking when the payment
      // reaches SUCCESSFUL. A FAILED result leaves it PENDING.
      final Payment settledPayment = await _paymentService.simulatePayment(
        paymentId: pendingPayment.id,
        result: 'SUCCESSFUL',
      );

      if (!mounted) {
        return;
      }

      if (!settledPayment.isSuccessful) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment was not successful. '
              'Your booking has not been confirmed.',
            ),
          ),
        );

        return;
      }

      // The booking is confirmed at this point, so the digital
      // ticket required by the MVP is issued before moving on.
      final String ticketNumber = await _resolveTicketNumber();

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            agency: widget.agency,
            trip: widget.trip,
            bookingMode: widget.bookingMode,
            departureCity: widget.departureCity,
            destinationCity: widget.destinationCity,
            pickupLocation: widget.pickupLocation,
            finalDestination: widget.finalDestination,
            travelDate: widget.travelDate,
            passengers: widget.passengers,
            luggage: widget.luggage,
            totalAmount: settledPayment.amount.round(),
            paymentMethod: _selectedPaymentMethod!,
            bookingReference: widget.booking.bookingReference,
            ticketNumber: ticketNumber,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Only one ticket may exist per booking. The backend answers
  /// with 409 when a ticket was already issued, in which case the
  /// existing ticket is retrieved instead of a new one being made.
  Future<String> _resolveTicketNumber() async {
    try {
      final BookingTicket ticket = await _ticketService.generateTicket(
        widget.booking.id,
      );

      return ticket.ticketNumber;
    } on ApiException catch (error) {
      if (error.statusCode != 409) {
        rethrow;
      }

      final BookingTicket ticket = await _ticketService.getTicketByBookingId(
        widget.booking.id,
      );

      return ticket.ticketNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(
                        children: [
                          _buildAmountCard(context),
                          const SizedBox(height: 20),
                          _buildBookingCard(context),
                          const SizedBox(height: 20),
                          _buildPaymentMethodCard(context),
                          const SizedBox(height: 20),
                          _buildPhoneCard(context),
                          const SizedBox(height: 20),
                          _buildSecurityCard(context),
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

  Widget _buildAmountCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(22),
      borderRadius: 20,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.payment_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text('Amount to pay', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${_formatPrice(widget.displayTotalAmount)} '
              'FCFA',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.departureCity} → '
            '${widget.destinationCity}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            widget.agency['name']?.toString() ?? 'Transport Agency',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking created',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Your booking has been created '
            'in easyGO. Complete payment to '
            'continue the reservation process.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _PaymentInfoRow(
            label: 'Booking reference',
            value: widget.booking.bookingReference,
          ),
          const Divider(height: 24),
          _PaymentInfoRow(
            label: 'Booking status',
            value: widget.booking.status,
          ),
          const Divider(height: 24),
          _PaymentInfoRow(
            label: 'Reserved seats',
            value: widget.booking.numberOfSeats.toString(),
          ),
          if (widget.booking.isDoorToDoor) ...[
            const Divider(height: 24),
            const _PaymentInfoRow(
              label: 'Door-to-door journey',
              value: 'Created',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment method',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose the mobile money service '
            'you want to use.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          RadioGroup<String>(
            groupValue: _selectedPaymentMethod,
            onChanged: (String? value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedPaymentMethod = value;
              });
            },
            child: Column(
              children: _paymentMethods
                  .map((method) => _PaymentMethodOption(method: method))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobile money number',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the phone number that '
            'will be used for the payment.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 9,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '6XXXXXXXX',
              prefixIcon: Icon(Icons.phone_outlined),
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 21,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This payment is currently '
              'simulated for the easyGO '
              'demonstration. The real '
              'backend payment endpoint '
              'will be connected in the '
              'next integration step.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
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
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Total amount')),
                    Text(
                      '${_formatPrice(widget.displayTotalAmount)} '
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
                    onPressed: _isProcessing
                        ? null
                        : () => _processPayment(l10n),
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_outline),
                    label: Text(
                      _isProcessing
                          ? 'Processing...'
                          : 'Pay '
                                '${_formatPrice(widget.displayTotalAmount)} '
                                'FCFA',
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

class _PaymentInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _PaymentInfoRow({required this.label, required this.value});

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
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String method;

  const _PaymentMethodOption({required this.method});

  @override
  Widget build(BuildContext context) {
    final bool isMtn = method == 'MTN Mobile Money';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          RadioGroup.maybeOf<String>(context)?.onChanged(method);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isMtn
                      ? Icons.phone_android
                      : Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  method,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Radio<String>(value: method),
            ],
          ),
        ),
      ),
    );
  }
}
