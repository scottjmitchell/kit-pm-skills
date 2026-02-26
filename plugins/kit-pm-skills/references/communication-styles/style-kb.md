# KB Briefing Style Guide

A KB briefing is a structured handoff document from a PM to the Knowledge Base / support writing team. Its job is to give a KB writer everything they need to produce (or update) a help article **without** needing to come back to the PM with questions.

---

## Format: New Feature

```markdown
# Knowledge Base Briefing — [Feature Name]

**Owner:** [PM name if known]
**Release date:** [Date or timeframe]
**Status:** Draft / Ready for writing

---

## Purpose of the Article

[1-2 sentences: what should the KB article help creators understand or do?]

## Audience

- [Who is affected — plan tiers, user segments, etc.]
- [Tone guidance if relevant]

---

## Key Details to Cover

### 1. What is [Feature Name]?

- [Core description — what it does, why it matters]
- [Key benefits for creators]

### 2. How It Works

- [Step-by-step walkthrough of the feature]
- [Different paths for different user types if applicable]
- [Where it lives in the app: navigation path, e.g. Automations → Rules → Add Rule]

### 3. [Additional sections as needed]

[Add sections specific to this feature — e.g. Privacy & Control, Pricing, Limitations, etc.]

### FAQs to Anticipate

- **[Question]?** — [Answer]
- **[Question]?** — [Answer]
- **[Question]?** — [Answer]

### Screenshots & Visuals Needed

- [Specific screens, states, and flows the KB writer should capture]
- [e.g. "Empty state of the automations dashboard", "Step 2 of the setup flow with validation error"]

### Messaging Priorities

1. **[Priority 1]**: [What to emphasise most]
2. **[Priority 2]**: [Secondary emphasis]
3. **[Priority 3]**: [Tertiary emphasis]

---

**Deliverable:** [Summary of what the KB writer should produce — article type, key emphasis areas]
```

---

## Format: Feature Update

```markdown
# Knowledge Base Briefing — [Feature/Change Name]

**Owner:** [PM name if known]
**Release date:** [Date or timeframe]
**Status:** Draft / Ready for writing

---

## Background

[What existed before this change. Describe the previous behaviour clearly so the KB writer understands the baseline.]

## What Changed

[Specific changes — before vs. after. Be precise about what's different.]

## Key Implications

- [Impact on existing users/workflows]
- [Do creators need to take any action?]
- [Any edge cases or gotchas]

## FAQs to Anticipate

- **[Question]?** — [Answer]
- **[Question]?** — [Answer]
- **[Question]?** — [Answer]

## Documentation Update Guidance

Writers should review and update the following articles:

### [Article title](URL)

- [Specific sections to update]
- [What language to change]
- [What to add/remove]

### [Additional articles if applicable]

- [Update guidance]

## Screenshots & Visuals Needed

- [Specific screens that show the new behaviour]

---

**Deliverable:** [Summary of updates needed — which articles, key changes, any new articles required]
```

---

## Writing Guidelines

- **Be specific and concrete** — the KB writer shouldn't need to guess
- **Include navigation paths** — e.g. `Automations → Rules → Add Rule → Trigger`
- **Call out plan-level differences explicitly** — free vs. Creator vs. Creator Pro behaviour
- **Frame FAQs as the actual question** a creator would ask, with a direct answer
- **List every screenshot/visual** the writer will need to capture, including edge cases and error states
- **For updates: be explicit about what language to change** in existing articles — quote the old text and propose the replacement where possible
- **Keep it scannable** — bullets over paragraphs, bold key terms, use headings generously
- **Spell out abbreviations** the first time (e.g. "RSS (Really Simple Syndication)")
- **Acknowledge gaps honestly** — if you're unsure about a detail, say so and flag it

---

## Quality Checklist

Before handing off a briefing, verify:

- [ ] A writer could produce the full article without asking the PM a single follow-up question
- [ ] Every step in "How It Works" is sequential and unambiguous
- [ ] All plan-tier differences are explicitly stated
- [ ] At least 3 FAQs are included
- [ ] Every screenshot needed is listed (including error states, edge cases)
- [ ] For updates: before/after is clear and all affected articles are listed
