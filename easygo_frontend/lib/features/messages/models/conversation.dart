// Models for customer-to-agency messaging.
//
// A conversation is addressed to one customer and one agency; the booking or
// parcel it concerns is carried as its human reference.

DateTime? _toNullableDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

List<dynamic> _toList(dynamic value) {
  if (value is List) {
    return value;
  }

  return const <dynamic>[];
}

/// One message inside a conversation.
class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole;
  final String body;
  final DateTime? createdAt;
  final DateTime? readAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.body,
    required this.createdAt,
    required this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? sender = _toMap(json['sender']);

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderRole: sender?['role']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: _toNullableDateTime(json['createdAt']),
      readAt: _toNullableDateTime(json['readAt']),
    );
  }

  /// A customer writes from the client side; anyone else is the agency.
  bool get isFromCustomer => senderRole == 'CUSTOMER';
}

/// A thread between one customer and one agency.
class Conversation {
  final String id;
  final String contextType;
  final String? contextReference;
  final String status;
  final String agencyId;
  final String agencyName;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final List<ChatMessage> messages;

  const Conversation({
    required this.id,
    required this.contextType,
    required this.contextReference,
    required this.status,
    required this.agencyId,
    required this.agencyName,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? agency = _toMap(json['agency']);
    final Map<String, dynamic>? customer = _toMap(json['customer']);

    final List<ChatMessage> messages = <ChatMessage>[];

    for (final dynamic item in _toList(json['messages'])) {
      if (item is Map) {
        messages.add(
          ChatMessage.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    final String name = [
      customer?['firstName'],
      customer?['lastName'],
    ].where((dynamic part) => part != null && '$part'.isNotEmpty).join(' ');

    return Conversation(
      id: json['id']?.toString() ?? '',
      contextType: json['contextType']?.toString() ?? 'GENERAL',
      contextReference: json['contextReference']?.toString(),
      status: json['status']?.toString() ?? 'OPEN',
      agencyId: agency?['id']?.toString() ?? '',
      agencyName: agency?['name']?.toString() ?? '',
      customerId: customer?['id']?.toString() ?? '',
      customerName: name,
      customerPhone: customer?['phone']?.toString(),
      lastMessageAt: _toNullableDateTime(json['lastMessageAt']),
      unreadCount: json['unreadCount'] is int
          ? json['unreadCount'] as int
          : int.tryParse('${json['unreadCount']}') ?? 0,
      messages: messages,
    );
  }

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  /// The heading the list shows for what the thread is about.
  String get contextLabel => switch (contextType) {
    'BOOKING' => 'Booking',
    'PARCEL' => 'Parcel',
    _ => 'General',
  };
}

/// Formats an instant as `HH:mm`, the style the message list uses.
String formatMessageTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

/// A short age for the conversation list: the time today, `Yesterday`, or the
/// date once it is older than that.
String conversationAgeLabel(DateTime? value, {DateTime? now}) {
  if (value == null) {
    return '';
  }

  final DateTime reference = now ?? DateTime.now();

  final DateTime today = DateTime(reference.year, reference.month, reference.day);
  final DateTime day = DateTime(value.year, value.month, value.day);

  final int differenceInDays = today.difference(day).inDays;

  if (differenceInDays <= 0) {
    return formatMessageTime(value);
  }

  if (differenceInDays == 1) {
    return 'Yesterday';
  }

  return '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}';
}

/// Projects a conversation onto the keys the conversation list and the chat
/// screen render.
Map<String, dynamic> conversationToCard(
  Conversation conversation, {
  DateTime? now,
}) {
  return <String, dynamic>{
    'id': conversation.id,
    'clientName': conversation.customerName.isEmpty
        ? '—'
        : conversation.customerName,
    'clientPhone': conversation.customerPhone ?? '—',
    'contextType': conversation.contextLabel,
    'contextReference': conversation.contextReference ?? '',
    // The thread stores the reference of the booking or parcel it is about; the
    // route itself is not part of the conversation record.
    'route': '',
    'lastMessage': conversation.lastMessage?.body ?? '',
    'lastMessageTime': conversationAgeLabel(
      conversation.lastMessageAt,
      now: now,
    ),
    'unreadCount': conversation.unreadCount,
    'messages': conversation.messages
        .map(
          (ChatMessage message) => <String, dynamic>{
            'id': message.id,
            'sender': message.isFromCustomer ? 'client' : 'agency',
            'message': message.body,
            'time': message.createdAt == null
                ? ''
                : formatMessageTime(message.createdAt!),
          },
        )
        .toList(),
  };
}
