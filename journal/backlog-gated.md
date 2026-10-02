# Backlog - gated

Backlog for `spec-gated-workflow/`. Per MD-007, gated takes one import of Synfactu's method, is tagged v4.0.0, then frozen. After that, this file only collects observations and shared fixes that landed in batch, kept in case gated is updated later.

Tags: **gated** (gated only), **shared** (landed in batch first, recorded here for a later port).

## Import (next session)

- [ ] **gated** Import Synfactu's method 4.1.0 (`G:\Programs\SynfactuDEV`: `ai-rules/`, `ai-agents/`, `CLAUDE.md`, `docker/`, `.devcontainer/`, `specs/init.md`, templates) into `spec-gated-workflow/`. Strip product content: Synfactu's ADs, specs, context and design.
  - This brings in work Synfactu already did: Prisma 7 (AD-020), the prod-image migration (AD-025 to AD-028), the devcontainer fixes (2.9.1, 2.11.0), `AGENTS.md` (2.10.0), the ai-method scope, the `RM-XXX` roadmap ids (2.11.1, 2.12.0), architect traceability, the widget registry (4.0.0), and cloud sessions with the one-session-per-spec preflight (4.1.0).
  - Apply MD-006. Kept ADs, renumbered in the template's sequence, each with a policy rule and an AD line: AD-023 `@map` naming, AD-031 computed defaults with the AD-033 exception clause, AD-034 explicit join models, AD-035 time of day in minutes, AD-020, and AD-025 to AD-028 merged into one line. AD-018 is dropped.
  - Make init step 6 conditional (Money/Duration/Rate, rounding and day length only if the app handles money or time).
  - Back-port the `/force` override and the G1 to G6 descriptive gate names (template 2.10.0, 3.0.0).
  - Fix the stale `D-013`/`D-014` IDs in `.gitignore` and `TEMPLATE.md` (should be `AD-`).
  - Write the `CHANGELOG.md` entry and tag `spec-gated-workflow-v4.0.0`. Then gated is frozen.

## Observations (not planned, kept for a possible later update)

- [ ] **gated** More commits per phase: one each for the functional spec (product owner), the design, and the technical spec (architect).
- [ ] **gated** Commit during the coder → tester → reviewer loop, so steps are visible.
- [ ] **gated** Gated's orchestrator is a subagent, but subagents cannot spawn subagents. The fix (orchestrator skill, carrying the 4.1.0 preflight) lands in batch first.
- [ ] **shared** Shared fixes land in batch after the fork. Add one line here per fix as it lands, citing the batch commit or tag.
