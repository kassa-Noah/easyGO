import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../models/agency_console.dart';
import '../services/agency_console_service.dart';
import 'agency_branches_screen.dart';
import 'edit_agency_profile_screen.dart';

class AgencyProfileScreen extends StatefulWidget {
  const AgencyProfileScreen({super.key});

  @override
  State<AgencyProfileScreen> createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends State<AgencyProfileScreen> {
  final AgencyConsoleService _console = AgencyConsoleService.instance;

  Map<String, dynamic> _agency = <String, dynamic>{};

  List<ConsoleBranch> _branches = <ConsoleBranch>[];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // The profile may have just been edited, so force a re-read rather than
      // serving the cached record.
      final StaffAgencyProfile profile = await _console.getMyAgency(
        refresh: true,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _agency = _toProfileMap(profile);
        _branches = profile.branches;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  /// Projects the agency record onto the keys this screen renders.
  ///
  /// The head office row is shown from the first branch, because the agency
  /// record itself carries no single head-office address. The agency has no
  /// opening-hours or rating field at all, so those rows are gone rather than
  /// filled with an invented value.
  Map<String, dynamic> _toProfileMap(StaffAgencyProfile profile) {
    final ConsoleBranch? primary = profile.branches.isEmpty
        ? null
        : profile.branches.first;

    return <String, dynamic>{
      'agencyId': profile.agencyId,
      'name': profile.name,
      'email': dashIfEmpty(profile.email),
      'phone': dashIfEmpty(profile.phone),
      'description': dashIfEmpty(profile.description),
      'website': dashIfEmpty(profile.website),
      'staffRole': profile.staffRole,
      'headOffice': dashIfEmpty(primary?.city),
      'address': dashIfEmpty(primary?.address),
      // The record holds one status flag, `isActive`, which means the platform
      // still lists the agency. There is no verification field, so nothing here
      // may claim the agency was vetted.
      'isActive': profile.isActive,
    };
  }

  Future<void> _editProfile() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditAgencyProfileScreen(agency: _agency),
      ),
    );

    // The API is the source of truth, so re-read instead of trusting the map
    // handed back by the edit screen.
    if (saved == true && mounted) {
      await _loadProfile();
    }
  }

  /// Branch addresses and coordinates are what routes are built from, so this
  /// is a first-class action rather than something buried in the edit form.
  Future<void> _manageBranches() async {
    final bool? changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AgencyBranchesScreen()),
    );

    if (changed == true && mounted) {
      await _loadProfile();
    }
  }

  Widget _buildError(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.error,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Unable to load the agency profile.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.agencyProfile),
        actions: [
          IconButton(
            tooltip: localizations.editProfile,
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _buildError(context)
                    else ...[
                      _buildAgencyHeader(context, localizations),
                    const SizedBox(height: 18),
                    _buildContactInformation(context, localizations),
                    const SizedBox(height: 18),
                    _buildBranchInformation(context),
                    const SizedBox(height: 18),
                    _buildPublicInformation(context, localizations),
                    const SizedBox(height: 18),
                    _buildManagementNotice(context, localizations),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _editProfile,
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(localizations.editAgencyInformation),
                      ),
                    ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgencyHeader(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final bool isActive = _agency['isActive'] as bool;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.directions_bus_outlined,
              size: 42,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _agency['name'] as String,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 7),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _agency['description'] as String,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _ProfileBadge(
                icon: Icons.store_mall_directory_outlined,
                text:
                    '${_branches.length} '
                    '${_branches.length == 1 ? 'branch' : 'branches'}',
                color: AppColors.primary,
              ),
              if (_agency['staffRole'] != null &&
                  (_agency['staffRole'] as String).isNotEmpty)
                _ProfileBadge(
                  icon: Icons.badge_outlined,
                  text: _agency['staffRole'] as String,
                  color: AppColors.secondary,
                ),
              _ProfileBadge(
                icon: isActive
                    ? Icons.toggle_on_outlined
                    : Icons.toggle_off_outlined,
                text: isActive
                    ? localizations.activeAgency
                    : localizations.inactiveAgency,
                color: isActive ? AppColors.success : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformation(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return _SectionCard(
      title: localizations.contactInformation,
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.email_outlined,
            label: localizations.emailAddress,
            value: _agency['email'] as String,
          ),
          const SizedBox(height: 14),
          _InformationRow(
            icon: Icons.phone_outlined,
            label: localizations.phoneNumber,
            value: _agency['phone'] as String,
          ),
          const SizedBox(height: 14),
          _InformationRow(
            icon: Icons.language_outlined,
            label: 'Website',
            value: _agency['website'] as String,
          ),
        ],
      ),
    );
  }

  /// The agency's branches, which is where the real addresses and phones live.
  Widget _buildBranchInformation(BuildContext context) {
    return _SectionCard(
      title: 'Branches',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_branches.isEmpty)
            Text(
              'This agency has no branch yet.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            for (int index = 0; index < _branches.length; index++) ...[
              if (index > 0) const SizedBox(height: 14),
              _InformationRow(
                icon: Icons.location_city_outlined,
                label: '${_branches[index].name} '
                    '(${_branches[index].city})',
                value: '${_branches[index].address}'
                    '${_branches[index].phone == null ? '' : ' • ${_branches[index].phone}'}',
              ),
            ],
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _isLoading || _agency.isEmpty ? null : _manageBranches,
              icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
              label: Text(
                _branches.isEmpty ? 'Add a branch' : 'Manage branches',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicInformation(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return _SectionCard(
      title: localizations.publicAgencyInformation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.publicAgencyInformationDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.public_outlined, color: AppColors.primary),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    localizations.publicAgencyVisibilityNotice,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementNotice(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.warning,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.profileManagement,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  localizations.profileManagementNotice,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: AppColors.primary),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
