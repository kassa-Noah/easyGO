import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';

class TrackingDetailsScreen extends StatelessWidget {
  final String trackingReference;
  final String itemType;
  final String departureCity;
  final String destinationCity;
  final String currentStatus;

  const TrackingDetailsScreen({
    super.key,
    required this.trackingReference,
    required this.itemType,
    required this.departureCity,
    required this.destinationCity,
    required this.currentStatus,
  });

  static const List<String> _statuses = [
    'Registered',
    'Received by Agency',
    'Loaded',
    'In Transit',
    'Arrived',
    'Ready for Collection',
    'Delivered',
  ];

  int get _currentStatusIndex {
    final int index =
        _statuses.indexOf(currentStatus);

    return index < 0 ? 0 : index;
  }

  double get _progress {
    if (_statuses.length <= 1) {
      return 0;
    }

    return _currentStatusIndex /
        (_statuses.length - 1);
  }

  bool get _isParcel =>
      itemType.toLowerCase() == 'parcel';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.trackingDetails,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: [
                    Color(0xFF09111F),
                    Color(0xFF0D1B2A),
                    Color(0xFF10253B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
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
            padding:
                const EdgeInsets.all(20),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 820,
                  ),
                  child: Column(
                    children: [
                      _buildItemHeader(
                        context,
                        l10n,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildProgressCard(
                        context,
                        l10n,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildRouteCard(
                        context,
                        l10n,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildTimelineCard(
                        context,
                        l10n,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildTrackingNotice(
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
      ),
    );
  }

  Widget _buildItemHeader(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(18),
      borderRadius: 17,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child: Icon(
              _isParcel
                  ? Icons
                      .inventory_2_outlined
                  : Icons
                      .luggage_outlined,
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
                  _isParcel
                      ? l10n
                          .independentParcel
                      : l10n
                          .travelerLuggage,
                  style:
                      Theme.of(context)
                          .textTheme
                          .titleMedium
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
                  l10n.trackingReference,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                ),

                const SizedBox(
                  height: 3,
                ),

                SelectableText(
                  trackingReference,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .w600,
                            color: AppColors
                                .primary,
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      borderRadius: 18,
      child: Column(
        children: [
          Text(
            l10n.journeyProgress,
            textAlign:
                TextAlign.center,
            style:
                Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
          ),

          const SizedBox(
            height: 25,
          ),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: _progress,
            ),
            duration:
                const Duration(
              milliseconds: 850,
            ),
            curve: Curves.easeOutCubic,
            builder: (
              context,
              animatedProgress,
              child,
            ) {
              final int
                  animatedPercentage =
                  (animatedProgress * 100)
                      .round();

              return SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment:
                      Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child:
                          CircularProgressIndicator(
                        value:
                            animatedProgress,
                        strokeWidth: 13,
                        backgroundColor:
                            Theme.of(
                          context,
                        ).dividerColor,
                        color: AppColors
                            .secondary,
                        strokeCap:
                            StrokeCap.round,
                      ),
                    ),

                    Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          '$animatedPercentage%',
                          style:
                              Theme.of(
                            context,
                          )
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontSize:
                                        32,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          l10n.progress,
                          style:
                              Theme.of(
                            context,
                          )
                                  .textTheme
                                  .labelSmall
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
              );
            },
          ),

          const SizedBox(
            height: 22,
          ),

          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary
                  .withValues(
                alpha: 0.13,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Text(
              l10n
                  .trackingStatusLabel(
                    currentStatus,
                  )
                  .toUpperCase(),
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
                color: AppColors
                    .secondaryDark,
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            l10n
                .operationalProgressDescription,
            textAlign:
                TextAlign.center,
            style:
                Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      height: 1.4,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(18),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            l10n.transportRoute,
            style:
                Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
          ),

          const SizedBox(
            height: 20,
          ),

          Row(
            children: [
              Expanded(
                child: _RouteLocation(
                  label: l10n.from,
                  city: departureCity,
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons
                          .local_shipping_outlined,
                      color:
                          AppColors.primary,
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Container(
                      height: 2,
                      margin:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                      ),
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .primary
                            .withValues(
                          alpha: 0.55,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _RouteLocation(
                  label: l10n.to,
                  city:
                      destinationCity,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(18),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            l10n.trackingTimeline,
            style:
                Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
          ),

          const SizedBox(
            height: 22,
          ),

          ...List.generate(
            _statuses.length,
            (index) {
              final bool completed =
                  index <
                      _currentStatusIndex;

              final bool current =
                  index ==
                      _currentStatusIndex;

              return _TimelineItem(
                title: l10n
                    .trackingStatusLabel(
                  _statuses[index],
                ),
                currentStatusLabel:
                    l10n.currentStatus,
                completed: completed,
                current: current,
                showLine: index <
                    _statuses.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingNotice(
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
            decoration: BoxDecoration(
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
                  .trackingUpdateNotice,
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
}

class _RouteLocation
    extends StatelessWidget {
  final String label;
  final String city;
  final bool alignEnd;

  const _RouteLocation({
    required this.label,
    required this.city,
    this.alignEnd = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: alignEnd
              ? TextAlign.end
              : TextAlign.start,
          style:
              Theme.of(context)
                  .textTheme
                  .labelSmall,
        ),

        const SizedBox(
          height: 5,
        ),

        Text(
          city,
          textAlign: alignEnd
              ? TextAlign.end
              : TextAlign.start,
          style:
              Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
        ),
      ],
    );
  }
}

class _TimelineItem
    extends StatelessWidget {
  final String title;
  final String currentStatusLabel;
  final bool completed;
  final bool current;
  final bool showLine;

  const _TimelineItem({
    required this.title,
    required this.currentStatusLabel,
    required this.completed,
    required this.current,
    required this.showLine,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool active =
        completed || current;

    final Color inactiveColor =
        Theme.of(context).dividerColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 250,
                  ),
                  width: 26,
                  height: 26,
                  decoration:
                      BoxDecoration(
                    color: completed
                        ? AppColors.success
                        : current
                            ? AppColors
                                .primary
                            : Theme.of(
                                context,
                              )
                                .colorScheme
                                .surface,
                    shape:
                        BoxShape.circle,
                    border:
                        Border.all(
                      color: active
                          ? completed
                              ? AppColors
                                  .success
                              : AppColors
                                  .primary
                          : inactiveColor,
                      width: 2,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color:
                              Colors.white,
                        )
                      : current
                          ? const Center(
                              child:
                                  SizedBox(
                                width: 8,
                                height: 8,
                                child:
                                    DecoratedBox(
                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .white,
                                    shape:
                                        BoxShape
                                            .circle,
                                  ),
                                ),
                              ),
                            )
                          : null,
                ),

                if (showLine)
                  Expanded(
                    child:
                        AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds:
                            250,
                      ),
                      width: 2,
                      constraints:
                          const BoxConstraints(
                        minHeight: 35,
                      ),
                      color: completed
                          ? AppColors.success
                          : inactiveColor,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 24,
              ),
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
                            .bodyMedium
                            ?.copyWith(
                              fontWeight:
                                  current
                                      ? FontWeight
                                          .bold
                                      : FontWeight
                                          .w500,
                              color: active
                                  ? null
                                  : Theme.of(
                                      context,
                                    )
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                  ),

                  if (current) ...[
                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      currentStatusLabel,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight
                                .w600,
                        color: AppColors
                            .primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}