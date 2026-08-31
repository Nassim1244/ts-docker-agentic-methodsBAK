# SynFactu — Functional Specification (V1)

> Billing and dashboard software for a freelance consultant operating under two regimes: French micro-entreprise and salary portage (portage salarial). This document covers the **functional** scope. Technical choices are in "Spécification technique.md"; the data model is in "MCD.md". Domain terms with no clean English equivalent are kept as-is: TJM (daily rate), URSSAF, portage, CFP, versement libératoire, HT.

---

## 1. Introduction and Context

### 1.1 Purpose
Define the functional behavior of SynFactu, a tool to record, invoice, track payments for and analyze a freelance consultant's activity, replacing the current Excel workbook.

### 1.2 Background
The consultant currently uses a yearly Excel workbook. It works but has three limits: it is not clean (abandoned experiments remain), it has no statistics or charts, and it covers a single year. SynFactu must hold **all years in one single database** and provide stats and charts natively.

### 1.3 Scope
In scope: data entry (CRUD), consolidation for partner billing, micro invoicing tracking, portage declarations, payment tracking, gross/net management, URSSAF tracking, dashboard and statistics, and a role model designed in from the start. Out of scope for V1: generating legal invoice PDFs, full VAT management, automated reminders, Google Calendar import (planned later).

### 1.4 Glossary
- **TJM**: daily rate (taux journalier moyen).
- **HT**: excluding tax (hors taxes).
- **Brut / Net**: gross revenue vs net after charges.
- **Partner**: an intermediary who refers end clients and is invoiced under portage.
- **End client**: the final client, possibly reached through a partner.
- **Portage**: salary portage; the portage company employs the consultant and pays a net salary.
- **CFP**: contribution to professional training.
- **Versement libératoire**: flat personal income tax option for micro-entreprise.

### 1.5 Personas
- **Administrator** (the consultant): full access to all data and features.
- **Externalized administrative and financial assistant** (later): restricted access (time entry, URSSAF, etc.), no access to all history features. Detailed scope to be defined.

---

## 2. Business Overview

### 2.1 The two billing regimes
The consultant bills under two regimes that must remain **strictly separate** (merging them in the workbook proved to be a mistake):
- **Micro-entreprise**: charges approx. 25% of revenue.
- **Portage salarial**: charges approx. 50% of revenue.

These charge rates are **not fixed forever** (e.g. legal URSSAF scale updates for micro, contractual changes for portage). SynFactu **historizes** them with validity periods rather than storing a single static value per regime (see MCD, REGIME_RATE, RG-19).

### 2.2 Revenue streams
- **Full time-based** : with a TJM, off site is billed.
- **Time on-site only**: paid for time spent in front of clients; unbilled preparation time is tracked to compute a real billing rate.
- **Fixed-price (forfait)**: an agreed global amount; time is tracked only to derive the real TJM.

**Training is not a revenue stream**: it is a property of a mission (`is_training` flag), orthogonal to which of the streams above bills it. The goal is to easily list all training missions done over a year. For V1, only the boolean flag is needed; subcontracted-vs-direct classification and the full "Déclaration d'Activité de Formation" tooling are deferred to a later phase (see MCD, section 5).

### 2.3 Gross vs net
At invoicing, the net is an **estimate** derived from the regime charge rate in effect on the **invoice/declaration's creation date** (not the invoicing month), frozen into the document as `estimated_charge_rate` (RG-20). Since the applied rate is frozen at creation, later regime rate changes never retroactively affect existing invoices/declarations.

The **real** net/charge rate are **not** stored on the invoice/declaration itself: they are recorded **per payment** (RG-22), since a single document can be settled by several payments, each with its own real rate (e.g. installments spanning different URSSAF months). For micro payments, the real rate is auto-computed from the finalized monthly URSSAF declaration; for portage payments, the real charge rate is derived once the payslip is entered (the payment amount already is the real net salary). Dashboards and stats mix estimated figures (for payments not yet reconciled) with real figures (for reconciled payments), so in-progress billing is still reflected.

