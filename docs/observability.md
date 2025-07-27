# Observability Stack Documentation

## Overview

Project Radar includes a comprehensive observability stack based on OpenTelemetry, Prometheus, Tempo, and Grafana. This provides distributed tracing, metrics collection, and visualization capabilities for monitoring application performance and behavior.

## Components

### 1. OpenTelemetry Instrumentation
- **Traces**: Distributed tracing for all HTTP requests, database calls, and custom operations
- **Metrics**: Runtime metrics, HTTP metrics, and custom business metrics
- **Logs**: Structured logging with Serilog correlated to traces via OTLP

### 2. Grafana Stack
- **Prometheus**: Metrics storage and querying (port 9090)
- **Tempo**: Distributed trace storage and querying (ports 3200, 4317, 4318)
- **Grafana**: Visualization dashboards (port 3000)

## Getting Started

### Starting the Observability Stack

```bash
# Start all services including observability
./scripts/dev-setup.sh

# Or if services are already running
docker-compose up -d
```

### Accessing Dashboards

```bash
# Display all observability URLs
./scripts/observability-urls.sh

# Open Grafana in browser
./scripts/observability-urls.sh --open
```

### URLs
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Tempo**: http://localhost:3200
- **OTLP Endpoints**:
  - gRPC: localhost:4317
  - HTTP: localhost:4318

## Pre-configured Dashboards

### ASP.NET Core Performance
- Request rate by endpoint
- Error rate gauge
- Request duration percentiles (p50, p95)
- CPU usage over time

### System Metrics
- GC heap size by generation
- GC collection rates
- Thread pool metrics
- Memory allocation rates

## Custom Telemetry

### Adding Custom Traces
```csharp
using var activity = TelemetryConstants.ActivitySource.StartActivity("MyOperation");
activity?.SetTag("custom.tag", "value");
// Your operation here
```

### Adding Custom Metrics
```csharp
TelemetryConstants.OpportunityCreatedCounter.Add(1, 
    new KeyValuePair<string, object?>("status", "success"));
```

### Structured Logging
```csharp
Log.Information("Operation completed {@Data}", new { Id = 123, Status = "Success" });
```

## Integration with Aspire

When running with .NET Aspire (`dotnet run` from AppHost), traces and metrics are sent to both:
1. The Aspire dashboard (integrated development experience)
2. The Grafana stack (production-like monitoring)

This dual export allows developers to use Aspire's integrated debugging while also testing production monitoring workflows.

## Troubleshooting

### No Data in Grafana
1. Ensure all services are healthy: `docker-compose ps`
2. Check OTLP endpoint is accessible: `curl http://localhost:4318/v1/traces`
3. Verify backend is running and sending data

### Missing Metrics
1. Check Prometheus targets: http://localhost:9090/targets
2. Ensure backend metrics endpoint is accessible: http://localhost:5000/metrics
3. Verify Prometheus can reach the backend service

### Trace Correlation Issues
1. Ensure correlation IDs are being propagated via `X-Correlation-Id` header
2. Check Serilog enrichers are configured correctly
3. Verify OTLP exporter includes trace context fields

## Performance Considerations

- Sampling is currently set to 100% for development
- Consider implementing head-based sampling for production
- Monitor Tempo storage usage and implement retention policies as needed
- Prometheus retention is configured for local development (not production)