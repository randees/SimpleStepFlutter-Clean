# MCP Server Integration Specification

## Overview

This specification outlines the implementation of a Model Context Protocol (MCP) server integration for the SimpleStepFlutter application using Supabase Edge Functions as the MCP server backend. The integration will enable OpenAI models to access health data and functionality through a standardized protocol.

## Feature Description

The MCP server integration will allow OpenAI models and applications to:

- Query step count data through standardized endpoints via Supabase Edge Functions
- Access detailed step analytics and summaries through defined tools hosted on Supabase
- Receive comprehensive step count insights including activity patterns and trends
- Integrate with the existing step tracking workflow through secure API calls

## Technical Requirements

### 1. Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Supabase MCP   │    │   OpenAI API    │
│                 │    │  Edge Functions │    │                 │
│ - Health Service│◄──►│ - MCP Protocol  │◄──►│ - GPT Models    │
│ - Step Tracking │    │ - Step Queries  │    │ - Assistant API │
│ - App State     │    │ - Analytics     │    │ - Function Call │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 2. Core Components

#### 2.1 Supabase Edge Functions (`supabase/functions/mcp-server/`)

- **Purpose**: Serverless MCP protocol implementation focused on step count analytics
- **Responsibilities**:
  - Handle MCP protocol messages and routing
  - Authenticate OpenAI API requests
  - Query Supabase database for step count data
  - Execute step analytics tools and return detailed summaries
  - Provide activity pattern analysis

#### 2.2 Flutter MCP Client (`lib/services/mcp_client_service.dart`)

- **Purpose**: Client-side service for MCP communication with Supabase
- **Responsibilities**:
  - Configure OpenAI API with MCP server endpoints
  - Handle authentication with API keys
  - Manage connection state and error handling
  - Provide interface for triggering step analytics operations

#### 2.3 Supabase Step Analytics (`supabase/functions/shared/`)

- **Purpose**: Shared utilities and step analysis functions for MCP
- **Responsibilities**:
  - Define step count analytics tools and their schemas
  - Handle step data query optimization and aggregation
  - Manage data access permissions for step data
  - Provide detailed step summary formatting utilities

### 3. Dependencies and Packages

#### 3.1 Required Additions to `pubspec.yaml`

```yaml
dependencies:
  # Existing dependencies...
  http: ^1.1.0                   # HTTP client for API calls
  openai_dart: ^0.2.0            # OpenAI API client
  dio: ^5.3.2                    # Advanced HTTP client with interceptors
  retry: ^3.1.2                  # Retry logic for API calls

dev_dependencies:
  # Existing dev dependencies...
  mockito: ^5.4.2                # Mocking for tests
  test: ^1.24.9                  # Additional testing utilities
```

#### 3.2 Supabase Edge Functions Dependencies

```typescript
// supabase/functions/mcp-server/deps.ts
export { serve } from "https://deno.land/std@0.168.0/http/server.ts"
export { createClient } from 'https://esm.sh/@supabase/supabase-js@2.33.1'
export { corsHeaders } from '../_shared/cors.ts'
```

### 4. Implementation Plan

#### Phase 1: Foundation (Week 1)

- [ ] Set up Supabase Edge Functions for MCP server
- [ ] Create basic MCP protocol message handling
- [ ] Implement OpenAI API key authentication
- [ ] Set up CORS and security headers
- [ ] Create Flutter MCP client service skeleton

#### Phase 2: Core Functionality (Week 2)

- [ ] Implement step count data query endpoints in Supabase functions
- [ ] Create MCP tool for detailed step analytics
- [ ] Add OpenAI function calling integration for step data
- [ ] Implement step pattern analysis (most/least active days)
- [ ] Create error handling and logging

#### Phase 3: Analytics & Integration (Week 3)

- [ ] Connect Flutter app with Supabase MCP endpoints
- [ ] Integrate with existing HealthService step data flows
- [ ] Add detailed step summary generation (30-day analysis)
- [ ] Implement data caching and optimization for step queries
- [ ] Create comprehensive testing for step analytics

#### Phase 4: Testing & Documentation (Week 4)

- [ ] Write unit tests for Supabase step analytics functions
- [ ] Create integration tests with OpenAI API
- [ ] Performance testing and optimization for step queries
- [ ] Documentation and setup guides for step-focused MCP
- [ ] Example OpenAI prompts for step data analysis

### 5. MCP Protocol Implementation

#### 5.1 Supported Capabilities
```json
{
  "capabilities": {
    "resources": {
      "subscribe": true,
      "listChanged": true
    },
    "tools": {
      "listChanged": true
    },
    "prompts": {
      "listChanged": true
    },
    "logging": {}
  }
}
```

#### 5.2 Available Resources

- `/steps/daily-data` - Daily step count data with timestamps
- `/steps/weekly-summary` - Weekly step count aggregations
- `/steps/activity-patterns` - Activity pattern analysis data

#### 5.3 Available Tools

