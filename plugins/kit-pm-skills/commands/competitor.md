---
description: Research and produce a competitor analysis for any feature area or topic. Use this when you need competitive context for a PRD, are exploring a new feature area, responding to competitive pressure, or want to understand how competitors approach a specific problem. Even a vague topic works — describe the area and this command will identify relevant competitors, research their current state, and produce an insight-driven analysis following Kit's style guide. Use any time the user mentions "how do competitors handle X", "what does Beehiiv/Mailchimp/ActiveCampaign do with X", "competitive analysis", or "where does Kit stand on X compared to the market".
argument-hint: <feature area or topic, e.g. "automation folders" or "pricing page">
allowed-tools: [Bash, Read, Write, Glob, Grep, Task, AskUserQuestion]
---

# Competitor Analysis

Research and produce a competitor analysis for: $ARGUMENTS

## Setup

1. Run: `mkdir -p competitor-analysis .claude/state`
2. Read `.claude/pm-skills/config.md` if it exists. Extract and store:
   - `feature_areas` — PM's owned features (used to focus research and Kit's current state)
   - `english` — British or American (default: British)

### Config check

If any of the following are missing, ask and save before continuing. Skip if all are present.

| Key | Question | Options |
|---|---|---|
| `feature_areas` | "What feature areas do you own? (Helps focus Kit's current state research)" | "Automations" / "Extensibility" / "Email Sending" / "Other — I'll describe mine" |
| `english` | "Which English spelling do you prefer?" | "British (the correct spelling)" / "American English" |

After collecting, update `.claude/pm-skills/config.md` — add missing keys without reformatting existing values.

---

## Step 1: Clarifying questions

Use `AskUserQuestion` to ask both questions:

**Q1:** "What's the context for this analysis?"
- `Competitive context for a PRD`
- `Responding to competitive pressure on a specific feature`
- `Exploring a new feature area`
- `Standalone strategic reference`

**Q2:** "How much depth do you need?"
- `Full analysis — TL;DR, landscape, feature table, insights, gaps, recommendations`
- `Quick snapshot — feature table + key takeaways (good for dropping into a PRD)`

Store both answers. Wait before continuing.

---

## Step 2: Identify competitors

Default competitor set: **ActiveCampaign, Mailchimp, Beehiiv, Klaviyo**.

Adjust based on the topic — add competitors directly relevant to the feature area even if not in the default set (e.g. Substack for newsletters, ConvertKit-era comparisons for creator monetisation). If the user mentioned specific competitors in `$ARGUMENTS`, prioritise those.

---

## Step 3: Launch parallel research agents

Spawn all agents in a single message. Use `model: "haiku"` for all.

**Agent 1 — Kit's current state** (`subagent_type: "general-purpose"`)

```
Research Kit's current state for the following topic: [TOPIC FROM $ARGUMENTS]

1. Search my-features/ in the current workspace for relevant feature documentation
2. Search competitor-analysis/ for any prior analysis on this topic
3. Search prds/ for related PRDs that describe current or planned behaviour

Feature areas to focus on: [feature_areas from config, or "not specified"]

Write findings to .claude/state/competitor-kit.md
Include: what Kit currently offers, known gaps, any in-flight work, relevant PRD context.
```

**Agent 2 — ActiveCampaign & Klaviyo** (`subagent_type: "senior-research-analyst"`)

```
Research how ActiveCampaign and Klaviyo handle the following topic: [TOPIC FROM $ARGUMENTS]

For each competitor, cover:
- Current feature state — what do they offer today?
- UX patterns and notable design decisions
- Plan gating — what's free vs paid? Usage limits by tier?
- How they position or message this capability
- Any differentiators or weaknesses worth noting

Write findings to .claude/state/competitor-ac-klaviyo.md
Be specific — describe actual features, not marketing copy.
```

**Agent 3 — Mailchimp & Beehiiv** (`subagent_type: "senior-research-analyst"`)

```
Research how Mailchimp and Beehiiv handle the following topic: [TOPIC FROM $ARGUMENTS]

For each competitor, cover:
- Current feature state — what do they offer today?
- UX patterns and notable design decisions
- Plan gating — what's free vs paid? Usage limits by tier?
- How they position or message this capability
- Any differentiators or weaknesses worth noting

Write findings to .claude/state/competitor-mailchimp-beehiiv.md
Be specific — describe actual features, not marketing copy.
```

