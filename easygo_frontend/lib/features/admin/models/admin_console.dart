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

/// A notification delivered to the signed-in account.
class AdminNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  const AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: _toNullableDateTime(json['createdAt']),
    );
  }
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
