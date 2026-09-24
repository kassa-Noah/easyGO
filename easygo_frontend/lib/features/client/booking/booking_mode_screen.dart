import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'journey_search_screen.dart';

class BookingModeScreen
    extends StatelessWidget {
  final Map<String, dynamic> agency;

  const BookingModeScreen({
    super.key,
    required this.agency,
  });

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
          l10n.bookTrip,
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
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 760,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    GlassContainer(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      borderRadius: 16,
                      child: Row(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          const Icon(
                            Icons
                                .directions_bus_outlined,
                            size: 18,
                            color:
                                AppColors
                                    .primary,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Flexible(
                            child: Text(
                              agency['name']
                                      ?.toString() ??
                                  l10n
                                      .transportAgency,
                              style:
                                  const TextStyle(
                                fontSize: 13,
                                color:
                                    AppColors
                                        .primary,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Text(
                      l10n
                          .howWouldYouLikeToTravel,
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

                    Text(
                      l10n
                          .chooseTravelService,
                      style:
                          Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                height: 1.5,
                              ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    _BookingModeCard(
                      icon: Icons
                          .home_work_outlined,
                      title:
                          l10n.doorToDoor,
                      description: l10n
                          .doorToDoorDescription,
                      badge: l10n
                          .completeJourney,
                      features: [
                        l10n.pickupTaxi,
                        l10n
                            .interurbanTransport,
                        l10n
                            .destinationTaxi,
                      ],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    JourneySearchScreen(
                              agency:
                                  agency,
                              bookingMode:
                                  'door_to_door',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _BookingModeCard(
                      icon: Icons
                          .directions_bus_outlined,
                      title: l10n
                          .interurbanOnly,
                      description: l10n
                          .interurbanOnlyDescription,
                      badge:
                          l10n.busOnly,
                      features: [
                        l10n
                            .departureAgency,
                        l10n
                            .interurbanTransport,
                        l10n
                            .arrivalAgency,
                      ],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    JourneySearchScreen(
                              agency:
                                  agency,
                              bookingMode:
                                  'interurban_only',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    GlassContainer(
                      padding:
                          const EdgeInsets
                              .all(16),
                      borderRadius: 16,
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Icon(
                            Icons
                                .info_outline,
                            color:
                                AppColors
                                    .primary,
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Text(
                              l10n
                                  .taxiDoorToDoorInformation,
                              style:
                                  Theme.of(
                                context,
                              )
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontSize:
                                            13,
                                        height:
                                            1.5,
                                      ),
                            ),
                          ),
                        ],
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
    );
  }
}

class _BookingModeCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String badge;
  final List<String> features;
  final VoidCallback onTap;

  const _BookingModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 250,
        ),
        curve: Curves.easeOut,
        width: double.infinity,
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .primary
                        .withValues(
                      alpha: isDark
                          ? 0.20
                          : 0.10,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
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
                        height: 5,
                      ),

                      Text(
                        badge,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color:
                              AppColors
                                  .secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              description,
              style:
                  Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        height: 1.5,
                      ),
            ),

            const SizedBox(
              height: 16,
            ),

            ...features.map(
              (feature) => Padding(
                padding:
                    const EdgeInsets
                        .only(
                  bottom: 8,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        top: 1,
                      ),
                      child: Icon(
                        Icons
                            .check_circle_outline,
                        size: 18,
                        color:
                            AppColors
                                .secondary,
                      ),
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Expanded(
                      child: Text(
                        feature,
                        style:
                            Theme.of(
                          context,
                        )
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontSize:
                                      13,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}