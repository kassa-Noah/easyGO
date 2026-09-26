// Models for the administrator console.
//
// Every value here comes from the running API; nothing is derived from a
// fixture. Where the backend has no equivalent of something the interface used
// to show, the model simply does not carry it, so the screen cannot display a
// number the platform cannot produce.

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String? _toNullableString(dynamic value) {
  final String? text = value?.toString();

  if (text == null || text.isEmpty) {
    return null;
  }

  return text;
}

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

List<dynamic> _toList(dynamic value) {
  if (value is List) {
    return value;
  }

  return const <dynamic>[];
}

DateTime? _toNullableDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}

/// Groups a number with thousands separators, the way the console displays
/// counts.
String formatAdminCount(int value) {
  final String digits = value.abs().toString();

  final StringBuffer buffer = StringBuffer();

  for (int index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }

    buffer.write(digits[index]);
  }

  return value < 0 ? '-$buffer' : buffer.toString();
}

/// Formats an instant as `dd/MM/yyyy`, the date style the console uses.
String formatAdminDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';

/// Formats an instant as `dd/MM/yyyy • HH:mm`.
String formatAdminDateTime(DateTime value) =>
    '${formatAdminDate(value)} • '
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

/// Formats an amount the way fares and payments are displayed.
String formatAdminAmount(num value) {
  final int whole = value.round();

  return '${formatAdminCount(whole)} FCFA';
}

/// Platform-wide counters returned by `GET /api/admin/statistics`.
class AdminStatistics {
  final int usersTotal;
  final int usersActive;
  final int usersCustomers;
  final int usersAgencyStaff;

  final int agenciesTotal;
  final int agenciesActive;

  final int tripsTotal;
  final int tripsScheduled;
  final int tripsArrived;

  final int bookingsTotal;
  final int bookingsPending;
  final int bookingsConfirmed;
  final int bookingsCompleted;
  final int bookingsCancelled;

  final int paymentsTotal;
  final int paymentsSuccessful;
  final int paymentsPending;
  final int paymentsFailed;
  final double paymentsSuccessfulAmount;

  final int ticketsTotal;

  final int luggageTotal;
  final int luggageDelivered;
  final int luggageLost;

  final int parcelsTotal;
  final int parcelsDelivered;
  final int parcelsCollected;
  final int parcelsLost;

  final int journeysTotal;
  final int journeysCompleted;

  final int reviewsTotal;

  const AdminStatistics({
    required this.usersTotal,
    required this.usersActive,
    required this.usersCustomers,
    required this.usersAgencyStaff,
    required this.agenciesTotal,
    required this.agenciesActive,
    required this.tripsTotal,
    required this.tripsScheduled,
    required this.tripsArrived,
    required this.bookingsTotal,
    required this.bookingsPending,
    required this.bookingsConfirmed,
    required this.bookingsCompleted,
    required this.bookingsCancelled,
    required this.paymentsTotal,
    required this.paymentsSuccessful,
    required this.paymentsPending,
    required this.paymentsFailed,
    required this.paymentsSuccessfulAmount,
    required this.ticketsTotal,
    required this.luggageTotal,
    required this.luggageDelivered,
    required this.luggageLost,
    required this.parcelsTotal,
    required this.parcelsDelivered,
    required this.parcelsCollected,
    required this.parcelsLost,
    required this.journeysTotal,
    required this.journeysCompleted,
    required this.reviewsTotal,
  });

  factory AdminStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> block(String key) =>
        _toMap(json[key]) ?? <String, dynamic>{};

    final Map<String, dynamic> users = block('users');
    final Map<String, dynamic> agencies = block('agencies');
    final Map<String, dynamic> trips = block('trips');
    final Map<String, dynamic> bookings = block('bookings');
    final Map<String, dynamic> payments = block('payments');
    final Map<String, dynamic> tickets = block('tickets');
    final Map<String, dynamic> luggage = block('luggage');
    final Map<String, dynamic> parcels = block('parcels');
    final Map<String, dynamic> journeys = block('journeys');
    final Map<String, dynamic> reviews = block('reviews');

