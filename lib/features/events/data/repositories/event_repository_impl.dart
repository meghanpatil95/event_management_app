/*
import '../../../../core/network/api_exceptions.dart';
import '../../domain/domain.dart';
import '../datasources/event_local_data_source.dart';
import '../datasources/event_remote_data_source.dart';
import '../dto/event_dto.dart';

/// Implementation of [EventRepository] with an offline-first approach.
///
/// Fetches from remote first, caches results locally, and falls back to
/// the local cache when the remote call fails. DTOs are mapped to domain
/// entities inside this repository.
class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _remoteDataSource;
  final EventLocalDataSource _localDataSource;

  /// Creates an [EventRepositoryImpl] instance.
  ///
  /// [remoteDataSource] - The remote data source to fetch events from.
  /// [localDataSource] - The local data source for caching and offline fallback.
  EventRepositoryImpl(this._remoteDataSource, this._localDataSource);

  List<Event> _dtosToEvents(List<EventDto> dtos) =>
      dtos.map((dto) => dto.toDomain()).toList();

  @override
  Future<List<Event>> getEvents() async {
    try {
      final eventDtos = await _remoteDataSource.getEvents(
        page: 1,
        pageSize: 100,
      );
      await _localDataSource.cacheEvents(eventDtos);
      await _localDataSource.debugPrintCachedEvents();
      return _dtosToEvents(eventDtos);
    } on NetworkException {
      final cached = await _localDataSource.getCachedEvents();
      return _dtosToEvents(cached);
    }
  }

  @override
  Future<List<Event>> getEventsPage({int page = 1, int pageSize = 20,String searchQuery=''}) async {
    try {
      final eventDtos = await _remoteDataSource.getEvents(
        page: page,
        pageSize: pageSize,
      );
      // filter by search query
      final filtered = eventDtos
          .where((e) => e.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
      final cached = await _localDataSource.getCachedEvents();
      final updated = _mergeAndSort(cached, filtered);
      await _localDataSource.cacheEvents(updated);
      await _localDataSource.debugPrintCachedEvents();
      // return _dtosToEvents(eventDtos);
      return _dtosToEvents(filtered);
    } on NetworkException {
      final cached = await _localDataSource.getCachedEvents();
      final start = (page - 1) * pageSize;
      final end = (start + pageSize).clamp(0, cached.length);
      if (start >= cached.length) return [];
      return _dtosToEvents(cached.sublist(start, end));
    }
  }

  /// Merges [remote] into [existing] by id and returns a list sorted by dateTime.
  List<EventDto> _mergeAndSort(List<EventDto> existing, List<EventDto> remote) {
    final byId = {for (final e in existing) e.id: e};
    for (final e in remote) byId[e.id] = e;
    final merged = byId.values.toList();
    merged.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return merged;
  }

  @override
  Future<Event> getEventById(String eventId) async {
    try {
      final eventDto = await _remoteDataSource.getEventById(eventId);
      await _localDataSource.cacheEvent(eventDto);
      await _localDataSource.debugPrintCachedEvents();
      return eventDto.toDomain();
    } on EventNotFoundException catch (e) {
      throw Exception('Event not found: ${e.eventId}');
    } on NetworkException {
      final cached = await _localDataSource.getCachedEventById(eventId);
      if (cached == null) {
        throw Exception('Event not found: $eventId');
      }
      return cached.toDomain();
    }
  }

  */
/*@override
  Future<Event> registerForEvent(String eventId) async {
    print("registerForEvent :: $registerForEvent event id : $eventId ");
    final eventDto = await _remoteDataSource.registerForEvent(eventId);
    print("eventDto :: ${eventDto.toJson()} ");

    final cached = await _localDataSource.getCachedEvents();
    print("cached :: ${cached.first.toJson()} ");
    final updated = _mergeAndSort(cached, [eventDto]);
    print("updated :: ${updated.where((e)=>e.id == 'event_4').first.toJson()} ");
    await _localDataSource.cacheEvents(updated);
    await _localDataSource.debugPrintCachedEvents();
    return eventDto.toDomain();
  }*//*


  @override
  Future<Event> registerForEvent(String eventId) async {
    print("registerForEvent START :: eventId = $eventId");

    final localEvent = await _localDataSource.getCachedEventById(eventId);
    print("localEvent :: ${localEvent?.isRegistered}");
    if (localEvent != null && localEvent.isRegistered) {
      throw AlreadyRegisteredException(eventId);
    }

    try {
      final eventDto = await _remoteDataSource.registerForEvent(eventId);
      print("eventDto :: ${eventDto.toJson()}");

      final cached = await _localDataSource.getCachedEvents();
      print("cached count :: ${cached.length}");

      final updated = _mergeAndSort(cached, [eventDto]);
      print("updated event :: ${updated.firstWhere((e) => e.id == eventId).toJson()}");

      await _localDataSource.cacheEvents(updated);

      await _localDataSource.debugPrintCachedEventById(eventId);

      return eventDto.toDomain();
    } catch (e, st) {
      print("❌ registerForEvent FAILED :: $e");
      print(st);
      rethrow;
    }
  }


  @override
  Future<Event> unregisterFromEvent(String eventId) async {
    final eventDto = await _remoteDataSource.unregisterFromEvent(eventId);
    final cached = await _localDataSource.getCachedEvents();
    final updated = _mergeAndSort(cached, [eventDto]);
    await _localDataSource.cacheEvents(updated);
    await _localDataSource.debugPrintCachedEventById(eventId);

    return eventDto.toDomain();
  }
}
*/




