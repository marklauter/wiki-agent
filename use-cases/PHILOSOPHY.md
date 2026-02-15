# Use case philosophy

Guiding principles for writing use cases in this project. Every use case must reflect these ideas.

## Goals over tasks

Use cases describe what an actor wants to achieve, not what steps they perform. Goals are stable — they survive model upgrades, tool changes, and prompt rewrites. Tasks are transient means to an end.

Ask "what state of the world does the actor want?" not "what commands does the actor run?"

## Invariants over preconditions

Domain rules are not entry gates you check once. They are constraints that must hold continuously — before, during, and after execution. An agent that violates an invariant mid-scenario has failed, even if the final output looks correct.

Express constraints as invariants, not as preconditions or validation steps.

## Domain events over return values

Agents communicate through meaningful state transitions, not function returns. A drift assessment, a filed finding, a change report — these are domain events. They are the published language between bounded contexts.

Name them. Define them. They are the integration points of the system.

## Obstacles over exceptions

When something goes wrong, describe the threat to the goal — not the error code. "Source code is unreachable" tells you what's at risk. "Exit code 128" tells you nothing about what to do next.

Frame failures as goal obstacles with recovery strategies, not try/catch blocks.

## Intent over mechanics

Scenario steps express what is accomplished, not how. "Wiki content is verified against current source" gives an agent room to find the best path. "Run grep on lines 1-50 of each file" does not.

The agent's job is to satisfy intent. The use case's job is to express it clearly.

## Bounded contexts over shared models

Each use case lives in a bounded context with its own language and its own rules. Proofread and resolve share a published language (the issue body protocol) but operate independently. They do not share internal state.

Respect boundaries. Define protocols at every crossing point.

## Single responsibility for agents

Writers write. Explorers explore. Reviewers review. Orchestrators coordinate. An agent that both decides what to write and evaluates whether it wrote well has two jobs and will do both poorly.

Separate judgment from execution. Separate analysis from mutation.
