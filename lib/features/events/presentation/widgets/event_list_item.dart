import 'package:flutter/material.dart';

import '../../domain/domain.dart';

/// Widget that displays a single event in the list.
///
/// This is a pure presentation widget with no business logic.
/// Use [onTap] to navigate to event details (e.g. pass [event.id]).
class EventListItem extends StatelessWidget {
  final Event event;

  /// Called when the user taps the item; e.g. navigate to details with [event.id].
  final VoidCallback? onTap;

  const EventListItem({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          event.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(event.dateTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStatusChip(context),
          ],
        ),
        trailing: event.isRegistered
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (event.status) {
      case EventStatus.upcoming:
        statusColor = Colors.blue;
        statusText = 'Upcoming';
        break;
      case EventStatus.ongoing:
        statusColor = Colors.green;
        statusText = 'Ongoing';
        break;
      case EventStatus.completed:
        statusColor = Colors.grey;
        statusText = 'Completed';
        break;
      case EventStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: statusColor,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
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
      'Dec'
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
