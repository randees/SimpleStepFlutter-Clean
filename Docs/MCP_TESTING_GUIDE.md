# 🧪 MCP Server Testing Guide

## Current Status: ✅ Ready for Testing!

Your MCP server is deployed and working at:
`https://YOUR-PROJECT-ID.supabase.co/functions/v1/mcp-server`

## 📋 Step 1: Set Up Test Data (Required)

1. **Open Supabase SQL Editor**: 
   - Go to https://supabase.com/dashboard/project/YOUR-PROJECT-ID/editor
   - Copy the SQL from `setup_health_data.sql` 
   - Paste and run it to create the health_data table with test data

## 🔧 Step 2: Test MCP Server Directly

Once you've set up the test data, run this command:

```bash
chmod +x test_health_data.sh && ./test_health_data.sh
```

This will test:
- ✅ Step summary analytics for test-user-123
- ✅ Activity patterns and weekly insights
- ✅ Most/least active days analysis

## 📱 Step 3: Test Flutter MCP Widget

1. **Access the Flutter App**:
   - Open http://localhost:3000 in your browser
   - Or wait for the Flutter app to finish loading

2. **Open MCP Test Widget**:
   - Click the API icon (📡) in the top-right corner
   - This opens the MCP Test Widget

3. **Configure the Widget**:
   ```
   Supabase URL: https://YOUR-PROJECT-ID.supabase.co
   MCP Endpoint: https://YOUR-PROJECT-ID.supabase.co/functions/v1/mcp-server
   MCP Secret: mcp-secret-2024-simple-step
   OpenAI API Key: YOUR-OPENAI-API-KEY
   ```

4. **Test MCP Connection**:
   - Click "Test MCP Connection"
   - Should show success message

5. **Test Step Analytics**:
   - Click "Test Step Analytics"
   - Should return detailed step analysis

6. **Test Natural Language Queries**:
   - Try queries like:
     - "What was my most active day?"
     - "Show me my weekly step pattern"
     - "How many steps did I take yesterday?"

## 🎯 Expected Results

### ✅ Successful MCP Connection
```json
{
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {"tools": {}, "resources": {"subscribe": true}},
    "serverInfo": {"name": "SimpleStep Analytics MCP Server", "version": "1.0.0"}
  }
}
```

### ✅ Step Analytics Response
```
**30-Day Activity Pattern Analysis**

🎯 **Key Insights:**
- Most Active Day of Week: [Day] ([X] avg steps)
- Least Active Day of Week: [Day] ([Y] avg steps)

📊 **30-Day Highlights:**
- Highest Step Day: 2025-08-XX ([X] steps)
- Lowest Step Day: 2025-08-XX ([Y] steps)
- Daily Average: [X] steps
```

## 🔍 Troubleshooting

### If MCP Connection Fails:
- ✅ Verify the MCP endpoint URL
- ✅ Check that MCP secret matches: `mcp-secret-2024-simple-step`
- ✅ Ensure health_data table exists with test data

### If No Step Data Found:
- ✅ Confirm you ran the setup_health_data.sql script
- ✅ Check that test data was inserted for user 'test-user-123'

### If Flutter App Won't Load:
- ✅ Try refreshing http://localhost:3000
- ✅ Check if Chrome is blocking the localhost connection
- ✅ Try running on a different device: `flutter run -d edge`

## 🚀 Next Steps After Testing

Once everything works:

1. **OpenAI Integration**: Test with real OpenAI function calling
2. **Real Health Data**: Connect to actual Health Connect data
3. **Custom Analytics**: Add more sophisticated step analysis
4. **Production Deploy**: Move to production Supabase environment

## 📞 Current Configuration

- **Project**: YOUR-PROJECT-ID
- **MCP Endpoint**: /functions/v1/mcp-server
- **Test User**: test-user-123
- **Date Range**: July 21 - August 20, 2025
- **Sample Data**: ~30 days of realistic step counts

---

🎉 **Your MCP server is fully functional and ready for testing!**
