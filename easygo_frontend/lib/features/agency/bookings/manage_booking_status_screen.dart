import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class ManageBookingStatusScreen extends StatefulWidget {
  const ManageBookingStatusScreen({
    super.key,
    required this.booking,
  });

  final Map<String, dynamic> booking;

  @override
  State<ManageBookingStatusScreen> createState() =>
      _ManageBookingStatusScreenState();
}

class _ManageBookingStatusScreenState
    extends State<ManageBookingStatusScreen> {
  late String _currentStatus;

  String? _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _currentStatus =
        widget.booking['status'] as String;
  }

  List<String> get _allowedTransitions {
    switch (_currentStatus) {
      case 'Confirmed':
        return [
          'Completed',
          'Cancelled',
        ];

      case 'Completed':
      case 'Cancelled':
      default:
        return [];
    }
  }

  bool get _canManage =>
      _allowedTransitions.isNotEmpty;

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'Confirmed':
        return AppColors.primary;

      case 'Completed':
        return AppColors.success;

      case 'Cancelled':
        return AppColors.error;

      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(
    String status,
  ) {
    switch (status) {
      case 'Confirmed':
        return Icons.check_circle_outline;

      case 'Completed':
        return Icons.task_alt;

      case 'Cancelled':
        return Icons.cancel_outlined;

      default:
        return Icons.info_outline;
    }
  }

  String _transitionDescription(
    String status,
  ) {
    switch (status) {
      case 'Completed':
        return 'Use this when the booking has been fulfilled and the client has completed the scheduled journey.';

      case 'Cancelled':
        return 'Use this when the booking is no longer active and should not proceed as scheduled.';

      default:
        return '';
    }
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) {
      _showMessage(
        'Select the new booking status.',
      );
      return;
    }

    final bool? confirmed =
        await _confirmStatusChange();

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(
      const Duration(
        milliseconds: 900,
      ),
    );

    if (!mounted) {
      return;
    }

    final String newStatus =
        _selectedStatus!;

    setState(() {
      _isSaving = false;
      _currentStatus = newStatus;
      _selectedStatus = null;
    });

    await _showDemoResult(
      newStatus,
    );
  }

  Future<bool?> _confirmStatusChange() {
    final String newStatus =
        _selectedStatus!;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            _statusIcon(newStatus),
            color: _statusColor(
              newStatus,
            ),
            size: 38,
          ),
          title: const Text(
            'Confirm Status Change',
          ),
          content: Text(
            'Change booking '
            '${widget.booking['bookingReference']} '
            'from $_currentStatus to '
            '$newStatus?\n\n'
            'This action represents an operational '
            'booking-state change.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Keep Current Status',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Confirm',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDemoResult(
    String newStatus,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 38,
          ),
          title: const Text(
            'Status Validated',
          ),
          content: Text(
            'The booking status change to '
            '$newStatus has been simulated '
            'successfully on this screen.\n\n'
            'No database record has been updated. '
            'The backend will perform and authorize '
            'the real status transition.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Continue',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Booking Status',
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
                  end:
                      Alignment.bottomRight,
                  colors: [
                    Color(0xFF09111F),
                    Color(0xFF0D1B2A),
                    Color(0xFF10253B),
                  ],
                )
              : const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
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
            padding:
                const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              34,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 800,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildBookingHeader(
                      context,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    _buildCurrentStatus(
                      context,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    if (_canManage)
                      _buildTransitionSection(
                        context,
                      )
                    else
                      _buildFinalStatusNotice(
                        context,
                      ),
                    const SizedBox(
                      height: 18,
                    ),
                    _buildBusinessRuleNotice(
                      context,
                    ),
                    if (_canManage) ...[
                      const SizedBox(
                        height: 24,
                      ),
                      _buildUpdateButton(),
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

  Widget _buildBookingHeader(
    BuildContext context,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons
                  .confirmation_number_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking[
                          'bookingReference']
                      as String,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.booking[
                          'clientName']
                      as String,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.booking['departureCity']} → '
                  '${widget.booking['destinationCity']}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(
    BuildContext context,
  ) {
    final Color color =
        _statusColor(
      _currentStatus,
    );

    return GlassContainer(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Current Booking Status',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(
              15,
            ),
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              border: Border.all(
                color: color.withValues(
                  alpha: 0.25,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(
                    color:
                        color.withValues(
                      alpha: 0.12,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon(
                      _currentStatus,
                    ),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        _currentStatus,
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color: color,
                            ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        _currentStatus ==
                                'Confirmed'
                            ? 'This booking is active.'
                            : 'This booking has reached a final state.',
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionSection(
    BuildContext context,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Select New Status',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            'Only valid transitions from the current booking state are displayed.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          ..._allowedTransitions.map(
            (status) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child:
                    _StatusOptionCard(
                  status: status,
                  description:
                      _transitionDescription(
                    status,
                  ),
                  color:
                      _statusColor(
                    status,
                  ),
                  icon:
                      _statusIcon(
                    status,
                  ),
                  selected:
                      _selectedStatus ==
                          status,
                  onTap: () {
                    setState(() {
                      _selectedStatus =
                          status;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStatusNotice(
    BuildContext context,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.lock_outline,
              color:
                  AppColors.textSecondary,
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
                  'Final Booking State',
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
                  '$_currentStatus bookings are read-only in the current booking lifecycle.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessRuleNotice(
    BuildContext context,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding:
          const EdgeInsets.all(17),
      borderRadius: 17,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.warning
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
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
                  'Status Control',
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
                  'The backend must verify the current booking status, agency ownership, and requested transition before saving any change.',
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

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed:
            _isSaving
                ? null
                : _updateStatus,
        icon: _isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons
                    .published_with_changes_outlined,
              ),
        label: Text(
          _isSaving
              ? 'Validating Status...'
              : 'Update Booking Status',
        ),
      ),
    );
  }
}

class _StatusOptionCard
    extends StatelessWidget {
  const _StatusOptionCard({
    required this.status,
    required this.description,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String status;
  final String description;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        width: double.infinity,
        padding:
            const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(
                  alpha: 0.10,
                )
              : Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(
                    alpha: 0.35,
                  ),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color
                : Theme.of(context)
                    .dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
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
                    status,
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
                    description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons
                      .radio_button_checked
                  : Icons
                      .radio_button_unchecked,
              color: selected
                  ? color
                  : AppColors
                      .textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}