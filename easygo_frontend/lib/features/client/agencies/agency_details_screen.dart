import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../booking/booking_mode_screen.dart';
import 'agency_conversation_screen.dart';

class AgencyDetailsScreen
    extends StatefulWidget {
  final Map<String, dynamic> agency;

  const AgencyDetailsScreen({
    super.key,
    required this.agency,
  });

  @override
  State<AgencyDetailsScreen> createState() =>
      _AgencyDetailsScreenState();
}

class _AgencyDetailsScreenState
    extends State<AgencyDetailsScreen> {
  int _selectedRating = 0;

  final TextEditingController
      _reviewController =
      TextEditingController();

  final List<Map<String, dynamic>>
      _demoReviews = [
    {
      'name': 'Demo Traveler',
      'rating': 5,
      'comment':
          'Comfortable journey and good customer service.',
      'date': '12 Sep 2026',
    },
    {
      'name': 'Client User',
      'rating': 4,
      'comment':
          'The booking process was simple and the departure was well organized.',
      'date': '04 Sep 2026',
    },
  ];

  Map<String, dynamic> get agency =>
      widget.agency;

  String get _agencyName =>
      agency['name']?.toString() ??
      'Transport Agency';

  String get _agencyLocation =>
      agency['address']?.toString() ??
      '${agency['location'] ?? 'Yaoundé'}, Cameroon';

  String get _agencyPhone =>
      agency['phone']?.toString() ??
      '+237 6XX XXX XXX';

  String get _openingHours =>
      agency['openingHours']?.toString() ??
      '05:00 - 22:00';

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _openConversation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgencyConversationScreen(
          agency: agency,
        ),
      ),
    );
  }

  void _showCallInformation() {
    final l10n =
        AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      AppColors.primary,
                  child: Icon(
                    Icons.call_outlined,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  _agencyName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 6),

                Text(
                  _agencyPhone,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(height: 18),

                Text(
                  l10n.callIntegrationInfo,
                  textAlign:
                      TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width:
                      double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        sheetContext,
                      );
                    },
                    child: Text(
                      l10n.close,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDirections() {
    final l10n =
        AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  l10n.agencyLocation,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                Container(
                  height: 180,
                  width:
                      double.infinity,
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .primaryLight
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                    border:
                        Border.all(
                      color:
                          Theme.of(context)
                              .dividerColor,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 52,
                        color:
                            AppColors
                                .primary,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        l10n.mapPreview,
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
                        height: 4,
                      ),

                      Text(
                        l10n
                            .interactiveMapLater,
                        textAlign:
                            TextAlign.center,
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _InformationRow(
                  icon: Icons
                      .location_on_outlined,
                  title:
                      l10n.agencyAddress,
                  value:
                      _agencyLocation,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .near_me_outlined,
                      color:
                          AppColors.primary,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        l10n
                            .approximateDistance(
                          agency['distance']
                                  ?.toString() ??
                              l10n
                                  .notAvailable,
                        ),
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodyMedium,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Container(
                  padding:
                      const EdgeInsets
                          .all(14),
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .primary
                        .withValues(
                      alpha: 0.06,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      13,
                    ),
                  ),
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
                        width: 9,
                      ),

                      Expanded(
                        child: Text(
                          l10n
                              .directionsProductionInfo,
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

                const SizedBox(height: 18),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        sheetContext,
                      );
                    },
                    icon: const Icon(
                      Icons
                          .directions_outlined,
                    ),
                    label: Text(
                      l10n
                          .directionsPending,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareInformation() {
    final l10n =
        AppLocalizations.of(context);

    final List<String> services =
        List<String>.from(
      agency['services'] ?? [],
    );

    final String shareText =
        '$_agencyName\n'
        '${l10n.location}: $_agencyLocation\n'
        '${l10n.yourRating}: ${agency['rating'] ?? '0.0'}/5\n'
        '${l10n.services}: ${services.map(l10n.serviceLabel).join(', ')}';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n.shareAgency,
          ),
          content:
              SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  l10n.sharePreview,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .all(14),
                  decoration:
                      BoxDecoration(
                    color:
                        Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                  child: Text(
                    shareText,
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              height:
                                  1.6,
                            ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  l10n
                      .nativeSharingInfo,
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                l10n.close,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReviews() {
    final l10n =
        AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (
            context,
            scrollController,
          ) {
            return ListView(
              controller:
                  scrollController,
              padding:
                  const EdgeInsets
                      .fromLTRB(
                20,
                0,
                20,
                30,
              ),
              children: [
                Text(
                  l10n.agencyReviews(
                    _agencyName,
                  ),
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
                  '${agency['rating'] ?? '0.0'} / 5 • ${l10n.reviews(agency['reviews'] as int? ?? 0)}',
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                ),

                const SizedBox(
                  height: 20,
                ),

                ..._demoReviews.map(
                  (review) =>
                      Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      bottom: 12,
                    ),
                    child:
                        _ReviewCard(
                      review: review,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  l10n
                      .demoReviewsInformation,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            fontSize: 11,
                            height: 1.5,
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWriteReview() {
    final l10n =
        AppLocalizations.of(context);

    _selectedRating = 0;
    _reviewController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        24,
              ),
              child:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      l10n
                          .rateThisAgency,
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
                      _agencyName,
                      style:
                          Theme.of(context)
                              .textTheme
                              .bodySmall,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Text(
                      l10n.yourRating,
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
                      height: 8,
                    ),

                    Row(
                      children:
                          List.generate(
                        5,
                        (index) {
                          final int rating =
                              index + 1;

                          return IconButton(
                            onPressed: () {
                              setModalState(
                                () {
                                  _selectedRating =
                                      rating;
                                },
                              );
                            },
                            icon: Icon(
                              rating <=
                                      _selectedRating
                                  ? Icons.star
                                  : Icons
                                      .star_border,
                              color:
                                  AppColors
                                      .warning,
                              size: 31,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    TextField(
                      controller:
                          _reviewController,
                      maxLines: 4,
                      maxLength: 250,
                      decoration:
                          InputDecoration(
                        labelText:
                            l10n.review,
                        hintText:
                            l10n.reviewHint,
                        alignLabelWithHint:
                            true,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          ElevatedButton(
                        onPressed: () {
                          final String
                              comment =
                              _reviewController
                                  .text
                                  .trim();

                          if (_selectedRating ==
                              0) {
                            ScaffoldMessenger
                                    .of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content:
                                    Text(
                                  l10n
                                      .selectRatingError,
                                ),
                              ),
                            );

                            return;
                          }

                          if (comment
                              .isEmpty) {
                            ScaffoldMessenger
                                    .of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content:
                                    Text(
                                  l10n
                                      .enterReviewError,
                                ),
                              ),
                            );

                            return;
                          }

                          setState(() {
                            _demoReviews
                                .insert(
                              0,
                              {
                                'name':
                                    'Demo Client',
                                'rating':
                                    _selectedRating,
                                'comment':
                                    comment,
                                'date':
                                    l10n.today,
                              },
                            );
                          });

                          Navigator.pop(
                            sheetContext,
                          );

                          ScaffoldMessenger
                                  .of(
                            this.context,
                          ).showSnackBar(
                            SnackBar(
                              content:
                                  Text(
                                l10n
                                    .reviewAdded,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          l10n
                              .submitReview,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context);

    final List<String> services =
        List<String>.from(
      agency['services'] ?? [],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.agencyDetails,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              _backgroundGradient(),
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
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      _buildAgencyHeader(
                        l10n,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _buildQuickActions(
                        l10n,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            OutlinedButton
                                .icon(
                          onPressed:
                              _openConversation,
                          icon:
                              const Icon(
                            Icons
                                .chat_bubble_outline,
                          ),
                          label: Text(
                            l10n
                                .messageAgency,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildSectionTitle(
                        l10n.aboutAgency,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        l10n
                            .aboutAgencyDescription,
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  height:
                                      1.6,
                                ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildSectionTitle(
                        l10n.services,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: services
                            .map(
                              (service) =>
                                  _ServiceChip(
                                label: l10n
                                    .serviceLabel(
                                  service,
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildSectionTitle(
                        l10n
                            .agencyInformation,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildInformationCard(
                        l10n,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildSectionTitle(
                        l10n
                            .popularRoutes,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildRoute(
                        'Yaoundé',
                        'Douala',
                        l10n.priceFrom(
                          '6,000 FCFA',
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _buildRoute(
                        'Yaoundé',
                        'Bafoussam',
                        l10n.priceFrom(
                          '5,000 FCFA',
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _buildRoute(
                        'Yaoundé',
                        'Buea',
                        l10n.priceFrom(
                          '7,000 FCFA',
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildSectionTitle(
                        l10n
                            .customerReviews,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildReviewSummary(
                        l10n,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            OutlinedButton
                                .icon(
                          onPressed:
                              _showWriteReview,
                          icon:
                              const Icon(
                            Icons
                                .rate_review_outlined,
                          ),
                          label: Text(
                            l10n
                                .rateReviewAgency,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),

              _buildBottomButton(
                l10n,
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient
      _backgroundGradient() {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF09111F),
          Color(0xFF0D1B2A),
          Color(0xFF10253B),
        ],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF2F8FF),
        Color(0xFFF7FBFF),
        Color(0xFFF1FFF6),
      ],
    );
  }

  Widget _buildAgencyHeader(
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors
                  .primaryLight
                  .withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: const Icon(
              Icons
                  .directions_bus_rounded,
              size: 45,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  _agencyName,
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
                  height: 7,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 19,
                      color: AppColors
                          .warning,
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Text(
                      '${agency['rating'] ?? '0.0'}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Expanded(
                      child: Text(
                        '(${l10n.reviews(agency['reviews'] as int? ?? 0)})',
                        style:
                            Theme.of(
                          context,
                        )
                                .textTheme
                                .bodySmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 7,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .location_on_outlined,
                      size: 16,
                      color:
                          AppColors
                              .secondary,
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Expanded(
                      child: Text(
                        '${agency['location'] ?? ''} • ${agency['distance'] ?? ''}',
                        style:
                            Theme.of(
                          context,
                        )
                                .textTheme
                                .bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon:
                Icons.call_outlined,
            label: l10n.call,
            onTap:
                _showCallInformation,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: _ActionButton(
            icon: Icons
                .directions_outlined,
            label:
                l10n.directions,
            onTap:
                _showDirections,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: _ActionButton(
            icon:
                Icons.share_outlined,
            label: l10n.share,
            onTap:
                _showShareInformation,
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard(
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(16),
      child: Column(
        children: [
          _InformationRow(
            icon: Icons
                .location_on_outlined,
            title: l10n.location,
            value:
                _agencyLocation,
          ),

          const Divider(
            height: 28,
          ),

          _InformationRow(
            icon:
                Icons.phone_outlined,
            title: l10n.phone,
            value: _agencyPhone,
          ),

          const Divider(
            height: 28,
          ),

          _InformationRow(
            icon: Icons
                .access_time_outlined,
            title:
                l10n.openingHours,
            value:
                _openingHours,
          ),

          const Divider(
            height: 28,
          ),

          _InformationRow(
            icon:
                Icons.verified_outlined,
            title: l10n.status,
            value:
                l10n.verifiedAgency,
          ),
        ],
      ),
    );
  }

  Widget _buildRoute(
    String departure,
    String destination,
    String price,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(15),
      child: Row(
        children: [
          const Icon(
            Icons.route_outlined,
            color:
                AppColors.primary,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  '$departure → $destination',
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
                  price,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
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
    );
  }

  Widget _buildReviewSummary(
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(18),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '${agency['rating'] ?? '0.0'}',
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
                height: 4,
              ),

              const Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors
                        .warning,
                  ),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors
                        .warning,
                  ),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors
                        .warning,
                  ),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors
                        .warning,
                  ),
                  Icon(
                    Icons.star_half,
                    size: 16,
                    color: AppColors
                        .warning,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            child: Text(
              l10n.basedOnReviews(
                agency['reviews']
                        as int? ??
                    0,
              ),
              style:
                  Theme.of(context)
                      .textTheme
                      .bodyMedium,
            ),
          ),

          TextButton(
            onPressed:
                _showReviews,
            child: Text(
              l10n.viewAll,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(
    AppLocalizations l10n,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          16,
        ),
        child: GlassContainer(
          padding:
              const EdgeInsets.all(8),
          child: SizedBox(
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
                            BookingModeScreen(
                      agency: agency,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons
                    .confirmation_num_outlined,
              ),
              label: Text(
                l10n.bookTrip,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(
            fontWeight:
                FontWeight.bold,
          ),
    );
  }
}

class _ActionButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GlassContainer(
      padding:
          EdgeInsets.zero,
      borderRadius: 14,
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 14,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              label,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationRow
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InformationRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color:
              Theme.of(context)
                  .colorScheme
                  .primary,
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
                title,
                style:
                    Theme.of(context)
                        .textTheme
                        .bodySmall,
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value,
                style:
                    Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceChip
    extends StatelessWidget {
  final String label;

  const _ServiceChip({
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            AppColors.secondary
                .withValues(
          alpha:
              isDark ? 0.20 : 0.12,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w500,
          color: isDark
              ? AppColors
                  .secondaryLight
              : AppColors
                  .secondaryDark,
        ),
      ),
    );
  }
}

class _ReviewCard
    extends StatelessWidget {
  final Map<String, dynamic> review;

  const _ReviewCard({
    required this.review,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final int rating =
        review['rating'] as int;

    return GlassContainer(
      padding:
          const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),
                child:
                    const Icon(
                  Icons.person_outline,
                  size: 19,
                  color:
                      AppColors.primary,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      review['name']
                          .toString(),
                      style:
                          Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      review['date']
                          .toString(),
                      style:
                          Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontSize:
                                    10,
                              ),
                    ),
                  ],
                ),
              ),

              Row(
                children:
                    List.generate(
                  5,
                  (index) => Icon(
                    index < rating
                        ? Icons.star
                        : Icons
                            .star_border,
                    size: 14,
                    color:
                        AppColors.warning,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 11,
          ),

          Text(
            review['comment']
                .toString(),
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
    );
  }
}