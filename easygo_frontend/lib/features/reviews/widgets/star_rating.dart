import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// A read-only row of stars.
///
/// Half ratings are rounded up to the next whole star so a 4.5 reads as five
/// filled stars rather than as an ambiguous half glyph; the exact average is
/// always shown as a number beside it.
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color starColor = color ?? AppColors.warning;
    final int filled = rating.isFinite ? rating.round().clamp(0, 5) : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int index) {
        return Icon(
          index < filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: index < filled
              ? starColor
              : AppColors.textLight.withValues(alpha: 0.45),
        );
      }),
    );
  }
}

/// A row of stars the user picks from.
class StarRatingInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  /// Set while the form is submitting.
  final bool enabled;

  final double size;

  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(5, (int index) {
        final int star = index + 1;
        final bool selected = star <= value;

        return IconButton(
          onPressed: enabled ? () => onChanged(star) : null,
          tooltip: '$star',
          iconSize: size,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          constraints: const BoxConstraints(),
          icon: Icon(
            selected ? Icons.star_rounded : Icons.star_outline_rounded,
            color: selected
                ? AppColors.warning
                : AppColors.textLight.withValues(alpha: 0.45),
          ),
        );
      }),
    );
  }
}
