# **High Level Architecture Specification**

Version: 1.2 
Date: July 26, 2025

## **1\. Overview**

This document provides a detailed technical specification for the architecture of "Project Radar". The system is designed as a **reactive, message-driven microservice architecture** based on the principles of **Event Sourcing (ES)** and **Command Query Responsibility Segregation (CQRS)**.

This approach ensures high scalability, resilience, and full auditability of all system state changes. All application components will be containerized using Docker and orchestrated for local development via Docker Compose.

The architecture is broadly divided into two main logical parts:

* **The Ingestion Pipeline:** A set of backend services responsible for processing raw opportunity data into structured, actionable information.  
* **The Interactive Component:** The user-facing application, consisting of a Blazor WebAssembly frontend and a set of backend services that handle user interactions and queries.

## **2\. System Components**

### **2.1. Infrastructure Layer**

The foundation of the system is managed via Docker Compose for local development.

* **Container Orchestration (Docker Compose):** A docker-compose.yml file will define and manage all infrastructure and application services. This ensures a consistent, one-command setup for the development environment.  
* **Database (PostgreSQL):** A single PostgreSQL instance will serve two distinct roles:  
  1. **Event Store Persistence:** It will house the append-only log of all domain events.  
  2. **Read Model Persistence:** It will store the denormalized projections of data, optimized for fast queries by the frontend.  
* **Message Bus (RabbitMQ):** RabbitMQ will act as the central message broker, facilitating asynchronous communication between all microservices. It decouples services, allowing them to evolve independently and ensuring system resilience.
* **Secrets Management:** All sensitive values (Postgres password, RabbitMQ credentials, Auth0 client secret, LLM keys) are injected via **Docker Secrets**.  The local `docker‑compose.override.yml` mounts secret files from `./dev‑secrets/*`.
* **Developer Orchestration:** The solution is boot‑strapped with **dotnet Aspire** (preview).  Running `dotnet aspire run` starts every service with live‑reload and aggregated dashboards.


### **2.2. Application Layer**

#### **2.2.1. Frontend Client**

* **Technology:** Blazor WebAssembly (.NET 8).  
* **Responsibilities:**  
  * Provides the complete user interface (Inbox, Backlog, Kanban Board).  
  * Handles user authentication via an OAuth 2.0 / OIDC flow.  
  * Communicates with the backend via two distinct patterns:  
    1. **Sending Commands:** Sends HTTP POST requests to specific API Gateway endpoints to initiate state changes.  
    2. **Querying Read Models:** Sends HTTP GET requests to query endpoints to fetch data for display.

#### **2.2.2. Backend Services (.NET 8 Microservices)**

All backend logic is encapsulated in small, single-responsibility microservices that communicate via the message bus.

* **API Gateway / Command Endpoints:** A lightweight service that exposes HTTP endpoints for the Blazor client. Its sole responsibility is to receive commands, validate them, and publish them to the message bus for processing. It does not contain business logic.  
* **Ingestion Pipeline Services (Examples):**  
  * DataExtractionService: Consumes a "raw opportunity text" message, interfaces with an LLM service to extract structured data, and publishes an OpportunityExtracted event.  
  * WeightingService: Consumes OpportunityExtracted events, retrieves the user's profile, calls an LLM to generate a score and justification, and publishes an OpportunityWeighted event.  
  * DeduplicationService: Consumes OpportunityExtracted events, checks for duplicates based on a content hash, and publishes OpportunityMarkedAsDuplicate if necessary.  
* **Interactive Workflow Services (Command Handlers):**  
  * These services listen for specific commands from the API Gateway.  
  * They load the relevant event stream from the Event Store to validate the command, then publish a new event upon success.  
* **Projector Services (Query Handlers):**  
  * These services are responsible for building the read models.  
  * Each projector subscribes to a specific stream of events from RabbitMQ.  
  * When an event is received, the projector updates the corresponding denormalized read model table in PostgreSQL.

### **2.3. Persistence Layer**

#### **2.3.1. The Custom Event Store**

This is a custom .NET library, not a standalone service. It provides a programmatic interface for interacting with the event log in PostgreSQL.

* **Core Principle:** It will be built following the **"Aggregateless Event Sourcing"** and **"Command Context Consistency"** patterns. This means consistency is not enforced by loading a large aggregate object, but rather by ensuring that the state required to validate a single command has not changed between the time of the check and the time of the write.  
* **Functionality:**  
  * AppendToStream(streamId, expectedVersion, events): Appends one or more events to a stream, ensuring optimistic concurrency via the expectedVersion.  
  * ReadStream(streamId): Reads all events for a given stream ID.

#### **2.3.2. Read Models**

These are simple, denormalized tables in PostgreSQL designed specifically to back UI views. For example, a backlog\_view table might contain opportunities in the backlog, with a priority column for sorting.

