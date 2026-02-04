/// Mock-only: when [MockSocketService] emits event:status_updated, it sets
/// [eventId] -> [status] here. [MockEventRemoteDataSource] uses this to return
/// updated status on refetch so the UI shows the "live" change.
final Map<String, String> mockEventStatusOverrides = {};
