import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _seatCapacityController = TextEditingController();

  static const List<String> _cities = [
    'Yaoundé',
    'Douala',
    'Bafoussam',
    'Bamenda',
    'Buea',
    'Limbe',
  ];

  static const List<String> _travelClasses = ['Classic', 'VIP'];

  String? _departureCity;
  String? _destinationCity;
  String? _travelClass;

  DateTime? _travelDate;
  TimeOfDay? _departureTime;
  TimeOfDay? _arrivalTime;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _seatCapacityController.dispose();
    super.dispose();
  }

  Future<void> _selectTravelDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? now.add(const Duration(days: 1)),
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
      initialTime: _departureTime ?? const TimeOfDay(hour: 7, minute: 0),
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
      initialTime: _arrivalTime ?? const TimeOfDay(hour: 11, minute: 0),
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _arrivalTime = selectedTime;
    });
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

    return '$day ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');

    final String minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  int _minutesFromMidnight(TimeOfDay time) {
    return (time.hour * 60) + time.minute;
  }

  String? _validatePositiveNumber(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    final int? number = int.tryParse(value.trim());

    if (number == null || number <= 0) {
      return 'Enter a valid $fieldName.';
    }

    return null;
  }

  bool _validateTripSchedule() {
    if (_travelDate == null) {
      _showMessage('Select the travel date.');
      return false;
    }

    if (_departureTime == null) {
      _showMessage('Select the departure time.');
      return false;
    }

    if (_arrivalTime == null) {
      _showMessage('Select the arrival time.');
      return false;
    }

    if (_departureCity == _destinationCity) {
      _showMessage('Departure and destination cities must be different.');
      return false;
    }

    final int departureMinutes = _minutesFromMidnight(_departureTime!);

    final int arrivalMinutes = _minutesFromMidnight(_arrivalTime!);

    if (arrivalMinutes <= departureMinutes) {
      _showMessage(
        'Arrival time must be after departure time for this prototype trip schedule.',
      );
      return false;
    }

    return true;
  }

  Future<void> _createTrip() async {
    FocusScope.of(context).unfocus();

    final bool formValid = _formKey.currentState?.validate() ?? false;

    if (!formValid) {
      return;
    }

    if (!_validateTripSchedule()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    await _showDemoConfirmation();
  }

  Future<void> _showDemoConfirmation() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 38,
          ),
          title: const Text('Trip Validated'),
          content: Text(
            'The trip from $_departureCity to '
            '$_destinationCity on '
            '${_formatDate(_travelDate!)} '
            'has passed frontend validation.\n\n'
            'No trip has been saved yet. '
            'The backend will create the real trip reference and persist the record.',
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
      appBar: AppBar(title: const Text('Create Trip')),
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
                      _buildAgencyHeader(context),
                      const SizedBox(height: 20),
                      _buildRouteSection(context),
                      const SizedBox(height: 18),
                      _buildScheduleSection(context),
                      const SizedBox(height: 18),
                      _buildServiceSection(context),
                      const SizedBox(height: 18),
                      _buildCapacitySection(context),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
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

  Widget _buildAgencyHeader(BuildContext context) {
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
              Icons.business_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'General Express',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'New trips are associated with the authenticated agency.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_user_outlined, color: AppColors.secondary),
        ],
      ),
    );
  }

  Widget _buildRouteSection(BuildContext context) {
    return _FormSection(
      title: 'Route',
      description: 'Define the interurban route operated by the agency.',
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
        setState(() {
          _departureCity = value;

          if (_destinationCity == value) {
            _destinationCity = null;
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
      initialValue: availableDestinations.contains(_destinationCity)
          ? _destinationCity
          : null,
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

  Widget _buildScheduleSection(BuildContext context) {
    return _FormSection(
      title: 'Schedule',
      description:
          'Set the travel date and planned departure and arrival times.',
      child: Column(
        children: [
          _SelectionField(
            label: 'Travel Date',
            value: _travelDate == null
                ? 'Select date'
                : _formatDate(_travelDate!),
            icon: Icons.calendar_today_outlined,
            onTap: _selectTravelDate,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 580;

              final Widget departure = _SelectionField(
                label: 'Departure Time',
                value: _departureTime == null
                    ? 'Select time'
                    : _formatTime(_departureTime!),
                icon: Icons.schedule_outlined,
                onTap: _selectDepartureTime,
              );

              final Widget arrival = _SelectionField(
                label: 'Arrival Time',
                value: _arrivalTime == null
                    ? 'Select time'
                    : _formatTime(_arrivalTime!),
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

  Widget _buildServiceSection(BuildContext context) {
    return _FormSection(
      title: 'Service Information',
      description: 'Define the travel class and passenger fare.',
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

          final Widget priceField = TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Passenger Fare',
              hintText: 'e.g. 7000',
              prefixIcon: Icon(Icons.payments_outlined),
              suffixText: 'FCFA',
            ),
            validator: (value) {
              return _validatePositiveNumber(value, fieldName: 'fare');
            },
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: classField),
                const SizedBox(width: 14),
                Expanded(child: priceField),
              ],
            );
          }

          return Column(
            children: [classField, const SizedBox(height: 14), priceField],
          );
        },
      ),
    );
  }

  Widget _buildCapacitySection(BuildContext context) {
    return _FormSection(
      title: 'Seat Capacity',
      description:
          'Specify the total number of passenger seats available for the trip.',
      child: TextFormField(
        controller: _seatCapacityController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Total Seat Capacity',
          hintText: 'e.g. 50',
          prefixIcon: Icon(Icons.airline_seat_recline_normal),
          suffixText: 'seats',
        ),
        validator: (value) {
          final String? error = _validatePositiveNumber(
            value,
            fieldName: 'seat capacity',
          );

          if (error != null) {
            return error;
          }

          final int seats = int.parse(value!.trim());

          if (seats > 100) {
            return 'Seat capacity cannot exceed 100 in this prototype.';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSubmitting ? null : _createTrip,
        icon: _isSubmitting
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_road_outlined),
        label: Text(_isSubmitting ? 'Validating Trip...' : 'Create Trip'),
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