- `get_step_summary` - Retrieve detailed step count analytics for date range including:
  - Most active/inactive days of the week
  - Day with most/least steps in the last 30 days
  - Weekly and daily step count trends
  - Activity pattern analysis

### 6. Security Considerations

#### 6.1 Authentication
- API key-based authentication for MCP clients
- Token-based session management
- Rate limiting per client/endpoint

#### 6.2 Data Protection

- Encrypt step count data in transit
- Implement data access logging for step queries
- Respect user privacy preferences for step data
- GDPR compliance for step count information

#### 6.3 Access Control
- Role-based permissions for different client types
- Granular data access controls
- Audit trail for all data access

### 7. Configuration

#### 7.1 MCP Server Configuration (`config/mcp_config.dart`)
```dart
class MCPConfig {
  static const int defaultPort = 8080;
  static const String defaultHost = 'localhost';
  static const Duration sessionTimeout = Duration(hours: 24);
  static const int maxConcurrentClients = 10;
  static const List<String> allowedOrigins = ['*'];
}
```

#### 7.2 Environment Variables
- `MCP_SERVER_PORT` - Server port (default: 8080)
- `MCP_SERVER_HOST` - Server host (default: localhost)
- `MCP_ENABLE_LOGGING` - Enable detailed logging (default: true)
- `MCP_API_KEY` - Master API key for authentication

### 8. File Structure

```
lib/
├── services/
│   ├── health_service.dart          # Existing
│   ├── supabase_service.dart        # Existing
│   └── mcp_client_service.dart      # New - OpenAI MCP client
├── models/
│   ├── mcp_message.dart             # New - MCP protocol messages
│   ├── openai_function.dart         # New - OpenAI function definitions
│   └── step_analytics.dart          # New - Step analytics models
├── config/
│   └── openai_config.dart           # New - OpenAI API configuration
└── utils/
    ├── mcp_logger.dart              # New - MCP-specific logging
    └── openai_helpers.dart          # New - OpenAI API utilities

supabase/
├── functions/
│   ├── mcp-server/
│   │   ├── index.ts                 # Main MCP server endpoint
│   │   └── types.ts                 # TypeScript type definitions
│   ├── _shared/
│   │   ├── cors.ts                  # CORS utilities
│   │   ├── auth.ts                  # Authentication helpers
│   │   └── database.ts              # Database query helpers
│   └── step-analytics/
│       ├── get-summary.ts           # Step summary analytics tool
│       ├── activity-patterns.ts     # Activity pattern analysis
│       └── weekly-trends.ts         # Weekly step trends analysis
```

### 9. Testing Strategy

#### 9.1 Unit Tests

- Test MCP protocol message handling for step data
- Validate step analytics accuracy and calculations
- Test OpenAI function calling for step queries
- Security and authentication tests for step data access

#### 9.2 Integration Tests

- End-to-end MCP client-server communication for step analytics
- Step data flow through MCP layer
- OpenAI function calling with step summary tools
- Error handling and recovery for step queries

#### 9.3 Performance Tests

- Concurrent client handling for step analytics
- Large step dataset queries and aggregations
- Memory usage optimization for step calculations
- Response time benchmarks for step summary generation

### 10. Documentation Deliverables

#### 10.1 Developer Documentation
- API reference with examples
- Integration guide for external clients
- Configuration and deployment guide
- Troubleshooting and FAQ

#### 10.2 Example Implementations

- OpenAI Assistant with health data analysis capabilities
- Python script using OpenAI API with MCP tools
- Node.js application integrating health data via OpenAI
- Postman collection for testing Supabase MCP endpoints

### 11. Success Criteria

- [ ] MCP server successfully exposes step count data via standardized protocol
- [ ] OpenAI models can connect and query detailed step analytics
- [ ] Step summary includes most/least active days and activity patterns
- [ ] 30-day step analysis provides meaningful insights about activity trends
- [ ] Security measures protect step count data
- [ ] Performance meets requirements (< 100ms response time for step queries)
- [ ] Comprehensive test coverage for step analytics (> 90%)
- [ ] Documentation enables easy OpenAI integration for step data

### 12. Risk Mitigation

#### 12.1 Technical Risks
- **Protocol Complexity**: Start with simplified MCP subset, expand gradually
- **Performance Impact**: Implement caching and async processing
- **Security Vulnerabilities**: Regular security audits and penetration testing

#### 12.2 Integration Risks

- **Step Service Disruption**: Implement MCP as non-blocking overlay to existing step tracking
- **Data Consistency**: Use existing step data validation and sync mechanisms
- **Backward Compatibility**: Ensure existing app functionality remains intact

### 13. Future Enhancements

- Advanced step analytics with machine learning predictions
- Multi-user step comparison and leaderboards via MCP
- Integration with additional fitness tracking APIs
- Custom step challenges and goal tracking via OpenAI
- Advanced reporting and visualization tools for step data

---

**Document Version**: 1.0  
**Last Updated**: August 20, 2025  
**Next Review**: September 20, 2025