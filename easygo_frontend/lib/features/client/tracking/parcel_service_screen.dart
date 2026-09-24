import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'parcel_payment_screen.dart';

class ParcelServiceScreen
    extends StatefulWidget {
  final String recipientName;
  final String recipientPhone;
  final String departureCity;
  final String destinationCity;
  final String description;
  final double weight;

  const ParcelServiceScreen({
    super.key,
    required this.recipientName,
    required this.recipientPhone,
    required this.departureCity,
    required this.destinationCity,
    required this.description,
    required this.weight,
  });

  @override
  State<ParcelServiceScreen> createState() =>
      _ParcelServiceScreenState();
}

class _ParcelServiceScreenState
    extends State<ParcelServiceScreen> {
  String? _selectedServiceId;

  /*
   * FRONTEND DEMONSTRATION DATA ONLY.
   *
   * In production, the easyGO backend will
   * determine the agencies eligible for the
   * selected route and parcel characteristics.
   *
   * The backend will also return the
   * authoritative parcel transport quote.
   */
  final List<Map<String, dynamic>>
      _services = [
    {
      'id': 'service_001',
      'agency': 'General Express',
      'rating': 4.8,
      'estimatedDuration': 'Same day',
      'price': 4500,
    },
    {
      'id': 'service_002',
      'agency': 'Finexs Voyage',
      'rating': 4.6,
      'estimatedDuration': 'Same day',
      'price': 4000,
    },
    {
      'id': 'service_003',
      'agency': 'Touristique Express',
      'rating': 4.5,
      'estimatedDuration':
          'Within 24 hours',
      'price': 4200,
    },
  ];

  Map<String, dynamic>?
      get _selectedService {
    if (_selectedServiceId == null) {
      return null;
    }

    for (final Map<String, dynamic>
        service in _services) {
      if (service['id'] ==
          _selectedServiceId) {
        return service;
      }
    }

    return null;
  }

  String _formatPrice(int value) {
    return value
        .toString()
        .replaceAllMapped(
      RegExp(
        r'(?=(\d{3})+(?!\d))',
      ),
      (match) => ',',
    );
  }

  void _continueToPayment() {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final Map<String, dynamic>?
        service = _selectedService;

    if (service == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .selectParcelTransportServiceError,
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ParcelPaymentScreen(
          recipientName:
              widget.recipientName,
          recipientPhone:
              widget.recipientPhone,
          departureCity:
              widget.departureCity,
          destinationCity:
              widget.destinationCity,
          description:
              widget.description,
          weight: widget.weight,
          agencyName:
              service['agency'],
          amount: service['price'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final Map<String, dynamic>?
        selectedService =
        _selectedService;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.parcelServices,
        ),
      ),
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
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets
                          .all(20),
                  children: [
                    Center(
                      child:
                          ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 820,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            _buildParcelSummary(
                              context,
                              l10n,
                            ),

                            const SizedBox(
                              height: 26,
                            ),

                            Text(
                              l10n
                                  .availableTransportServices,
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
                              height: 7,
                            ),

                            Text(
                              l10n
                                  .selectParcelAgencyDescription,
                              style:
                                  Theme.of(
                                context,
                              )
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        height:
                                            1.4,
                                      ),
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            ..._services.map(
                              (service) =>
                                  Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  bottom:
                                      14,
                                ),
                                child:
                                    _ParcelServiceCard(
                                  service:
                                      service,
                                  selected:
                                      _selectedServiceId ==
                                          service[
                                              'id'],
                                  onTap:
                                      () {
                                    setState(
                                      () {
                                        _selectedServiceId =
                                            service[
                                                'id'];
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            _buildNotice(
                              context,
                              l10n,
                            ),

                            const SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildBottomSection(
                context,
                l10n,
                selectedService,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParcelSummary(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
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
            BorderRadius.circular(20),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.16,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: const Icon(
                  Icons
                      .inventory_2_outlined,
                  size: 22,
                  color: Colors.white,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Text(
                l10n.parcelRequest,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      l10n.from,
                      style:
                          const TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight
                                .w600,
                        color:
                            Colors.white70,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      widget.departureCity,
                      style:
                          const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.14,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: Colors.white,
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .end,
                  children: [
                    Text(
                      l10n.to,
                      style:
                          const TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight
                                .w600,
                        color:
                            Colors.white70,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      widget
                          .destinationCity,
                      textAlign:
                          TextAlign.end,
                      style:
                          const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.scale_outlined,
                  size: 17,
                  color:
                      Colors.white70,
                ),

                const SizedBox(
                  width: 7,
                ),

                Expanded(
                  child: Text(
                    '${widget.weight.toStringAsFixed(1)} kg'
                    '  •  ${widget.description}',
                    style:
                        const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color:
                          Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(15),
      borderRadius: 14,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(
              color: AppColors.primary
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 20,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Text(
              l10n
                  .parcelServiceDemoNotice,
              style:
                  Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        height: 1.5,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic>? service,
  ) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      width: double.infinity,
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
                  isDark ? 0.92 : 0.96,
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
              maxWidth: 820,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration:
                      const Duration(
                    milliseconds: 250,
                  ),
                  child: service == null
                      ? const SizedBox
                          .shrink()
                      : Padding(
                          key: ValueKey(
                            service['id'],
                          ),
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),
                          child: Row(
                            children: [
                              Text(
                                l10n
                                    .parcelFee,
                                style:
                                    Theme.of(
                                  context,
                                )
                                        .textTheme
                                        .bodySmall,
                              ),

                              const Spacer(),

                              Text(
                                '${_formatPrice(service['price'])} FCFA',
                                style:
                                    const TextStyle(
                                  fontSize:
                                      18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      AppColors
                                          .primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        service == null
                            ? null
                            : _continueToPayment,
                    icon:
                        const Icon(
                      Icons
                          .payment_outlined,
                    ),
                    label: Text(
                      l10n
                          .continueToPayment,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParcelServiceCard
    extends StatelessWidget {
  final Map<String, dynamic>
      service;

  final bool selected;
  final VoidCallback onTap;

  const _ParcelServiceCard({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  String _formatPrice(int value) {
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
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

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
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            17,
          ),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.transparent,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration:
                      BoxDecoration(
                    color: AppColors.primary
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .directions_bus_outlined,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        service['agency'],
                        style:
                            Theme.of(
                          context,
                        )
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color:
                                AppColors
                                    .warning,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(
                            '${service['rating']}',
                            style:
                                Theme.of(
                              context,
                            )
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                AnimatedSwitcher(
                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),
                  child: Icon(
                    selected
                        ? Icons
                            .radio_button_checked
                        : Icons
                            .radio_button_off,
                    key: ValueKey(
                      selected,
                    ),
                    color: selected
                        ? AppColors.primary
                        : Theme.of(
                            context,
                          )
                            .colorScheme
                            .onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            const Divider(),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 18,
                  color: Theme.of(
                    context,
                  )
                      .colorScheme
                      .onSurfaceVariant,
                ),

                const SizedBox(
                  width: 7,
                ),

                Expanded(
                  child: Text(
                    l10n
                        .parcelDurationLabel(
                      service[
                          'estimatedDuration'],
                    ),
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Text(
                  '${_formatPrice(service['price'])} FCFA',
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}