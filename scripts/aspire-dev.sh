#!/bin/bash

# Aspire development environment runner for Project Radar
# This script starts the application with .NET Aspire orchestration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APPHOST_DIR="$PROJECT_ROOT/src/xrai.projectradar.application/xrai.projectradar.apphost"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check if .NET SDK is installed
    if ! command -v dotnet &> /dev/null; then
        log_error ".NET SDK is not installed. Please install .NET 8 SDK or later."
        exit 1
    fi
    
    local dotnet_version=$(dotnet --version)
    log_info ".NET SDK version: $dotnet_version"
    
    # Check if the AppHost project exists
    if [ ! -f "$APPHOST_DIR/xrai.projectradar.apphost.csproj" ]; then
        log_error "AppHost project not found at $APPHOST_DIR"
        exit 1
    fi
    
    # Check if development secrets exist
    local dev_secrets_dir="$PROJECT_ROOT/dev-secrets"
    if [ ! -f "$dev_secrets_dir/postgres_user" ] || [ ! -f "$dev_secrets_dir/postgres_password" ] || [ ! -f "$dev_secrets_dir/rabbitmq.conf" ]; then
        log_warn "Development secrets not found. Running setup script..."
        "$SCRIPT_DIR/dev-setup.sh"
    fi
    
    log_info "Prerequisites check passed"
}

# Stop running services if requested
stop_services() {
    log_step "Stopping existing services..."
    
    cd "$PROJECT_ROOT"
    
    # Stop Docker Compose services if running
    if command -v docker-compose &> /dev/null; then
        docker-compose down 2>/dev/null || true
    else
        docker compose down 2>/dev/null || true
    fi
    
    log_info "Services stopped"
}

# Start Aspire
start_aspire() {
    log_step "Starting Aspire orchestration..."
    
    cd "$APPHOST_DIR"
    
    # Set environment variables for Aspire
    export DOTNET_ENVIRONMENT="Development"
    
    # Pass PostgreSQL credentials from secrets
    if [ -f "$PROJECT_ROOT/dev-secrets/postgres_user" ]; then
        export POSTGRES_USER=$(cat "$PROJECT_ROOT/dev-secrets/postgres_user")
    fi
    
    if [ -f "$PROJECT_ROOT/dev-secrets/postgres_password" ]; then
        export POSTGRES_PASSWORD=$(cat "$PROJECT_ROOT/dev-secrets/postgres_password")
    fi
    
    # Extract RabbitMQ credentials from config
    if [ -f "$PROJECT_ROOT/dev-secrets/rabbitmq.conf" ]; then
        export RABBITMQ_USER=$(grep "default_user" "$PROJECT_ROOT/dev-secrets/rabbitmq.conf" | cut -d'=' -f2 | tr -d ' ')
        export RABBITMQ_PASSWORD=$(grep "default_pass" "$PROJECT_ROOT/dev-secrets/rabbitmq.conf" | cut -d'=' -f2 | tr -d ' ')
    fi
    
    log_info "Starting Aspire dashboard and services..."
    log_info "The Aspire dashboard will open in your browser automatically"
    log_info "Press Ctrl+C to stop all services"
    echo ""
    
    # Run Aspire
    dotnet run
}

# Show usage
show_usage() {
    echo "Project Radar Aspire Development Runner"
    echo "======================================"
    echo ""
    echo "This script starts the Project Radar application using .NET Aspire orchestration."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --no-docker    Stop existing Docker Compose services before starting Aspire"
    echo "  --help, -h     Show this help message"
    echo ""
    echo "Features:"
    echo "  - Automatic service orchestration (PostgreSQL, RabbitMQ, Backend)"
    echo "  - Integrated dashboard with logging and metrics"
    echo "  - OpenTelemetry tracing and metrics"
    echo "  - Live reload for development"
    echo "  - Service health monitoring"
    echo ""
    echo "Requirements:"
    echo "  - .NET 8 SDK or later"
    echo "  - Development secrets (created by dev-setup.sh if missing)"
    echo ""
}

# Main execution
main() {
    local stop_docker=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-docker)
                stop_docker=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log_info "Starting Project Radar with Aspire orchestration..."
    
    check_prerequisites
    
    if [ "$stop_docker" = true ]; then
        stop_services
    fi
    
    start_aspire
}

# Handle script interruption
trap 'echo -e "\n${YELLOW}[INFO]${NC} Aspire shutdown requested. Stopping services..."; exit 0' INT TERM

# Run main function
main "$@"