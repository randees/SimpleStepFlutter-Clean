# Test Scripts

This directory contains shell scripts for testing MCP server functionality and database connectivity.

## Scripts:

### `test_mcp_server.sh`
Tests the MCP server endpoints including:
- Server initialization
- Tools list retrieval
- Step analytics queries
- Activity pattern analysis

### `test_health_data.sh`
Tests health data endpoints and database connectivity:
- User data retrieval
- Health data queries
- Database performance

## Usage

Make scripts executable and run from project root:
```bash
chmod +x test/scripts/*.sh
./test/scripts/test_mcp_server.sh
./test/scripts/test_health_data.sh
```

## Requirements

- curl (for HTTP requests)
- jq (for JSON processing, optional but recommended)
- Valid Supabase configuration
- MCP server running (for MCP tests)