    return AdminStatistics(
      usersTotal: _toInt(users['total']),
      usersActive: _toInt(users['active']),
      usersCustomers: _toInt(users['customers']),
      usersAgencyStaff: _toInt(users['agencyStaff']),
      agenciesTotal: _toInt(agencies['total']),
      agenciesActive: _toInt(agencies['active']),
      tripsTotal: _toInt(trips['total']),
      tripsScheduled: _toInt(trips['scheduled']),
      tripsArrived: _toInt(trips['arrived']),
      bookingsTotal: _toInt(bookings['total']),
      bookingsPending: _toInt(bookings['pending']),
      bookingsConfirmed: _toInt(bookings['confirmed']),
      bookingsCompleted: _toInt(bookings['completed']),
      bookingsCancelled: _toInt(bookings['cancelled']),
      paymentsTotal: _toInt(payments['total']),
      paymentsSuccessful: _toInt(payments['successful']),
      paymentsPending: _toInt(payments['pending']),
      paymentsFailed: _toInt(payments['failed']),
      paymentsSuccessfulAmount: _toDouble(payments['totalSuccessfulAmount']),
      ticketsTotal: _toInt(tickets['total']),
      luggageTotal: _toInt(luggage['total']),
      luggageDelivered: _toInt(luggage['delivered']),
      luggageLost: _toInt(luggage['lost']),
      parcelsTotal: _toInt(parcels['total']),
      parcelsDelivered: _toInt(parcels['delivered']),
      parcelsCollected: _toInt(parcels['collected']),
      parcelsLost: _toInt(parcels['lost']),
      journeysTotal: _toInt(journeys['total']),
      journeysCompleted: _toInt(journeys['completed']),
      reviewsTotal: _toInt(reviews['total']),
    );
  }

  /// Agencies that are currently disabled. The platform stores a single active
  /// flag, so there is no separate "pending review" state to report.
  int get agenciesInactive => agenciesTotal - agenciesActive;
}

/// An account as the administrator console sees it.
class AdminAccount {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  const AdminAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory AdminAccount.fromJson(Map<String, dynamic> json) {
    return AdminAccount(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: _toNullableString(json['phone']),
      role: json['role']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      createdAt: _toNullableDateTime(json['createdAt']),
    );
  }

  String get fullName => [firstName, lastName]
      .where((String part) => part.isNotEmpty)
      .join(' ');

  String get statusLabel => isActive ? 'Active' : 'Suspended';
}

/// An agency as the administrator console sees it.
class AdminAgency {
  final String id;
  final String name;
  final String? description;
  final String? phone;
  final String? email;
  final String? website;
  final bool isActive;
  final DateTime? createdAt;
  final List<String> branchCities;
  final int branchCount;
  final int tripCount;
  final int vehicleCount;
  final int staffCount;

  const AdminAgency({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.email,
    required this.website,
    required this.isActive,
    required this.createdAt,
    required this.branchCities,
    required this.branchCount,
    required this.tripCount,
    required this.vehicleCount,
    required this.staffCount,
  });

  factory AdminAgency.fromJson(Map<String, dynamic> json) {
    final List<String> cities = <String>[];

    for (final dynamic item in _toList(json['branches'])) {
      final Map<String, dynamic>? branch = _toMap(item);
      final String? city = _toNullableString(branch?['city']);

      if (city != null && !cities.contains(city)) {
        cities.add(city);
      }
    }

    // The admin endpoint counts the related records; fall back to the branches
    // it also returns when a response carries no counts.
    final Map<String, dynamic>? counts = _toMap(json['_count']);

    return AdminAgency(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: _toNullableString(json['description']),
      phone: _toNullableString(json['phone']),
      email: _toNullableString(json['email']),
      website: _toNullableString(json['website']),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: _toNullableDateTime(json['createdAt']),
      branchCities: cities,
      branchCount: counts == null
          ? cities.length
          : _toInt(counts['branches']),
      tripCount: _toInt(counts?['trips']),
      vehicleCount: _toInt(counts?['vehicles']),
      staffCount: _toInt(counts?['staff']),
    );
  }

