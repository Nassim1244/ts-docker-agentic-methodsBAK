# Workbench changelog

What was done in the workbench, one entry per `workbench-v<semver>` tag. Most recent first. Each template's own versions are in its `<template>/CHANGELOG.md`. What comes next is in `journal/roadmap.md`.

Each bullet is tagged with its stream: [batch], [gated] or [workbench]. Binding decisions are only cited by ID here. Their text is in `decisions/method-decisions.md`.

## [workbench-v0.2.0] - 2026-10-02

### Decided (grill session: cloud, concurrency, Synfactu AD triage)
- [workbench] MD-003: cloud sessions in both templates.
  - Gated takes Synfactu 4.1.0's one unmerged session per spec.
  - In batch, local sessions stay on trunk. A cloud session works one feature on `cloud/feat/<feature-id>`, claimed by `Refs:`. The branch rebases onto main and fast-forwards, and the gates run again only if main moved.
- [workbench] MD-004: a minimal cloud setup script for the gates. No Docker or e2e in the cloud.
- [batch] MD-005: the architect computes the batch schema up front and can be called back. A migration on a session branch gets an automatic architect check before merging, plus `Risk: schema`.
- [workbench] MD-006: Synfactu AD triage.
  - Kept as template rules: AD-023, AD-031 (with AD-033 as its exception), AD-034, AD-035, AD-020, and AD-025 to AD-028 merged.
  - AD-018 stays Synfactu-only, and the init money step becomes conditional.
- [workbench] MD-007: batch is the target method, to be brought to Synfactu. Gated takes a one-time import of Synfactu 4.1.0, tagged v4.0.0, then is frozen. Batch forks from that tag.

### Changed
- [workbench] The journal is split into `journal/backlog-batch.md` and `journal/backlog-gated.md`, replacing `backlog.md`.
- [workbench] `journal/progress.md` is replaced by `journal/roadmap.md` (what comes next) and this changelog (what was done). The workbench gets its own `workbench-v<semver>` tags.
- [workbench] Root `CLAUDE.md`: new journal layout, gated frozen after the import, shared-rule changes land in batch only while gated is frozen.

## [workbench-v0.1.0] - 2026-10-02

### Decided (grill session: v4 direction)
- [workbench] MD-001: the repository becomes a method workbench holding independent templates named by philosophy, each versioned with its own git tags. Apps live in their own repos.
- [workbench] MD-002: decisions use two files per domain: a short log the AI reads, and a rationale file for humans.
- [batch] The cycles philosophy:
  - No approval stops; review happens on error, and errors are fixed with the human.
  - Machine gates decide when a cycle exits.
  - Trunk-based, with traceability from commit titles and trailers.
  - The only hard stop is the prod release: a review of the risk trailers plus a migration dry-run on a local copy of prod.
- [workbench] The orchestrator becomes a main-session skill, and decision rationale becomes a skill instead of being auto-loaded.
- [workbench] ai-method: separate check and update agents, and apps keep a `method.lock`.
- [workbench] Notes and decisions about designing the method live in `journal/` and `decisions/`, never in the templates.

### Changed
- [gated] The v3 template moved into `spec-gated-workflow/`.
- [workbench] Workbench root added: `CLAUDE.md`, `.gitignore`, `decisions/` (MD-001, MD-002), `journal/`.
- [gated] `spec-gated-workflow-v*` tags added alongside the old `template/v*` ones, on the same commits (v3.0.0 = `49b307c`).
