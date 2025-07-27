# Next Step: Iteration 3 - Aspire Development Host Integration

## Detailed Implementation Plan

### 1. Configure Aspire AppHost Project Structure

#### 1.1 Update Aspire AppHost Dependencies
- [ ] Add necessary NuGet packages for PostgreSQL and RabbitMQ integration to AppHost project
- [ ] Add Aspire.Hosting.PostgreSQL package for PostgreSQL orchestration
- [ ] Add Aspire.Hosting.RabbitMQ package for RabbitMQ orchestration  
- [ ] Update project references and ensure compatibility with existing infrastructure

#### 1.2 Configure Service Discovery Infrastructure
- [ ] Set up Aspire service discovery for backend API project
- [ ] Configure connection strings and service endpoints through Aspire configuration
- [ ] Implement service registration for PostgreSQL and RabbitMQ resources
- [ ] Set up proper service naming conventions for internal communication

### 2. Integrate Existing Docker Infrastructure

#### 2.1 Bridge Docker and Aspire Configuration
- [ ] Configure Aspire to work with existing docker-compose.yml services
- [ ] Map Docker secrets to Aspire configuration system
- [ ] Ensure PostgreSQL connection uses same credentials as Docker setup
- [ ] Integrate RabbitMQ configuration with Aspire service discovery

#### 2.2 Update Backend Project for Aspire Integration
- [ ] Add Aspire.ServiceDefaults package to backend project
- [ ] Configure backend project to use Aspire service discovery
- [ ] Update connection strings to use Aspire configuration
- [ ] Add health check endpoints for Aspire dashboard monitoring

### 3. Configure Live-Reload Development Workflow

#### 3.1 Set Up Hot Reload Capabilities
- [ ] Configure backend project for live-reload during development
- [ ] Set up file watching for automatic service restart on code changes
- [ ] Configure Aspire to properly handle service restarts without losing state
- [ ] Test hot reload functionality with simple code changes

#### 3.2 Integrate Development Scripts
- [ ] Update existing dev-setup.sh script to work with Aspire
- [ ] Create aspire-dev.sh script for Aspire-specific development tasks
- [ ] Ensure Docker infrastructure can run alongside Aspire when needed
- [ ] Document the combined workflow options (Docker-only vs Aspire)

### 4. Configure Aspire Dashboard and Monitoring

#### 4.1 Set Up Service Health Monitoring
- [ ] Configure health checks for all services in Aspire dashboard
- [ ] Add service status indicators for PostgreSQL and RabbitMQ
- [ ] Set up logging aggregation through Aspire dashboard
- [ ] Configure service dependency visualization

#### 4.2 Dashboard Configuration and Access
- [ ] Ensure Aspire dashboard is accessible at default port
- [ ] Configure dashboard to show service logs and metrics
- [ ] Set up service restart capabilities through dashboard
- [ ] Test dashboard functionality and service management features

### 5. Testing and Integration Verification

#### 5.1 End-to-End Aspire Startup Testing
- [ ] Test complete service startup with `dotnet aspire run`
- [ ] Verify all services start in correct order with proper dependencies
- [ ] Test service discovery between backend and infrastructure services
- [ ] Verify configuration injection and connection string resolution

#### 5.2 Development Workflow Validation
- [ ] Test hot reload functionality with backend code changes
- [ ] Verify service restart capabilities without data loss
- [ ] Test debugging workflow with Aspire integration
- [ ] Validate that existing Docker infrastructure remains functional

### 6. Create Unit Tests for Aspire Configuration

#### 6.1 Test Service Discovery Configuration
- [ ] Create unit tests for Aspire service registration
- [ ] Test connection string resolution and configuration injection
- [ ] Verify service dependency configuration is correct
- [ ] Test error handling for missing or misconfigured services

#### 6.2 Integration Tests for Development Workflow  
- [ ] Create integration tests that verify Aspire service startup
- [ ] Test service communication through Aspire service discovery
- [ ] Verify health check endpoints function correctly
- [ ] Test live-reload scenarios with service dependencies

## Expected Outcomes

- Complete .NET Aspire integration with existing Docker infrastructure
- Seamless developer experience with `dotnet aspire run` command
- Live-reload capability for rapid development iteration
- Integrated dashboard for service monitoring and management
- Service discovery and configuration management through Aspire
- Maintained compatibility with existing Docker-based development workflow

## Next Iteration Preview

The next iteration (Iteration 4) will focus on Observability Stack implementation:
- Adding OpenTelemetry instrumentation to backend services (OTEL 1.7)
- Setting up Grafana stack with Prometheus + Tempo + Grafana OSS
- Configuring OTLP exporters for traces and metrics
- Setting up optional ELK stack for logging (disabled by default)
- Creating comprehensive monitoring dashboards

## Prerequisites

- Completed Iteration 1 (Solution Structure & Project Setup)  
- Completed Iteration 2 (Infrastructure & Docker Setup)
- .NET 8 SDK and Aspire workload installed
- Docker and Docker Compose functional
- Existing PostgreSQL and RabbitMQ services running via docker-compose

## Success Criteria

- [ ] `dotnet aspire run` starts all services successfully including backend, PostgreSQL, and RabbitMQ
- [ ] Aspire dashboard is accessible and shows all service health status
- [ ] Backend service can connect to PostgreSQL and RabbitMQ through Aspire service discovery
- [ ] Live-reload works for backend code changes without manual restarts
- [ ] Service logs are visible in Aspire dashboard
- [ ] All unit and integration tests pass
- [ ] Existing Docker infrastructure continues to work independently
- [ ] Service dependencies are properly configured and visualized in dashboard