  String get cityLabel => branchCities.isEmpty ? '—' : branchCities.join(', ');

  /// The platform stores one active flag, so an agency is either active or
  /// disabled. There is no separate "pending verification" state to claim.
  String get statusLabel => isActive ? 'Active' : 'Suspended';
}

/// Turns a stored enum such as `ARRIVED_AT_DESTINATION_AGENCY` into a readable
/// label, used as the fallback for any state without explicit wording.
String _humanise(String status) {
  if (status.isEmpty) {
    return '—';
  }

  return status
      .toLowerCase()
      .split('_')
      .map(
        (String word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

/// The trip states the monitor list shows.
String adminTripStatusLabel(String status) => switch (status) {
  'SCHEDULED' => 'Scheduled',
  'BOARDING' => 'Boarding',
  'DEPARTED' => 'In Progress',
  'ARRIVED' => 'Completed',
  'CANCELLED' => 'Cancelled',
  _ => _humanise(status),
};

/// The booking states the monitor list shows.
String adminBookingStatusLabel(String status) => switch (status) {
  'PENDING' => 'Pending',
  'CONFIRMED' => 'Confirmed',
  'COMPLETED' => 'Completed',
  'CANCELLED' => 'Cancelled',
  _ => _humanise(status),
};

/// The luggage and parcel states the monitor lists show. Both use the same
/// wording; luggage calls the first hand-over RECEIVED_AT_AGENCY while parcels
/// call it RECEIVED_AT_ORIGIN_AGENCY.
String adminTrackingStatusLabel(String status) => switch (status) {
  'RECEIVED_AT_AGENCY' || 'RECEIVED_AT_ORIGIN_AGENCY' => 'Received by agency',
  'ARRIVED_AT_DESTINATION_AGENCY' => 'Arrived',
  'READY_FOR_COLLECTION' => 'Ready for collection',
  'IN_TRANSIT' => 'In transit',
  _ => _humanise(status),
};

/// A trip as the platform monitor shows it.
class AdminTripRow {
  final String id;
  final String originCity;
  final String destinationCity;
  final String? agencyName;
  final DateTime? departureTime;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final String status;

  const AdminTripRow({
    required this.id,
    required this.originCity,
    required this.destinationCity,
    required this.agencyName,
    required this.departureTime,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
  });

  factory AdminTripRow.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? route = _toMap(json['route']);
    final Map<String, dynamic>? origin = _toMap(route?['originBranch']);
    final Map<String, dynamic>? destination = _toMap(
      route?['destinationBranch'],
    );

    return AdminTripRow(
      id: json['id']?.toString() ?? '',
      originCity: origin?['city']?.toString() ?? '',
      destinationCity: destination?['city']?.toString() ?? '',
      agencyName: _toNullableString(_toMap(json['agency'])?['name']),
      departureTime: _toNullableDateTime(json['departureTime']),
      price: _toDouble(json['price']),
      totalSeats: _toInt(json['totalSeats']),
      availableSeats: _toInt(json['availableSeats']),
      status: adminTripStatusLabel(json['status']?.toString() ?? ''),
    );
  }

  String get routeLabel => '$originCity → $destinationCity';

  int get bookedSeats {
    final int booked = totalSeats - availableSeats;

    return booked < 0 ? 0 : booked;
  }
}

/// A booking as the platform monitor shows it.
class AdminBookingRow {
  final String id;
  final String bookingReference;
  final String passengerName;
  final String? agencyName;
  final String originCity;
  final String destinationCity;
  final DateTime? departureTime;
  final double totalAmount;
  final int numberOfSeats;
  final String status;

  const AdminBookingRow({
    required this.id,
    required this.bookingReference,
    required this.passengerName,
    required this.agencyName,
    required this.originCity,
    required this.destinationCity,
    required this.departureTime,
    required this.totalAmount,
    required this.numberOfSeats,
    required this.status,
  });

  factory AdminBookingRow.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? user = _toMap(json['user']);
    final Map<String, dynamic>? trip = _toMap(json['trip']);
    final Map<String, dynamic>? route = _toMap(trip?['route']);
    final Map<String, dynamic>? origin = _toMap(route?['originBranch']);
    final Map<String, dynamic>? destination = _toMap(route?['destinationBranch']);

    return AdminBookingRow(
      id: json['id']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      passengerName: [user?['firstName'], user?['lastName']]
          .where((dynamic part) => part != null && '$part'.isNotEmpty)
          .join(' '),
      agencyName: _toNullableString(_toMap(trip?['agency'])?['name']),
      originCity: origin?['city']?.toString() ?? '',
      destinationCity: destination?['city']?.toString() ?? '',
      departureTime: _toNullableDateTime(trip?['departureTime']),
      totalAmount: _toDouble(json['totalAmount']),
      numberOfSeats: _toInt(json['numberOfSeats']),
      status: adminBookingStatusLabel(json['status']?.toString() ?? ''),
    );
  }

  String get routeLabel => '$originCity → $destinationCity';
}

/// A piece of luggage as the platform monitor shows it.
class AdminLuggageRow {
  final String id;
  final String trackingNumber;
  final String? description;
  final double? weightKg;
  final String status;
  final String? bookingReference;
  final String? passengerName;
  final String? agencyName;

  const AdminLuggageRow({
    required this.id,
    required this.trackingNumber,
    required this.description,
    required this.weightKg,
    required this.status,
    required this.bookingReference,
    required this.passengerName,
    required this.agencyName,
  });

  factory AdminLuggageRow.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? booking = _toMap(json['booking']);
    final Map<String, dynamic>? user = _toMap(booking?['user']);
    final Map<String, dynamic>? trip = _toMap(booking?['trip']);

    return AdminLuggageRow(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      description: _toNullableString(json['description']),
      weightKg: json['weightKg'] == null
          ? null
          : _toDouble(json['weightKg']),
      status: adminTrackingStatusLabel(json['status']?.toString() ?? ''),
      bookingReference: _toNullableString(booking?['bookingReference']),
      passengerName: [
        user?['firstName'],
        user?['lastName'],
      ].where((dynamic part) => part != null && '$part'.isNotEmpty).join(' '),
      agencyName: _toNullableString(_toMap(trip?['agency'])?['name']),
    );
  }
}

