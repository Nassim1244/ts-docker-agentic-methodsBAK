# SynFactu — Review of the Functional Specification (V1)

> Review of `../docs/_hist/Spécification fonctionnelle v1.md`, `../docs/_hist/MCD.md` and `Bilan et points ouverts.md`, cross-checked against `Besoin/Description besoin.txt`, `Besoin/Questions-Réponses.md`, `Besoin/Backlog.md`, `Tech stack/synfactu tech stack.md` and the two example workbooks (`Exemple 2026-Comptabilité v2.xlsx`, `Exemple time Tracker - 2026.xlsx`).
>
> Findings are graded: **[A] blocking** (the model cannot produce a stated feature — fix before coding), **[B] missing scope** (in the source need, absent from the spec), **[C] contradiction / ambiguity** (fixable by a sentence, but must be decided).

---

## A. Blocking — a stated feature is not computable from the model

### A1. `MICRO_INVOICE` has no date at all
§6.2 states the micro payment delay is counted **from the invoice date**, and §6.5 flags **overdue** invoices. The entity carries only `invoicing_month` + `year`. There is no `issue_date`, no `sent_date`, no `due_date` and no payment-terms field. `expected_payment` is an **amount** (Excel column "Paiement attendu"), not a date.

→ Add `issue_date`, `sent_date` (nullable), and either `due_date` or `payment_terms_days` (default in settings, overridable). "Overdue" = `today > due_date AND status ≠ Payée`. Same for `PORTAGE_DECLARATION` (its reference date per §6.2 is the first day of the month billed, but a due date is still needed for the overdue flag).

### A2. `MICRO_INVOICE` is not linked to a mission
§5.4 lists the recorded fields as "number, invoicing month, year, client, **mission**, amount HT…", and RG-14's numbering embeds the mission (`2026-01-001_Client_mission`). The MCD links `MICRO_INVOICE` to `CLIENT` only. The Excel "Factu micro" sheet has a Mission column.

→ Add `id_mission` (0,1 — an invoice may group several missions of one client; decide 0,1 vs a link table). Same question for `PORTAGE_DECLARATION`.

### A3. No `PAYSLIP` entity, although the spec depends on one
§5.5 and RG-22 both say the portage real rate is derived "once the **payslip** is entered", and Q8 answered "saisie manuelle depuis le bulletin". Nothing in the MCD represents a payslip. §5.5 also writes "link it to either a micro invoice **or a portage payslip/declaration**", conflating two different objects.

→ Either add `PAYSLIP` (month, year, gross, net, employer charges, portage company) with `PAYMENT → PAYSLIP`, or state explicitly that the payslip is not stored and that the user types the real rate on the payment. Pick one; today the three documents say three different things.

### A4. Portage payment cardinality is wrong
RG-04 forces a payment to settle **exactly one** declaration. But a portage salary is **one monthly payment covering every partner and every end client of that month**. The Excel "Déclaration portage" sheet is a matrix month × (partner, end client) — in April 2026, two different partners are both declared and both settled by the same salary.

→ Either (a) make `PORTAGE_DECLARATION` one row per month, with partner/client as **breakdown lines** (new `PORTAGE_DECLARATION_LINE` entity), or (b) make `PAYMENT ↔ PORTAGE_DECLARATION` many-to-many with an allocated amount. Option (a) matches the Excel and keeps RG-04 intact; recommended.

### A5. Missing "billed duration", distinct from worked and rounded duration
The Excel "Temps passé" sheet has **three** durations: `Worked`, `Worked rounded`, `Temps facturable` — and the billed one can **exceed** the worked one (row: worked 02:45 → rounded 02:45 → billed 03:30 for an on-site session). `Heures` / `Jours` / `CA` are all derived from *Temps facturable*, not from the rounded worked time.

The MCD has only `duration` + `rounded_duration` + a `billable` boolean, so `computed_revenue` cannot be reproduced, and RG-06 / §6.3 (real billing rate = billed vs worked) has no numerator.

→ Add `billed_duration` (nullable, defaults to `rounded_duration`, manually overridable). `computed_revenue` derives from `billed_duration`; the real billing rate from `billed_duration / duration`.

