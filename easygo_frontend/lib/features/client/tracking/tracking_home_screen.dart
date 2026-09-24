import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'parcel_home_screen.dart';
import 'tracking_details_screen.dart';
import 'traveler_luggage_screen.dart';

class TrackingHomeScreen extends StatefulWidget {
  const TrackingHomeScreen({
    super.key,
  });

  @override
  State<TrackingHomeScreen> createState() =>
      _TrackingHomeScreenState();
}

class _TrackingHomeScreenState
    extends State<TrackingHomeScreen> {
  final TextEditingController
      _referenceController =
      TextEditingController();

  final FocusNode _referenceFocusNode =
      FocusNode();

  @override
  void dispose() {
    _referenceController.dispose();
    _referenceFocusNode.dispose();

    super.dispose();
  }

  void _trackReference() {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final String reference =
        _referenceController.text
            .trim()
            .toUpperCase();

    if (reference.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n.trackingReferenceRequired,
          ),
        ),
      );

      return;
    }

    _referenceFocusNode.unfocus();

    String itemType;
    String departureCity;
    String destinationCity;
    String currentStatus;

    /*
     * FRONTEND DEMONSTRATION DATA
     *
     * The reference prefix is used temporarily
     * to determine the type of tracked item.
     *
     * LUG- = Traveler luggage
     * PAR- = Independent parcel
     *
     * During backend integration, Flutter will
     * send the tracking reference to the backend.
     * The backend will return the authoritative
     * item type, route and tracking status.
     */

    if (reference.startsWith('PAR-')) {
      itemType = 'parcel';
      departureCity = 'Yaoundé';
      destinationCity = 'Douala';
      currentStatus = 'In Transit';
    } else {
      itemType = 'luggage';
      departureCity = 'Yaoundé';
      destinationCity = 'Douala';
      currentStatus = 'In Transit';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TrackingDetailsScreen(
          trackingReference: reference,
          itemType: itemType,
          departureCity: departureCity,
          destinationCity:
              destinationCity,
          currentStatus: currentStatus,
        ),
      ),
    );
  }

  void _useDemoReference(
    String reference,
  ) {
    setState(() {
      _referenceController.text =
          reference;

      _referenceController.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: _referenceController
              .text.length,
        ),
      );
    });
  }

  void _openTravelerLuggage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const TravelerLuggageScreen(),
      ),
    );
  }

  void _openIndependentParcel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ParcelHomeScreen(),
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
        automaticallyImplyLeading: false,
        title: Text(
          l10n.track,
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
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 820,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      _buildHeader(
                        context,
                        l10n,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _buildReferenceTracking(
                        context,
                        l10n,
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      Text(
                        l10n.trackingServices,
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

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        l10n
                            .chooseTrackingService,
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodySmall,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _TrackingOptionCard(
                        icon: Icons
                            .luggage_outlined,
                        title: l10n
                            .travelerLuggage,
                        subtitle: l10n
                            .travelerLuggageDescription,
                        badge: l10n
                            .linkedToBooking,
                        onTap:
                            _openTravelerLuggage,
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      _TrackingOptionCard(
                        icon: Icons
                            .inventory_2_outlined,
                        title: l10n
                            .independentParcel,
                        subtitle: l10n
                            .independentParcelDescription,
                        badge:
                            l10n.parcelService,
                        onTap:
                            _openIndependentParcel,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildTrackingExplanation(
                        context,
                        l10n,
                      ),

                      const SizedBox(
                        height: 25,
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

  Widget _buildHeader(
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
          end: Alignment.bottomRight,
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
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.95,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_searching,
              size: 32,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  l10n.trackYourItems,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  l10n
                      .trackYourItemsDescription,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color:
                        Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceTracking(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .qr_code_scanner_outlined,
                color:
                    AppColors.primary,
              ),

              const SizedBox(
                width: 9,
              ),

              Expanded(
                child: Text(
                  l10n.trackByReference,
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
              ),
            ],
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            l10n
                .trackByReferenceDescription,
            style:
                Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      height: 1.5,
                    ),
          ),

          const SizedBox(
            height: 16,
          ),

          TextField(
            controller:
                _referenceController,
            focusNode:
                _referenceFocusNode,
            textCapitalization:
                TextCapitalization
                    .characters,
            textInputAction:
                TextInputAction.search,
            onSubmitted: (_) {
              _trackReference();
            },
            decoration:
                InputDecoration(
              labelText:
                  l10n.trackingReference,
              hintText: l10n
                  .trackingReferenceExample,
              prefixIcon:
                  const Icon(
                Icons.tag_outlined,
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          SizedBox(
            width: double.infinity,
            child:
                ElevatedButton.icon(
              onPressed:
                  _trackReference,
              icon: const Icon(
                Icons.search,
              ),
              label: Text(
                l10n.trackItem,
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(
              13,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(
                    alpha: 0.45,
                  ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  l10n.demoReferences,
                  style:
                      Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                ),

                const SizedBox(
                  height: 8,
                ),

                _DemoReferenceButton(
                  reference: l10n
                      .travelerLuggageDemoReference,
                  description:
                      l10n.travelerLuggage,
                  onTap: () {
                    _useDemoReference(
                      l10n
                          .travelerLuggageDemoReference,
                    );
                  },
                ),

                const SizedBox(
                  height: 5,
                ),

                _DemoReferenceButton(
                  reference: l10n
                      .parcelDemoReference,
                  description: l10n
                      .independentParcel,
                  onTap: () {
                    _useDemoReference(
                      l10n
                          .parcelDemoReference,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingExplanation(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(16),
      borderRadius: 15,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 21,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  l10n.howTrackingWorks,
                  style:
                      Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  l10n
                      .trackingExplanation,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            height: 1.5,
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingOptionCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const _TrackingOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
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
      child: Padding(
        padding:
            const EdgeInsets.all(
          17,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(
                  alpha: 0.09,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Icon(
                icon,
                size: 28,
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
                            .titleSmall
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
                    subtitle,
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              height: 1.4,
                            ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .secondary
                          .withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                    child: Text(
                      badge,
                      style:
                          const TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight
                                .w600,
                        color: AppColors
                            .secondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Icon(
              Icons.chevron_right,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoReferenceButton
    extends StatelessWidget {
  final String reference;
  final String description;
  final VoidCallback onTap;

  const _DemoReferenceButton({
    required this.reference,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(8),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 3,
          ),
          child: Row(
            children: [
              const Icon(
                Icons
                    .touch_app_outlined,
                size: 15,
                color:
                    AppColors.primary,
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: Text(
                  '$reference — $description',
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            fontSize: 11,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}