/// A parcel as the platform monitor shows it.
class AdminParcelRow {
  final String id;
  final String trackingNumber;
  final String? description;
  final double? weightKg;
  final String status;
  final String recipientName;
  final String originCity;
  final String destinationCity;
  final String? agencyName;

  const AdminParcelRow({
    required this.id,
    required this.trackingNumber,
    required this.description,
    required this.weightKg,
    required this.status,
    required this.recipientName,
    required this.originCity,
    required this.destinationCity,
    required this.agencyName,
  });

  factory AdminParcelRow.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? origin = _toMap(json['originBranch']);

    return AdminParcelRow(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      description: _toNullableString(json['description']),
      weightKg: json['weightKg'] == null
          ? null
          : _toDouble(json['weightKg']),
      status: adminTrackingStatusLabel(json['status']?.toString() ?? ''),
      recipientName: json['recipientName']?.toString() ?? '',
      originCity: origin?['city']?.toString() ?? '',
      destinationCity: _toMap(json['destinationBranch'])?['city']?.toString() ?? '',
      agencyName: _toNullableString(_toMap(origin?['agency'])?['name']),
    );
  }

  String get routeLabel => '$originCity → $destinationCity';
}

/// The administrator landing page payload: counters plus the newest records.
class AdminDashboard {
  final AdminStatistics statistics;
  final List<AdminAccount> recentUsers;
  const AdminDashboard({
    required this.statistics,
    required this.recentUsers,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? activity = _toMap(json['recentActivity']);

    final List<AdminAccount> users = <AdminAccount>[];

    for (final dynamic item in _toList(activity?['users'])) {
      final Map<String, dynamic>? user = _toMap(item);

      if (user != null) {
        users.add(AdminAccount.fromJson(user));
      }
    }

    return AdminDashboard(
      statistics: AdminStatistics.fromJson(
        _toMap(json['statistics']) ?? <String, dynamic>{},
      ),
      recentUsers: users,
    );
  }

  /// The newest accounts, ready for display.
  List<AdminAccount> get newestAccounts {
    final List<AdminAccount> accounts = List<AdminAccount>.of(recentUsers);

    accounts.sort((AdminAccount a, AdminAccount b) {
      final DateTime left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return right.compareTo(left);
    });

    return accounts;
  }
}

/// A branch, as the route editor needs it.
///
/// [AdminAgency] only keeps branch *cities*, which is enough to describe an
/// agency but not enough to build a route: a route joins two branches by id.
class AdminBranch {
  final String id;
  final String name;
  final String city;
  final String agencyId;
  final String agencyName;

