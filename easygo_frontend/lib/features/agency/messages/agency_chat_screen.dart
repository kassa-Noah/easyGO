import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class AgencyChatScreen extends StatefulWidget {
  const AgencyChatScreen({super.key, required this.conversation});

  final Map<String, dynamic> conversation;

  @override
  State<AgencyChatScreen> createState() => _AgencyChatScreenState();
}

class _AgencyChatScreenState extends State<AgencyChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> _messages;

  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    final List<dynamic> sourceMessages =
        widget.conversation['messages'] as List<dynamic>? ?? [];

    _messages = sourceMessages
        .map((message) => Map<String, dynamic>.from(message as Map))
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _clientName => widget.conversation['clientName'] as String;

  String get _clientPhone => widget.conversation['clientPhone'] as String;

  String get _contextType => widget.conversation['contextType'] as String;

  String get _contextReference =>
      widget.conversation['contextReference'] as String;

  String get _route => widget.conversation['route'] as String;

  String _currentTime() {
    final DateTime now = DateTime.now();

    final String hour = now.hour.toString().padLeft(2, '0');

    final String minute = now.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();

    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) {
      return;
    }

    final Map<String, dynamic> message = {
      'id': 'MSG-LOCAL-${DateTime.now().millisecondsSinceEpoch}',
      'sender': 'agency',
      'message': text,
      'time': _currentTime(),
    };

    setState(() {
      _messages.add(message);
      _isSending = false;

      widget.conversation['messages'] = _messages;

      widget.conversation['lastMessage'] = text;

      widget.conversation['lastMessageTime'] = _currentTime();

      widget.conversation['unreadCount'] = 0;
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  IconData _contextIcon() {
    switch (_contextType) {
      case 'Booking':
        return Icons.confirmation_number_outlined;
      case 'Parcel':
        return Icons.inventory_2_outlined;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  Color _contextColor() {
    switch (_contextType) {
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                _initials(_clientName),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _clientName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _clientPhone,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  _buildConversationContext(context),
                  Expanded(child: _buildMessages(context)),
                  _buildComposer(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationContext(BuildContext context) {
    final Color color = _contextColor();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GlassContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(_contextIcon(), color: color, size: 20),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _contextType == 'General'
                        ? 'General Inquiry'
                        : '$_contextType Conversation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_contextReference.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      _contextReference,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (_route.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(_route, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(BuildContext context) {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 38,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];

        final bool fromAgency = message['sender'] == 'agency';

        return _MessageBubble(
          message: message['message'] as String,
          time: message['time'] as String,
          fromAgency: fromAgency,
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).scaffoldBackgroundColor.withValues(alpha: 0.85),
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) {
                  _sendMessage();
                },
                decoration: const InputDecoration(
                  hintText: 'Reply to client...',
                  prefixIcon: Icon(Icons.chat_outlined),
                ),
              ),
            ),
            const SizedBox(width: 9),
            SizedBox(
              width: 50,
              height: 50,
              child: FilledButton(
                onPressed: _isSending ? null : _sendMessage,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.time,
    required this.fromAgency,
  });

  final String message;
  final String time;
  final bool fromAgency;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color agencyBackground = isDark
        ? AppColors.primaryDark
        : AppColors.primary;

    final Color clientBackground = isDark
        ? const Color(0xFF17263A)
        : Colors.white.withValues(alpha: 0.82);

    return Align(
      alignment: fromAgency ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
        decoration: BoxDecoration(
          color: fromAgency ? agencyBackground : clientBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(17),
            topRight: const Radius.circular(17),
            bottomLeft: Radius.circular(fromAgency ? 17 : 4),
            bottomRight: Radius.circular(fromAgency ? 4 : 17),
          ),
          border: fromAgency
              ? null
              : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  height: 1.4,
                  color: fromAgency ? Colors.white : null,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: fromAgency
                    ? Colors.white70
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
