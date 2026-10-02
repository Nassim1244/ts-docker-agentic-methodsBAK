# Backlog

Method-workbench backlog. Each item names where it lands:
- **shared**: both templates. Fixed in `spec-gated-workflow/` first, then inherited by `batch-design-workflow/` at the fork, and kept aligned by the drift check.
- **gated**: `spec-gated-workflow/` only.
- **cycles**: `batch-design-workflow/` only.
- **workbench**: workbench root, never shipped in a template.

Heavy items get their own focused session. Light ones are batched.

## Open decisions (grill before implementing)

- [ ] **Cloud sessions + concurrency** (synfactu 4.1.0: `cloud/feat/<x>` branches, one unmerged session per spec). Conflicts with trunk-only cycles and affects the headless per-cycle script and design worktrees. Target: shared or gated?
- [ ] **Product ADs promoted to policies in synfactu**: `@map` snake_case naming (AD-023), defaults computed rather than seeded (AD-031), explicit join models (AD-034), time stored as integer minutes (AD-035). Sort into generic stack conventions (template) or synfactu-only.
- [ ] **Testing philosophy for cycles**: what is automated, logic vs UI. Dedicated session. Already agreed: logic tests derived from spec business rules.

## Shared

- [ ] Orchestrator becomes a main-session skill (`/orchestrate`): subagents cannot spawn subagents.
- [ ] Quick committer: a light `/commit-quick` mode that only blocks secrets.
- [ ] Checks run twice (implementation and commit): run once and record the result. Commit re-checks only files changed since.
- [ ] Decisions: apply MD-002 to both templates.
  - Add a `# Decision` section to the spec template: Functional / Technical (plus Design in batch-design), list form, no IDs.
  - Each domain gets a short log and a rationale file: `specs/functional/functional-{decisions,rationale}.md`, `specs/technical/technical-{decisions,rationale}.md`, `design/design-{decisions,rationale}.md`. Replaces `ai-rules/decisions.md` and `functional-decisions.md`.
  - Load lists: the product owner reads FD, the designer FD and DD, the architect FD, DD and AD. Remove the decision log from the reviewer, auditor, dependency and coder. Rationale is opened only to change a rule (possibly as a skill).
  - Each owner promotes binding spec decisions to its log at the end of its step. In batch-design, the AI proposes DD entries at step 4 and the user confirms.
  - Check agent: alert when a log passes about 40 lines.
  - Sort synfactu's 35 ADs into binding log lines and rationale.
- [x] Method decisions vs product decisions: separate numbering (MD-001, MD-002 in the workbench `decisions/`). This resolves the AD-016 collision.
- [ ] Review tags pollute the log: replace them with `review/` files (status on the first lines).
- [ ] Reviewer effort per context: review profiles (post-architect, post-implementation, release). For example, no e2e after the architect.
- [ ] Prototype fidelity: the coder stays as close as possible to the Claude Design prototype, and the reviewer checks it.
- [ ] Widgets registry: start from synfactu 4.0.0 (designer, coder, reviewer, testing already wired). Add the architect, and improve the entry format (what / first defined / used by / contract / status / known gap).
- [ ] Claude Design after the product-owner spec, replacing most of the `@designer` work.
- [ ] `AGENTS.md` handling (synfactu 2.10.0): Next 16 writes into `CLAUDE.md` otherwise, and `create-next-app` overwrites it. `init.md` must create `AGENTS.md` first.
- [ ] Devcontainer fixes (synfactu 2.9.1, 2.11.0): drop the node feature, drop `NODE_ENV`, chown `node_modules` and `/data`, use a literal image tag, and add the `stat` gate in `init.md`.
- [ ] Prisma 7 (synfactu 2.11.0, AD-020): driver adapter, URL in `prisma.config.ts`, no initial migration, `src/generated/` as build output. The template `init.md` currently fails.
- [ ] Prod image migration (synfactu AD-025 to AD-028, `start_server.sh`): self-contained `prisma migrate deploy` in the runtime image.
- [ ] ai-method scope: `.gitignore`, `AGENTS.md`, `docker-compose.dev.yml` (synfactu).
- [ ] ai-method: split into separate `check` and `update` agents. Apps keep a `method.lock` (template name, tag, locally adapted files), and update does a 3-way merge.
- [ ] Roadmap `RM-XXX` ids, with no spec index pre-assigned in the roadmap (synfactu 2.11.1, 2.12.0).
- [ ] Architect traceability: every technical-spec claim traces to an AD, a policy or a user answer (synfactu).
- [ ] Template `.gitignore` cites `D-013` and `D-014`, a stale ID scheme. It should be `AD-013` and `AD-014`. Synfactu's `TEMPLATE.md` uses `D-XXX` too.
- [ ] Back-port to synfactu-based gated: `/force` override and the G1–G6 descriptive gate names (template 2.10.0, 3.0.0).

## Gated

- [ ] More commits per phase: one each for the functional spec (product owner), the design, and the technical spec (architect).
- [ ] Commit during the coder → tester → reviewer loop, so steps are visible.

## Cycles

- [ ] Batch flow: full functional spec → cut into features → Claude Design (exported code/HTML in `design/<feature>/`) → spec and features updated to match the design → architect once per batch → autonomous cycles → manual UI test → quick fix cycles.
- [ ] Cycle driver script: one headless `claude -p` session per cycle, with state kept in files and git. Needs a permission allowlist in the devcontainer.
- [ ] Cycle exit on machine gates only (typecheck, lint, logic tests, build).
- [ ] Commit traceability: cycle ref in the commit title, `Refs: <feature-id>`, and a `Risk: schema|auth|deps` trailer when relevant. Git tags only for batches and prod releases.
- [ ] Prod release gate: review `Risk:` commits since the last prod tag, plus a migration dry-run.
- [ ] Migration dry-run script: dump from the prod container, restore into a throwaway DB, `migrate deploy`, destroy. Everything stays local.
- [ ] Design in a separate git worktree while the AI codes on trunk.

## Workbench

- [ ] Layout: root `CLAUDE.md` for method design, `spec-gated-workflow/`, `batch-design-workflow/`, `journal/`, `decisions/`. Versions as git tags per template (`spec-gated-workflow-vX`, `batch-design-workflow-vX`). Releases/ becomes redundant.
- [ ] Note: commit `c29c71f` flattened the template to the root. The layout reverses it.
- [ ] `install.sh <template> <app-dir>`: copies the template and writes `method.lock`.
- [ ] Drift check script: diffs the files meant to be identical across templates and reports divergence.
- [ ] Method changelog and README live at the workbench root, per template, never shipped into app repos.
