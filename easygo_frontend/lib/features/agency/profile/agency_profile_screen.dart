import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'edit_agency_profile_screen.dart';

class AgencyProfileScreen extends StatefulWidget {
  const AgencyProfileScreen({
    super.key,
  });

  @override
  State<AgencyProfileScreen> createState() =>
      _AgencyProfileScreenState();
}

class _AgencyProfileScreenState
    extends State<AgencyProfileScreen> {
  Map<String, dynamic> _agency = {
    'name': 'General Express',
    'email': 'contact@generalexpress.cm',
    'phone': '+237 6 70 00 00 00',
    'description':
        'Interurban passenger transportation service connecting major cities in Cameroon.',
    'headOffice': 'Yaoundé, Centre',
    'address': 'Mvan, Yaoundé',
    'openingHours': '05:30 - 21:00',
    'rating': 4.5,
    'reviewCount': 128,
    'verified': true,
  };

  Future<void> _editProfile() async {
    final result =
        await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditAgencyProfileScreen(
          agency: _agency,
        ),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _agency = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.agencyProfile,
        ),
        actions: [
          IconButton(
            tooltip: localizations.editProfile,
            onPressed: _editProfile,
            icon: const Icon(
              Icons.edit_outlined,
            ),
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
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              34,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 850,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildAgencyHeader(
                      context,
                      localizations,
                    ),
                    const SizedBox(height: 18),
                    _buildContactInformation(
                      context,
                      localizations,
                    ),
                    const SizedBox(height: 18),
                    _buildLocationInformation(
                      context,
                      localizations,
                    ),
                    const SizedBox(height: 18),
                    _buildPublicInformation(
                      context,
                      localizations,
                    ),
                    const SizedBox(height: 18),
                    _buildManagementNotice(
                      context,
                      localizations,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _editProfile,
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        label: Text(
                          localizations.editAgencyInformation,
                        ),
                      ),
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

  Widget _buildAgencyHeader(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final bool verified =
        _agency['verified'] as bool;

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
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.directions_bus_outlined,
              size: 42,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _agency['name'] as String,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
              ),
              if (verified) ...[
                const SizedBox(width: 7),
                const Icon(
                  Icons.verified,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _agency['description'] as String,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _ProfileBadge(
                icon: Icons.star,
                text:
                    '${_agency['rating']} / 5',
                color: AppColors.warning,
              ),
              _ProfileBadge(
                icon: Icons.reviews_outlined,
                text:
                    '${_agency['reviewCount']} ${localizations.reviews}',
                color: AppColors.primary,
              ),
              if (verified)
                _ProfileBadge(
                  icon:
                      Icons.verified_outlined,
                  text:
                      localizations.verifiedAgency,
                  color: AppColors.success,
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
            icon: Icons.schedule_outlined,
            label: localizations.openingHours,
            value:
                _agency['openingHours'] as String,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInformation(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return _SectionCard(
      title: localizations.locationInformation,
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.location_city_outlined,
            label: localizations.headOffice,
            value:
                _agency['headOffice'] as String,
          ),
          const SizedBox(height: 14),
          _InformationRow(
            icon: Icons.location_on_outlined,
            label: localizations.agencyAddress,
            value:
                _agency['address'] as String,
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            localizations.publicAgencyInformationDescription,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.public_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    localizations.publicAgencyVisibilityNotice,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          height: 1.45,
                        ),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(12),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.profileManagement,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizations.profileManagementNotice,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        height: 1.45,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall,
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
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