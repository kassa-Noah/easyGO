import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/maps/maps_config.dart';

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

/// The branches of an agency, on a Google map.
///
/// The platform used to draw a panel here saying the coordinates were known but
/// that there was no map to show them on. This shows the map when a Google Maps
/// key is configured, and when one is not it says exactly what is missing and
/// keeps the coordinates readable — it never draws a fake map or an empty grey
/// box that looks like a failure.
class BranchMap extends StatefulWidget {
  const BranchMap({
    super.key,
    required this.points,
    this.height = 220,
  });

  /// Every branch to place. An empty list is a normal state: an agency can
  /// exist before it has a branch, and before it has coordinates.
  final List<MapPoint> points;

  final double height;

  @override
  State<BranchMap> createState() => _BranchMapState();
}

class _BranchMapState extends State<BranchMap> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// A CameraUpdate that frames every point.
  ///
  /// Fitting the bounds rather than picking a zoom means two branches in
  /// different cities are both visible, instead of the second one being off
  /// screen.
  CameraUpdate? get _initialCamera {
    final List<MapPoint> points = widget.points;

    if (points.isEmpty) {
      return null;
    }

    if (points.length == 1) {
      return CameraUpdate.newLatLngZoom(
        LatLng(points.first.latitude, points.first.longitude),
        13,
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final MapPoint point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    return CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      // Room for the markers themselves, which sit above their coordinate.
      56,
    );
  }

  Set<Marker> get _markers {
    return widget.points
        .map(
          (MapPoint point) => Marker(
            markerId: MarkerId(point.id),
            position: LatLng(point.latitude, point.longitude),
            infoWindow: InfoWindow(
              title: point.title,
              snippet: point.description,
            ),
          ),
        )
        .toSet();
  }

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

    if (!MapsConfig.isConfigured) {
      return _frame(
        context,
        child: _centred(
          context,
          icon: Icons.map_outlined,
          title: 'Map not configured',
          detail: MapsConfig.setupHint,
          footer: _coordinateList(context),
        ),
      );
    }

    return _frame(
      context,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;

            final CameraUpdate? camera = _initialCamera;

            if (camera != null) {
              controller.moveCamera(camera);
            }
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.points.first.latitude,
              widget.points.first.longitude,
            ),
            zoom: 11,
          ),
          markers: _markers,
          // The points are branches, not a route, so the map is for looking at
          // rather than travelling: no zoom buttons cluttering a small card, but
          // still pannable and zoomable by gesture.
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }

  Widget _coordinateList(BuildContext context) {
    return Column(
      children: [
        for (final MapPoint point in widget.points)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${point.title}: '
              '${point.latitude.toStringAsFixed(4)}, '
              '${point.longitude.toStringAsFixed(4)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
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
    Widget? footer,
  }) {
    return SingleChildScrollView(
      child: Column(
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
          ?footer,
        ],
      ),
    );
  }
}