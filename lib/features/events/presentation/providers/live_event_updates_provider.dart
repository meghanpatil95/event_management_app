import 'package:event_management_app/core/socket/socket_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'event_details_provider.dart';
import 'events_notifier.dart';

/// Listens to Socket.IO [event:status_updated] and invalidates
/// [eventDetailsProvider] and [eventsProvider] so UI refetches.
/// Watch this provider from a long-lived widget (e.g. event list or app shell)
/// so the subscription stays active.
final liveEventUpdatesProvider = Provider<void>((ref) {
  final service = ref.watch(socketServiceProvider);
  if (service == null) return;
  final sub = service.eventStatusUpdates.listen((map) {
    final eventId = map['eventId'] as String?;
    if (eventId != null && eventId.isNotEmpty) {
      ref.invalidate(eventDetailsProvider(eventId));
      ref.invalidate(eventsProvider);
    }
  });
  ref.onDispose(() => sub.cancel());
});
