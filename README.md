# Ì∫Ä Simple Step Flutter - Health Tracking App

A comprehensive Flutter application for health data tracking with AI-powered analytics, built with Supabase backend and OpenAI integration.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![OpenAI](https://img.shields.io/badge/OpenAI-74aa9c?style=for-the-badge&logo=openai&logoColor=white)

## ‚ú® Features

- **Ì≥± Cross-Platform**: iOS, Android, Web, Windows, macOS, Linux
- **Ì¥í Secure Configuration**: Environment-based secrets management
- **Ì≥ä Health Tracking**: Step counting, health data synchronization
- **Ì¥ñ AI Analytics**: OpenAI-powered health insights and recommendations
- **Ì∑ÑÔ∏è Database Integration**: Supabase for user data and health records
- **Ìæ® Modern UI**: Material Design with FluentUI icon support
- **Ì¥å MCP Integration**: Model Context Protocol for advanced AI interactions

## Ì∫Ä Quick Start

### Prerequisites

- Flutter SDK (>=3.0.0)
- A Supabase account and project
- An OpenAI API key (optional, for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR-USERNAME/SimpleStepFlutter.git
   cd SimpleStepFlutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with your API keys:
   ```properties
   SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
   SUPABASE_ANON_KEY=YOUR-SUPABASE-ANON-KEY
   OPENAI_API_KEY=YOUR-OPENAI-API-KEY
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Ì≥ã Configuration Guide

### Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from Settings > API
3. Run the database migrations from `supabase/migrations/`
4. Update your `.env` file with the credentials

### OpenAI Setup

1. Get an API key from [platform.openai.com](https://platform.openai.com/api-keys)
2. Add it to your `.env` file as `OPENAI_API_KEY`

For detailed setup instructions, see [SECURITY_SETUP.md](SECURITY_SETUP.md).

## Ì¥í Security

This project uses environment variables to manage sensitive configuration:

- All API keys are stored in `.env` (never committed)
- Configuration validation and error handling
- Secure logging (secrets are masked)
- Production-ready security practices

See [SECURITY_SETUP.md](SECURITY_SETUP.md) for detailed security guidelines.

## Ì≥ñ Documentation

- [Security Setup Guide](SECURITY_SETUP.md)
- [MCP Testing Guide](Docs/MCP_TESTING_GUIDE.md)
- [Health Connect Testing](Docs/HEALTH_CONNECT_TESTING_GUIDE.md)
- [Project Overview](Docs/project_overview.md)

## Ì¥ù Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## Ì≥Ñ License

This project is licensed under the MIT License.

## Ìπè Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Supabase](https://supabase.com/) - Backend as a Service
- [OpenAI](https://openai.com/) - AI integration
- [FluentUI](https://developer.microsoft.com/en-us/fluentui) - Icon system

---

**‚ö†Ô∏è Important**: Remember to configure your `.env` file before running the application. Never commit your `.env` file to version control!
