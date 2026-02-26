---
description: Create a PRD whenever you're scoping a new feature, writing up an idea, or documenting a product direction. Also use to revise an existing PRD by passing a Linear ticket ID (e.g. "refine ECO-123" or "flesh out PROD-76"). Use this any time the user mentions writing a spec, documenting a feature, exploring a product idea, or wanting to turn a rough Linear ticket into a proper requirements doc.
argument-hint: <feature or topic> | <ticket ID to refine>
allowed-tools: [Bash, Read, Write, Glob, Grep, Task, AskUserQuestion]
---

# Create PRD

Create a PRD (Product Requirements Document) based on: $ARGUMENTS

## Setup

Before doing anything else:

1. Run: `mkdir -p prds .claude/state`
2. Read `.claude/pm-skills/config.md` if it exists. Extract and store:
   - `prd_team` — Linear team for PRD creation (default: `Product Backlog`)
   - `prd_label` — Linear label to apply (default: none)
   - `prd_create_as` — whether to create as `issues` or `projects` (default: `issues`)
   - `feature_areas` — PM's owned features (use to focus research)
   - `english` — British or American (default: British)
3. Read `.claude/pm-skills/pricing-packaging.md` if it exists — contains plan principles used to fill the Pricing & Packaging section

### Config check

If any of the following are missing or empty, collect them before proceeding. Skip entirely if all are present.

For any missing team or label keys, fetch options from Linear first (use `list_teams` for teams, `list_issue_labels` filtered to Squad group for labels). Then ask for all missing items in a single `AskUserQuestion` call (batch up to 4 questions at once).

| Key | Question to ask | Options |
|---|---|---|
| `prd_team` | "Which Linear team should new PRDs be created in?" | Fetched teams + "Other — I'll type mine" |
| `prd_create_as` | "Should approved PRDs be created as Linear issues or projects?" | "Issue (default)" / "Project" |
| `english` | "Which English spelling do you prefer?" | "British (the correct spelling)" / "American English" |
| `feature_areas` | "What feature areas do you own? (Used to focus research)" | "Automations" / "Extensibility" / "Email Sending" / "Other — I'll describe mine" |

`prd_label` is optional — only ask if the user has previously indicated they want one, or if no label is set and it seems relevant. Don't interrupt the flow for it.

After collecting answers, update `.claude/pm-skills/config.md`: add missing keys using the same format as existing entries. Don't reformat or remove existing values.

---

## Templates & Style Guide

Before drafting, read:
- `.claude/pm-skills/communication-styles/style-prd.md` — PRD writing guidelines (voice, tone, section rules)
- `.claude/pm-skills/communication-styles/prd-template.md` — full PRD template with all sections

> If these files don't exist, run `/setup` first to install them.

---

## Instructions

### 1. Detect task type from `$ARGUMENTS`

- If it references an existing ticket ID (e.g. "refine ECO-123", "update PROD-76") → **Path B: Revision**
- Otherwise → **Path A: New PRD**

### 2. Ask clarifying questions

Ask 2–4 questions to understand the problem, affected users, constraints, and known success metrics.

Also ask: **Pricing & Packaging depth** — Is this a significant new feature or capability (→ use the full P&P assessment with background table, quadrant, plan recommendation, and competitor packaging), or a smaller iteration/improvement on an existing feature (→ use the abridged version: one-line plan recommendation with brief rationale)?

**Wait for the user's answers before proceeding.**

---

## Path A: New PRD

### A1. Launch 2 parallel research agents

Spawn **two** Task agents **in a single message**, both using `model: "haiku"`.

**Agent 1 — Internal Context** (`subagent_type: "general-purpose"`, `model: "haiku"`)

```
Search for internal context related to the feature area below.

Check:
1. Linear: Search for related tickets (list_issues with a relevant query). 3–5 searches max.
2. Existing PRDs: Scan the prds/ directory in the current workspace for related documents.
3. Feature docs: Check my-features/ in the current workspace if it exists.

Topic: [user's topic and clarifying answers]
PM's feature areas for context: [feature_areas from config, or "not configured"]

Write findings to .claude/state/prd-research-internal.md
Include: what exists today, what's in flight, relevant decisions or constraints.
```

**Agent 2 — Competitive & Market Research** (`subagent_type: "senior-research-analyst"`, `model: "haiku"`)

```
Research how competitors handle the feature area below.

Competitors to check: ActiveCampaign, Mailchimp, Beehiiv, Klaviyo — plus any others directly relevant.

Cover:
- How competitors solve this (or fail to)
- Key UX patterns and plan gating decisions
- Why users need this (creator economy context, pain at scale)
- What Kit could learn from or differentiate against
- Which plan tier(s) each competitor gates this feature behind (free, basic, paid, enterprise) — and any usage limits by tier

Topic: [user's topic and clarifying answers]

Write findings to .claude/state/prd-research-external.md
Keep it tight — key insights and actionable takeaways only.
```

