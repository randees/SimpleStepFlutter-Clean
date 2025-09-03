import 'package:flutter/material.dart';
import '../services/custom_prompts_service.dart';
import '../models/custom_ai_prompt.dart';

class CustomPromptsTestPage extends StatefulWidget {
  const CustomPromptsTestPage({super.key});

  @override
  State<CustomPromptsTestPage> createState() => _CustomPromptsTestPageState();
}

class _CustomPromptsTestPageState extends State<CustomPromptsTestPage> {
  List<CustomAiPrompt> _prompts = [];
  bool _isLoading = false;
  String _status = 'Ready';

  @override
  void initState() {
    super.initState();
    _testCustomPrompts();
  }

  Future<void> _testCustomPrompts() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing custom prompts...';
    });

    try {
      // Test 1: Get existing prompts
      setState(() {
        _status = 'Fetching existing prompts...';
      });
      final prompts = await CustomPromptsService.getCustomPrompts('goal_setting');
      setState(() {
        _prompts = prompts;
        _status = 'Found ${prompts.length} existing prompts';
      });

      // Test 2: Create a test prompt
      setState(() {
        _status = 'Creating test prompt...';
      });
      final testPrompt = await CustomPromptsService.createCustomPrompt(
        promptTypeId: 'goal_setting',
        promptText: 'This is a test prompt created at ${DateTime.now()}',
        promptName: 'Test Prompt ${DateTime.now().millisecondsSinceEpoch}',
      );

      if (testPrompt != null) {
        setState(() {
          _status = '✅ Test prompt created successfully: ${testPrompt.promptName}';
        });

        // Test 3: Refresh the list to see the new prompt
        await Future.delayed(const Duration(seconds: 1));
        final updatedPrompts = await CustomPromptsService.getCustomPrompts('goal_setting');
        setState(() {
          _prompts = updatedPrompts;
          _status = '✅ All tests passed! Created and retrieved ${updatedPrompts.length} prompts';
        });
      } else {
        setState(() {
          _status = '❌ Failed to create test prompt';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Prompts Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Status: $_status',
              style: TextStyle(
                fontSize: 16,
                color: _status.contains('❌') ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _testCustomPrompts,
                child: const Text('Run Test Again'),
              ),
            const SizedBox(height: 24),
            Text(
              'Current Prompts (${_prompts.length}):',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _prompts.length,
                itemBuilder: (context, index) {
                  final prompt = _prompts[index];
                  return Card(
                    child: ListTile(
                      title: Text(prompt.promptName),
                      subtitle: Text(
                        prompt.promptText.length > 100
                            ? '${prompt.promptText.substring(0, 100)}...'
                            : prompt.promptText,
                      ),
                      trailing: Text(
                        prompt.createdAt.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
