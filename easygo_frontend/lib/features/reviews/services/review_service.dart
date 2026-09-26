import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/review.dart';

/// Ratings customers leave for the agency that carried them.
///
/// Reading an agency's reviews is public. Writing one is not: the backend only
/// accepts a review from somebody with a COMPLETED booking on that trip, and
/// only one per trip, so the errors it returns are meaningful and are passed on
/// rather than replaced with a generic message.
class ReviewService {
  ReviewService._();

  static final ReviewService instance = ReviewService._();

  final ApiClient _apiClient = ApiClient.instance;

  /// Every review left for an agency, newest first, together with the average
  /// and the total the API computed.
  Future<AgencyReviews> getAgencyReviews(String agencyId) async {
    final dynamic response = await _apiClient.get('/reviews/agency/$agencyId');

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'The review list is missing.');
    }

    return AgencyReviews.fromJson(Map<String, dynamic>.from(data));
  }

  /// The signed-in customer's own reviews.
  Future<List<Review>> getMyReviews() async {
    final dynamic response = await _apiClient.get(
      '/reviews/me',
      authenticated: true,
    );

    return _mapList(response);
  }

  /// Rates a trip the customer has completed.
  ///
  /// Throws an [ApiException] carrying the backend's own message when the trip
  /// was not completed (403) or has already been reviewed (409).
  Future<Review> createReview({
    required String agencyId,
    required String tripId,
    required int rating,
    String? comment,
  }) async {
    final dynamic response = await _apiClient.post(
      '/reviews',
      authenticated: true,
      body: {
        'agencyId': agencyId,
        'tripId': tripId,
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'The saved review is missing.');
    }

    return Review.fromJson(Map<String, dynamic>.from(data));
  }

  List<Review> _mapList(dynamic response) {
    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(message: 'The review list is missing.');
    }

    final List<Review> reviews = <Review>[];

    for (final dynamic item in data) {
      if (item is Map) {
        reviews.add(Review.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return reviews;
  }
}
