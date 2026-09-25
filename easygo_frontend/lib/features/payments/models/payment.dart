import '../../bookings/models/booking.dart';

class Payment {
  final String id;
  final String transactionReference;
  final double amount;
  final String method;
  final String status;
  final String? providerReference;
  final DateTime? paidAt;
  final String bookingId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Booking? booking;

  const Payment({
    required this.id,
    required this.transactionReference,
    required this.amount,
    required this.method,
    required this.status,
    required this.providerReference,
    required this.paidAt,
    required this.bookingId,
    required this.createdAt,
    required this.updatedAt,
    this.booking,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      transactionReference: json['transactionReference']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      providerReference: json['providerReference']?.toString(),
      paidAt: _parseDateTime(json['paidAt']),
      bookingId: json['bookingId']?.toString() ?? '',
      createdAt:
          _parseDateTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          _parseDateTime(json['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      booking: json['booking'] is Map<String, dynamic>
          ? Booking.fromJson(json['booking'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isPending => status == 'PENDING';

  bool get isSuccessful => status == 'SUCCESSFUL';

  bool get isFailed => status == 'FAILED';

  bool get isSimulated => method == 'SIMULATED';

  static double _parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
