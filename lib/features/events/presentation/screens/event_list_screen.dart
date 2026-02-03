import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/providers.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../providers/providers.dart';
import '../widgets/event_list_item.dart';
import 'event_details_screen.dart';

/// Screen that displays a paginated list of events.
///
/// Features:
/// - Loading state indicator
/// - Error state with retry option
/// - Paginated list with automatic load more
/// - Pull-to-refresh
/// - No business logic (all handled by [EventsNotifier])
class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(eventsProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(eventsProvider.notifier).refresh();
  }

  void _openEventDetails(BuildContext context, String eventId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailsScreen(eventId: eventId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          if (authState case AuthAuthenticated(:final session))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  session.user.displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            tooltip: 'Log out',
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (state) {
          if (state.events.isEmpty) {
            return const Center(
              child: Text('No events available'),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.events.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.events.length) {
                  // Loading indicator for next page
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final event = state.events[index];
                return EventListItem(
                  event: event,
                  onTap: () => _openEventDetails(context, event.id),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          print("error :$error \n stacktrace : $stackTrace");
          return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(eventsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}
