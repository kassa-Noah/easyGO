/// Models for the luggage and parcel tracking MVP.
///
/// The backend returns luggage and parcels with their tracking
/// events, the route branches and, for luggage, the owning booking.
library;

double? _toNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
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

/// Converts a backend status such as `IN_TRANSIT` into
/// `In Transit` for display.
String formatTrackingStatus(String status) {
  if (status.isEmpty) {
    return '';
  }

  return status
      .split('_')
      .where((String part) => part.isNotEmpty)
      .map((String part) {
        return part[0].toUpperCase() + part.substring(1).toLowerCase();
      })
      .join(' ');
}

class TrackingEvent {
  final String id;
  final String status;
  final int progressPercentage;
  final String? location;
  final String? description;
  final DateTime? createdAt;

  const TrackingEvent({
    required this.id,
    required this.status,
    required this.progressPercentage,
    required this.location,
    required this.description,
    required this.createdAt,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      progressPercentage: _toInt(json['progressPercentage']),
      location: _toNullableString(json['location']),
      description: _toNullableString(json['description']),
      createdAt: _toNullableDateTime(json['createdAt']),
    );
  }

  String get statusLabel => formatTrackingStatus(status);
}

/// Passenger luggage belonging to a booking.
class Luggage {
  final String id;
  final String trackingNumber;
  final String? description;
  final double? weightKg;
  final String status;
  final int progressPercentage;
  final String bookingId;
  final DateTime? createdAt;

  final String? bookingReference;
  final String? agencyName;
  final String? originCity;
  final String? destinationCity;
  final DateTime? departureTime;

  final List<TrackingEvent> trackingEvents;

  const Luggage({
    required this.id,
    required this.trackingNumber,
    required this.description,
    required this.weightKg,
    required this.status,
    required this.progressPercentage,
    required this.bookingId,
    required this.createdAt,
    required this.bookingReference,
    required this.agencyName,
    required this.originCity,
    required this.destinationCity,
    required this.departureTime,
    required this.trackingEvents,
  });

  factory Luggage.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? booking = _toMap(json['booking']);

    final Map<String, dynamic>? trip = _toMap(booking?['trip']);

    final Map<String, dynamic>? agency = _toMap(trip?['agency']);

    final Map<String, dynamic>? route = _toMap(trip?['route']);

    final Map<String, dynamic>? originBranch = _toMap(
      route?['originBranch'],
    );

    final Map<String, dynamic>? destinationBranch = _toMap(
      route?['destinationBranch'],
    );

    return Luggage(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      description: _toNullableString(json['description']),
      weightKg: _toNullableDouble(json['weightKg']),
      status: json['status']?.toString() ?? '',
      progressPercentage: _toInt(json['progressPercentage']),
      bookingId: json['bookingId']?.toString() ?? '',
      createdAt: _toNullableDateTime(json['createdAt']),
      bookingReference: _toNullableString(booking?['bookingReference']),
      agencyName: _toNullableString(agency?['name']),
      originCity: _toNullableString(originBranch?['city']),
      destinationCity: _toNullableString(destinationBranch?['city']),
      departureTime: _toNullableDateTime(trip?['departureTime']),
      trackingEvents: _toTrackingEvents(json['trackingEvents']),
    );
  }

  String get statusLabel => formatTrackingStatus(status);

  bool get isDelivered => status == 'DELIVERED';

  bool get isLost => status == 'LOST';

  String get routeLabel {
    if (originCity == null || destinationCity == null) {
      return 'Route unavailable';
    }

    return '$originCity → $destinationCity';
  }
}

/// A parcel sent between cities, independently of a booking.
class Parcel {
  final String id;
  final String trackingNumber;
  final String description;
  final double? weightKg;
  final String recipientName;
  final String recipientPhone;
  final String status;
  final int progressPercentage;
  final double? shipmentPrice;
  final String senderId;
  final String? recipientUserId;
  final String originBranchId;
  final String destinationBranchId;
  final String? tripId;
  final DateTime? createdAt;

  final String? senderName;
  final String? originCity;
  final String? destinationCity;
  final String? originAgencyName;
  final String? destinationAgencyName;
  final DateTime? departureTime;

  final List<TrackingEvent> trackingEvents;

  const Parcel({
    required this.id,
    required this.trackingNumber,
    required this.description,
    required this.weightKg,
    required this.recipientName,
    required this.recipientPhone,
    required this.status,
    required this.progressPercentage,
    required this.shipmentPrice,
    required this.senderId,
    required this.recipientUserId,
    required this.originBranchId,
    required this.destinationBranchId,
    required this.tripId,
    required this.createdAt,
    required this.senderName,
    required this.originCity,
    required this.destinationCity,
    required this.originAgencyName,
    required this.destinationAgencyName,
    required this.departureTime,
    required this.trackingEvents,
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? sender = _toMap(json['sender']);

    final Map<String, dynamic>? originBranch = _toMap(
      json['originBranch'],
    );

    final Map<String, dynamic>? destinationBranch = _toMap(
      json['destinationBranch'],
    );

    final Map<String, dynamic>? trip = _toMap(json['trip']);

    final String? senderName = sender == null
        ? null
        : [
            sender['firstName']?.toString() ?? '',
            sender['lastName']?.toString() ?? '',
          ].where((String part) => part.isNotEmpty).join(' ');

    return Parcel(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      weightKg: _toNullableDouble(json['weightKg']),
      recipientName: json['recipientName']?.toString() ?? '',
      recipientPhone: json['recipientPhone']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      progressPercentage: _toInt(json['progressPercentage']),
      shipmentPrice: _toNullableDouble(json['shipmentPrice']),
      senderId: json['senderId']?.toString() ?? '',
      recipientUserId: _toNullableString(json['recipientUserId']),
      originBranchId: json['originBranchId']?.toString() ?? '',
      destinationBranchId: json['destinationBranchId']?.toString() ?? '',
      tripId: _toNullableString(json['tripId']),
      createdAt: _toNullableDateTime(json['createdAt']),
      senderName: (senderName == null || senderName.isEmpty)
          ? null
          : senderName,
      originCity: _toNullableString(originBranch?['city']),
      destinationCity: _toNullableString(destinationBranch?['city']),
      originAgencyName: _toNullableString(_toMap(originBranch?['agency'])?['name']),
      destinationAgencyName: _toNullableString(
        _toMap(destinationBranch?['agency'])?['name'],
      ),
      departureTime: _toNullableDateTime(trip?['departureTime']),
      trackingEvents: _toTrackingEvents(json['trackingEvents']),
    );
  }

  String get statusLabel => formatTrackingStatus(status);

  bool get isDelivered => status == 'DELIVERED' || status == 'COLLECTED';

  bool get isLost => status == 'LOST';

  bool get isCancelled => status == 'CANCELLED';

  String get routeLabel {
    if (originCity == null || destinationCity == null) {
      return 'Route unavailable';
    }

    return '$originCity → $destinationCity';
  }
}

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

List<TrackingEvent> _toTrackingEvents(dynamic value) {
  if (value is! List) {
    return const <TrackingEvent>[];
  }

  return value
      .whereType<Map>()
      .map((item) => TrackingEvent.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
