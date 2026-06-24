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

---

## 6. Medplum CLI Reference

The Medplum CLI ([packages/cli](file:///Users/soepaing/projects/medplum/packages/cli)) is a command-line tool used to authenticate with Medplum servers, perform REST operations, switch environment profiles, and deploy serverless Bots.

### Initial Build & Activation
Since the CLI depends on `@medplum/hl7` (which is not part of the standard dev server build), you must build it and its dependencies using Turborepo before first use:
```bash
npx turbo run build --filter=@medplum/cli
```

### Execution Commands
You can run the CLI locally in two ways:

1. **From the repository root:**
   ```bash
   npx tsx packages/cli/src/index.ts <command>
   ```
2. **From the CLI workspace directory:**
   ```bash
   cd packages/cli
   npm run medplum -- <command>
   ```

### Common CLI Operations

* **Logging In (Localhost):**
  ```bash
  npx tsx packages/cli/src/index.ts login --base-url http://localhost:8103
  ```
  *(Sign in with local admin details: `admin@example.com` / `medplum_admin`)*

* **Checking Login Session:**
  ```bash
  npx tsx packages/cli/src/index.ts whoami
  ```

* **Querying FHIR Resources:**
  ```bash
  npx tsx packages/cli/src/index.ts get Patient
  ```

* **Managing Environment Profiles:**
  ```bash
  npx tsx packages/cli/src/index.ts profile list
  ```

### CLI Storage & Behavior
* **Profile Configuration Files:** The CLI caches session tokens, active profiles, and endpoints in JSON files located under your user home directory:
  `~/.medplum/<profile>.json` (e.g. `~/.medplum/default.json`).
* **localStorage Warning:** Modern Node.js versions (v22+) might output an `ExperimentalWarning: localStorage is not available because --localstorage-file was not provided.` warning since the SDK performs browser checks. You can cleanly suppress this by prefixing commands with the `NODE_NO_WARNINGS` env variable:
  ```bash
  NODE_NO_WARNINGS=1 npx tsx packages/cli/src/index.ts whoami
  ```

---

## 7. Testing GraphQL Externally

You can query the Medplum GraphQL endpoint (`http://localhost:8103/fhir/R4/$graphql`) from outside the React web app using the local CLI authentication token.

### Step 1: Retrieve the Access Token
Use the CLI to output the active access token:
```bash
NODE_NO_WARNINGS=1 npx tsx packages/cli/src/index.ts token
```

### Step 2: Create a Test Patient (REST API)
Using the token, you can post a new patient using `curl`:
```bash
# Save your token into a shell variable
TOKEN=$(NODE_NO_WARNINGS=1 npx tsx packages/cli/src/index.ts token)

# Create Homer Simpson
curl -X POST http://localhost:8103/fhir/R4/Patient \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"resourceType":"Patient","name":[{"given":["Homer"],"family":"Simpson"}]}'
```

### Step 3: Query the Patient via GraphQL
Use `curl` to query the list of patients, requesting the ID and name fields:
```bash
curl -X POST http://localhost:8103/fhir/R4/\$graphql \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ PatientList { id name { given family } } }"}'
```

It should return the newly created patient details:
```json
{
  "data": {
    "PatientList": [
      {
        "id": "cc616671-f9b7-46c8-990f-47f9724a3cc4",
        "name": [
          {
            "given": [
              "Homer"
            ],
            "family": "Simpson"
          }
        ]
      }
    ]
  }
}
```
