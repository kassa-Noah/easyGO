import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../agencies/models/agency.dart';
import '../../agencies/services/agency_service.dart';
import '../agencies/agency_details_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../notifications/services/notification_service.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final AgencyService _agencyService = AgencyService.instance;

  List<Agency> _agencies = [];

  int _unreadNotifications = 0;

  String _searchQuery = '';
  String? _errorMessage;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAgencies() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<Agency> agencies = await _agencyService.getAgencies();

      // The badge is decorative, so failing to read it must not stop the page
      // from rendering.
      int unread = 0;

      try {
        unread = await NotificationService.instance.getUnreadCount();
      } on ApiException {
        unread = 0;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _agencies = agencies;
        _unreadNotifications = unread;
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
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Unable to load transport agencies.';
        _isLoading = false;
      });
    }
  }

  List<Agency> get _visibleAgencies {
    final String query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return List<Agency>.from(_agencies);
    }

    return _agencies.where((agency) {
      final bool matchesAgencyName = agency.name.toLowerCase().contains(query);

      final bool matchesDescription =
          agency.description?.toLowerCase().contains(query) ?? false;

      final bool matchesPhone =
          agency.phone?.toLowerCase().contains(query) ?? false;

      final bool matchesEmail =
          agency.email?.toLowerCase().contains(query) ?? false;

      final bool matchesBranch = agency.activeBranches.any((branch) {
        return branch.name.toLowerCase().contains(query) ||
            branch.city.toLowerCase().contains(query) ||
            branch.address.toLowerCase().contains(query);
      });

      return matchesAgencyName ||
          matchesDescription ||
          matchesPhone ||
          matchesEmail ||
          matchesBranch;
    }).toList();
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );

    // Reading them on the other screen changes the count this one shows.
    if (mounted) {
      await _loadAgencies();
    }
  }

  void _openAgency(Agency agency) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgencyDetailsScreen(agency: agency),
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
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final List<Agency> agencies = _visibleAgencies;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _backgroundGradient(context)),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAgencies,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(l10n),

                        const SizedBox(height: 24),

                        _buildSearchBar(l10n),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.transportAgencies,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (!_isLoading && _errorMessage == null)
                              Text(
                                l10n.agenciesFound(agencies.length),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 11),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          l10n.agencySectionDescription,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                if (_isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60, bottom: 60),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (_errorMessage != null)
                  SliverToBoxAdapter(child: _buildErrorState())
                else if (agencies.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptySearchState(l10n))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: agencies.length,
                      itemBuilder: (context, index) {
                        final Agency agency = agencies[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _AgencyCard(
                            agency: agency,
                            onTap: () {
                              _openAgency(agency);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
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

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'easy',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'GO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(
                    Icons.directions_bus_outlined,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Interurban transport',
                    style: Theme.of(context).textTheme.bodySmall,
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
          padding: EdgeInsets.zero,
          child: Center(
            child: IconButton(
              tooltip: l10n.notifications,
              onPressed: _openNotifications,
              icon: Badge(
                isLabelVisible: _unreadNotifications > 0,
                label: Text('$_unreadNotifications'),
                child: const Icon(Icons.notifications_none),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: l10n.searchAgencyHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  tooltip: l10n.clearSearchTooltip,
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close),
                )
              : null,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 35, 30, 50),
      child: Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  size: 40,
                  color: AppColors.error,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Unable to load agencies',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 7),

              Text(
                _errorMessage ?? 'Please try again.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(height: 1.5),
              ),

              const SizedBox(height: 18),

              OutlinedButton.icon(
                onPressed: _loadAgencies,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 35, 30, 50),
      child: Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _searchQuery.isEmpty
                      ? Icons.directions_bus_outlined
                      : Icons.search_off_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                l10n.noAgenciesFound,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 7),

              Text(
                _searchQuery.isEmpty
                    ? 'No active transport agencies are currently available.'
                    : l10n.noAgencyMatches(_searchQuery),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(height: 1.5),
              ),

              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 16),

                TextButton.icon(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.clearSearch),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AgencyCard extends StatelessWidget {
  final Agency agency;
  final VoidCallback onTap;

  const _AgencyCard({required this.agency, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<AgencyBranch> branches = agency.activeBranches;

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agency.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      if (agency.description?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 5),
                        Text(
                          agency.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              branches.isEmpty
                                  ? 'No branch information available'
                                  : agency.cities,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),

            if (branches.isNotEmpty) ...[
              const SizedBox(height: 14),

              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: branches
                    .map((branch) => _BranchBadge(label: branch.city))
                    .toList(),
              ),
            ],

            if (agency.phone != null || agency.email != null) ...[
              const SizedBox(height: 14),

              Divider(height: 1, color: Theme.of(context).dividerColor),

              const SizedBox(height: 12),

              if (agency.phone != null && agency.phone!.trim().isNotEmpty)
                _AgencyContactRow(
                  icon: Icons.phone_outlined,
                  value: agency.phone!,
                ),

              if (agency.phone != null &&
                  agency.phone!.trim().isNotEmpty &&
                  agency.email != null &&
                  agency.email!.trim().isNotEmpty)
                const SizedBox(height: 7),

              if (agency.email != null && agency.email!.trim().isNotEmpty)
                _AgencyContactRow(
                  icon: Icons.email_outlined,
                  value: agency.email!,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AgencyContactRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _AgencyContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _BranchBadge extends StatelessWidget {
  final String label;

  const _BranchBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.secondaryLight : AppColors.secondaryDark,
        ),
      ),
    );
  }
}
