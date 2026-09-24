class AgencyBranch {
  final String id;
  final String name;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final bool isActive;
  final String agencyId;

  const AgencyBranch({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.isActive,
    required this.agencyId,
  });

  bool get hasCoordinates {
    return latitude != null && longitude != null;
  }

  factory AgencyBranch.fromJson(Map<String, dynamic> json) {
    return AgencyBranch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      phone: json['phone']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      agencyId: json['agencyId']?.toString() ?? '',
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}

class Agency {
  final String id;
  final String name;
  final String? description;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? website;
  final bool isActive;
  final List<AgencyBranch> branches;

  const Agency({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.email,
    required this.logoUrl,
    required this.website,
    required this.isActive,
    required this.branches,
  });

  List<AgencyBranch> get activeBranches {
    return branches.where((branch) => branch.isActive).toList();
  }

  String get cities {
    final List<String> values = activeBranches
        .map((branch) => branch.city.trim())
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();

    return values.join(', ');
  }

  factory Agency.fromJson(Map<String, dynamic> json) {
    final dynamic branchesData = json['branches'];

    final List<AgencyBranch> branches = branchesData is List
        ? branchesData
              .whereType<Map>()
              .map(
                (branch) =>
                    AgencyBranch.fromJson(Map<String, dynamic>.from(branch)),
              )
              .toList()
        : <AgencyBranch>[];

    return Agency(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Transport Agency',
      description: json['description']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      website: json['website']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      branches: branches,
    );
  }
}
