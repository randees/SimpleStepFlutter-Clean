import 'package:flutter/material.dart';
import '../../models/custom_ai_prompt.dart';

/// Composable widget for custom prompt management
class CustomPromptWidget extends StatefulWidget {
  final TextEditingController promptController;
  final TextEditingController promptNameController;
  final String promptStatus;
  final VoidCallback onResetPrompt;
  final VoidCallback onSavePrompt;
  final VoidCallback onLoadPrompts;
  final bool isLoadingPrompts;
  final List<CustomAiPrompt> savedPrompts;
  final CustomAiPrompt? selectedPrompt;
  final ValueChanged<CustomAiPrompt?> onPromptSelected;
  final ValueChanged<CustomAiPrompt> onDeletePrompt;
  final bool useConstrainedLayout;

  const CustomPromptWidget({
    super.key,
    required this.promptController,
    required this.promptNameController,
    required this.promptStatus,
    required this.onResetPrompt,
    required this.onSavePrompt,
    required this.onLoadPrompts,
    this.isLoadingPrompts = false,
    this.savedPrompts = const [],
    this.selectedPrompt,
    required this.onPromptSelected,
    required this.onDeletePrompt,
    this.useConstrainedLayout = false,
  });

  @override
  State<CustomPromptWidget> createState() => _CustomPromptWidgetState();
}

class _CustomPromptWidgetState extends State<CustomPromptWidget> {
  void _showPromptHelpModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.help_outline,
                      color: Colors.blue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Custom Prompt Help',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Available Tools Section
                        const Text(
                          '🔧 Available Tools',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'You can use these functions in your custom prompts to access health data:',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),

                        // Tools list
                        _buildToolItem(
                          'get_step_summary',
                          'Get detailed step analytics including most/least active days and patterns',
                        ),
                        _buildToolItem(
                          'get_activity_patterns',
                          'Get weekly activity patterns and trends',
                        ),
                        _buildToolItem(
                          'get_health_summary',
                          'Get comprehensive health overview including all vital signs, sleep, nutrition, and wellness metrics',
                        ),
                        _buildToolItem(
                          'get_vital_signs',
                          'Get specific vital signs data (heart rate, blood pressure, temperature, etc.)',
                        ),
                        _buildToolItem(
                          'get_sleep_analysis',
                          'Get detailed sleep patterns, quality, and duration analysis',
                        ),
                        _buildToolItem(
                          'get_nutrition_analysis',
                          'Get nutrition data including calories, macronutrients, hydration, and meal patterns',
                        ),
                        _buildToolItem(
                          'get_wellness_metrics',
                          'Get mental health and wellness data including mood, stress, meditation',
                        ),
                        _buildToolItem(
                          'get_health_insights',
                          'Get AI-generated health insights, recommendations, and personalized advice',
                        ),
                        _buildToolItem(
                          'get_genetic_insights',
                          'Get genetic insights and personalized health recommendations based on genetic data analysis',
                        ),

                        const SizedBox(height: 32),

                        // Available Variables Section
                        const Text(
                          '📝 Available Variables',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Use these variables in your prompts - they will be automatically replaced with user data:',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),

                        // Variables list
                        _buildVariableItem(
                          '{user_id}',
                          'User\'s unique identifier (UUID) - required for all MCP function calls',
                        ),
                        _buildVariableItem(
                          '{user_email}',
                          'User\'s email address - fallback identifier',
                        ),
                        _buildVariableItem(
                          '{user_name}',
                          'User\'s display name',
                        ),
                        _buildVariableItem(
                          '{user_age}',
                          'User\'s age calculated from date of birth',
                        ),
                        _buildVariableItem(
                          '{user_activity_level}',
                          'User\'s activity level (e.g., "Moderately Active")',
                        ),
                        _buildVariableItem(
                          '{user_health_goals}',
                          'User\'s health goals (comma-separated list)',
                        ),
                        _buildVariableItem(
                          '{current_date}',
                          'Today\'s date in YYYY-MM-DD format',
                        ),

                        const SizedBox(height: 32),

                        // Usage Tips Section
                        const Text(
                          '💡 Usage Tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• Always use {user_id} for MCP function calls - this is the primary identifier',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Use {current_date} for date-based queries to get recent data',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Combine multiple tools for comprehensive health analysis',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Use ReAct pattern: Think → Act (call function) → Observe → Respond',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Keep responses under 1000 characters when possible',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Example Section
                        const Text(
                          '📋 Example Prompt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'You are a helpful health assistant for {user_name}. When users ask about their health data, always call the appropriate function first to get their real data before providing advice.\n\nAvailable tools:\n- get_health_summary: Get comprehensive health overview\n- get_step_summary: Get step analytics\n- get_sleep_analysis: Get sleep patterns\n\nCurrent date: {current_date}\nUser ID for functions: {user_id}\n\nUse a ReAct approach: Think about what data you need, call the function, then provide personalized advice based on real data.',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolItem(String name, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildVariableItem(String variable, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            variable,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.green,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description, style: const TextStyle(fontSize: 13)),
          ),
        ],
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
                  'Custom System Prompt:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showPromptHelpModal,
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: const Text('Help'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: widget.onResetPrompt,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status message
            if (widget.promptStatus.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.promptStatus.contains('Error')
                      ? Colors.red.shade50
                      : widget.promptStatus.contains('success')
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
                  border: Border.all(
                    color: widget.promptStatus.contains('Error')
                        ? Colors.red.shade200
                        : widget.promptStatus.contains('success')
                        ? Colors.green.shade200
                        : Colors.blue.shade200,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.promptStatus,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.promptStatus.contains('Error')
                        ? Colors.red.shade700
                        : widget.promptStatus.contains('success')
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Saved Prompts Section
            Row(
              children: [
                const Text(
                  'Saved Prompts:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: widget.isLoadingPrompts
                      ? null
                      : widget.onLoadPrompts,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Saved prompts dropdown
            if (widget.savedPrompts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<CustomAiPrompt>(
                  value: widget.selectedPrompt,
                  hint: const Text('Select a saved prompt'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: widget.savedPrompts.map((prompt) {
                    return DropdownMenuItem<CustomAiPrompt>(
                      value: prompt,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              prompt.promptName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.onDeletePrompt(prompt),
                            icon: const Icon(Icons.delete, size: 16),
                            color: Colors.red.shade400,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: widget.onPromptSelected,
                ),
              )
            else if (widget.isLoadingPrompts)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No saved prompts yet. Create and save your first custom prompt!',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Save Current Prompt Section
            const Text(
              'Save Current Prompt:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Prompt name input
            TextField(
              controller: widget.promptNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a name for this prompt...',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.isLoadingPrompts ? null : widget.onSavePrompt,
                icon: widget.isLoadingPrompts
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save, size: 16),
                label: const Text('Save Current Prompt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Prompt Editor Section
            const Text(
              'Prompt Editor:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Current prompt info
            if (widget.selectedPrompt != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Editing: ${widget.selectedPrompt!.promptName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        widget.onPromptSelected(null);
                      },
                      icon: const Icon(Icons.clear, size: 16),
                      color: Colors.blue.shade600,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Prompt text editor
            widget.useConstrainedLayout
                ? TextField(
                    controller: widget.promptController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your custom system prompt...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: null,
                    minLines: 5,
                    textAlignVertical: TextAlignVertical.top,
                  )
                : Expanded(
                    child: TextField(
                      controller: widget.promptController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your custom system prompt...',
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
