---
description: Generate release notes when a feature ships — writes the internal #all-shipped Slack post (with tone matched to the PM's natural voice) and an optional developer changelog entry. Use this any time a feature lands, you want to announce what shipped, write up a release, or create a developer-facing changelog entry.
argument-hint: <feature name or description>
allowed-tools: [Bash, Read, Write, Glob, Grep, Task, AskUserQuestion]
---

# Shipped Release Notes

Generate release notes for a shipped feature: $ARGUMENTS

## Setup

Before doing anything else:

1. Run: `mkdir -p shipped-notes .claude/state`
2. Read `.claude/pm-skills/config.md` if it exists. Extract and store:
   - `feature_areas` — used to focus PRD and docs search
   - `kit_docs` — `yes` or `no` (if `no`, skip the kit-docs MCP search in Agent 2)

3. **Load tone of voice**: Check if `.claude/pm-skills/tone-of-voice.md` exists.
   - If it exists: read it and write its contents to `.claude/state/shipped-tone.md`
   - If it doesn't exist: write the following to `.claude/state/shipped-tone.md`:
     ```
     No tone reference found. Use a professional, accessible, team-focused voice per the style guide.
     Tip: run /tone to build a personalised tone reference from Granola meetings.
     ```

4. If `shipped-notes/MEMORY.md` exists, read it for context on past conventions before starting.

Read `.claude/pm-skills/communication-styles/style-release-notes.md` for format, Slack mrkdwn rules, voice guidelines, and the output file structure. If this file doesn't exist, run `/setup` first.

### Config check

If any of the following are missing or empty, ask for them in a single `AskUserQuestion` call before proceeding. Skip entirely if all are present.

| Key | Question to ask | Options |
|---|---|---|
| `feature_areas` | "What feature areas do you own? (Used to focus docs and PRD search)" | "Automations" / "Extensibility" / "Email Sending" / "Other — I'll describe mine" |
| `kit_docs` | "Should release notes search Kit developer docs for API/plugin context?" | "Yes — I have kit-docs configured" / "No — skip" |

After collecting answers, update `.claude/pm-skills/config.md`: add missing keys using the same format as existing entries. Don't reformat or remove existing values.

5. Use `AskUserQuestion` to ask:
   > Does this feature need a developer changelog entry?
   - **Yes — Slack post + developer changelog** (API changes, new endpoints, App Store/Plugin/Webhook updates, or anything developer-facing)
   - **No — Slack post only**

   Store the answer as `needs_dev_changelog: yes` or `needs_dev_changelog: no`.

---

## Instructions

### Step 1: Launch parallel data-gathering agents

Spawn **two** `general-purpose` Task agents **in a single message**. Pass each agent the feature input (`$ARGUMENTS`).

**Agent 1 — Linear Feature Context**

```
Find the shipped feature details in Linear. The feature is: [USER'S INPUT]

1. Search for the feature in completed projects: list_projects with state "completed" and a query matching the feature name
2. If not found as a project, search completed issues: list_issues with state "done" and a query matching the feature name
3. Get full project/issue details including description and resources
4. List all completed issues within the project
5. Collect all unique assignee names — these are the builders to credit

Write findings to .claude/state/shipped-linear.md
Include: project link, all issue IDs and titles, assignee names, project description, implementation details from issue descriptions.
```

**Agent 2 — PRDs & Developer Docs**

```
Search for internal documentation related to this shipped feature: [USER'S INPUT]

1. Check prds/ in the current workspace for related PRDs — glob for *.md files, grep for the feature name
2. If kit-docs is configured (kit_docs: yes in config), search Kit developer documentation using the kit-docs MCP (SearchKitDeveloperDocumentation) for API, plugin, or developer-facing components
3. Check my-features/ in the current workspace if it exists

PM's feature areas for context: [feature_areas from config, or "not configured"]

Write findings to .claude/state/shipped-docs.md
Include: relevant PRD excerpts (problem statement, goals, key features), developer doc links, API/plugin details.
```

### Step 2: Assess completeness

After both agents return, read:
- `.claude/state/shipped-linear.md`
- `.claude/state/shipped-docs.md`
- `.claude/state/shipped-tone.md`

Verify you have enough to cover:
- **What** the feature does
- **Why** it matters (problem solved, user benefit)
- **How** to use it (workflow, API endpoints if relevant)
- **Where** to learn more (docs links)

If any of these are unclear, use `AskUserQuestion` to ask for missing details. Ask all questions at once.

### Step 3: Hand off to copywriter

