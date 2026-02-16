# DC-01 -- Wiki Creation

## Purpose

Owns the transition from an empty wiki to a populated wiki. The source code is explored, a wiki structure is proposed and approved by the user, and writer agents produce pages. This context assumes the wiki has no existing content pages -- restructuring an existing wiki belongs to [DC-06 Wiki Restructuring](DC-06-wiki-restructuring.md).

## Ubiquitous language

- **Exploration report** -- A structured summary of one facet of the source code (API surface, architecture, configuration), produced by an explorer agent.
- **Wiki plan** -- A hierarchical structure of sections containing pages, each with filename, title, description, and key source files. Proposed by the planning agent, refined and approved by the user.
- **Writer assignment** -- The input to a writer agent: page file path, title, description, key source files, audience, tone, and editorial guidance.

## Use cases

- [UC-01](../UC-01-populate-new-wiki.md) -- Populate new wiki from source code with user-approved structure

## Domain events produced

- [DE-01 WikiPopulated](DOMAIN-EVENTS.md#de-01----wikipopulated)

## Integration points

- **Requires:** [DC-05 Workspace Lifecycle](DC-05-workspace-lifecycle.md) -- workspace must be provisioned before wiki creation.
- **Feeds:** [DC-02 Editorial Review](DC-02-editorial-review.md) -- populated wiki is ready for quality review. [DC-04 Drift Detection](DC-04-drift-detection.md) -- populated wiki has content pages to sync.
