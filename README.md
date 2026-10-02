# ts-docker-agentic-methods

A workbench of agentic development methods for TypeScript applications running in Docker. Each method is a self-contained template for [Claude Code](https://claude.com/claude-code): agents, policies, specs and Docker skeletons that you copy into an application repository, install and then adapt.

This repository builds no application. It is where the methods are designed, tested against a real app, and versioned.

## Methods

| Template | Philosophy | Status |
|---|---|---|
| [`spec-gated-workflow/`](spec-gated-workflow/) | One spec per feature, with a human approval gate on every spec. | Will take one import of the version tested in the reference app (v4.0.0), then be frozen. |
| `batch-design-workflow/` | Several features designed at once in Claude Design, then built by autonomous AI cycles. Machine gates decide when a cycle is done, and a human steps in only when an error appears or at a prod release. | Planned. Will be forked from `spec-gated-workflow-v4.0.0`. This is the active method. |

All templates share one stack: Next.js (App Router), TypeScript, Prisma, SQLite, Tailwind, shadcn/ui, Vitest, Playwright, and Docker Compose with a devcontainer. A template is not stack-agnostic. Its rules are specific enough for a reviewer agent to cite them and refuse a change.

## Using a template

1. Pick a template tag, for example `spec-gated-workflow-v3.0.0`.
2. Copy that template folder, including its hidden `.claude/` directory, into an empty application repository.
3. Follow the template's own `README.md`, which covers the vision file, the `specs/init.md` bootstrap and the first feature.

An `install.sh <template> <app-dir>` script and a `method.lock` file are planned. The lock file records which template and tag an app was installed from, so the app can be updated later.

## Repository layout

```
spec-gated-workflow/      template (ships into apps)
batch-design-workflow/    template, not created yet
decisions/                method decisions: short log + rationale (MD-nnn)
journal/                  roadmap and backlogs for designing the methods
workbench-changelog.md    what was done, one entry per workbench tag
CLAUDE.md                 entry point for Claude Code sessions in this workbench
```

Nothing in `decisions/` or `journal/` ships into a template. The decisions and notes about designing the methods stay here. Each template carries only its own rules and its own `CHANGELOG.md`.

## Versioning

- Each template is tagged on its own: `<template>-v<semver>`, for example `spec-gated-workflow-v3.0.0`.
- The workbench is tagged at milestones: `workbench-v<semver>`, described in [`workbench-changelog.md`](workbench-changelog.md). Apps never reference workbench tags.

## How the methods evolve

Methods are tested on a real application, Synfactu, a self-hosted invoicing app. What works there comes back here. A rule moves into a template only when it is generic to the stack, never when it is a product choice. Binding method decisions are logged in [`decisions/method-decisions.md`](decisions/method-decisions.md), and the reasons behind them are in [`decisions/method-rationale.md`](decisions/method-rationale.md). What comes next is in [`journal/roadmap.md`](journal/roadmap.md).

## License

Each template carries its own `LICENSE` (AGPL-3.0 for `spec-gated-workflow/`).
