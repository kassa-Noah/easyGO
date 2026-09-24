import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../agencies/agency_details_screen.dart';
import '../notifications/notifications_screen.dart';

class ClientHomeScreen
    extends StatefulWidget {
  const ClientHomeScreen({
    super.key,
  });

  @override
  State<ClientHomeScreen> createState() =>
      _ClientHomeScreenState();
}

class _ClientHomeScreenState
    extends State<ClientHomeScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();

  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filters = [
    'All',
    'Top Rated',
    'Closest',
    'Popular',
  ];

  final List<Map<String, dynamic>>
      _agencies = [
    {
      'name': 'General Express',
      'location': 'Yaoundé',
      'rating': 4.8,
      'reviews': 124,
      'distance': '2.4 km',
      'distanceValue': 2.4,
      'services': [
        'Interurban',
        'Door-to-Door',
        'Parcel',
      ],
    },
    {
      'name': 'Finexs Voyage',
      'location': 'Yaoundé',
      'rating': 4.6,
      'reviews': 98,
      'distance': '3.1 km',
      'distanceValue': 3.1,
      'services': [
        'Interurban',
        'Parcel',
      ],
    },
    {
      'name': 'Touristique Express',
      'location': 'Yaoundé',
      'rating': 4.5,
      'reviews': 76,
      'distance': '4.0 km',
      'distanceValue': 4.0,
      'services': [
        'Interurban',
        'Door-to-Door',
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>>
      get _visibleAgencies {
    final String query =
        _searchQuery
            .trim()
            .toLowerCase();

    List<Map<String, dynamic>>
        results =
        _agencies.where(
      (agency) {
        if (query.isEmpty) {
          return true;
        }

        final String name =
            agency['name']
                .toString()
                .toLowerCase();

        final String location =
            agency['location']
                .toString()
                .toLowerCase();

        final List<String> services =
            List<String>.from(
          agency['services'],
        );

        final bool matchesService =
            services.any(
          (service) => service
              .toLowerCase()
              .contains(query),
        );

        return name.contains(query) ||
            location.contains(query) ||
            matchesService;
      },
    ).toList();

    switch (_selectedFilter) {
      case 'Top Rated':
        results.sort(
          (a, b) =>
              (b['rating'] as num)
                  .compareTo(
            a['rating'] as num,
          ),
        );
        break;

      case 'Closest':
        results.sort(
          (a, b) =>
              (a['distanceValue']
                      as num)
                  .compareTo(
            b['distanceValue']
                as num,
          ),
        );
        break;

      case 'Popular':
        results.sort(
          (a, b) =>
              (b['reviews'] as int)
                  .compareTo(
            a['reviews'] as int,
          ),
        );
        break;

      case 'All':
      default:
        break;
    }

    return results;
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const NotificationsScreen(),
      ),
    );
  }

  void _openAgency(
    Map<String, dynamic> agency,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgencyDetailsScreen(
          agency: agency,
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final agencies =
        _visibleAgencies;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              _backgroundGradient(
            context,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    20,
                    20,
                    20,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      _buildHeader(
                        l10n,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _buildSearchBar(
                        l10n,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n
                                  .transportAgencies,
                              style: Theme.of(
                                context,
                              )
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                            ),
                          ),

                          if (_searchQuery
                              .isNotEmpty)
                            Text(
                              l10n
                                  .agenciesFound(
                                agencies
                                    .length,
                              ),
                              style: Theme.of(
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
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        l10n
                            .agencySectionDescription,
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodyMedium,
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      _buildFilters(
                        l10n,
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),

              if (agencies.isEmpty)
                SliverToBoxAdapter(
                  child:
                      _buildEmptySearchState(
                    l10n,
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 20,
                  ),
                  sliver:
                      SliverList.builder(
                    itemCount:
                        agencies.length,
                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final agency =
                          agencies[
                              index];

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 16,
                        ),
                        child:
                            _AgencyCard(
                          agency:
                              agency,
                          l10n: l10n,
                          onTap: () {
                            _openAgency(
                              agency,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _backgroundGradient(
    BuildContext context,
  ) {
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

  Widget _buildHeader(
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              RichText(
                text:
                    const TextSpan(
                  children: [
                    TextSpan(
                      text: 'easy',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            AppColors
                                .primary,
                      ),
                    ),
                    TextSpan(
                      text: 'GO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            AppColors
                                .secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 4,
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
                  Text(
                    'Yaoundé',
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),

        GlassContainer(
          width: 48,
          height: 48,
          borderRadius: 15,
          padding:
              EdgeInsets.zero,
          child: Stack(
            clipBehavior:
                Clip.none,
            children: [
              Center(
                child: IconButton(
                  tooltip: l10n
                      .notifications,
                  onPressed:
                      _openNotifications,
                  icon: const Icon(
                    Icons
                        .notifications_none,
                  ),
                ),
              ),

              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.error,
                    shape:
                        BoxShape.circle,
                    border:
                        Border.all(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      child: TextField(
        controller:
            _searchController,
        textInputAction:
            TextInputAction.search,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration:
            InputDecoration(
          hintText:
              l10n.searchAgencyHint,
          prefixIcon:
              const Icon(
            Icons.search,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                      tooltip: l10n
                          .clearSearchTooltip,
                      onPressed:
                          _clearSearch,
                      icon:
                          const Icon(
                        Icons.close,
                      ),
                    )
                  : null,
          filled: false,
          border:
              InputBorder.none,
          enabledBorder:
              InputBorder.none,
          focusedBorder:
              InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilters(
    AppLocalizations l10n,
  ) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount:
            _filters.length,
        separatorBuilder:
            (
          context,
          index,
        ) =>
                const SizedBox(
          width: 10,
        ),
        itemBuilder:
            (
          context,
          index,
        ) {
          final String filter =
              _filters[index];

          final bool selected =
              _selectedFilter ==
                  filter;

          return ChoiceChip(
            label: Text(
              l10n.filterLabel(
                filter,
              ),
            ),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedFilter =
                    filter;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptySearchState(
    AppLocalizations l10n,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        30,
        35,
        30,
        50,
      ),
      child: Center(
        child: GlassContainer(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: 0.08,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
                  Icons
                      .search_off_rounded,
                  size: 40,
                  color:
                      AppColors.primary,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              Text(
                l10n
                    .noAgenciesFound,
                style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                _searchQuery.isEmpty
                    ? l10n
                        .noAgenciesForFilter
                    : l10n
                        .noAgencyMatches(
                        _searchQuery,
                      ),
                textAlign:
                    TextAlign.center,
                style:
                    Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                  height: 1.5,
                ),
              ),

              if (_searchQuery
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 16,
                ),

                TextButton.icon(
                  onPressed:
                      _clearSearch,
                  icon:
                      const Icon(
                    Icons.refresh,
                  ),
                  label: Text(
                    l10n
                        .clearSearch,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AgencyCard
    extends StatelessWidget {
  final Map<String, dynamic>
      agency;

  final AppLocalizations l10n;

  final VoidCallback onTap;

  const _AgencyCard({
    required this.agency,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final List<String> services =
        List<String>.from(
      agency['services'],
    );

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
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
                  width: 62,
                  height: 62,
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .primaryLight
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .directions_bus_rounded,
                    size: 34,
                    color:
                        AppColors
                            .primary,
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
                        agency['name']
                            .toString(),
                        style: Theme.of(
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
                        height: 6,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 18,
                            color:
                                AppColors
                                    .warning,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(
                            '${agency['rating']}',
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
                              '(${l10n.reviews(agency['reviews'] as int)})',
                              overflow:
                                  TextOverflow
                                      .ellipsis,
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
                        height: 6,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons
                                .location_on_outlined,
                            size: 15,
                            color:
                                Theme.of(
                              context,
                            )
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),

                          const SizedBox(
                            width: 3,
                          ),

                          Expanded(
                            child: Text(
                              '${agency['location']} • ${agency['distance']}',
                              overflow:
                                  TextOverflow
                                      .ellipsis,
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
              height: 14,
            ),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: services
                  .map(
                    (service) =>
                        _ServiceBadge(
                      label: l10n
                          .serviceLabel(
                        service,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceBadge
    extends StatelessWidget {
  final String label;

  const _ServiceBadge({
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
        horizontal: 9,
        vertical: 5,
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
          fontSize: 11,
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