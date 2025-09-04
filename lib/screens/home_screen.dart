import 'package:flutter/material.dart';
import 'step_counter_page.dart';
import 'database_test_page.dart';
import 'ai_mcp_test_page.dart';
import '../utils/app_icons.dart';

/// Home screen with hamburger menu navigation to three main pages:
/// 1. Step Counter (health data and sync)
/// 2. Database Connection Tester (Supabase connectivity)
/// 3. Goal Setting Agent (OpenAI integration with custom prompts)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Default to Goal Setting Agent page

  final List<Widget> _pages = [
    const StepCounterPage(),
    const DatabaseTestPage(),
    const AIMCPTestPage(),
  ];

  final List<String> _pageTitles = [
    'Step Counter',
    'Database Test',
    'Goal Setting Agent',
  ];

  final List<String> _pageDescriptions = [
    'Health data & sync',
    'Test Supabase database connectivity and user data access',
    'AI-powered goal planning with OpenAI integration using ReAct approach',
  ];

  final List<IconData> _pageIcons = [
    AppIcons.walk(),
    AppIcons.database(),
    AppIcons.brain(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isWideScreen =
            screenWidth > 800; // Consistent breakpoint with AI page

        return Scaffold(
          appBar: AppBar(
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isWideScreen
                  ? Container(
                      key: const ValueKey('wide_title'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _pageIcons[_selectedIndex],
                                size: 24,
                                color: _selectedIndex == 1
                                    ? Colors.blue.shade700
                                    : _selectedIndex == 2
                                    ? Colors.purple.shade700
                                    : Colors.green.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _pageTitles[_selectedIndex],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _pageDescriptions[_selectedIndex],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      key: const ValueKey('narrow_title'),
                      child: Row(
                        children: [
                          Icon(
                            _pageIcons[_selectedIndex],
                            size: 24,
                            color: _selectedIndex == 1
                                ? Colors.blue.shade700
                                : _selectedIndex == 2
                                ? Colors.purple.shade700
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _pageTitles[_selectedIndex],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            toolbarHeight: isWideScreen ? 80 : 56, // Responsive height
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
                  title: const Text('Goal Setting Agent'),
                  subtitle: const Text('AI-powered goal planning'),
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
      },
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
