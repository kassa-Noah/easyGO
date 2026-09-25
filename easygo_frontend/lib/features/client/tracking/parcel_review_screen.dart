import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../tracking/models/tracking.dart';
import '../../tracking/services/parcel_service.dart';
import 'parcel_confirmation_screen.dart';

class ParcelReviewScreen extends StatefulWidget {
  final String recipientName;
  final String recipientPhone;
  final String departureCity;
  final String destinationCity;
  final String description;
  final double weight;

  /// The real agency branch identifiers the parcel is sent
  /// between. They are what the backend persists.
  final String originBranchId;
  final String destinationBranchId;

  final String originAgencyName;
  final String destinationAgencyName;

  const ParcelReviewScreen({
    super.key,
    required this.recipientName,
    required this.recipientPhone,
    required this.departureCity,
    required this.destinationCity,
    required this.description,
    required this.weight,
    required this.originBranchId,
    required this.destinationBranchId,
    required this.originAgencyName,
    required this.destinationAgencyName,
  });

  @override
  State<ParcelReviewScreen> createState() => _ParcelReviewScreenState();
}

class _ParcelReviewScreenState extends State<ParcelReviewScreen> {
  final ParcelService _parcelService = ParcelService.instance;

  bool _isSubmitting = false;

  Future<void> _submitParcel() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // The parcel is registered by the backend, which owns the
      // tracking reference and the initial tracking event.
      final Parcel parcel = await _parcelService.createParcel(
        description: widget.description,
        recipientName: widget.recipientName,
        recipientPhone: widget.recipientPhone,
        originBranchId: widget.originBranchId,
        destinationBranchId: widget.destinationBranchId,
        weightKg: widget.weight,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ParcelConfirmationScreen(
            recipientName: widget.recipientName,
            recipientPhone: widget.recipientPhone,
            departureCity: parcel.originCity ?? widget.departureCity,
            destinationCity: parcel.destinationCity ?? widget.destinationCity,
            description: widget.description,
            weight: widget.weight,
            originAgencyName: widget.originAgencyName,
            destinationAgencyName: widget.destinationAgencyName,
            trackingReference: parcel.trackingNumber,
            status: parcel.status,
            progressPercentage: parcel.progressPercentage,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewParcel)),
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
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildRouteCard(context, l10n),

                            const SizedBox(height: 18),

                            _ReviewSection(
                              title: l10n.recipientInformation,
                              icon: Icons.person_outline,
                              children: [
                                _ReviewRow(
                                  label: l10n.name,
                                  value: widget.recipientName,
                                ),
                                _ReviewRow(
                                  label: l10n.phone,
                                  value: widget.recipientPhone,
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            _ReviewSection(
                              title: l10n.parcelInformation,
                              icon: Icons.inventory_2_outlined,
                              children: [
                                _ReviewRow(
                                  label: l10n.description,
                                  value: widget.description,
                                ),
                                _ReviewRow(
                                  label: l10n.weight,
                                  value:
                                      '${widget.weight.toStringAsFixed(1)} kg',
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            _buildPricingNotice(context, l10n),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildBottomSection(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, AppLocalizations l10n) {
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.route_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              const SizedBox(width: 11),

              Text(
                l10n.parcelRoute,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.from,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.departureCity,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 21,
                  color: Colors.white,
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.to,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.destinationCity,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingNotice(BuildContext context, AppLocalizations l10n) {
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
              l10n.parcelPricingNotice,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, AppLocalizations l10n) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: isDark ? 0.92 : 0.96),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitParcel,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  l10n.sendParcel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
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

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
