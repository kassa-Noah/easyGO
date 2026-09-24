import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'agency_parcel_details_screen.dart';

class AgencyParcelsScreen extends StatefulWidget {
  const AgencyParcelsScreen({
    super.key,
  });

  @override
  State<AgencyParcelsScreen> createState() =>
      _AgencyParcelsScreenState();
}

class _AgencyParcelsScreenState
    extends State<AgencyParcelsScreen> {
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

  static const List<Map<String, dynamic>> _parcels = [
    {
      'id': 'PAR-DEMO-001',
      'senderName': 'John Doe',
      'senderPhone': '+237 6 70 00 00 01',
      'recipientName': 'Michael N.',
      'recipientPhone': '+237 6 70 00 00 11',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Douala',
      'description': 'Clothes and personal items',
      'weight': 6,
      'serviceType': 'Standard Parcel',
      'amount': 3500,
      'paymentMethod': 'MTN Mobile Money',
      'paymentStatus': 'Paid',
      'registeredDate': '20 Sep 2026',
      'status': 'In Transit',
    },
    {
      'id': 'PAR-DEMO-002',
      'senderName': 'Marie N.',
      'senderPhone': '+237 6 70 00 00 02',
      'recipientName': 'Brice K.',
      'recipientPhone': '+237 6 70 00 00 12',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Bafoussam',
      'description': 'Books and documents',
      'weight': 4,
      'serviceType': 'Standard Parcel',
      'amount': 3000,
      'paymentMethod': 'Orange Money',
      'paymentStatus': 'Paid',
      'registeredDate': '21 Sep 2026',
      'status': 'Received by Agency',
    },
    {
      'id': 'PAR-DEMO-003',
      'senderName': 'Clarisse F.',
      'senderPhone': '+237 6 70 00 00 05',
      'recipientName': 'Paul M.',
      'recipientPhone': '+237 6 70 00 00 13',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Buea',
      'description': 'Small household package',
      'weight': 8,
      'serviceType': 'Standard Parcel',
      'amount': 4500,
      'paymentMethod': 'MTN Mobile Money',
      'paymentStatus': 'Paid',
      'registeredDate': '22 Sep 2026',
      'status': 'Loaded',
    },
    {
      'id': 'PAR-DEMO-004',
      'senderName': 'Samuel T.',
      'senderPhone': '+237 6 70 00 00 03',
      'recipientName': 'Alice E.',
      'recipientPhone': '+237 6 70 00 00 14',
      'departureCity': 'Douala',
      'destinationCity': 'Yaoundé',
      'description': 'Personal effects',
      'weight': 5,
      'serviceType': 'Standard Parcel',
      'amount': 3500,
      'paymentMethod': 'Orange Money',
      'paymentStatus': 'Paid',
      'registeredDate': '04 Aug 2026',
      'status': 'Delivered',
    },
    {
      'id': 'PAR-DEMO-005',
      'senderName': 'Grace M.',
      'senderPhone': '+237 6 70 00 00 04',
      'recipientName': 'Kevin A.',
      'recipientPhone': '+237 6 70 00 00 15',
      'departureCity': 'Yaoundé',
      'destinationCity': 'Limbe',
      'description': 'Shoes and accessories',
      'weight': 3,
      'serviceType': 'Standard Parcel',
      'amount': 3000,
      'paymentMethod': 'MTN Mobile Money',
      'paymentStatus': 'Paid',
      'registeredDate': '23 Sep 2026',
      'status': 'Registered',
    },
  ];

  List<Map<String, dynamic>> get _filteredParcels {
    if (_selectedFilter == _all) {
      return _parcels;
    }

    return _parcels
        .where(
          (parcel) =>
              parcel['status'] == _selectedFilter,
        )
        .toList();
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(?=(\d{3})+(?!\d))'),
      (match) => ',',
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
        return Icons.inventory_2_outlined;
    }
  }

  void _openParcelDetails(
    Map<String, dynamic> parcel,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgencyParcelDetailsScreen(
          parcel: parcel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final parcels = _filteredParcels;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agency Parcels',
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
                  constraints: const BoxConstraints(
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
                        child: parcels.isEmpty
                            ? _buildEmptyState(context)
                            : Column(
                                key: ValueKey(
                                  _selectedFilter,
                                ),
                                children: parcels
                                    .map(
                                      (parcel) => Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          bottom: 14,
                                        ),
                                        child:
                                            _buildParcelCard(
                                          context,
                                          parcel,
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
    final int active = _parcels
        .where(
          (parcel) =>
              parcel['status'] != 'Delivered',
        )
        .length;

    final int delivered = _parcels
        .where(
          (parcel) =>
              parcel['status'] == 'Delivered',
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
                  color: AppColors.secondary
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parcel Management',
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
                      '${_parcels.length} parcels',
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
              padding: const EdgeInsets.only(
                right: 9,
              ),
              child: ChoiceChip(
                label: Text(filter),
                selected:
                    _selectedFilter == filter,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildParcelCard(
    BuildContext context,
    Map<String, dynamic> parcel,
  ) {
    final String status =
        parcel['status'] as String;

    final Color color =
        _statusColor(status);

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      onTap: () {
        _openParcelDetails(parcel);
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
                      parcel['id'] as String,
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
                      parcel['description']
                          as String,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
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
                  'Sender: ${parcel['senderName']}',
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
                '${parcel['weight']} kg',
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
                  '${parcel['departureCity']} → '
                  '${parcel['destinationCity']}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_pin_outlined,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Recipient: '
                  '${parcel['recipientName']}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            color:
                Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatPrice(parcel['amount'] as int)} FCFA',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
              ),
              Text(
                parcel['registeredDate']
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
        'empty-parcels-$_selectedFilter',
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
              color: AppColors.secondary
                  .withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 34,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == _all
                ? 'No parcels'
                : 'No $_selectedFilter parcels',
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
            'There are currently no agency parcels under this tracking status.',
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

class _SummaryBadge extends StatelessWidget {
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
      padding: const EdgeInsets.symmetric(
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