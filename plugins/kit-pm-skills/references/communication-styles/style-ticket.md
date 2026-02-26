# Linear Ticket Style Guide

## Titles

Pattern: `[Action verb] [what]`

**Good:** "Add search to automations library", "Fix 404 on VA template button", "Investigate rate limiting strategy for API V4"

**Bad:** "Improve automations" (vague), "Bug fix" (which one?), "Add a blue search input in the top-left corner" (over-specifying the solution)

---

## Feature Ticket

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

---

## Bug Ticket

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

---

## Spike Ticket

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

---

## Acceptance Criteria Guidance

Good criteria are testable and describe outcomes, not implementation. Cover the happy path AND edge cases.

- **Good:** "User can move an automation into a folder via drag-and-drop or dropdown"
- **Bad:** "Add a blue 'Move to folder' button in the top-right corner" (that's design's job)

If you can't write acceptance criteria, the scope isn't ready — flag this to the user rather than leaving them vague.
