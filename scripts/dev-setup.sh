#!/bin/bash

# Complete development environment setup for Project Radar
# This script creates all necessary secrets and sets up the development environment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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
    
    # Check if Docker is installed and running
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker Desktop or Docker Engine."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker is not running. Please start Docker."
        exit 1
    fi
    
    # Check if docker-compose is available
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Create all required secrets
create_secrets() {
    log_step "Creating development secrets..."
    
    local create_secret_script="$SCRIPT_DIR/create-secret.sh"
    
    # Create PostgreSQL secrets
    "$create_secret_script" postgres_user "projectradar_user"
    "$create_secret_script" postgres_password
    
    # Create RabbitMQ configuration
    "$create_secret_script" rabbitmq_config "projectradar_user"
    
    log_info "All secrets created successfully"
}

# Create Docker secrets from files
setup_docker_secrets() {
    log_step "Setting up Docker secrets..."
    
    local dev_secrets_dir="$PROJECT_ROOT/dev-secrets"
    
    # Remove existing secrets (ignore errors if they don't exist)
    docker secret rm postgres_user postgres_password 2>/dev/null || true
    
    # Create Docker secrets from files
    docker secret create postgres_user "$dev_secrets_dir/postgres_user"
    docker secret create postgres_password "$dev_secrets_dir/postgres_password"
    
    log_info "Docker secrets created successfully"
}

# Start the infrastructure
start_infrastructure() {
    log_step "Starting infrastructure services..."
    
    cd "$PROJECT_ROOT"
    
    # Use docker-compose or docker compose depending on availability
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    log_info "Infrastructure services started"
}

# Wait for services to be healthy
wait_for_services() {
    log_step "Waiting for services to be healthy..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Health check attempt $attempt/$max_attempts..."
        
        # Check PostgreSQL health
        if docker exec projectradar-postgres pg_isready -U projectradar_user -d projectradar &> /dev/null; then
            postgres_healthy=true
        else
            postgres_healthy=false
        fi
        
        # Check RabbitMQ health
        if docker exec projectradar-rabbitmq rabbitmq-diagnostics ping &> /dev/null; then
            rabbitmq_healthy=true
        else
            rabbitmq_healthy=false
        fi
        
        if [ "$postgres_healthy" = true ] && [ "$rabbitmq_healthy" = true ]; then
            log_info "All services are healthy!"
            return 0
        fi
        
        if [ "$postgres_healthy" = false ]; then
            log_warn "PostgreSQL is not ready yet..."
        fi
        
        if [ "$rabbitmq_healthy" = false ]; then
            log_warn "RabbitMQ is not ready yet..."
        fi
        
        sleep 5
        ((attempt++))
    done
    
    log_error "Services failed to become healthy within the timeout period"
    return 1
}

# Show service information
show_service_info() {
    log_step "Development environment is ready!"
    
    echo ""
    echo "Service Access Information:"
    echo "=========================="
    echo "PostgreSQL:"
    echo "  Host: localhost"
    echo "  Port: 5432"
    echo "  Database: projectradar"
    echo "  Username: projectradar_user"
    echo "  Password: (stored in dev-secrets/postgres_password)"
    echo ""
    echo "RabbitMQ:"
    echo "  AMQP: localhost:15671"
    echo "  Management UI: http://localhost:15673"
    echo "  Username: projectradar_user"
    echo "  Password: (stored in dev-secrets/rabbitmq.conf)"
    echo ""
    echo "To stop the services: docker-compose down"
    echo "To view logs: docker-compose logs -f"
    echo "To restart: docker-compose restart"
    echo ""
}

# Main execution
main() {
    log_info "Starting Project Radar development environment setup..."
    
    check_prerequisites
    create_secrets
    setup_docker_secrets
    start_infrastructure
    
    if wait_for_services; then
        show_service_info
        log_info "Setup completed successfully!"
    else
        log_error "Setup failed - some services are not healthy"
        exit 1
    fi
}

# Show usage if help is requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Project Radar Development Environment Setup"
    echo "==========================================="
    echo ""
    echo "This script sets up the complete development environment for Project Radar."
    echo "It will:"
    echo "  1. Check prerequisites (Docker installation and status)"
    echo "  2. Create all required secrets for local development"
    echo "  3. Set up Docker secrets"
    echo "  4. Start PostgreSQL and RabbitMQ services"
    echo "  5. Wait for services to become healthy"
    echo "  6. Display connection information"
    echo ""
    echo "Usage: $0 [--help|-h]"
    echo ""
    echo "Prerequisites:"
    echo "  - Docker Desktop or Docker Engine must be installed and running"
    echo "  - Docker Compose must be available"
    echo ""
    exit 0
fi

# Run main function
main