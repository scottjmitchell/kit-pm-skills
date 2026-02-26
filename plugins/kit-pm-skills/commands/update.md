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

Check which of the following expected config fields are **absent**. A field is "set" if its key line exists in the config — even if the value is blank (e.g. `prd_label:` with no value counts as set). Only ask questions for fields that are truly absent.

### Config field checklist

**`## English` section — `preference` field**
- Set if the line `preference:` exists under `## English`
- If missing → ask: "Which English spelling do you prefer?"
  - `British (the correct spelling)`
  - `American English`

**`## Editor` section — `preference` field**
- Set if the line `preference:` exists under `## Editor`
- If missing → ask: "Which text editor or IDE do you use?"
  - `VS Code — opens files with 'code'`
  - `Cursor — opens files with 'cursor'`
  - `Zed — opens files with 'zed'`
  - `System default — uses 'open' (macOS) or 'xdg-open' (Linux)`

**`## Linear` section fields**
- `prd_team` — if missing → fetch Linear teams (call `mcp__linear-server__list_teams`), ask "Which Linear team should new PRDs be created in?" with fetched teams + "Other — I'll type mine"
- `prd_label` — if the `prd_label:` line is absent entirely → ask "Should a label be applied to new PRDs?" (Yes/No). If Yes → fetch Squad labels (`mcp__linear-server__list_issue_labels`, filter by group "Squad"), ask which label. If No → write `prd_label:` (blank)
- `prd_create_as` — if missing → ask "When a PRD is approved, should it be created as a Linear issue or project?" (Issue / Project)
- `ticket_team` — if missing → ask "Where should /ticket create issues by default?" using fetched Linear teams, with "Same as PRDs — [prd_team]" as first option

**`## Feature Areas` section**
- Set if the section exists and has content below the heading
- If missing or empty → ask "What feature areas do you own?" (multiSelect):
  - `Automations (visual automations, rules, webhooks, RSS)`
  - `Extensibility (app store, APIs, developer documentation)`
  - `Email Sending (pipeline, deliverability, sequence scheduling)`
  - `Growth, monetisation, or subscriber acquisition`

**`## Integrations` section fields**
- `granola` — if missing → ask "Do you use Granola for meetings?" (Yes / No)
- `kit_docs` — if missing → ask "Do you want kit-docs search for /api and release notes?" (Yes / No)

Group questions into as few `AskUserQuestion` calls as possible (up to 4 questions per call). Don't ask about fields that are already set.

**If all fields are already set:** Tell the user their config is complete and skip to Step 5.

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
