# Remediation Plan v2

Sequenced fix plan for all issues in `refactor-issues/fusion.md`.
Incorporates DDD-inspired domain architecture: explicit markdown protocols at every agent boundary, domain knowledge in guidance files organized by concern, and custom agents (`.claude/agents/`) with well-defined roles.

**Principles:**

- Each wave contains only tasks independent of each other → parallel Opus agents.
- Agents own their domain: writers write, explorers explore, reviewers review. Orchestrators only coordinate.
- Every agent boundary has an explicit markdown protocol defining input and output.
- Domain knowledge lives in guidance files, not inline in commands.
- Writing principles have a single source of truth (`editorial/`), not duplicated inline.

---

## Wave 0 — Domain Architecture

**Goal:** Create the protocol files, operations guidance, and folder structure that all subsequent waves reference. No command files are modified in this wave.
**Parallelism:** 3 independent tasks, all run concurrently.

### Task 0A: Create protocol files

Create `.claude/guidance/protocols/` with 7 protocol files. Each follows a consistent structure: Purpose, Producer, Consumer, Required fields, Output format, Validation rules.

**Protocols:**

1. **`source-analysis.md`** — Explorer output when analyzing source code.
   - Producers: `wiki-explorer` (init-wiki Phase 1, proofread-wiki Phase 3, refresh-wiki Phase 1)
   - Consumers: init-wiki planner, proofread-wiki reviewers
   - Required fields: `area_name`, `file_paths[]`, `key_types[]`, `public_api_summary`, `architectural_notes`

2. **`page-plan.md`** — Wiki page plan for new content.
   - Producer: init-wiki Phase 2 planner
   - Consumer: init-wiki Phase 3 writers
   - Required fields: `page_title`, `filename`, `purpose`, `sections[]`, `source_files[]`, `audience_notes`

3. **`page-content.md`** — Structure guide for new wiki pages.
   - Used by: `wiki-writer` (init-wiki Phase 3)
   - Defines: required page structure (title, opening sentence, sections, code examples). Writer follows this when creating pages via `Write` and returns a confirmation (filename, title, summary).
   - Required confirmation fields: `filename`, `title`, `summary`

4. **`review-finding.md`** — Proofreading finding.
   - Producer: `wiki-reviewer` (proofread-wiki Phase 4)
   - Consumer: orchestrator → `issue-body.md` → GitHub issue
   - Required fields: `page`, `location`, `severity`, `category`, `finding`, `recommendation`, `source_evidence`

5. **`drift-assessment.md`** — Source change impact on wiki.
   - Producer: `wiki-explorer` (refresh-wiki Phase 2)
   - Consumer: refresh-wiki Phase 3 editor agents
   - Required fields: `wiki_page`, `source_files[]`, `changes[]`, `impact_description`, `correct_content`

6. **`edit-instruction.md`** — Change report format. Shared across contexts.
   - Producers: `wiki-writer` (refresh-wiki, resolve-issues edit mode)
   - Consumer: orchestrator (for logging, error checking, and downstream decisions like issue closing)
   - Writer applies edits directly via `Edit`, then returns a report of what changed.
   - Required report fields: `file`, `old_string`, `new_string`, `rationale`

7. **`issue-body.md`** — Published Language between proofread-wiki and resolve-issues.
   - Producer: proofread-wiki (filing via `file-issue.sh`)
   - Consumer: resolve-issues (parsing)
   - Defines: issue title format, body sections (`Page`, `Location`, `Category`, `Finding`, `Recommendation`, `Source evidence`)

**Files:** `.claude/guidance/protocols/` (7 new files)

### Task 0B: Create operations guidance

Create `.claude/guidance/operations/git-workflow.md`:

- When to pull: `--ff-only` before analysis, `--rebase` before push.
- Conflict handling: show conflict and stop, tell user how to resolve.
- Push failure handling: check exit code, report auth / network / non-fast-forward with actionable message.
- Upstream tracking check: `git log @{u}..HEAD` with error handling when no upstream exists.
- Source repo is always read-only — never stage, commit, or push to it.

**Files:** `.claude/guidance/operations/git-workflow.md`

### Task 0C: Reorganize guidance and update agents