### 2.4 Observability
* **Tracing & Metrics:** Every .NET service is instrumented with **OpenTelemetry** (OTEL 1.7).  The OTLP exporter streams traces & metrics to a local **Grafana stack** (Prometheus + Tempo + Grafana OSS dashboards).
* **Structured Logging:** Serilog continues to be the canonical logger.  Primary sink =  OTLP.  **Optional** secondary sink =  Elasticsearch → Kibana (for devs preferring the classical ELK workflow).  The ELK containers are disabled by default and can be enabled via `COMPOSE_PROFILES=elk`.

## **3\. Communication & Data Flow**

### **3.1. Write Path (Command Flow)**

1. **UI Action:** The user performs an action (e.g., clicks "Archive" on an opportunity).  
2. **HTTP Command:** The Blazor client sends an HTTP request (e.g., POST /api/opportunities/{id}/archive) to the API Gateway.  
3. **Message Bus:** The API Gateway validates the request and publishes a command message (e.g., ArchiveOpportunityCommand) to a commands exchange in RabbitMQ.  
4. **Command Handler:** The relevant workflow service consumes the command.  
5. **State Validation:** The service reads the event stream for the opportunity from the Event Store to confirm it is in a valid state to be archived.  
6. **Event Persistence:** The service appends a new domain event (e.g., OpportunityArchived) to the Event Store.  
7. **Event Publication:** The service publishes the domain event to a domain-events exchange in RabbitMQ.

### **3.2. Read Path (Query Flow)**

1. **Event Consumption:** A Projector service consumes the domain event (e.g., OpportunityArchived) from the message bus.  
2. **Read Model Update:** The projector executes a SQL statement to update the corresponding read model table (e.g., deleting a row from the inbox\_view).  
3. **UI Request:** The user navigates to the Inbox. The Blazor client sends an HTTP request to fetch the data (e.g., GET /api/inbox).  
4. **Query Execution:** The API Gateway (or a dedicated query service) queries the appropriate read model table directly.  
5. **Data Return:** The query result (a list of opportunities) is returned as a JSON response to the client for rendering.

## **4\. Messaging Topology (RabbitMQ)**

**Note:** The following topology, including exchange names and routing key conventions, represents a preliminary design. These details are illustrative and are expected to evolve as implementation progresses.

A topic-based exchange strategy will be used for flexibility.

* **Proposed Exchange for Commands: commands.exchange (Topic Exchange)**  
  * Commands would be published here with a routing key that describes the intent (e.g., a potential routing key could be commands.opportunity.archive).  
  * Command handler services would bind a queue to this exchange with a specific routing key to consume only the commands they are interested in.  
* **Proposed Exchange for Events: events.exchange (Topic Exchange)**  
  * Events would be published here with a routing key describing the fact (e.g., a potential routing key could be events.opportunity.archived).  
  * Multiple projector services could subscribe to the same events by binding their queues with the appropriate routing keys (e.g., one projector updates the inbox view, another updates an audit log).

## **5\. Database Schema (PostgreSQL)**

**Note:** The schemas presented below are conceptual starting points. The exact table names, column names, and data types are subject to change and refinement during the implementation phase.

### **5.1. Event Store Schema (Conceptual)**

A single primary table, tentatively named events, will store the event log. Its structure might look like this:

\-- This is a potential schema and is subject to change.  
CREATE TABLE events (  
    id BIGSERIAL PRIMARY KEY,  
    stream\_id UUID NOT NULL,  
    version INT NOT NULL,  
    event\_type VARCHAR(255) NOT NULL,  
    payload JSONB NOT NULL,  
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),  
    UNIQUE(stream\_id, version)  
);

### **5.2. Read Model Schema (Example)**

An example table, potentially named backlog\_view, could be structured as follows to support the UI:

\-- This is an example schema and is subject to change.  
CREATE TABLE backlog\_view (  
    opportunity\_id UUID PRIMARY KEY,  
    title TEXT,  
    customer\_name TEXT,  
    ai\_score INT,  
    priority INT,  
    \-- ... other denormalized fields for display ...  
    last\_updated TIMESTAMPTZ  
);


## 5.3 Event Retention
Events are stored **indefinitely** until a retention/anonymisation strategy is defined. GDPR compliance remains an open item.

## **6\. Security**

Authentication will be handled via an external Identity Provider (IdP) using the OAuth 2.0 / OIDC standard. The Blazor client will be responsible for the authentication flow (e.g., redirecting to the IdP). Backend APIs will be secured and will validate JWT bearer tokens on every incoming request.

* **IdP:** **Auth0** SaaS tenant.  Access‑tokens validated server‑side with openid‑configuration discovery.
* **Blazor WASM CSRF:** All API calls use the **Bearer JWT** header; cookies carry only non‑sensitive refresh tokens and are set `SameSite=None; Secure`.  No anti‑forgery hidden‐form tokens are required.