Spawn a **copywriter** Task agent (`subagent_type: "copywriter"`) with all gathered context:

```
Write shipped release notes for a feature. I'm providing feature context, internal documentation, tone of voice, and format requirements.

First, read the style guide at `.claude/pm-skills/communication-styles/style-release-notes.md` — it defines format, Slack mrkdwn rules, voice guidelines, and the exact output file structure to use.

## Feature Context (from Linear)
[Insert contents of .claude/state/shipped-linear.md]

## Internal Documentation
[Insert contents of .claude/state/shipped-docs.md]

## Tone of Voice
[Insert contents of .claude/state/shipped-tone.md]

---

Additional notes:
- Wrap the Slack post in a markdown code fence so it's easy to copy.
- Omit the External Developer Release Note section entirely if needs_dev_changelog: no.
- Match the tone of voice samples closely — vocabulary, energy, how value and impact are framed. If no tone samples were available, use a professional, accessible, team-focused voice. The notes should sound human, not like a generic PM template.

Write the complete file content and return it.
```

### Step 4: Save and open

Take the copywriter's output and:
1. Generate a kebab-case filename with today's date: `YYYY-MM-DD-feature-name.md`
2. Save to `shipped-notes/`
3. Open the file: `code shipped-notes/<filename>.md`

### Step 5: Developer Changelog (optional)

If `needs_dev_changelog: no`, skip this step entirely.

If `needs_dev_changelog: yes`:

**First, generate the `<Update>` block** from the External Developer Release Note and show it to the user for approval before doing anything else.

```xml
<Update label="Month YYYY" tags={["Tag1"]}>
## EMOJI Title
1–2 sentences or 2–4 bullets. Preserve all developers.kit.com links. No internal references.
</Update>
```
Emoji: 🚀 Added · 🔧 Changed · 🐛 Fixed · ⚠️ Breaking
Valid tags: `"API"`, `"Kit App Store"`, `"Plugins"`, `"Webhooks"`, `"SDK"`, `"Authentication"`, `"Documentation"`, `"Forms"`, `"Automation"`, `"Commerce"`, `"Analytics"`

**Once approved, check whether the developer-documentation repo is available locally:**

Run: `find ~/Projects ~/Developer ~/Code ~/Sites -maxdepth 4 -name "developer-documentation" -type d 2>/dev/null | head -1`

**Path found → push it yourself:**
1. `cd` into the found path, fetch origin, checkout main, pull
2. Create branch: `changelog/YYYY-MM-DD-feature-slug`
3. Insert the `<Update>` block at the top of `changelog.mdx` (after frontmatter, before first existing entry)
4. Commit (`changelog: add [feature name] entry`), push, open PR with `gh pr create --base main`
5. Output the PR URL and open it in the browser: `open <PR URL>`

**Path not found → hand off via Slack:**
Use the Slack MCP (`mcp__claude_ai_Slack__slack_send_message`) to post in `#ecosystem-talk`:

> Hey @scott / @imjohnbo — can one of you push this developer changelog entry for [feature name]? Just needs to go in `changelog.mdx` at the top of the Kit developer docs.
>
> ```
> [the approved <Update> block]
> ```

If the Slack MCP is unavailable, display the message and ask the user to post it manually in `#ecosystem-talk`.

### Step 6: Clean up

Delete the temporary files:
- `.claude/state/shipped-linear.md`
- `.claude/state/shipped-docs.md`
- `.claude/state/shipped-tone.md`

If you learned anything new about the feature area, team conventions, or product that would help future release notes, append it to `shipped-notes/MEMORY.md`.

### Step 7: Background tone refresh

If `granola` is `yes` in config, spawn a background Task agent to keep the tone reference fresh for next time:

Spawn a `general-purpose` Task agent with `run_in_background: true`:

```
Refresh the tone of voice reference at .claude/pm-skills/tone-of-voice.md from recent Granola meetings.

1. Use list_meetings to find the 10 most recent meetings
2. Use get_meeting_transcript for the 5 most content-rich meetings (skip short standups)
3. Extract:
   - Voice Profile: 3–5 bullet summary of communication style
   - Representative Samples: 8–10 excerpts (1–3 sentences each) capturing the natural speaking voice
   - Key Patterns: vocabulary preferences, formality level, sentence rhythm
4. Write to .claude/pm-skills/tone-of-voice.md:

# Tone of Voice Reference

> Last updated: [today's date]

## Voice Profile
[bullets]

## Representative Samples
[excerpts]

## Key Patterns
[bullets]

If Granola MCP is unavailable, exit silently without modifying the file.
```
