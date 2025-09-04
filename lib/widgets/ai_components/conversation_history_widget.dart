import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/ai_services/conversation_service.dart';

/// Composable widget for displaying and managing conversation history
class ConversationHistoryWidget extends StatefulWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final VoidCallback onClearHistory;
  final bool isExpanded;
  final ValueChanged<bool> onExpandedChanged;
  final bool useConstrainedLayout;

  const ConversationHistoryWidget({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.onClearHistory,
    this.isExpanded = false,
    required this.onExpandedChanged,
    this.useConstrainedLayout = false,
  });

  @override
  State<ConversationHistoryWidget> createState() =>
      _ConversationHistoryWidgetState();
}

class _ConversationHistoryWidgetState extends State<ConversationHistoryWidget> {
  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void didUpdateWidget(ConversationHistoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll when new messages are added
    if (widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  void _handleClearHistory() {
    widget.onClearHistory();
    if (kDebugMode) {
      print('🧹 Conversation history cleared - AI context reset');
    }
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation history cleared - AI context reset'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Conversation History:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.messages.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.messages.length} msg${widget.messages.length == 1 ? '' : 's'} in context',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const Spacer(),
                if (widget.messages.isNotEmpty)
                  TextButton.icon(
                    onPressed: _handleClearHistory,
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    widget.onExpandedChanged(!widget.isExpanded);
                  },
                  icon: Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  tooltip: widget.isExpanded
                      ? 'Collapse history'
                      : 'Expand history',
                ),
              ],
            ),
            const SizedBox(height: 8),
            widget.useConstrainedLayout
                ? SizedBox(
                    height: 200, // Fixed height for constrained layout
                    child: widget.messages.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'No health conversation yet. Ask a question about your health data to get started!',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              controller: widget.scrollController,
                              itemCount: widget.messages.length,
                              itemBuilder: (context, index) {
                                final message = widget.messages[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: message.isUser
                                        ? Colors.blue.shade50
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: message.isUser
                                          ? Colors.blue.shade200
                                          : Colors.green.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            message.isUser
                                                ? Icons.person
                                                : Icons.psychology,
                                            size: 16,
                                            color: message.isUser
                                                ? Colors.blue.shade600
                                                : Colors.green.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            message.isUser ? 'You' : 'AI Assistant',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: message.isUser
                                                  ? Colors.blue.shade600
                                                  : Colors.green.shade600,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(message.message),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  )
                : Expanded(
                    child: widget.messages.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'No health conversation yet. Ask a question about your health data to get started!',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              controller: widget.scrollController,
                              itemCount: widget.messages.length,
                              itemBuilder: (context, index) {
                                final message = widget.messages[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: message.isUser
                                        ? Colors.blue.shade50
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: message.isUser
                                          ? Colors.blue.shade200
                                          : Colors.green.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            message.isUser
                                                ? Icons.person
                                                : Icons.psychology,
                                            size: 16,
                                            color: message.isUser
                                                ? Colors.blue.shade600
                                                : Colors.green.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            message.isUser ? 'You' : 'AI Assistant',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: message.isUser
                                                  ? Colors.blue.shade600
                                                  : Colors.green.shade600,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(message.message),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
