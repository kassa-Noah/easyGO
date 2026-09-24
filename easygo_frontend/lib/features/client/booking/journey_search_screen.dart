import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'trip_results_screen.dart';

class JourneySearchScreen
    extends StatefulWidget {
  final Map<String, dynamic> agency;
  final String bookingMode;

  const JourneySearchScreen({
    super.key,
    required this.agency,
    required this.bookingMode,
  });

  @override
  State<JourneySearchScreen> createState() =>
      _JourneySearchScreenState();
}

class _JourneySearchScreenState
    extends State<JourneySearchScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _pickupController =
      TextEditingController();

  final TextEditingController
      _finalDestinationController =
      TextEditingController();

  String? _departureCity;
  String? _destinationCity;

  DateTime? _travelDate;

  int _passengers = 1;
  int _luggage = 0;

  final List<String> _cities = const [
    'Yaoundé',
    'Douala',
    'Bafoussam',
    'Bamenda',
    'Buea',
    'Limbe',
  ];

  bool get _isDoorToDoor =>
      widget.bookingMode ==
      'door_to_door';

  @override
  void dispose() {
    _pickupController.dispose();
    _finalDestinationController
        .dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime now =
        DateTime.now();

    final DateTime? selected =
        await showDatePicker(
      context: context,
      initialDate:
          _travelDate ?? now,
      firstDate: now,
      lastDate: DateTime(
        now.year + 1,
        now.month,
        now.day,
      ),
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    setState(() {
      _travelDate = selected;
    });
  }

  void _searchTrips() {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_travelDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n.travelDateRequired,
          ),
        ),
      );

      return;
    }

    if (_departureCity ==
        _destinationCity) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .citiesMustBeDifferent,
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TripResultsScreen(
          agency: widget.agency,
          bookingMode:
              widget.bookingMode,
          departureCity:
              _departureCity!,
          destinationCity:
              _destinationCity!,
          pickupLocation:
              _isDoorToDoor
                  ? _pickupController
                      .text
                      .trim()
                  : null,
          finalDestination:
              _isDoorToDoor
                  ? _finalDestinationController
                      .text
                      .trim()
                  : null,
          travelDate:
              _travelDate!,
          passengers:
              _passengers,
          luggage: _luggage,
        ),
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    final String day = date.day
        .toString()
        .padLeft(2, '0');

    final String month = date.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final AppLocalizations l10n =
        AppLocalizations.of(context);

    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isDoorToDoor
              ? l10n.doorToDoorJourney
              : l10n.interurbanJourney,
        ),
      ),
      body: Container(
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
          child: Form(
            key: _formKey,
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
                              .start,
                      children: [
                        _buildServiceHeader(
                          l10n,
                        ),

                        const SizedBox(
                          height: 26,
                        ),

                        Text(
                          l10n
                              .journeyDetails,
                          style:
                              Theme.of(
                            context,
                          )
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          l10n
                              .journeyDetailsDescription,
                          style:
                              Theme.of(
                            context,
                          )
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    height:
                                        1.5,
                                  ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        GlassContainer(
                          padding:
                              const EdgeInsets
                                  .all(18),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              if (_isDoorToDoor) ...[
                                _buildLabel(
                                  l10n
                                      .pickupLocation,
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                TextFormField(
                                  controller:
                                      _pickupController,
                                  decoration:
                                      InputDecoration(
                                    hintText: l10n
                                        .pickupLocationHint,
                                    prefixIcon:
                                        const Icon(
                                      Icons
                                          .my_location_outlined,
                                    ),
                                  ),
                                  validator:
                                      (value) {
                                    if (value ==
                                            null ||
                                        value
                                            .trim()
                                            .isEmpty) {
                                      return l10n
                                          .pickupLocationRequired;
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(
                                  height: 20,
                                ),
                              ],

                              _buildLabel(
                                l10n
                                    .departureCity,
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              DropdownButtonFormField<
                                  String>(
                                initialValue:
                                    _departureCity,
                                isExpanded: true,
                                decoration:
                                    InputDecoration(
                                  prefixIcon:
                                      const Icon(
                                    Icons
                                        .location_city_outlined,
                                  ),
                                  hintText: l10n
                                      .selectDepartureCity,
                                ),
                                items: _cities
                                    .map(
                                      (
                                        city,
                                      ) =>
                                          DropdownMenuItem<
                                              String>(
                                        value:
                                            city,
                                        child:
                                            Text(
                                          city,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged:
                                    (value) {
                                  setState(
                                    () {
                                      _departureCity =
                                          value;
                                    },
                                  );
                                },
                                validator:
                                    (value) {
                                  if (value ==
                                      null) {
                                    return l10n
                                        .departureCityRequired;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              _buildLabel(
                                l10n
                                    .destinationCity,
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              DropdownButtonFormField<
                                  String>(
                                initialValue:
                                    _destinationCity,
                                isExpanded: true,
                                decoration:
                                    InputDecoration(
                                  prefixIcon:
                                      const Icon(
                                    Icons
                                        .flag_outlined,
                                  ),
                                  hintText: l10n
                                      .selectDestinationCity,
                                ),
                                items: _cities
                                    .map(
                                      (
                                        city,
                                      ) =>
                                          DropdownMenuItem<
                                              String>(
                                        value:
                                            city,
                                        child:
                                            Text(
                                          city,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged:
                                    (value) {
                                  setState(
                                    () {
                                      _destinationCity =
                                          value;
                                    },
                                  );
                                },
                                validator:
                                    (value) {
                                  if (value ==
                                      null) {
                                    return l10n
                                        .destinationCityRequired;
                                  }

                                  return null;
                                },
                              ),

                              if (_isDoorToDoor) ...[
                                const SizedBox(
                                  height: 20,
                                ),

                                _buildLabel(
                                  l10n
                                      .finalDestination,
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                TextFormField(
                                  controller:
                                      _finalDestinationController,
                                  decoration:
                                      InputDecoration(
                                    hintText: l10n
                                        .finalDestinationHint,
                                    prefixIcon:
                                        const Icon(
                                      Icons
                                          .home_outlined,
                                    ),
                                  ),
                                  validator:
                                      (value) {
                                    if (value ==
                                            null ||
                                        value
                                            .trim()
                                            .isEmpty) {
                                      return l10n
                                          .finalDestinationRequired;
                                    }

                                    return null;
                                  },
                                ),
                              ],

                              const SizedBox(
                                height: 20,
                              ),

                              _buildLabel(
                                l10n
                                    .travelDate,
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              InkWell(
                                onTap:
                                    _selectDate,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                                child:
                                    InputDecorator(
                                  decoration:
                                      const InputDecoration(
                                    prefixIcon:
                                        Icon(
                                      Icons
                                          .calendar_month_outlined,
                                    ),
                                  ),
                                  child: Text(
                                    _travelDate ==
                                            null
                                        ? l10n
                                            .selectTravelDate
                                        : _formatDate(
                                            _travelDate!,
                                          ),
                                    style:
                                        Theme.of(
                                      context,
                                    )
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: _travelDate ==
                                                      null
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        _CounterField(
                          title:
                              l10n.passengers,
                          subtitle: l10n
                              .passengersDescription,
                          icon: Icons
                              .people_outline,
                          value:
                              _passengers,
                          minimum: 1,
                          onChanged:
                              (value) {
                            setState(
                              () {
                                _passengers =
                                    value;
                              },
                            );
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        _CounterField(
                          title:
                              l10n.luggage,
                          subtitle: l10n
                              .luggageDescription,
                          icon: Icons
                              .luggage_outlined,
                          value: _luggage,
                          minimum: 0,
                          onChanged:
                              (value) {
                            setState(
                              () {
                                _luggage =
                                    value;
                              },
                            );
                          },
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        GlassContainer(
                          padding:
                              const EdgeInsets
                                  .all(14),
                          borderRadius: 15,
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Icon(
                                Icons
                                    .info_outline,
                                size: 20,
                                color:
                                    AppColors
                                        .primary,
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              Expanded(
                                child: Text(
                                  l10n
                                      .journeySearchInformation,
                                  style:
                                      Theme.of(
                                    context,
                                  )
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            height:
                                                1.5,
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              ElevatedButton
                                  .icon(
                            onPressed:
                                _searchTrips,
                            icon:
                                const Icon(
                              Icons.search,
                            ),
                            label: Text(
                              l10n
                                  .searchAvailableTrips,
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
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

  Widget _buildServiceHeader(
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(16),
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
            child: Icon(
              _isDoorToDoor
                  ? Icons
                      .local_taxi_outlined
                  : Icons
                      .directions_bus_outlined,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  widget.agency['name']
                          ?.toString() ??
                      l10n
                          .transportAgency,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _isDoorToDoor
                      ? l10n
                          .doorToDoorService
                      : l10n
                          .interurbanOnly,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    color:
                        AppColors
                            .secondary,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(
    String label,
  ) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(
            fontWeight:
                FontWeight.w600,
          ),
    );
  }
}

class _CounterField
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int value;
  final int minimum;
  final ValueChanged<int>
      onChanged;

  const _CounterField({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.minimum,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GlassContainer(
      padding:
          const EdgeInsets.all(15),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              size: 21,
              color:
                  AppColors.primary,
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
                  title,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  subtitle,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: '-',
            onPressed:
                value > minimum
                    ? () => onChanged(
                          value - 1,
                        )
                    : null,
            icon: const Icon(
              Icons
                  .remove_circle_outline,
            ),
          ),

          AnimatedSwitcher(
            duration:
                const Duration(
              milliseconds: 180,
            ),
            child: SizedBox(
              key: ValueKey<int>(
                value,
              ),
              width: 28,
              child: Text(
                '$value',
                textAlign:
                    TextAlign.center,
                style:
                    Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
              ),
            ),
          ),

          IconButton(
            tooltip: '+',
            onPressed: () =>
                onChanged(
              value + 1,
            ),
            icon: const Icon(
              Icons
                  .add_circle_outline,
              color:
                  AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}