import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';

/// A branch to place on the map.
///
/// Both the customer directory and the agency console have their own branch
/// models, so the widget takes the three things a marker needs rather than
/// either model.
class MapPoint {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;

  const MapPoint({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
  });
}

/// The branches of an agency, on a map.
///
/// The tiles come from OpenStreetMap, which is why there is no key to configure
/// and no "map not configured" state. That state used to exist and had to be
/// explained to the reader; using OpenStreetMap removes it rather than hiding
/// it.
///
/// OpenStreetMap's public tile server is free to use but not free of rules. It
/// asks to be identified, which `userAgentPackageName` does, and it requires the
/// attribution in the corner, which [RichAttributionWidget] draws. Its capacity
/// is donated, so an application with real traffic should point
/// [tileServerUrl] at its own tile server — see the README.
class BranchMap extends StatefulWidget {
  const BranchMap({
    super.key,
    required this.points,
    this.height = 220,
    this.tileServerUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  });

  /// Every branch to place. An empty list is a normal state: an agency can
  /// exist before it has a branch, and before it has coordinates.
  final List<MapPoint> points;

  final double height;

  /// The tile source. Public OpenStreetMap tiles are the default so the widget
  /// works out of the box; a deployment with traffic should supply its own.
  final String tileServerUrl;

  @override
  State<BranchMap> createState() => _BranchMapState();
}

class _BranchMapState extends State<BranchMap> {
  /// The application id, which OpenStreetMap asks for so it can tell an
  /// application apart from a scraper. It identifies the app, not the user.
  static const String _userAgentPackageName = 'com.example.easygo_frontend';

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return _frame(
        context,
        child: _centred(
          context,
          icon: Icons.location_off_outlined,
          title: 'No branch location to show',
          detail: 'This agency has no branch with coordinates yet.',
        ),
      );
    }

    return _frame(
      context,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: FlutterMap(
          options: MapOptions(
            // Framing the points rather than fixing a zoom means two branches in
            // different cities are both visible, instead of the second one being
            // off screen. Capped so a single branch does not zoom to a street
            // corner.
            initialCameraFit: CameraFit.coordinates(
              coordinates: <LatLng>[
                for (final MapPoint point in widget.points)
                  LatLng(point.latitude, point.longitude),
              ],
              padding: const EdgeInsets.all(48),
              maxZoom: 15,
            ),
            // The points are branches, not a route, so the map is for looking at
            // rather than travelling. Panning and zooming stay; rotating a
            // street map under the reader only makes it harder to read.
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: widget.tileServerUrl,
              userAgentPackageName: _userAgentPackageName,
              maxZoom: 19,
            ),

            // A pin, not a numbered dot: the sheet shows one branch at a time,
            // so a number would refer to a list that is not on screen.
            MarkerLayer(
              markers: <Marker>[
                for (final MapPoint point in widget.points)
                  Marker(
                    point: LatLng(point.latitude, point.longitude),
                    width: 44,
                    height: 44,
                    // The pin's tip is at the widget's bottom centre, so placing
                    // the widget above the point puts the tip on it rather than
                    // half a pin off.
                    alignment: Alignment.topCenter,
                    child: Tooltip(
                      message: point.title,
                      child: _marker(),
                    ),
                  ),
              ],
            ),

            // Required by OpenStreetMap, and the honest thing to show anyway.
            //
            // This is the bar that shows the credit rather than the one that
            // hides it behind a button: OpenStreetMap's tile policy asks for
            // attribution, and a credit a reader has to go looking for is not
            // really on display. The default text size is shrunk to fit a card
            // this small.
            DefaultTextStyle(
              style: const TextStyle(fontSize: 9),
              child: SimpleAttributionWidget(
                source: const Text('OpenStreetMap contributors'),
                backgroundColor: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A pin with a white halo, so it stays visible over pale and dark tiles
  /// alike. Map imagery is not a controlled background.
  Widget _marker() {
    return Stack(
      alignment: Alignment.center,
      children: const <Widget>[
        Icon(Icons.location_on, size: 44, color: Colors.white),
        Icon(Icons.location_on, size: 34, color: AppColors.primary),
      ],
    );
  }

  Widget _frame(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      height: widget.height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }

  Widget _centred(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: AppColors.primary),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}