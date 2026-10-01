import 'package:flutter/material.dart';

/// A placeholder block for content that has not arrived yet.
///
/// Used through [SkeletonList] rather than on its own, so a whole screen shares
/// one animation instead of one per block.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 12,
    this.animation,
  });

  final double height;
  final double? width;
  final double radius;

  /// Drives the sweep. Null renders a still block, which is what a reader who
  /// has asked for reduced motion should get: a placeholder is information, and
  /// it does not need to move to say "something is coming".
  final Animation<double>? animation;

  static const Color _lightBase = Color(0xFFE3EAF4);
  static const Color _lightHighlight = Color(0xFFF4F8FD);

  static const Color _darkBase = Color(0xFF1B2739);
  static const Color _darkHighlight = Color(0xFF25344A);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color base = isDark ? _darkBase : _lightBase;

    final Animation<double>? animation = this.animation;

    if (animation == null) {
      return _block(height, width, radius, base);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // One sweep per cycle: the highlight starts off the left edge and
        // finishes off the right.
        final double position = animation.value * 3 - 1;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(position, 0),
              end: Alignment(position + 1, 0),
              colors: <Color>[
                base,
                isDark ? _darkHighlight : _lightHighlight,
                base,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _block(double height, double? width, double radius, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// The shape of the cards this app lists: an icon, a title line and a
/// supporting line.
///
/// Placeholders that match what is arriving make a wait feel shorter than a
/// spinner does, because the screen is already the shape it is about to become
/// and nothing jumps when the data lands.
class SkeletonList extends StatefulWidget {
  const SkeletonList({
    super.key,
    this.rows = 4,
    this.height = 96,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
  });

  final int rows;

  /// Height of each placeholder card, so a screen can match its own rows.
  final double height;

  final EdgeInsetsGeometry padding;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion == _reduceMotion && _controller.isAnimating) {
      return;
    }

    _reduceMotion = reduceMotion;

    if (reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    // A repeating controller that outlives the screen fails widget tests at
    // teardown and keeps painting into a disposed tree.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(widget.rows, (int index) {
        return Padding(
          padding: widget.padding,
          child: _SkeletonCard(
            height: widget.height,
            animation: _reduceMotion ? null : _controller,
          ),
        );
      }),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height, required this.animation});

  final double height;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Falls back rather than asserting. Both consoles define these two, but
        // this card is on seventeen screens now, and a placeholder that crashes
        // on a theme that forgot to set a border colour would take the screen
        // down at the exact moment it is meant to be reassuring.
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerTheme.color ?? theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 44, width: 44, radius: 13, animation: animation),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 13, radius: 6, animation: animation),

                const SizedBox(height: 10),

                FractionallySizedBox(
                  widthFactor: 0.62,
                  child: SkeletonBox(
                    height: 11,
                    radius: 6,
                    animation: animation,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
