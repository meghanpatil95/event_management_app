import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Displays an OpenStreetMap map centered on the event location with a marker.
///
/// Uses [flutter_map] with OSM tiles (no API keys). Used on the Event Details
/// screen when the event has [latitude] and [longitude]. Supports an optional
/// [title] for the marker (shown as tooltip on tap or as marker label).
class EventLocationMap extends StatelessWidget {
  /// Latitude for map center and marker.
  final double latitude;

  /// Longitude for map center and marker.
  final double longitude;

  /// Optional title shown for the marker (e.g. event name).
  final String? title;

  /// Height of the map container. Defaults to 200.
  final double height;

  const EventLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.title,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 13.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.webwork.event_management_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: Tooltip(
                    message: title ?? 'Event location',
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
