# Maps Integration Documentation

## Overview

The Maps feature displays **event location** on a map using **OpenStreetMap** via the [flutter_map](https://pub.dev/packages/flutter_map) package. It is used on the Event Details screen to show where an event takes place, with **marker support** for the venue. No Google Maps SDK or API keys are used at runtime.

For a comparison of map options (OpenStreetMap vs Google Maps), see [docs/map.md](../../../docs/map.md).

---

## Project Structure

```
lib/features/maps/
├── MAPS.md                          # This file
└── presentation/
    └── widgets/
        └── event_location_map.dart   # Map widget with marker
```

The maps feature is **presentation-only**: it does not define its own domain or data layers. It receives coordinates (and optional title) from the Events feature and renders an OpenStreetMap-based map with a marker.

---

## Architecture

### Design Decisions

- **No separate domain/data**: Map display is a UI concern. Event coordinates come from the existing `Event` entity (`latitude`, `longitude`). No new repositories or use cases.
- **Reusable widget**: `EventLocationMap` is a stateless widget that accepts `latitude`, `longitude`, and optional `title`. It can be used from Event Details or any screen that needs to show a location.
- **Free, no API keys**: OpenStreetMap tiles via flutter_map avoid Google Maps SDK and API keys; the app runs without map-related configuration.
- **Graceful fallback**: If coordinates are `null`, the widget is not shown (parent checks); the widget itself is only used when coordinates are present.

### Integration with Events

- **Event entity** (domain): Optional `double? latitude` and `double? longitude` for map display.
- **EventDto** (data): Optional `latitude` / `longitude` from API or mock. When the backend provides coordinates, they are mapped to the entity and passed to the map.
- **Event Details screen**: Renders `EventLocationMap` below the location row when the event has valid coordinates.

---

## Implementation Details

### EventLocationMap Widget

**Location:** `lib/features/maps/presentation/widgets/event_location_map.dart`

**Parameters:**

| Parameter    | Type     | Required | Description                          |
|-------------|----------|----------|--------------------------------------|
| `latitude`  | `double` | Yes      | Latitude for map center and marker   |
| `longitude` | `double` | Yes      | Longitude for map center and marker  |
| `title`     | `String?`| No       | Optional marker tooltip (e.g. event title) |
| `height`    | `double` | No       | Map height (default: 200)            |

**Behavior:**

1. Centers the map on the given coordinates (zoom ~13.5).
2. Places a single **marker** at that position (red location icon).
3. Optional `title` is shown as a tooltip when the user long-presses or hovers the marker.
4. Uses OpenStreetMap tiles; no API keys or platform-specific map configuration required.

**Usage (from Event Details):**

```dart
if (event.latitude != null && event.longitude != null)
  EventLocationMap(
    latitude: event.latitude!,
    longitude: event.longitude!,
    title: event.title,
    height: 200,
  )
```

### Marker Support

- One **Marker** is placed at `LatLng(latitude, longitude)` using a Material `Icons.location_on` icon.
- Optional **tooltip** text is set from `title` so users can see the event name when interacting with the marker.

---

## Platform Configuration

- **Android:** `INTERNET` permission is already declared in the manifest; required for loading map tiles. No Google Maps API key or other map-specific setup.
- **iOS:** No map-related keys in `Info.plist`; no Google Maps SDK.

---

## Data Flow

1. **Event Details** loads an `Event` (e.g. via `eventDetailsProvider`).
2. If `event.latitude != null && event.longitude != null`, the screen shows `EventLocationMap(...)`.
3. **EventLocationMap** builds a `FlutterMap` with:
   - `MapOptions.initialCenter` and `initialZoom: 13.5`.
   - A **TileLayer** for OpenStreetMap tiles.
   - A **MarkerLayer** with one **Marker** at the event position.
4. Tiles are loaded from the OpenStreetMap tile server; behavior is handled entirely in Flutter (no native map SDK).

---

## Assignment Requirements Met

- **Display event location**: Event location is shown on the Event Details screen via an OpenStreetMap-based map centered on event coordinates.
- **Marker support**: A single marker is placed at the event location; optional tooltip shows the event title.
- **No Google Maps in runtime**: No Google Maps SDK or API keys are used; OpenStreetMap via flutter_map is used for the assignment to avoid billing/API dependencies.

---

## Testing

1. **With coordinates**: Open an event that has `latitude` and `longitude` (mock data assigns coordinates to known venue names). You should see a map and a red marker.
2. **Without coordinates**: If the API returns events without lat/lng, the map section is not shown; only the text location row is displayed.
3. **Platform**: Run on Android and iOS; no API keys are required. Map and marker should render using OSM tiles.

---

## Summary

The Maps feature is a small, self-contained presentation module that uses **flutter_map** and **OpenStreetMap** to display event location with a marker. It keeps the existing Clean Architecture intact, requires no API keys or billing, and meets the assignment requirements for “Display event location” and “Marker support.” See **docs/map.md** for the comparison with the Google Maps option.