### A6. No hours→days conversion rule
Every figure in the consolidation view (§5.2: "9,5h - soit 1,36 j") and every `computed_revenue` depends on it. The workbook uses **7 h = 1 day** (9.5/7 = 1.357; 14/7 = 2), and the "Theures" column of the Clients sheet is simply `TJM / 7` (700→100, 650→92.86, 500→71.43). Nothing in the spec or the MCD states this.

→ Add `hours_per_day` as a setting (default 7). Decide whether it can be overridden **per client** — the Excel stores an hourly rate per client, so this is a real question, not a formality.

### A7. No hourly billing type
`billing_type` has three values, all day-based or forfait. But the formation time tracker bills a **flat 65 €/h** — not `TJM / hours_per_day`. `RATE.hourly_rate` exists in the MCD but no billing type consumes it, and no rule says when it wins over `tjm`.

→ Add a fourth `billing_type` (`horaire`) driven by `RATE.hourly_rate`, or state that hourly rates are always derived from the TJM (which the time tracker contradicts).

### A8. Two different "non-billable" notions collapsed into one boolean
The Excel distinguishes:

- **"Non facturable" = X** on an entry of a *billable* mission — preparation time, TJM present, CA = 0 (the prep rows of an on-site mission);
- a **non-billable client** — the internal "non facturable" entries, TJM = 0, internal/commercial time.

Both map to `TIME_ENTRY.billable = false` today. They must be told apart: the first is what feeds the real billing rate (§6.3, RG-06), the second is overhead that belongs in a separate bucket. Additionally RG-05 says "a non-billable **client/mission**" but `MISSION` has no `billable` flag — only `CLIENT` does.

→ Either add `MISSION.billable` and a distinct `TIME_ENTRY.unbilled_reason` (`prep` / `internal` / `commercial`), or reuse the tag taxonomy for the second case and say so explicitly.

### A9. Cardinality section is incomplete, and the TIME_ENTRY XOR has no rule
MCD §3 omits the two "bills" relations that are in the Mermaid diagram: `MICRO_INVOICE (0,1) — bills — TIME_ENTRY (0,n)` and `PORTAGE_DECLARATION (0,1) — bills — TIME_ENTRY (0,n)`. And RG-04 states the XOR for `PAYMENT` only — there is no equivalent rule for `TIME_ENTRY.id_invoice` / `id_declaration`, which, unlike PAYMENT, must also allow **neither**, since that is exactly the billing backlog of RG-11.

→ Add the two cardinalities and an RG-26: "a TIME_ENTRY is linked to at most one of id_invoice / id_declaration, never both; unlinked billable entries constitute the billing backlog."

### A10. `TIME_ENTRY.invoicing_month` has no year
`MICRO_INVOICE` and `PORTAGE_DECLARATION` both carry `month` + `year`; `TIME_ENTRY` carries `invoicing_month` alone. The workbook has a dedicated `Année` column precisely because the two diverge: work dated 2025-10-19 is affected to **2026.01**. RG-16's pre-selection ("client/mission/month") would collide across years.

→ Store `invoicing_period` as `YYYY-MM` (single field, recommended) or add `invoicing_year`. Apply the same normalization to `MICRO_INVOICE.invoicing_month`, `PORTAGE_DECLARATION.month`, `PAYMENT.month`, `URSSAF_RECORD.month` — all are currently free strings ("Janvier"), which will not sort, group or join reliably.

---

## B. Missing scope — present in the need, absent from the functional spec

The first five come straight from `Description besoin.txt` and appear in **none** of §1.3, §3, §5 or §10. B1 is explicitly flagged there as "il faut le prévoir tout de suite".

### B1. CSV import with column mapping and dry run
Stated flow: read the CSV → map columns to database fields → **dry run showing what will happen** → user validates. Deferred in time, but it must be designed in now (it constrains the API and the write layer). It also very likely **is** the Excel history migration of §8 — decide whether §8 and this are one feature or two.

### B2. Data export (CSV or JSON) for backups
Absent from the spec. Interacts with §9 "Data integrity" and with the tech-stack backup strategy.

