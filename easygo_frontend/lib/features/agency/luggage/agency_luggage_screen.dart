import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'agency_luggage_details_screen.dart';

class AgencyLuggageScreen extends StatefulWidget {
  const AgencyLuggageScreen({
    super.key,
  });

  @override
  State<AgencyLuggageScreen> createState() =>
      _AgencyLuggageScreenState();
}

class _AgencyLuggageScreenState
    extends State<AgencyLuggageScreen> {
  static const String _all = 'All';

  static const List<String> _filters = [
    _all,
    'Registered',
    'Received by Agency',
    'Loaded',
    'In Transit',
    'Arrived',
    'Ready for Collection',
    'Delivered',
  ];

  String _selectedFilter = _all;

  static const List<Map<String, dynamic>>
      _luggageItems = [
    {
      'id': 'LUG-DEMO-001',
      'bookingReference': 'DEMO-BOOKING-001',
      'ticketReference': 'DEMO-TICKET-001',
      'clientName': 'John Doe',
      'clientPhone': '+237 6 70 00 00 01',
      'tripId': 'TRIP-DEMO-001',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Douala',
      'travelDate': '20 Sep 2026',
      'departureTime': '07:00',
      'description': 'Traveler suitcase',
      'weight': 18,
      'status': 'In Transit',
    },
    {
      'id': 'LUG-DEMO-002',
      'bookingReference': 'DEMO-BOOKING-002',
      'ticketReference': 'DEMO-TICKET-002',
      'clientName': 'Marie N.',
      'clientPhone': '+237 6 70 00 00 02',
      'tripId': 'TRIP-DEMO-002',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Bafoussam',
      'travelDate': '25 Sep 2026',
      'departureTime': '09:30',
      'description': 'Medium blue travel bag',
      'weight': 12,
      'status': 'Received by Agency',
    },
    {
      'id': 'LUG-DEMO-003',
      'bookingReference': 'DEMO-BOOKING-002',
      'ticketReference': 'DEMO-TICKET-002',
      'clientName': 'Marie N.',
      'clientPhone': '+237 6 70 00 00 02',
      'tripId': 'TRIP-DEMO-002',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Bafoussam',
      'travelDate': '25 Sep 2026',
      'departureTime': '09:30',
      'description': 'Traveler suitcase',
      'weight': 15,
      'status': 'Received by Agency',
    },
    {
      'id': 'LUG-DEMO-004',
      'bookingReference': 'DEMO-BOOKING-003',
      'ticketReference': 'DEMO-TICKET-003',
      'clientName': 'Samuel T.',
      'clientPhone': '+237 6 70 00 00 03',
      'tripId': 'TRIP-DEMO-003',
      'departureCity': 'Douala',
      'destinationCity': 'Yaoundé',
      'travelDate': '04 Aug 2026',
      'departureTime': '08:00',
      'description': 'Traveler suitcase',
      'weight': 16,
      'status': 'Delivered',
    },
    {
      'id': 'LUG-DEMO-005',
      'bookingReference': 'DEMO-BOOKING-005',
      'ticketReference': 'DEMO-TICKET-005',
      'clientName': 'Clarisse F.',
      'clientPhone': '+237 6 70 00 00 05',
      'tripId': 'TRIP-DEMO-001',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Douala',
      'travelDate': '20 Sep 2026',
      'departureTime': '07:00',
      'description': 'Black cabin bag',
      'weight': 9,
      'status': 'Loaded',
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilter == _all) {
      return _luggageItems;
    }

    return _luggageItems
        .where(
          (item) =>
              item['status'] == _selectedFilter,
        )
        .toList();
  }

  void _openDetails(
    Map<String, dynamic> luggage,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgencyLuggageDetailsScreen(
          luggage: luggage,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Registered':
        return AppColors.textSecondary;
      case 'Received by Agency':
        return AppColors.primary;
      case 'Loaded':
        return AppColors.primaryDark;
      case 'In Transit':
        return AppColors.warning;
      case 'Arrived':
        return AppColors.secondary;
      case 'Ready for Collection':
        return AppColors.secondaryDark;
      case 'Delivered':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Registered':
        return Icons.app_registration_outlined;
      case 'Received by Agency':
        return Icons.inventory_2_outlined;
      case 'Loaded':
        return Icons.file_upload_outlined;
      case 'In Transit':
        return Icons.local_shipping_outlined;
      case 'Arrived':
        return Icons.location_on_outlined;
      case 'Ready for Collection':
        return Icons.inventory_outlined;
      case 'Delivered':
        return Icons.check_circle_outline;
      default:
        return Icons.luggage_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final items = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Traveler Luggage',
        ),
      ),
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              32,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildSummary(context),
                      const SizedBox(height: 20),
                      _buildFilters(),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: 250,
                        ),
                        child: items.isEmpty
                            ? _buildEmptyState(
                                context,
                              )
                            : Column(
                                key: ValueKey(
                                  _selectedFilter,
                                ),
                                children: items
                                    .map(
                                      (item) =>
                                          Padding(
                                        padding:
                                            const EdgeInsets
                                                .only(
                                          bottom: 14,
                                        ),
                                        child:
                                            _buildLuggageCard(
                                          context,
                                          item,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
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

  Widget _buildSummary(
    BuildContext context,
  ) {
    final int active = _luggageItems
        .where(
          (item) =>
              item['status'] != 'Delivered',
        )
        .length;

    final int delivered = _luggageItems
        .where(
          (item) =>
              item['status'] == 'Delivered',
        )
        .length;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.luggage_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Luggage Management',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'General Express • '
                      '${_luggageItems.length} items',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SummaryBadge(
                label: 'Active',
                value: active,
                color: AppColors.primary,
              ),
              _SummaryBadge(
                label: 'Delivered',
                value: delivered,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map(
          (filter) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                right: 9,
              ),
              child: ChoiceChip(
                label: Text(filter),
                selected:
                    _selectedFilter ==
                        filter,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter =
                        filter;
                  });
                },
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildLuggageCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final String status =
        item['status'] as String;

    final Color color =
        _statusColor(status);

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      onTap: () {
        _openDetails(item);
      },
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  _statusIcon(status),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['id'] as String,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['description']
                          as String,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  item['clientName']
                      as String,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),
              ),
              Text(
                '${item['weight']} kg',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.route_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${item['departureCity']} → '
                  '${item['destinationCity']}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color:
                Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  item['bookingReference']
                      as String,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ),
              Text(
                item['travelDate']
                    as String,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return GlassContainer(
      key: ValueKey(
        'empty-$_selectedFilter',
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      borderRadius: 18,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.luggage_outlined,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == _all
                ? 'No luggage items'
                : 'No $_selectedFilter luggage',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
          const SizedBox(height: 7),
          Text(
            'There are currently no traveler luggage items under this status.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SummaryBadge
    extends StatelessWidget {
  const _SummaryBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}