import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class EditTripScreen extends StatefulWidget {
  const EditTripScreen({super.key, required this.trip});

  final Map<String, dynamic> trip;

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _priceController;

  static const List<String> _cities = [
    'Yaoundé',
    'Douala',
    'Bafoussam',
    'Bamenda',
    'Buea',
    'Limbe',
  ];

  static const List<String> _travelClasses = ['Classic', 'VIP'];

  late String _departureCity;
  late String _destinationCity;
  late String _travelClass;

  late DateTime _travelDate;
  late TimeOfDay _departureTime;
  late TimeOfDay _arrivalTime;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _departureCity = widget.trip['departureCity'] as String;

    _destinationCity = widget.trip['destinationCity'] as String;

    _travelClass = widget.trip['travelClass'] as String;

    _priceController = TextEditingController(
      text: (widget.trip['price'] as int).toString(),
    );

    _travelDate = _parseTripDate(widget.trip['date'] as String);

    _departureTime = _parseTripTime(widget.trip['departureTime'] as String);

    _arrivalTime = _parseTripTime(widget.trip['arrivalTime'] as String);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  DateTime _parseTripDate(String value) {
    final List<String> parts = value.trim().split(' ');

    if (parts.length != 3) {
      return DateTime.now();
    }

    const Map<String, int> months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    final int? day = int.tryParse(parts[0]);

    final int? month = months[parts[1]];

    final int? year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return DateTime.now();
    }

    return DateTime(year, month, day);
  }

  TimeOfDay _parseTripTime(String value) {
    final List<String> parts = value.trim().split(':');

    if (parts.length != 2) {
      return const TimeOfDay(hour: 7, minute: 0);
    }

    final int? hour = int.tryParse(parts[0]);

    final int? minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return const TimeOfDay(hour: 7, minute: 0);
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final String day = date.day.toString().padLeft(2, '0');

    return '$day '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');

    final String minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  int _minutesFromMidnight(TimeOfDay time) {
    return (time.hour * 60) + time.minute;
  }

  Future<void> _selectTravelDate() async {
    final DateTime now = DateTime.now();

    DateTime initialDate = _travelDate;

    if (initialDate.isBefore(now)) {
      initialDate = now;
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 2, 12, 31),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _travelDate = selectedDate;
    });
  }

  Future<void> _selectDepartureTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _departureTime,
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _departureTime = selectedTime;
    });
  }

  Future<void> _selectArrivalTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _arrivalTime,
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _arrivalTime = selectedTime;
    });
  }

  String? _validateFare(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Passenger fare is required.';
    }

    final int? fare = int.tryParse(value.trim());

    if (fare == null || fare <= 0) {
      return 'Enter a valid passenger fare.';
    }

    return null;
  }

  bool _validateSchedule() {
    if (_departureCity == _destinationCity) {
      _showMessage('Departure and destination cities must be different.');

      return false;
    }

    final int departureMinutes = _minutesFromMidnight(_departureTime);

    final int arrivalMinutes = _minutesFromMidnight(_arrivalTime);

    if (arrivalMinutes <= departureMinutes) {
      _showMessage(
        'Arrival time must be after departure time for this prototype trip schedule.',
      );

      return false;
    }

    return true;
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    final bool formValid = _formKey.currentState?.validate() ?? false;

    if (!formValid) {
      return;
    }

    if (!_validateSchedule()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    await _showDemoConfirmation();
  }

  Future<void> _showDemoConfirmation() async {
    final int fare = int.parse(_priceController.text.trim());

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 38,
          ),
          title: const Text('Changes Validated'),
          content: Text(
            'The changes for '
            '${widget.trip['id']} have passed '
            'frontend validation.\n\n'
            'Route: $_departureCity → '
            '$_destinationCity\n'
            'Date: ${_formatDate(_travelDate)}\n'
            'Schedule: '
            '${_formatTime(_departureTime)} – '
            '${_formatTime(_arrivalTime)}\n'
            'Class: $_travelClass\n'
            'Fare: $fare FCFA\n\n'
            'No database record has been updated yet. '
            'The backend will perform the real update.',
          ),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Trip')),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTripIdentity(context),
                      const SizedBox(height: 18),
                      _buildRouteSection(),
                      const SizedBox(height: 18),
                      _buildScheduleSection(),
                      const SizedBox(height: 18),
                      _buildServiceSection(),
                      const SizedBox(height: 18),
                      _buildCapacityNotice(context),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
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

  Widget _buildTripIdentity(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      borderRadius: 17,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.edit_road_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.trip['id'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'General Express • Scheduled Trip',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Scheduled',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection() {
    return _FormSection(
      title: 'Route',
      description: 'Update the departure and destination cities.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 580;

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _departureField()),
                const SizedBox(width: 14),
                Expanded(child: _destinationField()),
              ],
            );
          }

          return Column(
            children: [
              _departureField(),
              const SizedBox(height: 14),
              _destinationField(),
            ],
          );
        },
      ),
    );
  }

  Widget _departureField() {
    return DropdownButtonFormField<String>(
      initialValue: _departureCity,
      decoration: const InputDecoration(
        labelText: 'Departure City',
        prefixIcon: Icon(Icons.trip_origin),
      ),
      items: _cities
          .map(
            (city) => DropdownMenuItem<String>(value: city, child: Text(city)),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _departureCity = value;

          if (_destinationCity == value) {
            _destinationCity = _cities.firstWhere((city) => city != value);
          }
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Select a departure city.';
        }

        return null;
      },
    );
  }

  Widget _destinationField() {
    final List<String> availableDestinations = _cities
        .where((city) => city != _departureCity)
        .toList();

    return DropdownButtonFormField<String>(
      key: ValueKey('destination-$_departureCity-$_destinationCity'),
      initialValue: availableDestinations.contains(_destinationCity)
          ? _destinationCity
          : availableDestinations.first,
      decoration: const InputDecoration(
        labelText: 'Destination City',
        prefixIcon: Icon(Icons.location_on_outlined),
      ),
      items: availableDestinations
          .map(
            (city) => DropdownMenuItem<String>(value: city, child: Text(city)),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _destinationCity = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Select a destination city.';
        }

        return null;
      },
    );
  }

  Widget _buildScheduleSection() {
    return _FormSection(
      title: 'Schedule',
      description: 'Update the travel date and planned times.',
      child: Column(
        children: [
          _SelectionField(
            label: 'Travel Date',
            value: _formatDate(_travelDate),
            icon: Icons.calendar_today_outlined,
            onTap: _selectTravelDate,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 580;

              final Widget departure = _SelectionField(
                label: 'Departure Time',
                value: _formatTime(_departureTime),
                icon: Icons.schedule_outlined,
                onTap: _selectDepartureTime,
              );

              final Widget arrival = _SelectionField(
                label: 'Arrival Time',
                value: _formatTime(_arrivalTime),
                icon: Icons.access_time_outlined,
                onTap: _selectArrivalTime,
              );

              if (wide) {
                return Row(
                  children: [
                    Expanded(child: departure),
                    const SizedBox(width: 14),
                    Expanded(child: arrival),
                  ],
                );
              }

              return Column(
                children: [departure, const SizedBox(height: 14), arrival],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection() {
    return _FormSection(
      title: 'Service Information',
      description: 'Update the travel class and passenger fare.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 580;

          final Widget classField = DropdownButtonFormField<String>(
            initialValue: _travelClass,
            decoration: const InputDecoration(
              labelText: 'Travel Class',
              prefixIcon: Icon(Icons.event_seat_outlined),
            ),
            items: _travelClasses
                .map(
                  (travelClass) => DropdownMenuItem<String>(
                    value: travelClass,
                    child: Text(travelClass),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _travelClass = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Select a travel class.';
              }

              return null;
            },
          );

          final Widget fareField = TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Passenger Fare',
              prefixIcon: Icon(Icons.payments_outlined),
              suffixText: 'FCFA',
            ),
            validator: _validateFare,
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: classField),
                const SizedBox(width: 14),
                Expanded(child: fareField),
              ],
            );
          }

          return Column(
            children: [classField, const SizedBox(height: 14), fareField],
          );
        },
      ),
    );
  }

  Widget _buildCapacityNotice(BuildContext context) {
    final int totalSeats = widget.trip['totalSeats'] as int;

    final int bookedSeats = widget.trip['bookedSeats'] as int;

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
              Icons.event_seat_outlined,
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
                  'Seat Capacity',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$bookedSeats of $totalSeats seats are currently booked.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Capacity and seat availability are managed separately to protect existing bookings.',
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _saveChanges,
        icon: _isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_isSaving ? 'Validating Changes...' : 'Save Changes'),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
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
          const SizedBox(height: 5),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SelectionField extends StatelessWidget {
  const _SelectionField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.chevron_right),
        ),
        child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
