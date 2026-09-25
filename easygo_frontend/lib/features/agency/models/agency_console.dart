/// Models for the agency console.
///
/// These are tailored to what an agency staff member needs to see:
/// the passenger behind a booking, the occupancy of a trip and the
/// progression of luggage and parcels. They are deliberately separate
/// from the customer-facing models, which carry different fields.
library;

import '../../tracking/models/tracking.dart';

double? _toNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}

double _toDouble(dynamic value) {
  return _toNullableDouble(value) ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _toNullableDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
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

String _fullName(Map<String, dynamic>? user) {
  if (user == null) {
    return '';
  }

  return [
    user['firstName']?.toString() ?? '',
    user['lastName']?.toString() ?? '',
  ].where((String part) => part.isNotEmpty).join(' ');
}

/// A branch of the staff member's agency.
class ConsoleBranch {
  final String id;
  final String name;
  final String city;
  final String address;
  final String? phone;
  final bool isActive;

  const ConsoleBranch({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    required this.isActive,
  });

  factory ConsoleBranch.fromJson(Map<String, dynamic> json) {
    return ConsoleBranch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: _toNullableString(json['phone']),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

/// The agency the signed-in staff member belongs to.
class StaffAgencyProfile {
  final String staffRole;
  final String agencyId;
  final String name;
  final String? description;
  final String? phone;
  final String? email;
  final String? website;
  final bool isActive;
  final List<ConsoleBranch> branches;

  const StaffAgencyProfile({
    required this.staffRole,
    required this.agencyId,
    required this.name,
    required this.description,
    required this.phone,
    required this.email,
    required this.website,
    required this.isActive,
    required this.branches,
  });

  factory StaffAgencyProfile.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? agency = _toMap(json['agency']);

    final List<dynamic> branchJson = agency?['branches'] is List
        ? agency!['branches'] as List<dynamic>
        : const <dynamic>[];

    return StaffAgencyProfile(
      staffRole: json['staffRole']?.toString() ?? '',
      agencyId: agency?['id']?.toString() ?? '',
      name: agency?['name']?.toString() ?? '',
      description: _toNullableString(agency?['description']),
      phone: _toNullableString(agency?['phone']),
      email: _toNullableString(agency?['email']),
      website: _toNullableString(agency?['website']),
      isActive: agency?['isActive'] as bool? ?? false,
      branches: branchJson
          .whereType<Map>()
          .map(
            (item) => ConsoleBranch.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  List<String> get cities {
    return branches.map((ConsoleBranch branch) => branch.city).toSet().toList()
      ..sort();
  }
}

/// A trip as presented in the agency console.
class ConsoleTrip {
  final String id;
  final String originCity;
  final String destinationCity;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final String status;
  final String? vehicleDescription;
  final String? vehicleRegistration;
  final int bookingCount;
  final int parcelCount;

  const ConsoleTrip({
    required this.id,
    required this.originCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
    required this.vehicleDescription,
    required this.vehicleRegistration,
    required this.bookingCount,
    required this.parcelCount,
  });

  factory ConsoleTrip.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? route = _toMap(json['route']);

    final Map<String, dynamic>? originBranch = _toMap(route?['originBranch']);

    final Map<String, dynamic>? destinationBranch = _toMap(
      route?['destinationBranch'],
    );

    final Map<String, dynamic>? vehicle = _toMap(json['vehicle']);

    final Map<String, dynamic>? counts = _toMap(json['_count']);

    final String? brand = _toNullableString(vehicle?['brand']);

    final String? model = _toNullableString(vehicle?['model']);

    final String description = [
      brand ?? '',
      model ?? '',
    ].where((String part) => part.isNotEmpty).join(' ');

    return ConsoleTrip(
      id: json['id']?.toString() ?? '',
      originCity: originBranch?['city']?.toString() ?? '',
      destinationCity: destinationBranch?['city']?.toString() ?? '',
      departureTime: _toNullableDateTime(json['departureTime']),
      arrivalTime: _toNullableDateTime(json['arrivalTime']),
      price: _toDouble(json['price']),
      totalSeats: _toInt(json['totalSeats']),
      availableSeats: _toInt(json['availableSeats']),
      status: json['status']?.toString() ?? '',
      vehicleDescription: description.isEmpty ? null : description,
      vehicleRegistration: _toNullableString(vehicle?['registrationNumber']),
      bookingCount: _toInt(counts?['bookings']),
      parcelCount: _toInt(counts?['parcels']),
    );
  }

  int get bookedSeats {
    final int booked = totalSeats - availableSeats;

    return booked < 0 ? 0 : booked;
  }

  String get routeLabel => '$originCity → $destinationCity';

  String get statusLabel => formatTrackingStatus(status);
}

/// A booking as presented in the agency console.
class ConsoleBooking {
  final String id;
  final String bookingReference;
  final String passengerName;
  final String? passengerPhone;
  final String? passengerEmail;
  final String originCity;
  final String destinationCity;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final String status;
  final double totalAmount;
  final int numberOfSeats;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? ticketNumber;
  final bool hasJourney;
  final int luggageCount;
  final String? pickupAddress;
  final String? finalDestination;
  final String? vehicleDescription;

  const ConsoleBooking({
    required this.id,
    required this.bookingReference,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerEmail,
    required this.originCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
    required this.totalAmount,
    required this.numberOfSeats,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.ticketNumber,
    required this.hasJourney,
    required this.luggageCount,
    required this.pickupAddress,
    required this.finalDestination,
    required this.vehicleDescription,
  });

  factory ConsoleBooking.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? user = _toMap(json['user']);

    final Map<String, dynamic>? trip = _toMap(json['trip']);

    final Map<String, dynamic>? route = _toMap(trip?['route']);

    final List<dynamic> payments = json['payments'] is List
        ? json['payments'] as List<dynamic>
        : const <dynamic>[];

    // The most recent payment is the one that reflects the outcome.
    Map<String, dynamic>? latestPayment;

    for (final dynamic item in payments) {
      final Map<String, dynamic>? payment = _toMap(item);

      if (payment == null) {
        continue;
      }

      latestPayment = payment;
    }

    final Map<String, dynamic>? ticket = _toMap(json['ticket']);

    final Map<String, dynamic>? journey = _toMap(json['journey']);

    final Map<String, dynamic>? vehicle = _toMap(trip?['vehicle']);

    final List<dynamic> luggage = json['luggage'] is List
        ? json['luggage'] as List<dynamic>
        : const <dynamic>[];

    final String vehicleDescription = [
      _toNullableString(vehicle?['brand']) ?? '',
      _toNullableString(vehicle?['model']) ?? '',
    ].where((String part) => part.isNotEmpty).join(' ');

    return ConsoleBooking(
      id: json['id']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      passengerName: _fullName(user),
      passengerPhone: _toNullableString(user?['phone']),
      passengerEmail: _toNullableString(user?['email']),
      originCity:
          _toMap(route?['originBranch'])?['city']?.toString() ?? '',
      destinationCity:
          _toMap(route?['destinationBranch'])?['city']?.toString() ?? '',
      departureTime: _toNullableDateTime(trip?['departureTime']),
      arrivalTime: _toNullableDateTime(trip?['arrivalTime']),
      status: json['status']?.toString() ?? '',
      totalAmount: _toDouble(json['totalAmount']),
      numberOfSeats: _toInt(json['numberOfSeats']),
      paymentStatus: _toNullableString(latestPayment?['status']),
      paymentMethod: _toNullableString(latestPayment?['method']),
      ticketNumber: _toNullableString(ticket?['ticketNumber']),
      hasJourney: journey != null,
      luggageCount: luggage.length,
      pickupAddress: _toNullableString(journey?['pickupAddress']),
      finalDestination: _toNullableString(
        journey?['destinationAddress'],
      ),
      vehicleDescription: vehicleDescription.isEmpty
          ? null
          : vehicleDescription,
    );
  }

  String get routeLabel => '$originCity → $destinationCity';

  String get statusLabel => formatTrackingStatus(status);
}

/// Luggage as presented in the agency console.
class ConsoleLuggage {
  final String id;
  final String trackingNumber;
  final String? description;
  final double? weightKg;
  final String status;
  final int progressPercentage;
  final String passengerName;
  final String? passengerPhone;
  final String? bookingReference;
  final String? ticketNumber;
  final String? tripId;
  final DateTime? departureTime;
  final String originCity;
  final String destinationCity;
  final List<TrackingEvent> trackingEvents;

  const ConsoleLuggage({
    required this.id,
    required this.trackingNumber,
    required this.description,
    required this.weightKg,
    required this.status,
    required this.progressPercentage,
    required this.passengerName,
    required this.passengerPhone,
    required this.bookingReference,
    required this.ticketNumber,
    required this.tripId,
    required this.departureTime,
    required this.originCity,
    required this.destinationCity,
    required this.trackingEvents,
  });

  factory ConsoleLuggage.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? booking = _toMap(json['booking']);

    final Map<String, dynamic>? trip = _toMap(booking?['trip']);

    final Map<String, dynamic>? route = _toMap(trip?['route']);

    final Map<String, dynamic>? user = _toMap(booking?['user']);

    final Map<String, dynamic>? ticket = _toMap(booking?['ticket']);

    return ConsoleLuggage(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      description: _toNullableString(json['description']),
      weightKg: _toNullableDouble(json['weightKg']),
      status: json['status']?.toString() ?? '',
      progressPercentage: _toInt(json['progressPercentage']),
      passengerName: _fullName(user),
      passengerPhone: _toNullableString(user?['phone']),
      bookingReference: _toNullableString(booking?['bookingReference']),
      ticketNumber: _toNullableString(ticket?['ticketNumber']),
      tripId: _toNullableString(booking?['tripId']),
      departureTime: _toNullableDateTime(trip?['departureTime']),
      originCity:
          _toMap(route?['originBranch'])?['city']?.toString() ?? '',
      destinationCity:
          _toMap(route?['destinationBranch'])?['city']?.toString() ?? '',
      trackingEvents: _toEvents(json['trackingEvents']),
    );
  }

  String get routeLabel => '$originCity → $destinationCity';

  String get statusLabel => luggageStatusLabel(status);
}

/// A parcel as presented in the agency console.
class ConsoleParcel {
  final String id;
  final String trackingNumber;
  final String description;
  final double? weightKg;
  final String recipientName;
  final String recipientPhone;
  final String status;
  final int progressPercentage;
  final String senderName;
  final String? senderPhone;
  final double? shipmentPrice;
  final DateTime? registeredAt;
  final String originCity;
  final String destinationCity;
  final List<TrackingEvent> trackingEvents;

  const ConsoleParcel({
    required this.id,
    required this.trackingNumber,
    required this.description,
    required this.weightKg,
    required this.recipientName,
    required this.recipientPhone,
    required this.status,
    required this.progressPercentage,
    required this.senderName,
    required this.senderPhone,
    required this.shipmentPrice,
    required this.registeredAt,
    required this.originCity,
    required this.destinationCity,
    required this.trackingEvents,
  });

  factory ConsoleParcel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? originBranch = _toMap(json['originBranch']);

    final Map<String, dynamic>? destinationBranch = _toMap(
      json['destinationBranch'],
    );

    final Map<String, dynamic>? sender = _toMap(json['sender']);

    return ConsoleParcel(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      weightKg: _toNullableDouble(json['weightKg']),
      recipientName: json['recipientName']?.toString() ?? '',
      recipientPhone: json['recipientPhone']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      progressPercentage: _toInt(json['progressPercentage']),
      senderName: _fullName(sender),
      senderPhone: _toNullableString(sender?['phone']),
      shipmentPrice: _toNullableDouble(json['shipmentPrice']),
      registeredAt: _toNullableDateTime(json['createdAt']),
      originCity: originBranch?['city']?.toString() ?? '',
      destinationCity: destinationBranch?['city']?.toString() ?? '',
      trackingEvents: _toEvents(json['trackingEvents']),
    );
  }

  String get routeLabel => '$originCity → $destinationCity';

  String get statusLabel => parcelStatusLabel(status);
}

class AgencyDashboard {
  final Map<String, dynamic> trips;
  final Map<String, dynamic> bookings;
  final Map<String, dynamic> luggage;
  final Map<String, dynamic> parcels;
  final double revenue;
  final List<ConsoleTrip> upcomingTrips;
  final List<ConsoleBooking> recentBookings;

  const AgencyDashboard({
    required this.trips,
    required this.bookings,
    required this.luggage,
    required this.parcels,
    required this.revenue,
    required this.upcomingTrips,
    required this.recentBookings,
  });

  factory AgencyDashboard.fromJson(Map<String, dynamic> json) {
    return AgencyDashboard(
      trips: _toMap(json['trips']) ?? const <String, dynamic>{},
      bookings: _toMap(json['bookings']) ?? const <String, dynamic>{},
      luggage: _toMap(json['luggage']) ?? const <String, dynamic>{},
      parcels: _toMap(json['parcels']) ?? const <String, dynamic>{},
      revenue: _toDouble(_toMap(json['revenue'])?['successfulPayments']),
      upcomingTrips: _toList(json['upcomingTrips'], ConsoleTrip.fromJson),
      recentBookings: _toList(
        json['recentBookings'],
        ConsoleBooking.fromJson,
      ),
    );
  }

  int tripCount() => _toInt(trips['total']);

  int scheduledTripCount() => _toInt(trips['scheduled']);

  int bookingCount() => _toInt(bookings['total']);

  int pendingBookingCount() => _toInt(bookings['pending']);

  int confirmedBookingCount() => _toInt(bookings['confirmed']);

  int luggageCount() => _toInt(luggage['total']);

  int luggageInTransitCount() => _toInt(luggage['inTransit']);

  int parcelCount() => _toInt(parcels['total']);

  int parcelInTransitCount() => _toInt(parcels['inTransit']);
}

List<TrackingEvent> _toEvents(dynamic value) {
  if (value is! List) {
    return const <TrackingEvent>[];
  }

  return value
      .whereType<Map>()
      .map((item) => TrackingEvent.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<T> _toList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) {
    return <T>[];
  }

  final List<T> result = <T>[];

  for (final dynamic item in value) {
    if (item is Map) {
      result.add(fromJson(Map<String, dynamic>.from(item)));
    }
  }

  return result;
}

/// Display label used by the agency tracking screens for each backend status.
///
/// The screens group and filter on human labels ("Arrived", "Received by
/// Agency") while the API stores enum values ("ARRIVED_AT_DESTINATION_AGENCY",
/// "RECEIVED_AT_AGENCY"), so both directions are needed. The order below is the
/// operational lifecycle: a status may only advance to the next entry.
const List<String> luggageLifecycle = <String>[
  'Registered',
  'Received by Agency',
  'Loaded',
  'In Transit',
  'Arrived',
  'Ready for Collection',
  'Delivered',
];

/// Parcels share the luggage wording except for the first legacy hand-over,
/// which the API records as `RECEIVED_AT_ORIGIN_AGENCY`.
const List<String> parcelLifecycle = <String>[
  'Registered',
  'Received by Agency',
  'Loaded',
  'In Transit',
  'Arrived',
  'Ready for Collection',
  'Delivered',
];

const Map<String, String> _luggageLabelsToApi = <String, String>{
  'Registered': 'REGISTERED',
  'Received by Agency': 'RECEIVED_AT_AGENCY',
  'Loaded': 'LOADED',
  'In Transit': 'IN_TRANSIT',
  'Arrived': 'ARRIVED_AT_DESTINATION_AGENCY',
  'Ready for Collection': 'READY_FOR_COLLECTION',
  'Delivered': 'DELIVERED',
  'Lost': 'LOST',
};

const Map<String, String> _parcelLabelsToApi = <String, String>{
  'Registered': 'REGISTERED',
  'Received by Agency': 'RECEIVED_AT_ORIGIN_AGENCY',
  'Loaded': 'LOADED',
  'In Transit': 'IN_TRANSIT',
  'Arrived': 'ARRIVED_AT_DESTINATION_AGENCY',
  'Ready for Collection': 'READY_FOR_COLLECTION',
  'Collected': 'COLLECTED',
  'Delivered': 'DELIVERED',
  'Lost': 'LOST',
  'Cancelled': 'CANCELLED',
};

String _labelFor(Map<String, String> labelsToApi, String apiStatus) {
  for (final MapEntry<String, String> entry in labelsToApi.entries) {
    if (entry.value == apiStatus) {
      return entry.key;
    }
  }

  return formatTrackingStatus(apiStatus);
}

/// Converts an agency screen label into the value the API expects.
String luggageStatusToApi(String label) =>
    _luggageLabelsToApi[label] ?? label;

/// Converts a luggage enum value returned by the API into a screen label.
String luggageStatusLabel(String apiStatus) =>
    _labelFor(_luggageLabelsToApi, apiStatus);

/// Converts an agency screen label into the value the API expects.
String parcelStatusToApi(String label) => _parcelLabelsToApi[label] ?? label;

/// Converts a parcel enum value returned by the API into a screen label.
String parcelStatusLabel(String apiStatus) =>
    _labelFor(_parcelLabelsToApi, apiStatus);

/// The label that follows [label] in the lifecycle, or `null` at the end.
String? nextLuggageStatus(String label) => _nextIn(luggageLifecycle, label);

/// The label that follows [label] in the lifecycle, or `null` at the end.
String? nextParcelStatus(String label) => _nextIn(parcelLifecycle, label);

String? _nextIn(List<String> lifecycle, String label) {
  final int index = lifecycle.indexOf(label);

  if (index < 0 || index >= lifecycle.length - 1) {
    return null;
  }

  return lifecycle[index + 1];
}

/// Optional console fields are frequently absent, so render a dash rather than
/// leaving a row value visually empty.
String dashIfEmpty(String? value) =>
    (value == null || value.isEmpty) ? '—' : value;

/// Renders a number the way the agency screens display it, or a dash when the
/// platform has no value for the field yet.
String dashIfNull(num? value) =>
    value == null ? '—' : value.toStringAsFixed(1);

const List<String> _monthAbbreviations = <String>[
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

/// Formats a tracking date as the agency screens display it (e.g. `10 Oct 2026`).
String formatConsoleDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')} '
    '${_monthAbbreviations[value.month - 1]} ${value.year}';

/// Formats a time of day as `HH:mm`.
String formatConsoleTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';
