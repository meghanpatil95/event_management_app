import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_provider.dart';
import '../../../chat/presentation/screens/event_chat_screen.dart';
import '../../domain/domain.dart';
import '../providers/providers.dart';
import '../state/event_registration_state.dart';

/// Screen that displays a single event's details.
///
/// Fetches event via [eventDetailsProvider] using [eventId].
/// Watches [eventRegistrationProvider] and loads initial registration status on init.
/// Shows loading, error, and data states.
class EventDetailsScreen extends ConsumerStatefulWidget {
  /// The event ID to load; typically passed from [EventListScreen] navigation.
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _didLoadInitial = false;

  @override
  Widget build(BuildContext context) {
    final eventId = widget.eventId;
    final eventAsync = ref.watch(eventDetailsProvider(eventId));
    final registrationState = ref.watch(eventRegistrationProvider(eventId));

    //  LISTEN TO REGISTRATION ERRORS ONLY
    ref.listen<EventRegistrationState>(eventRegistrationProvider(eventId), (
      previous,
      next,
    ) {

      if (next.errorMessage != null && previous?.errorMessage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    //  LISTEN TO EVENT CHANGES FOR NOTIFICATIONS
    ref.listen<AsyncValue<Event>>(eventDetailsProvider(eventId), (
      previous,
      next,
    ) {


      final oldRegistered = previous?.valueOrNull?.isRegistered ?? false;
      final newRegistered = next.valueOrNull?.isRegistered ?? false;

      final notificationService = ref.read(notificationServiceProvider);
      final event = next.valueOrNull;
      if (!oldRegistered && newRegistered) {
        print("event for notify : $event");
        if (event != null) {
          notificationService.scheduleEventReminders(event);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ' Successfully registered for the event\n ${event.title}',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (oldRegistered && !newRegistered) {
        notificationService.cancelEventReminders(eventId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ' You have unregistered from the event ${event?.title}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    if (!_didLoadInitial) {
      _didLoadInitial = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(eventRegistrationProvider(eventId).notifier)
            .loadInitialStatus(eventId);
      });
    }

    // Keep live event updates subscription active so status changes refetch this event.
    ref.watch(liveEventUpdatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EventChatScreen(
                    eventId: eventId,
                    eventTitle: eventAsync.valueOrNull?.title,
                  ),
                ),
              );
            },
            tooltip: 'Group Chat',
          ),
        ],
      ),
      body: eventAsync.when(
        data: (event) => _EventDetailsContent(
          event: event,
          registrationState: registrationState,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load event',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(eventDetailsProvider(eventId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




class _EventDetailsContent extends ConsumerWidget {
  final Event event;
  final EventRegistrationState registrationState;

  const _EventDetailsContent({
    required this.event,
    required this.registrationState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRegistered = event.isRegistered;
    final notifier = ref.read(eventRegistrationProvider(event.id).notifier);
    // final isExpired = event.isExpired;
    final isExpired = event.status.name == 'expired';
    final isCompleted = event.status.name == 'completed';

    final isCancelled = event.status.name == 'cancelled';
    print(
      "isCompleted :$isCompleted \n isExpired :$isExpired \n isCancelled : $isCancelled \n event.status.name :${event.status.name} \n event.isExpired : ${event.isExpired}",
    );
    final isLoading = registrationState.isLoading;

    String buttonLabel;
    bool enabled;
    Widget? buttonChild;
    if (isExpired) {
      buttonLabel = 'Event Expired';
      enabled = false;
    } else if (isCompleted) {
      buttonLabel = 'Event Completed';
      enabled = false;
    } else if (isLoading) {
      buttonLabel = ''; // unused, we show indicator
      enabled = false;
      buttonChild = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (isRegistered) {
      buttonLabel = 'Unregister';
      enabled = true;
    } else if (isCancelled) {
      buttonLabel = 'Event Cancelled';
      enabled = false;
    } else {
      buttonLabel = 'Register';
      enabled = true;
    }

    void onPressed() {
      print("isRegistered onPressed ::$isRegistered eventid : ${event.id}");
      if (isRegistered) {
        notifier.unregister(event.id);
      } else {
        notifier.register(event.id);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _StatusChip(status: event.status),
          if (isRegistered) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'You are registered',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Date & time',
            value: _formatDateTime(event.dateTime),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.location_on,
            label: 'Location',
            value: event.location,
          ),
          const SizedBox(height: 24),
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(event.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: enabled ? onPressed : null,
              child: buttonChild ?? Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$month $day, $year • $displayHour:$displayMinute $period';
  }
}

class _StatusChip extends StatelessWidget {
  final EventStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String text) = switch (status) {
      EventStatus.upcoming => (Colors.blue, 'Upcoming'),
      EventStatus.ongoing => (Colors.green, 'Ongoing'),
      EventStatus.completed => (Colors.grey, 'Completed'),
      EventStatus.cancelled => (Colors.red, 'Cancelled'),
      EventStatus.expired => (Colors.orange, 'Expired'),
    };
    return Chip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
