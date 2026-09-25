import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/features/messages/models/conversation.dart';

/// The conversation list and the two chat screens both render the projection
/// produced by `conversationToCard`. These tests pin the shape of both the
/// parsed record and that projection, because the screens cast several of the
/// keys straight to `String` and a missing key would crash at render time.

Map<String, dynamic> _payload({
  String contextType = 'BOOKING',
  String? contextReference = 'EGO-BK-001',
  String status = 'OPEN',
  int unreadCount = 0,
  List<Map<String, dynamic>> messages = const <Map<String, dynamic>>[],
}) {
  return <String, dynamic>{
    'id': 'conv-1',
    'contextType': contextType,
    'contextReference': contextReference,
    'status': status,
    'unreadCount': unreadCount,
    'lastMessageAt': '2026-09-25T10:42:00.000Z',
    'agency': <String, dynamic>{'id': 'agency-1', 'name': 'Finexs Voyages'},
    'customer': <String, dynamic>{
      'id': 'customer-1',
      'firstName': 'John',
      'lastName': 'Doe',
      'phone': '+237 6 70 00 00 01',
    },
    'messages': messages,
  };
}

void main() {
  group('Conversation.fromJson', () {
    test('reads the agency id so the client can find its own thread', () {
      final Conversation conversation = Conversation.fromJson(_payload());

      expect(conversation.agencyId, 'agency-1');
      expect(conversation.agencyName, 'Finexs Voyages');
    });

    test('builds the customer name from the nested customer record', () {
      final Conversation conversation = Conversation.fromJson(_payload());

      expect(conversation.customerId, 'customer-1');
      expect(conversation.customerName, 'John Doe');
      expect(conversation.customerPhone, '+237 6 70 00 00 01');
    });

    test('tolerates a conversation with no context reference', () {
      final Conversation conversation = Conversation.fromJson(
        _payload(contextType: 'GENERAL', contextReference: null),
      );

      expect(conversation.contextReference, isNull);
      expect(conversation.contextLabel, 'General');
    });

    test('counts unread messages from the stored counter', () {
      final Conversation conversation = Conversation.fromJson(
        _payload(unreadCount: 3),
      );

      expect(conversation.unreadCount, 3);
    });

    test('has no last message when the thread is empty', () {
      final Conversation conversation = Conversation.fromJson(_payload());

      expect(conversation.lastMessage, isNull);
    });

    test('exposes the newest stored message as the last message', () {
      final Conversation conversation = Conversation.fromJson(
        _payload(
          messages: <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'm1',
              'body': 'Good morning.',
              'senderId': 'customer-1',
              'sender': <String, dynamic>{'id': 'customer-1', 'role': 'CUSTOMER'},
              'createdAt': '2026-09-25T10:35:00.000Z',
            },
            <String, dynamic>{
              'id': 'm2',
              'body': 'How can we help?',
              'senderId': 'staff-1',
              'sender': <String, dynamic>{
                'id': 'staff-1',
                'role': 'AGENCY_STAFF',
              },
              'createdAt': '2026-09-25T10:42:00.000Z',
            },
          ],
        ),
      );

      expect(conversation.lastMessage?.body, 'How can we help?');
    });
  });

  group('ChatMessage', () {
    test('treats a CUSTOMER role as the client side of the thread', () {
      final ChatMessage message = ChatMessage.fromJson(<String, dynamic>{
        'id': 'm1',
        'body': 'Hello.',
        'senderId': 'customer-1',
        'sender': <String, dynamic>{'id': 'customer-1', 'role': 'CUSTOMER'},
      });

      expect(message.isFromCustomer, isTrue);
    });

    test('treats agency staff as the agency side of the thread', () {
      final ChatMessage message = ChatMessage.fromJson(<String, dynamic>{
        'id': 'm2',
        'body': 'Hello.',
        'senderId': 'staff-1',
        'sender': <String, dynamic>{'id': 'staff-1', 'role': 'AGENCY_STAFF'},
      });

      expect(message.isFromCustomer, isFalse);
    });

    test('does not treat an unknown sender as the customer', () {
      final ChatMessage message = ChatMessage.fromJson(<String, dynamic>{
        'id': 'm3',
        'body': 'Hello.',
      });

      expect(message.senderRole, '');
      expect(message.isFromCustomer, isFalse);
    });
  });

  group('conversationToCard', () {
    test('supplies every key the conversation list casts to a string', () {
      final Map<String, dynamic> card = conversationToCard(
        Conversation.fromJson(
          _payload(
            messages: <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'm1',
                'body': 'Please, has my luggage arrived?',
                'senderId': 'customer-1',
                'sender': <String, dynamic>{
                  'id': 'customer-1',
                  'role': 'CUSTOMER',
                },
                'createdAt': '2026-09-25T10:42:00.000Z',
              },
            ],
          ),
        ),
      );

      expect(card['id'], 'conv-1');
      expect(card['clientName'], 'John Doe');
      expect(card['clientPhone'], '+237 6 70 00 00 01');
      expect(card['contextType'], 'Booking');
      expect(card['contextReference'], 'EGO-BK-001');
      expect(card['route'], '');
      expect(card['lastMessage'], 'Please, has my luggage arrived?');
      expect(card['lastMessageTime'], isA<String>());
      expect(card['unreadCount'], 0);
    });

    test('gives an empty reference rather than null when there is none', () {
      final Map<String, dynamic> card = conversationToCard(
        Conversation.fromJson(
          _payload(contextType: 'GENERAL', contextReference: null),
        ),
      );

      expect(card['contextReference'], '');
      expect(card['contextType'], 'General');
    });

    test('falls back to a placeholder when the customer is missing', () {
      final Conversation conversation = Conversation.fromJson(<String, dynamic>{
        'id': 'conv-2',
        'contextType': 'GENERAL',
        'status': 'OPEN',
      });

      final Map<String, dynamic> card = conversationToCard(conversation);

      expect(card['clientName'], '—');
      expect(card['clientPhone'], '—');
      expect(card['lastMessage'], '');
    });

    test('labels each message with the side that wrote it', () {
      final Map<String, dynamic> card = conversationToCard(
        Conversation.fromJson(
          _payload(
            messages: <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'm1',
                'body': 'Hello.',
                'senderId': 'customer-1',
                'sender': <String, dynamic>{
                  'id': 'customer-1',
                  'role': 'CUSTOMER',
                },
                'createdAt': '2026-09-25T10:35:00.000Z',
              },
              <String, dynamic>{
                'id': 'm2',
                'body': 'Good morning.',
                'senderId': 'staff-1',
                'sender': <String, dynamic>{
                  'id': 'staff-1',
                  'role': 'AGENCY_STAFF',
                },
                'createdAt': '2026-09-25T10:37:00.000Z',
              },
            ],
          ),
        ),
      );

      final List<dynamic> messages = card['messages'] as List<dynamic>;
      final Map<String, dynamic> first = messages[0] as Map<String, dynamic>;
      final Map<String, dynamic> second = messages[1] as Map<String, dynamic>;

      expect(messages.length, 2);
      expect(first['sender'], 'client');
      expect(first['message'], 'Hello.');
      expect(first['time'], isA<String>());
      expect(second['sender'], 'agency');
      expect(second['message'], 'Good morning.');
    });
  });

  group('conversationAgeLabel', () {
    final DateTime now = DateTime(2026, 9, 25, 14, 30);

    test('describes a missing timestamp as empty', () {
      expect(conversationAgeLabel(null, now: now), '');
    });

    test('shows the time for a conversation active today', () {
      final String label = conversationAgeLabel(
        DateTime(2026, 9, 25, 10, 42),
        now: now,
      );

      expect(label, isNot('Yesterday'));
      expect(label.contains('42'), isTrue);
    });

    test('describes the previous day as yesterday', () {
      final String label = conversationAgeLabel(
        DateTime(2026, 9, 24, 16, 20),
        now: now,
      );

      expect(label, 'Yesterday');
    });

    test('shows a date once the thread is older than yesterday', () {
      final String label = conversationAgeLabel(
        DateTime(2026, 9, 21, 9, 0),
        now: now,
      );

      expect(label, '21/09');
    });
  });
}
