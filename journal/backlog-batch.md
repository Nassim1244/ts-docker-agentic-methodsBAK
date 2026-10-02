# Backlog - batch

Backlog for `batch-design-workflow/`, the active method (MD-007), plus workbench items. Batch forks from `spec-gated-workflow-v4.0.0` once the gated import is done (see `backlog-gated.md`).

Each item names where it lands:
- **shared**: rules gated also carries (security, Prisma and architecture ownership, commits, tech stack and Docker, init). Applied in batch, then logged in `backlog-gated.md` while gated is frozen.
- **cycles**: batch only.
- **workbench**: workbench root, never shipped in a template.

Heavy items get their own focused session. Light ones are batched.

## Open decisions (grill before implementing)

- [x] Cloud sessions and concurrency: MD-003, MD-004, MD-005.
- [x] Synfactu product ADs: MD-006.
- [ ] **Testing philosophy for cycles**: the right ratio between testing everything and relying on user feedback; what is automated, logic vs UI. Dedicated grill session. Already agreed: logic tests derived from spec business rules. Constraint from MD-004: e2e runs locally only.

## Fork

- [ ] **cycles** Create `batch-design-workflow/` from `spec-gated-workflow-v4.0.0`.

## Shared

- [ ] Orchestrator becomes a main-session skill (`/orchestrate`): subagents cannot spawn subagents. It carries the claim check from MD-003.
- [ ] Cloud setup script (MD-004): pinned Node and pnpm from `policy_techstack.md`, frozen install, `prisma generate`. Gates only, no Docker.
- [ ] Quick committer: a light `/commit-quick` mode that only blocks secrets.
- [ ] Checks run twice (implementation and commit): run once and record the result. Commit re-checks only files changed since.
- [ ] Decisions: apply MD-002.
  - Add a `# Decision` section to the spec template: Functional / Technical / Design, list form, no IDs.
  - Each domain gets a short log and a rationale file: `specs/functional/functional-{decisions,rationale}.md`, `specs/technical/technical-{decisions,rationale}.md`, `design/design-{decisions,rationale}.md`. Replaces `ai-rules/decisions.md` and `functional-decisions.md`.
  - Load lists: the product owner reads FD, the designer FD and DD, the architect FD, DD and AD. Remove the decision log from the reviewer, auditor, dependency and coder. Rationale is opened only to change a rule (possibly as a skill).
  - Each owner promotes binding spec decisions to its log at the end of its step. The AI proposes DD entries at step 4 and the user confirms.
  - Check agent: alert when a log passes about 40 lines.
  - The template ADs imported in gated v4.0.0 (including the MD-006 lines) become the seeded `technical-decisions.md`.
- [ ] Review tags pollute the log: replace them with `review/` files (status on the first lines).
- [ ] Reviewer effort per context: review profiles (post-architect, post-implementation, release). For example, no e2e after the architect.
- [ ] Prototype fidelity: the coder stays as close as possible to the Claude Design prototype, and the reviewer checks it.
- [ ] Widgets registry: add the architect, and improve the entry format (what / first defined / used by / contract / status / known gap).
- [ ] Claude Design after the product-owner spec, replacing most of the `@designer` work.
- [ ] ai-method: split into separate `check` and `update` agents. Apps keep a `method.lock` (template name, tag, locally adapted files), and update does a 3-way merge.

## Cycles

- [ ] Batch flow: full functional spec → cut into features → Claude Design (exported code/HTML in `design/<feature>/`) → spec and features updated to match the design → architect once per batch → autonomous cycles → manual UI test → quick fix cycles.
- [ ] Cycle driver script: one headless `claude -p` session per cycle, with state kept in files and git. Needs a permission allowlist in the devcontainer. Checks the feature claim before starting (MD-003).
- [ ] Cycle exit on machine gates only (typecheck, lint, logic tests, build).
- [ ] Cloud branches (MD-003): `cloud/feat/<feature-id>`, one unmerged session per feature keyed on `Refs:`, rebase onto main and fast-forward, gates re-run only if main moved. Rewrite the batch branching section of `policy_commits.md` (trunk for local, cloud branches for cloud).
- [ ] Migration on a session branch (MD-005): automatic architect check before any merge, `Risk: schema` trailer. The architect can be called back during a batch.
- [ ] Commit traceability: cycle ref in the commit title, `Refs: <feature-id>`, and a `Risk: schema|auth|deps` trailer when relevant. Git tags only for batches and prod releases.
- [ ] Prod release gate: review `Risk:` commits since the last prod tag, plus a migration dry-run.
- [ ] Migration dry-run script: dump from the prod container, restore into a throwaway DB, `migrate deploy`, destroy. Everything stays local.
- [ ] Design in a separate git worktree while the AI codes on trunk.
- [ ] Bring batch to Synfactu: migration plan from Synfactu's 4.1.0 method to the batch template.

## Workbench

- [ ] Layout: `batch-design-workflow/` still to create. Releases/ becomes redundant once versions are tags.
- [ ] Note: commit `c29c71f` flattened the template to the root. The layout reverses it.
- [ ] `install.sh <template> <app-dir>`: copies the template and writes `method.lock`.
- [ ] Drift check script: diffs the files meant to be identical across templates and reports divergence. Lower priority while gated is frozen.
- [ ] Method changelog and README live at the workbench root, per template, never shipped into app repos.
