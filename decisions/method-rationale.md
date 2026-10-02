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

## MD-003 Cloud sessions and concurrency in both templates
- **Date**: 2026-10-02
- **Why**: The user needs Claude Code cloud sessions in both methods. Synfactu 4.1.0 tested the gated version. A `cloud/` prefix makes a branch's origin visible. A spec may be claimed by only one unmerged session, and the orchestrator preflight checks this against the `Implements specs/...` line. The claim releases when the branch merges, so a sequential handoff between local and cloud is unaffected. A statement that holds in one environment only starts with `Local session only:` or `Cloud session only:`.
- **Batch-design**:
  - The strict trunk-only rule is relaxed for cloud sessions only. Local sessions still commit on trunk.
  - A cloud session runs one feature's cycles on `cloud/feat/<feature-id>`.
  - The claim unit is the feature, keyed on the `Refs: <feature-id>` trailer. Two sessions can build different features of one batch in parallel, but never the same one.
  - When the gates pass, the branch rebases on main. If main has not moved, the result is a fast-forward of commits that already passed, so the gates don't run again. If the rebase replayed commits onto a newer main, the gates run again first.
  - History stays linear and the trailers stay intact.
- **Limit**: a claim only sees pushed branches. Unpushed local trunk work is invisible to a cloud session.
- **Rejected**:
  - Trunk-only with no cloud sessions: the user needs them.
  - Cloud in gated only: batch has the same need.
  - A PR merged by a human: adds an approval stop the cycles philosophy avoids.
  - A branch per batch: long-lived, and conflicts grow.
  - Claiming trunk or the whole batch: serialises everything.
  - No claim: duplicate work only surfaces at rebase.
  - Re-running the gates on a fast-forward: the commits are identical to the ones that passed.
- **Constrains**: The gated preflight lives in the orchestrator, so it moves into the orchestrator skill when that lands. The batch driver script must check the claim before starting a feature.

## MD-004 Minimal cloud setup script
- **Date**: 2026-10-02
- **Why**: A cloud session runs in Anthropic's managed VM, not in the devcontainer, so nothing installs the pinned Node and pnpm there. Synfactu documented the gap without filling it.
  - The script does not replicate the devcontainer. It only brings the VM to what the machine gates need: pinned Node and pnpm, `pnpm install --frozen-lockfile`, `prisma generate`.
  - SQLite is a file, so no database service is needed.
  - The same script ships in both templates. That is what "shared" means here, not that the two environments are alike.
- **Rejected**:
  - Replicating the devcontainer: there is no Docker in the cloud VM, and the gates don't need it.
  - Documenting only: every app would rewrite the same script.
- **Constrains**: e2e tests and anything that needs Docker run locally only. The script reads its versions from `policy_techstack.md` and never keeps its own copies.

## MD-005 Schema changes during a batch
- **Date**: 2026-10-02
- **Why**: Parallel feature sessions (MD-003) that each generate a Prisma migration produce timestamp-ordered migrations that can conflict.
  - The architect computes the schema for the whole batch before the cycles. Cutting features can still reveal new needs, so the architect can be called back during a batch.
  - Any migration on a session branch therefore gets an architect check before merging, whether the merge is a fast-forward or not. The check validates it against the batch schema and main's latest migrations, and regenerates it if main moved.
  - The check is automatic, done by the AI architect, in line with "review on error". The `Risk: schema` trailer brings it to the human at the prod release gate.
- **Rejected**:
  - Regenerating migrations automatically on rebase, with no check: rewrites an artefact blindly.
  - Serialising every feature that touches the schema: removes parallelism.
  - A human stop per migration: the prod release gate already reviews `Risk: schema` commits.

## MD-006 Triage of Synfactu product ADs
- **Date**: 2026-10-02
- **Why**: Synfactu promoted some of its own ADs into its policies. A template takes one only when it is a generic stack convention, not a product choice. Each kept item is a real choice with rejected options. Under MD-002 it therefore gets a policy rule and one line in the template's seeded `specs/technical/` log, numbered in the template's own sequence. The rationale names the Synfactu source, for example "from Synfactu AD-023".
- **Kept**:
  - AD-023: PascalCase models, camelCase fields, snake_case tables and columns via `@map` and `@@map`. It is decided once, when the schema is first created. Changing it later means a rename migration.
  - AD-031: the repository computes bootstrap defaults instead of seeding them as rows. AD-033 becomes its exception clause: a user-editable reference list that must exist in production is inserted by the migration, never by `seed.ts`.
  - AD-034: every many-to-many relation uses an explicit, named join model, never Prisma's implicit one.
  - AD-035: a wall-clock time of day is stored as integer minutes since midnight, consistent with AD-007's integer-minutes rule.
  - AD-020: Prisma 7 with a driver adapter, the URL in `prisma.config.ts`, and the generated client as build output.
  - AD-025 to AD-028, merged into one line: `prisma migrate deploy` runs self-contained in the release image. AD-027 was already superseded by AD-028.
- **Synfactu-only**: AD-018. Half-up rounding and a 420-minute day come from French consulting billing.
  - Checking showed the template carries the same bias: its init step 6 builds `Money`, `Duration` and `Rate` and asks for a day length.
  - That step becomes conditional. Init asks whether the app handles money or time, and only then builds the value objects and asks for the rounding convention and day length.
  - AD-007's integer-storage rule stays generic.
- **Rejected**:
  - Keeping Synfactu's numbers: leaves gaps, and collides with existing template ADs.
  - One line per Synfactu AD for 025 to 028: four lines for one choice.
  - Fix only, with no AD line: the rejected options would be lost.
  - Template defaults of half up and 420 minutes: product bias.
  - Keeping the money init step mandatory: wrong for apps that handle neither money nor time.

## MD-007 Batch is the target, gated imported then frozen
- **Date**: 2026-10-02
- **Why**: The user's goal is to bring the batch method to Synfactu, not to keep developing gated.
  - Synfactu's fork (2.11 to 4.1.0) is the version tested on a real project.
  - Importing it once into `spec-gated-workflow/` gives gated its tested state, and gives batch the best base to fork from. The import strips product content, applies MD-006, and back-ports `/force` and the G1 to G6 gate names.
  - Bringing batch to Synfactu then becomes a smaller diff, and the stripping is needed for the fork anyway.
  - After the v4.0.0 tag, gated is frozen. The observations made while using gated in Synfactu are kept in `journal/backlog-gated.md` for a possible later update.
- **Amends MD-001**: while gated is frozen, the rule that a shared-rule change is applied to every template in the same commit is suspended. Shared changes land in batch and get a line in `backlog-gated.md`.
- **Journal**: two backlogs (`backlog-batch.md` and `backlog-gated.md`) and one `progress.md`. Each progress entry starts with `[batch-nnn]` or `[gated-nnn]`.
- **Rejected**:
  - Forking batch from the current template: the 2.11 to 4.1.0 changes would have to be imported again, and the diff to Synfactu grows.
  - Forking batch straight from Synfactu: gated would keep an untested state, and the stripping would happen without a named, tagged base.
  - Maintaining gated in parallel: effort the user does not plan to spend.
