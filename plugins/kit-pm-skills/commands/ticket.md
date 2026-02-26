---
description: Draft and create a Linear ticket for any feature, bug, or investigation. Use this whenever something is ready to hand off to engineering — adding a feature, fixing a bug, or scoping a spike. Even a rough idea is enough: describe what you want built, what's broken, or what needs figuring out, and the command will shape it into a properly structured ticket with acceptance criteria and create it in your Linear workspace. Use this any time the user says "write a ticket", "create an issue", "raise a bug", "draft a Linear ticket", or describes work that needs to be picked up by engineering.
argument-hint: <describe the feature, bug, or investigation>
allowed-tools: [Bash, Read, AskUserQuestion]
---

# Linear Ticket Writer

Draft and create a Linear ticket from: $ARGUMENTS

## Setup

1. Run: `mkdir -p .claude/pm-skills .claude/state`
2. Read `.claude/pm-skills/config.md` if it exists. Extract and store:
   - `ticket_team` — default Linear team for tickets. Fall back to `prd_team` if not set, then `Product Backlog` if neither is set.
   - `prd_label` — label to apply (default: none)
   - `english` — British or American (default: British)

### Config check

If any of the following are missing or empty (and no valid fallback exists), collect them before proceeding. Skip entirely if all are present or can be resolved from fallbacks.

For `ticket_team`, only ask if both `ticket_team` and `prd_team` are absent — if `prd_team` is set, use it as the fallback silently. For team options, fetch from Linear first using `list_teams` if available.

| Key | Question to ask | Options |
|---|---|---|
| `ticket_team` (no `prd_team` fallback) | "Which Linear team should /ticket create issues in by default?" | Fetched teams + "Other — I'll type mine" |
| `english` | "Which English spelling do you prefer?" | "British (the correct spelling)" / "American English" |

After collecting answers, update `.claude/pm-skills/config.md`: add missing keys using the same format as existing entries. Don't reformat or remove existing values.

---

## Step 1: Detect ticket type

From `$ARGUMENTS`, determine:
- **Feature** — adding or improving functionality ("add X", "build Y", "update Z to support…")
- **Bug** — something broken or behaving incorrectly ("fix X", "404 on Y", "broken when Z")
- **Spike** — an investigation, research task, or decision to figure out ("investigate X", "research whether Y", "decide between Z approaches")

If genuinely ambiguous, ask before continuing.

---

## Step 2: Ask for missing information

Review `$ARGUMENTS` and ask only for what's genuinely missing. Keep it to 2–3 questions max — don't ask for things you can reasonably infer or draft.

**Feature — ask about what's missing:**
- Does a Figma design exist? If so, what's the link? (If design is in progress, note that)
- Any technical constraints or dependencies engineering should know about?
- If the user story isn't clear from context: who benefits, and what's the outcome they get?

**Bug — ask about what's missing:**
- Steps to reproduce, if not described
- Impact: who's affected, rough volume, and is anything blocked?
- Environment: production only, staging too, or everywhere?

**Spike — ask about:**
- What the expected output is (Slack summary, recommendation doc, PR?)
- How long to spend before checking in (timebox)

Wait for the user's answers before continuing.

---

## Step 3: Draft the ticket

Read `.claude/pm-skills/communication-styles/style-ticket.md` for the appropriate ticket template (feature, bug, or spike) and acceptance criteria guidance. If this file doesn't exist, run `/setup` first.

Write in the `english` from config. Be direct and scannable — write for engineers, not executives. One or two sentences of business context is enough; this isn't a PRD.

---

## Step 4: Review and create

Show the draft title and description to the user. Include the target team at the bottom so it's visible before they confirm:

```
---
Creating in: [ticket_team]
```

Use `AskUserQuestion` with:
- `Looks good — create it`
- `Change the target team`
- `Edit the draft`

**If "Change the target team":**
Use `list_teams` from the Linear MCP to fetch all available teams. Present them as options (up to 4, plus "Other — I'll type mine" if more exist). Store the chosen team as the target for this ticket. Do not update the config — this is a one-off override.

**If "Edit the draft":**
Ask what to change, revise, and return to the top of this step.

**Once confirmed**, create the ticket:
1. Use `save_issue` to create the issue in the target team with status **Todo**
2. If `prd_label` is set in config, apply it
3. Open the created issue in the user's browser: `open <issue URL>`
