# Phase 0: Foundation & Scaffolding - Implementation Plan

**Version:** 1.0  
**Date:** July 26, 2025  
**Target:** Complete foundation setup for Project Radar Application

## Step-by-Step Execution Plan

### □ Step 1: Repository Structure
- [ ] Create directory structure: `src/xrai.projectradar.application`, `infrastructure/docker`, `infrastructure/aspire-apphost`, `scripts`, `dev-secrets`, `.github/workflows`
- [ ] Create comprehensive .gitignore for .NET, Docker, IDE files, secrets
- [ ] **Verify:** All directories exist, .gitignore covers all necessary patterns

### □ Step 2: .NET Solution Setup
- [ ] Create solution in `src/xrai.projectradar.application` using `dotnet new sln`
- [ ] Create ASP.NET Core Web API project `xrai.projectradar.application.backend` with .NET 8
- [ ] Create NUnit test project `xrai.projectradar.application.backend.tests` with NSubstitute and coverlet
- [ ] Add both projects to solution
- [ ] **Verify:** `dotnet build`succeeds

### □ Step 3: Sample Service Implementation
- [ ] Create `IHealthService` interface with `GetHealthStatusAsync()` and `GetApplicationVersion()` methods
- [ ] Implement `HealthService` class
- [ ] Create `HealthController` with GET endpoints for health and version
- [ ] Register service in DI container
- [ ] **Verify:** API responds to `/api/health` and `/api/health/version`

### □ Step 4: Unit and Integration Tests
- [ ] Create unit tests for `HealthService` using NUnit
- [ ] Create integration tests for `HealthController` using `WebApplicationFactory`
- [ ] Ensure tests cover both happy path scenarios
- [ ] **Verify:** All tests pass with `dotnet test`

### □ Step 5: Docker Infrastructure
- [ ] Create `docker-compose.yml` with PostgreSQL, RabbitMQ, Prometheus, Tempo, Grafana
- [ ] Create `docker-compose.override.yml` with optional ELK stack (profile: elk)
- [ ] Create configuration files for Prometheus, Tempo, and Grafana provisioning
- [ ] Set up Docker secrets for passwords
- [ ] **Verify:** `docker-compose up -d` starts all services successfully

### □ Step 6: Secret Management
- [ ] Create `scripts/create-secrets.sh` to generate random passwords for all services
- [ ] Generate secrets for postgres, rabbitmq, grafana
- [ ] Update docker-compose to use secrets files from `dev-secrets/`
- [ ] **Verify:** Services start with generated secrets, passwords work

### □ Step 7: .NET Aspire Development Host
- [ ] Create Aspire AppHost project in `infrastructure/aspire-apphost`
- [ ] Configure Aspire to orchestrate PostgreSQL, RabbitMQ, and backend API
- [ ] Add project references between Aspire host and backend
- [ ] **Verify:** `dotnet run` from aspire-apphost opens dashboard with all services

### □ Step 8: CI/CD Pipeline
- [ ] Create GitHub Actions workflow `.github/workflows/ci.yml`
- [ ] Include jobs for: build-test, static-analysis, security-scan (Trivy), cloc-metrics
- [ ] Configure code coverage reporting and upload to Codecov
- [ ] Set quality gates that fail on HIGH/CRITICAL security issues
- [ ] **Verify:** Push to main is prohibited. A pull request triggers workflow, all jobs pass

### □ Step 9: Dependabot Configuration
- [ ] Create `.github/dependabot.yml` for NuGet, Docker, and GitHub Actions updates
- [ ] Configure weekly updates with PR limits
- [ ] **Verify:** Dependabot configuration is valid

### □ Step 10: Quality Tooling
- [ ] Create pre-commit hook script that runs cloc and saves metrics
- [ ] Create installation script for pre-commit hooks
- [ ] Set up metrics directory with gitkeep
- [ ] **Verify:** Pre-commit hook runs and saves metrics on commit

### □ Step 11: OpenTelemetry Integration
- [ ] Add OpenTelemetry packages to backend project
- [ ] Configure OTLP exporters for traces and metrics
- [ ] Add structured logging with Serilog to OTLP
- [ ] **Verify:** Traces and metrics appear in Grafana/Tempo

### □ Step 12: Final Integration Test
- [ ] Start infrastructure with `docker-compose up -d`
- [ ] Start Aspire host with `dotnet run`
- [ ] Verify API endpoints respond correctly
- [ ] Verify observability data flows to Grafana
- [ ] Push changes and verify CI pipeline completes successfully
- [ ] **Verify:** Complete end-to-end functionality works

## Success Criteria (Definition of Done)

- [ ] Developer can run `docker-compose up && dotnet aspire run` for complete local environment
- [ ] All CI/CD quality gates pass on main branch
- [ ] GitHub repository has branch protection requiring PR reviews
- [ ] API endpoints are functional and testable
- [ ] Observability stack shows traces and metrics
- [ ] Pre-commit hooks track code metrics automatically
- [ ] Security scanning passes with no HIGH/CRITICAL vulnerabilities

## Notes
- Each step should be implemented incrementally with verification
- If any verification fails, troubleshoot before proceeding to next step
- Keep all secrets in `dev-secrets/` and never commit them
- Document any deviations or issues encountered during implementation