**Agent 4 — Additional competitors** (only spawn if there are relevant competitors beyond the default set)

```
Research how [ADDITIONAL COMPETITORS] handle the following topic: [TOPIC FROM $ARGUMENTS]

[Same research brief as Agent 2]

Write findings to .claude/state/competitor-additional.md
```

---

## Step 4: Check completeness

After all agents return, read all research files. If any competitor's coverage is thin or missing for the specific topic, note gaps inline in the draft rather than re-researching — better to say "Beehiiv does not appear to offer this capability" than to leave a blank.

---

## Step 5: Draft the analysis

Write in `english` from config. Follow the style guide: insight-driven, not a feature checklist. Every comparison should lead to a "so what". Be honest about gaps.

**Always include Kit in the feature comparison table**, even when Kit has nothing.

---

### Full analysis format

```markdown
# Competitor Analysis: [Topic]

**Date**: [Month YYYY]
**Context**: [One sentence on what prompted this — PRD context, strategic review, etc.]

---

## TL;DR

[One paragraph. The key competitive insight — not a summary of every section, but the most important thing to understand from this analysis.]

---

## Competitive Landscape

- **ActiveCampaign**: [2–3 sentences on positioning, target audience, how they approach this space]
- **Klaviyo**: [2–3 sentences]
- **Mailchimp**: [2–3 sentences]
- **Beehiiv**: [2–3 sentences]
- **[Others if included]**: [2–3 sentences]

---

## Feature Comparison

| Feature | ActiveCampaign | Klaviyo | Mailchimp | Beehiiv | Kit |
|---------|---------------|---------|-----------|---------|-----|
| [Feature group] | | | | | |
| [Feature] | | | | | |

Use: Yes / No / Partial / [short phrase]. Group features logically — not a flat list.

---

## Key Insights

[Interpretation, not facts restated. What patterns emerge? What do competitors' choices reveal about their strategy? What does this mean for the market? 3–5 paragraphs or well-structured bullets.]

---

## Gaps & Opportunities

**Where Kit is behind:**
[Be direct. "Kit lacks X, which is a table-stakes expectation for power users."]

**Where Kit is ahead or differentiated:**
[Acknowledge strengths honestly. Don't invent them.]

**Opportunities:**
[Frame gaps as opportunities — "Kit lacks X, which is an opportunity to differentiate by doing Y"]

---

## Recommendations

[Specific and actionable. What should Kit actually do based on this analysis? Prioritised if possible.]

1. [Recommendation]
2. [Recommendation]
3. [Recommendation]

**Timing note**: [If relevant — when does this need to happen given competitive context?]
```

---

### Quick snapshot format

```markdown
# Competitor Snapshot: [Topic]

**Date**: [Month YYYY]

## TL;DR

[One paragraph — the key competitive insight.]

## Feature Comparison

| Feature | ActiveCampaign | Klaviyo | Mailchimp | Beehiiv | Kit |
|---------|---------------|---------|-----------|---------|-----|

## Key Takeaways

- [Insight + implication for Kit]
- [Insight + implication for Kit]
- [Insight + implication for Kit]
- [Recommendation]
```

---

### After drafting

Save to `competitor-analysis/` with filename: `YYYY-MM-DD-[topic-slug].md`

Open: `code competitor-analysis/<filename>.md` then `code --command markdown.showPreviewToSide`

---

## Step 6: Critical review (full analysis only)

For full analyses, spawn a **lewis** Task agent (`model: "opus"`):

```
Review this competitor analysis. Read it at: [filepath]

Research context is available at:
- .claude/state/competitor-kit.md
- .claude/state/competitor-ac-klaviyo.md
- .claude/state/competitor-mailchimp-beehiiv.md

Pay particular attention to:
- Any competitor claims that seem unsubstantiated or need caveating
- Key insights that aren't drawn from the research
- Gaps in the analysis — competitors or angles not covered
- Whether the Recommendations follow logically from the Gaps & Opportunities
```

Present the review to the user.

---

## Step 7: Clean up

Delete all temporary files:
- `.claude/state/competitor-kit.md`
- `.claude/state/competitor-ac-klaviyo.md`
- `.claude/state/competitor-mailchimp-beehiiv.md`
- `.claude/state/competitor-additional.md` (if created)
