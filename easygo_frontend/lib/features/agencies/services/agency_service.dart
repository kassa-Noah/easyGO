import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/agency.dart';

class AgencyService {
  AgencyService._();

  static final AgencyService instance = AgencyService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<List<Agency>> getAgencies() async {
    final dynamic response = await _apiClient.get('/agencies');

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid agency response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'Agency information is missing.');
    }

    return data
        .whereType<Map>()
        .map((item) => Agency.fromJson(Map<String, dynamic>.from(item)))
        .where((agency) => agency.isActive)
        .toList();
  }
}
