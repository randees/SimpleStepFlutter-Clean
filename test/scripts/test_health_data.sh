#!/bin/bash

# Test MCP Server with Real Health Data
echo "🧪 Testing MCP Server with Health Data"
echo "======================================"

# Configuration
BASE_URL="https://YOUR-PROJECT-ID.supabase.co/functions/v1/mcp-server"
AUTH_TOKEN=""YOUR-SUPABASE-ANON-KEY""
MCP_SECRET="mcp-secret-2024-simple-step"

# Headers
HEADERS="-H Content-Type:application/json -H Authorization:Bearer\ $AUTH_TOKEN -H X-MCP-Secret:$MCP_SECRET"

echo ""
echo "📊 Testing Step Summary (August 1-20, 2025)"
echo "--------------------------------------------"
curl -s -X POST "$BASE_URL" $HEADERS \
  -d '{
    "method": "tools/call",
    "params": {
      "name": "get_step_summary",
      "arguments": {
        "userId": "test-user-123",
        "startDate": "2025-08-01",
        "endDate": "2025-08-20"
      }
    }
  }'

echo ""
echo ""
echo "📈 Testing Activity Patterns (30 days)"
echo "--------------------------------------"
curl -s -X POST "$BASE_URL" $HEADERS \
  -d '{
    "method": "tools/call",
    "params": {
      "name": "get_activity_patterns",
      "arguments": {
        "userId": "test-user-123",
        "days": 30
      }
    }
  }'

echo ""
echo ""
echo "✅ MCP Server Health Data Testing Complete!"
