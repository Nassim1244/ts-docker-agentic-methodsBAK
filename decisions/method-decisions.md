# Method decisions

Read this before proposing or changing anything about how the methods are designed.
- Each line is a decision currently in force that constrains future work, with the options it rejected.
- The explanation for each is in `method-rationale.md`, under the same ID. Open that file only when changing a decision.
- Log a decision here only if a future session could break it without knowing. Otherwise it belongs in `journal/`.
- When a decision is superseded, remove its line from this file. Its rationale entry stays, and the entry for the new decision names the one it supersedes.
- IDs are `MD-nnn`, allocated in order and never reused.
- If this file grows past about 40 lines, alert the user: some lines probably belong in a rule or should be superseded.

- MD-001 The workbench holds independent, self-contained templates named by philosophy and versioned with git tags per template. Rejected: evolving v3 in place, one shared ai-rules with two workflows, folders named by version.
- MD-002 Decisions are recorded in two files per domain: a short log (one line per binding decision, with what it rejected) and a rationale file. The domains are FD in `specs/functional/`, AD in `specs/technical/`, DD in `design/`, and MD in the workbench `decisions/`. Rejected: one long decisions.md read by every agent, one file per decision.
