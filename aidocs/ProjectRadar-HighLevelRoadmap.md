# **High Level Implementation Roadmap**

Version: 1.2  
Date: July 26, 2025

## **Guiding Principles**

This roadmap outlines the path for implementing "Project Radar". It is founded on a set of core principles designed to maximize efficiency, ensure quality, and deliver value early and often.

1. **Quality First, Foundation Up:** We will begin by building a robust, production-ready foundation. All non-functional requirements, especially concerning automation, testing, and code quality, are not afterthoughts but prerequisites.  
2. **Agile Vertical Slices:** After establishing the foundation, we will develop the application in thin, vertical slices. Each slice will deliver a complete, testable piece of end-to-end user functionality, ensuring the application is always in a potentially shippable state.  
3. **Outside-In Development:** We will start by building the user-facing components with mocked data and progressively replace the mocks with the real backend pipeline. This provides immediate visual feedback and ensures the application is built with the user's workflow as the primary driver.  
4. **AI-Driven, Human-Guided:** While the goal is to generate all code using AI, the process will be meticulously guided by this strategic plan and the detailed project description to ensure the final product is coherent, robust, and fit for purpose.

## **Phase 0: Foundation & Scaffolding**

**Primary Goal:** To establish a fully automated, production-grade development environment and CI/CD pipeline before writing the first line of application logic. This phase is about building the "factory" before building the "car".

**Key Activities:**

* **Repository Setup:** Configure the GitHub repository with protected branches (e.g., main) to enforce quality gates.  
* **Infrastructure as Code:** Create a docker-compose.yml file to define and run the required infrastructure services (PostgreSQL, RabbitMQ) for a consistent local development environment.  
* **CI/CD Pipeline:** Implement the initial GitHub Actions workflow. This workflow will:  
  * Build a simple "Hello World" .NET solution.  
  * Run initial (empty) unit tests.  
  * Integrate static code analysis tools (for cyclomatic complexity, etc.).  
  * Integrate a linter.  
  * Measure and report code coverage.  
* **Quality Gates:** Configure the CI pipeline to fail if any of the quality checks (tests, coverage thresholds, linting rules) do not pass.  
* **Developer Tooling:** Implement the pre-commit hook to run cloc and track code metrics automatically.
* **dotnet Aspire Dev Host:** Add `./infrastructure/aspire-apphost/` launching all services for in‑IDE F5 debugging.
* **Docker Secrets wiring:** Update `docker‑compose.yml` to mount secrets files; document helper script `./scripts/create‑secret.sh`.
* **Security & Quality Gates:**
  * Integrate **Trivy** GitHub Action for container‑image & dependency (SBOM) scanning — *severity ≥ HIGH* fails the build.
  * Dependabot enabled for NuGet & npm.

**Definition of Done:**

* A developer can clone the repository, run a single command (docker-compose up) to start the infrastructure, and make a small code change on a feature branch.  
* Pushing the change triggers the CI pipeline, which runs through all defined quality checks successfully.  
* The main branch is protected. Merging is only possible via a pull request from a feature branch. A secondary review is not required, allowing the single developer to merge their own PRs once all automated checks have passed.
* `dotnet aspire run` starts all services & infra, Grafana opens at <http://localhost:3000> with traces visible.
* All GitHub Actions jobs (build, tests, static analysis, Trivy scan) pass on `main`.

## **Phase 1: UI/UX Prototyping & Data Discovery**

**Primary Goal:** To rapidly create a high-fidelity, interactive (but non-functional) prototype of the user interface. This will serve as a visual guide for the final Blazor implementation and help clarify the data structures needed from the ingestion pipeline.

**Key Activities:**

* Use a rapid prototyping tool like v0.dev to generate a Next.js application.  
* Build out the three main UI views: Inbox, Backlog, and the Active Kanban Board.  
* Simulate the entire user workflow, including drag-and-drop functionality and moving items between states.  
* Use static, hard-coded data to populate the UI.

**Definition of Done:**

* A clickable web prototype that demonstrates the complete user journey.  
* The prototype's source code is committed to a separate /prototype directory in the repository. It is explicitly understood to be **throwaway code**.

## **Phase 2: Core Persistence \- The Custom Event Store**

## Phase 2a — **Event‑Store Spike**  *(new sub‑phase before Phase 2)*
Time‑box: 3 dev‑days.  Success criteria: **Replay 10 k events in ≤ 5 s on local Postgres** and write benchmark notes.  Decide if snapshotting/partitioning is required.

