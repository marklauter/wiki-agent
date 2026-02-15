# wiki-writer

Claude Code toolset for GitHub wiki management: creation, editorial review, sync, and issue tracking. Works with any GitHub project.

## How it works

wiki-writer is a reusable workspace powered by [Claude Code](https://docs.anthropic.com/en/docs/claude-code). You open this project, tell it which GitHub repo you're working on, and it clones the source and wiki repos into a local `workspace/` directory. All commands then operate against whatever project is currently loaded.

Nothing is permanent — cloned repos and config are gitignored. Switch projects any time by running `/up` with a different repo.

### Workspace layout

```
wiki-writer/
├── .claude/              # Commands, skills, and guidance (checked in)
├── workspace/            # Cloned repos (gitignored)
│   ├── MyProject/        # Source repo
│   └── MyProject.wiki/   # Wiki repo
└── workspace.config.yml   # Current project config (gitignored)
```

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- Git configured with access to your GitHub repos

## Getting started

1. **Clone wiki-writer:**

   ```bash
   git clone https://github.com/your-org/wiki-writer.git
   cd wiki-writer
   ```

2. **Open it in Claude Code:**

   ```bash
   claude
   ```

3. **Load a project:**

   ```
   /up owner/repo
   ```

   This clones the source repo and its wiki into `workspace/`, asks you about target audience and tone, and writes `workspace.config.yml`. All other commands use this config.

4. **Work on the wiki** using the commands below.

5. **Tear down when done:**

   ```
   /down
   ```

   This checks for uncommitted or unpushed wiki changes before cleaning up.

## Commands

### `/up owner/repo`

Set up a project workspace. Clones (or pulls) the source repo and wiki repo into `workspace/`, then interviews you for audience and tone preferences. Writes `workspace.config.yml` with:

- `repo` — GitHub `owner/repo` slug
- `sourceDir` — path to cloned source repo
- `wikiDir` — path to cloned wiki repo
- `audience` — target audience for the wiki
- `tone` — writing tone (e.g., reference-style, tutorial-style)

If the target project has a `CLAUDE.md`, it reads that for project context. If the wiki already exists, it reads `_Sidebar.md` to understand the current structure.

Run `/up` without arguments to confirm which project is currently loaded.

### `/down`

Tear down the current workspace. Before removing anything, it checks for:

- **Uncommitted changes** in the wiki repo — warns and asks to confirm
- **Unpushed commits** in the wiki repo — warns and asks to confirm

Then removes the cloned repos, config file, and (if empty) the `workspace/` directory.

### `/refresh-wiki`

Sync wiki pages with recent source code changes. Reads the last 50 commits from the source repo, identifies behavioral changes, maps them to wiki pages, and launches parallel agents to compare source against docs. Pages that are stale get updated automatically.

### `/proofread-wiki`

Editorial review of wiki pages. Launches parallel reviewer agents that audit pages across four passes:

| Pass | Scope |
|------|-------|
| `structural` | Organization, flow, gaps, redundancies |
| `line` | Sentence-level clarity and tightening |
| `copy` | Grammar, punctuation, formatting, terminology |
| `accuracy` | Verify claims and examples against source code |

Findings are filed as GitHub issues with the `docs` label. Run with specific pages or passes, or review everything at once.

### `/resolve-issues`

The complement to `/proofread-wiki`. Reads open `docs`-labeled GitHub issues, applies the recommended corrections to wiki pages, and closes the issues. Supports filtering by issue number or page name. Use `--dry-run` to preview changes without applying them.

## Switching projects

To switch to a different project, run `/up` with the new repo:

```
/up owner/other-repo
```

This replaces the current workspace. If you want a clean slate first, run `/down` before `/up`.
