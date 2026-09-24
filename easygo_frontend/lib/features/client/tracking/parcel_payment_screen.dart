import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'parcel_confirmation_screen.dart';

class ParcelPaymentScreen extends StatefulWidget {
  final String recipientName;
  final String recipientPhone;
  final String departureCity;
  final String destinationCity;
  final String description;
  final double weight;

  final String agencyName;
  final int amount;

  const ParcelPaymentScreen({
    super.key,
    required this.recipientName,
    required this.recipientPhone,
    required this.departureCity,
    required this.destinationCity,
    required this.description,
    required this.weight,
    required this.agencyName,
    required this.amount,
  });

  @override
  State<ParcelPaymentScreen> createState() => _ParcelPaymentScreenState();
}

class _ParcelPaymentScreenState extends State<ParcelPaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();

  String? _selectedMethod;

  bool _isProcessing = false;

  /*
   * Canonical payment method values.
   *
   * These values remain unchanged regardless
   * of the selected application language.
   */
  final List<String> _paymentMethods = ['MTN Mobile Money', 'Orange Money'];

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

  String _paymentMethodLabel(AppLocalizations l10n, String method) {
    switch (method) {
      case 'MTN Mobile Money':
        return l10n.mtnMobileMoney;

      case 'Orange Money':
        return l10n.orangeMoney;

      default:
        return method;
    }
  }

  Future<void> _processPayment() async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectPaymentMethodError)));

      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    /*
     * FRONTEND PROTOTYPE ONLY.
     *
     * This delay simulates communication
     * with a payment service.
     *
     * During backend integration:
     *
     * Flutter
     *    ↓
     * easyGO Backend
     *    ↓
     * Payment Provider
     *    ↓
     * Verified Payment Result
     *
     * Flutter must not independently
     * authorize a real payment.
     */
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelConfirmationScreen(
          recipientName: widget.recipientName,
          recipientPhone: widget.recipientPhone,
          departureCity: widget.departureCity,
          destinationCity: widget.destinationCity,
          description: widget.description,
          weight: widget.weight,
          agencyName: widget.agencyName,
          amount: widget.amount,
          paymentMethod: _selectedMethod!,
          trackingReference: 'PAR-DEMO-001',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.parcelPayment)),
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildAmountCard(context, l10n),

                              const SizedBox(height: 24),

                              Text(
                                l10n.paymentMethod,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 15),

                              ..._paymentMethods.map(
                                (method) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _PaymentMethodCard(
                                    title: _paymentMethodLabel(l10n, method),
                                    selected: _selectedMethod == method,
                                    onTap: _isProcessing
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedMethod = method;
                                            });
                                          },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              GlassContainer(
                                padding: const EdgeInsets.all(16),
                                borderRadius: 16,
                                child: TextFormField(
                                  controller: _phoneController,
                                  enabled: !_isProcessing,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    if (!_isProcessing) {
                                      _processPayment();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: l10n.paymentPhoneNumber,
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n.enterPaymentPhoneNumber;
                                    }

                                    final String digits = value.replaceAll(
                                      RegExp(r'\D'),
                                      '',
                                    );

                                    if (digits.length < 9) {
                                      return l10n.enterValidPaymentPhoneNumber;
                                    }

                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),

                              _buildPrototypeNotice(context, l10n),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildBottomSection(context, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
        children: [
          Text(
            l10n.amountToPay,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),

          const SizedBox(height: 8),

          Text(
            '${_formatPrice(widget.amount)} FCFA',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.business_outlined,
                      size: 17,
                      color: Colors.white70,
                    ),

                    const SizedBox(width: 7),

                    Flexible(
                      child: Text(
                        widget.agencyName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  '${widget.departureCity} → '
                  '${widget.destinationCity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrototypeNotice(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.all(15),
      borderRadius: 14,
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

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              l10n.parcelPrototypePaymentNotice,
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

    final String formattedAmount = _formatPrice(widget.amount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: isDark ? 0.92 : 0.96),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _isProcessing
                      ? const SizedBox(
                          key: ValueKey('processing'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.payParcelAmount(formattedAmount),
                          key: const ValueKey('pay'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const _PaymentMethodCard({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 15,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 22,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                key: ValueKey(selected),
                color: selected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
