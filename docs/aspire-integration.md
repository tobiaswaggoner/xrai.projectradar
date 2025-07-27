# .NET Aspire Integration

This document describes the .NET Aspire integration for Project Radar, which provides orchestration, service discovery, and observability for the development environment.

## Overview

.NET Aspire provides:
- **Service Orchestration**: Manages PostgreSQL, RabbitMQ, and the backend API as a cohesive unit
- **Service Discovery**: Automatic connection string management and service endpoint resolution
- **Observability**: Built-in OpenTelemetry integration with traces, metrics, and logs
- **Development Dashboard**: Unified view of all services, logs, and metrics
- **Live Reload**: Automatic service restart on code changes

## Architecture

The Aspire AppHost project (`xrai.projectradar.apphost`) orchestrates:
- PostgreSQL database with persistent volume
- RabbitMQ message broker with management plugin
- Backend API with health checks and OpenTelemetry

## Running with Aspire

### Quick Start
```bash
# Run Aspire with all services
cd scripts
./aspire-dev.sh
```

### Manual Start
```bash
cd src/xrai.projectradar.application/xrai.projectradar.apphost
dotnet run
```

### Stop Docker Services First
If you want to stop existing Docker Compose services:
```bash
./aspire-dev.sh --no-docker
```

## Aspire Dashboard

When running, the Aspire dashboard is available at:
- URL: https://localhost:17141
- Features:
  - Service health monitoring
  - Real-time logs from all services
  - Distributed traces (OpenTelemetry)
  - Metrics visualization
  - Service dependency graph

## Service Discovery

The backend automatically discovers services through Aspire:
- PostgreSQL connection: `projectradar` (resolved via service discovery)
- RabbitMQ connection: `rabbitmq` (resolved via service discovery)

No manual connection string configuration needed!

## Health Checks

Health check endpoints:
- `/health` - Basic health check
- `/alive` - Liveness probe

## OpenTelemetry Integration

The backend exports:
- **Traces**: HTTP requests, database queries, message bus operations
- **Metrics**: Request duration, throughput, error rates
- **Logs**: Structured logging with correlation IDs

All telemetry data is visible in the Aspire dashboard.

## Development Workflow

1. **Start Infrastructure**: Run `./scripts/dev-setup.sh` to create secrets and start Docker services
2. **Run with Aspire**: Use `./scripts/aspire-dev.sh` for full orchestration
3. **Make Changes**: Edit code - services auto-reload
4. **View Logs**: Check the Aspire dashboard for logs and traces
5. **Debug**: Use Visual Studio or VS Code with Aspire integration

## Configuration

Aspire automatically configures:
- PostgreSQL connection with credentials from Docker secrets
- RabbitMQ connection with management plugin
- OpenTelemetry OTLP endpoint for telemetry export
- Service discovery for HTTP clients

## Troubleshooting

### Aspire Won't Start
- Ensure .NET 8 SDK is installed: `dotnet --version`
- Check if ports are available: 17141 (dashboard), 5432 (PostgreSQL), 5672/15672 (RabbitMQ)

### Services Not Discovered
- Verify Docker services are running: `docker ps`
- Check Aspire dashboard for service status
- Review logs in the dashboard for connection errors

### No Telemetry Data
- Ensure backend is running and healthy
- Check OTLP endpoint configuration in dashboard
- Verify OpenTelemetry packages are installed

## Benefits

1. **Simplified Development**: One command starts everything
2. **Better Debugging**: Integrated logs and traces
3. **Realistic Environment**: Service discovery mimics production
4. **Fast Feedback**: Live reload on code changes
5. **Observability**: Built-in monitoring without external tools