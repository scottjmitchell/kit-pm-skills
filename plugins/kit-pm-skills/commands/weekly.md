---
description: Generate a weekly Lattice check-in from your Linear, Granola, and Notion activity. Use this any time you need to write your weekly manager update — even with no context. Just run it and answer a few quick questions about your wins and priorities. Use when the user says "write my weekly", "weekly update", "Lattice check-in", "weekly review", or wants to write up what they did this week.
argument-hint: <optional focus or context>
allowed-tools: [Bash, Read, Write, Task, AskUserQuestion]
---

# Weekly Check-in

Generate a weekly Lattice check-in from the past 7 days of activity.

## Setup

1. Run: `mkdir -p weekly-updates .claude/state`
2. Read `.claude/pm-skills/config.md` if it exists. Extract and store:
   - `ticket_team` — Linear team to query for weekly activity (fall back to `prd_team`, then ask)
   - `feature_areas` — PM's owned features (used to focus research)
   - `granola` — `yes` or `no` (skip Granola agent if `no`)
   - `english` — British or American (default: British)
3. Read `.claude/pm-skills/communication-styles/style-weekly-update.md` for the output format and voice guidelines. If this file doesn't exist, run `/setup` first.

### Config check

If any of the following are missing, collect them before proceeding. Batch missing items into a single `AskUserQuestion` call.

| Key | Question to ask | Options |
|---|---|---|
| `ticket_team` (no fallback) | "Which Linear team should `/weekly` query for your activity?" | Fetched teams + "Other — I'll type mine" |
| `feature_areas` | "What feature areas do you own?" | "Automations" / "Extensibility" / "Email Sending" / "Other — I'll describe mine" |
| `granola` | "Do you use Granola? (Used as a content source for meetings and decisions this week, plus tone matching)" | "Yes" / "No" |

After collecting, update `.claude/pm-skills/config.md`: add missing keys, don't reformat existing values.

---

## Step 1: Launch parallel research agents

Spawn agents **in a single message**. Both use `model: "haiku"`.

**Agent 1 — Linear activity** (`subagent_type: "general-purpose"`)

```
Fetch this week's Linear activity for the [ticket_team] team.

Run all three queries in parallel:
1. list_issues — team: "[ticket_team]", state: "done", updatedAt: "-P7D", limit: 50
2. list_issues — team: "[ticket_team]", state: "in progress", limit: 30
3. list_projects — team: "[ticket_team]", updatedAt: "-P7D", limit: 20

For each completed issue, capture: ID, title, project name (if any), and a brief description of what it achieved.
For in-progress issues, capture: ID, title, project name.
For projects, capture: name, health status, and any recent milestone notes.

Write findings to .claude/state/weekly-linear.md. Format as three sections: Completed, In Progress, Project Status.
```

**Agent 2 — Granola meetings** (`subagent_type: "general-purpose"`) — *only spawn if `granola: yes`*

```
Fetch this week's meetings from Granola. Granola is the PRIMARY content source for what actually happened in meetings — use it to surface wins, decisions, and context that may not be captured in Linear.

1. Use list_meetings to find meetings from the last 7 days
2. Use get_meeting_transcript for the 3–5 most relevant meetings
3. From the transcripts, extract three things:

   a) ACCOMPLISHMENTS & DECISIONS — things that happened and matter for a weekly update:
      - Decisions made (e.g. "Decided to ship VA folders before search")
      - Stakeholder alignment achieved (e.g. "Aligned with engineering on API rate limiting approach")
      - Research completed (e.g. "Ran 3 user interviews on sequence scheduling — key finding: timezone handling is the #1 pain point")
      - Work reviewed or approved (e.g. "PRD for automation folders reviewed with Katie, green-lit for Q2")
      - Cross-team unblocking (e.g. "Unblocked app partner Zapier on webhook schema question")
      Be specific — include names, features, outcomes.

   b) CONTEXT FOR IN-PROGRESS WORK — what's actively being discussed, debated, or in flight that didn't complete yet

   c) TONE SAMPLES — 3–5 short excerpts of how the PM naturally speaks in meetings (vocabulary, sentence rhythm, how they frame impact or progress). These are used to match voice in the written update.

Write findings to .claude/state/weekly-granola.md with three clear sections: "Accomplishments & Decisions", "In-Progress Context", and "Tone Samples".
If Granola MCP tools are unavailable, write "Granola unavailable" to the file and continue.
```

If `granola: no`, skip Agent 2 and write `.claude/state/weekly-granola.md` with: "Granola not configured."

---

## Step 2: Ask clarifying questions

After both agents return, read the research files. Then use `AskUserQuestion` to ask all questions at once — tailor based on what the data shows:

- "What's your biggest win this week? Anything else I should highlight?"
- "What are your 1-3 most important priorities for next week? What does 'done' look like for each?"
- "Any blockers or challenges where you need support?"
- "Anything you learned this week worth including?"

Keep these confirmation-style where possible — reference specific items from the research so the user can quickly confirm or correct.

---

## Step 3: Draft via copywriter

Spawn a **copywriter** Task agent (`subagent_type: "copywriter"`) with all gathered context:

```
Write a weekly Lattice check-in for a PM. I'm providing two content sources — Linear and Granola — plus tone samples and the PM's own clarifications.

First, read the style guide at `.claude/pm-skills/communication-styles/style-weekly-update.md` — it defines the structure, section rules, and voice.

## Linear Activity
[Insert contents of .claude/state/weekly-linear.md]

## Granola Meetings — Accomplishments, Decisions & Tone
[Insert contents of .claude/state/weekly-granola.md]

## PM's Clarifications
[Insert answers from Step 2]

---

Both Linear AND Granola are content sources. Linear captures shipped tickets and in-progress work; Granola captures decisions made, stakeholder alignment, research completed, and cross-team unblocking — things that are real wins but may not have Linear tickets. Treat both equally when deciding what goes in "What's going well" and "Align on expectations".

Use the Granola tone samples to match voice — vocabulary, energy, how outcomes are framed. This should sound like the PM dashed it off themselves, not like an AI summary.

Omit optional sections (challenges, learnings, support asks) unless the PM provided genuine content for them.

Return the complete check-in text, ready to paste into Lattice.
```

---

## Step 4: Save and open

Take the copywriter's output and:
1. Save to `weekly-updates/YYYY-MM-DD.md` (today's date)
2. Open: `code weekly-updates/<filename>.md`

---

## Step 5: Clean up

Delete temporary files:
- `.claude/state/weekly-linear.md`
- `.claude/state/weekly-granola.md`
