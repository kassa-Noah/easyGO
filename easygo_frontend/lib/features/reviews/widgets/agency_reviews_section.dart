import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import 'star_rating.dart';

/// The reviews left for one agency.
///
/// Loads its own data so the page around it does not have to wait: a slow or
/// failing review request leaves the rest of the agency page intact and shows
/// the problem here. A brand new agency has no reviews, which is a normal state
/// and is explained rather than left blank.
class AgencyReviewsSection extends StatefulWidget {
  final String agencyId;
  final String agencyName;

  /// How many reviews the page shows before it stops. The API returns them all.
  final int limit;

  const AgencyReviewsSection({
    super.key,
    required this.agencyId,
    required this.agencyName,
    this.limit = 5,
  });

  @override
  State<AgencyReviewsSection> createState() => _AgencyReviewsSectionState();
}

class _AgencyReviewsSectionState extends State<AgencyReviewsSection> {
  final ReviewService _reviews = ReviewService.instance;

  List<Review> _items = <Review>[];

  ReviewSummary _summary = ReviewSummary.empty;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final AgencyReviews result = await _reviews.getAgencyReviews(
        widget.agencyId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _items = result.reviews;
        _summary = result.summary;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.customerReviews,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          _buildError(context, l10n)
        else if (_items.isEmpty)
          _buildEmptyState(context, l10n)
        else
          _buildSummaryAndList(context, l10n),
      ],
    );
  }

  Widget _buildSummaryAndList(BuildContext context, AppLocalizations l10n) {
    final ReviewSummary summary = _summary;

    final List<Review> shown = _items.length > widget.limit
        ? _items.sublist(0, widget.limit)
        : _items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    summary.averageLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  StarRating(rating: summary.average, size: 20),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.basedOnReviews(summary.count),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.reviewsArePublic,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...shown.map(
          (Review review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReviewCard(review: review),
          ),
        ),
        if (_items.length > shown.length)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              l10n.reviews(_items.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
      child: Column(
        children: [
          const Icon(
            Icons.reviews_outlined,
            size: 32,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noReviewsYet,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.noReviewsYetExplanation,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, AppLocalizations l10n) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.error, size: 30),
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  String _dateLabel() {
    final DateTime? created = review.createdAt?.toLocal();

    if (created == null) {
      return '';
    }

    final String day = created.day.toString().padLeft(2, '0');
    final String month = created.month.toString().padLeft(2, '0');

    return '$day/$month/${created.year}';
  }

  @override
  Widget build(BuildContext context) {
    final String date = _dateLabel();

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.authorName.isEmpty ? '—' : review.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (date.isNotEmpty)
                Text(date, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          StarRating(rating: review.rating.toDouble(), size: 16),
          if (review.routeLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.routeLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (review.hasComment) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}
