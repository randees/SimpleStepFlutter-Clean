import 'package:flutter/material.dart';
import '../../models/user_model.dart';

/// Composable widget for health question input
class QuestionInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final UserModel? selectedUser;
  final bool isProcessing;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;

  const QuestionInputWidget({
    super.key,
    required this.controller,
    this.selectedUser,
    this.isProcessing = false,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<QuestionInputWidget> createState() => _QuestionInputWidgetState();
}

class _QuestionInputWidgetState extends State<QuestionInputWidget> {
  void _handleSubmit() {
    if (!widget.isProcessing && widget.selectedUser != null) {
      widget.onSubmit();
    }
  }

  void _handleCancel() {
    if (widget.isProcessing && widget.onCancel != null) {
      widget.onCancel!();
    }
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
                  'Ask a Health Question:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    widget.controller.clear();
                  },
                  icon: const Icon(Icons.clear, size: 20),
                  tooltip: 'Clear question',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'e.g., "How is my overall health this week?" or "Show me my sleep patterns"',
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        widget.isProcessing || widget.selectedUser == null
                        ? null
                        : _handleSubmit,
                    child: widget.isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Ask Health AI'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextButton(
                    onPressed: widget.isProcessing ? _handleCancel : null,
                    style: TextButton.styleFrom(
                      backgroundColor: widget.isProcessing
                          ? Colors.red.shade100
                          : Colors.grey.shade200,
                      foregroundColor: widget.isProcessing
                          ? Colors.red.shade700
                          : Colors.grey.shade500,
                    ),
                    child: Text(
                      widget.isProcessing ? 'Cancel' : 'Cancel',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
