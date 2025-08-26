import 'package:flutter/material.dart';
import 'step_counter_page.dart';
import 'database_test_page.dart';
import 'ai_mcp_test_page.dart';
import '../utils/app_icons.dart';

/// Home screen with hamburger menu navigation to three main pages:
/// 1. Step Counter (health data and sync)
/// 2. Database Connection Tester (Supabase connectivity)
/// 3. AI/MCP Test (OpenAI integration with custom prompts)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const StepCounterPage(),
    const DatabaseTestPage(),
    const AIMCPTestPage(),
  ];

  final List<String> _pageTitles = [
    'Step Counter',
    'Database Test',
    'AI/MCP Test',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcons.walkIcon(size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Simple Step Flutter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Health & Data Platform',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                AppIcons.walk(),
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              ),
              title: const Text('Step Counter'),
              subtitle: const Text('Health data & sync'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                AppIcons.database(),
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
              ),
              title: const Text('Database Test'),
              subtitle: const Text('Supabase connectivity'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                AppIcons.brain(),
                color: _selectedIndex == 2 ? Colors.purple : Colors.grey,
              ),
              title: const Text('AI/MCP Test'),
              subtitle: const Text('OpenAI with custom prompts'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Navigation',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(AppIcons.info(), color: Colors.grey),
              title: const Text('About'),
              subtitle: const Text('App information'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Simple Step Flutter',
      applicationVersion: '1.0.0',
      applicationIcon: AppIcons.walkIcon(size: 48),
      children: [
        const Text(
          'A comprehensive health and data platform featuring step counting, '
          'database connectivity testing, and AI integration with custom prompts.',
        ),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Health Connect/HealthKit integration'),
        const Text('• Supabase database synchronization'),
        const Text('• OpenAI API with custom system prompts'),
        const Text('• Cross-platform data analysis'),
      ],
    );
  }
}
