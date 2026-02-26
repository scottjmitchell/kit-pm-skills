---
description: Build or refresh your persistent tone of voice reference from recent Granola meetings and Slack messages. Run once after setup to seed the file, then re-run any time your voice reference feels stale. /shipped and /weekly read from this file automatically rather than fetching Granola on every run. Use when the output from writing skills doesn't sound like you, or when you want to update the reference with more recent meetings.
argument-hint: (no arguments needed)
allowed-tools: [Bash, Read, Write, Task]
---

# Tone of Voice Refresh

Build or refresh the persistent tone of voice reference used by `/shipped` and `/weekly`.

## Setup

1. Run: `mkdir -p .claude/pm-skills .claude/state`
2. Read `.claude/pm-skills/config.md` if it exists. Extract `granola` — if `no` or absent, stop and tell the user:
   > `/tone` requires Granola. Set `granola: yes` in `.claude/pm-skills/config.md` and make sure the Granola MCP is configured.

If an existing `.claude/pm-skills/tone-of-voice.md` exists, note the "Last updated" date to the user before proceeding:
> Refreshing tone reference (last updated: [date])

---

## Step 1: Fetch and analyse

Spawn **two** `general-purpose` Task agents **in a single message** (`model: "sonnet"`):

**Agent 1 — Granola meetings:**

```
Analyse recent Granola meeting transcripts to extract tone of voice patterns.

1. Use list_meetings to find the 15 most recent meetings
2. Use get_meeting_transcript for the 6 most content-rich meetings — prefer meetings with substantial discussion; skip short standups or 1:1s with very little content
3. Focus on moments where the PM is explaining something, making a point, or describing an outcome — not small talk or logistics.

Extract:
- 5–7 representative excerpts (1–3 sentences each) that capture the natural speaking voice
- 5–8 key patterns: vocabulary, sentence rhythm, how impact is framed, recurring constructions

Write to .claude/state/tone-granola.md
If Granola MCP tools are unavailable, write "GRANOLA_UNAVAILABLE" to the file and stop.
```

**Agent 2 — Slack messages:**

```
Analyse recent Slack messages to extract tone of voice patterns.

1. Search for recent messages sent by the user in channels they're active in — use slack_search_public_and_private with a query like "from:me" to find recent outbound messages, or slack_read_channel on 2–3 channels where the user is active (e.g. #ecosystem-talk, #all-shipped, or similar product/team channels)
2. Focus on messages where the user is sharing an update, making a point, giving feedback, or explaining a decision — skip reactions, short acknowledgements ("sounds good", "👍"), and purely logistical messages
3. Aim to collect 15–20 substantive messages across different contexts (team updates, async decisions, product discussions)

Extract:
- 5–7 representative message excerpts (edited for brevity if needed) that capture the written async voice
- 5–8 key patterns specific to written Slack communication: how updates are structured, how tone differs from meetings, use of formatting, sign-off style

Write to .claude/state/tone-slack.md
If Slack MCP tools are unavailable, write "SLACK_UNAVAILABLE" to the file and stop.
```

---

## Step 2: Write the tone file

After both agents return, read `.claude/state/tone-granola.md` and `.claude/state/tone-slack.md`.

If `tone-granola.md` contains `GRANOLA_UNAVAILABLE`, inform the user and stop:
> Granola wasn't reachable. Check that the Granola MCP server is running and try again.

If `tone-slack.md` contains `SLACK_UNAVAILABLE`, proceed using Granola data only and note:
> Slack wasn't reachable — tone reference built from Granola only. To include Slack in future tone builds, enable the Slack integration in your claude.ai settings.

Otherwise, synthesise both files into `.claude/pm-skills/tone-of-voice.md`. The Voice Profile and Key Patterns should draw from both sources; note where patterns differ between spoken (meetings) and written (Slack) contexts if relevant:

```markdown
# Tone of Voice Reference

> Last updated: [today's date in YYYY-MM-DD]
> Sources: Granola meetings + Slack messages

## Voice Profile

[3–5 bullets synthesising patterns from both Granola and Slack]

## Representative Samples

### From meetings
[5–7 excerpts from tone-granola.md]

### From Slack
[5–7 excerpts from tone-slack.md — omit this section if SLACK_UNAVAILABLE]

## Key Patterns

[Merged bullet list from both sources. Where spoken and written patterns differ notably, call it out: e.g. "In meetings: X / In Slack: Y"]
```

Delete `.claude/state/tone-granola.md` and `.claude/state/tone-slack.md`.

---

## Step 3: Confirm

Tell the user how many samples were captured and confirm the file location:
> Tone reference saved to `.claude/pm-skills/tone-of-voice.md` — [N] samples from [N] meetings + [N] Slack messages. `/shipped` and `/weekly` will use this automatically.

If this was a refresh (file existed before), note:
> Previous reference replaced. Run `/tone` again any time to refresh.