1. Move existing guidance into domain subfolders:
   - `guidance/editorial-guidance.md` → `guidance/editorial/editorial-guidance.md`
   - `guidance/wiki-instructions.md` → `guidance/editorial/wiki-instructions.md`

2. Update `CLAUDE.md` references to point to new paths.

3. Update `.claude/agents/` to reference protocols and guidance:

   **`wiki-explorer.md`:**
   - Add: "Return structured reports following `.claude/guidance/protocols/source-analysis.md` or `.claude/guidance/protocols/drift-assessment.md` as specified by your task prompt."
   - No other changes — agent is already correctly scoped.

   **`wiki-writer.md`:**
   - Remove inline writing principles (lines 12–21).
   - Add: "Read `.claude/guidance/editorial/editorial-guidance.md` and `.claude/guidance/editorial/wiki-instructions.md` for writing principles."
   - Add: "For new pages, use `Write` to create the file, following `.claude/guidance/protocols/page-content.md` for structure. For edits to existing pages, use `Edit` to apply changes directly. In both cases, return a confirmation report per `.claude/guidance/protocols/edit-instruction.md`."
   - The writer owns the mutation — it reads source, drafts content, and writes/edits the file itself.

   **`wiki-reviewer.md`:**
   - Add: "Return findings following `.claude/guidance/protocols/review-finding.md`."
   - Keep existing review checklist (it's agent-specific context, not duplicated guidance).

**Files:** `.claude/guidance/editorial/` (2 moved files), `.claude/agents/` (3 updated files), `CLAUDE.md`

---

## Wave 1 — Foundation Fixes

**Goal:** Fix standalone bugs and structural issues that don't touch swarm command internals.
**Parallelism:** Two sequential batches (shared file conflicts — see execution summary).
**Depends on:** Wave 0 (guidance paths are stable, so reference updates are correct).

### Task 1A: Workspace selection — centralize and simplify

**Fixes:** Fusion §2.1, §2.2

Replace all inline workspace selection steps (in init-wiki, proofread-wiki, refresh-wiki, resolve-issues, save, down) with a single line referencing CLAUDE.md:

> Follow the **Workspace selection** procedure in CLAUDE.md to resolve `repo`, `sourceDir`, `wikiDir`, `audience`, and `tone`.

Verify CLAUDE.md's canonical algorithm has the "no configs → stop" check at step 2 (it does). Remove all divergent inline variants.

**Files:** `.claude/commands/init-wiki.md`, `.claude/commands/proofread-wiki.md`, `.claude/commands/refresh-wiki.md`, `.claude/commands/resolve-issues.md`, `.claude/commands/save.md`, `.claude/commands/down.md`

### Task 1B: `.gitignore` — add generated directories

**Fixes:** Fusion §10.1

Add `.proofread/` and `issues/` to `.gitignore`.

**Files:** `.gitignore`

### Task 1C: `file-issue.sh` — fix label parsing and add config path

**Fixes:** Fusion §6.1, §6.3

1. Fix label extraction: replace `tail -1` with `head -1 | sed 's/^labels:[[:space:]]*//'`
2. Accept optional config path as second argument (after title). Fall back to auto-detect if not provided.
3. Update `proofread-wiki.md` Phase 6 example to pass the config path.

**Files:** `.scripts/file-issue.sh`, `.claude/commands/proofread-wiki.md` (Phase 6 example only)

### Task 1D: `/up` — fix step ordering and atomicity

**Fixes:** Fusion §4.1, §4.2, §4.3, §4.4, §4.5, §4.6

Rewrite `/up` flow:

1. Interview (repo URL, audience, tone) — collect all inputs first.
2. Derive `{owner}` and `{repo}` from URL. Strip `.git` suffix if present.
3. Check if workspace already exists → ask to confirm overwrite or abort.
4. Create directory structure (`workspace/{owner}/`, `workspace/config/{owner}/{repo}/`).
5. Clone source repo to `workspace/{owner}/{repo}`. On failure → clean up dirs and config → stop.
6. Clone wiki repo to `workspace/{owner}/{repo}.wiki`. On failure → warn but continue (wiki may not exist yet).
7. Write config to `workspace/config/{owner}/{repo}/workspace.config.yml` — only after successful clone(s).
8. Read source `CLAUDE.md` if present. Confirm workspace is ready.

**Files:** `.claude/commands/up.md`

### Task 1E: `settings.json` — audit and fill permission gaps

**Fixes:** Fusion §6.2 (partially), plus gaps found in review

Audit every Bash invocation across all commands and ensure `settings.json` covers them. Currently missing:

- `Bash(mkdir:*)` — used by `/up`
- `Bash(rm:*)` — used by `/down`
- `Bash(rmdir:*)` — used by `/down`
- `Bash(gh issue close:*)` — used by `/resolve-issues`
- `Bash(gh issue comment:*)` — used by `/resolve-issues`
- `Bash(bash .scripts/*:*)` — used by `/proofread-wiki` for `file-issue.sh`
- `Bash(git log:*)` — used by `/save` and `/down` without `-C` prefix
- `Bash(git diff:*)` — used by `/save` without `-C` prefix
- `Bash(git add:*)` — used by `/resolve-issues` push-then-close flow
- `Bash(git commit:*)` — used by `/resolve-issues` push-then-close flow
- `Bash(git push:*)` — used by `/resolve-issues` and `/save`

**Files:** `.claude/settings.json`

### Task 1F: `/down` — add path validation and safety

**Fixes:** Fusion §5.1, §5.2, §5.3, §5.4, §5.5

Add before any `rm -rf`:

1. Resolve paths to absolute.
2. Assert both `sourceDir` and `wikiDir` are within the `workspace/` directory (string prefix check).
3. Assert paths match the expected pattern `workspace/{owner}/{repo}[.wiki]`.
4. If validation fails → refuse to delete and show the suspicious path.

Also:
- Handle `git log @{u}..HEAD` failure when no upstream exists (catch the error, treat as "nothing to push").
- On partial deletion failure, report what was removed and what remains.

**Files:** `.claude/commands/down.md`

---

## Wave 2 — Subagent Architecture Restructuring

**Goal:** Fix the CRITICAL subagent permission issue and connect commands to the protocol/agent layer.
**Parallelism:** 4 independent tasks (one per swarm command), all run concurrently.
**Depends on:** Wave 0 (protocols exist) + Wave 1 (workspace selection and settings are stable).

Each task follows the same pattern:

- Commands reference **custom agents** (`.claude/agents/wiki-explorer`, `wiki-writer`, `wiki-reviewer`) instead of inline `subagent_type` declarations.
- **Agents own their domain.** Writers read source, read guidance, and apply edits directly using their own `Write`/`Edit` tools. Explorers read and analyze. Reviewers read and assess. Each agent's frontmatter grants exactly the tools it needs.
- **Orchestrators only coordinate** — dispatch agents, collect confirmations, handle errors, sequence phases. They never call `Edit` or `Write` on wiki content themselves.

Custom agents (`.claude/agents/`) declare explicit `tools:` grants in their frontmatter. `wiki-writer` has `Write, Edit`; `wiki-explorer` and `wiki-reviewer` have `disallowedTools: Write, Edit`. This is the structural enforcement of the read/write boundary.

### Task 2A: `init-wiki` — use wiki-explorer and wiki-writer agents

**Fixes:** Fusion §1.1 (init-wiki), §9.9, §9.10, §9.13

Restructure to reference custom agents and protocols:

- Phase 1 (explore): Launch `wiki-explorer` agents. Each returns a **Source Analysis** (protocol: `source-analysis.md`).
- Phase 2 (plan): Launch a `wiki-explorer` agent (or `general-purpose`). Returns a **Page Plan** per page (protocol: `page-plan.md`).
- Phase 3 (write): Launch `wiki-writer` agents, each given a page plan + source file paths. Each writer creates its page directly via `Write` (following `page-content.md` structure) and returns a confirmation. Orchestrator collects confirmations via `TaskOutput`.
- Sidebar: Launch a `wiki-writer` agent for `_Sidebar.md` + `Home.md` (removes the "orchestrator does content authoring" issue).

Also fix:
- Add `TaskOutput` to `allowed-tools`.
- Remove `Edit` and `Write` from `allowed-tools` (orchestrator doesn't need them — writers handle mutations).

**Files:** `.claude/commands/init-wiki.md`

### Task 2B: `proofread-wiki` — use wiki-explorer and wiki-reviewer agents

**Fixes:** Fusion §1.1 (proofread-wiki), §1.2, §6.2

Restructure to reference custom agents and protocols:

- Phase 3 (source exploration): Launch `wiki-explorer` agents. Each returns a **Source Analysis** (protocol: `source-analysis.md`). Orchestrator writes to `.proofread/{repo}/source/`.
- Phase 4 (review): Launch `wiki-reviewer` agents. Each returns **Review Findings** (protocol: `review-finding.md`). Orchestrator writes to `.proofread/{repo}/findings/`.
- Phase 5 (dedup): Orchestrator runs `gh issue list --label documentation` directly (not via subagent). Filters findings.
- Phase 6 (file issues): Orchestrator calls `bash .scripts/file-issue.sh` directly (covered by `Bash(bash .scripts/*:*)` added in Task 1E). Issue body conforms to `issue-body.md` protocol.

**Files:** `.claude/commands/proofread-wiki.md`

### Task 2C: `refresh-wiki` — use wiki-explorer and wiki-writer agents

**Fixes:** Fusion §1.1 (refresh-wiki)

Restructure to reference custom agents and protocols:

- Phase 2 (explore): Launch `wiki-explorer` agents. Each returns a **Drift Assessment** (protocol: `drift-assessment.md`). Orchestrator collects via `TaskOutput`.
- Phase 3 (update): Launch `wiki-writer` agents (edit mode), each given one wiki page + the drift assessment + editorial guidance references. Each writer reads the page, applies edits directly via `Edit`, and returns a **Change Report** (protocol: `edit-instruction.md`). Orchestrator collects confirmations via `TaskOutput`.

Also fix:
- Add `TaskOutput` to `allowed-tools` in the frontmatter.
- Remove `Edit` from `allowed-tools` if present (orchestrator doesn't edit — writers do).

**Files:** `.claude/commands/refresh-wiki.md`

### Task 2D: `resolve-issues` — use wiki-writer agents, orchestrator closes issues

**Fixes:** Fusion §1.1 (resolve-issues), §1.3

Restructure to reference custom agents and protocols:

- Phase 2 (fix): Launch `wiki-writer` agents (edit mode). Each given an issue (parsed per `issue-body.md` protocol) + the wiki page path + source file paths + editorial guidance references. Each writer reads the page, applies edits directly via `Edit`, and returns a **Change Report** (protocol: `edit-instruction.md`). Orchestrator collects confirmations via `TaskOutput`.
- Phase 3 (close): Orchestrator runs `gh issue close` and `gh issue comment` directly — no Bash subagents needed. Uses the change reports from Phase 2 to construct the closing comment.

**Files:** `.claude/commands/resolve-issues.md`

---

## Wave 3 — Git Workflow

**Goal:** Add proper git pull/push handling. Commands reference `operations/git-workflow.md` for patterns.
**Parallelism:** 3 independent tasks.
**Depends on:** Wave 2 (tasks 3A and 3B share files with Wave 2 tasks).

### Task 3A: `refresh-wiki` — pull before analysis

**Fixes:** Fusion §3.1 (refresh-wiki), §9.1

Add to Phase 0 (after workspace selection), referencing `operations/git-workflow.md`:
1. `git -C {sourceDir} pull --ff-only` (source repo — get latest).
2. `git -C {wikiDir} pull --ff-only` (wiki repo — get latest before editing).

Also fix HEAD~50:
- Use `git -C {sourceDir} log --oneline -50 --format=%H | tail -1` to get the actual oldest commit hash, then diff against that. If the repo has fewer than 50 commits, diff against the root.

**Files:** `.claude/commands/refresh-wiki.md`

### Task 3B: `resolve-issues` — pull before editing, push-then-close flow

**Fixes:** Fusion §3.1 (resolve-issues), §3.5

Add to Phase 0, referencing `operations/git-workflow.md`:
1. `git -C {wikiDir} pull --ff-only`

Replace the current Phase 3 (close issues immediately) with a push-then-close flow at the end of the command:

1. Stage and commit all wiki edits (`git -C {wikiDir} add -A && git -C {wikiDir} commit`).
2. Push (`git -C {wikiDir} push`). If push fails → stop, tell user to resolve manually, do NOT close any issues.
3. Only after push succeeds → close each issue with `gh issue close` and a comment summarizing what changed.

This keeps the entire flow within one command (no cross-command state) and guarantees issues are only closed after edits are live.

**Files:** `.claude/commands/resolve-issues.md`

### Task 3C: `/save` — detect unpushed, pull before push, handle failures

**Fixes:** Fusion §3.2, §3.3, §3.4

Rewrite `/save` flow, referencing `operations/git-workflow.md`:
1. Workspace selection (CLAUDE.md reference from Wave 1).
2. Check for uncommitted changes (`git status --porcelain`).
3. Check for unpushed commits (`git log @{u}..HEAD --oneline 2>/dev/null`).
4. If neither → "Nothing to save."
5. If uncommitted → show diff, generate commit message, stage and commit.
6. `git -C {wikiDir} pull --rebase` — if merge conflict, show the conflict and stop.
7. `git -C {wikiDir} push` — check exit code, report success or failure with actionable message.

**Files:** `.claude/commands/save.md`

---

## Wave 4 — Command Hardening

**Goal:** Fix remaining MEDIUM issues — error handling, edge cases, retry logic. Protocol references are already in place from Wave 2; this wave tightens how commands use them.
**Parallelism:** 4 independent tasks (one per swarm command).
**Depends on:** Waves 2–3 (command structure and git workflow are stable).

### Task 4A: `resolve-issues` — guidance, tone, edge cases, and retry

**Fixes:** Fusion §8.1, §8.2, §8.3, §8.4, §9.5, §9.6, §9.7, §9.8, §7.1 (resolve-issues)

1. Fixer agent prompt references `editorial/editorial-guidance.md` and `editorial/wiki-instructions.md` (not CLAUDE.md).
2. Remove hardcoded "reference-style" tone — pass `{tone}` from workspace config to agent prompt.
3. Fix description: `docs` → `documentation`.
4. Fix constraint name: `fix-docs` → `resolve-issues`.
5. Add early exit when zero issues found.
6. Issue body parsing now uses `issue-body.md` protocol (from Wave 2) — validate required sections present.
7. Prefix source file paths with `{sourceDir}/`.
8. Sanitize issue body text before passing to `--body` shell argument (use heredoc, not inline interpolation).
9. Add retry-once for failed fixer agents (§7.1).

**Files:** `.claude/commands/resolve-issues.md`

### Task 4B: `refresh-wiki` — mapping, dedup, edge cases, and retry

**Fixes:** Fusion §9.2, §9.3, §9.4, §7.1 (refresh-wiki), §7.3

1. Replace the vague source-to-wiki mapping with an explicit two-step process:
   a. Orchestrator reads `_Sidebar.md` to build the wiki page list.
   b. For each changed source file, orchestrator reads the first 20 lines of each wiki page looking for references to that source file (imports, class names, file paths). Build the mapping from concrete textual matches, not heuristics.
2. Deduplicate wiki pages across explorer tuples — ensure each wiki page appears in at most one tuple.
3. Filter out deleted source files before passing to explorers (check `git show HEAD:{file}` to confirm existence).
4. Add retry-once for failed explorer agents (consistent with proofread-wiki Phase 4).
5. Validate explorer output against `drift-assessment.md` protocol: require `wiki_page`, `source_files`, `correct_content` fields. Log and skip malformed results.

**Files:** `.claude/commands/refresh-wiki.md`

### Task 4C: `proofread-wiki` — edge cases and robustness

**Fixes:** Fusion §6.4, §6.5, §6.6, §6.7, §6.8, §7.1 (proofread-wiki), §9.14, §9.15, §9.16, §9.17, §9.18

1. Fix template `recommendation` field: make optional or remove `required: true`.
2. Add issue count cap (configurable, default 20) to prevent tracker flooding.
3. Route Phase 1 sidebar issues through Phase 5 dedup.
4. Specify `--pass` flag parsing: case-insensitive, accept both `--pass structural` and `--pass=structural`.
5. Clear `.proofread/{repo}/` at start of each run to avoid stale findings.
6. Fix Phase 1 circular reference — remove "using Phase 6 process" or move sidebar review to after Phase 6 is defined.
7. Add check for `_Sidebar.md` existence.
8. Align template field instructions with example.
9. Fix fallback file path: use `issues/{repo}/` instead of `issues/{sourceDir}/` (§6.5).
10. Add rate-limit awareness: if filing >20 issues, insert 1-second delays between `gh issue create` calls (§6.6).
11. Add retry-once for failed Phase 3 explorer agents (§7.1).

**Files:** `.claude/commands/proofread-wiki.md`, `.github/ISSUE_TEMPLATE/` (if template needs update)

### Task 4D: `init-wiki` — edge cases and cleanup

**Fixes:** Fusion §8.5, §8.6, §9.11, §9.12, §7.1 (init-wiki), §10.13 (subagent_type)

1. Inline writing principles already removed in Wave 0 (Task 0C updated `wiki-writer`). Verify no remnants in command file.
2. Fix terminology: "kebab-case" → "Title-Case-Hyphenated" (or just show the example without naming the convention).
3. Leave `grep -v '^\.'` as-is — excluding all dotfiles is likely intentional (dotfiles are config/metadata, not wiki-worthy content). Add a comment explaining the intent.
4. Clarify sidebar link format: no `.md` extension in `[[links]]`.
5. Verify agents use correct `subagent_type` or custom agent name for `wiki-explorer`.
6. Add retry-once for failed writer agents (§7.1).

**Files:** `.claude/commands/init-wiki.md`

---

## Wave 5 — Polish

**Goal:** LOW-severity items. Optional but worth doing for robustness.
**Parallelism:** 3 independent tasks.
**Depends on:** Wave 4.

### Task 5A: `/up` and `/down` minor fixes

**Fixes:** Fusion §4.7, §5.6

`/up`:
- Validate parsed owner/repo against GitHub (`gh repo view`) before cloning.
- Use `--depth 1` for source repo clone.
- Handle wiki clone failure gracefully (wiki may not exist yet).

`/down`:
- Consolidate two safety checks (uncommitted + unpushed) into one prompt.
- Add `git fetch` before unpushed check.
- Clean up empty parent directories after deletion.

**Files:** `.claude/commands/up.md`, `.claude/commands/down.md`

### Task 5B: `resolve-issues` and `save` minor fixes

**Fixes:** Fusion §10.4, §10.5, §10.11, §10.12, §9.19, §9.20

`resolve-issues`:
- Increase or remove `--limit 100`.
- Add instruction to read `{sourceDir}/CLAUDE.md`.

`save`:
- Add commit message guidance (imperative mood, ≤72 chars first line, summarize if many files).
- Replace `git add -A` with explicit file list from `git status` (exclude temp files).

**Files:** `.claude/commands/resolve-issues.md`, `.claude/commands/save.md`

### Task 5C: `refresh-wiki` and `proofread-wiki` minor fixes

**Fixes:** Fusion §10.6, §10.7, §10.8, §10.9, §10.14

`refresh-wiki`:
- Make commit lookback configurable via `$ARGUMENTS` (default 50).
- Use consistent model for explorer agents (opus or document the sonnet choice).
- When source changes suggest a new page is needed, note it in the output.

`proofread-wiki`:
- Specify parallelism pattern more precisely (e.g., "batch N agents at a time").
- Add timeout guidance for Task agents.

**Files:** `.claude/commands/refresh-wiki.md`, `.claude/commands/proofread-wiki.md`

---

## Execution Summary

```
Wave 0 ─── 3 parallel Opus tasks ─── Domain architecture (protocols, guidance, agents)
  │
Wave 1 ─┬─ Batch 1 (3 parallel): 1A, 1B, 1D
         └─ Batch 2 (3 parallel): 1C, 1E, 1F
  │
Wave 2 ─── 4 parallel Opus tasks ─── Subagent architecture (CRITICAL)
  │
Wave 3 ─── 3 parallel Opus tasks ─── Git workflow
  │
Wave 4 ─── 4 parallel Opus tasks ─── Command hardening
  │
Wave 5 ─── 3 parallel Opus tasks ─── Polish (optional)
```

| Wave | Tasks | Parallel Agents | What's delivered |
|------|-------|-----------------|------------------|
| 0 | 0A–0C | 3 | 7 protocol files, operations guidance, reorganized editorial guidance, updated agents |
| 1 | 1A–1F | 3 + 3 (two batches) | Bug fixes, workspace selection, /up, /down, settings, .gitignore |
| 2 | 2A–2D | 4 | All 7 CRITICAL findings — commands wired to agents + protocols |
| 3 | 3A–3C | 3 | Git workflow (pull/push/conflict handling) |
| 4 | 4A–4D | 4 | Edge cases, error handling, retry logic, protocol validation |
| 5 | 5A–5C | 3 | Polish |
| **Total** | **23 tasks** | **max 4 concurrent** | |

### Domain architecture map

After Wave 2, the system looks like this:

```
Commands (orchestrators)              Agents                      Protocols
─────────────────────────            ──────                      ─────────
init-wiki ──────────────→ wiki-explorer ──→ source-analysis.md
                          wiki-writer  ──→ page-plan.md
                          wiki-writer  ──→ page-content.md

proofread-wiki ─────────→ wiki-explorer ──→ source-analysis.md
                          wiki-reviewer ──→ review-finding.md
                          file-issue.sh ──→ issue-body.md

refresh-wiki ───────────→ wiki-explorer ──→ drift-assessment.md
                          wiki-writer  ──→ edit-instruction.md

resolve-issues ─────────→ wiki-writer  ──→ edit-instruction.md
                          (issue input)←── issue-body.md

save ───────────────────→ (no agents — orchestrator-only)
up ─────────────────────→ (no agents — orchestrator-only)
down ───────────────────→ (no agents — orchestrator-only)
```

Shared guidance referenced by all agents:
- `editorial/editorial-guidance.md` — writing quality, tone, style
- `editorial/wiki-instructions.md` — wiki conventions, links, sidebar format
- `operations/git-workflow.md` — referenced by commands, not agents

### Known gaps

The following fusion items are intentionally deferred:

- §10.10 — Source repo READONLY enforced only by natural language. Structural enforcement would require a read-only mount or filesystem permissions, which is out of scope for prompt-level fixes. (Note: `wiki-explorer` already has `disallowedTools: Write, Edit` which provides structural enforcement for the explorer agent.)
- §7.3 — Full schema validation of subagent output. Task 4B adds field-presence checks for `refresh-wiki`; full validation across all commands is deferred — the protocol files themselves serve as the spec, and agents trained on them should conform.

### File Conflict Matrix

Each file is touched by at most one task per wave. Wave 1 uses two sequential batches to avoid conflicts on shared files.

| File | Wave 0 | Wave 1 | Wave 2 | Wave 3 | Wave 4 | Wave 5 |
|------|--------|--------|--------|--------|--------|--------|
| `protocols/*.md` | 0A | — | — | — | — | — |
| `operations/git-workflow.md` | 0B | — | — | — | — | — |
| `editorial/*.md` | 0C | — | — | — | — | — |
| `wiki-explorer.md` (agent) | 0C | — | — | — | — | — |
| `wiki-writer.md` (agent) | 0C | — | — | — | — | — |
| `wiki-reviewer.md` (agent) | 0C | — | — | — | — | — |
| `CLAUDE.md` | 0C | — | — | — | — | — |
| `init-wiki.md` | — | 1A | 2A | — | 4D | — |
| `proofread-wiki.md` | — | 1A→1C | 2B | — | 4C | 5C |
| `refresh-wiki.md` | — | 1A | 2C | 3A | 4B | 5C |
| `resolve-issues.md` | — | 1A | 2D | 3B | 4A | 5B |
| `save.md` | — | 1A | — | 3C | — | 5B |
| `up.md` | — | 1D | — | — | — | 5A |
| `down.md` | — | 1A→1F | — | — | — | 5A |
| `file-issue.sh` | — | 1C | — | — | — | — |
| `.gitignore` | — | 1B | — | — | — | — |
| `settings.json` | — | 1E | — | — | — | — |

Arrow notation (e.g., `1A→1C`) means these tasks run sequentially within the wave, not in parallel.

---

## Verification

After each wave, verify the changes before proceeding to the next.

### After Wave 0

- [ ] 7 protocol files exist in `.claude/guidance/protocols/`, each with Purpose, Producer, Consumer, Required fields, Output format sections.
- [ ] `operations/git-workflow.md` exists with pull, push, conflict, and upstream check patterns.
- [ ] `editorial/editorial-guidance.md` and `editorial/wiki-instructions.md` exist (moved from `guidance/`).
- [ ] Old paths (`guidance/editorial-guidance.md`, `guidance/wiki-instructions.md`) no longer exist.
- [ ] `CLAUDE.md` references updated to `editorial/` paths.
- [ ] `wiki-explorer.md`: references `source-analysis.md` and `drift-assessment.md` protocols.
- [ ] `wiki-writer.md`: inline writing principles removed, references `editorial/` guidance and `page-content.md` / `edit-instruction.md` protocols.
- [ ] `wiki-reviewer.md`: references `review-finding.md` protocol.

### After Wave 1

- [ ] All 6 command files reference CLAUDE.md workspace selection instead of inline steps.
- [ ] `.gitignore` includes `.proofread/` and `issues/`.
- [ ] `file-issue.sh`: run `grep -A1 '^labels:' .github/ISSUE_TEMPLATE/wiki-docs.yml | head -1` and confirm it extracts `["documentation"]`.
- [ ] `up.md`: confirm step order is interview → derive → check exists → mkdir → clone → write config.
- [ ] `down.md`: confirm path validation exists before any `rm -rf`.
- [ ] `settings.json`: spot-check that `mkdir`, `rm`, `gh issue close`, `gh issue comment`, `bash .scripts/*` are all covered.

### After Wave 2

- [ ] All four swarm commands reference custom agents (`wiki-explorer`, `wiki-writer`, `wiki-reviewer`) instead of inline `subagent_type` declarations.
- [ ] All four swarm commands specify which protocol each agent should follow in its task prompt.
- [ ] `wiki-writer` agents are instructed to apply edits directly (Write for new pages, Edit for existing). Orchestrator does NOT call Edit/Write on wiki content.
- [ ] Orchestrator collects confirmations/change reports via `TaskOutput`. No editorial judgment at orchestrator level.
- [ ] `init-wiki.md` frontmatter: `TaskOutput` present; `Edit` and `Write` removed from `allowed-tools`.
- [ ] `refresh-wiki.md` frontmatter: `TaskOutput` present; `Edit` removed from `allowed-tools`.

### After Wave 3

- [ ] `refresh-wiki.md`, `resolve-issues.md`: confirm `git pull --ff-only` in Phase 0.
- [ ] `resolve-issues.md`: confirm push-then-close flow (commit → push → close issues). Confirm issues are NOT closed before push.
- [ ] `save.md`: confirm it checks both uncommitted (`git status --porcelain`) and unpushed (`git log @{u}..HEAD`), and runs `pull --rebase` before push.
- [ ] All three commands reference `operations/git-workflow.md`.

### After Wave 4

- [ ] `resolve-issues.md`: fixer agents reference `editorial/` guidance, not `CLAUDE.md`. `{tone}` is used, not hardcoded.
- [ ] `refresh-wiki.md`: source-to-wiki mapping reads `_Sidebar.md` and scans page content. Explorer output validated against `drift-assessment.md` protocol.
- [ ] `proofread-wiki.md`: `.proofread/` cleared at start, issue cap exists, `_Sidebar.md` existence check present.
- [ ] `init-wiki.md`: no inline writing principles remain.

### After Wave 5

- [ ] `up.md`: `--depth 1` on source clone, `gh repo view` validation.
- [ ] `down.md`: single safety prompt, empty parent dir cleanup.
- [ ] Smoke test: run `/up` with a test repo, then `/init-wiki`, then `/save`, then `/down` — full lifecycle.
