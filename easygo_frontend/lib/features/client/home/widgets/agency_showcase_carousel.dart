import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../../agencies/models/agency.dart';
import '../../../agencies/models/agency_route_offer.dart';
/// A rail of agency advertisements that advances on its own.
///
/// Every agency on the platform gets a card, showing what it is called, what it
/// says about itself, where it goes and what that costs. The route and the fare
/// come from the public route catalogue, so a card advertises something real
/// rather than a name over a pretty picture.
///
/// Everything drawn here comes from the agency's own record: the colour from its
/// id, the artwork from the same hash, the words from its description and its
/// branches. There is no agency photography in this project and none is
/// invented — an agency that has set a logo shows it as the badge, and one that
/// has not gets its monogram. `logoUrl` has been on the record and in the API
/// since the schema was written and no agency has ever set one, so the monogram
/// is the branch that actually renders today.
class AgencyShowcaseCarousel extends StatefulWidget {
  const AgencyShowcaseCarousel({
    super.key,
    required this.agencies,
    required this.offers,
    required this.onOpen,
  });

  final List<Agency> agencies;

  /// The route to advertise each agency with, keyed by agency id. An agency with
  /// no entry simply advertises less.
  final Map<String, AgencyRouteOffer> offers;

  final void Function(Agency agency) onOpen;

  /// How long a card is held before the rail moves on. Long enough to read a
  /// name, a route and a fare; short enough that a reader who is only watching
  /// still sees the whole set without waiting.
  ///
  /// Public so a test can wait for exactly one advance instead of guessing at
  /// it and silently passing when the pacing changes.
  static const Duration dwell = Duration(seconds: 5);

  @override
  State<AgencyShowcaseCarousel> createState() => _AgencyShowcaseCarouselState();
}

class _AgencyShowcaseCarouselState extends State<AgencyShowcaseCarousel> {
  static const Duration _travel = Duration(milliseconds: 600);

  /// Deliberately short. This is a rail a reader passes on the way to the agency
  /// list, not the destination, so it is tall enough for a badge, a name, a
  /// tagline and a fare, and no taller.
  static const double _height = 158;

  late final PageController _controller;

  Timer? _timer;

  int _page = 0;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();

    // Always opens on the first agency. The rail reaches every other agency
    // within a few seconds anyway, and one that opened somewhere different on
    // each visit would be unpredictable without being any more alive.
    _controller = PageController(viewportFraction: 0.87);

