import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import 'event_repository_provider.dart';

/// Holds the paginated list state for events.
///
/// [events] - The list of events loaded so far.
/// [currentPage] - The last successfully loaded page (1-indexed).
/// [hasMore] - Whether more events are available to load.
class PaginatedEventsState {
  /// List of events loaded across all pages.
  final List<Event> events;

  /// The last successfully loaded page (1-indexed).
  final int currentPage;

  /// Whether more events are available to load.
  final bool hasMore;

  const PaginatedEventsState({
    required this.events,
    required this.currentPage,
    required this.hasMore,
  });

  /// Creates the initial empty state.
  factory PaginatedEventsState.initial() => const PaginatedEventsState(
        events: [],
        currentPage: 0,
        hasMore: true,
      );

  /// Creates a copy with updated fields.
  PaginatedEventsState copyWith({
    List<Event>? events,
    int? currentPage,
    bool? hasMore,
  }) {
    return PaginatedEventsState(
      events: events ?? this.events,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
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
    final events = await repository.getEventsPage(
      page: page,
      pageSize: _pageSize,
    );

    return PaginatedEventsState(
      events: events,
      currentPage: page,
      hasMore: events.length >= _pageSize,
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
