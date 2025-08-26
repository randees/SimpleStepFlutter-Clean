import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'config/env_config.dart';
import 'config/supabase_config.dart';
import 'config/openai_config.dart';
import 'services/supabase_service.dart';
import 'screens/home_screen.dart';

void main() async {
  print('🔄 Main: Starting app initialization...');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration first
  try {
    print('🔄 Main: Loading environment configuration...');
    await EnvConfig.initialize();
    print('✅ Main: Environment configuration loaded');

    // Print configuration summary (with masked secrets) for debugging
    if (EnvConfig.debugMode) {
      print('📋 Configuration Summary: ${EnvConfig.getConfigSummary()}');
    }

    // Always print configuration status during startup for debugging
    print('🔍 Startup Configuration Status:');
    print('  - Platform: ${kIsWeb ? "Web" : "Native"}');
    print(
      '  - Environment: ${EnvConfig.isDevelopment ? "Development" : "Production"}',
    );
    print('  - Debug Mode: ${EnvConfig.debugMode}');
    print(
      '  - Supabase URL: ${EnvConfig.supabaseUrl.isNotEmpty ? "Set (${EnvConfig.supabaseUrl.length} chars)" : "NOT SET"}',
    );
    print(
      '  - Supabase Anon Key: ${EnvConfig.supabaseAnonKey.isNotEmpty ? "Set (${EnvConfig.supabaseAnonKey.length} chars)" : "NOT SET"}',
    );
    print(
      '  - OpenAI API Key: ${EnvConfig.openaiApiKey.isNotEmpty ? "Set (${EnvConfig.openaiApiKey.length} chars)" : "NOT SET"}',
    );
    print(
      '  - MCP Endpoint: ${EnvConfig.mcpEndpoint.isNotEmpty ? "Set (${EnvConfig.mcpEndpoint.length} chars)" : "NOT SET"}',
    );
    print(
      '  - MCP Secret: ${EnvConfig.mcpSecret.isNotEmpty ? "Set (${EnvConfig.mcpSecret.length} chars)" : "NOT SET"}',
    );
    print('🔍 Configuration Checks:');
    print('  - Supabase Configured: ${EnvConfig.isSupabaseConfigured}');
    print('  - OpenAI Configured: ${EnvConfig.isOpenAIConfigured}');
    print('  - MCP Configured: ${EnvConfig.isMCPConfigured}');
  } catch (e) {
    print('❌ Main: Error loading environment configuration: $e');
    print('❌ Main: App will continue with limited functionality');
  }

  // Initialize Supabase if configuration is available
  try {
    print('🔄 Main: Checking Supabase configuration...');

    // For web platform, give some extra time to ensure config is loaded
    if (kIsWeb) {
      print('🌐 Main: Web platform detected, checking config status...');
      await Future.delayed(
        Duration(milliseconds: 100),
      ); // Small delay to ensure config loading
    }

    if (SupabaseConfig.isConfigured) {
      print('🔄 Main: Supabase config found, initializing...');
      await SupabaseService.initialize();
      print('✅ Main: Supabase initialized successfully');

      if (EnvConfig.debugMode) {
        print('📋 Supabase Config: ${SupabaseConfig.getConfigSummary()}');
      }
    } else {
      print(
        '⚠️ Main: Supabase configuration not found in environment variables',
      );
      print('📋 Current config status: ${EnvConfig.getConfigSummary()}');
      print(
        '⚠️ Main: Please check your .env file and ensure SUPABASE_URL and SUPABASE_ANON_KEY are set',
      );
    }
  } catch (e) {
    print('❌ Main: Error initializing Supabase: $e');
    print('❌ Main: App will continue without database functionality');
  }

  // Validate OpenAI configuration
  print('🔄 Main: Validating OpenAI configuration...');
  if (OpenAIConfig.isConfigured) {
    print('✅ Main: OpenAI configuration validated');
    print(
      '📋 OpenAI API Key Length: ${EnvConfig.openaiApiKey.length} characters',
    );
    if (EnvConfig.debugMode) {
      print('📋 OpenAI Config: ${OpenAIConfig.getConfigSummary()}');
    }
  } else {
    print('⚠️ Main: OpenAI configuration incomplete');
    print(
      '⚠️ Current OpenAI Key: "${EnvConfig.openaiApiKey}" (length: ${EnvConfig.openaiApiKey.length})',
    );
    print(
      '⚠️ Is Valid Format: ${EnvConfig.isValidApiKeyFormat(EnvConfig.openaiApiKey)}',
    );
    print(
      '⚠️ Main: Please check your environment variables and ensure OPENAI_API_KEY is set',
    );
  }

  print('🔄 Main: Starting Flutter app...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Step Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
