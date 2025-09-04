import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateRequest, validateMCPSecret } from '../_shared/auth.ts'
import { getStepSummary, getActivityPatterns } from '../_shared/step_analytics.ts'
import { 
  getHealthSummary, 
  getVitalSigns, 
  getSleepAnalysis, 
  getNutritionAnalysis, 
  getWellnessMetrics, 
  getHealthInsights 
} from '../_shared/health_data.ts'

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

    // For MCP requests, we only validate the MCP secret, not Supabase JWT
    // This allows OpenAI to call our server with just the MCP secret
    if (!validateMCPSecret(req, mcpSecret)) {
      return new Response(
        JSON.stringify({ error: { code: 401, message: 'Invalid MCP secret' } }),
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
              userId: { type: "string", description: "User ID to analyze" },
              startDate: { type: "string", format: "date" },
              endDate: { type: "string", format: "date" }
            },
            required: ["userId", "startDate", "endDate"]
          }
        },
        {
          name: "get_activity_patterns",
          description: "Get activity patterns for the last 30 days including most/least active days of the week",
          inputSchema: {
            type: "object",
            properties: {
              userId: { type: "string", description: "User ID to analyze" },
              days: { type: "number", default: 30 }
            },
            required: ["userId"]
          }
        },
        {
          name: "get_health_summary",
          description: "Get comprehensive health data summary including vital signs, sleep, nutrition, wellness metrics, and recent health insights",
          inputSchema: {
            type: "object",
            properties: {
              userId: { type: "string", description: "User ID to analyze" },
              days: { type: "number", default: 7, description: "Number of days to analyze" }
            },
            required: ["userId"]
          }
        },
        {
          name: "get_vital_signs",
          description: "Get vital signs data including heart rate, blood pressure, and other physiological measurements",
          inputSchema: {
            type: "object",
            properties: {
              userId: { type: "string", description: "User ID to analyze" },
              startDate: { type: "string", format: "date", description: "Start date for analysis" },
              endDate: { type: "string", format: "date", description: "End date for analysis" },
              measurementType: { type: "string", description: "Specific vital sign type (optional)" }
            },
            required: ["userId", "startDate", "endDate"]
          }
        },
        {
          name: "get_sleep_analysis",
          description: "Get detailed sleep analysis including sleep duration, quality, patterns, and insights",
          inputSchema: {
            type: "object",
            properties: {
              userId: { type: "string", description: "User ID to analyze" },
              days: { type: "number", default: 7, description: "Number of days to analyze" }
            },
            required: ["userId"]
          }
        },
        {
          name: "get_nutrition_analysis",
          description: "Get nutrition analysis including calorie intake, macronutrient breakdown, hydration, and meal patterns",
          inputSchema: {
            type: "object",
            properties: {
              userId: { type: "string", description: "User ID to analyze" },
              days: { type: "number", default: 7, description: "Number of days to analyze" }
            },
            required: ["userId"]
          }
        },
        {
          name: "get_wellness_metrics",
          description: "Get wellness and mental health metrics including mood, stress levels, meditation, and overall wellness trends",
          inputSchema: {
            type: "object",
            properties: {
              userId: { type: "string", description: "User ID to analyze" },
              days: { type: "number", default: 7, description: "Number of days to analyze" }
            },
            required: ["userId"]
          }
        },
        {
          name: "get_health_insights",
          description: "Get recent health insights, patterns, recommendations, and personalized health advice",
          inputSchema: {
            type: "object",
            properties: {
              userId: { type: "string", description: "User ID to analyze" },
              category: { type: "string", description: "Filter insights by category (optional)" },
              limit: { type: "number", default: 5, description: "Maximum number of insights" }
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
        if (!args.userId) {
          return {
            error: {
              code: -32602,
              message: 'userId parameter is required for step summary'
            }
          }
        }
        
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
        if (!args.userId) {
          return {
            error: {
              code: -32602,
              message: 'userId parameter is required for activity patterns'
            }
          }
        }
        
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

      case 'get_health_summary':
        if (!args.userId) {
          return {
            error: {
              code: -32602,
              message: 'userId parameter is required for health summary'
            }
          }
        }
        
        const healthSummary = await getHealthSummary(
          supabaseUrl,
          supabaseKey,
          args.userId,
          args.days || 7
        )
        
        const healthText = `
**Comprehensive Health Summary (Last ${args.days || 7} Days)**

👤 **User Profile:**
- Name: ${healthSummary.user_profile?.display_name || 'Unknown'}
- Activity Level: ${healthSummary.user_profile?.activity_level || 'Unknown'}
- Health Goals: ${healthSummary.user_profile?.health_goals?.join(', ') || 'None specified'}

📊 **Health Data Overview:**
- Activity Records: ${healthSummary.activity_data?.length || 0} entries
- Vital Signs: ${healthSummary.vital_signs?.length || 0} measurements
- Sleep Records: ${healthSummary.sleep_data?.length || 0} nights
- Nutrition Entries: ${healthSummary.nutrition_data?.length || 0} logged items
- Wellness Metrics: ${healthSummary.wellness_data?.length || 0} entries
- Health Insights: ${healthSummary.health_insights?.length || 0} AI-generated insights

📅 **Date Range:** ${healthSummary.date_range.start_date} to ${healthSummary.date_range.end_date}

💡 **Recommendation:** For detailed analysis of any specific health area, ask about sleep, nutrition, vital signs, or wellness metrics specifically.
        `.trim()
        
        return { 
          result: { 
            content: [{ 
              type: "text", 
              text: healthText
            }] 
          } 
        }

      case 'get_vital_signs':
        if (!args.userId || !args.startDate || !args.endDate) {
          return {
            error: {
              code: -32602,
              message: 'userId, startDate, and endDate parameters are required for vital signs'
            }
          }
        }
        
        const vitals = await getVitalSigns(
          supabaseUrl,
          supabaseKey,
          args.userId,
          args.startDate,
          args.endDate,
          args.measurementType
        )
        
        const vitalsText = `
**Vital Signs Analysis (${args.startDate} to ${args.endDate})**

📊 **Overview:**
- Total Measurements: ${vitals.summary.total_measurements}
- Measurement Types: ${vitals.summary.measurement_types.join(', ') || 'None recorded'}

${vitals.vital_signs.length > 0 ? `
📈 **Recent Measurements:**
${vitals.vital_signs.slice(0, 5).map(v => 
  `- ${v.measurement_type}: ${v.value_numeric || v.value_text} ${v.unit} (${new Date(v.measured_at).toLocaleDateString()})`
).join('\n')}
` : '📭 **No vital signs data found for this period**'}

💡 **Tip:** Regular monitoring of vital signs helps track your health trends and identify any concerning patterns.
        `.trim()
        
        return { 
          result: { 
            content: [{ 
              type: "text", 
              text: vitalsText
            }] 
          } 
        }

      case 'get_sleep_analysis':
        if (!args.userId) {
          return {
            error: {
              code: -32602,
              message: 'userId parameter is required for sleep analysis'
            }
          }
        }
        
        const sleep = await getSleepAnalysis(
          supabaseUrl,
          supabaseKey,
          args.userId,
          args.days || 7
        )
        
        const sleepText = `
**Sleep Analysis (Last ${args.days || 7} Days)**

😴 **Sleep Overview:**
- Total Nights Recorded: ${sleep.summary.total_nights}
- Average Sleep Duration: ${sleep.summary.avg_sleep_hours} hours
- Average Sleep Quality: ${sleep.summary.avg_sleep_quality}/10
- Average Sleep Efficiency: ${sleep.summary.avg_sleep_efficiency}%

${sleep.sleep_records.length > 0 ? `
🌙 **Recent Sleep Patterns:**
${sleep.sleep_records.slice(0, 3).map(s => 
  `- ${s.sleep_date}: ${Math.round(s.total_sleep_minutes/60)}h ${s.total_sleep_minutes%60}m (Quality: ${s.sleep_quality_score}/10)`
).join('\n')}
` : '📭 **No sleep data found for this period**'}

💡 **Sleep Tips:** Aim for 7-9 hours of quality sleep nightly. Consistent bedtimes and good sleep hygiene improve both duration and quality.
        `.trim()
        
        return { 
          result: { 
            content: [{ 
              type: "text", 
              text: sleepText
            }] 
          } 
        }

      case 'get_nutrition_analysis':
        if (!args.userId) {
          return {
            error: {
              code: -32602,
              message: 'userId parameter is required for nutrition analysis'
            }
          }
        }
        
        const nutrition = await getNutritionAnalysis(
          supabaseUrl,
          supabaseKey,
          args.userId,
          args.days || 7
        )
        
        const nutritionText = `
**Nutrition Analysis (Last ${args.days || 7} Days)**

🍎 **Nutritional Overview:**
- Total Calories: ${nutrition.summary.total_calories.toLocaleString()}
- Daily Average: ${nutrition.summary.avg_daily_calories.toLocaleString()} calories
- Total Protein: ${nutrition.summary.total_protein_g}g
- Total Carbohydrates: ${nutrition.summary.total_carbs_g}g
- Total Fat: ${nutrition.summary.total_fat_g}g
- Water Intake: ${nutrition.summary.total_water_ml.toLocaleString()}ml (${nutrition.summary.avg_daily_water_ml}ml/day)

${nutrition.nutrition_records.length > 0 ? `
🥗 **Recent Nutrition Entries:** ${nutrition.nutrition_records.length} logged items
` : '📭 **No nutrition data found for this period**'}

💡 **Nutrition Tips:** Balanced macronutrients and adequate hydration support optimal health. Consider tracking your meals to identify patterns.
        `.trim()
        
        return { 
          result: { 
            content: [{ 
              type: "text", 
              text: nutritionText
            }] 
          } 
        }

      case 'get_wellness_metrics':
        if (!args.userId) {
          return {
            error: {
              code: -32602,
              message: 'userId parameter is required for wellness metrics'
            }
          }
        }
        
        const wellness = await getWellnessMetrics(
          supabaseUrl,
          supabaseKey,
          args.userId,
          args.days || 7
        )
        
        const wellnessText = `
**Wellness Metrics (Last ${args.days || 7} Days)**

🧘 **Mental Health & Wellness:**
- Total Wellness Entries: ${wellness.summary.total_entries}

${Object.keys(wellness.summary.wellness_averages).length > 0 ? `
📊 **Average Scores:**
${Object.entries(wellness.summary.wellness_averages)
  .map(([type, avg]) => `- ${type.replace('_', ' ')}: ${(avg as number).toFixed(1)}`)
  .join('\n')}
` : '📭 **No wellness data found for this period**'}

💡 **Wellness Tips:** Regular mood tracking and mindfulness practices contribute to better mental health. Consider meditation or stress management techniques.
        `.trim()
        
        return { 
          result: { 
            content: [{ 
              type: "text", 
              text: wellnessText
            }] 
          } 
        }

      case 'get_health_insights':
        if (!args.userId) {
          return {
            error: {
              code: -32602,
              message: 'userId parameter is required for health insights'
            }
          }
        }
        
        const insights = await getHealthInsights(
          supabaseUrl,
          supabaseKey,
          args.userId,
          args.category,
          args.limit || 5
        )
        
        const insightsText = `
**Health Insights & Recommendations**

${insights.length > 0 ? `
💡 **Personalized Health Insights:**
${insights.map((insight, index) => 
  `${index + 1}. **${insight.title}** (${insight.category})
   ${insight.description}
   Confidence: ${Math.round(insight.confidence_score * 100)}%`
).join('\n\n')}
` : '📭 **No health insights available yet**\n\nInsights are generated based on your health data patterns. Keep logging your activities, sleep, nutrition, and wellness data to receive personalized recommendations.'}

🎯 **Tip:** Health insights become more accurate and valuable as you consistently track your health data across all categories.
        `.trim()
        
        return { 
          result: { 
            content: [{ 
              type: "text", 
              text: insightsText
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
