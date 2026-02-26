---
description: Draft and create a Linear ticket for any feature, bug, or investigation. Use this whenever something is ready to hand off to engineering — adding a feature, fixing a bug, or scoping a spike. Even a rough idea is enough: describe what you want built, what's broken, or what needs figuring out, and the command will shape it into a properly structured ticket with acceptance criteria and create it in your Linear workspace. Use this any time the user says "write a ticket", "create an issue", "raise a bug", "draft a Linear ticket", or describes work that needs to be picked up by engineering.
argument-hint: <describe the feature, bug, or investigation>
allowed-tools: [Bash, Read, AskUserQuestion]
---

# Linear Ticket Writer

Draft and create a Linear ticket from: $ARGUMENTS

## Setup

Read `.claude/pm-skills/config.md` if it exists. Extract and store:
- `ticket_team` — default Linear team for tickets. Fall back to `prd_team` if not set, then `Product Backlog` if neither is set.
- `prd_label` — label to apply (default: none)
- `english` — British or American (default: British)

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

Write in the `english` from config. Be direct and scannable — write for engineers, not executives. One or two sentences of business context is enough; this isn't a PRD.

### Title

Pattern: `[Action verb] [what]`

Good: "Add search to automations library", "Fix 404 on VA template button", "Investigate rate limiting strategy for API V4"

Bad: "Improve automations" (vague), "Bug fix" (which one?), "Add a blue search input in the top-left corner" (over-specifying the solution)

### Feature ticket

```
**User Story**
As a [persona], I want to [goal], so that [benefit].

**Context**
[1–2 sentences: why now? What prompted this?]

**Acceptance Criteria**
- [ ] [Happy path condition]
- [ ] [Edge case]
- [ ] [Error state if relevant]
- [ ] [Additional condition]

**Design**
[Figma link — or "Design in progress" if not yet final]

**Technical Notes**
[Only include if there's something engineering needs to know — constraints, dependencies, known gotchas. Omit entirely if nothing to add.]

**Out of Scope**
[What this ticket explicitly does NOT include — prevents scope creep]
```

### Bug ticket

```
**What's Happening**
[Observed behaviour in 1–2 sentences]

**What Should Happen**
[Expected behaviour]

**Steps to Reproduce**
1. [Step]
2. [Step]
3. [Step]

**Environment**
[Production / Staging / All environments]

**Impact**
[Who's affected? Rough volume? Is it blocking revenue, data, or a core workflow?]

**Screenshots / Links**
[If relevant — omit section if nothing to add]
```

### Spike ticket

```
**Question to Answer**
[Specific question — what exactly do we need to figure out?]

**Context**
[Why do we need this now?]

**Suggested Approach**
[Optional — ideas on how to investigate. Omit if none.]

**Expected Output**
[What does "done" look like? A Slack post in #ecosystem-eng? A recommendation doc? A PR?]

**Timebox**
[How long to spend before checking in]

**Resources**
[Relevant links, docs, or code pointers — omit section if none]
```

### Acceptance criteria guidance (feature tickets)

Good criteria are testable and describe outcomes, not implementation. Cover the happy path AND edge cases.

- Good: "User can move an automation into a folder via drag-and-drop or dropdown"
- Bad: "Add a blue 'Move to folder' button in the top-right corner" (that's design's job)

If you can't write acceptance criteria, the scope isn't ready — flag this to the user rather than leaving them vague.

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
