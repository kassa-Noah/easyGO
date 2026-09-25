import '../../trips/models/trip.dart';

class Booking {
  final String id;
  final String bookingReference;

  final int numberOfSeats;

  final double tripAmount;
  final double taxiPickupAmount;
  final double taxiDropoffAmount;
  final double totalAmount;

  final String status;

  final String userId;
  final String tripId;

  final DateTime createdAt;
  final DateTime updatedAt;

  final Trip? trip;
  final BookingJourney? journey;

  final List<BookingPayment> payments;
  final BookingTicket? ticket;
  final List<BookingLuggage> luggage;

  const Booking({
    required this.id,
    required this.bookingReference,
    required this.numberOfSeats,
    required this.tripAmount,
    required this.taxiPickupAmount,
    required this.taxiDropoffAmount,
    required this.totalAmount,
    required this.status,
    required this.userId,
    required this.tripId,
    required this.createdAt,
    required this.updatedAt,
    required this.trip,
    required this.journey,
    required this.payments,
    required this.ticket,
    required this.luggage,
  });

  bool get isDoorToDoor {
    return journey != null;
  }

  bool get isCancelled {
    return status.toUpperCase() == 'CANCELLED';
  }

  bool get isConfirmed {
    return status.toUpperCase() == 'CONFIRMED';
  }

  bool get isPending {
    return status.toUpperCase() == 'PENDING';
  }

  bool get hasSuccessfulPayment {
    return payments.any(
      (payment) => payment.status.toUpperCase() == 'SUCCESSFUL',
    );
  }

  BookingPayment? get successfulPayment {
    for (final BookingPayment payment in payments) {
      if (payment.status.toUpperCase() == 'SUCCESSFUL') {
        return payment;
      }
    }

    return null;
  }

  int get luggageCount {
    return luggage.length;
  }

  String get agencyName {
    return trip?.agencyName ?? '';
  }

  String get originCity {
    return trip?.originCity ?? '';
  }

  String get destinationCity {
    return trip?.destinationCity ?? '';
  }

  DateTime? get departureTime {
    return trip?.departureTime;
  }

  DateTime? get arrivalTime {
    return trip?.arrivalTime;
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> tripJson = _toMap(json['trip']);

    final Map<String, dynamic> journeyJson = _toMap(json['journey']);

    final Map<String, dynamic> ticketJson = _toMap(json['ticket']);

    final List<dynamic> paymentsJson = json['payments'] is List
        ? json['payments'] as List
        : <dynamic>[];

    final List<dynamic> luggageJson = json['luggage'] is List
        ? json['luggage'] as List
        : <dynamic>[];

    return Booking(
      id: json['id']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      numberOfSeats: _toInt(json['numberOfSeats']),
      tripAmount: _toDouble(json['tripAmount']),
      taxiPickupAmount: _toDouble(json['taxiPickupAmount']),
      taxiDropoffAmount: _toDouble(json['taxiDropoffAmount']),
      totalAmount: _toDouble(json['totalAmount']),
      status: json['status']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? tripJson['id']?.toString() ?? '',
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      trip: tripJson.isEmpty ? null : Trip.fromJson(tripJson),
      journey: journeyJson.isEmpty
          ? null
          : BookingJourney.fromJson(journeyJson),
      payments: paymentsJson
          .whereType<Map>()
          .map(
            (item) => BookingPayment.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      ticket: ticketJson.isEmpty ? null : BookingTicket.fromJson(ticketJson),
      luggage: luggageJson
          .whereType<Map>()
          .map(
            (item) => BookingLuggage.fromJson(Map<String, dynamic>.from(item)),
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

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
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

class BookingJourney {
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

  const BookingJourney({
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
  });

  factory BookingJourney.fromJson(Map<String, dynamic> json) {
    return BookingJourney(
      id: json['id']?.toString() ?? '',
      pickupAddress: json['pickupAddress']?.toString() ?? '',
      pickupLatitude: Booking._toNullableDouble(json['pickupLatitude']),
      pickupLongitude: Booking._toNullableDouble(json['pickupLongitude']),
      destinationAddress: json['destinationAddress']?.toString() ?? '',
      destinationLatitude: Booking._toNullableDouble(
        json['destinationLatitude'],
      ),
      destinationLongitude: Booking._toNullableDouble(
        json['destinationLongitude'],
      ),
      status: json['status']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
    );
  }
}

class BookingPayment {
  final String id;
  final String transactionReference;

  final double amount;

  final String method;
  final String status;

  final String? providerReference;
  final DateTime? paidAt;

  final String bookingId;

  const BookingPayment({
    required this.id,
    required this.transactionReference,
    required this.amount,
    required this.method,
    required this.status,
    required this.providerReference,
    required this.paidAt,
    required this.bookingId,
  });

  factory BookingPayment.fromJson(Map<String, dynamic> json) {
    return BookingPayment(
      id: json['id']?.toString() ?? '',
      transactionReference: json['transactionReference']?.toString() ?? '',
      amount: Booking._toDouble(json['amount']),
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      providerReference: json['providerReference']?.toString(),
      paidAt: Booking._toNullableDateTime(json['paidAt']),
      bookingId: json['bookingId']?.toString() ?? '',
    );
  }
}

class BookingTicket {
  final String id;
  final String ticketNumber;
  final String qrCodeData;
  final String status;

  final DateTime issuedAt;
  final DateTime? usedAt;

  final String bookingId;

  const BookingTicket({
    required this.id,
    required this.ticketNumber,
    required this.qrCodeData,
    required this.status,
    required this.issuedAt,
    required this.usedAt,
    required this.bookingId,
  });

  factory BookingTicket.fromJson(Map<String, dynamic> json) {
    return BookingTicket(
      id: json['id']?.toString() ?? '',
      ticketNumber: json['ticketNumber']?.toString() ?? '',
      qrCodeData: json['qrCodeData']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      issuedAt: Booking._toDateTime(json['issuedAt']),
      usedAt: Booking._toNullableDateTime(json['usedAt']),
      bookingId: json['bookingId']?.toString() ?? '',
    );
  }
}

class BookingLuggage {
  final String id;
  final String trackingNumber;
  final String description;

  final double? weightKg;

  final String status;
  final int progressPercentage;

  final String bookingId;

  const BookingLuggage({
    required this.id,
    required this.trackingNumber,
    required this.description,
    required this.weightKg,
    required this.status,
    required this.progressPercentage,
    required this.bookingId,
  });

  factory BookingLuggage.fromJson(Map<String, dynamic> json) {
    return BookingLuggage(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      weightKg: Booking._toNullableDouble(json['weightKg']),
      status: json['status']?.toString() ?? '',
      progressPercentage: Booking._toInt(json['progressPercentage']),
      bookingId: json['bookingId']?.toString() ?? '',
    );
  }
}