### B3. PDF report builder
Stated need: choose a title, then add a chart or a table under it, manual page breaks, WYSIWYG, **pagination respected on export**. Absent from the functional spec — yet the tech stack has already selected `@react-pdf/renderer` for exactly this. Note this is *not* the invoice PDF, which §1.3 correctly excludes.

### B4. Internal data versioning with diff and restore
Stated need: periodic internal JSON snapshots; the user can recall a previous version and see the diff between the two. The spec has an **audit log** (§7, §9), which is a different thing (who changed what, for the assistant role). Both are wanted; say which covers what. Also: the audit log has **no entity in the MCD**, despite §7 promising it is designed in from the start.

### B5. AI analysis (Mistral API or Ollama)
In the need ("analyser les données avec l'IA") and in the tech stack (description generation, reminder-email drafting, client history summary). Absent from the functional spec. Low priority, but it belongs in §10 so the data model does not preclude it.

### B6. Product ambition (resale) is not in the functional spec
The tech-stack document states the software is **intended to be resold to other one-person companies as a self-hosted subscription licence**. The functional spec describes a personal tool for one consultant (§1.1, §9 "French, euro, French fiscal rules"). This changes real requirements: per-instance company identity, configurable fiscal parameters instead of hardcoded ones, onboarding, licence check. At minimum, state it as a product constraint in §1 so V1 does not hardcode one consultant's setup.

### B7. No settings / company entity
§5.1 and RG-17 refer to "a configurable application setting" (rounding step) with nothing to store it in. Also needed: `hours_per_day` (A6), VAT thresholds (B11), invoice numbering pattern, default payment terms (A1), company identity, URSSAF periodicity (B9).

→ Add a `SETTING` (key/value) or `COMPANY_PROFILE` entity.

### B8. Mission category taxonomy is not modeled
`Besoin/Backlog.md` lists **Formation école / Formation pro / Conseil**. `MISSION.is_training` is a boolean and cannot express it (RG-25). The stated goal — "easily list all training missions over a year" — is served, but the school/professional split is not.

→ Either replace `is_training` with a `mission_category` reference table (recommended, costs nothing now), or record that the taxonomy is knowingly deferred.

### B9. URSSAF periodicity is hardcoded to monthly
§5.7 and RG-08 assume one record per month. French micro-entreprise allows **monthly or quarterly** declarations, and the workbook aggregates by quarter (Trim 1…4).

→ Make the period configurable and store `period_type` + `period_start` / `period_end` on `URSSAF_RECORD`, or state that quarterly is out of scope for V1 (a decision, not an oversight).

### B10. Versement libératoire rate is not modeled
The URSSAF sheet uses **two** rates: 0.25 (cotisations + CFP) and 0.022 (versement libératoire) — a real total of ~27.2 %. `REGIME_RATE` carries a single blended number, and §2.1 says "micro: approx. 25%". So: does `estimated_charge_rate` include the versement libératoire or not? The two are deliberately separated in §5.7 (company tax vs personal income tax), which suggests **not** — but then the estimated net is a pre-income-tax net and the dashboards mix two different "nets".

→ Decide, and either split `REGIME_RATE` into two rate components or add a second historized rate.

### B11. VAT thresholds: plural, and they move
§5.8 says "the micro VAT threshold" (singular). The workbook tracks **four**: seuil simplifié 37 500, seuil mensuel 41 250, seuil N+1 25 000, seuil immédiat 27 500. The spec also does not say the base (CA **encaissé**, civil year, micro only — not the "invoicing year" used elsewhere).

→ Model thresholds as historized, configurable values, and state the computation base explicitly. It is a different year notion from `invoicing_month` (A10) and will be got wrong otherwise.

### B12. An undocumented workbook column affects computed durations
A column of the "Temps passé" sheet, historized in the Data sheet, feeds the computed durations without appearing anywhere in the spec or the MCD.

→ Resolved — see `Décisions v2.md`, Appendix A.

### B13. Google Calendar pre-fill has no functional description
Phase 3, but zero functional content: what is imported, how events map to missions/clients, how duplicates are avoided, whether the import is a proposal or a direct write. One paragraph now avoids a redesign later.

### B14. Alerts are promised everywhere and specified nowhere
§5.8 promises a VAT alert; §6.5 an overdue flag; RG-21 defers rate-change alerts; the Bilan defers "spécification des alertes". Nothing lists the alert catalogue or the delivery channel (in-app badge? email?).

