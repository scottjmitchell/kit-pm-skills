---
description: Build or refresh your persistent tone of voice reference from recent Granola meetings. Run once after setup to seed the file, then re-run any time your voice reference feels stale. /shipped and /weekly read from this file automatically rather than fetching Granola on every run. Use when the output from writing skills doesn't sound like you, or when you want to update the reference with more recent meetings.
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

Spawn one `general-purpose` Task agent (`model: "sonnet"`):

```
Build a tone of voice reference from recent Granola meeting transcripts.

1. Use list_meetings to find the 15 most recent meetings
2. Use get_meeting_transcript for the 6 most content-rich meetings — prefer meetings with substantial discussion; skip short standups or 1:1s with very little content
3. From the transcripts, analyse natural communication patterns. Focus on moments where the PM is explaining something, making a point, or describing an outcome — not small talk or logistics.

Extract and organise findings into three sections:

**Voice Profile** (3–5 bullet points):
A concise summary of the overall communication style — e.g. directness, energy level, how confidence is expressed, how technical depth is handled.

**Representative Samples** (8–10 excerpts):
Short excerpts (1–3 sentences each) that best capture the natural speaking voice. Include variety — some about product decisions, some about progress/outcomes, some about challenges. Do not attribute or add commentary — just the excerpts.

**Key Patterns** (bullet list):
Specific, observable patterns: preferred vocabulary, sentence rhythm, how impact is framed, level of formality, recurring phrases or constructions to use or avoid.

Write to .claude/state/tone-raw.md with those three sections as headers.
If Granola MCP tools are unavailable, write "GRANOLA_UNAVAILABLE" to the file and stop.
```

---

## Step 2: Write the tone file

After the agent returns, read `.claude/state/tone-raw.md`.

If it contains `GRANOLA_UNAVAILABLE`, inform the user and stop:
> Granola wasn't reachable. Check that the Granola MCP server is running and try again.

Otherwise, write `.claude/pm-skills/tone-of-voice.md`:

```markdown
# Tone of Voice Reference

> Last updated: [today's date in YYYY-MM-DD]

## Voice Profile

[Voice Profile section from tone-raw.md]

## Representative Samples

[Representative Samples from tone-raw.md]

## Key Patterns

[Key Patterns from tone-raw.md]
```

Delete `.claude/state/tone-raw.md`.

---

## Step 3: Confirm

Tell the user how many samples were captured and confirm the file location:
> Tone reference saved to `.claude/pm-skills/tone-of-voice.md` — [N] samples from [N] meetings. `/shipped` and `/weekly` will use this automatically.

If this was a refresh (file existed before), note:
> Previous reference replaced. Run `/tone` again any time to refresh.
