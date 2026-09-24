import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../tracking/tracking_details_screen.dart';

class BookingLuggageScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const BookingLuggageScreen({super.key, required this.trip});

  List<Map<String, dynamic>> get _luggageItems {
    final dynamic rawItems = trip['luggageItems'];

    if (rawItems is! List) {
      return [];
    }

    return rawItems.whereType<Map<String, dynamic>>().toList();
  }

  String _tripValue(String key, {String fallback = ''}) {
    return trip[key]?.toString() ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> luggageItems = _luggageItems;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingLuggage)),
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
          child: luggageItems.isEmpty
              ? _buildEmptyState(context, l10n)
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBookingSummary(context, l10n),
                            const SizedBox(height: 22),
                            _buildSectionHeader(
                              context,
                              l10n,
                              luggageItems.length,
                            ),
                            const SizedBox(height: 15),
                            ...luggageItems.map(
                              (luggage) => Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: _LuggageCard(
                                  luggage: luggage,
                                  agency: _tripValue('agency'),
                                  departureCity: _tripValue('departureCity'),
                                  destinationCity: _tripValue(
                                    'destinationCity',
                                  ),
                                  l10n: l10n,
                                  onTrack: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TrackingDetailsScreen(
                                              trackingReference:
                                                  luggage['trackingReference']
                                                      ?.toString() ??
                                                  '',
                                              itemType: 'luggage',
                                              departureCity: _tripValue(
                                                'departureCity',
                                              ),
                                              destinationCity: _tripValue(
                                                'destinationCity',
                                              ),
                                              currentStatus:
                                                  luggage['status']
                                                      ?.toString() ??
                                                  'Registered',
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildInformationNotice(context, l10n),
                            const SizedBox(height: 24),
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

  Widget _buildBookingSummary(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.luggage_outlined, color: Colors.white),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  l10n.luggageForThisBooking,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            l10n.bookingReferenceLabel,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            _tripValue('bookingReference'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _tripValue('departureCity'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: Colors.white70,
                ),
              ),
              Expanded(
                child: Text(
                  _tripValue('destinationCity'),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    AppLocalizations l10n,
    int itemCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.registeredLuggage,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            l10n.luggageItemCount(itemCount),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformationNotice(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      borderRadius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              l10n.bookingLuggageInformation,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.luggage_outlined,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.noLuggage,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noLuggageForBooking(_tripValue('bookingReference')),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LuggageCard extends StatelessWidget {
  final Map<String, dynamic> luggage;
  final String agency;
  final String departureCity;
  final String destinationCity;
  final AppLocalizations l10n;
  final VoidCallback onTrack;

  const _LuggageCard({
    required this.luggage,
    required this.agency,
    required this.departureCity,
    required this.destinationCity,
    required this.l10n,
    required this.onTrack,
  });

  String _value(String key, {String fallback = ''}) {
    return luggage[key]?.toString() ?? fallback;
  }

  Color get _statusColor {
    switch (_value('status')) {
      case 'Delivered':
        return AppColors.success;

      case 'In Transit':
        return AppColors.primary;

      case 'Arrived':
      case 'Ready for Collection':
        return AppColors.secondary;

      case 'Loaded':
        return AppColors.primaryLight;

      case 'Received by Agency':
        return AppColors.secondary;

      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = _value('status', fallback: 'Registered');

    final String description = _value('description');

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.luggage_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      _value('trackingReference'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.luggageItemDescriptionLabel(description),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  l10n.trackingStatusLabel(status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.scale_outlined,
                      size: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _value('weight'),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 10),
          _SmallInformationRow(label: l10n.agency, value: agency),
          const SizedBox(height: 8),
          _SmallInformationRow(
            label: l10n.route,
            value: '$departureCity → $destinationCity',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTrack,
              icon: const Icon(Icons.location_searching),
              label: Text(l10n.trackLuggage),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInformationRow extends StatelessWidget {
  final String label;
  final String value;

  const _SmallInformationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
