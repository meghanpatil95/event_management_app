import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../dto/event_dto.dart';

/// Hive box name for caching events locally.
const String eventCacheBoxName = 'event_cache';

/// Key used to store the list of cached events in the Hive box.
const String _eventsListKey = 'events';

/// Local data source for caching events using Hive.
///
/// Stores events as JSON in a Hive box for offline access and faster reads.
abstract class EventLocalDataSource {
  /// Returns the cached list of events, if any.
  ///
  /// Returns an empty list if no cache exists or the cache is empty.
  Future<List<EventDto>> getCachedEvents();

  /// Caches the given list of events, replacing any existing cache.
  Future<void> cacheEvents(List<EventDto> events);

  /// Returns a single cached event by [eventId], or null if not found.
  Future<EventDto?> getCachedEventById(String eventId);

  /// Caches or updates a single event.
  ///
  /// If an event with the same id already exists in the cache, it is updated.
  /// Otherwise the event is appended to the cache.
  Future<void> cacheEvent(EventDto event);

  /// Clears all cached events.
  Future<void> clearCache();
  Future<void> debugPrintCachedEvents();
}

/// Hive-backed implementation of [EventLocalDataSource].
class EventLocalDataSourceImpl implements EventLocalDataSource {
  Box<String> get _box => Hive.box<String>(eventCacheBoxName);

  @override
  Future<List<EventDto>> getCachedEvents() async {
    final jsonStr = _box.get(_eventsListKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => EventDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> cacheEvents(List<EventDto> events) async {
    final list = events.map((e) => e.toJson()).toList();
    await _box.put(_eventsListKey, jsonEncode(list));
  }

  @override
  Future<EventDto?> getCachedEventById(String eventId) async {
    final events = await getCachedEvents();
    try {
      return events.firstWhere((e) => e.id == eventId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheEvent(EventDto event) async {
    final events = await getCachedEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    final updated = List<EventDto>.from(events);
    if (index >= 0) {
      updated[index] = event;
    } else {
      updated.add(event);
    }
    await cacheEvents(updated);
  }

  @override
  Future<void> clearCache() async {
    await _box.delete(_eventsListKey);
  }

  Future<void> debugPrintCachedEvents() async {
    print('Hive events box content: ${_box.toMap()}');
  }

}
