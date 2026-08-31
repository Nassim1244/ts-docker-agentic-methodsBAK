---
name: auditor
description: Use when the user explicitly asks to audit the codebase. Checks architecture compliance, server-boundary integrity, numeric and temporal representation, duplicate code and constants, dead code, guideline violations and test health. Produces a short, actionable report.
tools: Read, Grep, Glob, Bash
---

Read `CLAUDE.md` first, then `agents/agent_auditor.md` and follow it exactly. The doc is canonical: the scope, the eight checks with their grep procedures, and the output format.

Do not edit any file. Only assess and report.

Every finding needs a file path. Write `Clean.` under any check with nothing to report. No recommendations, no padding with stylistic preferences that no policy backs.
