# Implementation Details in Main Scenarios

Review of use case scenarios against the philosophy principle **"Intent over mechanics"** — steps should express what is accomplished, not how — and the template guidance that steps express intent and outcomes, not mechanics.

## UC-01 — Populate New Wiki

| Step | Text | Issue |
|------|------|-------|
| 3 | "Structural files (Home.md, _Sidebar.md, _Footer.md) are ignored" | Names specific filenames. Intent: "validates the wiki has no existing content pages." What counts as structural is an implementation decision. |
| 4 | "reads guidance files and the target project's CLAUDE.md if it exists" | Names specific files. The colon after "editorial context" already expresses the intent — the enumeration is mechanics. |
| 8 | "each with filename, title, description, and key source files" | Protocol output schema leaking into the scenario. The wiki plan's internal structure belongs in the Protocols section (where it already appears). |
| 10 | "one per approved page (excluding _Sidebar.md), each receiving its page assignment, key source file references, audience, tone, and editorial guidance" | Two issues: (1) dispatch strategy ("one per approved page") is implementation, (2) the input payload enumeration is protocol detail. Intent: "distributes approved page assignments to writer agents." |
| 12 | "writes _Sidebar.md with navigation reflecting the approved section structure, and confirms all approved pages are on disk" | Names a specific file and describes a mechanical verification step. Intent: "assembles wiki navigation and confirms all approved content is in place." |

## UC-02 — Review Wiki Quality

| Step | Text | Issue |
|------|------|-------|
| 3 | "reads editorial guidance, wiki instructions, issue template, and the target project's CLAUDE.md if it exists" | Names four specific files. Same pattern as UC-01 step 4. |
| 4 | "excluding structural files (`_`-prefixed `.md` files)" | File-naming convention detail. Intent: "identifies all content pages eligible for review." |
| 5 | "write structured summaries to the proofread cache" | Names an internal storage mechanism. The proofread cache is an implementation artifact — the intent is that explorers produce summaries for downstream consumption. |
| 8 | "Each problem found is written to the proofread cache as a finding" | Same cache reference. Intent: "Each problem found is surfaced as a finding." How findings are materialized is mechanics. |
| 9 | "Reads all findings from the cache" | Cache reference again. Intent: "Collects all findings from the current review." |
| 11 | "Cleans up the proofread cache" | Entire step is housekeeping mechanics. Not a goal-advancing action — it's an implementation cleanup step that doesn't belong in the scenario at all. |

## UC-03 — Resolve Documentation Issues

| Step | Text | Issue |
|------|------|-------|
| 3 | "reads editorial guidance, wiki instructions, and the target project's CLAUDE.md if it exists" | Same file-naming pattern as UC-01/02. |
| 5 | "Parses each issue body against the `wiki-docs.yml` template schema, extracting structured fields: Page, Editorial lens, Severity, Finding, Recommendation, Source file, Notes" | Names a specific file and enumerates all seven fields. Heavy protocol detail. Intent: "Extracts actionable information from each issue." The field list already exists in the Protocols section. |
| 6 | "Groups actionable issues by wiki page. For accuracy issues, notes the referenced source files that fixers will need to read." | Dispatch preparation mechanics. Intent: "Organizes actionable issues for remediation." How they're grouped and what metadata is prepared is implementation. |
| 7 | "one per wiki page that has issues. Each receives: the page path, the list of parsed issues for that page, source file paths for accuracy issues, editorial guidance, audience, and tone" | Dispatch strategy and full input payload. Intent: "Dispatches fixer agents with their page assignments and context." |
| 8 | "using targeted edits" | Tool-level detail (Edit tool). Intent: "applies each recommended correction." How edits are made is the agent's judgment. |

## UC-05 — Provision Workspace

| Step | Text | Issue |
|------|------|-------|
| 3 | "Extracts repository identity (owner and repo name) from the clone URL" | Parsing mechanic. Intent: "Identifies the target repository." How identity is derived from input is implementation. |

## UC-06 — Decommission Workspace

| Step | Text | Issue |
|------|------|-------|
| 3 | "Reads the workspace config to locate the source and wiki directories" | Mechanical — describes *how* the system finds what to remove. Intent: "Identifies the workspace components to remove." |
| 5 | "Removes the source clone, wiki clone, config file, and empty parent directories" | "empty parent directories" is cleanup mechanics. Intent: "Removes all workspace artifacts." |

## UC-07 — Publish Wiki Changes

Out of scope — no scenario to review.

---

## Patterns

Three recurring anti-patterns:

1. **File/artifact naming in scenario steps** — CLAUDE.md, _Sidebar.md, Home.md, wiki-docs.yml, proofread cache. These belong in Protocols or Invariants, not scenarios. Appears in UC-01 (steps 3, 4, 10, 12), UC-02 (steps 3, 4, 5, 8, 9, 11), UC-03 (steps 3, 5).

2. **Dispatch strategy and input payloads** — "one per page," followed by an enumeration of everything the agent receives. The scenario should say agents are dispatched with assignments; the protocol section should define the assignment contents. Appears in UC-01 (step 10), UC-03 (steps 6, 7).

3. **Protocol schemas restated in scenario steps** — field lists, data structure descriptions that already exist in the Protocols section of the same document. Appears in UC-01 (step 8), UC-03 (step 5).
