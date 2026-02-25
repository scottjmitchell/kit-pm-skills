# Communication Style: Product Requirements Documents (PRDs)

## Purpose

A PRD is the definitive source of truth for what we're building and why. It serves multiple audiences:

- **Exec team**: Needs the business case and metrics impact
- **Engineering**: Needs enough clarity to scope and build
- **Design**: Needs problem context to explore solutions
- **Product Marketing**: Needs the value prop for positioning
- **Support**: Needs to understand what's changing for customers

Write a PRD when you're proposing a new feature, significant change to existing functionality, or multi-sprint project. Don't write PRDs for bug fixes or tiny iterations.

A good PRD answers three questions:
1. What problem are we solving and why does it matter?
2. What are we building to solve it?
3. How will we know if it worked?

## Format Rules

### TL;DR

This is your elevator pitch. One paragraph, no subheadings, no bullet points. Anyone at Kit should be able to read this and understand what you're proposing — from the CEO to someone in Support who's never touched your feature area.

**How to write it:**
- Lead with the problem, not the solution
- State who it affects (e.g., "Creators with 50+ automations...")
- Explain the impact (user friction + business cost)
- Mention the approach in one sentence
- Keep it under 100 words

**Good example:**
"Creators with large automation setups struggle to manage them because there's no way to search, filter, or organise workflows. This causes churn amongst power users and makes Kit feel less capable than competitors like ActiveCampaign. We're building folders and search for the automations library so creators can scale their usage without hitting organisational limits."

**Bad example:**
"This PRD proposes enhancements to the automations experience including search and organisational features to improve usability."

The bad example is vague ("enhancements"), doesn't explain the problem, and uses filler words ("including", "to improve usability").

### The Problem

This section sells the **why**. You need to convince the reader this problem is worth solving.

**Structure it with three perspectives:**

1. **User friction**: What pain are creators experiencing? Be specific. Use real examples or support tickets if possible.

2. **Business impact**: What does this cost us? Churn? Lower expansion? Support load? Competitive losses?

3. **Competitive context**: How do competitors handle this? Are we behind or ahead? Why does that matter?

**How to write it:**
- Start with the user pain — make it tangible
- Connect it to business metrics where possible (e.g., "Power users with 50+ automations churn at 2x the rate of average users")
- Reference specific competitors when relevant
- Be honest about what you don't know — "We believe X based on Y, but need to validate Z"

**What to avoid:**
- Starting with the solution ("We need folders because...")
- Vague complaints ("The experience isn't great")
- Skipping competitive context when you're clearly behind
- Making up impact numbers — if you don't have data, say so

### High-level Approach

Give just enough detail for the reader to imagine possible solutions and understand scope. This is not the place for wireframes or technical specs.

**How to write it:**
- One to three paragraphs maximum
- Describe the solution direction (e.g., "Add folders and search to the automations library")
- Mention big technical or design constraints if relevant
- Call out phasing if the solution is multi-part (e.g., "We'll launch folders first, search in a fast follow")

