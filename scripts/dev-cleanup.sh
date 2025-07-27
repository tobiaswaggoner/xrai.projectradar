#!/bin/bash

# Development environment cleanup script for Project Radar
# This script stops services, removes containers, and optionally cleans up data

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

# Show usage
show_usage() {
    echo "Project Radar Development Environment Cleanup"
    echo "============================================"
    echo ""
    echo "This script cleans up the development environment."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --full, -f     Full cleanup including volumes and secrets"
    echo "  --volumes, -v  Remove Docker volumes (data will be lost)"
    echo "  --secrets, -s  Remove Docker secrets"
    echo "  --help, -h     Show this help message"
    echo ""
    echo "Default behavior:"
    echo "  - Stop and remove containers"
    echo "  - Remove networks"
    echo "  - Keep volumes and data intact"
    echo "  - Keep secrets intact"
    echo ""
}

# Stop and remove containers
cleanup_containers() {
    log_step "Stopping and removing containers..."
    
    cd "$PROJECT_ROOT"
    
    # Use docker-compose or docker compose depending on availability
    if command -v docker-compose &> /dev/null; then
        docker-compose down
    else
        docker compose down
    fi
    
    log_info "Containers stopped and removed"
}

# Remove volumes
cleanup_volumes() {
    log_step "Removing Docker volumes (data will be lost)..."
    
    # Remove project-specific volumes
    docker volume rm xraiprojectradar_postgres_data 2>/dev/null || log_warn "postgres_data volume not found"
    docker volume rm xraiprojectradar_rabbitmq_data 2>/dev/null || log_warn "rabbitmq_data volume not found"
    
    log_info "Volumes removed"
}

# Remove Docker secrets
cleanup_docker_secrets() {
    log_step "Removing Docker secrets..."
    
    # Remove secrets (ignore errors if they don't exist)
    docker secret rm postgres_user 2>/dev/null || log_warn "postgres_user secret not found"
    docker secret rm postgres_password 2>/dev/null || log_warn "postgres_password secret not found"
    
    log_info "Docker secrets removed"
}

# Remove local dev secrets
cleanup_local_secrets() {
    log_step "Removing local development secrets..."
    
    local dev_secrets_dir="$PROJECT_ROOT/dev-secrets"
    
    if [[ -d "$dev_secrets_dir" ]]; then
        rm -rf "$dev_secrets_dir"/*
        log_info "Local secrets removed (directory kept)"
    else
        log_warn "No local secrets directory found"
    fi
}

# Clean up dangling Docker resources
cleanup_docker_system() {
    log_step "Cleaning up dangling Docker resources..."
    
    docker system prune -f --volumes=false
    
    log_info "Docker system cleaned"
}

# Main cleanup function
main() {
    local full_cleanup=false
    local cleanup_volumes=false
    local cleanup_secrets=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --full|-f)
                full_cleanup=true
                cleanup_volumes=true
                cleanup_secrets=true
                shift
                ;;
            --volumes|-v)
                cleanup_volumes=true
                shift
                ;;
            --secrets|-s)
                cleanup_secrets=true
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
    
    log_info "Starting Project Radar development environment cleanup..."
    
    if [[ "$full_cleanup" == true ]]; then
        log_warn "Performing FULL cleanup - all data and secrets will be removed!"
        echo -n "Are you sure? (type 'yes' to continue): "
        read -r confirmation
        if [[ "$confirmation" != "yes" ]]; then
            log_info "Cleanup cancelled"
            exit 0
        fi
    fi
    
    # Always clean up containers
    cleanup_containers
    
    # Conditional cleanup based on flags
    if [[ "$cleanup_volumes" == true ]]; then
        cleanup_volumes
    fi
    
    if [[ "$cleanup_secrets" == true ]]; then
        cleanup_docker_secrets
        cleanup_local_secrets
    fi
    
    # Always clean up system resources
    cleanup_docker_system
    
    log_info "Cleanup completed successfully!"
    
    if [[ "$cleanup_volumes" == false ]]; then
        log_info "Data volumes were preserved. Use --volumes to remove them."
    fi
    
    if [[ "$cleanup_secrets" == false ]]; then
        log_info "Secrets were preserved. Use --secrets to remove them."
    fi
    
    echo ""
    log_info "To restart the environment: ./scripts/dev-setup.sh"
}

# Run main function with all arguments
main "$@"