/// A customer's rating of the agency that carried them.
///
/// The backend only accepts one from somebody who has a COMPLETED booking on
/// the trip, so a review always refers to a journey that actually happened.
class Review {
  final String id;

  /// 1 to 5.
  final int rating;

  final String? comment;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String userId;
  final String agencyId;
  final String tripId;

  /// The reviewer, as far as the API discloses it: a name, not an account.
  final String authorName;

  /// The route the reviewed trip ran, when the API attached the trip.
  final String routeLabel;

  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.agencyId,
    required this.tripId,
    required this.authorName,
    required this.routeLabel,
  });

  bool get hasComment => comment != null && comment!.trim().isNotEmpty;

  factory Review.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? user = _toMap(json['user']);
    final Map<String, dynamic>? trip = _toMap(json['trip']);
    final Map<String, dynamic>? route = _toMap(trip?['route']);

    final String authorName = [
      user?['firstName'],
      user?['lastName'],
    ].where((dynamic part) => part != null && '$part'.trim().isNotEmpty).join(' ');

    return Review(
      id: json['id']?.toString() ?? '',
      rating: _toInt(json['rating']),
      comment: _toNullableString(json['comment']),
      createdAt: _toNullableDateTime(json['createdAt']),
      updatedAt: _toNullableDateTime(json['updatedAt']),
      userId: json['userId']?.toString() ?? '',
      agencyId: json['agencyId']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      authorName: authorName,
      routeLabel: _routeLabel(route),
    );
  }

  /// "Yaounde → Douala", built from the branches the route hangs off.
  static String _routeLabel(Map<String, dynamic>? route) {
    if (route == null) {
      return '';
    }

    final String origin = _cityOf(route['originBranch']);
    final String destination = _cityOf(route['destinationBranch']);

    if (origin.isEmpty || destination.isEmpty) {
      return '';
    }

    return '$origin → $destination';
  }

  static String _cityOf(dynamic branch) {
    final Map<String, dynamic>? map = _toMap(branch);

    if (map == null) {
      return '';
    }

    final String city = map['city']?.toString().trim() ?? '';

    return city.isNotEmpty ? city : (map['name']?.toString().trim() ?? '');
  }

  static Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse('$value') ?? 0;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final String text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

/// What a set of reviews adds up to.
class ReviewSummary {
  final double average;
  final int count;

  const ReviewSummary({required this.average, required this.count});

  static const ReviewSummary empty = ReviewSummary(average: 0, count: 0);

  /// The agency endpoint reports the average and the count itself, over every
  /// review rather than the handful the page displays, so those figures are
  /// used as given instead of being recomputed from a truncated list.
  factory ReviewSummary.fromApi({
    required int count,
    required double average,
  }) {
    if (count <= 0) {
      return ReviewSummary.empty;
    }

    return ReviewSummary(average: average, count: count);
  }

  /// The average is rounded to one decimal, which is all a star row shows.
  factory ReviewSummary.fromReviews(List<Review> reviews) {
    if (reviews.isEmpty) {
      return ReviewSummary.empty;
    }

    final int total = reviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );

    return ReviewSummary(
      average: total / reviews.length,
      count: reviews.length,
    );
  }

  bool get hasReviews => count > 0;

  String get averageLabel => average.toStringAsFixed(1);
}

/// An agency's reviews together with the totals the API computed for them.
class AgencyReviews {
  final List<Review> reviews;
  final ReviewSummary summary;

  const AgencyReviews({required this.reviews, required this.summary});

  static const AgencyReviews empty = AgencyReviews(
    reviews: <Review>[],
    summary: ReviewSummary.empty,
  );

  /// Reads `{ count, averageRating, reviews }`, the shape the agency endpoint
  /// returns. Anything else is treated as an empty result rather than an error,
  /// because a page with no reviews is not a failure.
  factory AgencyReviews.fromJson(Map<String, dynamic> json) {
    final dynamic rawReviews = json['reviews'];

    final List<Review> reviews = <Review>[];

    if (rawReviews is List) {
      for (final dynamic item in rawReviews) {
        if (item is Map) {
          reviews.add(Review.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final dynamic rawAverage = json['averageRating'];

    final double average = rawAverage is num
        ? rawAverage.toDouble()
        : double.tryParse('$rawAverage') ?? 0;

    final dynamic rawCount = json['count'];

    final int count = rawCount is num
        ? rawCount.toInt()
        : int.tryParse('$rawCount') ?? reviews.length;

    return AgencyReviews(
      reviews: reviews,
      summary: ReviewSummary.fromApi(count: count, average: average),
    );
  }
}