**What to avoid:**
- Detailed feature specs (that's what Key Features is for)
- Implementation details ("We'll use Elasticsearch...") unless it's a critical constraint
- Hedging language ("We might consider possibly adding...") — be direct

### Goals & Success

Define what success looks like with specific, measurable outcomes.

**How to write it:**
- Pick 2-4 metrics that matter
- Be specific: "Reduce automation churn by 15%" is better than "Improve retention"
- Explain why each metric matters if it's not obvious
- Include both user behaviour metrics (adoption, usage) and business metrics (revenue, churn)
- Call out leading indicators (e.g., "30% of power users create at least one folder within 30 days")

**Good examples:**
- "Reduce churn amongst creators with 50+ automations from 8% to 5% within 6 months"
- "30% of creators with 10+ automations use folders within 90 days of launch"
- "Reduce support tickets about 'finding automations' by 50%"

**Bad examples:**
- "Improve the automations experience" (not measurable)
- "Increase engagement" (too vague)
- "Delight users" (not a metric)

### Key Features

This is where you describe what you're building. Organise features logically and prioritise them so engineering knows what's in scope.

**How to write it:**
- Use bullet points or numbered lists
- Group related features under subheadings if helpful
- Mark priority levels (MVP, fast follow, future) if phasing matters
- Describe each feature in 1-2 sentences
- Include what you're **not** building if it's a common expectation

**What to avoid:**
- Paragraphs — use lists
- Ambiguous priority (is it in or out?)
- Feature bloat — if something isn't core to solving the problem, push it to fast follow

### Key Flows

Show the experience. Use Figma embeds, screenshots, or written descriptions of user flows.

**When to include mocks:**
- When the interaction is novel or complex
- When design is exploring multiple directions and you need feedback
- When stakeholders need to see it to understand it

**When to skip mocks:**
- When it's early and you're still validating the problem
- When the pattern is standard (e.g., "a modal with a text input" doesn't need a mock)

**If you don't have mocks yet**, describe the key flows in plain language:
- "User clicks 'New Folder', enters a name, and sees the folder appear in the sidebar"
- "User drags an automation onto a folder to move it"

### Open Issues & Key Decisions

Use this section to track questions that need team input or decisions you haven't made yet.

**How to write it:**
- Frame each issue as a question or decision point
- Explain why it's unresolved (e.g., "Need engineering input on feasibility")
- Note who needs to weigh in
- Update this section as decisions are made

### Launch Checklist

Don't fill this in during drafting — it's for later when you're closer to launch. Use it to track dependencies and handoffs across Support, Data, Product Marketing, Plans, Platform, Design, and Legal.

---

## Voice & Tone

PRDs should feel **professional but not stiff**. You're writing for a cross-functional audience, so clarity is paramount.

- **Problem-focused**: Start with the user pain and business impact, not the solution you've fallen in love with
- **Confident but honest**: State things directly. If something is uncertain, say so — don't hedge with "maybe" and "perhaps" everywhere, but don't pretend you have answers you don't
- **Conversational but structured**: Write like you're explaining the project to a smart colleague, not like you're writing a textbook
- **Active voice**: "We're building folders" not "Folders will be built"
- **Systems thinking**: Show you've considered how this fits into the broader product and business

**Tone for each section:**
- **TL;DR**: Clear, direct, high-level — imagine explaining it to the CEO in a hallway
- **The Problem**: Compelling and urgent — make the reader care
- **High-level Approach**: Pragmatic and scoped — show you've thought about the MVP
- **Goals & Success**: Specific and measurable — no hand-waving
- **Key Features**: Organised and actionable — engineering should know what to build

## Word Choice

### Preferred Terms
- "MVP approach" (when scoping down)
- "Fast follow" (for features after initial launch)
- "Feature flag" (when phasing rollout)
- "Run in parallel" (when workstreams are independent)
- "In scope" / "Out of scope" (for feature decisions)
- "Leading indicator" (for early success signals)
- "Power users" (for high-engagement creators)

### Terms to Avoid
- **Jargon without context**: If you use technical terms, add a brief clarifier
- **Hedging language**: "We're building folders" not "We might consider potentially adding folders"
- **Vague intensifiers**: "Very", "really", "quite" rarely add value
- **Corporate speak**: "Leverage", "synergy", "ideate", "circle back" — write like a human
- **American spellings**: Use British English throughout ("organised", "behaviour", "colour")

### Quantifying Impact
- Good: "Reduce churn by 15%", "30% adoption within 90 days"
- Acceptable: "Based on competitor research, we estimate 25-40% of power users would adopt this"
- Bad: "This will significantly improve engagement"

If you don't have data, say so: "We don't have data on this yet, but based on support tickets and competitor benchmarking, we believe this is a top-5 pain point for power users."

## Common Mistakes

### 1. Solution-first PRDs
Jumping straight to "We're building folders" without explaining why. Always start with the problem. Make the reader feel the pain before you present the solution.

### 2. Vague Success Metrics
"Improve engagement", "Increase satisfaction", "Better retention" — you can't measure success or prioritise the work. Pick specific numbers. If you don't have data, estimate and say it's an estimate.

### 3. Missing Competitive Context
Not mentioning that ActiveCampaign and Mailchimp both have this feature and we don't. Competitive pressure is a valid reason to build something.

### 4. Scope Creep in Key Features
Listing 20 features with no prioritisation. Be ruthless about the MVP. Move nice-to-haves to "fast follow" or "future".

### 5. TL;DRs That Are Too Long or Too Vague
One paragraph. Lead with the problem. Make it understandable to anyone at Kit.

## Example

**Input:** Creators with many automations (50+) struggle to find and manage them. There's no search, no folders, no way to organise. Power users are churning because the experience doesn't scale. Competitors like ActiveCampaign have folders and search.

**Output:**

# Automation Folders & Search

## TL;DR
Creators with large automation setups (50+) struggle to manage them because there's no way to search, filter, or organise workflows. This drives churn amongst our highest-value users and makes Kit feel less capable than competitors like ActiveCampaign, which offer folders and search. We're adding folders and search to the automations library so power users can scale their usage without hitting organisational limits.

---

## Problem Alignment

### The Problem

**User friction**: Creators who rely heavily on automations hit a wall as their library grows. With 50+ automations, there's no way to find a specific workflow quickly, no way to group related automations, and no visual hierarchy. Users resort to naming hacks (prefixing automations with "01_", "02_") or keeping external spreadsheets to track their setup. This friction slows down their work and makes Kit feel unscalable.

**Business impact**: Power users with 50+ automations churn at roughly 2x the rate of the average creator. These are high-value customers — they're typically running established businesses and paying for higher-tier plans. When they leave, it's often because they've hit the limits of our tooling and moved to a platform that can handle complexity. Support tickets about "finding automations" and "organising workflows" have increased 40% year-over-year as our power user segment grows.

**Competitive context**: ActiveCampaign, Mailchimp, and Klaviyo all offer folders and search for automations. ActiveCampaign in particular leans into this as a selling point for "serious marketers" — their UI makes organisation a first-class feature. We're visibly behind here, and it comes up in churn interviews and competitive win/loss analysis.

### High-level Approach

We're adding **folders** and **search** to the automations library. Folders will let creators organise automations into a hierarchy (supporting nested folders up to 3 levels deep). Search will filter across automation names and folder names in real time. We'll launch folders first (they solve the immediate pain) and follow up with search in a fast follow release.

This builds on our existing automations infrastructure — no major architectural changes required.

### Goals & Success

1. **Reduce churn amongst power users**: Drop churn for creators with 50+ automations from 8% to 5% within six months of launch.
2. **Drive adoption**: 30% of creators with 10+ automations create at least one folder within 90 days of launch.
3. **Reduce support load**: Cut support tickets related to "finding automations" by 50% within three months.

---

## Solution Alignment

### Key Features

**MVP (Folders)**
- Create, rename, and delete folders
- Nested folders (up to 3 levels deep)
- Drag-and-drop automations into folders
- Drag-and-drop to reorder folders
- Bulk move: select multiple automations and move them to a folder at once
- Folder state persists per user (collapsed folders stay collapsed)

**Fast Follow (Search)**
- Real-time search across automation names and folder names
- Filter by folder in the main automations view

**Future / Not in Scope for V1**
- Tags for automations (overlaps with folders; adds conceptual complexity)
- Sharing folders across team members (requires multi-user permissions work)
- Automation templates organised by folder (separate project)
- Colour-coding folders (nice-to-have, not solving the core problem)

### Key Flows

**Creating a folder:**
1. User clicks "New Folder" in the automations library sidebar
2. Inline input appears; user types folder name and hits Enter
3. Folder appears in the sidebar, expanded by default

**Organising automations:**
1. User drags an automation from the main list onto a folder in the sidebar
2. Automation moves into the folder; folder badge updates with count
3. User can expand/collapse folders to show/hide contents

Figma link: [To be added by Design]

### Open Issues & Key Decisions

1. **Do we allow unlimited nesting or cap at 3 levels?** Current plan: Cap at 3. Engineering flagged performance concerns with deep nesting. Revisit if users request more depth.
2. **Should folders be account-level or user-level?** Current plan: User-level. Avoids permissions complexity. Trade-off: Teams can't share a canonical folder structure.
3. **Do we build search in the MVP or fast follow?** Current plan: Fast follow. Folders solve the immediate pain. Splitting lets us ship faster and validate adoption.
4. **How do we handle automations when a folder is deleted?** Needs design input: Move to root level, or prevent deleting non-empty folders?

---

## Launch

### Launch Checklist

- [ ] **Support**: Update help docs, train support team on new folder features
- [ ] **Data**: Confirm tracking for folder creation, automation moves, search usage
- [ ] **Product Marketing**: Draft announcement (email, in-app, blog post)
- [ ] **Plans**: No plan gating required (available to all users)
- [ ] **Platform**: Feature flag for gradual rollout
- [ ] **Design**: Final mocks approved, components added to design system
- [ ] **Legal**: No legal review required (internal feature, no external data)
