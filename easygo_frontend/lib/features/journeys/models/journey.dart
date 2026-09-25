import '../../bookings/models/booking.dart';

class Journey {
  final String id;

  final String pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;

  final String destinationAddress;
  final double? destinationLatitude;
  final double? destinationLongitude;

  final String status;

  final String bookingId;
  final String userId;

  final DateTime createdAt;
  final DateTime updatedAt;

  final Booking? booking;
  final List<TaxiAssignment> taxiAssignments;

  const Journey({
    required this.id,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.status,
    required this.bookingId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.booking,
    required this.taxiAssignments,
  });

  TaxiAssignment? get pickupTaxi {
    for (final TaxiAssignment assignment in taxiAssignments) {
      if (assignment.segmentType == 'HOME_TO_DEPARTURE_AGENCY') {
        return assignment;
      }
    }

    return null;
  }

  TaxiAssignment? get arrivalTaxi {
    for (final TaxiAssignment assignment in taxiAssignments) {
      if (assignment.segmentType == 'ARRIVAL_AGENCY_TO_DESTINATION') {
        return assignment;
      }
    }

    return null;
  }

  factory Journey.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> bookingJson = _toMap(json['booking']);

    final List<dynamic> taxiJson = json['taxiAssignments'] is List
        ? json['taxiAssignments'] as List
        : <dynamic>[];

    return Journey(
      id: json['id']?.toString() ?? '',
      pickupAddress: json['pickupAddress']?.toString() ?? '',
      pickupLatitude: _toNullableDouble(json['pickupLatitude']),
      pickupLongitude: _toNullableDouble(json['pickupLongitude']),
      destinationAddress: json['destinationAddress']?.toString() ?? '',
      destinationLatitude: _toNullableDouble(json['destinationLatitude']),
      destinationLongitude: _toNullableDouble(json['destinationLongitude']),
      status: json['status']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      booking: bookingJson.isEmpty ? null : Booking.fromJson(bookingJson),
      taxiAssignments: taxiJson
          .whereType<Map>()
          .map(
            (item) => TaxiAssignment.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime _toDateTime(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

class TaxiAssignment {
  final String id;

  final String segmentType;
  final String status;

  final String? driverName;
  final String? driverPhone;

  final String? vehicleRegistration;
  final String? vehicleDescription;

  final String? externalReference;

  final String pickupAddress;
  final String dropoffAddress;

  final double estimatedFare;
  final double? finalFare;

  final DateTime? assignedAt;
  final DateTime? completedAt;

  final String journeyId;
  final String providerId;

  final TaxiProvider? provider;

  const TaxiAssignment({
    required this.id,
    required this.segmentType,
    required this.status,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleRegistration,
    required this.vehicleDescription,
    required this.externalReference,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.estimatedFare,
    required this.finalFare,
    required this.assignedAt,
    required this.completedAt,
    required this.journeyId,
    required this.providerId,
    required this.provider,
  });

  bool get isPickupSegment {
    return segmentType == 'HOME_TO_DEPARTURE_AGENCY';
  }

  bool get isArrivalSegment {
    return segmentType == 'ARRIVAL_AGENCY_TO_DESTINATION';
  }

  bool get hasDriver {
    return driverName != null && driverName!.trim().isNotEmpty;
  }

  factory TaxiAssignment.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> providerJson = Journey._toMap(json['provider']);

    return TaxiAssignment(
      id: json['id']?.toString() ?? '',
      segmentType: json['segmentType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      vehicleRegistration: json['vehicleRegistration']?.toString(),
      vehicleDescription: json['vehicleDescription']?.toString(),
      externalReference: json['externalReference']?.toString(),
      pickupAddress: json['pickupAddress']?.toString() ?? '',
      dropoffAddress: json['dropoffAddress']?.toString() ?? '',
      estimatedFare: _toDouble(json['estimatedFare']),
      finalFare: Journey._toNullableDouble(json['finalFare']),
      assignedAt: Journey._toNullableDateTime(json['assignedAt']),
      completedAt: Journey._toNullableDateTime(json['completedAt']),
      journeyId: json['journeyId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      provider: providerJson.isEmpty
          ? null
          : TaxiProvider.fromJson(providerJson),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class TaxiProvider {
  final String id;
  final String name;
  final String type;
  final String? apiBaseUrl;
  final bool isActive;

  const TaxiProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.apiBaseUrl,
    required this.isActive,
  });

  factory TaxiProvider.fromJson(Map<String, dynamic> json) {
    return TaxiProvider(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      apiBaseUrl: json['apiBaseUrl']?.toString(),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
