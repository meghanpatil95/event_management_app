# Map Options for Event Location

This document describes the two main options for displaying event location on a map in the app.

---

## Option 1: OpenStreetMap via flutter_map (used in this assignment)

**Status:** Implemented and used for this assignment.

- **Free:** No API keys or billing. Uses OpenStreetMap tile servers through the [flutter_map](https://pub.dev/packages/flutter_map) package.
- **Dependencies:** `flutter_map`, `latlong2`. No Google or other vendor SDKs.
- **Why used here:** OpenStreetMap is used for this assignment to avoid billing and API-key setup, so the app runs out of the box on all platforms without configuration.

**Implementation:** See `lib/features/maps/`. The map is shown on the Event Details screen when an event has `latitude` and `longitude`, with a single marker at the event location, centered at zoom ~13–14.

**Compliance:** When using the public OpenStreetMap tile server, ensure you follow the [OSM Tile Usage Policy](https://operations.osmfoundation.org/policies/tiles/) (e.g. set a valid User-Agent, attribution, and caching where applicable). The current implementation sets `TileLayer.userAgentPackageName` for identification.

### "Open in Maps" (directions)

Directions and navigation are handled by opening the **native map app** via deep links—no Maps SDK or directions API is used. This is free and avoids API costs.

- **Android:** Opens **Google Maps** at the event coordinates (`geo:` URI).
- **iOS:** Opens **Apple Maps** at the event coordinates (Apple Maps URL).
- **Fallback:** If the native app cannot be opened, the app opens the **Google Maps website** in the browser with the same destination.

The "Open in Maps" button on the Event Details screen uses `url_launcher` to launch these URLs. No API keys or billing are involved.

---

## Option 2: Google Maps (paid / API-key based)

**Status:** Not used in the current codebase. Suitable for production if you need Google Maps features.

- **Paid / API-key:** Requires a Google Cloud project and API keys for [Maps SDK for Android](https://developers.google.com/maps/documentation/android-sdk) and [Maps SDK for iOS](https://developers.google.com/maps/documentation/ios-sdk). Billing may apply depending on usage.
- **Package:** `google_maps_flutter`.
- **Platform setup:**
  - **Android:** Add `<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>` in `AndroidManifest.xml`.
  - **iOS:** Add `GMSApiKey` in `Info.plist` and ensure embedded views are allowed (e.g. `io.flutter.embedded_views_preview`).

Use this option when you need Google-specific features (e.g. Places, routing, or branding) and are ready to manage API keys and billing.

---

## Summary

| Option              | Cost / keys        | Used in assignment |
|---------------------|--------------------|--------------------|
| OpenStreetMap (flutter_map) | Free, no API keys | Yes                |
| Google Maps         | Paid, API keys     | No                 |

**OpenStreetMap via flutter_map is used for this assignment to avoid billing and API dependencies.**
