# Next Step: Iteration 2 - Infrastructure & Docker Setup

## Detailed Implementation Plan

### 1. Create Main Docker Compose Configuration

#### 1.1 Create Primary docker-compose.yml
- [ ] Create docker-compose.yml in project root directory
- [ ] Configure PostgreSQL service with proper version and configuration
- [ ] Configure RabbitMQ service with management plugin enabled
- [ ] Set up service networking and port mappings
- [ ] Configure volume mounts for data persistence

#### 1.2 Configure Service Dependencies
- [ ] Define service startup order and dependencies
- [ ] Configure health checks for PostgreSQL and RabbitMQ
- [ ] Set up proper service discovery between containers
- [ ] Configure restart policies for production readiness

### 2. Implement Docker Secrets Management

#### 2.1 Create Secrets Infrastructure
- [ ] Create ./dev-secrets/ directory structure for local development
- [ ] Define secrets for PostgreSQL (POSTGRES_PASSWORD, POSTGRES_USER)
- [ ] Define secrets for RabbitMQ (RABBITMQ_DEFAULT_USER, RABBITMQ_DEFAULT_PASS)
- [ ] Plan for future Auth0 and LLM API key secrets

#### 2.2 Configure Docker Secrets in Compose
- [ ] Update docker-compose.yml to use Docker Secrets syntax
- [ ] Configure PostgreSQL to consume secrets for authentication
- [ ] Configure RabbitMQ to consume secrets for user creation
- [ ] Set up proper file permissions and security for secrets

### 3. Create Development Helper Scripts

#### 3.1 Create Secret Management Script
- [ ] Create ./scripts/ directory structure
- [ ] Implement ./scripts/create-secret.sh script for generating secrets
- [ ] Add functionality to generate secure random passwords
- [ ] Include validation and error handling for secret creation
- [ ] Document script usage and parameters

#### 3.2 Create Development Utilities
- [ ] Create ./scripts/dev-setup.sh for complete environment setup
- [ ] Add database initialization scripts if needed
- [ ] Create cleanup scripts for development environment reset
- [ ] Add logging and status reporting to all scripts

### 4. Configure Local Development Overrides

#### 4.1 Create docker-compose.override.yml
- [ ] Create override file for local development customizations
- [ ] Configure secrets mounting from ./dev-secrets/* directory
- [ ] Set up development-specific environment variables
- [ ] Configure port mappings for local access (PostgreSQL: 5432, RabbitMQ: 5672, 15672)

#### 4.2 Configure Development Networking
- [ ] Set up Docker network for service communication
- [ ] Configure proper DNS resolution between services
- [ ] Ensure services are accessible from host for debugging
- [ ] Set up proper isolation and security boundaries

### 7. Integration Testing and Verification

#### 7.1 Infrastructure Startup Testing
- [ ] Test complete infrastructure startup with `docker-compose up`
- [ ] Verify PostgreSQL service starts and accepts connections
- [ ] Verify RabbitMQ service starts and management UI is accessible
- [ ] Test service discovery and inter-service communication

#### 7.2 Connectivity and Health Verification
- [ ] Test database connectivity from host system
- [ ] Test RabbitMQ management and messaging functionality
- [ ] Verify secrets are properly mounted and accessible
- [ ] Test infrastructure restart and recovery scenarios


## Expected Outcomes

- Complete containerized development environment with PostgreSQL and RabbitMQ
- Secure secrets management system using Docker Secrets and config file for RabbitMQ
- Helper scripts for easy local development setup
- Production-ready infrastructure configuration with proper health checks
- Verified connectivity between all infrastructure services
- Documentation of setup procedures and troubleshooting

## Next Iteration Preview

The next iteration (Iteration 3) will focus on Aspire Development Host Integration, including:
- Configuring Aspire AppHost to orchestrate all services (backend, PostgreSQL, RabbitMQ)
- Setting up service discovery and configuration management through Aspire
- Configuring live-reload for development workflow
- Integrating with existing Docker infrastructure for seamless development

## Prerequisites

- Docker and Docker Compose installed
- .NET 8 solution structure from Iteration 1 completed
- Basic understanding of containerization and Docker networking
- Git repository with proper directory structure

## Success Criteria

- [ ] `docker-compose up` starts all infrastructure services successfully
- [ ] PostgreSQL is accessible at localhost:5432 with proper authentication
- [ ] RabbitMQ is accessible at localhost:5672 and management UI at localhost:15672
- [ ] All secrets are properly configured and mounted via Docker Secrets
- [ ] Helper scripts work correctly for development setup
- [ ] Services can communicate with each other via Docker networking
- [ ] Infrastructure can be completely reset and restarted without issues
- [ ] No sensitive information is stored in plain text or committed to repository