import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fallback web URL for maps (works when native app is not available).
String _googleMapsWebUrl(double lat, double lng) {
  print("lat _googleMapsWebUrl $lat ,lang $lng");
  return 'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$lat,$lng';
} //'https://www.google.com/maps?q=$lat,$lng';

/// Opens the event location in the native maps app (Google Maps on Android,
/// Apple Maps on iOS) or in Google Maps in the browser as fallback.
///
/// Does not use any Maps SDK or directions API. Uses deep links only; free and
/// requires no API keys. Does not block the UI; [onError] is called only if
/// launching fails (e.g. no app and web also failed).
Future<void> openEventLocationInMaps(
  double lat,
  double lng, {
  void Function(String? message)? onError,
}) async {
  final urlsToTry = <Uri>[];

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      urlsToTry.add(Uri.parse('geo:$lat,$lng'));
      break;
    case TargetPlatform.iOS:
      urlsToTry.add(Uri.parse('https://maps.apple.com/?ll=$lat,$lng'));
      break;
    default:
      break;
  }

  urlsToTry.add(Uri.parse(_googleMapsWebUrl(lat, lng)));

  for (final uri in urlsToTry) {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // Try next URL
    }
  }

  onError?.call('Could not open maps');
}
