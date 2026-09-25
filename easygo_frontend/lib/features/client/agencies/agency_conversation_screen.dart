import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../messages/models/conversation.dart';
import '../../messages/services/messaging_service.dart';

class AgencyConversationScreen extends StatefulWidget {
  final Map<String, dynamic> agency;

  const AgencyConversationScreen({super.key, required this.agency});

  @override
  State<AgencyConversationScreen> createState() =>
      _AgencyConversationScreenState();
}

class _AgencyConversationScreenState extends State<AgencyConversationScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final MessagingService _messaging = MessagingService.instance;

  List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];

  /// Set once a thread exists; null until the first message is sent.
  String? _conversationId;

  bool _isLoading = true;

  bool _isSending = false;

  String? _errorMessage;

  String get _agencyName =>
      widget.agency['name']?.toString() ?? 'Transport Agency';

  String get _agencyId => widget.agency['id']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _loadThread();
  }

  /// Finds this customer's existing thread with this agency, so the history is
  /// visible before anything new is written.
  Future<void> _loadThread() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Conversation> conversations = await _messaging
          .getConversations();

      if (!mounted) {
        return;
      }

      Conversation? thread;

      for (final Conversation conversation in conversations) {
        if (conversation.agencyId == _agencyId) {
          thread = conversation;
          break;
        }
      }

      setState(() {
        _conversationId = thread?.id;
        _messages = thread == null
            ? <Map<String, dynamic>>[]
            : _messagesFromCard(conversationToCard(thread));
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _messagesFromCard(Map<String, dynamic> card) {
    final List<dynamic> source = card['messages'] as List<dynamic>? ?? [];

    return source
        .map((dynamic message) => Map<String, dynamic>.from(message as Map))
        .toList();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String message = _messageController.text.trim();

    if (message.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final Conversation conversation;

      if (_conversationId == null) {
        conversation = await _messaging.startConversation(
          agencyId: _agencyId,
          message: message,
        );
      } else {
        conversation = await _messaging.sendMessage(
          conversationId: _conversationId!,
          body: message,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _conversationId = conversation.id;
        _messages = _messagesFromCard(conversationToCard(conversation));
        _isSending = false;
      });

      _messageController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(
                Icons.support_agent_outlined,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _agencyName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    l10n.agencyStaff,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: _backgroundGradient(context)),
        child: Column(
          children: [
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Expanded(child: _buildError(context))
            else ...[
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState(context, l10n)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];

                          return _MessageBubble(
                            message: message['message'].toString(),
                            time: message['time'].toString(),
                            isClient: message['sender'] == 'client',
                          );
                        },
                      ),
              ),

              _buildComposer(l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 44,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 14),

            Text(
              l10n.messageAgency,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Send $_agencyName a message and it will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppColors.primary,
            ),

            const SizedBox(height: 14),

            Text(
              'Unable to load this conversation',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 14),

            TextButton(onPressed: _loadThread, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  LinearGradient _backgroundGradient(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF09111F), Color(0xFF0D1B2A), Color(0xFF10253B)],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF2F8FF), Color(0xFFF7FBFF), Color(0xFFF1FFF6)],
    );
  }

  Widget _buildComposer(AppLocalizations l10n) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: GlassContainer(
          padding: const EdgeInsets.fromLTRB(14, 4, 5, 4),
          borderRadius: 24,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: l10n.typeMessage,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),

              IconButton.filled(
                tooltip: l10n.send,
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isClient;

  const _MessageBubble({
    required this.message,
    required this.time,
    required this.isClient,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: isClient
              ? Theme.of(context).colorScheme.primary
              : isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(17),
            topRight: const Radius.circular(17),
            bottomLeft: Radius.circular(isClient ? 17 : 4),
            bottomRight: Radius.circular(isClient ? 4 : 17),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isClient
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              time,
              style: TextStyle(
                fontSize: 9,
                color: isClient
                    ? Colors.white70
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
