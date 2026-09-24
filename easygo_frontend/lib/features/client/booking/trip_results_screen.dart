import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'booking_review_screen.dart';

class TripResultsScreen
    extends StatelessWidget {
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

  bool get isDoorToDoor =>
      bookingMode == 'door_to_door';

  List<Map<String, dynamic>>
      get trips => [
        {
          'id': 'trip_001',
          'departureTime': '07:00',
          'arrivalTime': '11:00',
          'duration': '4h 00min',
          'class': 'VIP',
          'vehicle':
              '70-seat Coach',
          'availableSeats': 18,
          'price': 7000,
        },
        {
          'id': 'trip_002',
          'departureTime': '09:30',
          'arrivalTime': '13:45',
          'duration': '4h 15min',
          'class': 'Classic',
          'vehicle':
              '60-seat Coach',
          'availableSeats': 27,
          'price': 6000,
        },
        {
          'id': 'trip_003',
          'departureTime': '14:00',
          'arrivalTime': '18:00',
          'duration': '4h 00min',
          'class': 'VIP',
          'vehicle':
              '70-seat Coach',
          'availableSeats': 11,
          'price': 7000,
        },
      ];

  String _formattedDate() {
    final String day = travelDate.day
        .toString()
        .padLeft(2, '0');

    final String month =
        travelDate.month
            .toString()
            .padLeft(2, '0');

    return '$day/$month/${travelDate.year}';
  }

  String _formatPrice(
    int price,
  ) {
    return price
        .toString()
        .replaceAllMapped(
          RegExp(
            r'(?=(\d{3})+(?!\d))',
          ),
          (match) => ',',
        );
  }

  void _selectTrip(
    BuildContext context,
    Map<String, dynamic> trip,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookingReviewScreen(
          agency: agency,
          trip: trip,
          bookingMode: bookingMode,
          departureCity:
              departureCity,
          destinationCity:
              destinationCity,
          pickupLocation:
              pickupLocation,
          finalDestination:
              finalDestination,
          travelDate: travelDate,
          passengers: passengers,
          luggage: luggage,
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
          l10n.availableTrips,
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
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 900,
              ),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      20,
                      12,
                      20,
                      0,
                    ),
                    child:
                        _buildSearchSummary(
                      context,
                      l10n,
                    ),
                  ),

                  Expanded(
                    child:
                        ListView.separated(
                      padding:
                          const EdgeInsets
                              .all(20),
                      itemCount:
                          trips.length +
                              1,
                      separatorBuilder:
                          (
                        context,
                        index,
                      ) =>
                              const SizedBox(
                        height: 16,
                      ),
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        if (index ==
                            trips.length) {
                          return GlassContainer(
                            padding:
                                const EdgeInsets
                                    .all(
                              14,
                            ),
                            borderRadius:
                                15,
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Icon(
                                  Icons
                                      .info_outline,
                                  size: 20,
                                  color:
                                      AppColors
                                          .primary,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    l10n
                                        .tripResultsDemoInformation,
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
                          );
                        }

                        final Map<String,
                                dynamic>
                            trip =
                            trips[index];

                        return _TripCard(
                          trip: trip,
                          passengers:
                              passengers,
                          formattedPrice:
                              _formatPrice(
                            trip['price']
                                as int,
                          ),
                          onSelect: () {
                            _selectTrip(
                              context,
                              trip,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSummary(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .directions_bus_outlined,
                size: 18,
                color:
                    AppColors.primary,
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: Text(
                  agency['name']
                          ?.toString() ??
                      l10n
                          .transportAgency,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Row(
            children: [
              Expanded(
                child: _CityDisplay(
                  label: l10n.from,
                  city:
                      departureCity,
                  alignment:
                      CrossAxisAlignment
                          .start,
                ),
              ),

              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .primary
                      .withValues(
                    alpha: 0.10,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color:
                      AppColors.primary,
                ),
              ),

              Expanded(
                child: _CityDisplay(
                  label: l10n.to,
                  city:
                      destinationCity,
                  alignment:
                      CrossAxisAlignment
                          .end,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              _SummaryItem(
                icon: Icons
                    .calendar_today_outlined,
                text:
                    _formattedDate(),
              ),
              _SummaryItem(
                icon:
                    Icons.people_outline,
                text:
                    l10n.passengerCount(
                  passengers,
                ),
              ),
              _SummaryItem(
                icon:
                    Icons.luggage_outlined,
                text:
                    l10n.luggageCount(
                  luggage,
                ),
              ),
            ],
          ),

          if (isDoorToDoor) ...[
            const SizedBox(
              height: 16,
            ),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration:
                  BoxDecoration(
                color: AppColors
                    .secondary
                    .withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons
                        .local_taxi_outlined,
                    size: 16,
                    color: AppColors
                        .secondary,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    l10n
                        .doorToDoorJourney,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color: AppColors
                          .secondary,
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

class _TripCard
    extends StatelessWidget {
  final Map<String, dynamic> trip;
  final int passengers;
  final String formattedPrice;
  final VoidCallback onSelect;

  const _TripCard({
    required this.trip,
    required this.passengers,
    required this.formattedPrice,
    required this.onSelect,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final int availableSeats =
        trip['availableSeats'] as int;

    final bool enoughSeats =
        availableSeats >= passengers;

    return GlassContainer(
      padding:
          const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .primary
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  trip['class']
                      .toString(),
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColors.primary,
                  ),
                ),
              ),

              const Spacer(),

              Icon(
                enoughSeats
                    ? Icons
                        .event_seat_outlined
                    : Icons
                        .warning_amber_outlined,
                size: 17,
                color: enoughSeats
                    ? AppColors.secondary
                    : AppColors.error,
              ),

              const SizedBox(
                width: 5,
              ),

              Flexible(
                child: Text(
                  enoughSeats
                      ? l10n.seatsLeft(
                          availableSeats,
                        )
                      : l10n
                          .insufficientSeats,
                  textAlign:
                      TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    color: enoughSeats
                        ? AppColors
                            .secondary
                        : AppColors.error,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
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
                      trip['departureTime']
                          .toString(),
                      style:
                          Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      l10n.departure,
                      style:
                          Theme.of(context)
                              .textTheme
                              .bodySmall,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      trip['duration']
                          .toString(),
                      style:
                          Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontSize:
                                    11,
                              ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    const Row(
                      children: [
                        Expanded(
                          child:
                              Divider(),
                        ),
                        Padding(
                          padding:
                              EdgeInsets
                                  .symmetric(
                            horizontal: 5,
                          ),
                          child: Icon(
                            Icons
                                .directions_bus,
                            size: 18,
                            color:
                                AppColors
                                    .primary,
                          ),
                        ),
                        Expanded(
                          child:
                              Divider(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .end,
                  children: [
                    Text(
                      trip['arrivalTime']
                          .toString(),
                      style:
                          Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      l10n.arrival,
                      style:
                          Theme.of(context)
                              .textTheme
                              .bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              Icon(
                Icons
                    .directions_bus_outlined,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: Text(
                  trip['vehicle']
                      .toString(),
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            fontSize: 13,
                          ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          const Divider(),

          const SizedBox(
            height: 12,
          ),

          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final bool compact =
                  constraints.maxWidth <
                      390;

              final Widget fare =
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    l10n
                        .interurbanFare,
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontSize:
                                  11,
                            ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    '$formattedPrice FCFA',
                    style:
                        Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                  ),

                  if (passengers >
                      1)
                    Text(
                      l10n
                          .perPassenger,
                      style:
                          Theme.of(
                        context,
                      )
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontSize:
                                    11,
                              ),
                    ),
                ],
              );

              final Widget button =
                  SizedBox(
                width: compact
                    ? double.infinity
                    : 135,
                child:
                    ElevatedButton(
                  onPressed:
                      enoughSeats
                          ? onSelect
                          : null,
                  child: Text(
                    enoughSeats
                        ? l10n.select
                        : l10n
                            .insufficientSeats,
                    textAlign:
                        TextAlign.center,
                  ),
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    fare,
                    const SizedBox(
                      height: 14,
                    ),
                    button,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: fare,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
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

class _CityDisplay
    extends StatelessWidget {
  final String label;
  final String city;
  final CrossAxisAlignment
      alignment;

  const _CityDisplay({
    required this.label,
    required this.city,
    required this.alignment,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          alignment,
      children: [
        Text(
          label,
          style:
              Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    fontSize: 10,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          city,
          textAlign: alignment ==
                  CrossAxisAlignment
                      .end
              ? TextAlign.end
              : TextAlign.start,
          style:
              Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
        ),
      ],
    );
  }
}

class _SummaryItem
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),

        const SizedBox(
          width: 5,
        ),

        Text(
          text,
          style:
              Theme.of(context)
                  .textTheme
                  .bodySmall,
        ),
      ],
    );
  }
}