import '../../../../core/network/api_exceptions.dart';
import '../../domain/domain.dart';
import '../datasources/event_local_data_source.dart';
import '../datasources/event_remote_data_source.dart';
import '../dto/event_dto.dart';

/// Implementation of [EventRepository] with an offline-first approach.
///
/// Fetches from remote first, caches results locally, and falls back to
/// the local cache when the remote call fails. DTOs are mapped to domain
/// entities inside this repository.
class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _remoteDataSource;
  final EventLocalDataSource _localDataSource;

  /// Creates an [EventRepositoryImpl] instance.
  ///
  /// [remoteDataSource] - The remote data source to fetch events from.
  /// [localDataSource] - The local data source for caching and offline fallback.
  EventRepositoryImpl(this._remoteDataSource, this._localDataSource);

  List<Event> _dtosToEvents(List<EventDto> dtos) =>
      dtos.map((dto) => dto.toDomain()).toList();

  @override
  Future<List<Event>> getEvents() async {
    try {
      final eventDtos = await _remoteDataSource.getEvents(
        page: 1,
        pageSize: 100,
      );
      await _localDataSource.cacheEvents(eventDtos);
      await _localDataSource.debugPrintCachedEvents();
      return _dtosToEvents(eventDtos);
    } on NetworkException {
      final cached = await _localDataSource.getCachedEvents();
      return _dtosToEvents(cached);
    }
  }

  @override
  Future<List<Event>> getEventsPage({
    int page = 1,
    int pageSize = 20,
    String searchQuery = '',
  }) async {
    print("🔍 Repository getEventsPage - page: $page, pageSize: $pageSize, searchQuery: '$searchQuery'");

    try {
      // Fetch from remote WITHOUT filtering - let the UI handle it
      final eventDtos = await _remoteDataSource.getEvents(
        page: page,
        pageSize: pageSize,
      );

      print("🔍 Received ${eventDtos.length} events from remote");

      // Update cache with new data
      final cached = await _localDataSource.getCachedEvents();
      final updated = _mergeAndSort(cached, eventDtos);
      await _localDataSource.cacheEvents(updated);
      await _localDataSource.debugPrintCachedEvents();

      // Return raw events - filtering happens in the UI layer
      return _dtosToEvents(eventDtos);
    } on NetworkException {
      print("🔍 Network error - using cache");

      // Fallback to cache
      final cached = await _localDataSource.getCachedEvents();
      final start = (page - 1) * pageSize;
      final end = (start + pageSize).clamp(0, cached.length);

      if (start >= cached.length) return [];

      return _dtosToEvents(cached.sublist(start, end));
    }
  }

  /// Merges [remote] into [existing] by id and returns a list sorted by dateTime.
  List<EventDto> _mergeAndSort(List<EventDto> existing, List<EventDto> remote) {
    final byId = {for (final e in existing) e.id: e};
    for (final e in remote) {
      byId[e.id] = e;
    }
    final merged = byId.values.toList();
    merged.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return merged;
  }

  @override
  Future<Event> getEventById(String eventId) async {
    try {
      final eventDto = await _remoteDataSource.getEventById(eventId);
      await _localDataSource.cacheEvent(eventDto);
      await _localDataSource.debugPrintCachedEvents();
      return eventDto.toDomain();
    } on EventNotFoundException catch (e) {
      throw Exception('Event not found: ${e.eventId}');
    } on NetworkException {
      final cached = await _localDataSource.getCachedEventById(eventId);
      if (cached == null) {
        throw Exception('Event not found: $eventId');
      }
      return cached.toDomain();
    }
  }

  @override
  Future<Event> registerForEvent(String eventId) async {
    print("registerForEvent START :: eventId = $eventId");

    final localEvent = await _localDataSource.getCachedEventById(eventId);
    print("localEvent :: ${localEvent?.isRegistered}");

    if (localEvent != null && localEvent.isRegistered) {
      throw AlreadyRegisteredException(eventId);
    }

    try {
      final eventDto = await _remoteDataSource.registerForEvent(eventId);
      print("eventDto :: ${eventDto.toJson()}");

      final cached = await _localDataSource.getCachedEvents();
      print("cached count :: ${cached.length}");

      final updated = _mergeAndSort(cached, [eventDto]);
      print("updated event :: ${updated.firstWhere((e) => e.id == eventId).toJson()}");

      await _localDataSource.cacheEvents(updated);
      await _localDataSource.debugPrintCachedEventById(eventId);

      return eventDto.toDomain();
    } catch (e, st) {
      print("❌ registerForEvent FAILED :: $e");
      print(st);
      rethrow;
    }
  }

  @override
  Future<Event> unregisterFromEvent(String eventId) async {
    final eventDto = await _remoteDataSource.unregisterFromEvent(eventId);
    final cached = await _localDataSource.getCachedEvents();
    final updated = _mergeAndSort(cached, [eventDto]);
    await _localDataSource.cacheEvents(updated);
    await _localDataSource.debugPrintCachedEventById(eventId);

    return eventDto.toDomain();
  }
}