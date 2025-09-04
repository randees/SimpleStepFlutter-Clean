import 'package:flutter/material.dart';
import '../services/custom_prompts_service.dart';
import '../models/custom_ai_prompt.dart';

/// Demo widget to test custom prompts functionality
class CustomPromptsDemo extends StatefulWidget {
  const CustomPromptsDemo({Key? key}) : super(key: key);

  @override
  State<CustomPromptsDemo> createState() => _CustomPromptsDemoState();
}

class _CustomPromptsDemoState extends State<CustomPromptsDemo> {
  List<PromptType> promptTypes = [];
  List<CustomAiPrompt> customPrompts = [];
  String? selectedPromptTypeId;
  bool isLoading = false;
  String status = 'Ready to test custom prompts';

  @override
  void initState() {
    super.initState();
    _loadPromptTypes();
  }

  Future<void> _loadPromptTypes() async {
    setState(() {
      isLoading = true;
      status = 'Loading prompt types...';
    });

    try {
      final types = await CustomPromptsService.getPromptTypes();
      setState(() {
        promptTypes = types;
        status = 'Loaded ${types.length} prompt types';
      });
    } catch (e) {
      setState(() {
        status = 'Error loading prompt types: $e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCustomPrompts(String promptTypeId) async {
    setState(() {
      isLoading = true;
      status = 'Loading custom prompts...';
    });

    try {
      final prompts = await CustomPromptsService.getCustomPrompts(promptTypeId);
      setState(() {
        customPrompts = prompts;
        selectedPromptTypeId = promptTypeId;
        status = 'Loaded ${prompts.length} custom prompts';
      });
    } catch (e) {
      setState(() {
        status = 'Error loading custom prompts: $e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _createTestPrompt() async {
    if (selectedPromptTypeId == null) {
      setState(() {
        status = 'Please select a prompt type first';
      });
      return;
    }

    setState(() {
      isLoading = true;
      status = 'Creating test prompt...';
    });

    try {
      final result = await CustomPromptsService.createCustomPrompt(
        promptTypeId: selectedPromptTypeId!,
        promptText: 'This is a test prompt created at ${DateTime.now()}',
        promptName: 'Test Prompt ${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result != null) {
        await _loadCustomPrompts(selectedPromptTypeId!);
        setState(() {
          status = 'Test prompt created successfully!';
        });
      } else {
        setState(() {
          status = 'Failed to create test prompt';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error creating test prompt: $e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Prompts Demo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: status.contains('Error') ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Prompt Types Section
            Text(
              'Prompt Types (${promptTypes.length}):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (promptTypes.isEmpty && !isLoading)
              const Text(
                'No prompt types found. Migration may need to be applied.',
              )
            else
              Wrap(
                spacing: 8,
                children: promptTypes.map((type) {
                  final isSelected = selectedPromptTypeId == type.id;
                  return ChoiceChip(
                    label: Text(type.keyName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _loadCustomPrompts(type.id);
                      }
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : _loadPromptTypes,
                  child: const Text('Refresh Types'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (isLoading || selectedPromptTypeId == null)
                      ? null
                      : _createTestPrompt,
                  child: const Text('Create Test Prompt'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Custom Prompts Section
            if (selectedPromptTypeId != null) ...[
              Text(
                'Custom Prompts for ${promptTypes.firstWhere((t) => t.id == selectedPromptTypeId).keyName} (${customPrompts.length}):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (customPrompts.isEmpty)
                const Text('No custom prompts found.')
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: customPrompts.length,
                    itemBuilder: (context, index) {
                      final prompt = customPrompts[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            prompt.promptName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prompt.promptText.length > 100
                                    ? '${prompt.promptText.substring(0, 100)}...'
                                    : prompt.promptText,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Created: ${prompt.createdAt}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Prompt'),
                                  content: const Text(
                                    'Are you sure you want to delete this prompt?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                setState(() {
                                  isLoading = true;
                                  status = 'Deleting prompt...';
                                });

                                final success =
                                    await CustomPromptsService.deleteCustomPrompt(
                                      prompt.id,
                                    );

                                if (success) {
                                  await _loadCustomPrompts(
                                    selectedPromptTypeId!,
                                  );
                                  setState(() {
                                    status = 'Prompt deleted successfully';
                                  });
                                } else {
                                  setState(() {
                                    status = 'Failed to delete prompt';
                                  });
                                }

                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
