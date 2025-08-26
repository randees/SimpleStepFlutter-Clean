# Supabase MCP Server Setup Guide

## Overview

This guide walks you through setting up a Model Context Protocol (MCP) server using Supabase Edge Functions to enable OpenAI integration with your SimpleStepFlutter step count data. This proof of concept focuses specifically on step count analytics and insights.

## Prerequisites

- Existing Supabase project with step count data tables
- Supabase CLI installed and configured
- OpenAI API key
- Node.js 18+ for local development
- Deno runtime (automatically handled by Supabase)

## Step 1: Supabase Project Setup

### 1.1 Initialize Supabase Functions

```bash
# Navigate to your project root
cd C:/Projects/SimpleStepFlutter

# Initialize Supabase if not already done
supabase init

# Create the MCP server function
supabase functions new mcp-server

# Create shared utilities
supabase functions new _shared/cors
supabase functions new _shared/auth
supabase functions new _shared/step_analytics
```

### 1.2 Project Structure

After initialization, your Supabase functions structure should look like:

```
supabase/
├── functions/
│   ├── mcp-server/
│   │   └── index.ts
│   └── _shared/
│       ├── cors.ts
│       ├── auth.ts
│       └── step_analytics.ts
├── config.toml
└── .env.local
```

## Step 2: Environment Configuration

### 2.1 Create Environment Variables

Create or update `supabase/.env.local`:

```env
# Supabase Configuration
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key

# OpenAI Configuration
OPENAI_API_KEY=your-openai-api-key

# MCP Configuration
MCP_SERVER_SECRET=your-secret-key-for-mcp-auth
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

### 2.2 Update Supabase Config

Update `supabase/config.toml`:

```toml
[functions.mcp-server]
import_map = "./import_map.json"

[functions.mcp-server.env]
SUPABASE_URL = "env(SUPABASE_URL)"
SUPABASE_ANON_KEY = "env(SUPABASE_ANON_KEY)"
SUPABASE_SERVICE_ROLE_KEY = "env(SUPABASE_SERVICE_ROLE_KEY)"
OPENAI_API_KEY = "env(OPENAI_API_KEY)"
MCP_SERVER_SECRET = "env(MCP_SERVER_SECRET)"
ALLOWED_ORIGINS = "env(ALLOWED_ORIGINS)"
```

## Step 3: Implement Core Functions

### 3.1 CORS Utilities (`supabase/functions/_shared/cors.ts`)

```typescript
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
}

export function handleCors(request: Request): Response | null {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  return null
}
```

### 3.2 Authentication Helpers (`supabase/functions/_shared/auth.ts`)

```typescript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.33.1'

export interface AuthResult {
  user: any
  error: string | null
}

export async function authenticateRequest(
  request: Request,
  supabaseUrl: string,
  supabaseKey: string
): Promise<AuthResult> {
  const authHeader = request.headers.get('Authorization')
  
  if (!authHeader) {
    return { user: null, error: 'Missing Authorization header' }
  }

  const token = authHeader.replace('Bearer ', '')
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  const { data: { user }, error } = await supabase.auth.getUser(token)
  
  if (error || !user) {
    return { user: null, error: 'Invalid token' }
  }

  return { user, error: null }
}

export function validateMCPSecret(request: Request, secret: string): boolean {
  const mcpSecret = request.headers.get('X-MCP-Secret')
  return mcpSecret === secret
}
```

### 3.3 Step Analytics Helpers (`supabase/functions/_shared/step_analytics.ts`)

```typescript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.33.1'

export interface StepSummary {
  totalSteps: number
  averageSteps: number
  mostActiveDay: { date: string; steps: number }
  leastActiveDay: { date: string; steps: number }
  weeklyPattern: { [key: string]: number }
  dailyData: Array<{ date: string; steps: number }>
}

