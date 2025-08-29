# Test Fixtures

This directory contains JSON configuration files and test data used by the test scripts.

## Files:

### MCP Test Fixtures
- `test_initialize.json` - MCP server initialization test data
- `test_tools_list.json` - Available tools list test data  
- `test_activity_patterns.json` - Activity patterns test data
- `test_date_range.json` - Date range query test data
- `test_with_existing_data.json` - Test with existing user data
- `mcp-config.json` - MCP server configuration for testing

## Usage

These fixtures are used by the test scripts in `../scripts/` to verify MCP server functionality and database connectivity.

To run tests using these fixtures:
```bash
cd ../../
./test/scripts/test_mcp_server.sh
./test/scripts/test_health_data.sh
```