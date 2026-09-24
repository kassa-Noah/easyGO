import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class ManageTripAvailabilityScreen extends StatefulWidget {
  const ManageTripAvailabilityScreen({
    super.key,
    required this.trip,
  });

  final Map<String, dynamic> trip;

  @override
  State<ManageTripAvailabilityScreen> createState() =>
      _ManageTripAvailabilityScreenState();
}

class _ManageTripAvailabilityScreenState
    extends State<ManageTripAvailabilityScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _capacityController;

  late int _currentCapacity;
  late int _bookedSeats;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _currentCapacity =
        widget.trip['totalSeats'] as int;

    _bookedSeats =
        widget.trip['bookedSeats'] as int;

    _capacityController =
        TextEditingController(
      text: _currentCapacity.toString(),
    );

    _capacityController.addListener(
      _refreshPreview,
    );
  }

  @override
  void dispose() {
    _capacityController.removeListener(
      _refreshPreview,
    );
    _capacityController.dispose();

    super.dispose();
  }

  void _refreshPreview() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  int get _enteredCapacity {
    return int.tryParse(
          _capacityController.text.trim(),
        ) ??
        0;
  }

  int get _previewAvailableSeats {
    final int capacity =
        _enteredCapacity;

    if (capacity < _bookedSeats) {
      return 0;
    }

    return capacity - _bookedSeats;
  }

  double get _previewOccupancy {
    final int capacity =
        _enteredCapacity;

    if (capacity <= 0) {
      return 0;
    }

    final double value =
        _bookedSeats / capacity;

    return value.clamp(
      0.0,
      1.0,
    );
  }

  String? _validateCapacity(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Total seat capacity is required.';
    }

    final int? capacity =
        int.tryParse(
      value.trim(),
    );

    if (capacity == null ||
        capacity <= 0) {
      return 'Enter a valid seat capacity.';
    }

    if (capacity < _bookedSeats) {
      return 'Capacity cannot be lower than $_bookedSeats booked seats.';
    }

    if (capacity > 100) {
      return 'Seat capacity cannot exceed 100 in this prototype.';
    }

    return null;
  }

  Future<void> _saveAvailability() async {
    FocusScope.of(context).unfocus();

    final bool valid =
        _formKey.currentState
                ?.validate() ??
            false;

    if (!valid) {
      return;
    }

    final int newCapacity =
        int.parse(
      _capacityController.text.trim(),
    );

    if (newCapacity ==
        _currentCapacity) {
      _showMessage(
        'No capacity change has been made.',
      );
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

    setState(() {
      _isSaving = false;
    });

    await _showDemoConfirmation(
      newCapacity,
    );
  }

  Future<void> _showDemoConfirmation(
    int newCapacity,
  ) async {
    final int availableSeats =
        newCapacity - _bookedSeats;

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 38,
          ),
          title: const Text(
            'Availability Validated',
          ),
          content: Text(
            'The capacity change for '
            '${widget.trip['id']} has passed '
            'frontend validation.\n\n'
            'Previous capacity: '
            '$_currentCapacity seats\n'
            'New capacity: '
            '$newCapacity seats\n'
            'Booked seats: '
            '$_bookedSeats\n'
            'Available seats: '
            '$availableSeats\n\n'
            'No database record has been updated yet. '
            'The backend will perform the real availability update.',
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
                'Close',
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
                'Apply Demo Change',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        confirmed != true) {
      return;
    }

    setState(() {
      _currentCapacity =
          newCapacity;
    });

    _showMessage(
      'Demo availability updated locally on this screen.',
    );
  }

  void _resetCapacity() {
    _capacityController.text =
        _currentCapacity.toString();

    FocusScope.of(context).unfocus();
  }

  void _increaseCapacity() {
    final int current =
        _enteredCapacity;

    if (current >= 100) {
      _showMessage(
        'Prototype capacity limit is 100 seats.',
      );
      return;
    }

    _capacityController.text =
        (current + 1).toString();
  }

  void _decreaseCapacity() {
    final int current =
        _enteredCapacity;

    if (current <= _bookedSeats) {
      _showMessage(
        'Capacity cannot be lower than the number of booked seats.',
      );
      return;
    }

    _capacityController.text =
        (current - 1).toString();
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
          'Trip Availability',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildTripHeader(
                        context,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      _buildCurrentAvailability(
                        context,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      _buildCapacityEditor(
                        context,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      _buildPreview(
                        context,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      _buildBusinessRuleNotice(
                        context,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripHeader(
    BuildContext context,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding:
          const EdgeInsets.all(17),
      borderRadius: 17,
      child: Row(
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
              Icons.event_seat_outlined,
              color: AppColors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.trip['departureCity']} → '
                  '${widget.trip['destinationCity']}',
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
                  '${widget.trip['id']} • '
                  '${widget.trip['date']}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: const Text(
              'Scheduled',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAvailability(
    BuildContext context,
  ) {
    final int availableSeats =
        _currentCapacity -
            _bookedSeats;

    final double occupancy =
        _currentCapacity == 0
            ? 0
            : _bookedSeats /
                _currentCapacity;

    return GlassContainer(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            'Current Availability',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _AvailabilityValue(
                  value:
                      '$_currentCapacity',
                  label:
                      'Total Seats',
                ),
              ),
              _verticalDivider(
                context,
              ),
              Expanded(
                child: _AvailabilityValue(
                  value:
                      '$_bookedSeats',
                  label:
                      'Booked',
                ),
              ),
              _verticalDivider(
                context,
              ),
              Expanded(
                child: _AvailabilityValue(
                  value:
                      '$availableSeats',
                  label:
                      'Available',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Current occupancy',
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                ),
              ),
              Text(
                '${(occupancy * 100).round()}%',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            child:
                LinearProgressIndicator(
              value: occupancy,
              minHeight: 7,
              backgroundColor:
                  AppColors.primary
                      .withValues(
                alpha: 0.10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityEditor(
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
          _sectionTitle(
            context,
            'Update Capacity',
          ),
          const SizedBox(height: 5),
          Text(
            'Change the total number of seats available on this vehicle.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              IconButton.filledTonal(
                tooltip:
                    'Decrease capacity',
                onPressed:
                    _decreaseCapacity,
                icon: const Icon(
                  Icons.remove,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller:
                      _capacityController,
                  keyboardType:
                      TextInputType.number,
                  textAlign:
                      TextAlign.center,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Total Seat Capacity',
                    suffixText:
                        'seats',
                  ),
                  validator:
                      _validateCapacity,
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip:
                    'Increase capacity',
                onPressed:
                    _increaseCapacity,
                icon: const Icon(
                  Icons.add,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(
    BuildContext context,
  ) {
    final int capacity =
        _enteredCapacity;

    final bool valid =
        capacity >= _bookedSeats &&
            capacity > 0 &&
            capacity <= 100;

    return GlassContainer(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  context,
                  'Availability Preview',
                ),
              ),
              Icon(
                valid
                    ? Icons
                        .check_circle_outline
                    : Icons.error_outline,
                color: valid
                    ? AppColors.success
                    : AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PreviewItem(
                  label:
                      'New Capacity',
                  value: capacity > 0
                      ? '$capacity'
                      : '—',
                ),
              ),
              Expanded(
                child: _PreviewItem(
                  label:
                      'Booked Seats',
                  value:
                      '$_bookedSeats',
                ),
              ),
              Expanded(
                child: _PreviewItem(
                  label:
                      'Available',
                  value: valid
                      ? '$_previewAvailableSeats'
                      : '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Projected occupancy',
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                ),
              ),
              Text(
                valid
                    ? '${(_previewOccupancy * 100).round()}%'
                    : '—',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            child:
                LinearProgressIndicator(
              value: valid
                  ? _previewOccupancy
                  : 0,
              minHeight: 7,
              backgroundColor:
                  AppColors.primary
                      .withValues(
                alpha: 0.10,
              ),
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
          const EdgeInsets.all(16),
      borderRadius: 16,
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
              Icons
                  .shield_outlined,
              color:
                  AppColors.warning,
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
                  'Booking Protection',
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
                  'The total capacity cannot be reduced below the number of seats already booked. The backend must enforce this rule again before saving.',
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

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed:
                _isSaving
                    ? null
                    : _saveAvailability,
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
                        .save_outlined,
                  ),
            label: Text(
              _isSaving
                  ? 'Validating Availability...'
                  : 'Update Availability',
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child:
              OutlinedButton.icon(
            onPressed:
                _isSaving
                    ? null
                    : _resetCapacity,
            icon: const Icon(
              Icons.refresh_outlined,
            ),
            label: const Text(
              'Reset Changes',
            ),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider(
    BuildContext context,
  ) {
    return Container(
      width: 1,
      height: 52,
      color: Theme.of(context)
          .dividerColor,
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
            fontWeight:
                FontWeight.bold,
          ),
    );
  }
}

class _AvailabilityValue
    extends StatelessWidget {
  const _AvailabilityValue({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign:
              TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }
}

class _PreviewItem
    extends StatelessWidget {
  const _PreviewItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign:
              TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .labelSmall,
        ),
      ],
    );
  }
}