export async function getStepSummary(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  startDate: string,
  endDate: string
): Promise<StepSummary> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  // Query step data from your existing tables
  const { data: stepData, error } = await supabase
    .from('health_data')
    .select('*')
    .eq('user_id', userId)
    .eq('data_type', 'steps')
    .gte('date', startDate)
    .lte('date', endDate)
    .order('date', { ascending: true })

  if (error) {
    throw new Error('Failed to fetch step data')
  }

  // Calculate analytics
  const steps = stepData || []
  const totalSteps = steps.reduce((sum, day) => sum + (day.value || 0), 0)
  const averageSteps = steps.length > 0 ? Math.round(totalSteps / steps.length) : 0
  
  // Find most and least active days
  const sortedBySteps = [...steps].sort((a, b) => (b.value || 0) - (a.value || 0))
  const mostActiveDay = sortedBySteps[0] ? { 
    date: sortedBySteps[0].date, 
    steps: sortedBySteps[0].value || 0 
  } : { date: '', steps: 0 }
  
  const leastActiveDay = sortedBySteps[sortedBySteps.length - 1] ? {
    date: sortedBySteps[sortedBySteps.length - 1].date,
    steps: sortedBySteps[sortedBySteps.length - 1].value || 0
  } : { date: '', steps: 0 }

  // Calculate weekly pattern (day of week averages)
  const weeklyPattern: { [key: string]: number } = {}
  const dayTotals: { [key: string]: { total: number; count: number } } = {}
  
  steps.forEach(day => {
    const dayOfWeek = new Date(day.date).toLocaleDateString('en-US', { weekday: 'long' })
    if (!dayTotals[dayOfWeek]) {
      dayTotals[dayOfWeek] = { total: 0, count: 0 }
    }
    dayTotals[dayOfWeek].total += day.value || 0
    dayTotals[dayOfWeek].count += 1
  })

  Object.keys(dayTotals).forEach(day => {
    weeklyPattern[day] = Math.round(dayTotals[day].total / dayTotals[day].count)
  })

  return {
    totalSteps,
    averageSteps,
    mostActiveDay,
    leastActiveDay,
    weeklyPattern,
    dailyData: steps.map(d => ({ date: d.date, steps: d.value || 0 }))
  }
}

export async function getActivityPatterns(
  supabaseUrl: string,
  supabaseKey: string,
  userId: string,
  days: number = 30
): Promise<any> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  const endDate = new Date().toISOString().split('T')[0]
  const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
  
  return await getStepSummary(supabaseUrl, supabaseKey, userId, startDate, endDate)
}
```

## Step 4: Main MCP Server Implementation

### 4.1 MCP Server (`supabase/functions/mcp-server/index.ts`)

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateRequest, validateMCPSecret } from '../_shared/auth.ts'
import { getStepSummary, getActivityPatterns } from '../_shared/step_analytics.ts'

interface MCPRequest {
  method: string
  params?: any
}

interface MCPResponse {
  result?: any
  error?: {
    code: number
    message: string
  }
}

serve(async (req) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const mcpSecret = Deno.env.get('MCP_SERVER_SECRET')!

    // Validate MCP secret for OpenAI requests
    if (!validateMCPSecret(req, mcpSecret)) {
      return new Response(
        JSON.stringify({ error: { code: 401, message: 'Unauthorized' } }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const body: MCPRequest = await req.json()
    let response: MCPResponse

    switch (body.method) {
      case 'initialize':
        response = await handleInitialize()
        break
      
      case 'tools/list':
        response = await handleToolsList()
        break
      
      case 'tools/call':
        response = await handleToolCall(body.params, supabaseUrl, supabaseKey)
        break
      
      case 'resources/list':
        response = await handleResourcesList()
        break
      
      case 'resources/read':
        response = await handleResourceRead(body.params, supabaseUrl, supabaseKey)
        break
      
      default:
        response = {
          error: {
            code: -32601,
            message: `Method not found: ${body.method}`
          }
        }
    }

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('MCP Server Error:', error)
    return new Response(
      JSON.stringify({
        error: {
          code: -32603,
          message: 'Internal server error'
        }
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

async function handleInitialize(): Promise<MCPResponse> {
  return {
    result: {
      protocolVersion: "2024-11-05",
      capabilities: {
        tools: {},
        resources: { subscribe: true },
        prompts: {}
      },
      serverInfo: {
        name: "SimpleStep Analytics MCP Server",
        version: "1.0.0"
      }
    }
  }
}

async function handleToolsList(): Promise<MCPResponse> {
  return {
    result: {
      tools: [
        {
          name: "get_step_summary",
          description: "Get detailed step count analytics including most/least active days, weekly patterns, and 30-day analysis",
          inputSchema: {
            type: "object",
            properties: {
              startDate: { type: "string", format: "date" },
              endDate: { type: "string", format: "date" },
              userId: { type: "string" }
            },
            required: ["startDate", "endDate", "userId"]
          }
        },
        {
          name: "get_activity_patterns",
          description: "Get activity patterns for the last 30 days including most/least active days of the week",
          inputSchema: {
            type: "object",
            properties: {
              userId: { type: "string" },
              days: { type: "number", default: 30 }
            },
            required: ["userId"]
          }
        }
      ]
    }
  }
}

async function handleToolCall(
  params: any,
  supabaseUrl: string,
  supabaseKey: string
): Promise<MCPResponse> {
  const { name, arguments: args } = params

  try {
    switch (name) {
      case 'get_step_summary':
        const summary = await getStepSummary(
          supabaseUrl,
          supabaseKey,
          args.userId,
          args.startDate,
          args.endDate
        )
        
        const analysisText = `