### 2.4 High-level workflow
Time entry → consolidation → invoicing (micro) or declaration (portage) → payment(s) → tax tracking (URSSAF for micro). The dashboard reads across all of this.

---

## 3. Functional Scope (Overview)
- Core CRUD on financial data, optimized for fast entry.
- Visualization by month, quarter, year, multi-year, client, partner, regime and mission type.
- Statistics: annual averages, real TJM, average payment delay, etc.
- Charts: gross/net evolution, revenue trend, per-client distribution.
- Payment tracking and reconciliation, including installments.
- One single multi-year database (mandatory).

---

## 4. Data Model (Conceptual)
The conceptual data model (entities, Mermaid diagram, entity dictionary, cardinalities, business rules RG-01..RG-25, open questions) is maintained in **"MCD.md"**. See that document for the full model.

---

## 5. Functional Modules

### 5.1 Time tracking and entry
Record time entries quickly. Each entry carries: date, optional start/end, worked duration and rounded duration, billable flag, title, tags, client, partner, ISO week, the **invoicing month it is affected to (chosen manually)**, the applied TJM and the computed revenue. Inactive missions and inactive clients are excluded from selection lists. Future: pre-fill from Google Calendar.

**Rounding**: the rounding step is a configurable application setting (default: 15 minutes); the system auto-rounds but the value stays manually correctable per entry.

**Tags**: a predefined base list of tags is provided, extensible with user-added tags. Tags support hierarchy via `::`, e.g. `commercial::RDV1`, `commercial::rédactionProposition`.

### 5.2 Consolidation for partner billing
Aggregated view per partner, broken down by end client and by work week/month, showing hours, days and amount HT. The module **auto-generates the billing text**, e.g.:

```
Détail du mois : Avril 2026
Client : ELA SW : 9,5h - soit 1,36 j
  - Semaine 03 : 3,5h - soit 0,5 j
  - Semaine 04 : 6h - soit 0,86 j
Client : Léguméo : 8,75h - soit 1,25 j
  ...
```

### 5.3 Portage declaration view
Per partner (and per end client) for a given month: hours, days, CA, estimated charge rate (frozen at creation, see 2.3), estimated net and actual net. Mirrors the current "Déclaration portage" sheet, used to know what is ventilated per client.

### 5.4 Micro invoicing view
Simplified vs the current workbook (micro and portage are kept apart). Records invoices with: number, invoicing month, year, client, mission, amount HT, estimated charge rate (frozen at creation, see 2.3), expected payment, estimated net, status, comment. **Invoice numbering** follows the model `2026-01-001_Client_mission` (year-month-sequence_Client_mission); the **sequence resets to 001 every month**. The mission part is a few very short words. SynFactu tracks invoice **data only**; it does not produce the legal PDF.

**Status**: `Brouillon → Envoyée → Payée partiellement → Payée`. The first two are set manually; the last two are derived from linked payments. "En retard" is a computed dashboard flag (see 6.5), not a stored status. The same status model applies to portage declarations (5.3).

**Linking time entries to a billing**: the system pre-selects all unlinked billable time entries for the relevant client/mission/month; the user can deselect entries before validating.

### 5.5 Payments view
Declare a payment and link it to **either** a micro invoice **or** a portage payslip/declaration. Supports several payments per invoice/declaration (installments). Shows the outstanding amount per invoice/declaration.

Each payment carries the **real** figures once known (RG-22): for a micro payment, `actual_charge_rate`/`actual_net` are auto-computed once its month's URSSAF declaration is finalized; for a portage payment, `actual_charge_rate` is derived once the payslip is entered (the payment amount already is the real net salary, so no separate real-net field there). A payment is "reconciled" once its `actual_charge_rate` is set.