  const AdminBranch({
    required this.id,
    required this.name,
    required this.city,
    required this.agencyId,
    required this.agencyName,
  });

  /// "Finexs Voyages — Yaounde Main Branch (Yaounde)"
  String get label => '$agencyName — $name ($city)';

  /// Reads one branch out of the `branches` array an agency carries.
  static AdminBranch? fromAgencyJson(
    Map<String, dynamic> json,
    Map<String, dynamic> branch,
  ) {
    final String id = branch['id']?.toString() ?? '';

    if (id.isEmpty) {
      return null;
    }

    return AdminBranch(
      id: id,
      name: branch['name']?.toString() ?? '',
      city: branch['city']?.toString() ?? '',
      agencyId: json['id']?.toString() ?? '',
      agencyName: json['name']?.toString() ?? '',
    );
  }
}

/// A route: the pair of branches a trip runs between, and what it costs.
class AdminRoute {
  final String id;

  final String originBranchId;
  final String destinationBranchId;

  final String originBranchName;
  final String originCity;
  final String destinationBranchName;
  final String destinationCity;

  /// Routes are platform-wide, so the agency is read from the origin branch.
  final String agencyName;

  final double baseFare;

  /// Both are optional on the record; null means "not recorded".
  final double? distanceKm;
  final int? estimatedDurationMinutes;

  final bool isActive;

  const AdminRoute({
    required this.id,
    required this.originBranchId,
    required this.destinationBranchId,
    required this.originBranchName,
    required this.originCity,
    required this.destinationBranchName,
    required this.destinationCity,
    required this.agencyName,
    required this.baseFare,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.isActive,
  });

  factory AdminRoute.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? origin = _toMap(json['originBranch']);
    final Map<String, dynamic>? destination = _toMap(json['destinationBranch']);

    return AdminRoute(
      id: json['id']?.toString() ?? '',
      originBranchId: json['originBranchId']?.toString() ?? '',
      destinationBranchId: json['destinationBranchId']?.toString() ?? '',
      originBranchName: origin?['name']?.toString() ?? '',
      originCity: origin?['city']?.toString() ?? '',
      destinationBranchName: destination?['name']?.toString() ?? '',
      destinationCity: destination?['city']?.toString() ?? '',
      agencyName:
          _toMap(origin?['agency'])?['name']?.toString() ??
          _toMap(destination?['agency'])?['name']?.toString() ??
          '',
      baseFare: _toDouble(json['baseFare']),
      distanceKm: json['distanceKm'] == null
          ? null
          : _toDouble(json['distanceKm']),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] == null
          ? null
          : _toInt(json['estimatedDurationMinutes']),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  String get label => '$originCity → $destinationCity';

  /// The distance and duration are optional on the record, so they are shown as
  /// absent rather than as a zero.
  String get distanceLabel =>
      distanceKm == null ? 'Distance not recorded' : '${_trim(distanceKm!)} km';

  String get durationLabel {
    final int? minutes = estimatedDurationMinutes;

    if (minutes == null) {
      return 'Duration not recorded';
    }

    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;

    if (hours == 0) {
      return '$rest min';
    }

    return rest == 0 ? '$hours h' : '$hours h $rest min';
  }

  static String _trim(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }
}
