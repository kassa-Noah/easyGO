import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/star_rating.dart';

/// Rates a trip that has already been travelled.
///
/// The backend decides whether a review is allowed: it checks for a COMPLETED
/// booking on this trip and refuses a second review of the same trip. Its
/// message is shown as it comes, because "you can only review a trip that you
/// have completed" and "you have already reviewed this trip" say more than a
/// generic failure would.
class WriteReviewScreen extends StatefulWidget {
  final String agencyId;
  final String tripId;
  final String agencyName;

  /// Shown above the form so the reviewer knows which journey this is.
  final String routeLabel;

  const WriteReviewScreen({
    super.key,
    required this.agencyId,
    required this.tripId,
    required this.agencyName,
    required this.routeLabel,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final TextEditingController _commentController = TextEditingController();

  final ReviewService _reviews = ReviewService.instance;

  int _rating = 0;

  bool _isSubmitting = false;

  /// Shown in the form when the backend refuses the review.
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);

    if (_rating == 0) {
      setState(() {
        _errorMessage = l10n.selectRatingError;
      });

      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final Review review = await _reviews.createReview(
        agencyId: widget.agencyId,
        tripId: widget.tripId,
        rating: _rating,
        comment: _commentController.text,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          title: Text(l10n.reviewSubmittedTitle),
          content: Text(l10n.reviewSubmittedMessage(widget.agencyName)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) {
        return;
      }

      // The caller shows the review, so hand back what was stored.
      Navigator.pop(context, review);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rateThisAgency)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                GlassContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  borderRadius: 18,
                  child: Column(
                    children: [
                      Text(
                        widget.agencyName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.routeLabel.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.routeLabel,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        l10n.yourRating,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      StarRatingInput(
                        value: _rating,
                        enabled: !_isSubmitting,
                        onChanged: (int value) {
                          setState(() {
                            _rating = value;
                            _errorMessage = null;
                          });
                        },
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _commentController,
                        enabled: !_isSubmitting,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 1000,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: l10n.review,
                          hintText: l10n.reviewHint,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildError(context, _errorMessage!),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rate_review_outlined),
                    label: Text(l10n.submitReview),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
