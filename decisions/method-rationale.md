# Method rationale

The explanation behind each line in `method-decisions.md`. Written for humans. The AI opens it only when changing a decision, and reads only that decision's section.

Append-only. A superseded decision keeps its section here, and a `Superseded by MD-nnn` line is added under its title.

## MD-001 Workbench with independent templates
- **Date**: 2026-10-02
- **Why**: v4 is a change of philosophy, not a revision. It moves from approval gates on every spec to batches of designed features built in autonomous cycles, with review only when an error appears. The workflow, the gates, how often review happens and the testing all differ. `spec-gated-workflow/` still needs fixes (the orchestrator cannot be a subagent), so it is maintained, not archived.
- **Rejected**:
  - Evolving v3 in place: we would lose a maintained gated method.
  - One shared `ai-rules/` with two workflow files: templates would no longer be self-contained, and installing one would need an assembly step.
  - Folders named by version (`v3/`, `v4/`): every major version would mean another copy. Versions go in tags instead.
- **Constrains**: Rules that must stay identical in every template (security and data sovereignty, Prisma and architecture ownership, commits and versioning, tech stack and Docker) are copied into each template. A change applies to every copy in the same commit, and a drift check reports any divergence. Notes and rationale about designing the method stay in the workbench and never ship in a template.

## MD-002 Two-file decision model per domain
- **Date**: 2026-10-02
- **Why**: The old `decisions.md` mixed every decision with long rationale, and the reviewer, architect and auditor loaded it on every run. Most of that content is irrelevant to the task at hand. Rules already live in the policies. Decisions matter to the AI in two situations only. First, when proposing options, so it doesn't re-offer what was rejected. Second, when changing a rule, so it doesn't remove a safeguard whose purpose isn't obvious.
- **The model**:
  - A spec's `# Decision` section records every decision taken for that feature.
  - The agent that owns the domain copies only the decisions that bind future work into its domain's short log, as one line: what was chosen, and what was rejected. Example: `AD-036 Invoice numbers allocated in a DB transaction. Rejected: client-side counter.`
  - The rationale file holds the explanation, which humans read. The AI opens it only to change a rule.
- **Domains and readers**:
  - FD (functional): owned by the product owner, in `specs/functional/`.
  - DD (design): owned by the designer, in `design/`. In batch-design, the AI proposes DD entries at step 4 (the spec is updated to match the design) and the user confirms them.
  - AD (technical): owned by the architect, in `specs/technical/`.
  - MD (method): workbench only.
  - Each agent that makes choices reads its own log and the logs of the domains before it: the product owner reads FD, the designer FD and DD, the architect FD, DD and AD. The coder, tester, reviewer and committer read no decision log, only the policies.
- **Rules**:
  - Not every policy rule needs a decision behind it, only the ones with a real choice involved.
  - A superseded line is removed from the log and kept in the rationale.
  - Past about 40 lines, alert the user instead of enforcing a hard cap.
- **Rejected**:
  - One long `decisions.md` read by everyone: this was the token problem.
  - A short log that restates rules: duplicates the policies.
  - One file per decision: too many files.
  - Dropping the rationale: changing a rule safely needs to know why it exists.
- **Constrains**: Both templates move to this model (backlog). Synfactu's 35 ADs need to be sorted into binding entries and history.
