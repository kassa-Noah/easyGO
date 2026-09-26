import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../agencies/models/agency.dart';
import '../../reviews/widgets/agency_reviews_section.dart';
import '../booking/booking_mode_screen.dart';
import 'agency_conversation_screen.dart';

class AgencyDetailsScreen extends StatelessWidget {
  final Agency agency;

  const AgencyDetailsScreen({super.key, required this.agency});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.agencyDetails)),
      body: Container(
        decoration: BoxDecoration(gradient: _backgroundGradient(context)),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {},
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildAgencyHeader(context, l10n),

                      const SizedBox(height: 24),

                      _buildQuickActions(context, l10n),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _openConversation(context);
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: Text(l10n.messageAgency),
                        ),
                      ),

                      const SizedBox(height: 28),

                      _buildSectionTitle(context, l10n.aboutAgency),

                      const SizedBox(height: 10),

                      _buildDescription(context),

                      const SizedBox(height: 28),

                      _buildSectionTitle(context, 'Contact Information'),

                      const SizedBox(height: 12),

                      _buildContactInformation(context),

                      const SizedBox(height: 28),

                      _buildSectionTitle(context, 'Agency Branches'),

                      const SizedBox(height: 12),

                      _buildBranches(context),

                      const SizedBox(height: 28),

                      AgencyReviewsSection(
                        agencyId: agency.id,
                        agencyName: agency.name,
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              _buildBottomButton(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _backgroundGradient(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF09111F), Color(0xFF0D1B2A), Color(0xFF10253B)],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF2F8FF), Color(0xFFF7FBFF), Color(0xFFF1FFF6)],
    );
  }

  Widget _buildAgencyHeader(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              size: 45,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agency.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: AppColors.secondary,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        _agencyLocationText(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      agency.isActive
                          ? Icons.verified_outlined
                          : Icons.cancel_outlined,
                      size: 17,
                      color: agency.isActive
                          ? AppColors.secondary
                          : AppColors.error,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      agency.isActive
                          ? l10n.activeAgency
                          : l10n.inactiveAgency,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
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

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.call_outlined,
            label: l10n.call,
            enabled: _hasText(agency.phone),
            onTap: () {
              _showCallInformation(context);
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ActionButton(
            icon: Icons.directions_outlined,
            label: l10n.branchLocations,
            enabled: agency.activeBranches.isNotEmpty,
            onTap: () {
              _showDirections(context);
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ActionButton(
            icon: Icons.info_outline,
            label: 'Info',
            onTap: () {
              _showAgencyInformation(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final String? description = agency.description;

    if (!_hasText(description)) {
      return Text(
        'No agency description is currently available.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
      );
    }

    return Text(
      description!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
    );
  }

  Widget _buildContactInformation(BuildContext context) {
    final bool hasPhone = _hasText(agency.phone);

    final bool hasEmail = _hasText(agency.email);

    final bool hasWebsite = _hasText(agency.website);

    if (!hasPhone && !hasEmail && !hasWebsite) {
      return GlassContainer(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('No contact information is currently available.'),
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (hasPhone)
            _InformationRow(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: agency.phone!,
            ),

          if (hasPhone && hasEmail) const Divider(height: 28),

          if (hasEmail)
            _InformationRow(
              icon: Icons.email_outlined,
              title: 'Email',
              value: agency.email!,
            ),

          if ((hasPhone || hasEmail) && hasWebsite) const Divider(height: 28),

          if (hasWebsite)
            _InformationRow(
              icon: Icons.language_outlined,
              title: 'Website',
              value: agency.website!,
            ),
        ],
      ),
    );
  }

  Widget _buildBranches(BuildContext context) {
    final List<AgencyBranch> branches = agency.activeBranches;

    if (branches.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_off_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Text(
                'No active branch information is currently available for this agency.',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: branches
          .map(
            (branch) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BranchCard(
                branch: branch,
                onDirections: () {
                  _showBranchDetails(context, branch);
                },
              ),
            ),
          )
          .toList(),
    );
  }

  void _showCallInformation(BuildContext context) {
    if (!_hasText(agency.phone)) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.call_outlined, color: Colors.white),
                ),

                const SizedBox(height: 14),

                Text(
                  agency.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  agency.phone!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 18),

                Text(
                  l10n.callIntegrationInfo,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.5),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: Text(l10n.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDirections(BuildContext context) {
    final List<AgencyBranch> branches = agency.activeBranches;

    if (branches.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a branch',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  'Choose the agency branch whose location you want to view.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 18),

                ...branches.map(
                  (branch) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(branch.name),
                      subtitle: Text('${branch.address}, ${branch.city}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(sheetContext);

                        _showBranchDetails(context, branch);
                      },
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

  void _showBranchDetails(BuildContext context, AgencyBranch branch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        branch.hasCoordinates
                            ? 'Branch coordinates available'
                            : 'Map location unavailable',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (branch.hasCoordinates) ...[
                        const SizedBox(height: 5),
                        Text(
                          '${branch.latitude}, ${branch.longitude}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _InformationRow(
                  icon: Icons.location_city_outlined,
                  title: 'City',
                  value: branch.city,
                ),

                const SizedBox(height: 14),

                _InformationRow(
                  icon: Icons.location_on_outlined,
                  title: 'Address',
                  value: branch.address,
                ),

                if (_hasText(branch.phone)) ...[
                  const SizedBox(height: 14),
                  _InformationRow(
                    icon: Icons.phone_outlined,
                    title: 'Branch phone',
                    value: branch.phone!,
                  ),
                ],

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'The backend provides the branch coordinates. Interactive map navigation will be connected in a later integration step.',
                          style: TextStyle(fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAgencyInformation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agency.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                _InformationRow(
                  icon: Icons.business_outlined,
                  title: 'Agency status',
                  value: agency.isActive ? 'Active' : 'Inactive',
                ),

                const SizedBox(height: 14),

                _InformationRow(
                  icon: Icons.location_city_outlined,
                  title: 'Active branches',
                  value: agency.activeBranches.length.toString(),
                ),

                if (_hasText(agency.email)) ...[
                  const SizedBox(height: 14),
                  _InformationRow(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: agency.email!,
                  ),
                ],

                if (_hasText(agency.phone)) ...[
                  const SizedBox(height: 14),
                  _InformationRow(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    value: agency.phone!,
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openConversation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgencyConversationScreen(agency: _agencyToLegacyMap()),
      ),
    );
  }

  Map<String, dynamic> _agencyToLegacyMap() {
    final AgencyBranch? primaryBranch = agency.activeBranches.isNotEmpty
        ? agency.activeBranches.first
        : null;

    return <String, dynamic>{
      'id': agency.id,
      'name': agency.name,
      'description': agency.description,
      'phone': agency.phone,
      'email': agency.email,
      'logoUrl': agency.logoUrl,
      'website': agency.website,
      'isActive': agency.isActive,
      'location': primaryBranch?.city ?? '',
      'address': primaryBranch?.address ?? '',
      'latitude': primaryBranch?.latitude,
      'longitude': primaryBranch?.longitude,
      'branches': agency.activeBranches
          .map(
            (branch) => <String, dynamic>{
              'id': branch.id,
              'name': branch.name,
              'city': branch.city,
              'address': branch.address,
              'latitude': branch.latitude,
              'longitude': branch.longitude,
              'phone': branch.phone,
              'isActive': branch.isActive,
              'agencyId': branch.agencyId,
            },
          )
          .toList(),
      'services': <String>[],
      'rating': 0.0,
      'reviews': 0,
      'distance': '',
    };
  }

  Widget _buildBottomButton(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: GlassContainer(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: agency.isActive
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingModeScreen(agency: _agencyToLegacyMap()),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.confirmation_num_outlined),
              label: Text(
                l10n.bookTrip,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _agencyLocationText() {
    if (agency.activeBranches.isEmpty) {
      return 'No active branch available';
    }

    if (agency.cities.trim().isEmpty) {
      return 'Branch information available';
    }

    return agency.cities;
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = enabled
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).disabledColor;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 14,
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: foregroundColor),

              const SizedBox(height: 6),

              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InformationRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),

              const SizedBox(height: 3),

              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  final AgencyBranch branch;
  final VoidCallback onDirections;

  const _BranchCard({required this.branch, required this.onDirections});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  branch.city,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 3),

                Text(
                  branch.address,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                if (branch.hasCoordinates) ...[
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.my_location_outlined,
                        size: 14,
                        color: AppColors.secondary,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          'Geolocation available',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 11,
                                color: AppColors.secondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          IconButton(
            tooltip: 'View location',
            onPressed: onDirections,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
