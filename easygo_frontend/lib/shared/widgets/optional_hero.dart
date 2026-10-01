import 'package:flutter/material.dart';

/// A [Hero] that only flies when it was given a tag.
///
/// A screen reached by tapping a raised element is usually reachable another
/// way too — from a notification, from a refresh, from a different list — and
/// on those journeys nothing on the outgoing route carries the tag. A [Hero]
/// whose tag has no counterpart is a flight with nothing to fly from, so the
/// tag is optional and the element is simply drawn in place without one.
class OptionalHero extends StatelessWidget {
  const OptionalHero({super.key, required this.tag, required this.child});

  /// The tag of the flight, or null to draw [child] in place.
  final String? tag;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String? tag = this.tag;

    if (tag == null) {
      return child;
    }

    return Hero(tag: tag, child: child);
  }
}
