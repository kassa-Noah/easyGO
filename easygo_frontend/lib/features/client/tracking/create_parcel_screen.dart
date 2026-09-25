import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../agencies/models/agency.dart';
import '../../agencies/services/agency_service.dart';
import 'parcel_review_screen.dart';

class CreateParcelScreen extends StatefulWidget {
  const CreateParcelScreen({super.key});

  @override
  State<CreateParcelScreen> createState() => _CreateParcelScreenState();
}

class _CreateParcelScreenState extends State<CreateParcelScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AgencyService _agencyService = AgencyService.instance;

  final TextEditingController _recipientNameController =
      TextEditingController();

  final TextEditingController _recipientPhoneController =
      TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _weightController = TextEditingController();

  /* The backend identifies a route by its agency branches, so the
   * sender picks the real departure and arrival branches instead of
   * a free city name. */
  List<AgencyBranch> _branches = const <AgencyBranch>[];

  final Map<String, String> _agencyNamesByBranchId = <String, String>{};

  AgencyBranch? _originBranch;
  AgencyBranch? _destinationBranch;

  bool _isLoadingBranches = true;

  String? _branchError;

  @override
  void initState() {
    super.initState();

    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoadingBranches = true;
      _branchError = null;
    });

    try {
      final List<Agency> agencies = await _agencyService.getAgencies();

      final List<AgencyBranch> branches = <AgencyBranch>[];
      final Map<String, String> agencyNames = <String, String>{};

      for (final Agency agency in agencies) {
        for (final AgencyBranch branch in agency.activeBranches) {
          branches.add(branch);

          agencyNames[branch.id] = agency.name;
        }
      }

      branches.sort((AgencyBranch first, AgencyBranch second) {
        return '${first.city}${first.name}'.compareTo(
          '${second.city}${second.name}',
        );
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _branches = branches;

        _agencyNamesByBranchId
          ..clear()
          ..addAll(agencyNames);

        _isLoadingBranches = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _branchError = error.message;
        _isLoadingBranches = false;
      });
    }
  }

  String _branchLabel(AgencyBranch branch) {
    final String agencyName = _agencyNamesByBranchId[branch.id] ?? '';

    if (agencyName.isEmpty) {
      return '${branch.name} (${branch.city})';
    }

    return '$agencyName — ${branch.name} (${branch.city})';
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();

    super.dispose();
  }

  void _continueToReview() {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_originBranch == null || _destinationBranch == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectParcelCitiesError)));

      return;
    }

    if (_originBranch!.id == _destinationBranch!.id) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.differentParcelCitiesError)));

      return;
    }

    final double? weight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.validParcelWeightRequired)));

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParcelReviewScreen(
          recipientName: _recipientNameController.text.trim(),
          recipientPhone: _recipientPhoneController.text.trim(),
          departureCity: _originBranch!.city,
          destinationCity: _destinationBranch!.city,
          originBranchId: _originBranch!.id,
          destinationBranchId: _destinationBranch!.id,
          originAgencyName: _agencyNamesByBranchId[_originBranch!.id] ?? '',
          destinationAgencyName:
              _agencyNamesByBranchId[_destinationBranch!.id] ?? '',
          description: _descriptionController.text.trim(),
          weight: weight,
        ),
      ),
    );
  }

  Widget _buildRouteSection(BuildContext context, AppLocalizations l10n) {
    final bool isFrench = Localizations.localeOf(context).languageCode == 'fr';

    if (_isLoadingBranches) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_branchError != null) {
      return Column(
        children: [
          Text(
            _branchError!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _loadBranches,
            icon: const Icon(Icons.refresh),
            label: Text(isFrench ? 'Réessayer' : 'Try Again'),
          ),
        ],
      );
    }

    if (_branches.isEmpty) {
      return Text(
        isFrench
            ? 'Aucune agence de transport disponible pour le moment.'
            : 'No transport agency is available at the moment.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Column(
      children: [
        DropdownButtonFormField<AgencyBranch>(
          initialValue: _originBranch,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.departureCity,
            prefixIcon: const Icon(Icons.trip_origin_outlined),
          ),
          items: _branches
              .map(
                (branch) => DropdownMenuItem<AgencyBranch>(
                  value: branch,
                  child: Text(
                    _branchLabel(branch),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _originBranch = value;
            });
          },
        ),

        const SizedBox(height: 14),

        DropdownButtonFormField<AgencyBranch>(
          initialValue: _destinationBranch,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.destinationCity,
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          items: _branches
              .map(
                (branch) => DropdownMenuItem<AgencyBranch>(
                  value: branch,
                  child: Text(
                    _branchLabel(branch),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _destinationBranch = value;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sendParcel)),
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
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildIntroduction(context, l10n),

                        const SizedBox(height: 24),

                        _SectionCard(
                          title: l10n.recipientInformation,
                          icon: Icons.person_outline,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _recipientNameController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: l10n.recipientName,
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.recipientNameRequired;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _recipientPhoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: l10n.recipientPhone,
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.recipientPhoneRequired;
                                  }

                                  final String digits = value.replaceAll(
                                    RegExp(r'\D'),
                                    '',
                                  );

                                  if (digits.length < 9) {
                                    return l10n.validPhoneNumberRequired;
                                  }

                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _SectionCard(
                          title: l10n.transportRoute,
                          icon: Icons.route_outlined,
                          child: _buildRouteSection(context, l10n),
                        ),

                        const SizedBox(height: 18),

                        _SectionCard(
                          title: l10n.parcelInformation,
                          icon: Icons.inventory_2_outlined,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 3,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: l10n.parcelDescription,
                                  hintText: l10n.parcelDescriptionHint,
                                  alignLabelWithHint: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.parcelDescriptionRequired;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  _continueToReview();
                                },
                                decoration: InputDecoration(
                                  labelText: l10n.approximateWeight,
                                  suffixText: 'kg',
                                  prefixIcon: const Icon(Icons.scale_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.parcelWeightRequired;
                                  }

                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildNotice(context, l10n),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _continueToReview,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              l10n.continueToReview,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction(BuildContext context, AppLocalizations l10n) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.interurbanParcelDelivery,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  l10n.interurbanParcelDeliveryDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
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
              l10n.parcelReceptionNotice,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 17,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 21, color: AppColors.primary),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}
