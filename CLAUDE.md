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

The project now has a working .NET 8 solution structure with established build/test commands:

- **Build**: `dotnet build` (from solution root: `src/xrai.projectradar.application/`)
- **Test**: `dotnet test` (runs all NUnit tests with NSubstitute mocking)
- **dotnet Aspire**: Run `dotnet aspire run` to start all services with live-reload
- **Docker Compose**: Single-command setup for development environment (planned)
- **Secrets Management**: Docker Secrets (no plain-text env files)

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
- **Secrets**: Managed via Docker Secrets
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

The project has completed **Phase 0 (Foundation & Scaffolding)**. A complete .NET 8 solution structure is now implemented with:

- Main solution: `src/xrai.projectradar.application/xrai.projectradar.application.sln`
- ASP.NET Core Web API backend project with basic health endpoint
- NUnit test project with NSubstitute framework and passing tests
- .NET Aspire AppHost project for development orchestration
- Proper solution folder organization ("tests", "dev")

**Next Phase**: Infrastructure & Docker Setup, then UI/UX Prototyping. Future development will follow the reactive microservices architecture outlined above.