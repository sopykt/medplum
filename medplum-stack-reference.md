# Medplum Stack Overview & Local Setup Reference

Medplum is a developer platform designed to build HIPAA-compliant, interoperable healthcare applications extremely fast. Instead of building healthcare backends and user interfaces from scratch, Medplum provides a prebuilt, standards-based foundation structured around the **FHIR (Fast Healthcare Interoperability Resources)** data standard.

Below is a reference guide to the structure of the Medplum codebase and how the services run locally.

---

## 1. The Core Infrastructure (Backend & DB)
*   **The FHIR Clinical Data Repository (CDR):** Located in [packages/server](file:///Users/soepaing/projects/medplum/packages/server), this is a Node.js Express server that exposes a compliant FHIR API. It manages validation, search query parsing, access control (role-based security), and auditing.
*   **Database (PostgreSQL) & Cache (Redis):** The server stores clinical resources in Postgres using specialized indexing patterns for fast FHIR search queries, while Redis handles session caching and job queues.

---

## 2. Frontend Applications & Libraries
*   **The Medplum App:** Located in [packages/app](file:///Users/soepaing/projects/medplum/packages/app), this is the default React web portal (built with Vite and Mantine UI). As an administrator or clinician, you can use this app to:
    *   Inspect and edit FHIR resources directly.
    *   Manage projects, user profiles, and organization access control.
    *   Monitor background jobs and system events.
*   **The Medplum React Component Library:** Located in [packages/react](file:///Users/soepaing/projects/medplum/packages/react), this contains highly specialized, prebuilt UI components like patient charts, timelines, questionnaires, and scheduling UI.
*   **Core SDK & Hooks:** [packages/core](file:///Users/soepaing/projects/medplum/packages/core) and `packages/react-hooks` provide TypeScript clients and React hooks to interact with the backend API securely and easily.

---

## 3. Serverless Logic & Workflows
*   **Medplum Bots:** Located around [packages/bot-layer](file:///Users/soepaing/projects/medplum/packages/bot-layer), Bots are small, serverless JavaScript/TypeScript functions. You can write custom logic that automatically runs in response to events (e.g., when a new patient is created, or when a lab result arrives) to send notifications, call external APIs, or transform data.

---

## 4. Enterprise & Integration Tools
*   **Medplum Agent:** Located in [packages/agent](file:///Users/soepaing/projects/medplum/packages/agent), this is an on-premise proxy daemon used to securely connect local medical equipment, HL7 feeds, or local databases directly to the cloud or self-hosted Medplum CDR.
*   **Medplum CLI:** Located in [packages/cli](file:///Users/soepaing/projects/medplum/packages/cli), this command-line utility lets developers automate deployments, sync Bot files, and configure local environments.

---

## 5. Local Setup Reference

### Initial Setup & Build
You can run the helper script in the repository root to automatically install dependencies, build the packages, and launch PostgreSQL + Redis background containers:
```bash
./scripts/setup-local-stack.sh
```

### Dev Server Startup Commands
Once the initial setup is complete:
1. **API Backend:**
   ```bash
   cd packages/server
   npm run dev
   ```
   *   **API URL:** [http://localhost:8103](http://localhost:8103)
   *   **Healthcheck:** [http://localhost:8103/healthcheck](http://localhost:8103/healthcheck)
2. **Web App UI:**
   ```bash
   cd packages/app
   npm run dev
   ```
   *   **Web App URL:** [http://localhost:3000](http://localhost:3000)

### Quick Access Credentials
Use the default administrator account to sign in locally:
*   **Email:** `admin@example.com`
*   **Password:** `medplum_admin`
