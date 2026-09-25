import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/conversation.dart';

/// Customer-to-agency messaging.
///
/// Every endpoint is scoped by the backend to the signed-in account: a customer
/// sees only their own threads and agency staff only their agency's, so the
/// screens do not filter by participant themselves.
class MessagingService {
  MessagingService._();

  static final MessagingService instance = MessagingService._();

  final ApiClient _apiClient = ApiClient.instance;

  /// The signed-in account's conversations, most recently active first.
  Future<List<Conversation>> getConversations() async {
    final dynamic response = await _apiClient.get(
      '/conversations',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! List) {
      throw const ApiException(
        message: 'The conversation list is missing.',
      );
    }

    final List<Conversation> conversations = <Conversation>[];

    for (final dynamic item in data) {
      if (item is Map) {
        conversations.add(
          Conversation.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    return conversations;
  }

  /// One conversation with all of its messages.
  Future<Conversation> getConversation(String conversationId) async {
    final dynamic response = await _apiClient.get(
      '/conversations/$conversationId',
      authenticated: true,
    );

    return Conversation.fromJson(_extractData(response));
  }

  /// Sends a reply and returns the conversation as it now stands.
  Future<Conversation> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final dynamic response = await _apiClient.post(
      '/conversations/$conversationId/messages',
      authenticated: true,
      body: {'body': body},
    );

    return Conversation.fromJson(_extractData(response));
  }

  /// Starts a thread with an agency and posts the first message, or continues
  /// the open thread about the same record.
  Future<Conversation> startConversation({
    required String agencyId,
    required String message,
    String? contextType,
    String? contextReference,
  }) async {
    final dynamic response = await _apiClient.post(
      '/conversations',
      authenticated: true,
      body: {
        'agencyId': agencyId,
        'message': message,
        'contextType': ?contextType,
        'contextReference': ?contextReference,
      },
    );

    return Conversation.fromJson(_extractData(response));
  }

  /// Marks the other party's messages as read, returning how many changed.
  Future<int> markAsRead(String conversationId) async {
    final dynamic response = await _apiClient.patch(
      '/conversations/$conversationId/read',
      authenticated: true,
    );

    if (response is! Map) {
      return 0;
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      return 0;
    }

    final dynamic updated = data['updatedCount'];

    return updated is num ? updated.toInt() : 0;
  }

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'The conversation is missing.');
    }

    return Map<String, dynamic>.from(data);
  }
}