## Phase 2b - Implementation

**Primary Goal:** To implement the foundational persistence layer. This is a strategic exception to the vertical slice approach, as this component is a core dependency for all subsequent slices.

**Key Activities:**

* Develop the custom Event Store library based on the principles of "Aggregateless Event Sourcing" and "Command Context Consistency".  
* Implement the necessary logic to append events to a stream and read streams from the database.  
* Create the data access layer to persist events into PostgreSQL.  
* Write comprehensive unit and integration tests for the Event Store to ensure its reliability.

**Definition of Done:**

* A stable, well-tested, and documented .NET library for the Event Store is complete.  
* The library can be consumed as a package or project reference by the application's services.

## **Phase 3: The First End-to-End Display Slice**

**Primary Goal:** To have a mechanism for creating an opportunity with structured data and displaying it in the UI, establishing the full flow from command to query model.

**Key Activities:**

1. **Backend (Mock Ingestion):** Create a temporary, internal API endpoint (or similar mechanism) that accepts a structured JSON object representing a fully processed opportunity. This simulates the output of the future ingestion pipeline.  
2. **Backend (Command):** The endpoint's handler will trigger a command to create a new opportunity.  
3. **Persistence:** The command handler uses the Event Store to write an OpportunityAdded event containing the structured JSON payload.  
4. **Backend (Query):** A "Projector" service listens for OpportunityAdded events and populates an "Inbox" read model in a PostgreSQL table.  
5. **UI (Blazor):** Implement the Inbox view, which queries the read model to display the list of opportunities.

**Definition of Done:**

* A developer can send a JSON payload to a test endpoint.  
* The data is permanently saved in the Event Store.  
* A user can load the Blazor application and see the newly created opportunity listed in the Inbox view.

## **Phase 4: Expanding the Interactive Workflow**

**Primary Goal:** To build out the full interactive lifecycle management of an opportunity, from initial assessment to a final decision. This will be done in a series of small, subsequent vertical slices.

**Key Activities (as individual slices):**

* **Slice 4.1 (Editing):** Implement the ability to edit all fields of an opportunity. This includes creating an "Edit" UI and a corresponding command/event flow to persist the OpportunityUpdated event.  
* **Slice 4.2 (Triage):** Implement the "Move to Backlog" and "Archive" actions from the Inbox.  
* **Slice 4.3 (Prioritization):** Build the Backlog view, including drag-and-drop reordering to change an opportunity's priority.  
* **Slice 4.4 (Activation):** Implement the "Start Acquisition" action, which moves an opportunity from the Backlog to the "New" column of the Active Kanban board.  
* **Slice 4.5 (Pipeline Management):** Build the Active Kanban board with drag-and-drop functionality between columns.  
* **Slice 4.6 (Closing):** Implement the "Won" and "Lost" end states.

**Definition of Done:**

* The user can manage an opportunity through its entire lifecycle using the UI, with all state changes being persisted via events.

## **Phase 5: Introducing the Ingestion Pipeline**

**Primary Goal:** To incrementally replace the manual data entry and assessment with the AI-powered pipeline, slice by slice.

**Key Activities (as individual slices):**

* **Slice 5.1 (AI Data Extraction):**  
  * Create the first ingestion microservice and a simple UI to paste in raw text.  
  * This service takes the raw text, calls the LLM abstraction to extract the defined fields, and then uses the same command/event flow established in Phase 3 to create the opportunity.  
  * Update the UI to display this structured data.  
* **Slice 5.2 (AI Weighting & Justification):**  
  * Implement the user profile upload (PDF/text).  
  * Create a new service that uses the user profile and extracted data to generate a score and justification.  
  * Persist and display the score/justification in the UI. The Inbox is now sorted by this score.  
* **Slice 5.3 (Deduplication):**  
  * Implement the deduplication service that checks for duplicates before an opportunity is added.

**Definition of Done:**

* The mock ingestion from Phase 3 is replaced by a powerful ingestion point that automates data extraction and assessment, with all results visible and usable in the UI.

## Open Items (rolling)
| # | Topic | Target Phase |
|---|-------|--------------|
| 1 | GDPR‑compliant deletion/anonymisation mechanism | TBD |
| 2 | Decide if ELK remains optional or is dropped in favour of OTEL only | Phase 0 review |
| 3 | Fuzzy de‑duplication algorithm PoC (MinHash + Jaccard) | Phase 5.3 |
| 4 | Container image hardening baseline (CIS) | Phase 0+ |