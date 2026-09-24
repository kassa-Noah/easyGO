import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../home/main_screen.dart';
import 'tracking_details_screen.dart';

class ParcelConfirmationScreen
    extends StatelessWidget {
  final String recipientName;
  final String recipientPhone;
  final String departureCity;
  final String destinationCity;
  final String description;
  final double weight;
  final String agencyName;
  final int amount;
  final String paymentMethod;
  final String trackingReference;

  const ParcelConfirmationScreen({
    super.key,
    required this.recipientName,
    required this.recipientPhone,
    required this.departureCity,
    required this.destinationCity,
    required this.description,
    required this.weight,
    required this.agencyName,
    required this.amount,
    required this.paymentMethod,
    required this.trackingReference,
  });

  String _formatPrice(int value) {
    return value
        .toString()
        .replaceAllMapped(
      RegExp(
        r'(?=(\d{3})+(?!\d))',
      ),
      (match) => ',',
    );
  }

  String _paymentMethodLabel(
    AppLocalizations l10n,
  ) {
    switch (paymentMethod) {
      case 'MTN Mobile Money':
        return l10n.mtnMobileMoney;

      case 'Orange Money':
        return l10n.orangeMoney;

      default:
        return paymentMethod;
    }
  }

  void _openTracking(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TrackingDetailsScreen(
          trackingReference:
              trackingReference,
          itemType: 'parcel',
          departureCity:
              departureCity,
          destinationCity:
              destinationCity,
          currentStatus:
              'Registered',
        ),
      ),
    );
  }

  void _returnHome(
    BuildContext context,
  ) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ClientMainScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading:
              false,
          title: Text(
            l10n.shipmentConfirmation,
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end: Alignment
                        .bottomRight,
                    colors: [
                      Color(0xFF09111F),
                      Color(0xFF0D1B2A),
                      Color(0xFF10253B),
                    ],
                  )
                : const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end: Alignment
                        .bottomRight,
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
              padding:
                  const EdgeInsets.all(
                20,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 760,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,
                      children: [
                        _buildSuccessHeader(
                          context,
                          l10n,
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        _buildTrackingReference(
                          context,
                          l10n,
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        _buildDetails(
                          context,
                          l10n,
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        ElevatedButton.icon(
                          onPressed: () {
                            _openTracking(
                              context,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .location_searching,
                          ),
                          label: Text(
                            l10n.trackParcel,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        OutlinedButton.icon(
                          onPressed: () {
                            _returnHome(
                              context,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .home_outlined,
                          ),
                          label: Text(
                            l10n.returnToHome,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
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

  Widget _buildSuccessHeader(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0.70,
            end: 1,
          ),
          duration:
              const Duration(
            milliseconds: 550,
          ),
          curve:
              Curves.easeOutBack,
          builder: (
            context,
            scale,
            child,
          ) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              color: AppColors.success
                  .withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 82,
              color:
                  AppColors.success,
            ),
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        Text(
          l10n.parcelShipmentCreated,
          textAlign:
              TextAlign.center,
          style:
              Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          l10n
              .parcelShipmentCreatedDescription,
          textAlign:
              TextAlign.center,
          style:
              Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    height: 1.5,
                  ),
        ),
      ],
    );
  }

  Widget _buildTrackingReference(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(20),
      borderRadius: 17,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 27,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Text(
            l10n
                .trackingReferenceLabel,
            textAlign:
                TextAlign.center,
            style:
                Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                      letterSpacing:
                          0.7,
                    ),
          ),

          const SizedBox(
            height: 8,
          ),

          SelectableText(
            trackingReference,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            l10n
                .demoTrackingReferenceNotice,
            textAlign:
                TextAlign.center,
            style:
                Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      fontSize: 10,
                      height: 1.4,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(18),
      borderRadius: 17,
      child: Column(
        children: [
          _DetailRow(
            icon:
                Icons.business_outlined,
            label: l10n.agency,
            value: agencyName,
          ),

          _DetailRow(
            icon: Icons.route_outlined,
            label: l10n.route,
            value:
                '$departureCity → '
                '$destinationCity',
          ),

          _DetailRow(
            icon:
                Icons.person_outline,
            label: l10n.recipient,
            value: recipientName,
          ),

          _DetailRow(
            icon:
                Icons.phone_outlined,
            label: l10n.phone,
            value: recipientPhone,
          ),

          _DetailRow(
            icon: Icons
                .inventory_2_outlined,
            label: l10n.parcel,
            value: description,
          ),

          _DetailRow(
            icon:
                Icons.scale_outlined,
            label: l10n.weight,
            value:
                '${weight.toStringAsFixed(1)} kg',
          ),

          _DetailRow(
            icon: Icons
                .account_balance_wallet_outlined,
            label:
                l10n.paymentMethod,
            value:
                _paymentMethodLabel(
              l10n,
            ),
          ),

          _DetailRow(
            icon:
                Icons.payments_outlined,
            label: l10n.amount,
            value:
                '${_formatPrice(amount)} FCFA',
            last: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool last;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    AppColors.primary,
              ),

              const SizedBox(
                width: 9,
              ),

              SizedBox(
                width: 92,
                child: Text(
                  label,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: Text(
                  value,
                  textAlign:
                      TextAlign.end,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontSize: 13,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                ),
              ),
            ],
          ),
        ),

        if (!last)
          const Divider(
            height: 1,
          ),
      ],
    );
  }
}