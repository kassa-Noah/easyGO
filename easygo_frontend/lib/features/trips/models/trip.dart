class Trip {
  final String id;

  final DateTime departureTime;
  final DateTime arrivalTime;

  final double price;

  final int totalSeats;
  final int availableSeats;

  final String status;

  final String agencyId;
  final String routeId;
  final String vehicleId;

  final String agencyName;

  final String originCity;
  final String destinationCity;

  final String originBranchName;
  final String destinationBranchName;

  final String originBranchAddress;
  final String destinationBranchAddress;

  final double? distanceKm;
  final int? estimatedDurationMinutes;

  final String vehicleRegistrationNumber;
  final String vehicleModel;
  final String vehicleBrand;
  final int? vehicleCapacity;

  const Trip({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
    required this.agencyId,
    required this.routeId,
    required this.vehicleId,
    required this.agencyName,
    required this.originCity,
    required this.destinationCity,
    required this.originBranchName,
    required this.destinationBranchName,
    required this.originBranchAddress,
    required this.destinationBranchAddress,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.vehicleRegistrationNumber,
    required this.vehicleModel,
    required this.vehicleBrand,
    required this.vehicleCapacity,
  });

  Duration get duration {
    return arrivalTime.difference(departureTime);
  }

  String get vehicleDescription {
    final List<String> parts = [];

    final String brandModel = [
      vehicleBrand.trim(),
      vehicleModel.trim(),
    ].where((value) => value.isNotEmpty).join(' ');

    if (brandModel.isNotEmpty) {
      parts.add(brandModel);
    }

    if (vehicleRegistrationNumber.trim().isNotEmpty) {
      parts.add(vehicleRegistrationNumber.trim());
    }

    if (parts.isEmpty) {
      return 'Vehicle information unavailable';
    }

    return parts.join(' • ');
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> agency = _toMap(json['agency']);

    final Map<String, dynamic> route = _toMap(json['route']);

    final Map<String, dynamic> vehicle = _toMap(json['vehicle']);

    final Map<String, dynamic> originBranch = _toMap(route['originBranch']);

    final Map<String, dynamic> destinationBranch = _toMap(
      route['destinationBranch'],
    );

    return Trip(
      id: json['id']?.toString() ?? '',
      departureTime: _toDateTime(json['departureTime']),
      arrivalTime: _toDateTime(json['arrivalTime']),
      price: _toDouble(json['price']),
      totalSeats: _toInt(json['totalSeats']),
      availableSeats: _toInt(json['availableSeats']),
      status: json['status']?.toString() ?? '',
      agencyId: json['agencyId']?.toString() ?? agency['id']?.toString() ?? '',
      routeId: json['routeId']?.toString() ?? route['id']?.toString() ?? '',
      vehicleId:
          json['vehicleId']?.toString() ?? vehicle['id']?.toString() ?? '',
      agencyName: agency['name']?.toString() ?? '',
      originCity: originBranch['city']?.toString() ?? '',
      destinationCity: destinationBranch['city']?.toString() ?? '',
      originBranchName: originBranch['name']?.toString() ?? '',
      destinationBranchName: destinationBranch['name']?.toString() ?? '',
      originBranchAddress: originBranch['address']?.toString() ?? '',
      destinationBranchAddress: destinationBranch['address']?.toString() ?? '',
      distanceKm: _toNullableDouble(route['distanceKm']),
      estimatedDurationMinutes: _toNullableInt(
        route['estimatedDurationMinutes'],
      ),
      vehicleRegistrationNumber:
          vehicle['registrationNumber']?.toString() ?? '',
      vehicleModel: vehicle['model']?.toString() ?? '',
      vehicleBrand: vehicle['brand']?.toString() ?? '',
      vehicleCapacity: _toNullableInt(vehicle['capacity']),
    );
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static DateTime _toDateTime(dynamic value) {
    if (value == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.tryParse(value.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
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

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }
}
