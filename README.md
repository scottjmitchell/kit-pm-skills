# kit-pm-skills

Claude Code plugin with PM workflow commands for Kit PMs.

## Commands

| Command | What it does |
|---|---|
| `/prd <topic>` | Runs parallel internal + competitive research, drafts a PRD, runs a critical review |
| `/prd <ticket ID>` | Fetches an existing Linear ticket and produces a refined PRD from it |
| `/shipped <feature>` | Gathers Linear context + docs, produces an internal Slack post and external developer release note |

## Install

```bash
claude plugin install kit-pm@github:scottmitchell/kit-pm-skills
```

Or from a local clone:

```bash
claude --plugin-dir ~/path/to/kit-pm-skills
```

## Workspace setup

The commands expect this directory structure in your workspace root. They create missing directories automatically on first run, but you'll want to commit the empty folders:

```
your-workspace/
├── prds/              # PRD markdown files
├── shipped-notes/     # Release notes output
└── my-features/       # (Optional) Feature area docs — used by /prd for internal context
```

## Required: Linear MCP

Both commands use Linear to find tickets and projects. Make sure the Linear MCP server is configured in your workspace:

```json
// .mcp.json
{
  "linear-server": {
    "type": "...",
    "...": "..."
  }
}
```

## Optional: kit-docs MCP

`/shipped` uses the `kit-docs` MCP to search developer documentation for API/plugin features. If you don't have it configured, this step is skipped automatically.

## Optional: Granola MCP

`/shipped` uses Granola meeting notes to match the author's tone of voice in release notes. If Granola isn't available, the command falls back to standard style guide guidance automatically.

## After running /prd

Once you're happy with the PRD, confirm it and the command will:
1. Create a Linear issue in the **Product Backlog** team (status: Backlog)
2. Use the PRD title as the issue title
3. Open the issue in your browser

If your team uses a different Linear team name, update the post-approval step in `commands/prd.md`.

## References

The `references/` directory contains the full style guides used by both commands. These are for human reference — the commands have the key rules inlined:

- `references/style-prd.md` — PRD voice, tone, and formatting guide
- `references/style-release-notes.md` — Release notes format guide (internal Slack + external changelog)
- `references/prd-template.md` — Blank PRD template
