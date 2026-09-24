import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'agency_chat_screen.dart';

class AgencyConversationsScreen extends StatefulWidget {
  const AgencyConversationsScreen({
    super.key,
  });

  @override
  State<AgencyConversationsScreen> createState() =>
      _AgencyConversationsScreenState();
}

class _AgencyConversationsScreenState
    extends State<AgencyConversationsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': 'CONV-DEMO-001',
      'clientName': 'John Doe',
      'clientPhone': '+237 6 70 00 00 01',
      'contextType': 'Booking',
      'contextReference': 'DEMO-BOOKING-001',
      'route': 'Yaoundé → Douala',
      'lastMessage':
          'Please, has my luggage already arrived in Douala?',
      'lastMessageTime': '10:42',
      'unreadCount': 2,
      'messages': [
        {
          'id': 'MSG-001',
          'sender': 'client',
          'message':
              'Good morning. I would like some information about my luggage.',
          'time': '10:35',
        },
        {
          'id': 'MSG-002',
          'sender': 'agency',
          'message':
              'Good morning. Please provide your booking reference.',
          'time': '10:37',
        },
        {
          'id': 'MSG-003',
          'sender': 'client',
          'message':
              'My booking reference is DEMO-BOOKING-001.',
          'time': '10:39',
        },
        {
          'id': 'MSG-004',
          'sender': 'client',
          'message':
              'Please, has my luggage already arrived in Douala?',
          'time': '10:42',
        },
      ],
    },
    {
      'id': 'CONV-DEMO-002',
      'clientName': 'Marie N.',
      'clientPhone': '+237 6 70 00 00 02',
      'contextType': 'Booking',
      'contextReference': 'DEMO-BOOKING-002',
      'route': 'Yaoundé → Bafoussam',
      'lastMessage':
          'Thank you. I will arrive at the agency before departure.',
      'lastMessageTime': '09:18',
      'unreadCount': 0,
      'messages': [
        {
          'id': 'MSG-005',
          'sender': 'client',
          'message':
              'Hello. What time should I arrive before my trip?',
          'time': '09:10',
        },
        {
          'id': 'MSG-006',
          'sender': 'agency',
          'message':
              'Hello. Please arrive sufficiently before the scheduled departure so the agency can complete the required boarding procedures.',
          'time': '09:15',
        },
        {
          'id': 'MSG-007',
          'sender': 'client',
          'message':
              'Thank you. I will arrive at the agency before departure.',
          'time': '09:18',
        },
      ],
    },
    {
      'id': 'CONV-DEMO-003',
      'clientName': 'Clarisse F.',
      'clientPhone': '+237 6 70 00 00 05',
      'contextType': 'Parcel',
      'contextReference': 'PAR-DEMO-003',
      'route': 'Yaoundé → Buea',
      'lastMessage':
          'Can the recipient collect the parcel immediately after arrival?',
      'lastMessageTime': 'Yesterday',
      'unreadCount': 1,
      'messages': [
        {
          'id': 'MSG-008',
          'sender': 'client',
          'message':
              'Hello. I sent parcel PAR-DEMO-003 to Buea.',
          'time': '16:20',
        },
        {
          'id': 'MSG-009',
          'sender': 'agency',
          'message':
              'Hello. We can assist you with information concerning the parcel.',
          'time': '16:24',
        },
        {
          'id': 'MSG-010',
          'sender': 'client',
          'message':
              'Can the recipient collect the parcel immediately after arrival?',
          'time': '16:28',
        },
      ],
    },
    {
      'id': 'CONV-DEMO-004',
      'clientName': 'Samuel T.',
      'clientPhone': '+237 6 70 00 00 03',
      'contextType': 'General',
      'contextReference': '',
      'route': '',
      'lastMessage':
          'Do you have VIP trips from Douala to Yaoundé?',
      'lastMessageTime': 'Mon',
      'unreadCount': 0,
      'messages': [
        {
          'id': 'MSG-011',
          'sender': 'client',
          'message':
              'Good afternoon. Do you have VIP trips from Douala to Yaoundé?',
          'time': '14:05',
        },
        {
          'id': 'MSG-012',
          'sender': 'agency',
          'message':
              'Good afternoon. Available trips can be checked from the easyGO trip search.',
          'time': '14:11',
        },
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredConversations {
    final String query =
        _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _conversations;
    }

    return _conversations.where((conversation) {
      final String clientName =
          (conversation['clientName'] as String).toLowerCase();

      final String contextReference =
          (conversation['contextReference'] as String)
              .toLowerCase();

      final String lastMessage =
          (conversation['lastMessage'] as String).toLowerCase();

      return clientName.contains(query) ||
          contextReference.contains(query) ||
          lastMessage.contains(query);
    }).toList();
  }

  int get _totalUnread {
    return _conversations.fold<int>(
      0,
      (total, conversation) =>
          total + (conversation['unreadCount'] as int),
    );
  }

  Future<void> _openConversation(
    Map<String, dynamic> conversation,
  ) async {
    setState(() {
      conversation['unreadCount'] = 0;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgencyChatScreen(
          conversation: conversation,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  IconData _contextIcon(String contextType) {
    switch (contextType) {
      case 'Booking':
        return Icons.confirmation_number_outlined;
      case 'Parcel':
        return Icons.inventory_2_outlined;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  Color _contextColor(String contextType) {
    switch (contextType) {
      case 'Booking':
        return AppColors.primary;
      case 'Parcel':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final conversations = _filteredConversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF09111F),
                    Color(0xFF0D1B2A),
                    Color(0xFF10253B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF2F8FF),
                    Color(0xFFF7FBFF),
                    Color(0xFFF1FFF6),
                  ],
                ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              32,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 18),
                      _buildSearchField(),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration:
                            const Duration(milliseconds: 250),
                        child: conversations.isEmpty
                            ? _buildEmptyState(context)
                            : Column(
                                key: ValueKey(_searchQuery),
                                children: conversations
                                    .map(
                                      (conversation) => Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          bottom: 13,
                                        ),
                                        child:
                                            _buildConversationCard(
                                          context,
                                          conversation,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.forum_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Client Conversations',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'General Express • '
                  '${_conversations.length} conversations',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),
          if (_totalUnread > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_totalUnread unread',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText:
            'Search client, booking or parcel reference',
        prefixIcon: const Icon(
          Icons.search,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(
                  Icons.close,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    Map<String, dynamic> conversation,
  ) {
    final int unreadCount =
        conversation['unreadCount'] as int;

    final bool unread = unreadCount > 0;

    final String contextType =
        conversation['contextType'] as String;

    final Color contextColor =
        _contextColor(contextType);

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 17,
      onTap: () {
        _openConversation(conversation);
      },
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor:
                    AppColors.primary.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  _initials(
                    conversation['clientName']
                        as String,
                  ),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (unread)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation['clientName']
                            as String,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: unread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      conversation['lastMessageTime']
                          as String,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            fontWeight: unread
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _contextIcon(contextType),
                      size: 14,
                      color: contextColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      contextType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: contextColor,
                      ),
                    ),
                    if ((conversation[
                                'contextReference']
                            as String)
                        .isNotEmpty) ...[
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '• ${conversation['contextReference']}',
                          overflow:
                              TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  conversation['lastMessage']
                      as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        fontWeight: unread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                ),
                if ((conversation['route']
                        as String)
                    .isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.route_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          conversation['route']
                              as String,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (unread) ...[
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return GlassContainer(
      key: const ValueKey(
        'empty-conversations',
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      borderRadius: 18,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_chat_unread_outlined,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations found',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 7),
          Text(
            'No client conversation matches your current search.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where(
          (part) => part.isNotEmpty,
        )
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}