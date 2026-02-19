---
description: Generate internal Slack post and external developer release notes for a shipped feature
argument-hint: <feature name or description>
allowed-tools: [Bash, Read, Write, Glob, Grep, Task, AskUserQuestion]
---

# Shipped Release Notes

Generate release notes for a shipped feature: $ARGUMENTS

## Setup

Before doing anything else, run:
```bash
mkdir -p shipped-notes .claude/state
```

If `shipped-notes/MEMORY.md` exists, read it for context on past conventions before starting.

---

## Release Notes Style Guide

### Internal Slack Post (#all-shipped)

**Structure:**
- Emoji + bold title (e.g. `*Custom Field Webhooks*`)
- `*What shipped:*` — one sentence on the feature/capability
- `*Problem solved:*` — why it matters; user pain or business opportunity
- `*How it works:*` — 2–4 bullets, no jargon; translate technical terms into user benefits
- `*Expected impact:*` — user/business outcome
- `*Links:*` — Mixpanel dashboard, Linear project, docs

**Slack mrkdwn format (not markdown):**
- `*bold*` not `**bold**`
- `_italic_` not `*italic*`
- `•` bullets, not `-` dashes
- `` `code` `` for inline code
- `<url|link text>` for links

**Voice:** Celebratory but grounded. Accessible to non-technical readers. Active voice, present tense. Bold key terms.

### External Developer Release Note

**Structure:** No headings. Tight paragraph or 3–5 bullets. Lead with what's new → what it enables → how to use it → link to docs.

**Voice:** Technically precise. Benefit-focused, no marketing fluff. Assume developer fluency. Include endpoint paths, HTTP methods, OAuth requirements, parameter names where relevant.

---

## Instructions

### Step 1: Launch parallel data-gathering agents

Spawn **three** `general-purpose` Task agents **in a single message**. Pass each agent the feature input (`$ARGUMENTS`).

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
2. Search Kit developer documentation using the kit-docs MCP (SearchKitDeveloperDocumentation) if the feature has API, plugin, or developer-facing components — skip this step if kit-docs MCP is unavailable
3. Check my-features/ in the current workspace if it exists

Write findings to .claude/state/shipped-docs.md
Include: relevant PRD excerpts (problem statement, goals, key features), developer doc links, API/plugin details.
```

**Agent 3 — Tone of Voice** *(skip gracefully if Granola MCP is unavailable)*

```
Fetch recent meeting notes from Granola to extract the author's natural communication style and tone of voice.

1. Use the Granola MCP: list_meetings to find 5 recent meetings
2. Use get_meeting_transcript for 2–3 of them
3. Analyse natural communication patterns:
   - Vocabulary and phrasing preferences
   - How features and impact/value are described
   - Level of formality vs. casual energy
   - Sentence structure preferences (short/punchy vs. detailed)
   - Level of enthusiasm and how it's expressed

If Granola MCP tools are unavailable, write a note to .claude/state/shipped-tone.md saying "Granola unavailable — use standard team voice from style guide."

Write findings to .claude/state/shipped-tone.md
Include: a summary of tone patterns AND 3–5 representative excerpts that capture their voice.
```

### Step 2: Assess completeness

After all three agents return, read:
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

## Feature Context (from Linear)
[Insert contents of .claude/state/shipped-linear.md]

## Internal Documentation
[Insert contents of .claude/state/shipped-docs.md]

## Tone of Voice
[Insert contents of .claude/state/shipped-tone.md]

---

## Style Guide

### Internal Slack Post
Structure:
- Emoji + bold title
- *What shipped:* one sentence
- *Problem solved:* user pain or business opportunity
- *How it works:* 2–4 bullets, jargon-free
- *Expected impact:* user/business outcome
- *Links:* dashboards, Linear project, docs

Slack mrkdwn (not markdown): *bold*, _italic_, • bullets, `code`, <url|link text> for links
Voice: Celebratory but grounded. Accessible to non-technical readers. Active voice, present tense.
Wrap the entire Slack post in a markdown code fence so it's easy to copy.

### External Developer Release Note
Structure: No headings. Tight paragraph or 3–5 bullets. Lead with what's new → what it enables → how to use it → docs link.
Voice: Technically precise. Benefit-focused, no marketing fluff. Include endpoint paths, HTTP methods, OAuth requirements where relevant.
Length: Extremely concise — changelog entry, not blog post.

---

## Output Structure

# [Feature Name] — Shipped Release Notes

> Generated: [today's date] | Project: [Linear project link]
> Builders: [all unique assignees from completed issues]

---

## Internal Slack Post (#all-shipped)

[Slack mrkdwn content in a code fence]

---

## External Developer Release Note

[Developer-facing content]

---

Match the tone of voice samples closely — vocabulary, energy, how value and impact are framed. If no tone samples were available, use a professional, accessible, team-focused voice. The notes should sound human, not like a generic PM template.

Write the complete file content and return it.
```

### Step 4: Save and open

Take the copywriter's output and:
1. Generate a kebab-case filename with today's date: `YYYY-MM-DD-feature-name.md`
2. Save to `shipped-notes/`
3. Open the file: `open shipped-notes/<filename>.md`

### Step 5: Clean up

Delete the temporary files:
- `.claude/state/shipped-linear.md`
- `.claude/state/shipped-docs.md`
- `.claude/state/shipped-tone.md`

If you learned anything new about the feature area, team conventions, or product that would help future release notes, append it to `shipped-notes/MEMORY.md`.
