# Progress

Method-workbench progress. Most recent first. The work items themselves are in `backlog.md`.

## 2026-10-02 - v4 direction (grill session)

### Decided
- This repository becomes a **method workbench**. Its root `CLAUDE.md` is about designing methods, and apps live in their own repos.
- **Two independent templates named by philosophy**: `spec-gated-workflow/` (v3 lineage, bugfixes and shared-rule sync only) and `batch-design-workflow/` (design-centric, fast). Versioned as git tags. Shared rules are copied into each and kept aligned by a drift check.
- **Build order**: layout → fix gated → copy to cycles.
- **Synfactu is upstream for `spec-gated-workflow/`**: its method fork (2.11 → 4.1.0) is the version tested on a real project. Generic parts get taken, and `/force` and the gate renames get back-ported.
- **Cycles philosophy**: no approval stops, review on error. Machine gates decide cycle exit. Trunk-based. Traceability comes from commit titles and trailers, and errors are fixed with the human.
- **Hard stop only at prod release**: risk-trailer review plus a migration dry-run on a local copy of prod.
- **Orchestrator** becomes a main-session skill. **Decisions** rationale becomes a skill, not auto-loaded.
- **ai-method**: each template ships separate check and update agents, and apps keep `method.lock`.
- Method-design notes and decisions live in the workbench `journal/` and `decisions/`, never in the templates.

- **Folder names**: `spec-gated-workflow/` (created; the template moved into it) and `batch-design-workflow/` (not created yet).
- **Decision model (MD-002)**: two files per domain. A short log the AI reads, one line per binding decision, saying what was chosen and what was rejected. A rationale file humans read, which the AI opens only to change a rule. The domains are FD in `specs/functional/`, AD in `specs/technical/`, DD in `design/`, and MD in the workbench. Each chooser reads its own log plus upstream ones. Markdown, read per section.

### Done
- Template moved into `spec-gated-workflow/`.
- Workbench root: `CLAUDE.md`, `.gitignore`, `decisions/` (MD-001, MD-002), `journal/`.
- Baseline tag `spec-gated-workflow-v3.0.0`.

### Parked
- Testing philosophy (dedicated session).
- Cloud/concurrency and the synfactu product-AD triage (see backlog, Open decisions).

### Next
- Grill the open decisions in a fresh session: cloud sessions and concurrency, and which synfactu ADs belong in the template.
- Then fix `spec-gated-workflow/`: import the generic parts of synfactu's method fork, and back-port `/force` and the gate renames.
