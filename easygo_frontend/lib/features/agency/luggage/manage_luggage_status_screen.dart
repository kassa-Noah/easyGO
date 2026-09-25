import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../models/agency_console.dart';
import '../services/agency_console_service.dart';

class ManageLuggageStatusScreen extends StatefulWidget {
  const ManageLuggageStatusScreen({super.key, required this.luggage});

  final Map<String, dynamic> luggage;

  @override
  State<ManageLuggageStatusScreen> createState() =>
      _ManageLuggageStatusScreenState();
}

class _ManageLuggageStatusScreenState extends State<ManageLuggageStatusScreen> {
  static const List<String> _statuses = luggageLifecycle;

  final AgencyConsoleService _console = AgencyConsoleService.instance;

  late String _currentStatus;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _currentStatus = widget.luggage['status'] as String;
  }

  int get _currentIndex {
    return _statuses.indexOf(_currentStatus);
  }

  bool get _isFinalStatus => _currentStatus == 'Delivered';

  String? get _nextStatus {
    final int index = _currentIndex;

    if (index < 0 || index >= _statuses.length - 1) {
      return null;
    }

    return _statuses[index + 1];
  }

  double get _progress {
    final int index = _currentIndex;

    if (index < 0) {
      return 0;
    }

    return index / (_statuses.length - 1);
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
        return Icons.luggage_outlined;
    }
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'Registered':
        return 'The luggage has been registered in the easyGO system.';

      case 'Received by Agency':
        return 'Agency staff have physically received the luggage.';

      case 'Loaded':
        return 'The luggage has been loaded for the interurban journey.';

      case 'In Transit':
        return 'The luggage is currently moving between the departure and destination cities.';

      case 'Arrived':
        return 'The luggage has reached the destination city or agency.';

      case 'Ready for Collection':
        return 'The luggage has been processed and is ready for collection or the next delivery stage.';

      case 'Delivered':
        return 'The luggage has reached the end of its tracking lifecycle.';

      default:
        return '';
    }
  }

  Future<void> _advanceStatus() async {
    final String? next = _nextStatus;

    if (next == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(_statusIcon(next), color: _statusColor(next), size: 38),
          title: const Text('Confirm Tracking Update'),
          content: Text(
            'Advance luggage '
            '${widget.luggage['trackingNumber'] ?? widget.luggage['id']} '
            'from $_currentStatus to $next?\n\n'
            'Tracking stages cannot be skipped '
            'or moved backward in the current lifecycle.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Keep Current Status'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirm Update'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final String trackingNumber =
        widget.luggage['trackingNumber']?.toString() ??
        widget.luggage['id'].toString();

    try {
      await _console.updateLuggageStatus(
        luggageId: widget.luggage['id'] as String,
        status: luggageStatusToApi(next),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _currentStatus = next;
      });

      await _showResult(
        title: 'Tracking Status Updated',
        message:
            'Luggage $trackingNumber is now recorded as "$next". '
            'The new tracking event is visible to the traveler.',
        isError: false,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      await _showResult(
        title: 'Update Failed',
        message: error.message,
        isError: true,
      );
    }
  }

  Future<void> _showResult({
    required String title,
    required String message,
    required bool isError,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppColors.error : AppColors.success,
            size: 38,
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Update Tracking Status')),
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
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLuggageHeader(context),
                    const SizedBox(height: 18),
                    _buildCurrentStatus(context),
                    const SizedBox(height: 18),
                    if (!_isFinalStatus)
                      _buildNextStatus(context)
                    else
                      _buildFinalState(context),
                    const SizedBox(height: 18),
                    _buildLifecycle(context),
                    const SizedBox(height: 18),
                    _buildBusinessRuleNotice(context),
                    if (!_isFinalStatus) ...[
                      const SizedBox(height: 24),
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

  Widget _buildLuggageHeader(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.luggage_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.luggage['id'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.luggage['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 3),
                Text(
                  widget.luggage['clientName'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(BuildContext context) {
    final Color color = _statusColor(_currentStatus);

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Tracking Status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon(_currentStatus), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentStatus,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusDescription(_currentStatus),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tracking progress',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '${(_progress * 100).round()}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 7,
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStatus(BuildContext context) {
    final String next = _nextStatus!;

    final Color color = _statusColor(next);

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Valid Status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_statusIcon(next), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      next,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusDescription(next),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(height: 1.4),
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

  Widget _buildFinalState(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_outline, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking Complete',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Delivered is the final state of the luggage tracking lifecycle.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifecycle(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Lifecycle',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          ...List.generate(_statuses.length, (index) {
            final String status = _statuses[index];

            final bool completed = index < _currentIndex;

            final bool current = index == _currentIndex;

            final bool next = index == _currentIndex + 1;

            return _LifecycleStage(
              status: status,
              completed: completed,
              current: current,
              next: next,
              showConnector: index < _statuses.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBusinessRuleNotice(BuildContext context) {
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
                  'Tracking Integrity',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'The backend must verify agency ownership and the current luggage status before accepting the next tracking stage. Flutter must not be the authoritative tracking source.',
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

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _advanceStatus,
        icon: _isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.published_with_changes_outlined),
        label: Text(
          _isSaving ? 'Validating Update...' : 'Advance to $_nextStatus',
        ),
      ),
    );
  }
}

class _LifecycleStage extends StatelessWidget {
  const _LifecycleStage({
    required this.status,
    required this.completed,
    required this.current,
    required this.next,
    required this.showConnector,
  });

  final String status;
  final bool completed;
  final bool current;
  final bool next;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final Color color = completed
        ? AppColors.success
        : current
        ? AppColors.primary
        : next
        ? AppColors.warning
        : AppColors.textLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: color),
              ),
              child: Icon(
                completed
                    ? Icons.check
                    : current
                    ? Icons.radio_button_checked
                    : next
                    ? Icons.arrow_downward
                    : Icons.circle_outlined,
                size: 14,
                color: color,
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 27,
                color: completed
                    ? AppColors.success.withValues(alpha: 0.40)
                    : Theme.of(context).dividerColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: current ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (current)
                  const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  )
                else if (next)
                  const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
