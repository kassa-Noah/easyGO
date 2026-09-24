import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'booking_confirmation_screen.dart';

class PaymentScreen
    extends StatefulWidget {
  final Map<String, dynamic> agency;
  final Map<String, dynamic> trip;

  final String bookingMode;
  final String departureCity;
  final String destinationCity;

  final String? pickupLocation;
  final String? finalDestination;

  final DateTime travelDate;

  final int passengers;
  final int luggage;
  final int totalAmount;

  const PaymentScreen({
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
    this.pickupLocation,
    this.finalDestination,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _phoneController =
      TextEditingController();

  String? _selectedMethod;
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();

    super.dispose();
  }

  String _formatPrice(
    int value,
  ) {
    return value
        .toString()
        .replaceAllMapped(
          RegExp(
            r'(?=(\d{3})+(?!\d))',
          ),
          (match) => ',',
        );
  }

  Future<void> _processPayment() async {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .selectPaymentMethodError,
          ),
        ),
      );

      return;
    }

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Frontend prototype simulation only.
    // Production payment verification will be
    // performed by the backend/payment provider.
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookingConfirmationScreen(
          agency: widget.agency,
          trip: widget.trip,
          bookingMode:
              widget.bookingMode,
          departureCity:
              widget.departureCity,
          destinationCity:
              widget.destinationCity,
          pickupLocation:
              widget.pickupLocation,
          finalDestination:
              widget.finalDestination,
          travelDate:
              widget.travelDate,
          passengers:
              widget.passengers,
          luggage: widget.luggage,
          totalAmount:
              widget.totalAmount,
          paymentMethod:
              _selectedMethod!,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.payment,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end: Alignment
                      .bottomRight,
                  colors: [
                    Color(0xFF09111F),
                    Color(0xFF0D1B2A),
                    Color(0xFF10253B),
                  ],
                )
              : const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end: Alignment
                      .bottomRight,
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
                child:
                    SingleChildScrollView(
                  padding:
                      const EdgeInsets
                          .all(20),
                  child: Center(
                    child:
                        ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 720,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            _buildAmountCard(
                              context,
                              l10n,
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            Text(
                              l10n
                                  .selectPaymentMethod,
                              style:
                                  Theme.of(
                                context,
                              )
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              l10n
                                  .paymentSecurityInformation,
                              style:
                                  Theme.of(
                                context,
                              )
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        height:
                                            1.5,
                                      ),
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            _PaymentMethodCard(
                              title: l10n
                                  .mtnMobileMoney,
                              subtitle: l10n
                                  .mtnMobileMoneyDescription,
                              icon: Icons
                                  .phone_android,
                              selected:
                                  _selectedMethod ==
                                      'MTN Mobile Money',
                              onTap: () {
                                if (_isProcessing) {
                                  return;
                                }

                                setState(() {
                                  _selectedMethod =
                                      'MTN Mobile Money';
                                });
                              },
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _PaymentMethodCard(
                              title: l10n
                                  .orangeMoney,
                              subtitle: l10n
                                  .orangeMoneyDescription,
                              icon: Icons
                                  .account_balance_wallet_outlined,
                              selected:
                                  _selectedMethod ==
                                      'Orange Money',
                              onTap: () {
                                if (_isProcessing) {
                                  return;
                                }

                                setState(() {
                                  _selectedMethod =
                                      'Orange Money';
                                });
                              },
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            Text(
                              l10n
                                  .paymentPhoneNumber,
                              style:
                                  Theme.of(
                                context,
                              )
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            TextFormField(
                              controller:
                                  _phoneController,
                              keyboardType:
                                  TextInputType
                                      .phone,
                              enabled:
                                  !_isProcessing,
                              decoration:
                                  InputDecoration(
                                hintText: l10n
                                    .paymentPhoneHint,
                                prefixIcon:
                                    const Icon(
                                  Icons
                                      .phone_outlined,
                                ),
                              ),
                              validator:
                                  (value) {
                                if (value ==
                                        null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return l10n
                                      .paymentPhoneRequired;
                                }

                                final String
                                    digits =
                                    value
                                        .replaceAll(
                                  RegExp(
                                    r'\D',
                                  ),
                                  '',
                                );

                                if (digits
                                        .length <
                                    9) {
                                  return l10n
                                      .invalidPhoneNumber;
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 24,
                            ),

                            GlassContainer(
                              padding:
                                  const EdgeInsets
                                      .all(
                                15,
                              ),
                              borderRadius:
                                  15,
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration:
                                        BoxDecoration(
                                      color: AppColors
                                          .primary
                                          .withValues(
                                        alpha:
                                            0.10,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        10,
                                      ),
                                    ),
                                    child:
                                        const Icon(
                                      Icons
                                          .info_outline,
                                      size: 20,
                                      color:
                                          AppColors
                                              .primary,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Expanded(
                                    child: Text(
                                      l10n
                                          .prototypePaymentInformation,
                                      style:
                                          Theme.of(
                                        context,
                                      )
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                height:
                                                    1.5,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              _buildBottomSection(
                context,
                l10n,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withValues(
              alpha: 0.20,
            ),
            blurRadius: 24,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.14,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .account_balance_wallet_outlined,
              color: Colors.white,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            l10n.amountToPay,
            style:
                const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${_formatPrice(widget.totalAmount)} FCFA',
              style:
                  const TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            '${widget.departureCity} → '
            '${widget.destinationCity}',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withValues(
              alpha:
                  isDark ? 0.96 : 0.94,
            ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context)
                .dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 720,
            ),
            child: SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                onPressed:
                    _isProcessing
                        ? null
                        : _processPayment,
                child:
                    AnimatedSwitcher(
                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),
                  child: _isProcessing
                      ? Row(
                          key: const ValueKey(
                            'processing',
                          ),
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2.4,
                                color:
                                    Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Flexible(
                              child: Text(
                                l10n
                                    .processingPayment,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      15,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey(
                            'payment',
                          ),
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            const Icon(
                              Icons
                                  .lock_outline,
                              size: 19,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: Text(
                                l10n.payAmount(
                                  _formatPrice(
                                    widget
                                        .totalAmount,
                                  ),
                                ),
                                textAlign:
                                    TextAlign
                                        .center,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ),
                          ],
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

class _PaymentMethodCard
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 17,
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 220,
        ),
        curve: Curves.easeOut,
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            17,
          ),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.transparent,
            width:
                selected ? 2 : 1,
          ),
          color: selected
              ? AppColors.primary
                  .withValues(
                alpha: 0.06,
              )
              : Colors.transparent,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 220,
              ),
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(
                color: AppColors
                    .primary
                    .withValues(
                  alpha: selected
                      ? 0.16
                      : 0.09,
                ),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: Icon(
                icon,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    subtitle,
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            AnimatedSwitcher(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              child: Icon(
                selected
                    ? Icons
                        .radio_button_checked
                    : Icons
                        .radio_button_off,
                key:
                    ValueKey<bool>(
                  selected,
                ),
                color: selected
                    ? AppColors.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}