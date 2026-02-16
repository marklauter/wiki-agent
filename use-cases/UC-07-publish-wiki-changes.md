# UC-07 -- Publish Wiki Changes

**STATUS: OUT OF SCOPE**

## Goal

Local wiki changes are committed and pushed to GitHub so they become visible on the live wiki.

## Rationale for scoping out

Publishing wiki changes is a standard git workflow -- commit and push. Users can do this with whatever tool they already use: the git CLI, their IDE's source control panel, a GUI client, etc. The system does not need to own this workflow.

The question of how much intelligence to invest in commit message generation (semantic diff-based messages vs. file-name summaries), whether to gate on user confirmation before pushing, and how to handle multiple unpushed commits revealed design complexity that does not justify the value. The user knows their tools.

## Design decisions made before scoping out

These are recorded in case UC-07 is ever revisited:

- **Semantic commit messages.** The LLM would read diffs and produce content-aware commit messages describing *what changed*, not just which files were touched. The commit message was the sole judgment step in the workflow.
- **No confirmation gate before push.** Publishing adds to the remote rather than destroying local work. Showing the diff summary was considered sufficient -- no type-to-confirm pattern.
- **Pull --rebase before push.** The system would pull with rebase to integrate any remote changes before pushing, consistent with the cross-cutting "clones reflect remote state" invariant.
- **Scripts own deterministic behavior.** `wiki-save.sh` (stage, commit, push) and `check-wiki-safety.sh` (detect uncommitted/unpushed) already exist in `.scripts/` and would have been the implementation backbone.
