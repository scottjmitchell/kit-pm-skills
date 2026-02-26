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

## Pricing & Packaging

### Feature Assessment
| Question | Response | Notes |
|---|---|---|
| What does this feature help creators do? | | |
| Highly requested? | Yes / No | |
| Primary creator segment? | Just starting out / Established / Enterprise / All | |
| Advanced versions planned? | Yes / No | |
| Differentiation level? | Table stakes / Critical / Differentiating | |
| Annual cost to Kit? | Free / Low / Medium / High | |

**Quadrant:** [Table-stakes / Differentiator / Nice-to-have / Dissatisfier — 1–2 sentence rationale]

### Plan Recommendation
**Recommended plan:** [Free / Creator / Creator Pro / All plans]

**Rationale:** [Which plan principles does this satisfy? Be specific.]

### Competitor Packaging
[How do key competitors package this feature? Which plan tiers gate access? Any usage limits at lower tiers?]

> **Abridged alternative** (for smaller iterations/improvements — use instead of the full section above):
>
> ```markdown
> ## Pricing & Packaging
> **Recommended plan:** [Free / Creator / Creator Pro / All plans]
> **Rationale:** [1–2 sentences: which plan principles this satisfies and any relevant competitor context]
> ```

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
- [ ] Does this feature need a name? (DMF) — **Recommended: Yes / No** — [rationale]

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

Draft the PRD using the template and guidelines above:
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
