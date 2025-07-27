#!/bin/bash

# Helper script to display observability URLs and open them in browser

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine the platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OPEN_CMD="xdg-open"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OPEN_CMD="open"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OPEN_CMD="start"
else
    OPEN_CMD=""
fi

echo -e "${BLUE}Project Radar Observability Dashboard URLs${NC}"
echo "=========================================="
echo ""
echo -e "${GREEN}Grafana Dashboard:${NC}"
echo "  URL: http://localhost:3000"
echo "  Username: admin"
echo "  Password: admin"
echo "  Dashboards:"
echo "    - ASP.NET Core Performance"
echo "    - System Metrics"
echo ""
echo -e "${GREEN}Prometheus Metrics Explorer:${NC}"
echo "  URL: http://localhost:9090"
echo "  Query examples:"
echo "    - http_server_request_duration_seconds_count"
echo "    - process_runtime_dotnet_gc_heap_size_bytes"
echo ""
echo -e "${GREEN}Tempo Trace Explorer:${NC}"
echo "  URL: http://localhost:3200"
echo "  Access traces through Grafana for best experience"
echo ""
echo -e "${GREEN}Application Endpoints:${NC}"
echo "  Backend Health: http://localhost:5000/health"
echo "  Backend Metrics: http://localhost:5000/metrics"
echo "  Backend Swagger: http://localhost:5000/swagger"
echo ""

# If requested, open URLs
if [[ "${1:-}" == "--open" ]] || [[ "${1:-}" == "-o" ]]; then
    if [ -n "$OPEN_CMD" ]; then
        echo "Opening Grafana dashboard in browser..."
        $OPEN_CMD "http://localhost:3000" 2>/dev/null || echo "Failed to open browser automatically"
    else
        echo "Could not determine how to open browser on this platform"
    fi
fi

echo "Usage: $0 [--open|-o] to open Grafana in browser"