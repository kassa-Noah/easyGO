import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/agency_route_offer.dart';

/// The route each agency is advertised with.
///
/// Read from the public route catalogue rather than from a field on the agency,
/// because that is where the platform actually records what an agency serves
/// and what it charges.
class RouteOfferService {
  RouteOfferService._();

  static final RouteOfferService instance = RouteOfferService._();

  final ApiClient _apiClient = ApiClient.instance;

  /// One offer per agency, keyed by agency id.
  ///
  /// The cheapest route an agency runs is the one worth advertising, so that is
  /// the one kept when it runs several.
  Future<Map<String, AgencyRouteOffer>> getOffersByAgency() async {
    final dynamic response = await _apiClient.get('/routes');

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid route response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      return const <String, AgencyRouteOffer>{};
    }

    final Map<String, AgencyRouteOffer> offers = <String, AgencyRouteOffer>{};

    for (final dynamic item in data) {
      if (item is! Map) {
        continue;
      }

      final AgencyRouteOffer? offer = AgencyRouteOffer.fromJson(
        Map<String, dynamic>.from(item),
      );

      if (offer == null) {
        continue;
      }

      final AgencyRouteOffer? current = offers[offer.agencyId];

      if (current == null || offer.baseFare < current.baseFare) {
        offers[offer.agencyId] = offer;
      }
    }

    return offers;
  }
}
