# Implementation plan Phase 0: Foundation & Scaffolding

## Iteration 1: Solution Structure & Project Setup

Create the complete .NET solution structure with proper project organization, Aspire integration, and basic test infrastructure.

- [x] Create main solution structure at ./src/xrai.projectradar.application/xrai.projectradar.application.sln
- [x] Create backend project: ./src/xrai.projectradar.application/xrai.projectradar.backend/xrai.projectradar.backend.csproj (Empty ASP.NET application)
- [x] Create test project: ./src/xrai.projectradar.application/tests/xrai.projectradar.backend.tests/xrai.projectradar.backend.tests.csproj (NUnit, NSubstitute)
- [x] Create Aspire AppHost: ./src/xrai.projectradar.application/xrai.projectradar.AppHost/xrai.projectradar.AppHost.csproj
- [x] Organize solution folders: create "tests" folder and move test project, create "dev" folder and move Aspire project
- [x] Add simple dummy unit test to verify test infrastructure works
- [x] Verify solution builds and tests run successfully

---

## Iteration 2: Infrastructure & Docker Setup ✅ COMPLETED

Set up the complete containerized development environment with PostgreSQL, RabbitMQ, and proper secrets management.

- [x] Create docker-compose.yml with PostgreSQL and RabbitMQ services
- [x] Implement Docker Secrets configuration for all sensitive values (DB passwords, RabbitMQ credentials)
- [x] Create ./scripts/create-secret.sh helper script for local development
- [x] Update docker-compose.yml to mount secrets files from ./dev-secrets/*
- [x] Create docker-compose.override.yml for local development overrides
- [x] Test complete infrastructure startup with `docker-compose up`
- [x] Verify services are accessible and properly configured

---

## Iteration 3: Aspire Development Host Integration ✅ COMPLETED

Configure .NET Aspire for local development with integrated dashboard and service discovery.

- [x] Configure Aspire AppHost to orchestrate all services (backend, PostgreSQL, RabbitMQ)
- [x] Set up service discovery and configuration management through Aspire
- [x] Configure live-reload for development workflow
- [x] Integrate with existing Docker infrastructure
- [x] Test complete startup with `dotnet aspire run`
- [x] Verify Aspire dashboard accessibility and service health monitoring

---

## Iteration 4: Observability Stack (Grafana + OpenTelemetry) ✅ COMPLETED

Implement comprehensive observability with OpenTelemetry tracing, metrics, and Grafana visualization.

- [x] Add OpenTelemetry instrumentation to backend services (OTEL 1.7)
- [x] Configure OTLP exporter for traces and metrics
- [x] Set up Grafana stack: Prometheus + Tempo + Grafana OSS
- [x] Create Grafana dashboards for application monitoring
- [x] Configure Serilog with OTLP as primary sink
- [x] Test observability pipeline: generate traces/metrics and verify in Grafana at http://localhost:3000

---

## Iteration 5: CI/CD Pipeline & Quality Gates

Implement comprehensive GitHub Actions workflow with quality gates, security scanning, and automated checks.

- [ ] Create GitHub Actions workflow for continuous integration
- [ ] Implement automated build and test execution
- [ ] Add static code analysis for cyclomatic complexity and linting
- [ ] Configure code coverage measurement and reporting (target >80%)
- [ ] Integrate Trivy container image and dependency scanning (fail on HIGH+ severity)
- [ ] Set up Dependabot for NuGet and npm dependency updates
- [ ] Configure branch protection rules for main branch
- [ ] Test complete CI pipeline with feature branch workflow

---

## Iteration 6: Development Tooling & Code Metrics

Set up development productivity tools and automated code metrics collection.

- [ ] Implement pre-commit hook for cloc (Count Lines of Code) metrics
- [ ] Create automated code metrics collection and versioned storage
- [ ] Set up development scripts and utilities
- [ ] Configure IDE integration and debugging workflows
- [ ] Document development workflow and setup procedures
- [ ] Create developer onboarding documentation
- [ ] Verify complete development environment: clone → single command setup → feature development → PR workflow