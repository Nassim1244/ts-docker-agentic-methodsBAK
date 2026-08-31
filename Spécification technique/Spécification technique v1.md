# SynFactu — Technical Specification (Plan)

> Technical companion to the functional specification. **To be detailed in a second phase** — the current focus is the functional spec. This document only captures the high-level direction known so far.

---

## 1. Purpose and Scope

- 1.1 Translate the functional specification into a technical design
- 1.2 Out of scope for now: detailed design (deferred to phase 2)

## 2. High-Level Direction (Current Ideas)

- 2.1 Software type: **web application**
- 2.2 Deployment: runs in a **Docker** environment, either on Windows or on a VPS
- 2.3 Single-tenant for now (one consultant), with user roles planned (see functional spec, section 7)

## 3. Candidate Technology Stack

- 3.1 Frontend: **React + TypeScript**
- 3.2 UI components: **shadcn/ui**
- 3.3 Backend: TBD
- 3.4 Database: TBD (must support the multi-year single database requirement)
- 3.5 Authentication / authorization: TBD (must support the role model)

## 4. Architecture (To Be Defined)

- 4.1 Application layers and module breakdown
- 4.2 Data persistence and migrations
- 4.3 API design
- 4.4 Containerization and deployment (Docker on Windows / VPS)

## 5. Integrations (To Be Defined)

- 5.1 Google Calendar (time-entry pre-fill)
- 5.2 Possible accounting/export integrations

## 6. Non-Functional / Technical Requirements (To Be Defined)

- 6.1 Backup and persistence strategy
- 6.2 Security of financial data
- 6.3 Performance and scalability
- 6.4 Logging and observability

## 7. Open Questions

- Backend language/framework
- Database engine
- Auth solution
- Hosting target (local Windows vs VPS) and its constraints
