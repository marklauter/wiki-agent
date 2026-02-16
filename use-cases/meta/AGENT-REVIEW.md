# use-case-designer agent review

Assessment of the use-case-designer agent based on the complete output corpus it produced: 6 fully designed use cases, 1 scoped-out use case, 1 stub, plus 12 supporting artifacts (~3,000 lines of structured design material produced across multiple sessions). Reviewed 2026-02-16.

## Strengths to preserve

### 1. Philosophical coherence

PHILOSOPHY.md contains 13 principles, and every use case artifact demonstrably follows them. "Actors have drives" is not just stated -- it is applied. The Actor Catalog classifies every agent by its drive, explains why separation exists, and uses the Assessor/Content Mutator hierarchy to distinguish agents by their defining behavioral trait (read-only judgment vs. wiki modification). The elevator examples in the philosophy doc make the ideas concrete and teach-worthy. This is not boilerplate -- it is a genuine intellectual contribution to modeling AI agent systems.

**Preserve:** The philosophy-first approach. The agent reads PHILOSOPHY.md before every session, and the template encodes principles into structure. This is the mechanism that produces coherence. Do not weaken it.

### 2. Structural consistency across use cases

Every use case follows TEMPLATE.md exactly: same sections, same ordering, same voice. Goal statements describe desired end states, not task lists. Scenario steps express intent, not mechanics. Invariants are framed as continuous rules, not preconditions. This consistency holds even though the use cases were designed across multiple sessions with fresh agent contexts each time.

**Preserve:** The template as a structural contract, not a suggestion. The agent prompt says "following TEMPLATE.md structure exactly" -- this instruction produces the consistency.

### 3. Cross-referencing integrity

Domain events referenced in use cases match their definitions in DOMAIN-EVENTS.md. Bounded context files correctly reference their use cases and integration points. The actor appearance matrix in ACTOR-CATALOG.md is accurate. Glossary entries match terminology used throughout the corpus. Spot-checked cross-references found no broken links or contradictions.

**Preserve:** The practice of defining integration points formally (domain events, protocols, bounded contexts) rather than leaving them as informal prose references.

### 4. The Socratic interview style

The agent prompt's behavioral instructions -- "ask one phase at a time," "summarize what you heard before moving on," "if the user gives a task-oriented answer, redirect to intent" -- produce high-quality extraction. The instruction "your job is to extract, not invent" is the single most important sentence in the prompt and appears to have been honored throughout. The agent never fabricated domain knowledge or invented requirements.

**Preserve:** The phase-by-phase interview with summarization between phases. This is what prevents the agent from jumping to scenarios before goals are clear.

### 5. Honest gap documentation

Implementation gaps are documented candidly in Notes sections across UC-02, UC-03, UC-04, and UC-06. UC-08 exists as an honest stub with known context rather than being fabricated or ignored. Accepted trade-offs (stale UC-02 issues after UC-04 corrections, AskUserQuestion limitations) are named explicitly rather than hand-waved.

**Preserve:** The Notes section as the home for honesty -- implementation gaps, design tensions, and open questions. The agent prompt should continue to encourage this rather than pushing for false completeness.

### 6. The actor taxonomy

The abstract Assessor/Content Mutator hierarchy with behavioral traits (read-only vs. write permission) as the classification axis is elegant. The Creator/Corrector distinction within Content Mutator is well-motivated by different judgment types (synthetic vs. mechanical). The separation rationale is grounded in drive conflicts, not arbitrary decomposition.

**Preserve:** The practice of justifying actor separation through drive conflicts ("whose drive is insufficient here, and what complementary drive is needed?") rather than functional decomposition.

### 7. Domain event design

The distinction between published events (cross-boundary) and internal events (within a use case) is correctly applied. DE-02 FindingFiled is the only event that serves as a formal integration contract, and this is explicitly called out. Internal events like IssueIdentified and DriftDetected stay in their use cases where they belong.

**Preserve:** The discipline of only promoting events to DOMAIN-EVENTS.md when they cross a bounded context boundary. Internal coordination events belong in the use case that produces them.

### 8. The meta-process artifacts

USE-CASE-PHASES.md and USE-CASE-MODEL-ARTIFACTS.md codify not just what to produce but when and why, including what triggers backtracking between phases. The relationship map at the end of USE-CASE-MODEL-ARTIFACTS.md makes the model navigable by someone who did not build it. These documents turn tacit process knowledge into explicit, teachable structure.

**Preserve:** These artifacts as living documents. They should be updated if the agent prompt or process changes.

## Structural weaknesses

### 1. Grounding phase applied inconsistently

The agent prompt says "read the relevant source files to verify that the scenario matches reality" but does not specify which source files to check or how thoroughly. UC-03, UC-04, and UC-06 have detailed implementation gap notes showing the agent compared the design against source code. UC-01 and UC-05 have fewer such notes. This may reflect genuine variation in gap density, or inconsistent grounding rigor across sessions.

**Remediation:** Add a grounding checklist to the agent prompt -- enumerate the source files to check (command file, scripts, agent definitions) and require explicit confirmation that each was read.

### 2. No post-write cross-validation

USE-CASE-PHASES.md describes backtracking between phases, but the agent prompt has no mechanism to trigger it. After writing a new use case, the agent does not systematically re-read existing use cases to verify that actor names, domain events, invariant references, and protocol definitions are consistent with the new artifact.

**Remediation:** Add a post-write validation step to the agent prompt: "After writing the use case, verify all cross-references, actor names, domain events, and shared invariants against existing artifacts. Report any inconsistencies."

### 3. Session boundary degrades accumulated context

