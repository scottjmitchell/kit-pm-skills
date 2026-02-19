---
description: Create or refine a PRD with parallel research and critical review
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
   - `feature_areas` — PM's owned features (use to focus research)
   - `english` — British or American (default: British)

If the config file doesn't exist, use defaults and note that running `/setup` first will personalise the experience.

---

## PRD Guidelines

PRDs serve engineering, design, product marketing, support, and exec. A good PRD answers:
1. What problem are we solving and why does it matter?
2. What are we building to solve it?
3. How will we know if it worked?

**Voice:** Problem-first. Confident but honest. Use the English spelling from config. Active voice. No corporate speak.

**TL;DR:** One paragraph, no bullets. Lead with user pain, not the solution. Under 100 words.

**The Problem:** Three perspectives — user friction (specific, tangible), business impact (metrics where possible), competitive context (are we behind?). Say "we don't have data" rather than making up numbers.

**Goals & Success:** 2–4 measurable metrics. "Reduce churn by 15%" not "improve retention".

**Key Features:** Bullet lists. Mark MVP vs. fast follow vs. out of scope. Be ruthless about scope.

**Open Issues:** Frame as questions. Note who needs to weigh in.

**Launch Checklist:** Leave as template checkboxes — don't fill in during drafting.

---

## PRD Template

```markdown
## TL;DR
[One paragraph. Lead with the problem, mention who it affects, state the impact, describe the approach in one sentence.]

---

## Problem Alignment

### The Problem
**User friction:** [Specific pain. Real examples if possible.]
**Business impact:** [What does this cost? Churn, support load, competitive losses?]
**Competitive context:** [How do competitors handle this? Are we behind?]

### High-level Approach
[1–3 paragraphs. Solution direction + rough scope. Mention phasing if multi-part.]

### Goals & Success
1. [Specific metric — e.g. "Reduce X from Y% to Z% within 6 months"]
2. [Adoption metric — e.g. "30% of power users adopt within 90 days"]
3. [Optional third metric]

---

## Solution Alignment

### Key Features

**MVP**
- [Feature 1]
- [Feature 2]

**Fast Follow**
- [Feature 3]

**Out of Scope**
- [Feature 4 — explain why]

### Key Flows
[Figma links, screenshots, or written descriptions of key user journeys.]

### Open Issues & Key Decisions
1. [Question — explain why unresolved, note who needs to weigh in]

---

## Launch

### Launch Checklist

**Support**
- [ ] New or updated help centre articles needed?
- [ ] Support training required?

**Data**
- [ ] Mixpanel dashboard required?
- [ ] New Segment events required?

**Product Marketing**
- [ ] Announcement needed?
- [ ] Onboarding experience needed?

**Plans**
- [ ] Available on certain plans only?

**Platform**
- [ ] New API or plugin surface area?
- [ ] Infrastructure risk?

**Design**
- [ ] Separate mobile and desktop flows?

**Legal**
- [ ] Any risk?
```

---

## Instructions

### 1. Detect task type from `$ARGUMENTS`

- If it references an existing ticket ID (e.g. "refine ECO-123", "update PROD-76") → **Path B: Revision**
- Otherwise → **Path A: New PRD**

### 2. Ask clarifying questions

Ask 2–4 questions to understand the problem, affected users, constraints, and known success metrics.

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

Topic: [user's topic and clarifying answers]

Write findings to .claude/state/prd-research-external.md
Keep it tight — key insights and actionable takeaways only.
```

> **Note on metrics:** Skip a dedicated metrics agent — data tools are often unavailable and rarely return actionable data quickly. Note data gaps inline in the PRD and flag what a Redshift query would close.

### A2. Draft the PRD

After both agents return, read:
- `.claude/state/prd-research-internal.md`
- `.claude/state/prd-research-external.md`

Draft the PRD using the template and guidelines above:
- Thorough **Problem Alignment** grounded in the research
- Informed **Solution Alignment** with clear MVP scope
- Leave **Launch** section as template checkboxes
- Note data gaps explicitly rather than making up numbers
- Save to `prds/` with a kebab-case filename (e.g. `prds/automation-folders.md`)
- Open with `open prds/<filename>.md`

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
- Save to `prds/` with a kebab-case filename
- Open with `open prds/<filename>.md`

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

## Post-approval workflow (both paths)

Once the user confirms the PRD looks good:
1. Create a Linear issue in the team **`[prd_team from config]`** with status **Backlog**
2. Use the PRD's H1 heading as the issue title
3. Include the full PRD content in the description, **excluding the H1 title**
4. If `prd_label` is set in config, apply that label to the issue
5. Open the newly created issue in the user's browser
