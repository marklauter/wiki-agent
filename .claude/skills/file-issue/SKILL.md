---
name: file-issue
description: Files a GitHub issue (tech-debt, bug report, or docs) using gh CLI. Use when code review reveals tech debt, bugs, or documentation problems.
model: haiku
allowed-tools: Bash, Read, Glob
---

Fully autonomous — infer everything from context, never ask, never confirm.

## Setup

Read `workspace.config.yml` to get `repo` and `sourceDir`. If missing, return an error message and stop.

## Templates

Read the matching template to extract field names, dropdown options, and required/optional flags:

| Type | Template path | Label |
|------|--------------|-------|
| Tech debt | `{sourceDir}/.github/ISSUE_TEMPLATE/tech-debt.yml` | `tech-debt` |
| Bug report | `{sourceDir}/.github/ISSUE_TEMPLATE/bug-report.yml` | `bug` |
| Documentation | `{sourceDir}/.github/ISSUE_TEMPLATE/docs.yml` | `documentation` |

If the template file doesn't exist, fall back to a plain issue (no `--template` flag) and format the body as freeform markdown.

## Steps

1. **Infer issue type** from the caller's context. Default to `docs` when the caller is a wiki skill.
2. **Read the template file.** Extract `id`, `label`, `type`, `options`, and `validations.required` from each field.
3. **Check for duplicates:** `gh issue list --repo {repo} --state open --label LABEL --search "keywords" --limit 10 --json number,title`. If a close match exists, return the existing issue number and skip filing.
4. **Infer all field values** from context. Use `_No response_` for optional fields that can't be inferred.
5. **Build the body** with `### Field Name` sections matching the template's `id` values.
6. **Write body to a temp file** to avoid shell quoting issues:
   ```bash
   cat > /tmp/gh-issue-body.md << 'ISSUE_EOF'
   ... body content ...
   ISSUE_EOF
   ```
7. **Create the issue:**
   ```bash
   gh issue create --repo {repo} --template "TEMPLATE.yml" \
     --title "TITLE" --body-file /tmp/gh-issue-body.md --label LABEL
   ```
   Pass `--label` explicitly — don't rely on `--template` to apply labels.
8. **Return the issue URL** from the command output. Clean up the temp file.

## Title

Under 70 characters. Descriptive, no category prefix (the label handles that). Focus on *what's wrong*, not the fix.

## Caller overrides

Callers (e.g., `wiki-review`) may override: issue type, label, title constraints, and template. Apply overrides as given — they take precedence over inference.