→ At minimum, list the alert types in §6.5 and mark them Phase 2.

### B15. §8 Migration has no acceptance criteria
"Scope and timing to be discussed later" is fine as a phasing decision, but the migration is the reason the multi-year database exists (§1.2 — "ABSOLUMENT"). Decide at least: which years, which sheets, whether it goes through B1's CSV importer, and what "migrated correctly" means (yearly totals matching the workbook is a good acceptance test).

---

## C. Contradictions and ambiguities

**C1. Portage real net: entered or derived?** `Bilan` says "le net réel est saisi manuellement dès réception du bulletin, **inchangé** par rapport à la spec initiale", and Q8 says the same. RG-22 says `actual_charge_rate` is **derived** and that `PAYMENT.amount` already is the real net. Three documents, two rules — and per A3 there is no payslip to enter anything on.

**C2. "Derived from `amount` against the corresponding CA share" (RG-22) is not a formula.** With one salary covering several declarations (A4), "the corresponding CA share" is undefined. Write the arithmetic.

**C3. Stale documents.** `Bilan et points ouverts.md` and `Besoin/Résumé de Claude.txt` still describe the superseded rule from Q4 ("estimation replaced by the real net **at full payment**"), superseded by per-payment reconciliation (RG-22/RG-23). They also still list "formation" as a mission *type*, superseded by RG-24/RG-25. Either mark them as historical records or update them.

**C4. `PAYMENT` stores `payment_date` *and* `month`/`year`.** Redundant, and it is ambiguous which one attaches the payment to its `URSSAF_RECORD` (RG-08 says "received during the month"). Keep `payment_date` and derive the period, or state that the period is manually overridable and why.

**C5. "Net before tax" — before which tax?** The URSSAF sheet has *Net avant impôt* (payment − cotisations) **and** *Net du mois* (payment − cotisations − versement libératoire). `URSSAF_RECORD` models only `net_before_tax`, and `PAYMENT.actual_net` does not say which of the two it is. Ties directly to B10.

**C6. RG-20 freezes the rate on the *creation date*.** Deliberate, but it breaks on back-dated entry and on the Excel migration: a 2024 invoice imported in 2026 would freeze the 2026 rate. RG-20 says the field stays editable — make that explicit as the migration rule, or use the invoicing period as the reference date for imported rows.

**C7. RG-10 vs RG-05/RG-06 (`temps sur site`).** RG-10 computes the work value as "the sum of the **billable** time entries", which is only correct if prep time is `billable = false`. But RG-05 then says those same non-billable entries "count toward the real billing rate". One boolean is doing two contradictory jobs — see A8.

**C8. Partial invoicing of a forfait is undefined.** §5.9 allows invoicing "a fraction of a forfait"; no rule says how the fraction is recorded (typed amount? percentage? milestone?). RG-11's running delta needs it.

**C9. Forfait missions have no rate.** `MISSION.id_rate` is "absent for fixed-price missions", so `TIME_ENTRY.applied_tjm` and `computed_revenue` are undefined for them — null? zero? The real-TJM statistic (RG-06) needs the answer.

**C10. `RATE.valid_from` / `valid_to` vs RG-02.** If a rate is versioned in time, which version prices a time entry — the one valid on the work day, or the one frozen on the mission? `TIME_ENTRY.applied_tjm` implies freeze-per-entry, but no rule states it. Also, is the applied TJM overridable per entry?

**C11. `REGIME_RATE` has no integrity rule.** Nothing forbids overlapping validity periods, and nothing says what happens when no rate covers a date (reject? fall back to the latest?).