Each agent invocation starts fresh. Accumulated domain vocabulary, design decisions, actor names, and cross-cutting invariants live in MEMORY.md and the parent context, not in the agent's own working memory. The prompt says "update your agent memory with domain terminology" but is vague about retrieval -- it does not say "read your memory before starting" or "verify your output against previously established terminology."

For 8 use cases this was manageable because the human operator provided rich context each time. For a larger model (20+ use cases), the agent would need a more robust context-loading protocol.

**Remediation:** Add an explicit retrieval step to the agent's "First steps" section: read MEMORY.md, ACTOR-CATALOG.md, GLOSSARY.md, and SHARED-INVARIANTS.md before beginning the interview. The agent already reads TEMPLATE.md and PHILOSOPHY.md -- extend the list to include vocabulary and constraint artifacts.

### 4. Template protocol notation diverges from practice

The template shows `{protocol-name.md}` suggesting protocols are separate markdown files. In practice, protocols are described inline in each use case's Protocols section. The inline descriptions are clear and functional, but the template does not match the practice.

**Remediation:** Update TEMPLATE.md to show inline protocol descriptions matching the style used in existing use cases, or extract protocols into separate files as the template implies. Pick one and make it consistent.

### 5. Duplicate agent definition

The agent definition exists in both `.claude/agents/use-case-designer.md` (operational) and `use-cases/meta/use-case-designer.md` (documentation). Both are modified in the current working tree. If someone updates one and forgets the other, they will diverge.

**Remediation:** Decide which is canonical. The operational copy (`.claude/agents/`) is what Claude Code uses. The meta copy should either be removed, replaced with a reference to the operational copy, or kept as a read-only snapshot with a clear note that the operational copy is authoritative.

### 6. Glossary does not record superseded terms

Terms like "editorial lens" replaced earlier terms ("pass"), and MEMORY.md records this decision. But the glossary entry does not note the superseded term. For a glossary meant to be the canonical spelling, noting retired vocabulary would help newcomers avoid reviving old terms.

**Remediation:** Add a "Formerly: {old term}" annotation to glossary entries where a rename occurred.

## Improvement opportunities

Actionable changes to the agent prompt and supporting artifacts, ordered by impact.

### A. Add post-write cross-validation step to the agent prompt

Addresses weaknesses 2 and partially 1. After writing a use case, the agent should re-read ACTOR-CATALOG.md, GLOSSARY.md, SHARED-INVARIANTS.md, and DOMAIN-EVENTS.md to verify that the new artifact is consistent with the existing model. Any inconsistency should be reported to the user before the session ends. This is the single highest-leverage change -- it catches the errors that accumulate silently across sessions.

### B. Make the grounding phase prescriptive

Addresses weakness 1. Replace the vague "read the relevant source files" instruction with an explicit checklist:

1. Read the command file (`.claude/commands/`) that implements this use case.
2. Read any scripts in `.scripts/` referenced by the command.
3. Read the agent definition (`.claude/agents/`) for each supporting actor.
4. Compare scenario steps against actual implementation. Document every divergence as an implementation gap in the Notes section.

The agent should confirm to the user which files it read and what gaps it found.

### C. Expand the "First steps" context-loading protocol

Addresses weakness 3. The agent currently reads TEMPLATE.md and PHILOSOPHY.md before each session. Extend this to include:

- ACTOR-CATALOG.md (established actors, drives, naming)
- GLOSSARY.md (canonical vocabulary)
- SHARED-INVARIANTS.md (cross-cutting rules)
- USE-CASE-CATALOG.md (what exists, bounded contexts)
- DOMAIN-EVENTS.md (published events, integration points)

This front-loads the accumulated model into the agent's context window, reducing dependence on the parent context or MEMORY.md to carry vocabulary and design decisions.

### D. Resolve the duplicate agent definition

Addresses weakness 5. The operational copy at `.claude/agents/use-case-designer.md` is canonical -- it is what Claude Code executes. The meta copy at `use-cases/meta/use-case-designer.md` should either be deleted or replaced with a one-line reference pointing to the operational copy.

## What is not a weakness

These are design choices that could be questioned but that hold up under scrutiny:

- **AskUserQuestion as the interview channel.** Limited compared to free-form conversation, but acceptable for MVP. The agent itself documents this limitation in UC-01's notes.
- **One use case per session.** Matches the Socratic interview style. Batching would compromise depth.
- **No automated testing of cross-references.** The model is small enough (8 use cases) that manual verification suffices. A larger model would need tooling.
- **Meta-process artifacts written after most use cases.** USE-CASE-PHASES.md and USE-CASE-MODEL-ARTIFACTS.md codify a process that was already working. Writing them earlier would have been ideal but is not a deficiency -- the process was implicit in the agent prompt and became explicit through practice.

## Verdict

The use-case-designer agent is a well-designed tool that has produced professional-quality output. The corpus would hold up under peer review by someone trained in Cockburn-style use cases or Evans-style domain modeling. The actor taxonomy with drives is original and well-applied. The philosophical coherence is the strongest signal of quality -- it is easy to write one good use case, but maintaining consistency across 6 fully designed use cases plus a dozen supporting artifacts requires either rigorous process or a well-structured agent. This agent provides the latter.

The agent's design philosophy -- the designer structures, the domain expert knows -- is the right stance for working with a knowledgeable user. The Socratic interview style produces better results than a template-filling approach because it forces the user to articulate goals and constraints in their own terms before the agent imposes structure. The five-phase progression (goal, invariants, events, scenarios, grounding) is well-ordered. Goal discovery first prevents the common failure mode of jumping straight to scenarios and discovering halfway through that the goal is unclear.

The main improvement opportunities are operational, not philosophical. The agent's beliefs are sound; its process needs tightening at the edges -- especially around cross-validation, grounding rigor, and context loading across session boundaries.
