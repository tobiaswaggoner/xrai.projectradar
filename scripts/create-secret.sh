#!/bin/bash

# Create Docker secrets for local development
# Usage: ./scripts/create-secret.sh [secret_name] [value]
# If no value is provided, a secure random password will be generated

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_SECRETS_DIR="$PROJECT_ROOT/dev-secrets"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

generate_password() {
    # Generate a secure random password (32 characters, alphanumeric)
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
}

create_rabbitmq_config() {
    local username="${1:-projectradar_user}"
    local password="${2:-}"
    
    if [[ -z "$password" ]]; then
        password=$(generate_password)
        log_info "Generated secure random password for RabbitMQ"
    fi
    
    local config_file="$DEV_SECRETS_DIR/rabbitmq.conf"
    
    # Check if config already exists
    if [[ -f "$config_file" ]]; then
        log_warn "RabbitMQ config already exists at $config_file"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping RabbitMQ config creation"
            return 0
        fi
    fi
    
    # Create the RabbitMQ configuration file
    cat > "$config_file" << EOF
# RabbitMQ configuration for Project Radar
# Sets the default user and password.
# These are only used when the database is first created.
default_user = $username
default_pass = $password
EOF
    
    chmod 600 "$config_file"
    
    log_info "Created RabbitMQ config at $config_file"
    log_info "Username: $username"
    log_info "Password: $password"
}

create_secret() {
    local secret_name="$1"
    local secret_value="${2:-}"
    
    if [[ -z "$secret_name" ]]; then
        log_error "Secret name is required"
        exit 1
    fi
    
    local secret_file="$DEV_SECRETS_DIR/$secret_name"
    
    # Check if secret already exists
    if [[ -f "$secret_file" ]]; then
        log_warn "Secret '$secret_name' already exists at $secret_file"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping secret creation"
            return 0
        fi
    fi
    
    # Generate password if not provided
    if [[ -z "$secret_value" ]]; then
        secret_value=$(generate_password)
        log_info "Generated secure random password for '$secret_name'"
    fi
    
    # Create the secret file
    echo -n "$secret_value" > "$secret_file"
    chmod 600 "$secret_file"
    
    log_info "Created secret '$secret_name' at $secret_file"
}

# Show usage if no arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <secret_name> [secret_value]"
    echo ""
    echo "Creates a Docker secret file for local development."
    echo "If secret_value is not provided, a secure random password will be generated."
    echo ""
    echo "Examples:"
    echo "  $0 postgres_password                    # Generate random password"
    echo "  $0 postgres_user projectradar_user     # Use specific value"
    echo "  $0 rabbitmq_config                     # Generate RabbitMQ config file"
    echo "  $0 rabbitmq_config user pass           # Create config with specific credentials"
    echo ""
    echo "Available secrets for this project:"
    echo "  - postgres_user"
    echo "  - postgres_password"
    echo "  - rabbitmq_config        # Creates rabbitmq.conf with user and password"
    exit 1
fi

# Ensure secrets directory exists
mkdir -p "$DEV_SECRETS_DIR"

# Handle special case for RabbitMQ config
if [[ "$1" == "rabbitmq_config" ]]; then
    create_rabbitmq_config "${2:-}" "${3:-}"
else
    # Create the secret
    create_secret "$1" "${2:-}"
fi

log_info "Secret creation completed successfully!"