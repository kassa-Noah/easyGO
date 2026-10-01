/// The route an agency is advertised with.
///
/// The platform already knows which pairs of branches an agency serves and what
/// it charges for them, so the customer home can say so. A poster that shows a
/// name and a picture and nothing else is decoration; a poster that says where
/// the agency goes and what it costs is an advertisement.
class AgencyRouteOffer {
  const AgencyRouteOffer({
    required this.agencyId,
    required this.fromCity,
    required this.toCity,
    required this.baseFare,
    this.durationMinutes,
  });

  final String agencyId;

  final String fromCity;
  final String toCity;

  final double baseFare;

  final int? durationMinutes;

  /// "6 000 FCFA".
  ///
  /// Grouped by hand rather than with `intl`, which is not a declared
  /// dependency of this app.
  String get formattedFare => '${_grouped(baseFare.round())} FCFA';

  /// The journey time as "4h 45", or null when the platform does not know it.
  String? get formattedDuration {
    final int? minutes = durationMinutes;

    if (minutes == null || minutes <= 0) {
      return null;
    }

    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;

    if (hours == 0) {
      return '${rest}min';
    }

    return rest == 0 ? '${hours}h' : '${hours}h ${rest}min';
  }

  /// Reads one route from the public catalogue.
  ///
  /// Returns null rather than throwing for anything it cannot read. A single
  /// malformed route should cost one advertisement, not the whole home screen.
  static AgencyRouteOffer? fromJson(Map<String, dynamic> json) {
    final dynamic origin = json['originBranch'];
    final dynamic destination = json['destinationBranch'];

    if (origin is! Map || destination is! Map) {
      return null;
    }

    final String agencyId = origin['agencyId']?.toString() ?? '';
    final String fromCity = origin['city']?.toString().trim() ?? '';
    final String toCity = destination['city']?.toString().trim() ?? '';

    if (agencyId.isEmpty || fromCity.isEmpty || toCity.isEmpty) {
      return null;
    }

    // Prisma serialises Decimal columns as strings, so this is not a number
    // until it has been parsed.
    final double? fare = _toDouble(json['baseFare']);

    if (fare == null || fare <= 0) {
      return null;
    }

    return AgencyRouteOffer(
      agencyId: agencyId,
      fromCity: fromCity,
      toCity: toCity,
      baseFare: fare,
      durationMinutes: _toInt(json['estimatedDurationMinutes']),
    );
  }
}

double? _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return value == null ? null : double.tryParse(value.toString());
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.round();
  }

  return value == null ? null : int.tryParse(value.toString());
}

/// Thousands separated by a thin space, so a fare reads as a price.
String _grouped(int value) {
  final String digits = value.abs().toString();

  final StringBuffer buffer = StringBuffer();

  for (int index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write('\u202F');
    }

    buffer.write(digits[index]);
  }

  return value < 0 ? '-$buffer' : buffer.toString();
}