**C12. Client and partner on `TIME_ENTRY` (§5.1) are derived** through MISSION → CLIENT → PARTNER. Either denormalize deliberately (and say why — it protects history if a client's referring partner changes) or remove them from §5.1. Today the spec and the MCD disagree.

**C13. Status model has no terminal negative state.** `Brouillon → Envoyée → Payée partiellement → Payée` — no `Annulée`, no credit note (avoir). Also undefined: does deleting a payment roll the status back from `Payée`?

**C14. When is the invoice number assigned** — at creation of the draft, or at sending? RG-14 resets the sequence monthly but says nothing about holes left by deleted drafts, nor about which month drives the sequence: the issue month or the invoicing month. They differ in the real data — invoice `2025-02-001` has invoicing month **Avril**. This one needs your call.

**C15. Naming asymmetry.** `MICRO_INVOICE.amount_ht` vs `PORTAGE_DECLARATION.total_ca` for the same concept; `MICRO_INVOICE` has `expected_payment`, `PORTAGE_DECLARATION` has no counterpart. Harmonize before the ORM schema is written.

**C16. Roadmap dependency.** §10 puts overdue flagging in Phase 2, but it requires the Phase 1 model change of A1. Same for the VAT bar (B11) and the settings entity (B7). All model changes should land in Phase 1.

**C17. §11 "The V1 modeling round of open points is resolved" is too strong** given A1–A10 and B1–B15.

**C18. Broken document references.** `Bilan et points ouverts.md` points to `Spécification/Spécification fonctionnelle.md`, `Spécification/Spécification technique.md`, `Spécification/MCD.md`. The real paths are `Spécification fonctionnelle/docs/_hist/Spécification fonctionnelle v1.md`, `Spécification technique/Spécification technique v1.md` and `Spécification fonctionnelle/docs/_hist/MCD.md`.

**C19. §2.2 "Full time-based: with a TJM, off site is billed"** is unclear — presumably "off-site work is billed too, unlike `temps sur site`". Reword.

**C20. The Glossary definition of "Partner" is too narrow**: "an intermediary who refers end clients and **is invoiced under portage**". RG-01 explicitly allows a partner to be billed directly, and the workbook shows **micro** invoices addressed to a partner. Drop "under portage".

**C21. No portage company entity.** `REGIME_RATE` for portage is a global rate, but the ~50 % is **contractual with a specific portage company**. Nothing records which company employs the consultant, and nothing survives a change of portage company. Worth one entity now.

**C22. `USER` / `ROLE` / `PERMISSION` will collide with Better Auth.** The tech stack delegates authentication, roles and invitations to Better Auth, which brings its own schema. Reconcile before writing the Prisma schema: keep the MCD entities as the conceptual view, and map — not duplicate — them onto Better Auth's tables.

**C23. Money and rounding rules are unspecified.** Decimal precision, rounding direction, and whether derived amounts (`computed_revenue`, `estimated_net`, `expected_payment`) are persisted or recomputed on read. With SQLite + Prisma this must be settled before the schema (`Decimal` mapping) — a functional decision with a technical consequence.

---

## Decisions needed from you (blocking the technical spec)

> All eight were resolved on 2026-08-31 — see `Décisions v2.md`.

1. **Hours per day** — confirm 7 h = 1 day, and whether it can vary per client. (A6)
2. **The undocumented duration column** — what is it, and is it still needed? (B12)
3. **Portage settlement** — one declaration per month with partner/client lines, or many-to-many payment ↔ declaration? (A4)
4. **Payslip** — stored entity, or is the real rate simply typed on the payment? (A3, C1)
5. **`estimated_charge_rate` for micro** — 25 % (cotisations only) or 27.2 % (incl. versement libératoire)? (B10, C5)
6. **Invoice number** — assigned at draft creation or at sending, and sequenced on the issue month or the invoicing month? (C14)
7. **Scope call on B1–B5** (CSV import, export, PDF report, versioning, AI): which are V1 features, which are "designed in but built later"? This one materially changes the technical spec.
8. **Resale ambition** (B6): must V1 be instance-configurable, or is that a later rewrite?

## Suggested order of work

1. Answer the 8 decisions above.
2. Patch the MCD for A1–A10 + B7 (settings) + B8 (mission category) + the audit-log entity — these are all **Phase 1 model changes**, cheap now and expensive after the first migration.
3. Add B1–B6 to §1.3 / §3 / §10 of the functional spec, even if only as phased scope.
4. Fix the C-list by editing sentences, and update `Bilan et points ouverts.md` (C3, C18).
5. Then write the technical spec: Prisma schema first (it is the direct translation of the corrected MCD), then API, then UI.
