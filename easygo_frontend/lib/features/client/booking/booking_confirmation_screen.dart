import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../home/main_screen.dart';
import 'digital_ticket_screen.dart';

class BookingConfirmationScreen
    extends StatelessWidget {
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
  final String paymentMethod;

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
    this.pickupLocation,
    this.finalDestination,
  });

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

  @override
  Widget build(
    BuildContext context,
  ) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
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
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 720,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 28,
                      ),

                      _buildSuccessIcon(),

                      const SizedBox(
                        height: 24,
                      ),

                      Text(
                        l10n
                            .paymentSuccessful,
                        textAlign:
                            TextAlign.center,
                        style:
                            Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 520,
                        ),
                        child: Text(
                          l10n
                              .paymentSuccessfulDescription,
                          textAlign:
                              TextAlign.center,
                          style:
                              Theme.of(
                            context,
                          )
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    height:
                                        1.5,
                                  ),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      GlassContainer(
                        padding:
                            const EdgeInsets
                                .all(18),
                        borderRadius: 18,
                        child: Column(
                          children: [
                            _ConfirmationRow(
                              label:
                                  l10n.agency,
                              value: agency[
                                          'name']
                                      ?.toString() ??
                                  l10n
                                      .transportAgency,
                            ),

                            const Divider(
                              height: 28,
                            ),

                            _ConfirmationRow(
                              label:
                                  l10n.route,
                              value:
                                  '$departureCity → $destinationCity',
                            ),

                            const Divider(
                              height: 28,
                            ),

                            _ConfirmationRow(
                              label: l10n
                                  .departure,
                              value: trip[
                                          'departureTime']
                                      ?.toString() ??
                                  l10n
                                      .notAvailable,
                            ),

                            const Divider(
                              height: 28,
                            ),

                            _ConfirmationRow(
                              label: l10n
                                  .paymentMethod,
                              value:
                                  paymentMethod,
                            ),

                            const Divider(
                              height: 28,
                            ),

                            _ConfirmationRow(
                              label: l10n
                                  .amountPaid,
                              value:
                                  '${_formatPrice(totalAmount)} FCFA',
                              emphasize:
                                  true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      GlassContainer(
                        padding:
                            const EdgeInsets
                                .all(15),
                        borderRadius: 15,
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
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
                                  11,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .confirmation_num_outlined,
                                size: 21,
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
                                    .digitalTicketReferenceInformation,
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
                        height: 30,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DigitalTicketScreen(
                                  agency:
                                      agency,
                                  trip: trip,
                                  bookingMode:
                                      bookingMode,
                                  departureCity:
                                      departureCity,
                                  destinationCity:
                                      destinationCity,
                                  pickupLocation:
                                      pickupLocation,
                                  finalDestination:
                                      finalDestination,
                                  travelDate:
                                      travelDate,
                                  passengers:
                                      passengers,
                                  luggage:
                                      luggage,
                                  totalAmount:
                                      totalAmount,
                                  paymentMethod:
                                      paymentMethod,

                                  // DEMO ONLY.
                                  // The backend
                                  // will generate
                                  // these references
                                  // in production.
                                  bookingReference:
                                      'DEMO-BOOKING-001',
                                  ticketReference:
                                      'DEMO-TICKET-001',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons
                                .confirmation_num_outlined,
                          ),
                          label: Text(
                            l10n
                                .viewDigitalTicket,
                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            TextButton.icon(
                          onPressed: () {
                            Navigator
                                .pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const ClientMainScreen(),
                              ),
                              (route) =>
                                  false,
                            );
                          },
                          icon: const Icon(
                            Icons
                                .home_outlined,
                          ),
                          label: Text(
                            l10n
                                .returnToHome,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
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

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0.75,
        end: 1,
      ),
      duration:
          const Duration(
        milliseconds: 500,
      ),
      curve: Curves.easeOutBack,
      builder: (
        context,
        value,
        child,
      ) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.success
                  .withValues(
                alpha: 0.25,
              ),
              blurRadius: 30,
              spreadRadius: 3,
            ),
          ],
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 58,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ConfirmationRow
    extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _ConfirmationRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style:
                Theme.of(context)
                    .textTheme
                    .bodySmall,
          ),
        ),

        const SizedBox(
          width: 18,
        ),

        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.end,
            style:
                Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontSize:
                          emphasize
                              ? 16
                              : null,
                      fontWeight:
                          emphasize
                              ? FontWeight
                                  .bold
                              : FontWeight
                                  .w600,
                      color:
                          emphasize
                              ? AppColors
                                  .primary
                              : null,
                    ),
          ),
        ),
      ],
    );
  }
}