### 5.6 Gross vs net management
Apply the regime's historized charge rate, as in effect on the document's creation date, at invoicing (RG-19, RG-20) to produce the **estimated** net. The **real** net/charge rate are never stored on the invoice/declaration: they live on its linked payment(s) (5.5, RG-22), since one document can be settled by several payments each with its own real rate. Track gross and net evolution in stats and charts, mixing estimated (unreconciled payments) and real (reconciled payments) figures. Regime rate changes are entered ahead of time (`valid_from`) and never retroactively affect already-created documents or payments.

### 5.7 URSSAF management (micro)
CRUD on monthly URSSAF records, separating:
- **Cotisations + CFP** = company-level tax.
- **Versement libératoire** = personal income tax.

The base of a month is the **sum of the micro payments received that month**; those payments are linked to the record.

### 5.8 VAT thresholds monitoring (micro)
No VAT management in V1. The dashboard shows a **progress bar toward the micro VAT threshold** and will feed an alert (alerts to be specified later).

### 5.9 Billing backlog and installments
- **Amount to invoice (work value)** per mission: time x TJM for `temps passé` and `temps sur site` missions; the agreed amount for `forfait` missions.
- **Billing backlog ("encours à facturer")** = work value minus the amount already invoiced.
- A total can be **invoiced in several steps** (a billing covers a subset of time entries, or a fraction of a forfait).
- **Outstanding to pay ("reste à payer")** = amount invoiced minus payments received.
- A bill can be **paid in several installments**.
- **No planned schedule (échéancier)**: only the two running deltas are tracked.

---

## 6. Dashboard and Reporting

### 6.1 Key indicators
Revenue (HT), gross, net, outstanding to invoice, outstanding to pay, average payment delay, real TJM, real billing rate.

### 6.2 Payment delay reference
- **Micro**: counted from the **invoice date**.
- **Portage**: counted from the **start of the month concerned by the billing**.

### 6.3 Real TJM and billing rate
The denominator for the real TJM / billing rate includes **all time, billable or not** (preparation, related commercial time), so the real rate can be compared to the invoiced TJM.

### 6.4 Filters and breakdowns
Time filters (month, quarter, year, multi-year). Breakdowns by client, partner, regime and mission type.

### 6.5 Charts and alerts
Gross/net evolution, revenue trend, per-client distribution, VAT threshold progress bar. Overdue invoices/declarations are **flagged in the dashboard**.

---

## 7. User Management and Roles
Implemented later but **designed into the model from the start**.
- **Administrator**: full access.
- **Assistant** (externalized administrative and financial): restricted scope (time entry, URSSAF, etc.); no access to all history features.
- A **permission matrix** (features vs roles) will be detailed later.
- An **audit log** records changes (who changed what, when, before/after), useful as soon as an assistant enters data.

---

## 8. Data Migration
Import the history from the existing Excel workbooks into the single multi-year database, with a mapping of old sheets to the new model and a cleanup of legacy artifacts (orphan formulas, abandoned columns). Scope and timing to be discussed later.

---

## 9. Non-Functional Requirements (Functional-facing)
- **Usability**: speed of entry is a priority.
- **Data integrity**: one single source of truth, multi-year.
- **Localization**: French, euro, French fiscal rules.
- **Privacy**: financial data protection.
- **Traceability**: audit log of changes (see section 7).

---

## 10. Roadmap and Phasing
- **Phase 1**: core CRUD + multi-year database + the main views (time, consolidation, portage declaration, micro invoicing, payments).
- **Phase 2**: stats and charts dashboard, VAT threshold bar, overdue flagging.
- **Phase 3**: Google Calendar pre-fill, Excel history migration.
- **Phase 4**: user management and audit, training activity classification (Déclaration d'Activité).

---

## 11. Open Questions
The V1 modeling round of open points is resolved (see "Bilan et points ouverts.md" and "MCD.md" section 5). Remaining, deliberately deferred: the assistant permission matrix, the training subcontracted/direct classification and the full "Déclaration d'Activité de Formation" tooling (V1 only has the `is_training` flag), and the scope/timing of the Excel history migration.
