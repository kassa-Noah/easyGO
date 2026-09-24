import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';

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

  final List<Map<String, dynamic>> _messages = [];

  bool _demoMessagesCreated = false;

  String get _agencyName =>
      widget.agency['name']?.toString() ?? 'Transport Agency';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_demoMessagesCreated) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    _messages.addAll([
      {'sender': 'agency', 'message': l10n.demoAgencyGreeting, 'time': '09:10'},
      {'sender': 'client', 'message': l10n.demoClientQuestion, 'time': '09:12'},
      {'sender': 'agency', 'message': l10n.demoAgencyResponse, 'time': '09:14'},
    ]);

    _demoMessagesCreated = true;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _sendMessage() {
    final String message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    final DateTime now = DateTime.now();

    final String hour = now.hour.toString().padLeft(2, '0');

    final String minute = now.minute.toString().padLeft(2, '0');

    setState(() {
      _messages.add({
        'sender': 'client',
        'message': message,
        'time': '$hour:$minute',
      });
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        l10n.agencyMessagingDemoInfo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
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