**Step Count Analysis (${args.startDate} to ${args.endDate})**

📊 **Overall Statistics:**
- Total Steps: ${summary.totalSteps.toLocaleString()}
- Average Daily Steps: ${summary.averageSteps.toLocaleString()}

🏆 **Most Active Day:** ${summary.mostActiveDay.date} with ${summary.mostActiveDay.steps.toLocaleString()} steps
😴 **Least Active Day:** ${summary.leastActiveDay.date} with ${summary.leastActiveDay.steps.toLocaleString()} steps

📅 **Weekly Activity Pattern:**
${Object.entries(summary.weeklyPattern)
  .map(([day, avg]) => `- ${day}: ${avg.toLocaleString()} steps (average)`)
  .join('\n')}

📈 **Daily Data:** ${summary.dailyData.length} days of step data included
        `.trim()
        
        return { 
          result: { 
            content: [{ 
              type: "text", 
              text: analysisText
            }] 
          } 
        }
      
      case 'get_activity_patterns':
        const patterns = await getActivityPatterns(
          supabaseUrl,
          supabaseKey,
          args.userId,
          args.days || 30
        )
        
        const patternText = `
**30-Day Activity Pattern Analysis**

🎯 **Key Insights:**
- Most Active Day of Week: ${Object.entries(patterns.weeklyPattern)
  .sort(([,a], [,b]) => b - a)[0]?.[0]} (${Object.entries(patterns.weeklyPattern)
  .sort(([,a], [,b]) => b - a)[0]?.[1].toLocaleString()} avg steps)
- Least Active Day of Week: ${Object.entries(patterns.weeklyPattern)
  .sort(([,a], [,b]) => a - b)[0]?.[0]} (${Object.entries(patterns.weeklyPattern)
  .sort(([,a], [,b]) => a - b)[0]?.[1].toLocaleString()} avg steps)

