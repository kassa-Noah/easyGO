import 'package:easygo_frontend/features/reviews/models/review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Review.fromJson', () {
    test('reads the author name from the nested user', () {
      final Review review = Review.fromJson(<String, dynamic>{
        'id': 'r1',
        'rating': 5,
        'comment': '  Punctual and clean  ',
        'userId': 'u1',
        'agencyId': 'a1',
        'tripId': 't1',
        'createdAt': '2026-01-04T09:00:00.000Z',
        'user': <String, dynamic>{
          'id': 'u1',
          'firstName': 'Claire',
          'lastName': 'Client',
        },
      });

      expect(review.authorName, 'Claire Client');
      expect(review.rating, 5);
      expect(review.comment, 'Punctual and clean');
      expect(review.hasComment, isTrue);
      expect(review.createdAt, isNotNull);
    });

    test('builds the route label from the branch cities', () {
      final Review review = Review.fromJson(<String, dynamic>{
        'id': 'r1',
        'rating': 4,
        'trip': <String, dynamic>{
          'id': 't1',
          'route': <String, dynamic>{
            'originBranch': <String, dynamic>{
              'city': 'Yaounde',
              'name': 'Central Station',
            },
            'destinationBranch': <String, dynamic>{
              'city': 'Douala',
              'name': 'Bonaberi',
            },
          },
        },
      });

      expect(review.routeLabel, 'Yaounde → Douala');
    });

    test('falls back to the branch name when a city is missing', () {
      final Review review = Review.fromJson(<String, dynamic>{
        'rating': 3,
        'trip': <String, dynamic>{
          'route': <String, dynamic>{
            'originBranch': <String, dynamic>{'name': 'Mvan Terminal'},
            'destinationBranch': <String, dynamic>{'city': 'Douala'},
          },
        },
      });

      expect(review.routeLabel, 'Mvan Terminal → Douala');
    });

    test('leaves the route label empty when the trip was not attached', () {
      final Review review = Review.fromJson(<String, dynamic>{'rating': 2});

      expect(review.routeLabel, '');
      expect(review.authorName, '');
      expect(review.hasComment, isFalse);
    });

    test('treats a missing or blank comment as absent', () {
      final Review blank = Review.fromJson(<String, dynamic>{
        'rating': 1,
        'comment': '   ',
      });

      expect(blank.hasComment, isFalse);
      expect(blank.comment, isNull);
    });

    test('coerces a string rating', () {
      final Review review = Review.fromJson(<String, dynamic>{'rating': '4'});

      expect(review.rating, 4);
    });
  });

  group('ReviewSummary', () {
    test('is empty for no reviews', () {
      final ReviewSummary summary = ReviewSummary.fromReviews(
        <Review>[],
      );

      expect(summary.count, 0);
      expect(summary.average, 0);
      expect(summary.hasReviews, isFalse);
      expect(summary.averageLabel, '0.0');
    });

    test('averages the ratings and reports one decimal', () {
      final ReviewSummary summary = ReviewSummary.fromReviews(<Review>[
        _review(5),
        _review(4),
        _review(4),
      ]);

      expect(summary.count, 3);
      expect(summary.average, closeTo(4.333, 0.001));
      expect(summary.averageLabel, '4.3');
      expect(summary.hasReviews, isTrue);
    });
  });

  group('AgencyReviews.fromJson', () {
    // GET /reviews/agency/:agencyId answers with
    // { count, averageRating, reviews } rather than a bare list.
    test('reads the nested payload and keeps the API totals', () {
      final AgencyReviews result = AgencyReviews.fromJson(
        <String, dynamic>{
          'count': 7,
          'averageRating': 4.29,
          'reviews': <dynamic>[
            <String, dynamic>{
              'id': 'r1',
              'rating': 5,
              'user': <String, dynamic>{
                'firstName': 'Claire',
                'lastName': 'Client',
              },
            },
          ],
        },
      );

      expect(result.reviews, hasLength(1));
      expect(result.reviews.first.authorName, 'Claire Client');
      expect(result.summary.average, closeTo(4.29, 0.001));
      expect(result.summary.averageLabel, '4.3');
      // The count is the agency's total, not the length of the page.
      expect(result.summary.count, 7);
    });

    test('reads an agency with no reviews yet', () {
      final AgencyReviews result = AgencyReviews.fromJson(<String, dynamic>{
        'count': 0,
        'averageRating': 0,
        'reviews': <dynamic>[],
      });

      expect(result.reviews, isEmpty);
      expect(result.summary.hasReviews, isFalse);
      expect(result.summary.averageLabel, '0.0');
    });

    test('treats a malformed payload as no reviews', () {
      final AgencyReviews result = AgencyReviews.fromJson(
        <String, dynamic>{},
      );

      expect(result.reviews, isEmpty);
      expect(result.summary.hasReviews, isFalse);
    });
  });
}

Review _review(int rating) {
  return Review(
    id: 'r$rating',
    rating: rating,
    comment: null,
    createdAt: null,
    updatedAt: null,
    userId: 'u1',
    agencyId: 'a1',
    tripId: 't1',
    authorName: 'Claire Client',
    routeLabel: '',
  );
}
