/*
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import 'event_repository_provider.dart';

/// Holds the paginated list state for events.
///
/// [events] - The list of events loaded so far.
/// [currentPage] - The last successfully loaded page (1-indexed).
/// [hasMore] - Whether more events are available to load.
class PaginatedEventsState {
  final List<Event> events;
  final int currentPage;
  final bool hasMore;
  final String searchQuery; // added for search

  const PaginatedEventsState({
    required this.events,
    required this.currentPage,
    required this.hasMore,
     this.searchQuery='',
  });

  PaginatedEventsState copyWith({
    List<Event>? events,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
  }) {
    return PaginatedEventsState(
      events: events ?? this.events,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  factory PaginatedEventsState.initial() => const PaginatedEventsState(
    events: [],
    currentPage: 0,
    hasMore: true,
    searchQuery: '',
  );




  List<Event> get visibleEvents {
    final filtered = searchQuery.isEmpty
        ? events
        : events.where((e) {
      final q = searchQuery.toLowerCase();
      return e.title.toLowerCase().contains(q) ||
          e.location.toLowerCase().contains(q);
    }).toList();

    filtered.sort(_eventSort);
    return filtered;
  }

  /// 🔹 Sorting logic
  static int _eventSort(Event a, Event b) {
    int pa = _priority(a.status);
    int pb = _priority(b.status);

    if (pa != pb) return pa.compareTo(pb);

    // Secondary sort by date
    return a.dateTime.compareTo(b.dateTime);
  }

  static int _priority(EventStatus status) {
    switch (status) {
      case EventStatus.ongoing:
        return 0;
      case EventStatus.upcoming:
        return 1;
      case EventStatus.expired:
        return 2;
      case EventStatus.completed:
        return 3;
      case EventStatus.cancelled:
        return 4;
    }
  }
}


/// Default number of events per page.
const _defaultPageSize = 20;

/// [AsyncNotifier] for the paginated event list.
///
/// Manages loading, success, and error states via [AsyncValue].
/// Provides [loadMore] for pagination.
class EventsNotifier extends AsyncNotifier<PaginatedEventsState> {
  int _pageSize = _defaultPageSize;

  @override
  Future<PaginatedEventsState> build() async {
    _pageSize = _defaultPageSize;
    return _fetchPage(1);
  }

  void setSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) return;

    // update search query and refresh page 1
    state = AsyncLoading<PaginatedEventsState>();
    _fetchPage(1).then((newState) {
      state = AsyncData(newState.copyWith(searchQuery: query));
    });
  }


  /// Loads the next page of events and appends to the list.
  ///
  /// No-op if already loading, in error state, or no more events available.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;

    final repository = ref.read(eventRepositoryProvider);
    final nextPage = current.currentPage + 1;

    try {
      final newEvents = await repository.getEventsPage(
        page: nextPage,
        pageSize: _pageSize,
      );

      final updatedState = current.copyWith(
        events: [...current.events, ...newEvents],
        currentPage: nextPage,
        hasMore: newEvents.length >= _pageSize,
      );

      state = AsyncData(updatedState);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  /// Refreshes the event list from the first page.
  Future<void> refresh() async {
    state = const AsyncLoading<PaginatedEventsState>();

    try {
      final updated = await _fetchPage(1);
      state = AsyncData(updated);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<PaginatedEventsState> _fetchPage(int page) async {
    final repository = ref.read(eventRepositoryProvider);
    // get current search query
    final currentQuery = state.valueOrNull?.searchQuery ?? '';
    print(" currentQuery :$currentQuery");
    final events = await repository.getEventsPage(
      page: page,
      pageSize: _pageSize,
      searchQuery: currentQuery,
    );


    return PaginatedEventsState(
      events: events,
      currentPage: page,
      hasMore: events.length >= _pageSize,
      searchQuery: currentQuery,
    );
  }
}

/// Provider for the paginated events list.
///
/// Exposes [AsyncValue<PaginatedEventsState>] with:
/// - [AsyncLoading] - Initial load or refresh in progress
/// - [AsyncData] - Successfully loaded events
/// - [AsyncError] - An error occurred
final eventsProvider =
    AsyncNotifierProvider<EventsNotifier, PaginatedEventsState>(EventsNotifier.new);




*/



import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import 'event_repository_provider.dart';

