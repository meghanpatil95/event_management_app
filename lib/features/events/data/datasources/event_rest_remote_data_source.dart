import 'package:event_management_app/core/network/network.dart';

import '../dto/event_dto.dart';
import 'event_remote_data_source.dart';

/// REST implementation of [EventRemoteDataSource].
///
/// Uses the centralized [ApiClient]. All responses are mapped from JSON
/// to [EventDto]; DTO to domain mapping is done in the repository.
class EventRestRemoteDataSource implements EventRemoteDataSource {
  final ApiClient _client;

  EventRestRemoteDataSource(this._client);

  @override
  Future<List<EventDto>> getEvents({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _client.get(
        'events',
        queryParameters: {'page': '$page', 'pageSize': '$pageSize'},
      );
      final list = _extractEventList(response);
      return list.map((e) => EventDto.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _mapApiToEventException(e);
    }
  }

  @override
  Future<EventDto> getEventById(String eventId) async {
    try {
      final response = await _client.get('events/$eventId');
      if (response is! Map<String, dynamic>) {
        throw EventNotFoundException(eventId);
      }
      return EventDto.fromJson(response);
    } on NotFoundException {
      throw EventNotFoundException(eventId);
    } on ApiException catch (e) {
      _mapApiToEventException(e);
    }
  }

  @override
  Future<EventDto> registerForEvent(String eventId) async {
    try {
      final response = await _client.post('events/$eventId/register');
      if (response is! Map<String, dynamic>) {
        throw EventNotFoundException(eventId);
      }
      final dto = EventDto.fromJson(response);
      if (!dto.isRegistered) {
        throw AlreadyRegisteredException(eventId);
      }
      return dto;
    } on NotFoundException {
      throw EventNotFoundException(eventId);
    } on BadRequestException catch (e) {
      final msg = (e.body is Map ? (e.body as Map)['code'] : null)?.toString() ?? e.message;
      if (msg.toLowerCase().contains('already') || msg.toLowerCase().contains('registered')) {
        throw AlreadyRegisteredException(eventId);
      }
      if (msg.toLowerCase().contains('expired')) {
        throw EventExpiredException(eventId);
      }
      throw NetworkException(e.message);
    } on ApiException catch (e) {
      _mapApiToEventException(e, eventId: eventId);
    }
  }

  @override
  Future<EventDto> unregisterFromEvent(String eventId) async {
    try {
      // API may use DELETE /events/:id/register or POST /events/:id/unregister
      final response = await _client.delete('events/$eventId/register');
      if (response == null || response is! Map<String, dynamic>) {
        // If DELETE returns 204 No Content, refetch the event
        return getEventById(eventId);
      }
      return EventDto.fromJson(response);
    } on NotFoundException {
      throw EventNotFoundException(eventId);
    } on BadRequestException catch (e) {
      final msg = (e.body is Map ? (e.body as Map)['code'] : null)?.toString() ?? e.message;
      if (msg.toLowerCase().contains('not registered')) {
        throw NotRegisteredException(eventId);
      }
      if (msg.toLowerCase().contains('expired')) {
        throw EventExpiredException(eventId);
      }
      throw NetworkException(e.message);
    } on ApiException catch (e) {
      _mapApiToEventException(e, eventId: eventId);
    }
  }

  List<dynamic> _extractEventList(dynamic response) {
    if (response is List) return response;
    if (response is Map && response['data'] is List) {
      return response['data'] as List;
    }
    if (response is Map && response['events'] is List) {
      return response['events'] as List;
    }
    return [];
  }

  Never _mapApiToEventException(ApiException e, {String? eventId}) {
    if (e is NotFoundException && eventId != null) {
      throw EventNotFoundException(eventId);
    }
    throw NetworkException(e.message);
  }
}
