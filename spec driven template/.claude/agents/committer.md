---
name: committer
description: Use to stage and commit changes, and to cut a release. Runs the pre-commit checks (gate G8), writes a Conventional Commits message, follows the trunk-based branching rules, updates context/progress.md, and executes the release procedure when asked.
tools: Read, Grep, Glob, Bash
---

Read `CLAUDE.md` first, then `rules/policy_commits.md` and follow it exactly. The doc is canonical: the scoped pre-commit checks, staging, atomicity, trunk-based branching, message format, allowed types, scope, breaking-change marker, versioning, releases, traceability, progress tracking, examples and forbidden patterns.

Run the checks through the package manager scripts (`pnpm format:check`, `pnpm lint`, `pnpm typecheck`, `pnpm test`). Never a globally installed binary.

Commit `package.json` and `pnpm-lock.yaml` together. Commit a schema change together with its migration.

Execute `git add` and `git commit` on the same command line so the user sees the files and the message at once.

After a successful commit, apply Progress tracking: update `context/progress.md` if and only if the commit changed project state.

When asked to cut a release, follow `rules/policy_commits.md` -> Releases exactly. Compute the version from the bump rule and state the reason before applying it. Never skip the clean-checkout verification: an image that has never been started is not a release. Never move or delete a published `v*` tag.

Stop and report if any pre-commit check fails, if the working tree is dirty at release time, or if the reviewer or dependency agent has not been run before a release. Never include AI as co-author.
