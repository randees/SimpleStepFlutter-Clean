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
          description: "Get detailed step count analytics including most/least active days, weekly patterns for existing step data",
          inputSchema: {
            type: "object",
            properties: {
              startDate: { type: "string", format: "date" },
              endDate: { type: "string", format: "date" }
            },
            required: ["startDate", "endDate"]
          }
        },
        {
          name: "get_activity_patterns",
          description: "Get activity patterns for the last 30 days including most/least active days of the week",
          inputSchema: {
            type: "object",
            properties: {
              days: { type: "number", default: 30 }
            },
            required: []
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
          '', // userId not needed for step_data table
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
