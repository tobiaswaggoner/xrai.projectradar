# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Project Radar** is a specialized platform for capturing, evaluating, and tracking project opportunities for freelancers and contractors. The system automates project collection and analysis using an AI-powered pipeline, presenting opportunities in an interactive Kanban-style interface.

## Architecture

This is a **reactive, message-driven microservice architecture** built on:

- **Event Sourcing (ES)** and **Command Query Responsibility Segregation (CQRS)**
- **Custom Event Store** following "Aggregateless Event Sourcing" with "Command Context Consistency"
- **Asynchronous communication** via RabbitMQ message bus
- **PostgreSQL** for both event store and read models

### Technology Stack

- **Backend**: .NET 8 microservices
- **Frontend**: Blazor WebAssembly (prototyping with Next.js initially)
- **Message Bus**: RabbitMQ
- **Database**: PostgreSQL
- **Containerization**: Docker with Docker Compose orchestration
- **Development**: dotnet Aspire for local development
- **Authentication**: OAuth 2.0/OIDC via Auth0
- **Observability**: OpenTelemetry, Serilog, Grafana stack (Prometheus + Tempo)

## System Components

### Main Logical Parts
1. **Ingestion Pipeline**: Backend services processing raw opportunity data into structured information
2. **Interactive Component**: Blazor WebAssembly frontend + backend services for user interactions

### Core Services (Planned)
- **API Gateway**: HTTP endpoints for Blazor client, publishes commands to message bus
- **DataExtractionService**: LLM-based extraction of structured data from raw text
- **WeightingService**: AI scoring against user profile
- **DeduplicationService**: Hash-based duplicate detection
- **Projector Services**: Build read models from events for fast queries

## Development Setup

The project now has a complete development environment with dual workflow options:

- **Build**: `dotnet build` (from solution root: `src/xrai.projectradar.application/`)
- **Test**: `dotnet test` (runs all NUnit tests with NSubstitute mocking)
- **Aspire Development**: `dotnet run` from AppHost project - starts all services with live-reload, integrated dashboard, and telemetry
- **Docker Compose**: `docker-compose up` - standalone infrastructure services (PostgreSQL, RabbitMQ)
- **Secrets Management**: Docker Secrets for PostgreSQL, configuration files for RabbitMQ (no plain-text env files)
- **Service Discovery**: Aspire-based service discovery with HTTP resilience patterns
- **Observability**: OpenTelemetry integration with OTLP exporter for distributed tracing and metrics

## User Workflow

The UI consists of three main areas:
1. **Inbox**: Entry point for new opportunities (move to backlog or archive)
2. **Backlog**: Collection of interesting opportunities (sorted by AI score, manual prioritization)
3. **Active (Kanban Board)**: Active acquisition pipeline with drag-and-drop workflow

## Data Flow Patterns

### Write Path (Commands)
1. UI action → HTTP command to API Gateway
2. Command published to RabbitMQ
3. Service consumes command, validates state via Event Store
4. New domain event appended and published

### Read Path (Queries)
1. Projector consumes domain events
2. Updates denormalized read model tables
3. UI queries read models directly for fast display

## Quality Assurance

- **CI/CD**: GitHub Actions pipeline
- **Testing**: Unit tests with >80% code coverage target
- **Static Analysis**: Cyclomatic complexity and linting
- **Quality Gates**: All checks must pass for main branch merge
- **Code Metrics**: cloc pre-commit hook for tracking project progress

## Security Notes

- **Authentication**: OAuth 2.0/OIDC via Auth0
- **CSRF Protection**: Bearer token auth only, secure cookies
- **Secrets**: PostgreSQL via Docker Secrets, RabbitMQ via configuration files
- **Token Validation**: JWT validation on all API requests

## Event Sourcing Specifics

- **Custom Event Store Library**: .NET library for PostgreSQL interaction
- **Key Methods**: `AppendToStream()`, `ReadStream()`
- **Consistency**: Optimistic concurrency via expected version
- **Retention**: Events stored indefinitely (GDPR compliance pending)

## Messaging (RabbitMQ)

- **Commands Exchange**: Topic exchange for command routing
- **Events Exchange**: Topic exchange for domain events
- **Multiple Consumers**: Projectors can subscribe to same events

## Current Status

The project has completed **Phase 0 (Foundation & Scaffolding)** including:

### Completed Iterations:
1. **Solution Structure & Project Setup** - Complete .NET 8 solution with backend, tests, and Aspire AppHost
2. **Infrastructure & Docker Setup** - Containerized environment with PostgreSQL, RabbitMQ, and Docker Secrets
3. **Aspire Development Host Integration** - Enhanced development experience with service discovery, telemetry, and integrated dashboard

### Current Implementation Features:
- Complete .NET 8 solution structure with proper organization
- ASP.NET Core Web API backend with health endpoints and OpenTelemetry integration
- Comprehensive test suite with NUnit and NSubstitute (12 tests passing)
- .NET Aspire AppHost for development orchestration with PostgreSQL and RabbitMQ resources
- Docker Compose infrastructure with secrets management
- Service discovery and HTTP resilience patterns
- OpenTelemetry distributed tracing and metrics with OTLP exporter
- Dual development workflow (Docker-only or Aspire-enhanced)

**Next Phase**: Observability Stack (Grafana + OpenTelemetry), then UI/UX Prototyping. Future development will follow the reactive microservices architecture outlined above.