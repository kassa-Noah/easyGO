/// A ticket as an agency sees it when checking one at boarding.
///
/// The verification endpoint returns the ticket with its booking and trip
/// attached, so this carries the details a staff member needs to decide whether
/// to let the passenger through: whose ticket it is, when they are travelling
/// and whether the ticket is still usable.
class VerifiedTicket {
  final String id;
  final String ticketNumber;
  final String status;

  final DateTime? issuedAt;
  final DateTime? usedAt;

  final String bookingReference;
  final String bookingStatus;

  final String passengerName;
  final String? passengerPhone;

  final String agencyName;
  final String originCity;
  final String destinationCity;

  final DateTime? departureTime;

  final String vehicleDescription;

  const VerifiedTicket({
    required this.id,
    required this.ticketNumber,
    required this.status,
    required this.issuedAt,
    required this.usedAt,
    required this.bookingReference,
    required this.bookingStatus,
    required this.passengerName,
    required this.passengerPhone,
    required this.agencyName,
    required this.originCity,
    required this.destinationCity,
    required this.departureTime,
    required this.vehicleDescription,
  });

  /// A ticket the backend still considers usable at the gate.
  bool get isUsable => status == 'ACTIVE';

  /// A ticket that has already been taken.
  bool get isUsed => status == 'USED';

  String get statusLabel {
    switch (status) {
      case 'ACTIVE':
        return 'Valid';
      case 'USED':
        return 'Already used';
      case 'CANCELLED':
        return 'Cancelled';
      case 'EXPIRED':
        return 'Expired';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  factory VerifiedTicket.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? booking = _toMap(json['booking']);

    final Map<String, dynamic>? user = _toMap(booking?['user']);
    final Map<String, dynamic>? trip = _toMap(booking?['trip']);
    final Map<String, dynamic>? agency = _toMap(trip?['agency']);
    final Map<String, dynamic>? route = _toMap(trip?['route']);
    final Map<String, dynamic>? vehicle = _toMap(trip?['vehicle']);

    final String passengerName = [
      user?['firstName'],
      user?['lastName'],
    ].where((dynamic part) => part != null && '$part'.trim().isNotEmpty).join(' ');

    return VerifiedTicket(
      id: json['id']?.toString() ?? '',
      ticketNumber: json['ticketNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      issuedAt: _toNullableDateTime(json['issuedAt']),
      usedAt: _toNullableDateTime(json['usedAt']),
      bookingReference: booking?['bookingReference']?.toString() ?? '',
      bookingStatus: booking?['status']?.toString() ?? '',
      passengerName: passengerName,
      passengerPhone: user?['phone']?.toString(),
      agencyName: agency?['name']?.toString() ?? '',
      originCity: _city(route?['originBranch']),
      destinationCity: _city(route?['destinationBranch']),
      departureTime: _toNullableDateTime(trip?['departureTime']),
      vehicleDescription: _vehicleDescription(vehicle),
    );
  }

  /// The branch city, falling back to the branch name when the API omits it.
  static String _city(dynamic branch) {
    final Map<String, dynamic>? map = _toMap(branch);

    if (map == null) {
      return '';
    }

    final String city = map['city']?.toString().trim() ?? '';

    if (city.isNotEmpty) {
      return city;
    }

    return map['name']?.toString().trim() ?? '';
  }

  static String _vehicleDescription(Map<String, dynamic>? vehicle) {
    if (vehicle == null) {
      return '';
    }

    final String model = [
      vehicle['brand'],
      vehicle['model'],
    ].where((dynamic part) => part != null && '$part'.trim().isNotEmpty).join(' ');

    final String plate = vehicle['registrationNumber']?.toString().trim() ?? '';

    return [model, plate].where((part) => part.isNotEmpty).join(' • ');
  }

  static Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