📊 **30-Day Highlights:**
- Highest Step Day: ${patterns.mostActiveDay.date} (${patterns.mostActiveDay.steps.toLocaleString()} steps)
- Lowest Step Day: ${patterns.leastActiveDay.date} (${patterns.leastActiveDay.steps.toLocaleString()} steps)
- Daily Average: ${patterns.averageSteps.toLocaleString()} steps
        `.trim()
        
        return { 
          result: { 
            content: [{ 
              type: "text", 
              text: patternText
            }] 
          } 
        }
      
      default:
        return {
          error: {
            code: -32601,
            message: `Unknown tool: ${name}`
          }
        }
    }
  } catch (error) {
    return {
      error: {
        code: -32603,
        message: `Tool execution failed: ${error.message}`
      }
    }
  }
}

async function handleResourcesList(): Promise<MCPResponse> {
  return {
    result: {
      resources: [
        {
          uri: "steps://daily-data",
          name: "Daily Steps Data",
          description: "Access to daily step count data with timestamps",
          mimeType: "application/json"
        },
        {
          uri: "steps://weekly-summary",
          name: "Weekly Step Summary", 
          description: "Access to weekly step count aggregations",
          mimeType: "application/json"
        },
        {
          uri: "steps://activity-patterns",
          name: "Activity Patterns",
          description: "Access to step activity pattern analysis",
          mimeType: "application/json"
        }
      ]
    }
  }
}

async function handleResourceRead(
  params: any,
  supabaseUrl: string,
  supabaseKey: string
): Promise<MCPResponse> {
  const { uri } = params
  
  // Extract resource type from URI
  const resourceType = uri.replace('steps://', '')
  
  // For this proof of concept, return structured step data
  // In a full implementation, you'd query actual data based on resource type
  let responseData = {}
  
  switch (resourceType) {
    case 'daily-data':
      responseData = { 
        message: "Daily step count data with timestamps",
        format: "Array of {date: string, steps: number}"
      }
      break
    case 'weekly-summary':
      responseData = { 
        message: "Weekly step count aggregations",
        format: "Weekly totals and averages"
      }
      break
    case 'activity-patterns':
      responseData = { 
        message: "Activity pattern analysis data",
        format: "Day-of-week patterns and trends"
      }
      break
    default:
      responseData = { message: `Unknown resource: ${resourceType}` }
  }
  
  return {
    result: {
      contents: [
        {
          uri,
          mimeType: "application/json",
          text: JSON.stringify(responseData, null, 2)
        }
      ]
    }
  }
}
```

## Step 5: Deploy and Test

### 5.1 Deploy Functions

```bash
# Deploy the MCP server function
supabase functions deploy mcp-server

# Deploy shared utilities
supabase functions deploy _shared
```

### 5.2 Test the Deployment

```bash
# Test the MCP server endpoint
curl -X POST https://your-project-ref.supabase.co/functions/v1/mcp-server \
  -H "Authorization: Bearer your-anon-key" \
  -H "X-MCP-Secret: your-secret-key" \
  -H "Content-Type: application/json" \
  -d '{"method": "initialize"}'
```

### 5.3 Test Step Analytics Tool

```bash
# Test the step summary tool
curl -X POST https://your-project-ref.supabase.co/functions/v1/mcp-server \
  -H "Authorization: Bearer your-anon-key" \
  -H "X-MCP-Secret: your-secret-key" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "tools/call",
    "params": {
      "name": "get_step_summary",
      "arguments": {
        "userId": "your-user-id",
        "startDate": "2025-07-20",
        "endDate": "2025-08-20"
      }
    }
  }'
```

### 5.4 Expected Response

```json
{
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "tools": {},
      "resources": { "subscribe": true },
      "prompts": {}
    },
    "serverInfo": {
      "name": "SimpleStep Analytics MCP Server",
      "version": "1.0.0"
    }
  }
}
```

## Step 6: OpenAI Integration

### 6.1 Configure OpenAI Function Calling

In your Flutter app, you'll create an OpenAI client that uses your Supabase MCP endpoints:

