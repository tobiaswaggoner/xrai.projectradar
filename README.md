# Project Radar

> **🚧 Phase 0 Complete**: Foundation & scaffolding implemented. .NET 8 solution structure with build/test pipeline is ready. Next: Infrastructure & Docker setup.

An intelligent platform for freelancers and contractors to capture, evaluate, and track project opportunities using AI-powered analysis.

## 🎯 What is Project Radar?

Project Radar eliminates the manual effort of searching and evaluating freelance opportunities by:

- **Capturing** project opportunities from various sources through a simple interface
- **Analyzing** opportunities using AI to extract structured data and match against your profile
- **Tracking** the acquisition process through an intuitive Kanban-style workflow

### Key Features

- ✨ **AI-Powered Evaluation**: Automatically scores opportunities based on your skills and preferences
- 📊 **Smart Organization**: Inbox → Backlog → Active pipeline workflow
- 🔍 **Duplicate Detection**: Prevents redundant opportunities from cluttering your pipeline
- 📈 **Complete Audit Trail**: Full history of all decisions and changes
- 🎨 **Modern Interface**: Blazor WebAssembly frontend with drag-and-drop functionality

## 🏗️ Architecture

Project Radar is built as a **reactive, message-driven microservice architecture** with:

- **Event Sourcing + CQRS** for complete auditability and scalability
- **Custom Event Store** with "Aggregateless" pattern for optimal performance
- **Asynchronous messaging** via RabbitMQ between all services
- **Docker containerization** for consistent development and deployment

### Technology Stack

| Component | Technology |
|-----------|------------|
| **Backend** | .NET 8 Microservices |
| **Frontend** | Blazor WebAssembly |
| **Message Bus** | RabbitMQ |
| **Database** | PostgreSQL |
| **Authentication** | OAuth 2.0/OIDC (Auth0) |
| **Observability** | OpenTelemetry + Grafana Stack |
| **Development** | Docker Compose + dotnet Aspire |

## 🚀 Getting Started

The .NET 8 solution structure is now implemented and ready for development.

### Prerequisites

- .NET 8 SDK
- Docker & Docker Compose
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/tobiaswaggoner/xrai.projectradar.git
cd xrai.projectradar

# Navigate to solution and build
cd src/xrai.projectradar.application
dotnet build

# Run tests to verify setup
dotnet test

# Start all services with live-reload (future)
dotnet aspire run

# Alternative: Use Docker Compose directly (future)
docker-compose up -d
```

### Development Environment

The project uses **dotnet Aspire** for orchestrating the development environment:

- **Live reload** for all services
- **Aggregated dashboards** for monitoring
- **Integrated observability** with OpenTelemetry

## 📋 How It Works

### 1. Opportunity Ingestion
- Manual entry via simple form (URL source + raw text data)
- Future: Automated crawlers and integrations

### 2. AI Processing Pipeline
- **Data Extraction**: LLM extracts structured data (title, customer, rate, skills, etc.)
- **Scoring**: AI compares opportunity against your profile (1-100 score + justification)
- **Deduplication**: Hash-based detection of duplicate opportunities

### 3. Workflow Management
- **Inbox**: Review new opportunities
- **Backlog**: Prioritize interesting opportunities (AI-sorted, manual drag-and-drop)
- **Active**: Kanban board for tracking acquisition progress
- **Archive**: Completed opportunities (Won/Lost)

## 🛠️ Development

### Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Quality Requirements

- **Unit Tests**: >80% code coverage
- **Static Analysis**: Cyclomatic complexity monitoring
- **CI/CD**: GitHub Actions with quality gates
- **Code Style**: Consistent formatting and conventions

### Observability

- **Structured Logging**: Serilog with OTLP export
- **Distributed Tracing**: OpenTelemetry across all services
- **Metrics**: Prometheus + Grafana dashboards
- **Optional ELK**: Elasticsearch + Kibana for log analysis

## 🔒 Security & Privacy

- **Authentication**: OAuth 2.0/OIDC via Auth0
- **Data Protection**: No sensitive data in logs or commits
- **Container Security**: Docker Secrets and configuration files for credentials
- **CSRF Protection**: Bearer token authentication
- **Audit Trail**: Complete event history for compliance

## 📚 Documentation

- **[Project Description](aidocs/ProjectRadar-ProjectDescription.md)**: Detailed functional requirements
- **[Architecture Specification](aidocs/ProjectRadar-HighLevelArchitecture.md)**: Technical architecture details
- **[CLAUDE.md](CLAUDE.md)**: Developer guidance for AI assistance

## 📄 License

- This project will be licensed under a fair use license (still need to decide). Basically I will reserve the exclusive right for commercial use (i.e. building a business on this tool) for 2-3 years. All other usages are allowed including personal use. After the initial phase, this will transition to a true open source license.

## 🤝 Support

- **Issues**: [GitHub Issues](https://github.com/tobiaswaggoner/xrai.projectradar/issues)
- **Discussions**: [GitHub Discussions](https://github.com/tobiaswaggoner/xrai.projectradar/discussions)
- **Email**: [support@netzalist.de](mailto:support@netzalist.de)

---

**Built with ❤️ for the freelance community**