> **Note on metrics:** Skip a dedicated metrics agent — data tools are often unavailable and rarely return actionable data quickly. Note data gaps inline in the PRD and flag what a Redshift query would close.

### A2. Draft the PRD

After both agents return, read:
- `.claude/state/prd-research-internal.md`
- `.claude/state/prd-research-external.md`

Draft the PRD using the template and style guide read above:
- Thorough **Problem Alignment** grounded in the research
- Informed **Solution Alignment** with clear MVP scope
- Leave **Launch** section as template checkboxes — **exception:** fill in the DMF naming item with a recommendation: **Yes** if this is a net new creator-facing feature or a significant overhaul where rebranding would add marketing value; **No** for iterations on existing features. Include a one-sentence rationale.
- Note data gaps explicitly rather than making up numbers
- For the **Pricing & Packaging** section, use `.claude/pm-skills/pricing-packaging.md` to apply the correct plan principles. Use the **full** assessment (background table + quadrant + plan recommendation + competitor packaging) if the user indicated this is a significant new feature; use the **abridged** version (one-line recommendation + brief rationale) if it's a smaller iteration. Draw on the competitive research for the Competitor Packaging sub-section when using the full format.
- Save to `prds/` with a kebab-case filename (e.g. `prds/automation-folders.md`)
- Open with `code prds/<filename>.md` then run `code --command markdown.showPreviewToSide`

### A3. Critical review

Spawn a **lewis** Task agent (`model: "opus"`) with this prompt:

```
Review this PRD. Read it at: [filepath]

Research context is available at:
- .claude/state/prd-research-internal.md
- .claude/state/prd-research-external.md

Pay particular attention to anything in the research that the PRD underweights or overlooks.
```

Present the review feedback to the user.

### A4. Clean up

After the PRD is finalised, delete:
- `.claude/state/prd-research-internal.md`
- `.claude/state/prd-research-external.md`

---

## Path B: Revision

### B1. Fetch internal context

Spawn **one** `general-purpose` Task agent (`model: "haiku"`):

```
Fetch internal context for a PRD revision.

The existing ticket is: [ticket ID from $ARGUMENTS]

Tasks:
1. Fetch the existing Linear ticket in full (use get_issue with includeRelations: true)
2. Search for 3–5 related tickets (list_issues with a targeted query)
3. Scan prds/ in the current workspace for any existing PRD file for this ticket

Write findings to .claude/state/prd-research-internal.md
Include: full ticket content, related tickets worth linking, any existing PRD file content.
```

### B2. Draft the revised PRD

After the agent returns, read `.claude/state/prd-research-internal.md`.

Using the existing ticket content, the user's revision instructions, and the template above:
- Rewrite the PRD with the changes requested
- Preserve what's already good
- Note open issues that need team input
- For the **Pricing & Packaging** section, use `.claude/pm-skills/pricing-packaging.md` to apply the correct plan principles. Use the **full** assessment if the user indicated this is a significant new feature; use the **abridged** version if it's a smaller iteration — fill in what can be inferred from the existing ticket content
- Save to `prds/` with a kebab-case filename
- Open with `code prds/<filename>.md` then run `code --command markdown.showPreviewToSide`

### B3. Critical review

Spawn a **lewis** Task agent (`model: "opus"`) with this prompt:

```
Review this revised PRD. Read it at: [filepath]

The original Linear ticket content is in: .claude/state/prd-research-internal.md

Check for: blind spots, weak assumptions, missing perspectives, unattributable metrics, and anything important from the original ticket that was dropped or underweighted.
```

Present the review to the user.

### B4. Clean up

Delete `.claude/state/prd-research-internal.md`

---

## Post-approval workflow

Once the user confirms the PRD looks good:

### Path A: New PRD

**If `prd_create_as` is `issues` (default):**
1. Create a Linear issue in the team **`[prd_team from config]`** with status **Backlog**
2. Use the PRD's H1 heading as the issue title
3. Include the full PRD content in the description, **excluding the H1 title**
4. If `prd_label` is set in config, apply that label to the issue
5. Open the newly created issue in the user's browser

**If `prd_create_as` is `projects`:**
1. Create a Linear project in the team **`[prd_team from config]`**
2. Use the PRD's H1 heading as the project name
3. Include the full PRD content in the project description, **excluding the H1 title**
4. If `prd_label` is set in config, apply that label to the project
5. Open the newly created project in the user's browser

### Path B: Revised PRD

Update the existing Linear issue (the ticket ID from `$ARGUMENTS`):
1. Use `save_issue` to update the issue description with the full revised PRD content, **excluding the H1 title**
2. Open the updated issue in the user's browser