    // Started here, not in didChangeDependencies: that only fires when the
    // accessibility setting *changes*, so a rail whose first frame is already
    // correct would never have started at all.
    _restartTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // A reader who has asked the system to reduce motion has asked for this
    // among everything else. The rail still works by hand.
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      _restartTimer();
    }
  }

  @override
  void didUpdateWidget(AgencyShowcaseCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.agencies.length != widget.agencies.length) {
      if (_page >= widget.agencies.length) {
        _page = 0;

        if (_controller.hasClients) {
          _controller.jumpToPage(0);
        }
      }

      _restartTimer();
    }
  }

  @override
  void dispose() {
    // A periodic timer that outlives the screen fails widget tests at teardown
    // and keeps a disposed controller alive.
    _timer?.cancel();

    _controller.dispose();

    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;

    // One card has nothing to advance to, and nothing to advance for.
    if (_reduceMotion || widget.agencies.length < 2) {
      return;
    }

    _timer = Timer.periodic(AgencyShowcaseCarousel.dwell, (_) {
      _advance();
    });
  }

  void _advance() {
    if (!mounted || !_controller.hasClients) {
      return;
    }

    final int next = (_page + 1) % widget.agencies.length;

    _controller.animateToPage(
      next,
      duration: _travel,
      curve: Curves.easeInOutCubic,
    );
  }

  /// Holds the rail still while a finger is on it.
  ///
  /// Auto-advancing under someone who is mid-swipe moves the card they were
  /// reaching for. The dwell restarts on release, so a reader who lifts a finger
  /// still gets a full pause before the next move.
  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _timer?.cancel();
      _timer = null;
    } else if (notification is ScrollEndNotification) {
      _restartTimer();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.agencies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: _height,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.agencies.length,
              onPageChanged: (int page) {
                setState(() {
                  _page = page;
                });
              },
              itemBuilder: (context, index) {
                final Agency agency = widget.agencies[index];

                return _AgencyAdCard(
                  agency: agency,
                  offer: widget.offers[agency.id],
                  onTap: () {
                    widget.onOpen(agency);
                  },
                );
              },
            ),
          ),
        ),

        if (widget.agencies.length > 1) ...[
          const SizedBox(height: 12),
          _Dots(count: widget.agencies.length, current: _page),
        ],
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    // Ten agencies would be ten dots in a row on a phone. Past a handful they
    // stop being a position and become a texture, so the rail falls back to a
    // count instead.
    if (count > 6) {
      return Text(
        '${current + 1} / $count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool isCurrent = index == current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: isCurrent ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isCurrent
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

/// One agency, as an advertisement.
class _AgencyAdCard extends StatelessWidget {
  const _AgencyAdCard({
    required this.agency,
    required this.offer,
    required this.onTap,
  });

  final Agency agency;
  final AgencyRouteOffer? offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int seed = _fnv1a(agency.id);

    final List<Color> colors = agencyPosterColors(agency.id);

    final String? logoUrl = agency.logoUrl?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _TravelPosterPainter(seed)),

                // Text sits on artwork, and a photograph would need the same, so
                // both get the same scrim rather than two layouts.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.12),
                        Colors.black.withValues(alpha: 0.58),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Badge(
                            name: agency.name,
                            logoUrl: logoUrl,
                            monogramColor: colors.last,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Text(
                        agency.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),

                      if (_tagline(agency) case final String tagline) ...[
                        const SizedBox(height: 3),
                        Text(
                          tagline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.86),
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                      ],

                      if (offer case final AgencyRouteOffer route) ...[
                        const SizedBox(height: 9),
                        _FarePill(offer: route),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The line under the name: what the agency says about itself, or the shape of
  /// its network when it has not said anything.
  static String? _tagline(Agency agency) {
    final String? description = agency.description?.trim();

    if (description != null && description.isNotEmpty) {
      return description;
    }

    final String cities = agency.cities;

    return cities.isEmpty ? null : cities;
  }
}

/// The advertised route and what that route costs, as one readable strip.
///
/// The fare is the price of *this* route, not a "from" price, because that is
/// what the platform actually stores. Writing "from" over a single known fare
/// would invent a range that nothing supports.
class _FarePill extends StatelessWidget {
  const _FarePill({required this.offer});

  final AgencyRouteOffer offer;

  @override
  Widget build(BuildContext context) {
    final String? duration = offer.formattedDuration;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.alt_route_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 7),
          Expanded(
            // One line: the card is short, and two stacked lines spent height
            // the route and the fare do not need.
            child: Text(
              '${offer.fromCity} → ${offer.toCity} · ${offer.formattedFare}'
              '${duration == null ? '' : ' · $duration'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The agency's badge: its logo when it has one, its monogram when it does not.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.name,
    required this.logoUrl,
    required this.monogramColor,
  });

  final String name;
  final String? logoUrl;
  final Color monogramColor;

  @override
  Widget build(BuildContext context) {
    final String? url = logoUrl?.trim();

    return Container(
      width: 38,
      height: 38,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: url == null || url.isEmpty
          ? _monogram()
          : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                // A logo that will not load must not leave a blank badge.
                errorBuilder: (context, error, stackTrace) {
                  return _monogram();
                },
              ),
            ),
    );
  }

  Widget _monogram() {
    return Center(
      child: Text(
        _initials(name),
        style: TextStyle(
          color: monogramColor,
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Up to two letters from the agency's name, for the card's badge.
String _initials(String name) {
  final Iterable<String> words = name
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty);

  if (words.isEmpty) {
    return '?';
  }

  final String letters = words
      .take(2)
      .map((String word) => word.characters.first)
      .join();

  return letters.toUpperCase();
}

/// FNV-1a over the code units.
///
/// Not `String.hashCode`, which is not promised to be stable across runs, and
/// not a character sum, which two ids collide under easily.
int _fnv1a(String value) {
  const int offsetBasis = 0x811C9DC5;
  const int prime = 0x01000193;

  int hash = offsetBasis;

  for (final int unit in value.codeUnits) {
    hash = ((hash ^ unit) * prime) & 0xFFFFFFFF;
  }

  return hash;
}

/// The gradient an agency's generated card is drawn in.
///
/// Derived from the agency's id rather than picked at random, so an agency keeps
/// the same colour between visits — a card that changed every time would be
/// decoration, not identity.
///
/// The hue is spread around the whole wheel rather than drawn from a short list
/// of palettes. A list is what made two agencies wear the same colour: with six
/// entries that was arithmetic, not bad luck, and both seeded agencies landed on
/// the same one twice over. Saturation and lightness are fixed, so every hue
/// still produces a card dark enough for the white text on it.
List<Color> agencyPosterColors(String agencyId) {
  final double hue = (_fnv1a(agencyId) % 360).toDouble();

  return <Color>[
    HSLColor.fromAHSL(1, hue, 0.60, 0.30).toColor(),
    HSLColor.fromAHSL(1, (hue + 20) % 360, 0.66, 0.19).toColor(),
  ];
}

/// A travel poster: two ranges of hills with a dashed route running across them.
///
/// Drawn rather than photographed. It says "travel" without depicting a vehicle
/// or a place this app knows nothing about, it scales cleanly, and it works with
/// no network at all. Both the hill line and the route are moved by [seed], so
/// two agencies that end up with similar colours still do not look like the same
/// card.
class _TravelPosterPainter extends CustomPainter {
  const _TravelPosterPainter(this.seed);

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    _hill(canvas, size, base: 0.74, crest: 0.16 + (seed % 6) * 0.05, alpha: 0.09);

    _hill(canvas, size, base: 0.88, crest: 0.44 + (seed % 4) * 0.06, alpha: 0.14);

    _route(canvas, size);
  }

  /// One range of hills, as a single hump across the width.
  void _hill(
    Canvas canvas,
    Size size, {
    required double base,
    required double crest,
    required double alpha,
  }) {
    final double floor = size.height * base;

    final Path path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, floor)
      ..quadraticBezierTo(
        size.width * crest,
        size.height * (base - 0.34),
        size.width,
        floor,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: alpha));
  }

  /// A dashed route with a stop at each end.
  void _route(Canvas canvas, Size size) {
    final Offset start = Offset(size.width * 0.14, size.height * 0.62);
    final Offset end = Offset(size.width * 0.86, size.height * 0.24);

    final Path path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(size.width * 0.50, size.height * 0.28, end.dx, end.dy);

    final Paint dash = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const double dashLength = 7;
    const double gap = 8;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final double next = math.min(distance + dashLength, metric.length);

        canvas.drawPath(metric.extractPath(distance, next), dash);

        distance = next + gap;
      }
    }

    final Paint node = Paint()..color = Colors.white.withValues(alpha: 0.60);

    canvas.drawCircle(end, 5, node);
    canvas.drawCircle(start, 3.5, node);
  }

  @override
  bool shouldRepaint(_TravelPosterPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}
