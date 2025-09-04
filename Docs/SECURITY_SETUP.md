# 🔐 Security Configuration Guide

This guide explains how to securely configure the Simple Step Flutter app using environment variables to protect API keys and sensitive data.

## 🚨 **IMPORTANT: Never commit API keys to version control!**

This app uses environment variables to keep sensitive data secure. All API keys and secrets are loaded from a `.env` file that is **never committed** to the repository.

## 📋 **Setup Instructions**

### 1. Create your .env file

```bash
# Copy the example file and fill in your actual values
cp .env.example .env
```

### 2. Configure your .env file

Edit the `.env` file with your actual API keys and configuration:

```bash
# Supabase Configuration
SUPABASE_URL=https://your-actual-project-id.supabase.co
SUPABASE_ANON_KEY="YOUR-SUPABASE-ANON-KEY"
SUPABASE_SERVICE_ROLE_KEY="YOUR-SUPABASE-ANON-KEY"

# OpenAI Configuration
OPENAI_API_KEY=sk-your-actual-openai-api-key

# MCP Server Configuration
MCP_ENDPOINT=https://your-actual-project-id.supabase.co/functions/v1/mcp-server
MCP_SECRET=your-secure-mcp-secret-here

# Development Configuration (optional)
FLUTTER_ENV=development
DEBUG_MODE=true
```

### 3. Get your API keys

#### **Supabase Keys:**
1. Go to [supabase.com](https://supabase.com) → Your Project → Settings → API
2. Copy your **Project URL** and **anon public key**
3. Optionally copy the **service_role secret** for server operations

#### **OpenAI API Key:**
1. Go to [platform.openai.com](https://platform.openai.com)
2. Navigate to API Keys section
3. Create a new API key (starts with `sk-`)
4. Copy the key immediately (you won't see it again)

#### **MCP Secret:**
- Generate a secure random string for the MCP_SECRET
- Use a password generator or create a unique string

### 4. Verify configuration

Run the app and check the console logs:
```bash
flutter run
```

Look for these success messages:
- ✅ Environment configuration loaded successfully
- ✅ Supabase initialized successfully  
- ✅ OpenAI configuration validated

## 🔧 **Configuration Classes**

### EnvConfig
Central environment variable manager:
```dart
import 'package:your_app/config/env_config.dart';

// Initialize (done automatically in main.dart)
await EnvConfig.initialize();

// Access configuration
String apiKey = EnvConfig.openaiApiKey;
bool isConfigured = EnvConfig.isOpenAIConfigured;
```

### SupabaseConfig
Secure Supabase configuration:
```dart
import 'package:your_app/config/supabase_config.dart';

String url = SupabaseConfig.supabaseUrl;  // From SUPABASE_URL
String key = SupabaseConfig.supabaseAnonKey;  // From SUPABASE_ANON_KEY
bool configured = SupabaseConfig.isConfigured;
```

### OpenAIConfig
Secure OpenAI configuration:
```dart
import 'package:your_app/config/openai_config.dart';

String apiKey = OpenAIConfig.apiKey;  // From OPENAI_API_KEY
String endpoint = OpenAIConfig.mcpEndpoint;  // From MCP_ENDPOINT
bool configured = OpenAIConfig.isConfigured;
```

## 🛡️ **Security Features**

### ✅ **What's Protected:**
- ✅ Supabase URL and API keys
- ✅ OpenAI API keys
- ✅ MCP server secrets
- ✅ Service role keys
- ✅ All sensitive configuration

### ✅ **Security Measures:**
- ✅ Environment variables instead of hardcoded values
- ✅ Masked API keys in debug logs
- ✅ API key format validation
- ✅ Configuration validation at startup
- ✅ .env files excluded from git
- ✅ Secure fallback behavior

### ✅ **Debug-Safe Logging:**
```dart
// API keys are automatically masked in logs
print('API Key: ${EnvConfig.getMaskedApiKey(apiKey)}');
// Output: "API Key: sk-ab...xyz9"
```

## 🚫 **What NOT to Do**

- ❌ Never commit `.env` files
- ❌ Never hardcode API keys in source code
- ❌ Never share your `.env` file
- ❌ Never commit real keys to public repositories
- ❌ Never log full API keys

## 🔍 **Troubleshooting**

### **"Environment configuration not loaded" error:**
- Ensure `.env` file exists in project root
- Check that `.env` file has correct syntax (no spaces around `=`)
- Verify flutter_dotenv is in pubspec.yaml dependencies

### **"Supabase configuration not found" warning:**
- Check `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env`
- Ensure values don't have quotes or extra spaces
- Verify Supabase project is active

### **"OpenAI configuration incomplete" warning:**
- Check `OPENAI_API_KEY` in `.env`
- Ensure key starts with `sk-`
- Verify OpenAI account has billing set up

### **API key format validation failed:**
- OpenAI keys should start with `sk-`
- Supabase keys are JWT tokens (start with `eyJ`)
- Remove any quotes or whitespace

## 🌐 **Production Deployment**

For production deployments:

1. **Never include .env in builds**
2. **Use platform-specific environment variables:**
   - **Vercel:** Environment Variables in dashboard
   - **Firebase Hosting:** `firebase functions:config:set`
   - **AWS:** Systems Manager Parameter Store
   - **Docker:** Environment variables in container

3. **Web deployment:** Consider using different configuration methods for web builds since .env files aren't available in browsers

## 📝 **Development Team Setup**

1. Each developer should:
   - Copy `.env.example` to `.env`
   - Fill in their own API keys
   - Never commit their `.env` file

2. For team testing:
   - Use shared development Supabase project
   - Each developer can use their own OpenAI API key
   - Document any shared secrets in team password manager

## 🔄 **Updating Configuration**

When adding new secrets:

1. Add to `.env.example` with placeholder values
2. Add getter to `EnvConfig` class
3. Update documentation
4. Notify team to update their `.env` files

Example:
```dart
// In EnvConfig class
static String get newApiKey => _getEnv('NEW_API_KEY');
static bool get isNewServiceConfigured => newApiKey.isNotEmpty;
```
