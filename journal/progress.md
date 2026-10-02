# Progress

Method-workbench progress. Most recent first. The work items themselves are in `backlog-batch.md` and `backlog-gated.md`. From batch-001 on, each entry is headed `## [batch-nnn]` or `## [gated-nnn]` - date - title.

## [batch-001] - 2026-10-02 - Cloud, concurrency and Synfactu AD triage (grill session)

### Decided
- **MD-003 Cloud sessions in both templates**:
  - Branches are `cloud/<type>/<x>`, and statements scoped to one environment start with `Local session only:` or `Cloud session only:`.
  - Gated takes Synfactu 4.1.0 as it is: one unmerged session per spec.
  - Batch keeps local sessions on trunk. A cloud session works one feature on its own branch, and only one session can claim a feature (keyed on `Refs:`). The branch rebases onto main and fast-forwards. The gates run again only if main moved.
- **MD-004**: a minimal cloud setup script (Node/pnpm, frozen install, `prisma generate`), enough for the gates. No Docker or e2e in the cloud.
- **MD-005**: the architect computes the batch schema up front and can be called back. A migration on a session branch gets an automatic architect check before merging, plus `Risk: schema`.
- **MD-006 AD triage**:
  - Kept as template rules and AD lines in the template's own numbering: AD-023, AD-031 (with AD-033 as its exception), AD-034, AD-035, AD-020, and AD-025 to AD-028 merged into one line.
  - AD-018 stays Synfactu-only.
  - The template's init money step was found to carry Synfactu's billing bias and becomes conditional.
- **MD-007 Batch is the target**, to be brought to Synfactu.
  - Gated takes a one-time import of Synfactu's method 4.1.0, tagged v4.0.0, then is frozen. Batch forks from that tag.
  - Later shared fixes land in batch only and are logged in `backlog-gated.md`.
- **Journal**: the backlog is split into `backlog-batch.md` and `backlog-gated.md`. One `progress.md` is kept, with ID-prefixed entries.

### Done
- MD-003 to MD-007 logged, with rationale.
- `backlog.md` replaced by `backlog-batch.md` and `backlog-gated.md`.
- Root `CLAUDE.md` updated: journal layout, gated frozen after import, shared-rule handling.

### Next
- Grill the testing philosophy: the ratio between testing everything and relying on user feedback.
- Import Synfactu's method into `spec-gated-workflow/` (`backlog-gated.md` → Import), tag v4.0.0, then fork `batch-design-workflow/`.

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
- `spec-gated-workflow-v*` tags added alongside the old `template/v*` ones, on the same commits (v3.0.0 = `49b307c`). The move commit stays untagged until the next release.

### Parked
- Testing philosophy (dedicated session).
- Cloud/concurrency and the synfactu product-AD triage (see backlog, Open decisions).

### Next
- Grill the open decisions in a fresh session: cloud sessions and concurrency, and which synfactu ADs belong in the template.
- Then fix `spec-gated-workflow/`: import the generic parts of synfactu's method fork, and back-port `/force` and the gate renames.