/// Holds the paginated list state for events.
///
/// [events] - The list of events loaded so far.
/// [currentPage] - The last successfully loaded page (1-indexed).
/// [hasMore] - Whether more events are available to load.
class PaginatedEventsState {
  final List<Event> events;
  final int currentPage;
  final bool hasMore;
  final String searchQuery; // added for search

  const PaginatedEventsState({
    required this.events,
    required this.currentPage,
    required this.hasMore,
    this.searchQuery = '',
  });

  PaginatedEventsState copyWith({
    List<Event>? events,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
  }) {
    return PaginatedEventsState(
      events: events ?? this.events,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  factory PaginatedEventsState.initial() => const PaginatedEventsState(
    events: [],
    currentPage: 0,
    hasMore: true,
    searchQuery: '',
  );

  /// Client-side filtering and sorting of events
  List<Event> get visibleEvents {
    final filtered = searchQuery.isEmpty
        ? events
        : events.where((e) {
      final q = searchQuery.toLowerCase();
      return e.title.toLowerCase().contains(q) ||
          e.location.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q);
    }).toList();

    filtered.sort(_eventSort);
    return filtered;
  }

  /// Sorting logic
  static int _eventSort(Event a, Event b) {
    int pa = _priority(a.status);
    int pb = _priority(b.status);

    if (pa != pb) return pa.compareTo(pb);

    // Secondary sort by date
    return a.dateTime.compareTo(b.dateTime);
  }

  static int _priority(EventStatus status) {
    switch (status) {
      case EventStatus.ongoing:
        return 0;
      case EventStatus.upcoming:
        return 1;
      case EventStatus.expired:
        return 2;
      case EventStatus.completed:
        return 3;
      case EventStatus.cancelled:
        return 4;
    }
  }
}

/// Default number of events per page.
const _defaultPageSize = 20;

/// [AsyncNotifier] for the paginated event list.
///
/// Manages loading, success, and error states via [AsyncValue].
/// Provides [loadMore] for pagination.
/// Uses client-side filtering for instant search results without network calls.
class EventsNotifier extends AsyncNotifier<PaginatedEventsState> {
  int _pageSize = _defaultPageSize;

  @override
  Future<PaginatedEventsState> build() async {
    _pageSize = _defaultPageSize;
    return _fetchPage(1);
  }

  /// Updates search query instantly without refetching from server.
  /// Uses client-side filtering for instant, smooth search experience.
  void setSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) return;

    // Don't update if query hasn't changed
    if (current.searchQuery == query) return;

    // Update search query immediately without loading state
    // The visibleEvents getter will handle filtering
    state = AsyncData(current.copyWith(searchQuery: query));
  }

  /// Loads the next page of events and appends to the list.
  ///
  /// No-op if already loading, in error state, or no more events available.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;

    final repository = ref.read(eventRepositoryProvider);
    final nextPage = current.currentPage + 1;

    try {
      final newEvents = await repository.getEventsPage(
        page: nextPage,
        pageSize: _pageSize,
      );

      final updatedState = current.copyWith(
        events: [...current.events, ...newEvents],
        currentPage: nextPage,
        hasMore: newEvents.length >= _pageSize,
      );

      state = AsyncData(updatedState);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  /// Refreshes the event list from the first page.
  /// Preserves current search query.
  Future<void> refresh() async {
    final currentQuery = state.valueOrNull?.searchQuery ?? '';
    state = const AsyncLoading<PaginatedEventsState>();

    try {
      final updated = await _fetchPage(1);
      // Restore search query after refresh
      state = AsyncData(updated.copyWith(searchQuery: currentQuery));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<PaginatedEventsState> _fetchPage(int page) async {
    final repository = ref.read(eventRepositoryProvider);
    print("📍 Fetching page $page");

    final events = await repository.getEventsPage(
      page: page,
      pageSize: _pageSize,
    );

    print("📍 Received ${events.length} events");

    return PaginatedEventsState(
      events: events,
      currentPage: page,
      hasMore: events.length >= _pageSize,
      searchQuery: '',
    );
  }
}

/// Provider for the paginated events list.
///
/// Exposes [AsyncValue<PaginatedEventsState>] with:
/// - [AsyncLoading] - Initial load or refresh in progress
/// - [AsyncData] - Successfully loaded events
/// - [AsyncError] - An error occurred
final eventsProvider =
AsyncNotifierProvider<EventsNotifier, PaginatedEventsState>(
    EventsNotifier.new);