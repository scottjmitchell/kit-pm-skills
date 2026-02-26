---
description: Update kit-pm-skills and apply any new settings not yet in your config
allowed-tools: [Bash, Read, Write, Edit, AskUserQuestion, mcp__linear-server__list_teams, mcp__linear-server__list_issue_labels]
---

# Update kit-pm-skills

Check for remote updates, pull if available, then run incremental setup for any new or missing config settings.

---

## Step 1: Read current versions

Read the local plugin version:
```bash
python3 -c "import json; d=json.load(open('$HOME/.claude/plugins/marketplaces/kit-pm-skills/plugins/kit-pm-skills/.claude-plugin/plugin.json')); print(d['version'])"
```

Read the `installed_version` from `.claude/pm-skills/config.md`. Look for a line starting with `installed_version:`. If not found, treat as `not set`.

Store both as `local_version` and `installed_version`.

---

## Step 2: Check for remote updates

```bash
cd "$HOME/.claude/plugins/marketplaces/kit-pm-skills" && git fetch origin 2>&1 && git log HEAD..origin/master --oneline
```

**If commits are listed (updates available):**

Read the remote plugin version:
```bash
cd "$HOME/.claude/plugins/marketplaces/kit-pm-skills" && git show origin/master:plugins/kit-pm-skills/.claude-plugin/plugin.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['version'])"
```

Tell the user what's available, e.g.:
```
kit-pm-skills v1.3.0 is available (you're on v1.2.0)

New commits:
  abc1234 Add /update command and version tracking
  def5678 Add editor preference to setup
```

Use `AskUserQuestion` to ask:
"Pull update from v[local_version] → v[remote_version]?"
- `Yes — pull and apply new settings`
- `No — just check for missing settings (stay on current version)`

**If already up to date:** Tell the user they're on the latest version and skip to Step 4.

---

## Step 3: Pull (if confirmed)

```bash
cd "$HOME/.claude/plugins/marketplaces/kit-pm-skills" && git pull origin master
```

Re-read the local plugin version after pulling and store as `local_version`.

---

## Step 4: Incremental setup

Read `.claude/pm-skills/config.md` in full.

### 4a. Identify missing fields

Go through each field below and mark it as **present** or **missing**. A field is present if its key line exists anywhere in the config file — even with a blank value (e.g. `prd_label:` with nothing after it counts as present). Do not ask about present fields under any circumstances.

| Field | Present if config contains… |
|---|---|
| `english` | `preference:` line under `## English` |
| `editor` | `preference:` line under `## Editor` |
| `prd_team` | `prd_team:` line under `## Linear` |
| `prd_label` | `prd_label:` line under `## Linear` (blank value is fine) |
| `prd_create_as` | `prd_create_as:` line under `## Linear` |
| `ticket_team` | `ticket_team:` line under `## Linear` |
| `feature_areas` | `## Feature Areas` section with non-empty content below it |
| `granola` | `granola:` line under `## Integrations` |
| `kit_docs` | `kit_docs:` line under `## Integrations` |

**If all fields are present:** tell the user their config is complete and skip straight to Step 5. Do not ask any questions.

### 4b. Ask only about missing fields

If one or more fields are missing, fetch any Linear data needed first (only if `prd_team` or `ticket_team` or `prd_label` are missing):
- `prd_team` or `ticket_team` missing → call `mcp__linear-server__list_teams`
- `prd_label` missing → call `mcp__linear-server__list_issue_labels`, filter to group `Squad`

Then ask only about the missing fields, grouped into as few `AskUserQuestion` calls as possible (up to 4 questions per call):

- `english` → "Which English spelling do you prefer?" — `British (the correct spelling)` / `American English`
- `editor` → "Which text editor or IDE do you use?" — `VS Code` / `Cursor` / `Zed` / `System default`
- `prd_team` → "Which Linear team should new PRDs be created in?" — fetched teams + `Other — I'll type mine`
- `prd_label` → "Should a label be applied to new PRDs?" (Yes/No). If Yes → ask which Squad label using fetched labels. If No → write `prd_label:` (blank)
- `prd_create_as` → "When a PRD is approved, should it be created as a Linear issue or project?" — `Issue` / `Project`
- `ticket_team` → "Where should /ticket create issues by default?" — `Same as PRDs — [prd_team]` + other fetched teams + `Other`
- `feature_areas` → "What feature areas do you own?" (multiSelect) — `Automations` / `Extensibility` / `Email Sending` / `Growth, monetisation, or subscriber acquisition`
- `granola` → "Do you use Granola for meetings?" — `Yes` / `No`
- `kit_docs` → "Do you want kit-docs search for /api and release notes?" — `Yes` / `No`

---

## Step 4b: Refresh pricing-packaging.md (only if a git pull was performed in Step 3)

If the user confirmed and a pull was performed, refresh the local pricing-packaging reference from the updated plugin:

```bash
cat "$HOME/.claude/plugins/marketplaces/kit-pm-skills/plugins/kit-pm-skills/references/pricing-packaging.md"
```

Write the output to `.claude/pm-skills/pricing-packaging.md`, replacing the `last_synced:` line in the frontmatter with today's date (YYYY-MM-DD). This keeps the local copy in sync with any structural changes shipped in the plugin update.

---

## Step 5: Update config

For each new answer, add the field to config using `Edit`. Add new sections if the section heading doesn't exist yet. Never overwrite sections that already have content.

**Always** add or update the `## Plugin` section at the end of config with the current local plugin version:

```
## Plugin
installed_version: [local_version]
```

If a `## Plugin` section already exists, update the `installed_version` line. If it doesn't exist, append the section.

---

## Step 6: Confirm

```
✅ kit-pm-skills updated

[if pulled:]  v[old_version] → v[new_version]
[if no pull:] Already on v[local_version]

[if new fields were configured:]
New settings applied:
  [list fields that were added, e.g. "Editor: VS Code"]

[if nothing new:]
Config is complete — no new settings needed.

[if pull happened:]
See CHANGELOG for what's new:
  ~/.claude/plugins/marketplaces/kit-pm-skills/CHANGELOG.md
```