```dart
// lib/services/mcp_client_service.dart
import 'package:openai_dart/openai_dart.dart';

class MCPClientService {
  final OpenAI _client;
  final String _mcpEndpoint;
  final String _mcpSecret;

  MCPClientService({
    required String apiKey,
    required String mcpEndpoint,
    required String mcpSecret,
  }) : _client = OpenAI(apiKey: apiKey),
       _mcpEndpoint = mcpEndpoint,
       _mcpSecret = mcpSecret;

  Future<String> queryStepData(String prompt) async {
    // Use OpenAI's function calling to interact with your MCP server
    final response = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.gpt4,
        messages: [
          ChatCompletionMessage.user(content: prompt),
        ],
        functions: [
          // Define functions that map to your MCP tools
          ChatCompletionFunction(
            name: 'get_step_summary',
            description: 'Get detailed step count analytics including most/least active days and weekly patterns',
            parameters: {
              'type': 'object',
              'properties': {
                'startDate': {'type': 'string', 'format': 'date'},
                'endDate': {'type': 'string', 'format': 'date'},
                'userId': {'type': 'string'},
              },
              'required': ['startDate', 'endDate', 'userId'],
            },
          ),
          ChatCompletionFunction(
            name: 'get_activity_patterns',
            description: 'Get activity patterns for the last 30 days including most/least active days of the week',
            parameters: {
              'type': 'object',
              'properties': {
                'userId': {'type': 'string'},
                'days': {'type': 'number'},
              },
              'required': ['userId'],
            },
          ),
        ],
      ),
    );

    return response.choices.first.message.content ?? '';
  }
  
  // Example usage methods
  Future<String> getMostActiveDay() async {
    return await queryStepData("What was my most active day in the last 30 days?");
  }
  
  Future<String> getWeeklyPattern() async {
    return await queryStepData("What day of the week am I most active? Show me my weekly step pattern.");
  }
  
  Future<String> getStepTrends() async {
    return await queryStepData("Analyze my step trends over the last month. What insights can you provide?");
  }
}
```

## Step 7: Security Configuration

### 7.1 Row Level Security (RLS)

Enable RLS on your step data tables:

```sql
-- Enable RLS on health_data table
ALTER TABLE health_data ENABLE ROW LEVEL SECURITY;

-- Create policy for MCP server access to step data
CREATE POLICY "MCP server can read step data" ON health_data
  FOR SELECT
  USING (
    -- Allow access from service role or authenticated users
    (auth.role() = 'service_role' OR auth.uid() = user_id)
    AND data_type = 'steps'  -- Only allow access to step data
  );
```

### 7.2 API Key Management

- Store your OpenAI API key securely in Supabase secrets
- Use environment variables for MCP authentication
- Implement rate limiting for MCP endpoints
- Log all step data access for monitoring and privacy compliance

## Step 8: Monitoring and Logging

### 8.1 Enable Function Logs

```bash
# View function logs
supabase functions logs mcp-server

# Follow logs in real-time
supabase functions logs mcp-server --follow
```

### 8.2 Add Custom Logging

Add logging to your MCP functions:

```typescript
console.log('MCP Request:', {
  method: body.method,
  params: body.params,
  timestamp: new Date().toISOString()
});
```

## Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure CORS headers are properly set in all responses
2. **Authentication Failures**: Verify MCP secret and Supabase keys
3. **Function Timeouts**: Optimize step data queries and add timeouts
4. **OpenAI Rate Limits**: Implement proper rate limiting and retry logic
5. **Step Data Access**: Ensure RLS policies allow access to step data only

### Debug Commands

```bash
# Check function status
supabase functions list

# Test locally
supabase functions serve mcp-server --debug

# View database connections
supabase db logs
```

## Next Steps

1. Test the MCP server with OpenAI API calls for step data
2. Implement comprehensive step analytics and pattern recognition
3. Add detailed weekly and monthly step trend analysis
4. Create comprehensive error handling for step data queries
5. Set up monitoring and alerting for step data access

### Example OpenAI Prompts to Test

Once your MCP server is running, you can test it with these prompts:

- "What day of the week am I most active?"
- "Show me my least active day in the last 30 days"
- "Analyze my step patterns and tell me when I'm most consistent"
- "What was my highest step count day this month?"
- "Give me insights about my weekly activity trends"

---

**Document Version**: 1.0  
**Last Updated**: August 20, 2025  
**Next Review**: September 20, 2025
