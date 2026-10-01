import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../../agencies/models/agency.dart';

/// A strip of agency posters that advances on its own.
///
/// Every agency on the platform gets a slide. An agency that has a logo shows
/// it; one that does not gets a poster built from its own record — a colour
/// derived from its id so it looks the same every time the reader sees it, its
/// monogram, and the cities its branches are in.
///
/// Nothing here invents a photograph. `logoUrl` has been on the agency record
/// and in the API since the beginning but no agency has ever set one, so the
/// generated poster is the branch that actually renders today; the image branch
/// starts working the moment an agency uploads a logo, with no change here.
class AgencyShowcaseCarousel extends StatefulWidget {
  const AgencyShowcaseCarousel({
    super.key,
    required this.agencies,
    required this.onOpen,
  });

  final List<Agency> agencies;

  final void Function(Agency agency) onOpen;

  @override
  State<AgencyShowcaseCarousel> createState() => _AgencyShowcaseCarouselState();
}

class _AgencyShowcaseCarouselState extends State<AgencyShowcaseCarousel> {
  /// How long a slide is held before the strip moves on. Long enough to read a
  /// name and two city names, short enough that a reader who is only watching
  /// sees the whole set without waiting.
  static const Duration _dwell = Duration(seconds: 4);

  static const Duration _travel = Duration(milliseconds: 600);

  late final PageController _controller;

  Timer? _timer;

  int _page = 0;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();

    // Always opens on the first agency. The strip reaches every other agency
    // within a few seconds anyway, and one that opened somewhere different on
    // each visit would be unpredictable without being any more alive.
    _controller = PageController(viewportFraction: 0.86);

    // Started here, not in didChangeDependencies: that only fires when the
    // accessibility setting *changes*, so a strip whose first frame is already
    // correct would never have started at all.
    _restartTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // A reader who has asked the system to reduce motion has asked for this,
    // among everything else. The strip still works by hand.
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

    // One slide has nothing to advance to, and nothing to advance for.
    if (_reduceMotion || widget.agencies.length < 2) {
      return;
    }

    _timer = Timer.periodic(_dwell, (_) {
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

  /// Holds the strip still while a finger is on it.
  ///
  /// Auto-advancing under someone who is mid-swipe moves the page they were
  /// reaching for. The dwell restarts on release, so a reader who lifts a
  /// finger still gets a full pause before the next move.
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
          height: 168,
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

                return _AgencyPoster(
                  agency: agency,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool isCurrent = index == current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isCurrent
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

/// One agency, as a poster.
class _AgencyPoster extends StatelessWidget {
  const _AgencyPoster({required this.agency, required this.onTap});

  final Agency agency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = agencyPosterColors(agency.id);

    final String? logoUrl = agency.logoUrl?.trim();

    final bool hasLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
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
                if (hasLogo)
                  Image.network(
                    logoUrl,
                    fit: BoxFit.cover,
                    // A logo that will not load must not leave a blank card,
                    // so the generated poster is already behind it.
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),

                if (!hasLogo)
                  CustomPaint(painter: const _RouteMotifPainter()),

                // Text sits on a photograph and on a gradient alike, so both
                // get the same scrim rather than two different layouts.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.10),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Monogram(name: agency.name, logoUrl: logoUrl),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
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
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),

                      if (_subtitle(agency) case final String subtitle) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],

                      if (_cities(agency) case final List<String> cities
                          when cities.isNotEmpty) ...[
                        const SizedBox(height: 11),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: cities.map((String city) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    city,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
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

  /// The line under the name: what the agency says about itself, or the shape
  /// of its network when it has not said anything.
  static String? _subtitle(Agency agency) {
    final String? description = agency.description?.trim();

    if (description != null && description.isNotEmpty) {
      return description;
    }

    final int branches = agency.activeBranches.length;

    if (branches == 0) {
      return null;
    }

    return branches == 1 ? '1 branch' : '$branches branches';
  }

  /// The cities the agency actually has branches in — never a route it does not
  /// serve, and never a city invented to fill the row.
  ///
  /// Taken from [Agency.cities] rather than re-derived, so the poster and the
  /// agency list under it cannot disagree about where an agency operates.
  static List<String> _cities(Agency agency) {
    return agency.cities
        .split(', ')
        .where((String city) => city.isNotEmpty)
        .take(3)
        .toList();
  }
}

class _Monogram extends StatelessWidget {
  const _Monogram({required this.name, required this.logoUrl});

  final String name;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final String? url = logoUrl?.trim();

    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: url == null || url.isEmpty
          ? _letters()
          : ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _letters();
                },
              ),
            ),
    );
  }

  Widget _letters() {
    return Center(
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Up to two letters from the agency's name, for the poster's badge.
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

/// A dashed route with two stops, drawn behind the text on a generated poster.
///
/// It reads as travel without depicting any particular vehicle or place, which
/// is the honest thing for an agency the app knows almost nothing about.
class _RouteMotifPainter extends CustomPainter {
  const _RouteMotifPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset start = Offset(size.width * 0.10, size.height * 0.72);
    final Offset end = Offset(size.width * 0.92, size.height * 0.30);

    final Path path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.10,
        end.dx,
        end.dy,
      );

    final Paint dash = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    _drawDashed(canvas, path, dash);

    final Paint node = Paint()..color = Colors.white.withValues(alpha: 0.55);

    canvas.drawCircle(end, 5, node);
    canvas.drawCircle(start, 3.5, node);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const double dash = 7;
    const double gap = 8;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final double next = math.min(distance + dash, metric.length);

        canvas.drawPath(metric.extractPath(distance, next), paint);

        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_RouteMotifPainter oldDelegate) => false;
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

/// The gradient an agency's generated poster is drawn in.
///
/// Derived from the agency's id rather than picked at random, so an agency keeps
/// the same colour between visits — a poster that changed every time would be
/// decoration, not identity.
///
/// The hue is spread around the whole wheel rather than drawn from a short list
/// of palettes. A list is what made two agencies wear the same colour: with six
/// entries that was arithmetic, not bad luck, and both seeded agencies landed on
/// the same one twice over. Saturation and lightness are fixed, so every hue
/// still produces a poster dark enough for the white text on it.
List<Color> agencyPosterColors(String agencyId) {
  final double hue = (_fnv1a(agencyId) % 360).toDouble();

  return <Color>[
    HSLColor.fromAHSL(1, hue, 0.60, 0.30).toColor(),
    HSLColor.fromAHSL(1, (hue + 20) % 360, 0.66, 0.19).toColor(),
  ];
}
